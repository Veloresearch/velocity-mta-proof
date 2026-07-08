<#
  build_installer.ps1  -  one command to produce installer\dist\VelocitySetup.exe

  Steps:
    1. (optional) cargo build --release -p velocity   [-Build]
    2. stage the payload (exe + docs + icon) into installer\staging\
    3. compile velocity.iss with Inno Setup's ISCC.exe

  Requirements: Inno Setup 6 (ISCC.exe on PATH, or installed in the usual place).
    Install with:  winget install --id JRSoftware.InnoSetup -e
#>
param(
    [switch]$Build,        # also run `cargo build --release -p velocity` and stage that binary
    [string]$PayloadDir    # folder holding velocity.exe + docs (default: Velo-MTA, else repo root)
)

$ErrorActionPreference = 'Stop'
$here    = Split-Path -Parent $MyInvocation.MyCommand.Path
$repo    = Split-Path -Parent $here
$staging = Join-Path $here 'staging'
$distDir = Join-Path $here 'dist'

# Where the exe + docs live. Monorepo -> Velo-MTA; public release repo -> repo root.
if (-not $PayloadDir) {
    $veloMta = Join-Path $repo 'Velo-MTA'
    $PayloadDir = if (Test-Path (Join-Path $veloMta 'velocity.exe')) { $veloMta } else { $repo }
}

Write-Host "== Velocity installer build ==" -ForegroundColor Cyan
Write-Host "   payload: $PayloadDir" -ForegroundColor DarkGray

# 1. optional fresh release build ------------------------------------------------
$exeSrc = Join-Path $PayloadDir 'velocity.exe'
if ($Build) {
    Write-Host "-> cargo build --release -p velocity" -ForegroundColor Yellow
    Push-Location $repo
    cargo build --release -p velocity
    if ($LASTEXITCODE -ne 0) { throw "cargo build failed" }
    Pop-Location
    $exeSrc = Join-Path $repo 'target\release\velocity.exe'
}
if (-not (Test-Path $exeSrc)) { throw "velocity.exe not found at $exeSrc (build it, or pass -Build)" }

# 2. stage payload ---------------------------------------------------------------
if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }
New-Item -ItemType Directory -Path $staging | Out-Null

Copy-Item $exeSrc (Join-Path $staging 'velocity.exe') -Force
Copy-Item (Join-Path $repo 'crates\velocity\res\velocity.ico') (Join-Path $staging 'velocity.ico') -Force

$docs = @('README.md','QUICKSTART.md','CHANGELOG.md','LICENSE.txt')
foreach ($d in $docs) {
    $src = Join-Path $PayloadDir $d
    if (Test-Path $src) { Copy-Item $src (Join-Path $staging $d) -Force }
    else { Write-Warning "missing doc: $src (installer will skip it if you also remove it from velocity.iss)" }
}
Write-Host "-> staged payload in $staging" -ForegroundColor Green

# 3. locate ISCC and compile -----------------------------------------------------
$iscc = (Get-Command iscc.exe -ErrorAction SilentlyContinue).Source
if (-not $iscc) {
    foreach ($c in @(
        "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
        "${env:ProgramFiles}\Inno Setup 6\ISCC.exe",
        "${env:LOCALAPPDATA}\Programs\Inno Setup 6\ISCC.exe")) {
        if (Test-Path $c) { $iscc = $c; break }
    }
}
if (-not $iscc) {
    throw "ISCC.exe (Inno Setup) not found. Install it with:`n    winget install --id JRSoftware.InnoSetup -e`nthen re-run this script."
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
Write-Host "-> compiling with $iscc" -ForegroundColor Yellow
& $iscc (Join-Path $here 'velocity.iss')
if ($LASTEXITCODE -ne 0) { throw "ISCC failed" }

$out = Join-Path $distDir 'VelocitySetup.exe'
Write-Host "`nDONE: $out" -ForegroundColor Green
if (Test-Path $out) {
    $mb = [math]::Round((Get-Item $out).Length / 1MB, 1)
    Write-Host "     size: $mb MB  (model downloads separately on first run)" -ForegroundColor DarkGray
}
