Import-Module "$PSScriptRoot\..\..\Dewit.psd1" -Force

Describe 'Dewit task execution' {
    It 'returns unreachable when PowerShell remoting cannot connect' {
        InModuleScope Dewit {
            $resources = Get-DewitResourceIndex
            $result = Invoke-DewitTask -HostName remote01 -TaskName demo -ResourceName file -DesiredState @{ path = 'x'; state = 'present' } -ResourceInfo $resources['file'] -Mode run -WorkingPath $TestDrive
            $result.Status | Should Be 'UNREACHABLE'
        }
    }

    It 'returns remote Invoke-Command results' {
        InModuleScope Dewit {
            function Invoke-Command {
                param(
                    [string]$ComputerName,
                    [scriptblock]$ScriptBlock,
                    [object[]]$ArgumentList,
                    [string]$ErrorAction,
                    [int]$ThrottleLimit,
                    [pscredential]$Credential
                )

                [pscustomobject]@{
                    Status  = 'OK'
                    Changed = $false
                    Message = "mock remote $ComputerName throttle $ThrottleLimit"
                    Before  = $null
                    After   = $null
                    Error   = $null
                }
            }

            try {
                $resources = Get-DewitResourceIndex
                $result = Invoke-DewitTask -HostName remote01 -TaskName demo -ResourceName file -DesiredState @{ path = 'x'; state = 'present' } -ResourceInfo $resources['file'] -Mode run -WorkingPath $TestDrive -ThrottleLimit 7
                $result.Status | Should Be 'OK'
                $result.Message | Should Match 'remote01'
                $result.Message | Should Match '7'
            }
            finally {
                Remove-Item function:\Invoke-Command -ErrorAction SilentlyContinue
            }
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
