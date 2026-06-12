$modulePath = "$PSScriptRoot\..\..\src\Resources\Service\DewitResource.psm1"
Import-Module $modulePath -Force

Describe 'Dewit service resource' {
    It 'reports a missing service as non-compliant' {
        $desired = @{ name = 'DewitDefinitelyMissingService'; state = 'running' }
        $context = @{}
        $current = Get-DewitResourceState -DesiredState $desired -Context $context
        Test-DewitResourceState -DesiredState $desired -CurrentState $current -Context $context | Should Be $false
    }
}
