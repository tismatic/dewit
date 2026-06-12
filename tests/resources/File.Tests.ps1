$modulePath = "$PSScriptRoot\..\..\src\Resources\File\DewitResource.psm1"
Import-Module $modulePath -Force

Describe 'Dewit file resource' {
    It 'reports a missing file as non-compliant' {
        $desired = @{ path = Join-Path $TestDrive 'missing.txt'; state = 'present'; content = 'hello' }
        $context = @{ WorkingPath = $TestDrive }
        $current = Get-DewitResourceState -DesiredState $desired -Context $context
        Test-DewitResourceState -DesiredState $desired -CurrentState $current -Context $context | Should Be $false
    }

    It 'is idempotent after setting content' {
        $desired = @{ path = Join-Path $TestDrive 'hello.txt'; state = 'present'; content = 'hello' }
        $context = @{ WorkingPath = $TestDrive }
        $current = Get-DewitResourceState -DesiredState $desired -Context $context
        Set-DewitResourceState -DesiredState $desired -CurrentState $current -Context $context | Out-Null
        $after = Get-DewitResourceState -DesiredState $desired -Context $context
        Test-DewitResourceState -DesiredState $desired -CurrentState $after -Context $context | Should Be $true
    }
}
