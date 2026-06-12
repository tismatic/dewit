function New-DewitTaskResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$HostName,
        [Parameter(Mandatory)][string]$TaskName,
        [Parameter(Mandatory)][string]$ResourceName,
        [Parameter(Mandatory)][string]$Status,
        [Parameter(Mandatory)][bool]$Changed,
        [string]$Message,
        [object]$Before,
        [object]$After,
        [object]$ErrorRecord,
        [long]$DurationMs
    )

    [pscustomobject]@{
        HostName   = $HostName
        TaskName   = $TaskName
        Resource   = $ResourceName
        Status     = $Status
        Changed    = $Changed
        Message    = $Message
        Before     = $Before
        After      = $After
        Error      = if ($ErrorRecord) { $ErrorRecord.Exception.Message } else { $null }
        DurationMs = $DurationMs
    }
}
