Import-Module "$PSScriptRoot\..\..\Dewit.psd1" -Force

Describe 'Dewit result object' {
    It 'has the standard result properties' {
        InModuleScope Dewit {
            $result = New-DewitTaskResult -HostName localhost -TaskName demo -ResourceName file -Status OK -Changed:$false -Message ok -DurationMs 1
            $propertyNames = @($result.PSObject.Properties.Name)
            $propertyNames -contains 'HostName' | Should Be $true
            $propertyNames -contains 'TaskName' | Should Be $true
            $propertyNames -contains 'Resource' | Should Be $true
            $propertyNames -contains 'Status' | Should Be $true
            $propertyNames -contains 'Changed' | Should Be $true
            $propertyNames -contains 'DurationMs' | Should Be $true
        }
    }
}
