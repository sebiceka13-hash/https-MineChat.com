@echo off
rem Hap nje tunel publik te perkoheshem (trycloudflare.com) drejt serverit lokal.
rem URL-ja shfaqet ne dritaren e re qe hapet. Mos e mbyll ate dritare.
setlocal
set "CF=C:\Program Files (x86)\cloudflared\cloudflared.exe"
if not exist "%CF%" (
  echo cloudflared nuk u gjet: "%CF%"
  pause
  exit /b 1
)
start "Mine Chat - Tunel" "%CF%" tunnel --url https://localhost --no-tls-verify
echo.
echo Tuneli u hap ne dritaren "Mine Chat - Tunel".
echo Kopjo URL-ne https://....trycloudflare.com qe shfaqet aty.
echo.
timeout /t 8 >nul
endlocal
