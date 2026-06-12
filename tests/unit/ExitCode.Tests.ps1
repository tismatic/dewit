Import-Module "$PSScriptRoot\..\..\Dewit.psd1" -Force

Describe 'Dewit exit codes' {
    It 'returns zero for successful unchanged results' {
        InModuleScope Dewit {
            $results = @([pscustomobject]@{ Status = 'OK'; Changed = $false })
            Get-DewitExitCode -Results $results -Mode run | Should Be 0
        }
    }

    It 'returns two for changes only with detailed exit codes' {
        InModuleScope Dewit {
            $results = @([pscustomobject]@{ Status = 'CHANGED'; Changed = $true })
            Get-DewitExitCode -Results $results -Mode run -DetailedExitCode | Should Be 2
        }
    }

    It 'returns three for noncompliance in test mode' {
        InModuleScope Dewit {
            $results = @([pscustomobject]@{ Status = 'NONCOMPLIANT'; Changed = $false })
            Get-DewitExitCode -Results $results -Mode test | Should Be 3
        }
    }

    It 'returns five for unreachable hosts' {
        InModuleScope Dewit {
            $results = @([pscustomobject]@{ Status = 'UNREACHABLE'; Changed = $false })
            Get-DewitExitCode -Results $results -Mode run | Should Be 5
        }
    }

    It 'returns six for failed tasks' {
        InModuleScope Dewit {
            $results = @([pscustomobject]@{ Status = 'FAILED'; Changed = $false })
            Get-DewitExitCode -Results $results -Mode run | Should Be 6
        }
    }
}
