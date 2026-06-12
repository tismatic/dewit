Import-Module "$PSScriptRoot\..\..\Dewit.psd1" -Force

Describe 'Dewit inventory resolution' {
    It 'resolves simple hosts' {
        InModuleScope Dewit {
            $inventory = @{ hosts = @('localhost', 'web01') }
            $hosts = Resolve-DewitInventoryHosts -Inventory $inventory
            $hosts | Should Be @('localhost', 'web01')
        }
    }

    It 'resolves grouped hosts' {
        InModuleScope Dewit {
            $inventory = @{ groups = @{ web = @{ hosts = @('web01', 'web02') } } }
            $hosts = Resolve-DewitPlaybookHosts -RequestedHosts @('web') -Inventory $inventory -InventoryHosts @('web01', 'web02')
            $hosts | Should Be @('web01', 'web02')
        }
    }

    It 'resolves all hosts' {
        InModuleScope Dewit {
            $inventoryHosts = @('localhost', 'web01')
            $hosts = Resolve-DewitPlaybookHosts -RequestedHosts @('all') -Inventory @{ hosts = $inventoryHosts } -InventoryHosts $inventoryHosts
            $hosts | Should Be $inventoryHosts
        }
    }

    It 'rejects inventories without hosts or groups' {
        InModuleScope Dewit {
            $threw = $false
            try {
                Assert-DewitInventory -Inventory @{ defaults = @{} } -Path inventory.yml
            }
            catch {
                $threw = $true
            }
            $threw | Should Be $true
        }
    }
}
