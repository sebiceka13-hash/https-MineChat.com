@echo off
setlocal
for /f "tokens=5" %%p in ('netstat -ano ^| findstr ":443 " ^| findstr "LISTENING"') do taskkill /PID %%p /F >nul 2>&1
echo Mine Chat u ndal.
endlocal
