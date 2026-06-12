function Get-DewitResourceState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$DesiredState,

        [Parameter(Mandatory)]
        [hashtable]$Context
    )

    $path = Resolve-DewitResourcePath -Path $DesiredState.path -WorkingPath $Context.WorkingPath
    $exists = Test-Path -LiteralPath $path

    if (-not $exists) {
        return [pscustomobject]@{
            Exists  = $false
            Path    = $path
            Type    = $null
            Content = $null
        }
    }

    $item = Get-Item -LiteralPath $path
    $isDirectory = $item.PSIsContainer
    $content = $null
    if (-not $isDirectory) {
        $content = Get-Content -LiteralPath $path -Raw -ErrorAction SilentlyContinue
    }

    [pscustomobject]@{
        Exists  = $true
        Path    = $path
        Type    = if ($isDirectory) { 'directory' } else { 'file' }
        Content = $content
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

    switch ($DesiredState.state) {
        'absent' { return -not $CurrentState.Exists }
        'directory' { return $CurrentState.Exists -and $CurrentState.Type -eq 'directory' }
        'present' {
            if (-not $CurrentState.Exists -or $CurrentState.Type -ne 'file') {
                return $false
            }

            if ($DesiredState.ContainsKey('content')) {
                return [string]$CurrentState.Content -eq [string]$DesiredState.content
            }

            return $true
        }
    }
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

    $path = Resolve-DewitResourcePath -Path $DesiredState.path -WorkingPath $Context.WorkingPath
    $state = $DesiredState.state

    switch ($state) {
        'absent' {
            if (Test-Path -LiteralPath $path) {
                Remove-Item -LiteralPath $path -Recurse -Force
            }
            $message = "Removed $path"
        }
        'directory' {
            New-Item -Path $path -ItemType Directory -Force | Out-Null
            $message = "Created directory $path"
        }
        'present' {
            $parent = Split-Path -Parent $path
            if ($parent -and -not (Test-Path -LiteralPath $parent)) {
                New-Item -Path $parent -ItemType Directory -Force | Out-Null
            }

            if ($DesiredState.ContainsKey('content')) {
                Set-Content -LiteralPath $path -Value $DesiredState.content -NoNewline -Encoding utf8
                $message = "Wrote file $path"
            }
            elseif (-not (Test-Path -LiteralPath $path)) {
                New-Item -Path $path -ItemType File -Force | Out-Null
                $message = "Created file $path"
            }
            else {
                $message = "Updated file $path"
            }
        }
    }

    $after = Get-DewitResourceState -DesiredState $DesiredState -Context $Context
    [pscustomobject]@{
        Changed = $true
        Message = $message
        Before  = $CurrentState
        After   = $after
    }
}

function Resolve-DewitResourcePath {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$WorkingPath
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return [System.IO.Path]::GetFullPath((Join-Path $WorkingPath $Path))
}

Export-ModuleMember -Function Get-DewitResourceState, Test-DewitResourceState, Set-DewitResourceState
