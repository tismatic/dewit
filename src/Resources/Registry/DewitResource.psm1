function Get-DewitResourceState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$DesiredState,

        [Parameter(Mandatory)]
        [hashtable]$Context
    )

    $path = $DesiredState.path
    $name = $DesiredState.name

    if (-not (Test-Path -Path $path)) {
        return [pscustomobject]@{
            Exists = $false
            Path   = $path
            Name   = $name
            Value  = $null
            Type   = $null
        }
    }

    $property = Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue
    if (-not $property -or $null -eq $property.PSObject.Properties[$name]) {
        return [pscustomobject]@{
            Exists = $false
            Path   = $path
            Name   = $name
            Value  = $null
            Type   = $null
        }
    }

    [pscustomobject]@{
        Exists = $true
        Path   = $path
        Name   = $name
        Value  = $property.$name
        Type   = Get-DewitRegistryValueKind -Path $path -Name $name
    }
}

function Test-DewitResourceState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$DesiredState,

        [Parameter(Mandatory)]
        [object]$CurrentState,

        [Parameter(Mandatory)]
        [hashtable]$Context
    )

    if ($DesiredState.state -eq 'absent') {
        return -not $CurrentState.Exists
    }

    if (-not $CurrentState.Exists) {
        return $false
    }

    if ($DesiredState.ContainsKey('type')) {
        $desiredType = Convert-DewitRegistryType -Type $DesiredState.type
        if ($CurrentState.Type -ne $desiredType) {
            return $false
        }
    }

    if ($DesiredState.ContainsKey('value')) {
        return Test-DewitRegistryValueEqual -CurrentValue $CurrentState.Value -DesiredValue $DesiredState.value
    }

    return $true
}

function Set-DewitResourceState {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [hashtable]$DesiredState,

        [Parameter(Mandatory)]
        [object]$CurrentState,

        [Parameter(Mandatory)]
        [hashtable]$Context
    )

    $path = $DesiredState.path
    $name = $DesiredState.name

    if ($DesiredState.state -eq 'absent') {
        if (Test-Path -Path $path) {
            Remove-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue
        }

        $after = Get-DewitResourceState -DesiredState $DesiredState -Context $Context
        return [pscustomobject]@{
            Changed = $true
            Message = "Removed registry value $path\$name"
            Before  = $CurrentState
            After   = $after
        }
    }

    if (-not $DesiredState.ContainsKey('type')) {
        throw "Registry resource requires field 'type' when state is 'present'."
    }

    if (-not $DesiredState.ContainsKey('value')) {
        throw "Registry resource requires field 'value' when state is 'present'."
    }

    if (-not (Test-Path -Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }

    New-ItemProperty -Path $path -Name $name -Value $DesiredState.value -PropertyType (Convert-DewitRegistryType -Type $DesiredState.type) -Force | Out-Null

    $after = Get-DewitResourceState -DesiredState $DesiredState -Context $Context
    [pscustomobject]@{
        Changed = $true
        Message = "Set registry value $path\$name"
        Before  = $CurrentState
        After   = $after
    }
}

function Convert-DewitRegistryType {
    param([Parameter(Mandatory)][string]$Type)

    switch ($Type) {
        'string' { 'String' }
        'expandString' { 'ExpandString' }
        'multiString' { 'MultiString' }
        'dword' { 'DWord' }
        'qword' { 'QWord' }
        'binary' { 'Binary' }
    }
}

function Get-DewitRegistryValueKind {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name
    )

    try {
        $key = Get-Item -Path $Path -ErrorAction Stop
        return $key.GetValueKind($Name).ToString()
    }
    catch {
        return $null
    }
}

function Test-DewitRegistryValueEqual {
    param(
        [AllowNull()][object]$CurrentValue,
        [AllowNull()][object]$DesiredValue
    )

    if ($CurrentValue -is [array] -or $DesiredValue -is [array]) {
        return (Compare-Object -ReferenceObject @($CurrentValue) -DifferenceObject @($DesiredValue) -SyncWindow 0).Count -eq 0
    }

    return [string]$CurrentValue -eq [string]$DesiredValue
}

Export-ModuleMember -Function Get-DewitResourceState, Test-DewitResourceState, Set-DewitResourceState
