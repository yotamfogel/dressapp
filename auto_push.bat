@echo off
echo 🤖 Running auto-push script...
powershell -ExecutionPolicy Bypass -File "%~dp0auto_push.ps1"
pause 