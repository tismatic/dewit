function Show-DewitHelp {
    [CmdletBinding()]
    param(
        [string]$Command
    )

    switch ($Command) {
        'run' { @'
Usage: dewit run <playbook.yml> [-Hosts <host1,host2>] [-i <inventory.yml>] [-Credential <PSCredential>] [-ThrottleLimit <n>] [-ReportPath <results.json>] [-DetailedExitCode]

Apply a playbook to the target hosts.
'@; break }
        'plan' { @'
Usage: dewit plan <playbook.yml> [-Hosts <host1,host2>] [-i <inventory.yml>] [-Credential <PSCredential>] [-ThrottleLimit <n>] [-DetailedExitCode]

Preview changes without applying them.
'@; break }
        'test' { @'
Usage: dewit test <playbook.yml> [-Hosts <host1,host2>] [-i <inventory.yml>] [-Credential <PSCredential>] [-ThrottleLimit <n>] [-DetailedExitCode]

Check compliance without applying changes.
'@; break }
        'init' { @'
Usage: dewit init [path]

Create a starter Dewit project in the current directory or the provided path.
'@; break }
        'resources' { @'
Usage: dewit resources

List available Dewit resources.
'@; break }
        'report' { @'
Usage: dewit report <results.json> -OutFile <report.html>

Generate a basic HTML report from a JSON result file.
'@; break }
        default { @'
Dewit: Desired-state automation for Windows admins.

Usage:
  dewit init [path]
  dewit resources
  dewit plan <playbook.yml> [-Hosts <host1,host2>] [-i <inventory.yml>] [-Credential <PSCredential>] [-DetailedExitCode]
  dewit run <playbook.yml> [-Hosts <host1,host2>] [-i <inventory.yml>] [-Credential <PSCredential>] [-ReportPath <results.json>] [-DetailedExitCode]
  dewit test <playbook.yml> [-Hosts <host1,host2>] [-i <inventory.yml>] [-Credential <PSCredential>] [-DetailedExitCode]
  dewit inventory <inventory.yml>
  dewit report <results.json> -OutFile <report.html>
  dewit help [command]
'@ }
    }
}
