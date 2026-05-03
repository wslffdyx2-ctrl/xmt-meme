$ErrorActionPreference = "Stop"

Set-Location -LiteralPath $PSScriptRoot

Write-Host "Deploying site to Vercel..." -ForegroundColor Yellow
Write-Host "Preferred short project name: xmt-meme" -ForegroundColor Yellow

$localVercel = Join-Path $PSScriptRoot "node_modules\vercel\dist\vc.js"

if (Test-Path $localVercel) {
  node $localVercel deploy --prod --name xmt-meme
} else {
  npx --yes vercel@latest deploy --prod --name xmt-meme
}
