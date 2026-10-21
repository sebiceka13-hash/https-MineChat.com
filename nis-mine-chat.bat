@echo off
setlocal
set "APPDIR=C:\Users\sebic\OneDrive\Desktop\mine chat"

call "%APPDIR%\nis-serveri.bat"
ping -n 6 127.0.0.1 >nul 2>&1
echo Mine Chat po hapet te https://minechat
start "" https://minechat
endlocal