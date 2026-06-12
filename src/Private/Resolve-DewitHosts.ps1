function Resolve-DewitHosts {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object]$Playbook,

        [string]$InventoryPath,

        [string[]]$Hosts
    )

    if ($InventoryPath -and $Hosts) {
        throw 'Use either -Hosts for inline target hosts or -InventoryPath/-i for an inventory file, not both.'
    }

    if ($Hosts) {
        return Normalize-DewitInlineHosts -Hosts $Hosts
    }

    if ($InventoryPath) {
        $inventory = Parse-DewitYaml -Path (Resolve-DewitPath -Path $InventoryPath)
        Assert-DewitInventory -Inventory $inventory -Path $InventoryPath
        $inventoryHosts = Resolve-DewitInventoryHosts -Inventory $inventory
        if ($Playbook.hosts) {
            return Resolve-DewitPlaybookHosts -RequestedHosts @($Playbook.hosts) -Inventory $inventory -InventoryHosts $inventoryHosts
        }
        return $inventoryHosts
    }

    if ($Playbook.hosts) {
        return @($Playbook.hosts)
    }

    return @('localhost')
}

function Normalize-DewitInlineHosts {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$Hosts
    )

    $normalizedHosts = New-Object System.Collections.Generic.List[string]
    foreach ($hostEntry in $Hosts) {
        foreach ($hostNamePart in ([string]$hostEntry -split ',')) {
            $trimmedHostName = $hostNamePart.Trim()
            if ($trimmedHostName) {
                $normalizedHosts.Add($trimmedHostName)
            }
        }
    }

    if ($normalizedHosts.Count -eq 0) {
        throw '-Hosts did not contain any host names.'
    }

    return @($normalizedHosts | Select-Object -Unique)
}

function Assert-DewitInventory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object]$Inventory,

        [Parameter(Mandatory)]
        [string]$Path
    )

    if (-not $Inventory.hosts -and -not $Inventory.groups) {
        throw "Inventory '$Path' must define 'hosts' or 'groups'."
    }

    if ($Inventory.groups) {
        foreach ($groupName in (Get-DewitDictionaryKeys -InputObject $Inventory.groups)) {
            $group = Get-DewitDictionaryValue -InputObject $Inventory.groups -Key $groupName
            if (-not $group.hosts) {
                throw "Inventory '$Path' group '$groupName' is missing required field 'hosts'."
            }
        }
    }
}

function Resolve-DewitPlaybookHosts {
    param(
        [string[]]$RequestedHosts,
        [object]$Inventory,
        [string[]]$InventoryHosts
    )

    $resolved = New-Object System.Collections.Generic.List[string]
    foreach ($requestedHost in $RequestedHosts) {
        if ($requestedHost -eq 'all') {
            $InventoryHosts | ForEach-Object { $resolved.Add($_) }
            continue
        }

        if ($Inventory.groups -and (Test-DewitDictionaryKey -InputObject $Inventory.groups -Key $requestedHost)) {
            $group = Get-DewitDictionaryValue -InputObject $Inventory.groups -Key $requestedHost
            @($group.hosts) | ForEach-Object { $resolved.Add($_) }
            continue
        }

        $resolved.Add($requestedHost)
    }

    return @($resolved | Select-Object -Unique)
}

function Resolve-DewitInventoryHosts {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object]$Inventory
    )

    $hosts = New-Object System.Collections.Generic.List[string]

    if ($Inventory.hosts) {
        if ($Inventory.hosts -is [System.Collections.IDictionary]) {
            foreach ($hostName in (Get-DewitDictionaryKeys -InputObject $Inventory.hosts)) {
                $hosts.Add($hostName)
            }
        }
        else {
            @($Inventory.hosts) | ForEach-Object { $hosts.Add([string]$_) }
        }
    }

    if ($Inventory.groups) {
        foreach ($groupName in (Get-DewitDictionaryKeys -InputObject $Inventory.groups)) {
            $group = Get-DewitDictionaryValue -InputObject $Inventory.groups -Key $groupName
            @($group.hosts) | ForEach-Object { $hosts.Add([string]$_) }
        }
    }

    if ($hosts.Count -eq 0) {
        throw 'Inventory did not contain any hosts.'
    }

    return @($hosts | Select-Object -Unique)
}

function Get-DewitDictionaryKeys {
    param([Parameter(Mandatory)][object]$InputObject)

    if ($InputObject -is [System.Collections.IDictionary]) {
        return @($InputObject.Keys)
    }

    return @($InputObject.PSObject.Properties | Where-Object MemberType -eq 'NoteProperty' | Select-Object -ExpandProperty Name)
}

function Test-DewitDictionaryKey {
    param(
        [Parameter(Mandatory)][object]$InputObject,
        [Parameter(Mandatory)][string]$Key
    )

    if ($InputObject -is [System.Collections.IDictionary]) {
        return $InputObject.Contains($Key)
    }

    return $null -ne $InputObject.PSObject.Properties[$Key]
}

function Get-DewitDictionaryValue {
    param(
        [Parameter(Mandatory)][object]$InputObject,
        [Parameter(Mandatory)][string]$Key
    )

    if ($InputObject -is [System.Collections.IDictionary]) {
        return $InputObject[$Key]
    }

    return $InputObject.$Key
}
