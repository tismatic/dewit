function Get-DewitExitCode {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object[]]$Results,

        [Parameter(Mandatory)]
        [ValidateSet('run', 'plan', 'test')]
        [string]$Mode,

        [switch]$DetailedExitCode
    )

    if (@($Results | Where-Object Status -eq 'FAILED').Count -gt 0) {
        return 6
    }

    if (@($Results | Where-Object Status -eq 'UNREACHABLE').Count -gt 0) {
        return 5
    }

    if ($Mode -eq 'test' -and @($Results | Where-Object Status -eq 'NONCOMPLIANT').Count -gt 0) {
        return 3
    }

    if ($DetailedExitCode -and @($Results | Where-Object Changed).Count -gt 0) {
        return 2
    }

    return 0
}
