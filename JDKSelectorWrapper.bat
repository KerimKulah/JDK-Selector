@echo off
:: .bat dosyasının bulunduğu dizini al
set "SCRIPT_DIR=%~dp0"

:: Yönetici haklarıyla PowerShell başlat ve sadece bu işlemde ExecutionPolicy'yi Bypass yaparak script'i çalıştır
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -File \"\"%SCRIPT_DIR%JDKSelector.ps1\"\"' -Verb runAs"
