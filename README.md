# Wazuh Agent Deploy — KKU ODT

สคริปต์ติดตั้ง Wazuh Agent สำหรับมหาวิทยาลัยขอนแก่น  
**Wazuh Manager:** `xdr.kku.ac.th` (10.101.102.243)

---

## โครงสร้างไฟล์

```
├── install_wazuh_ODTLIB4F.bat   # Windows — ห้อง ODTLIB ชั้น 4
├── install_wazuh_ODTLIB5F.bat   # Windows — ห้อง ODTLIB ชั้น 5
├── _wazuh_install_core.bat      # Windows core logic (ไม่ต้องแตะ)
├── install_wazuh_ODTLIB4F.sh    # Linux — ห้อง ODTLIB ชั้น 4
├── install_wazuh_ODTLIB5F.sh    # Linux — ห้อง ODTLIB ชั้น 5
└── _wazuh_install_core.sh       # Linux core logic (ไม่ต้องแตะ)
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

```bash
chmod +x install_wazuh_ODTLIB4F.sh
sudo ./install_wazuh_ODTLIB4F.sh
```

- Script จะ **prompt ให้กรอกชื่อ Agent** เอง
- หรือส่งผ่าน environment variable (สำหรับ Ansible/mass deploy):

```bash
sudo AGENT_NAME="LIB4F-PC01" ./install_wazuh_ODTLIB4F.sh
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

Linux:
```bash
#!/bin/bash
GROUP=ODTLIB6F
source "$(dirname "$0")/_wazuh_install_core.sh"
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
