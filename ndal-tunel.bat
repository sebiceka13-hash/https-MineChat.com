@echo off
rem Ndalon tunelin publik te perkoheshem.
taskkill /IM cloudflared.exe /F >nul 2>&1
echo Tuneli u ndal.
timeout /t 3 >nul
