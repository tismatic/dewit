function Write-DewitResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object]$Result
    )

    $line = '{0,-22} {1,-12} {2}' -f $Result.HostName, $Result.Status, $Result.Message
    Write-Host $line
}

function Write-DewitSummary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object[]]$Results
    )

    Write-Host 'SUMMARY'
    foreach ($group in ($Results | Group-Object HostName)) {
        $ok = @($group.Group | Where-Object Status -eq 'OK').Count
        $changed = @($group.Group | Where-Object Status -eq 'CHANGED').Count
        $failed = @($group.Group | Where-Object Status -eq 'FAILED').Count
        $unreachable = @($group.Group | Where-Object Status -eq 'UNREACHABLE').Count
        $nonCompliant = @($group.Group | Where-Object Status -eq 'NONCOMPLIANT').Count
        $line = '{0,-22} OK={1}  CHANGED={2}  FAILED={3}  UNREACHABLE={4}  NONCOMPLIANT={5}' -f $group.Name, $ok, $changed, $failed, $unreachable, $nonCompliant
        Write-Host $line
    }
}
