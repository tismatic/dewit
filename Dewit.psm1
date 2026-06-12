$script:DewitModuleRoot = $PSScriptRoot

$privateFunctions = Get-ChildItem -Path (Join-Path $PSScriptRoot 'src/Private') -Filter '*.ps1' -ErrorAction SilentlyContinue
foreach ($functionFile in $privateFunctions) {
    . $functionFile.FullName
}

$publicFunctions = Get-ChildItem -Path (Join-Path $PSScriptRoot 'src/Public') -Filter '*.ps1' -ErrorAction SilentlyContinue
foreach ($functionFile in $publicFunctions) {
    . $functionFile.FullName
}

Export-ModuleMember -Function Invoke-Dewit, Test-Dewit, New-DewitProject, Test-DewitInventory, New-DewitReport, Get-DewitResource, dewit
