@echo off
:: .bat dosyasının bulunduğu dizini al
set "SCRIPT_DIR=%~dp0"

:: PowerShell'in tam yolunu kullanarak yönetici olarak başlat ve ExecutionPolicy'yi Unrestricted yap
"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Unrestricted -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Unrestricted -File \"%SCRIPT_DIR%JDKSelector.ps1\"' -Verb runAs"
