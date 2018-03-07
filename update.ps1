PARAM([Switch]$Force,[Switch]$Recursive)
If(-not $Force.IsPresent) {Write-verbose -verbose "Update cancelled. Run update.ps1 -force to update submodules."}
Write-verbose -verbose "update.ps1 fetches the current commits of the submodules. THIS MAY BREAK THE MODULE and constitutes a change as far as git is concerned."
If($Force.IsPresent -and $Recursive.IsPresent) {
Write-verbose -verbose "Updating submodules recursively..."
git submodule update --recursive --remote }
ELSEIf($Force.IsPresent) {
Write-verbose -verbose "Updating submodules..."
git submodule update --remote }
