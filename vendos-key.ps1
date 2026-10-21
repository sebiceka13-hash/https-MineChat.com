param(
  [Parameter(Mandatory = $false)]
  [string]$Key = ""
)

$ErrorActionPreference = "Stop"
$dir = "C:\Users\sebic\OneDrive\Desktop\mine chat"
$envFile = Join-Path $dir ".env"

if ([string]::IsNullOrWhiteSpace($Key)) {
  $sec = Read-Host "Ngjit celesin e ri te OpenAI" -AsSecureString
  $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
  $Key = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
  [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
}

$Key = $Key.Trim()
if ($Key -notmatch '^sk-') {
  Write-Host "Celesi nuk fillon me 'sk-'. Kontrollo nese e kopove i tere." -ForegroundColor Red
  exit 1
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
Copy-Item $envFile "$envFile.bak-$stamp" -Force
Write-Host "Backup: .env.bak-$stamp" -ForegroundColor DarkGray

$lines = [IO.File]::ReadAllLines($envFile)
$found = $false
for ($i = 0; $i -lt $lines.Length; $i++) {
  if ($lines[$i] -match '^OPENAI_API_KEY=') {
    $lines[$i] = "OPENAI_API_KEY=" + $Key
    $found = $true
  }
}
if (-not $found) {
  $lines += "OPENAI_API_KEY=" + $Key
}
[IO.File]::WriteAllLines($envFile, $lines)
Write-Host "Celesi u ruajt ne .env" -ForegroundColor Green

Get-CimInstance Win32_Process -Filter "Name='node.exe'" |
  Where-Object { $_.CommandLine -like '*server.js*' } |
  ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 2
Start-Process -FilePath "C:\Program Files\nodejs\node.exe" `
  -ArgumentList "--env-file-if-exists=.env", "server.js" `
  -WorkingDirectory $dir -WindowStyle Hidden `
  -RedirectStandardOutput (Join-Path $env:TEMP "mc-key.log") `
  -RedirectStandardError (Join-Path $env:TEMP "mc-key-err.log")
Start-Sleep -Seconds 10

Write-Host ""
Write-Host "Duke provuar OpenAI..." -ForegroundColor Cyan
$out = & node --env-file-if-exists=".env" -e "fetch('https://api.openai.com/v1/models',{headers:{Authorization:'Bearer '+process.env.OPENAI_API_KEY}}).then(async r=>{const j=await r.json(); if(j.error){console.log('401/ERROR: '+j.error.message)}else{console.log('OK - modelet: '+j.data.length)}})" 2>&1
Write-Host $out
Write-Host ""
Write-Host "Hap: https://minechat" -ForegroundColor Green
Read-Host "Shtyp Enter për mbyllje"