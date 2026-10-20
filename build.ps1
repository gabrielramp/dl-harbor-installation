$ErrorActionPreference = 'Stop'
function Fail($m) { Write-Host "[harbor-installer] ERROR: $m" -ForegroundColor Red; exit 1 }

$iscc = @("$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe",
          "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
          "$env:ProgramFiles\Inno Setup 6\ISCC.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $iscc) { Fail "ISCC.exe not found. Install Inno Setup 6 (https://jrsoftware.org/isdl.php)." }

foreach ($f in 'harbor-plugin.dll', 'harbor-balance.yaml', 'dl_harbor.vpk', 'harbor.vpk') {
    if (-not (Test-Path (Join-Path $PSScriptRoot "payload\$f"))) { Fail "payload\$f is missing; copy it in first." }
}

foreach ($iss in 'Client-Setup', 'Server-Setup') {
    & $iscc /Q (Join-Path $PSScriptRoot "$iss.iss")
    if ($LASTEXITCODE -ne 0) { Fail "ISCC failed on $iss.iss (exit $LASTEXITCODE)" }
    $exe = Get-Item (Join-Path $PSScriptRoot "Output\$iss.exe")
    Write-Host ("[harbor-installer] built {0} ({1:N0} bytes)" -f $exe.FullName, $exe.Length)
}
