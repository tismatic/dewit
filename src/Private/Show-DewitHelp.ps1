function Show-DewitHelp {
    [CmdletBinding()]
    param(
        [string]$Command
    )

    switch ($Command) {
        'run' { @'
Usage: dewit run <playbook.yml> [-i <inventory.yml>] [-ReportPath <results.json>] [-DetailedExitCode]

Apply a playbook to the target hosts.
'@; break }
        'plan' { @'
Usage: dewit plan <playbook.yml> [-i <inventory.yml>] [-DetailedExitCode]

Preview changes without applying them.
'@; break }
        'test' { @'
Usage: dewit test <playbook.yml> [-i <inventory.yml>] [-DetailedExitCode]

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
  dewit plan <playbook.yml> [-i <inventory.yml>] [-DetailedExitCode]
  dewit run <playbook.yml> [-i <inventory.yml>] [-ReportPath <results.json>] [-DetailedExitCode]
  dewit test <playbook.yml> [-i <inventory.yml>] [-DetailedExitCode]
  dewit inventory <inventory.yml>
  dewit report <results.json> -OutFile <report.html>
  dewit help [command]
'@ }
    }
}
