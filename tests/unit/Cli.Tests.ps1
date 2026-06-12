Import-Module "$PSScriptRoot\..\..\Dewit.psd1" -Force

Describe 'Dewit CLI wrapper' {
    It 'shows help by default' {
        $help = dewit | Out-String
        $help | Should Match 'Usage:'
    }

    It 'shows command help' {
        $help = dewit help run | Out-String
        $help | Should Match 'dewit run'
    }
}
