function dewit {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ValidateSet('run', 'plan', 'test', 'init', 'resources', 'inventory', 'report', 'help')]
        [string]$Command = 'help',

        [Parameter(Position = 1)]
        [string]$Path,

        [Alias('i')]
        [string]$InventoryPath,

        [string]$ReportPath,

        [switch]$DetailedExitCode,

        [string]$OutFile
    )

    switch ($Command) {
        'help' { Show-DewitHelp -Command $Path; break }
        'init' { New-DewitProject -Path ($Path ?? (Get-Location).Path); break }
        'resources' { Get-DewitResource; break }
        'inventory' {
            if (-not $Path) { throw "Missing inventory path. Use: dewit inventory <inventory.yml>" }
            Test-DewitInventory -Path $Path
            break
        }
        'report' {
            if (-not $Path) { throw "Missing results path. Use: dewit report <results.json> -OutFile <report.html>" }
            if (-not $OutFile) { throw "Missing output path. Use: dewit report <results.json> -OutFile <report.html>" }
            New-DewitReport -InputPath $Path -OutFile $OutFile
            break
        }
        'test' {
            if (-not $Path) { throw "Missing playbook path. Use: dewit test <playbook.yml>" }
            Invoke-Dewit -Path $Path -InventoryPath $InventoryPath -Mode test -ReportPath $ReportPath -DetailedExitCode:$DetailedExitCode
            break
        }
        'plan' {
            if (-not $Path) { throw "Missing playbook path. Use: dewit plan <playbook.yml>" }
            Invoke-Dewit -Path $Path -InventoryPath $InventoryPath -Mode plan -ReportPath $ReportPath -DetailedExitCode:$DetailedExitCode
            break
        }
        'run' {
            if (-not $Path) { throw "Missing playbook path. Use: dewit run <playbook.yml>" }
            Invoke-Dewit -Path $Path -InventoryPath $InventoryPath -Mode run -ReportPath $ReportPath -DetailedExitCode:$DetailedExitCode
            break
        }
    }
}
