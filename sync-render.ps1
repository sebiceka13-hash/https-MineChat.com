# Sync this folder's tracked files to the GitHub repo that Render builds from
# (https-MineChat.com), commit and push. Render then redeploys automatically.
# Usage: powershell -ExecutionPolicy Bypass -File .\sync-render.ps1

$ErrorActionPreference = "Stop"
$src = Split-Path -Parent $MyInvocation.MyCommand.Path
$tmp = Join-Path $env:TEMP "https-minechat-repo"
$repoUrl = "https://github.com/sebiceka13-hash/https-MineChat.com.git"

if (-not (Test-Path (Join-Path $tmp ".git"))) {
  if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
  git clone $repoUrl $tmp
} else {
  git -C $tmp pull --ff-only
}

$files = git -C $src ls-files
$copied = 0
foreach ($f in $files) {
  $s = Join-Path $src $f
  if (-not (Test-Path $s)) { continue }
  $d = Join-Path $tmp $f
  $dir = Split-Path $d -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  Copy-Item $s $d -Force
  $copied++
}

git -C $tmp add -A
$changes = git -C $tmp status --porcelain
if (-not $changes) {
  Write-Host "Asgje per te sinkronizuar - Render-i eshte tashme ne versionin e fundit."
  exit 0
}

$sha = (git -C $src rev-parse --short HEAD)
git -C $tmp -c user.name="sebiceka13-hash" -c user.email="sebiceka13-hash@users.noreply.github.com" commit -m "Sync from minechat $sha"
git -C $tmp push origin main

Write-Host "U sinkronizua me Render-in ($copied skedare). Render do te beje deploy automatikisht."
