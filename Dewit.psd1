@{
    RootModule        = 'Dewit.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = '7b88b136-c986-4f05-92aa-6b94e5d4d110'
    Author            = 'Dewit Contributors'
    CompanyName       = 'Dewit'
    Copyright         = '(c) Dewit Contributors. All rights reserved.'
    Description       = 'PowerShell-native desired-state automation for Windows admins.'
    PowerShellVersion = '7.4'
    FunctionsToExport = @('Invoke-Dewit', 'Test-Dewit', 'New-DewitProject', 'Test-DewitInventory', 'New-DewitReport', 'Get-DewitResource', 'dewit')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags       = @('PowerShell', 'Windows', 'DesiredState', 'Automation')
            LicenseUri = 'https://www.apache.org/licenses/LICENSE-2.0'
            ProjectUri = 'https://github.com/dewit/dewit'
        }
    }
}
