@echo off
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    exit /b
)

set "LOG_PATH=%~dp0choco_upgrade.log"
choco upgrade all -y > "%LOG_PATH%" 2>&1