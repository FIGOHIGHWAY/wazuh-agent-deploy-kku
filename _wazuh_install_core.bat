@echo off
:: ── Called by group-specific scripts, expects GROUP to be set ──

:: ── Privilege check ──
net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Run as Administrator
    pause & exit /b 1
)

:: ── Get MAC address (first active NIC) ──
for /f "skip=1 tokens=1" %%m in (
    'wmic nic where "NetConnectionStatus=2" get MACAddress 2^>nul'
) do (
    if not defined MAC set "MAC=%%m"
)
if not defined MAC set "MAC=%COMPUTERNAME%"
set "MAC=%MAC::=-%"

:: ── Config ──
set MANAGER=10.101.102.243
set MSI=%TEMP%\wazuh-agent.msi
set VER=4.10.1-1

echo ==============================
echo  Wazuh Agent Installer
echo  Agent  : %MAC%
echo  Group  : %GROUP%
echo  Manager: %MANAGER%
echo ==============================
echo.

:: ── Skip if already installed ──
sc query WazuhSvc >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [WARN] Wazuh already installed. Skipping.
    pause & exit /b 0
)

:: ── Download ──
echo [1/3] Downloading wazuh-agent-%VER%.msi ...
powershell -Command "Invoke-WebRequest -Uri 'https://packages.wazuh.com/4.x/windows/wazuh-agent-%VER%.msi' -OutFile '%MSI%'" 2>nul
if %ERRORLEVEL% NEQ 0 ( echo [ERROR] Download failed & pause & exit /b 1 )
if not exist "%MSI%"   ( echo [ERROR] MSI not found  & pause & exit /b 1 )

:: ── Install ──
echo [2/3] Installing...
msiexec.exe /i "%MSI%" /qn ^
    WAZUH_MANAGER="%MANAGER%" ^
    WAZUH_REGISTRATION_SERVER="%MANAGER%" ^
    WAZUH_AGENT_NAME="%MAC%" ^
    WAZUH_AGENT_GROUP="%GROUP%"
if %ERRORLEVEL% NEQ 0 ( echo [ERROR] Install failed (code %ERRORLEVEL%) & pause & exit /b 1 )

timeout /t 20 /nobreak >nul

:: ── Start service ──
echo [3/3] Starting service...
NET START WazuhSvc >nul 2>&1
if %ERRORLEVEL% NEQ 0 ( echo [ERROR] Service failed to start & pause & exit /b 1 )

:: ── Cleanup ──
del "%MSI%" >nul 2>&1

echo.
echo [OK] Agent "%MAC%" registered to group "%GROUP%" on %MANAGER%
echo.
pause
