$modulePath = "$PSScriptRoot\..\..\src\Resources\Registry\DewitResource.psm1"
Import-Module $modulePath -Force

Describe 'Dewit registry resource' {
    It 'is idempotent after setting a string value' {
        $testKey = "HKCU:\Software\DewitPester_$([guid]::NewGuid().ToString('N'))"
        $desired = @{ path = $testKey; name = 'ManagedBy'; value = 'Dewit'; type = 'string'; state = 'present' }
        $context = @{}

        try {
            $current = Get-DewitResourceState -DesiredState $desired -Context $context
            Set-DewitResourceState -DesiredState $desired -CurrentState $current -Context $context | Out-Null
            $after = Get-DewitResourceState -DesiredState $desired -Context $context
            Test-DewitResourceState -DesiredState $desired -CurrentState $after -Context $context | Should Be $true
        }
        finally {
            Remove-Item -Path $testKey -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'is compliant when an absent value does not exist' {
        $desired = @{ path = "HKCU:\Software\DewitPester_$([guid]::NewGuid().ToString('N'))"; name = 'Missing'; state = 'absent' }
        $context = @{}
        $current = Get-DewitResourceState -DesiredState $desired -Context $context
        Test-DewitResourceState -DesiredState $desired -CurrentState $current -Context $context | Should Be $true
    }
}
