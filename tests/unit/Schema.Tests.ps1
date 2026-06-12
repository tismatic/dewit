Import-Module "$PSScriptRoot\..\..\Dewit.psd1" -Force

Describe 'Dewit resource schema validation' {
    It 'rejects missing required fields' {
        InModuleScope Dewit {
            $resources = Get-DewitResourceIndex
            $threw = $false
            try {
                Test-DewitResourceSchema -TaskName demo -ResourceName file -DesiredState @{ state = 'present' } -ResourceInfo $resources['file']
            }
            catch {
                $threw = $true
            }
            $threw | Should Be $true
        }
    }

    It 'rejects invalid enum values' {
        InModuleScope Dewit {
            $resources = Get-DewitResourceIndex
            $threw = $false
            try {
                Test-DewitResourceSchema -TaskName demo -ResourceName file -DesiredState @{ path = 'x'; state = 'invalid' } -ResourceInfo $resources['file']
            }
            catch {
                $threw = $true
            }
            $threw | Should Be $true
        }
    }

    It 'rejects unsupported fields' {
        InModuleScope Dewit {
            $resources = Get-DewitResourceIndex
            $threw = $false
            try {
                Test-DewitResourceSchema -TaskName demo -ResourceName service -DesiredState @{ name = 'Spooler'; state = 'running'; typo = 'x' } -ResourceInfo $resources['service']
            }
            catch {
                $threw = $true
            }
            $threw | Should Be $true
        }
    }
}
