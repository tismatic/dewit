function Test-Dewit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Path,

        [Alias('i')]
        [string]$InventoryPath,

        [string[]]$Hosts,

        [pscredential]$Credential,

        [int]$ThrottleLimit = 32,

        [switch]$DetailedExitCode,

        [switch]$PassThru
    )

    Invoke-Dewit -Path $Path -InventoryPath $InventoryPath -Hosts $Hosts -Mode test -Credential $Credential -ThrottleLimit $ThrottleLimit -DetailedExitCode:$DetailedExitCode -PassThru:$PassThru
}
