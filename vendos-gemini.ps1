<#
  Vendos celesin FALAS te Google Gemini (pa kart banke).
  Ku merret: https://aistudio.google.com/apikey  -> Create API key
#>
param([switch]$Test)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$envFile = Join-Path $root '.env'

if (-not (Test-Path -LiteralPath $envFile)) {
  Write-Host "Nuk u gjet .env" -ForegroundColor Red
  exit 1
}

if (-not $Test) {
  Write-Host ""
  Write-Host "  Merr celesin keteq:" -ForegroundColor Cyan
  Write-Host "    1. Hap  https://aistudio.google.com/apikey" -ForegroundColor White
  Write-Host "    2. Hyr me llogarine Google" -ForegroundColor White
  Write-Host "    3. Click 'Create API key' -> zgjidh projektin 'mine-chat'" -ForegroundColor White
  Write-Host ""
  Write-Host "  Pastaj ngjite kesi, qe eshte e fshehur." -ForegroundColor Cyan
  $secure = Read-Host "  Celesi Gemini" -AsSecureString
  $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
  try { $key = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr) } finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr) }
  $key = $key.Trim()

  if ([string]::IsNullOrWhiteSpace($key)) { Write-Host "Celesi u anullua." -ForegroundColor Yellow; exit 1 }
  if ($key -notmatch '^AIza') { Write-Host "Ky nuk duket celes Gemini (prite te qe fillon me AIza)." -ForegroundColor Red; exit 1 }
}

$backup = "$envFile.bak"
Copy-Item -LiteralPath $envFile -Destination $backup -Force

$lines = Get-Content -LiteralPath $envFile -Encoding UTF8
$updated = New-Object System.Collections.Generic.List[string]
$seen = $false
foreach ($line in $lines) {
  if ($line -match '^\s*GEMINI_API_KEY\s*=') {
    $updated.Add("GEMINI_API_KEY=$key")
    $seen = $true
  } elseif ($line -match '^\s*GEMINI_MODEL\s*=') {
    $updated.Add($line)
  } else {
    $updated.Add($line)
  }
}
if (-not $seen) {
  if ($updated.Count -gt 0 -and $updated[$updated.Count - 1].Trim() -ne '') { $updated.Add('') }
  $updated.Add("GEMINI_API_KEY=$key")
  $updated.Add('GEMINI_MODEL=gemini-2.5-flash')
  $updated.Add('GEMINI_IMAGE_MODEL=gemini-2.5-flash-image')
}
[IO.File]::WriteAllLines($envFile, $updated, (New-Object Text.UTF8Encoding $false))

Write-Host ""
Write-Host "  .env u ruajt. Backup: .env.bak" -ForegroundColor Green

Write-Host "  Po e provoj celesin..." -ForegroundColor Cyan
$body = '{"contents":[{"role":"user","parts":[{"text":"ping"}]}],"generationConfig":{"maxOutputTokens":2}}'
try {
  $r = Invoke-RestMethod -Method Post -Uri ('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=' + $key) -ContentType 'application/json' -Body $body -TimeoutSec 25
  if ($r.candidates) {
    Write-Host "  CELESI FUNKSIONON. Modeli pergjigjet." -ForegroundColor Green
  } else {
    Write-Host "  Pergjigje e papritur nga Gemini." -ForegroundColor Yellow
  }
} catch {
  $msg = $_.Exception.Message
  Write-Host "  DESPERTO: $msg" -ForegroundColor Red
  Write-Host "  Celesi u ruajt ne .env, por nuk funksionon ende." -ForegroundColor Yellow
  Write-Host "  Kontrollo: a eshte i aktivizuar 'Generative Language API' ne projektin Google?" -ForegroundColor Yellow
  exit 1
}

Write-Host ""
Write-Host "  Tani dyfisho 'Ndal Mine Chat' dhe nise serverin e ri." -ForegroundColor Cyan
Write-Host "  Pastaj: https://minechat" -ForegroundColor White
Write-Host ""