#!/bin/bash
# =============================================================
#  Wazuh Agent Installer — Linux (KKU ODT)
# =============================================================
#
#  วิธีดาวน์โหลด:
#    curl -O https://raw.githubusercontent.com/FIGOHIGHWAY/wazuh-agent-deploy-kku/main/_wazuh_install_core.sh
#
#  วิธีติดตั้ง:
#    sudo bash _wazuh_install_core.sh
#
#  หรือดาวน์โหลดและรันในคำสั่งเดียว:
#    curl -s https://raw.githubusercontent.com/FIGOHIGHWAY/wazuh-agent-deploy-kku/main/_wazuh_install_core.sh | sudo bash
#
#  Script จะถาม:
#    1. Group     (เช่น ODTLIB4F, VMODT)
#    2. Agent name (เช่น LIB4F-PC01)
#
# =============================================================

MANAGER="10.101.102.243"
VER="4.10.1-1"

# ── Privilege check ──
if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] Run as root (sudo)"
    exit 1
fi

# ── Group (manual input if not pre-set) ──
if [[ -z "$GROUP" ]]; then
    read -rp "Group (e.g. ODTLIB4F): " GROUP </dev/tty
fi
if [[ -z "$GROUP" ]]; then
    echo "[ERROR] Group cannot be empty"
    exit 1
fi

# ── Agent name (manual input) ──
if [[ -z "$AGENT_NAME" ]]; then
    read -rp "Agent name (e.g. LIB4F-PC01): " AGENT_NAME </dev/tty
fi
if [[ -z "$AGENT_NAME" ]]; then
    echo "[ERROR] Agent name cannot be empty"
    exit 1
fi

# ── Detect distro ──
if   [[ -f /etc/debian_version ]]; then DISTRO=debian
elif [[ -f /etc/redhat-release ]]; then DISTRO=rhel
elif [[ -f /etc/arch-release ]];   then DISTRO=arch
else
    echo "[ERROR] Unsupported distro"
    exit 1
fi

echo "=============================="
echo " Wazuh Agent Installer (Linux)"
echo " Agent  : $AGENT_NAME"
echo " Group  : $GROUP"
echo " Manager: $MANAGER"
echo " Distro : $DISTRO"
echo "=============================="
echo

# ── Skip if already installed ──
if systemctl list-units --type=service | grep -q wazuh-agent; then
    echo "[WARN] Wazuh already installed. Skipping."
    exit 0
fi

# ── Add Wazuh repo & install ──
echo "[1/3] Adding Wazuh repository..."

case $DISTRO in
  debian)
    curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH \
        | gpg --dearmor -o /usr/share/keyrings/wazuh.gpg
    echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] \
https://packages.wazuh.com/4.x/apt/ stable main" \
        > /etc/apt/sources.list.d/wazuh.list
    apt-get update -qq
    echo "[2/3] Installing..."
    WAZUH_MANAGER="$MANAGER" apt-get install -y wazuh-agent=$VER
    ;;
  rhel)
    rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH
    cat > /etc/yum.repos.d/wazuh.repo <<EOF
[wazuh]
name=Wazuh
baseurl=https://packages.wazuh.com/4.x/yum/
enabled=1
gpgcheck=1
gpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH
EOF
    echo "[2/3] Installing..."
    WAZUH_MANAGER="$MANAGER" yum install -y wazuh-agent-$VER
    ;;
  arch)
    echo "[2/3] Installing via AUR..."
    # Assumes paru or yay is available
    AUR_HELPER=$(command -v paru || command -v yay)
    if [[ -z "$AUR_HELPER" ]]; then
        echo "[ERROR] AUR helper (paru/yay) not found"
        exit 1
    fi
    WAZUH_MANAGER="$MANAGER" sudo -u "${SUDO_USER:-$USER}" "$AUR_HELPER" -S --noconfirm wazuh-agent
    ;;
esac

if [[ $? -ne 0 ]]; then
    echo "[ERROR] Install failed"
    exit 1
fi

# ── Set agent name & group via enrollment config (Wazuh 4.x) ──
CONF=/var/ossec/etc/ossec.conf

sed -i "s|<address>.*</address>|<address>$MANAGER</address>|" "$CONF"

# Inject <enrollment> block with agent_name and groups
if grep -q "<enrollment>" "$CONF"; then
    sed -i "s|<enrollment>.*</enrollment>||g" "$CONF"
fi
sed -i "s|</client>|  <enrollment>\n    <enabled>yes</enabled>\n    <agent_name>$AGENT_NAME</agent_name>\n    <groups>$GROUP</groups>\n  </enrollment>\n</client>|" "$CONF"

# ── Start service ──
echo "[3/3] Starting service..."
systemctl daemon-reload
systemctl enable wazuh-agent
systemctl start wazuh-agent

if ! systemctl is-active --quiet wazuh-agent; then
    echo "[ERROR] Service failed to start"
    systemctl status wazuh-agent --no-pager
    exit 1
fi

echo
echo "[OK] Agent \"$AGENT_NAME\" registered to group \"$GROUP\" on $MANAGER"
echo "     Status: $(systemctl is-active wazuh-agent)"
