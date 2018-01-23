PARAM([Switch]$SuppressBootstrap)
write-verbose "Setup (running $PsCommandPath)..." -Verbose

If (-not $SuppressBootstrap.IsPresent) {
write-verbose "Running bootstrap..." -Verbose
. .\bootstrap.ps1
}
ELSE {write-verbose "Bootstrap suppressed." -Verbose}

Get-ChildItem -Directory | Get-ChildItem -filter setup.ps1 | ForEach-Object { Push-Location; Set-Location (Split-Path -Parent $_.Fullname); . ".\$($_.Name)" -SuppressBootstrap ; Pop-Location }

write-verbose "Done ($PsCommandPath)." -Verbose
