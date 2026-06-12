function Invoke-Dewit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Path,

        [ValidateSet('run', 'plan', 'test')]
        [string]$Mode = 'run',

        [Alias('i')]
        [string]$InventoryPath,

        [string[]]$Hosts,

        [string]$ReportPath,

        [pscredential]$Credential,

        [int]$ThrottleLimit = 32,

        [switch]$DetailedExitCode,

        [switch]$PassThru
    )

    $resolvedPath = Resolve-DewitPath -Path $Path
    $playbook = Parse-DewitYaml -Path $resolvedPath
    Assert-DewitPlaybook -Playbook $playbook -Path $resolvedPath

    $targetHosts = Resolve-DewitHosts -Playbook $playbook -InventoryPath $InventoryPath -Hosts $Hosts
    $resources = Get-DewitResourceIndex
    $results = New-Object System.Collections.Generic.List[object]

    Write-Host "PLAY [$($playbook.name)]"
    Write-Host ''

    foreach ($task in $playbook.tasks) {
        $resourceBlock = Get-DewitTaskResourceBlock -Task $task
        $resourceName = $resourceBlock.Name
        $desiredState = ConvertTo-DewitHashtable -InputObject $resourceBlock.Value

        if (-not $resources.ContainsKey($resourceName)) {
            throw "Task '$($task.name)' references unknown resource '$resourceName'. Run 'dewit resources' to list available resources."
        }

        Test-DewitResourceSchema -TaskName $task.name -ResourceName $resourceName -DesiredState $desiredState -ResourceInfo $resources[$resourceName]

        Write-Host "TASK [$($task.name)]"

        foreach ($targetHostName in $targetHosts) {
            $result = Invoke-DewitTask -HostName $targetHostName -TaskName $task.name -ResourceName $resourceName -DesiredState $desiredState -ResourceInfo $resources[$resourceName] -Mode $Mode -WorkingPath (Split-Path -Parent $resolvedPath) -Credential $Credential -ThrottleLimit $ThrottleLimit
            $results.Add($result)
            Write-DewitResult -Result $result
        }

        Write-Host ''
    }

    Write-DewitSummary -Results $results

    if ($ReportPath) {
        $reportFullPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ReportPath)
        $results | ConvertTo-Json -Depth 20 | Set-Content -Path $reportFullPath -Encoding utf8
    }

    $global:LASTEXITCODE = Get-DewitExitCode -Results $results.ToArray() -Mode $Mode -DetailedExitCode:$DetailedExitCode

    if ($PassThru) {
        return $results.ToArray()
    }
}
