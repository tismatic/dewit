function Invoke-DewitTask {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$HostName,

        [Parameter(Mandatory)]
        [string]$TaskName,

        [Parameter(Mandatory)]
        [string]$ResourceName,

        [Parameter(Mandatory)]
        [hashtable]$DesiredState,

        [Parameter(Mandatory)]
        [object]$ResourceInfo,

        [Parameter(Mandatory)]
        [ValidateSet('run', 'plan', 'test')]
        [string]$Mode,

        [Parameter(Mandatory)]
        [string]$WorkingPath,

        [pscredential]$Credential,

        [int]$ThrottleLimit = 32
    )

    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    $context = @{
        HostName     = $HostName
        Mode         = $Mode
        CheckMode    = $Mode -ne 'run'
        WhatIf       = $Mode -eq 'plan'
        Variables    = @{}
        TaskName     = $TaskName
        ResourceName = $ResourceName
        WorkingPath  = $WorkingPath
    }

    if (Test-DewitLocalHost -HostName $HostName) {
        return Invoke-DewitLocalTask -HostName $HostName -TaskName $TaskName -ResourceName $ResourceName -DesiredState $DesiredState -ResourceInfo $ResourceInfo -Mode $Mode -Context $context -Timer $timer
    }

    return Invoke-DewitRemoteTask -HostName $HostName -TaskName $TaskName -ResourceName $ResourceName -DesiredState $DesiredState -ResourceInfo $ResourceInfo -Mode $Mode -WorkingPath $WorkingPath -Credential $Credential -ThrottleLimit $ThrottleLimit -Timer $timer
}

function Invoke-DewitLocalTask {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$HostName,
        [Parameter(Mandatory)][string]$TaskName,
        [Parameter(Mandatory)][string]$ResourceName,
        [Parameter(Mandatory)][hashtable]$DesiredState,
        [Parameter(Mandatory)][object]$ResourceInfo,
        [Parameter(Mandatory)][ValidateSet('run', 'plan', 'test')][string]$Mode,
        [Parameter(Mandatory)][hashtable]$Context,
        [Parameter(Mandatory)][System.Diagnostics.Stopwatch]$Timer
    )

    try {
        $resourceModule = Import-Module -Name $ResourceInfo.Entrypoint -PassThru -Force -ErrorAction Stop
        $getCommand = Get-Command -Name Get-DewitResourceState -Module $resourceModule -ErrorAction Stop
        $testCommand = Get-Command -Name Test-DewitResourceState -Module $resourceModule -ErrorAction Stop
        $setCommand = Get-Command -Name Set-DewitResourceState -Module $resourceModule -ErrorAction Stop

        $current = & $getCommand -DesiredState $DesiredState -Context $context
        $inState = & $testCommand -DesiredState $DesiredState -CurrentState $current -Context $context

        if ($inState) {
            $timer.Stop()
            return New-DewitTaskResult -HostName $HostName -TaskName $TaskName -ResourceName $ResourceName -Status 'OK' -Changed $false -Message (Get-DewitOkMessage -ResourceName $ResourceName -DesiredState $DesiredState) -Before $current -After $current -DurationMs $timer.ElapsedMilliseconds
        }

        if ($Mode -eq 'plan') {
            $timer.Stop()
            return New-DewitTaskResult -HostName $HostName -TaskName $TaskName -ResourceName $ResourceName -Status 'CHANGED' -Changed $true -Message (Get-DewitPlanMessage -ResourceName $ResourceName -DesiredState $DesiredState) -Before $current -After $null -DurationMs $timer.ElapsedMilliseconds
        }

        if ($Mode -eq 'test') {
            $timer.Stop()
            return New-DewitTaskResult -HostName $HostName -TaskName $TaskName -ResourceName $ResourceName -Status 'NONCOMPLIANT' -Changed $false -Message (Get-DewitPlanMessage -ResourceName $ResourceName -DesiredState $DesiredState) -Before $current -After $null -DurationMs $timer.ElapsedMilliseconds
        }

        $setResult = & $setCommand -DesiredState $DesiredState -CurrentState $current -Context $context
        $timer.Stop()
        return New-DewitTaskResult -HostName $HostName -TaskName $TaskName -ResourceName $ResourceName -Status 'CHANGED' -Changed $true -Message $setResult.Message -Before $setResult.Before -After $setResult.After -DurationMs $timer.ElapsedMilliseconds
    }
    catch {
        $Timer.Stop()
        return New-DewitTaskResult -HostName $HostName -TaskName $TaskName -ResourceName $ResourceName -Status 'FAILED' -Changed $false -Message $_.Exception.Message -ErrorRecord $_ -DurationMs $timer.ElapsedMilliseconds
    }
}

function Invoke-DewitRemoteTask {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$HostName,
        [Parameter(Mandatory)][string]$TaskName,
        [Parameter(Mandatory)][string]$ResourceName,
        [Parameter(Mandatory)][hashtable]$DesiredState,
        [Parameter(Mandatory)][object]$ResourceInfo,
        [Parameter(Mandatory)][ValidateSet('run', 'plan', 'test')][string]$Mode,
        [Parameter(Mandatory)][string]$WorkingPath,
        [pscredential]$Credential,
        [int]$ThrottleLimit = 32,
        [Parameter(Mandatory)][System.Diagnostics.Stopwatch]$Timer
    )

    try {
        $resourceSource = Get-Content -Path $ResourceInfo.Entrypoint -Raw -ErrorAction Stop
        $invokeParameters = @{
            ComputerName  = $HostName
            ScriptBlock   = ${function:Invoke-DewitRemoteResourceScript}
            ArgumentList  = @($resourceSource, $DesiredState, $ResourceName, $TaskName, $Mode, $WorkingPath)
            ErrorAction   = 'Stop'
            ThrottleLimit = $ThrottleLimit
        }

        if ($Credential) {
            $invokeParameters.Credential = $Credential
        }

        $remoteResult = Invoke-Command @invokeParameters
        $Timer.Stop()

        return New-DewitTaskResult -HostName $HostName -TaskName $TaskName -ResourceName $ResourceName -Status $remoteResult.Status -Changed ([bool]$remoteResult.Changed) -Message $remoteResult.Message -Before $remoteResult.Before -After $remoteResult.After -ErrorRecord $null -DurationMs $Timer.ElapsedMilliseconds
    }
    catch {
        $Timer.Stop()
        return New-DewitTaskResult -HostName $HostName -TaskName $TaskName -ResourceName $ResourceName -Status 'UNREACHABLE' -Changed $false -Message "Could not connect to host '$HostName' using PowerShell remoting. $($_.Exception.Message)" -ErrorRecord $_ -DurationMs $Timer.ElapsedMilliseconds
    }
}

function Invoke-DewitRemoteResourceScript {
    param(
        [Parameter(Mandatory)][string]$ResourceSource,
        [Parameter(Mandatory)][hashtable]$DesiredState,
        [Parameter(Mandatory)][string]$ResourceName,
        [Parameter(Mandatory)][string]$TaskName,
        [Parameter(Mandatory)][ValidateSet('run', 'plan', 'test')][string]$Mode,
        [Parameter(Mandatory)][string]$WorkingPath
    )

    $context = @{
        HostName     = $env:COMPUTERNAME
        Mode         = $Mode
        CheckMode    = $Mode -ne 'run'
        WhatIf       = $Mode -eq 'plan'
        Variables    = @{}
        TaskName     = $TaskName
        ResourceName = $ResourceName
        WorkingPath  = $WorkingPath
    }

    try {
        $resourceModule = New-Module -ScriptBlock ([scriptblock]::Create($ResourceSource))
        $getCommand = Get-Command -Name Get-DewitResourceState -Module $resourceModule -ErrorAction Stop
        $testCommand = Get-Command -Name Test-DewitResourceState -Module $resourceModule -ErrorAction Stop
        $setCommand = Get-Command -Name Set-DewitResourceState -Module $resourceModule -ErrorAction Stop

        $current = & $getCommand -DesiredState $DesiredState -Context $context
        $inState = & $testCommand -DesiredState $DesiredState -CurrentState $current -Context $context

        if ($inState) {
            return [pscustomobject]@{
                Status  = 'OK'
                Changed = $false
                Message = 'Resource already matches desired state.'
                Before  = $current
                After   = $current
                Error   = $null
            }
        }

        if ($Mode -eq 'plan') {
            return [pscustomobject]@{
                Status  = 'CHANGED'
                Changed = $true
                Message = 'Would update resource state.'
                Before  = $current
                After   = $null
                Error   = $null
            }
        }

        if ($Mode -eq 'test') {
            return [pscustomobject]@{
                Status  = 'NONCOMPLIANT'
                Changed = $false
                Message = 'Resource does not match desired state.'
                Before  = $current
                After   = $null
                Error   = $null
            }
        }

        $setResult = & $setCommand -DesiredState $DesiredState -CurrentState $current -Context $context
        return [pscustomobject]@{
            Status  = 'CHANGED'
            Changed = $true
            Message = $setResult.Message
            Before  = $setResult.Before
            After   = $setResult.After
            Error   = $null
        }
    }
    catch {
        return [pscustomobject]@{
            Status  = 'FAILED'
            Changed = $false
            Message = $_.Exception.Message
            Before  = $null
            After   = $null
            Error   = $_.Exception.Message
        }
    }
}

function Test-DewitLocalHost {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$HostName
    )

    $localNames = @('localhost', '.', '127.0.0.1', '::1', $env:COMPUTERNAME, [System.Net.Dns]::GetHostName()) | Where-Object { $_ }
    return $HostName -in $localNames
}

function Get-DewitOkMessage {
    param([string]$ResourceName, [hashtable]$DesiredState)
    switch ($ResourceName) {
        'file' { return "File state already matches: $($DesiredState.path)" }
        'service' { return "Service state already matches: $($DesiredState.name)" }
        'registry' { return "Registry value already matches: $($DesiredState.path)\$($DesiredState.name)" }
        default { return 'Resource already matches desired state.' }
    }
}

function Get-DewitPlanMessage {
    param([string]$ResourceName, [hashtable]$DesiredState)
    switch ($ResourceName) {
        'file' { return "Would update file state: $($DesiredState.path)" }
        'service' { return "Would update service state: $($DesiredState.name)" }
        'registry' { return "Would update registry value: $($DesiredState.path)\$($DesiredState.name)" }
        default { return 'Would update resource state.' }
    }
}
