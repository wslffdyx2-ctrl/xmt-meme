$ErrorActionPreference = "Stop"

Set-Location -LiteralPath $PSScriptRoot

$projectJsonPath = Join-Path $PSScriptRoot ".vercel\project.json"
$shortNames = @("xmt-meme", "xmtou", "xmeme", "xmt-m")
$localVercel = Join-Path $PSScriptRoot "node_modules\vercel\dist\vc.js"

function Invoke-Vercel {
  param([string[]]$ArgsList)

  if (Test-Path $localVercel) {
    & node $localVercel @ArgsList
  } else {
    & npx --yes vercel@latest @ArgsList
  }
}

Write-Host "Vercel one-click flow started." -ForegroundColor Yellow

if (Test-Path $projectJsonPath) {
  $projectJson = Get-Content -LiteralPath $projectJsonPath -Raw | ConvertFrom-Json
  $currentName = $projectJson.projectName

  if ($shortNames -notcontains $currentName) {
    foreach ($shortName in $shortNames) {
      Write-Host "Trying short project name: $shortName" -ForegroundColor Yellow
      Invoke-Vercel -ArgsList @("project", "rename", $currentName, $shortName, "--yes")

      if ($LASTEXITCODE -eq 0) {
        $projectJson.projectName = $shortName
        $projectJson | ConvertTo-Json -Compress | Set-Content -LiteralPath $projectJsonPath -Encoding UTF8
        $currentName = $shortName
        break
      }
    }
  }
}

Write-Host "Deploying production..." -ForegroundColor Yellow
Invoke-Vercel -ArgsList @("deploy", "--prod", "--yes")

if ($LASTEXITCODE -ne 0) {
  throw "Vercel deployment failed."
}

if (Test-Path $projectJsonPath) {
  $projectJson = Get-Content -LiteralPath $projectJsonPath -Raw | ConvertFrom-Json
  Write-Host ""
  Write-Host "Production URL:" -ForegroundColor Green
  Write-Host "https://$($projectJson.projectName).vercel.app" -ForegroundColor Green
}
