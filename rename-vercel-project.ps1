$ErrorActionPreference = "Stop"

Set-Location -LiteralPath $PSScriptRoot

$projectJsonPath = Join-Path $PSScriptRoot ".vercel\project.json"
$projectJson = Get-Content -LiteralPath $projectJsonPath -Raw | ConvertFrom-Json
$oldName = $projectJson.projectName
$candidates = @("xmt-meme", "xmtou", "xmeme", "xmt-m")
$localVercel = Join-Path $PSScriptRoot "node_modules\vercel\dist\vc.js"

if (Test-Path $localVercel) {
  $vercel = @("node", $localVercel)
} else {
  $vercel = @("npx", "--yes", "vercel@latest")
}

foreach ($newName in $candidates) {
  Write-Host "Trying to rename Vercel project to: $newName" -ForegroundColor Yellow

  & $vercel[0] $vercel[1..($vercel.Count - 1)] project rename $oldName $newName --yes

  if ($LASTEXITCODE -eq 0) {
    $projectJson.projectName = $newName
    $projectJson | ConvertTo-Json -Compress | Set-Content -LiteralPath $projectJsonPath -Encoding UTF8

    Write-Host ""
    Write-Host "Done. New production URL should be:" -ForegroundColor Green
    Write-Host "https://$newName.vercel.app" -ForegroundColor Green
    exit 0
  }
}

Write-Host "All short names failed. Pick another name and run:" -ForegroundColor Red
Write-Host "vercel project rename $oldName YOUR-NAME --yes" -ForegroundColor Red
exit 1
