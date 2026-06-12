Import-Module "$PSScriptRoot\..\..\Dewit.psd1" -Force

Describe 'Dewit YAML parsing' {
    It 'parses the example playbook when powershell-yaml is available' {
        if (-not (Get-Command ConvertFrom-Yaml -ErrorAction SilentlyContinue)) {
            Set-TestInconclusive -Message 'ConvertFrom-Yaml is not available.'
        }

        InModuleScope Dewit {
            $result = Parse-DewitYaml -Path "$PSScriptRoot\..\..\examples\localhost\baseline.yml"
            $result.name | Should Be 'Localhost demo baseline'
        }
    }
}
