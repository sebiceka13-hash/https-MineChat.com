@echo off
setlocal
set "APPDIR=C:\Users\sebic\OneDrive\Desktop\mine chat"

netstat -ano | findstr ":443 " | findstr "LISTENING" >nul 2>&1
if not errorlevel 1 exit /b 0

cd /d "%APPDIR%"
start "" wscript.exe "%APPDIR%\nis-fshehur.vbs"
endlocal
