function Test-DewitInventory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Path
    )

    $resolvedPath = Resolve-DewitPath -Path $Path
    $inventory = Parse-DewitYaml -Path $resolvedPath
    Assert-DewitInventory -Inventory $inventory -Path $resolvedPath
    $hosts = Resolve-DewitInventoryHosts -Inventory $inventory

    [pscustomobject]@{
        Path      = $resolvedPath
        IsValid   = $hosts.Count -gt 0
        HostCount = $hosts.Count
        Hosts     = $hosts
    }
}
