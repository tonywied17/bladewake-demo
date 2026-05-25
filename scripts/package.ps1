#requires -Version 5.1
<#
.SYNOPSIS
    Package the latest Bladewake Windows build into a versioned zip for early-access distribution.

.DESCRIPTION
    Pulls Bladewake.exe + Bladewake.pck from the sibling main project's build/ folder,
    writes a version.txt, and zips them into dist/Bladewake-EarlyAccess-v<Version>-win64.zip.

    Run this from the bladewake-demo repo root, with the main project checked out as a sibling
    (../bladewake-gd/build/).

.PARAMETER Version
    Semver-ish version tag for this build (e.g. 0.1.0). Required.

.PARAMETER MainRepo
    Path to the main bladewake-gd checkout. Defaults to ../.

.PARAMETER Publish
    If set, also creates and uploads a GitHub Release using `gh` CLI.

.EXAMPLE
    .\scripts\package.ps1 -Version 0.1.0

.EXAMPLE
    .\scripts\package.ps1 -Version 0.1.0 -Publish
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$Version,

    [string]$MainRepo = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path,

    [switch]$Publish
)

$ErrorActionPreference = "Stop"

$demoRoot = Split-Path -Parent $PSScriptRoot
$buildDir = Join-Path $MainRepo "build"
$exe = Join-Path $buildDir "Bladewake.exe"
$pck = Join-Path $buildDir "Bladewake.pck"

if (-not (Test-Path $exe)) { throw "Missing build artifact: $exe" }
if (-not (Test-Path $pck)) { throw "Missing build artifact: $pck" }

$distDir = Join-Path $demoRoot "dist"
$stageDir = Join-Path $distDir "stage"

if (Test-Path $stageDir) { Remove-Item -Recurse -Force $stageDir }
New-Item -ItemType Directory -Force -Path $stageDir | Out-Null
New-Item -ItemType Directory -Force -Path $distDir | Out-Null

Copy-Item $exe (Join-Path $stageDir "Bladewake.exe")
Copy-Item $pck (Join-Path $stageDir "Bladewake.pck")

$gitSha = ""
try {
    Push-Location $MainRepo
    $gitSha = (git rev-parse --short HEAD) 2>$null
} finally {
    Pop-Location
}

$buildDate = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss 'UTC'")

@"
Bladewake Early Access Build
============================
Version:    v$Version
Built:      $buildDate
Source SHA: $gitSha
Platform:   Windows x64

To run: double-click Bladewake.exe
Report issues: https://github.com/tonywied17/bladewake-demo/issues
"@ | Set-Content -Path (Join-Path $stageDir "version.txt") -Encoding UTF8

$readme = Join-Path $stageDir "README.txt"
@"
BLADEWAKE — Early Access Test Build v$Version

1. Extract the entire folder somewhere writable (e.g. C:\Games\Bladewake).
2. Run Bladewake.exe.
3. Windows SmartScreen may warn (unsigned binary). Choose More info -> Run anyway.

Feedback / bugs: https://github.com/tonywied17/bladewake-demo/issues/new/choose
"@ | Set-Content -Path $readme -Encoding UTF8

$zipName = "Bladewake-EarlyAccess-v$Version-win64.zip"
$zipPath = Join-Path $distDir $zipName
if (Test-Path $zipPath) { Remove-Item -Force $zipPath }

Write-Host "Zipping -> $zipPath"
Compress-Archive -Path (Join-Path $stageDir "*") -DestinationPath $zipPath -CompressionLevel Optimal

Remove-Item -Recurse -Force $stageDir

$size = (Get-Item $zipPath).Length
$mb = [math]::Round($size / 1MB, 1)
Write-Host "OK: $zipName ($mb MB)" -ForegroundColor Green

if ($Publish) {
    Write-Host "Publishing GitHub Release v$Version..." -ForegroundColor Cyan
    Push-Location $demoRoot
    try {
        $notes = @"
Bladewake Early Access **v$Version**

- Source SHA: ``$gitSha``
- Built: $buildDate

See [CHANGELOG.md](CHANGELOG.md) for details. Bug reports + feedback welcome via [Issues](https://github.com/tonywied17/bladewake-demo/issues/new/choose).
"@
        $notesFile = Join-Path $env:TEMP "bw-release-notes-$Version.md"
        $notes | Set-Content -Path $notesFile -Encoding UTF8

        gh release create "v$Version" $zipPath `
            --title "Bladewake Early Access v$Version" `
            --notes-file $notesFile `
            --latest
    } finally {
        Pop-Location
    }
}
