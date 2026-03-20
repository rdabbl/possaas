$ErrorActionPreference = "Stop"

$possible = @(
  Join-Path ${env:ProgramFiles(x86)} "Inno Setup 6\ISCC.exe",
  Join-Path $env:ProgramFiles "Inno Setup 6\ISCC.exe"
)

$iscc = $possible | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $iscc) {
  throw "Inno Setup 6 not found. Please install it, then re-run this script. (ISCC.exe)"
}

Push-Location $PSScriptRoot
try {
  & $iscc ".\pos_nimirik.iss"
}
finally {
  Pop-Location
}
