Import-Module "$PSScriptRoot\..\..\Dewit.psd1" -Force

Describe 'Dewit task execution' {
    It 'returns unreachable for non-local hosts until remoting is implemented' {
        InModuleScope Dewit {
            $resources = Get-DewitResourceIndex
            $result = Invoke-DewitTask -HostName remote01 -TaskName demo -ResourceName file -DesiredState @{ path = 'x'; state = 'present' } -ResourceInfo $resources['file'] -Mode run -WorkingPath $TestDrive
            $result.Status | Should Be 'UNREACHABLE'
        }
    }

    It 'returns noncompliant in test mode without changing state' {
        InModuleScope Dewit {
            $resources = Get-DewitResourceIndex
            $path = Join-Path $TestDrive 'missing.txt'
            $result = Invoke-DewitTask -HostName localhost -TaskName demo -ResourceName file -DesiredState @{ path = $path; state = 'present'; content = 'hello' } -ResourceInfo $resources['file'] -Mode test -WorkingPath $TestDrive
            $result.Status | Should Be 'NONCOMPLIANT'
            Test-Path -LiteralPath $path | Should Be $false
        }
    }
}
