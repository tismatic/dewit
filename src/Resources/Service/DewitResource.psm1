function Get-DewitResourceState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$DesiredState,

        [Parameter(Mandatory)]
        [hashtable]$Context
    )

    $service = Get-Service -Name $DesiredState.name -ErrorAction SilentlyContinue
    if (-not $service) {
        return [pscustomobject]@{
            Exists      = $false
            Name        = $DesiredState.name
            Status      = $null
            StartupType = $null
        }
    }

    [pscustomobject]@{
        Exists      = $true
        Name        = $service.Name
        Status      = $service.Status.ToString().ToLowerInvariant()
        StartupType = $service.StartType.ToString().ToLowerInvariant()
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

    if (-not $CurrentState.Exists) {
        return $false
    }

    if ($DesiredState.state -eq 'restarted') {
        return $false
    }

    if ($CurrentState.Status -ne $DesiredState.state) {
        return $false
    }

    if ($DesiredState.ContainsKey('startupType') -and $CurrentState.StartupType -ne $DesiredState.startupType) {
        return $false
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

    if (-not $CurrentState.Exists) {
        throw "Service '$($DesiredState.name)' was not found."
    }

    if ($DesiredState.ContainsKey('startupType')) {
        Set-Service -Name $DesiredState.name -StartupType (Convert-DewitStartupType -StartupType $DesiredState.startupType)
    }

    switch ($DesiredState.state) {
        'running' { Start-Service -Name $DesiredState.name }
        'stopped' { Stop-Service -Name $DesiredState.name -Force }
        'restarted' { Restart-Service -Name $DesiredState.name -Force }
    }

    $after = Get-DewitResourceState -DesiredState $DesiredState -Context $Context
    [pscustomobject]@{
        Changed = $true
        Message = "Updated service $($DesiredState.name)"
        Before  = $CurrentState
        After   = $after
    }
}

function Convert-DewitStartupType {
    param([Parameter(Mandatory)][string]$StartupType)

    switch ($StartupType) {
        'automatic' { 'Automatic' }
        'manual' { 'Manual' }
        'disabled' { 'Disabled' }
    }
}

Export-ModuleMember -Function Get-DewitResourceState, Test-DewitResourceState, Set-DewitResourceState
