param([switch]$NoRestore)
$ErrorActionPreference = 'Stop'
Push-Location (Split-Path $PSScriptRoot -Parent)
try {
    if (-not $NoRestore) {
        & flutter pub get
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
    & dart format --output=none --set-exit-if-changed lib test
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    & flutter analyze --no-pub
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    & flutter test --no-pub
    exit $LASTEXITCODE
}
finally { Pop-Location }
