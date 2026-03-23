# Wazuh Agent Deploy — KKU ODT

สคริปต์ติดตั้ง Wazuh Agent สำหรับมหาวิทยาลัยขอนแก่น  
**Wazuh Manager:** `xdr.kku.ac.th` (10.101.102.243)

---

## โครงสร้างไฟล์

```
├── install_wazuh_ODTLIB4F.bat   # Windows — ห้อง ODTLIB ชั้น 4
├── install_wazuh_ODTLIB5F.bat   # Windows — ห้อง ODTLIB ชั้น 5
├── _wazuh_install_core.bat      # Windows core logic (ไม่ต้องแตะ)
└── _wazuh_install_core.sh       # Linux — ถามชื่อ Group และ Agent อัตโนมัติ
```

---

## วิธีใช้งาน

### Windows

1. วางไฟล์ทั้งหมดไว้ใน folder เดียวกัน
2. คลิกขวาที่ script ของ group ที่ต้องการ → **Run as administrator**

```batch
install_wazuh_ODTLIB4F.bat   ← ชั้น 4
install_wazuh_ODTLIB5F.bat   ← ชั้น 5
```

- Agent name ใช้ **MAC Address** ของ NIC ที่ connected อัตโนมัติ
- Format: `AA-BB-CC-DD-EE-FF`

### Linux

**ดาวน์โหลด:**
```bash
curl -O https://raw.githubusercontent.com/FIGOHIGHWAY/wazuh-agent-deploy-kku/main/_wazuh_install_core.sh
```

**ติดตั้ง:**
```bash
sudo bash _wazuh_install_core.sh
```

**หรือดาวน์โหลดและรันในคำสั่งเดียว:**
```bash
curl -s https://raw.githubusercontent.com/FIGOHIGHWAY/wazuh-agent-deploy-kku/main/_wazuh_install_core.sh | sudo bash
```

- Script จะ **prompt ให้กรอก Group และชื่อ Agent** เอง
- หรือส่งผ่าน environment variable (สำหรับ Ansible/mass deploy):

**กลุ่ม ODTLIB:**
```bash
sudo GROUP="ODTLIB4F" AGENT_NAME="LIB4F-PC01" bash _wazuh_install_core.sh
```

**กลุ่ม VMODT:**
```bash
sudo GROUP="VMODT" AGENT_NAME="odt.kku.ac.th" bash _wazuh_install_core.sh
```

**Distro ที่รองรับ:** Ubuntu/Debian · CentOS/RHEL/Rocky · Arch Linux

---

## เพิ่ม Group ใหม่

สร้างไฟล์ 3 บรรทัด (Windows):
```batch
@echo off
setlocal
set GROUP=ODTLIB6F
call "%~dp0_wazuh_install_core.bat"
```

Linux — ระบุ GROUP ตอนรัน:
```bash
sudo GROUP=ODTLIB6F bash _wazuh_install_core.sh
```

---

## ข้อกำหนด

| รายการ | ข้อกำหนด |
|--------|---------|
| Wazuh Agent | 4.10.1 |
| Windows | 10 / 11 / Server 2016+ |
| Linux | Ubuntu 20.04+ / RHEL 8+ / Arch |
| สิทธิ์ | Administrator / root |
| Network | เชื่อมต่อ Manager port 1514, 1515 |

---

## ติดต่อ

**สำนักเทคโนโลยีดิจิทัล มหาวิทยาลัยขอนแก่น**  
📧 nsupport@kku.ac.th | ☎️ 043-009700 ต่อ 42052  
🌐 https://digital.kku.ac.th
