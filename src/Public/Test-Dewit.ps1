function Test-Dewit {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Path,

        [Alias('i')]
        [string]$InventoryPath,

        [switch]$DetailedExitCode,

        [switch]$PassThru
    )

    Invoke-Dewit -Path $Path -InventoryPath $InventoryPath -Mode test -DetailedExitCode:$DetailedExitCode -PassThru:$PassThru
}
