Import-Module "$PSScriptRoot\..\..\Dewit.psd1" -Force

Describe 'Dewit resource discovery' {
    It 'discovers built-in resources' {
        $resources = Get-DewitResource
        @($resources.Name) -contains 'file' | Should Be $true
        @($resources.Name) -contains 'service' | Should Be $true
    }
}
