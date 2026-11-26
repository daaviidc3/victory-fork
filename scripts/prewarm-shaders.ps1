$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

$victory = Join-Path $repoRoot 'target\release\victory.exe'
if (-not (Test-Path -LiteralPath $victory)) {
    Write-Host 'Building the release executable...'
    & cargo build --release -p victory
    if ($LASTEXITCODE -ne 0) {
        throw "cargo build failed with exit code $LASTEXITCODE"
    }
}

Write-Host 'Pre-translating shaders from the configured game directory (2 workers to limit memory use)...'
Write-Host 'This fills the shader translation cache; it does not build GPU pipelines or raise in-game FPS.'
& $victory translate --warm all --jobs 2
if ($LASTEXITCODE -ne 0) {
    throw "shader warm-up failed with exit code $LASTEXITCODE"
}

Write-Host 'Shader cache warm-up finished.'
