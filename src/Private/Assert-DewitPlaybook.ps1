function Assert-DewitPlaybook {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object]$Playbook,

        [Parameter(Mandatory)]
        [string]$Path
    )

    if (-not $Playbook.name) {
        throw "Playbook '$Path' is missing required field 'name'."
    }

    if (-not $Playbook.tasks) {
        throw "Playbook '$Path' is missing required field 'tasks'."
    }

    foreach ($task in $Playbook.tasks) {
        if (-not $task.name) {
            throw "Playbook '$Path' contains a task without required field 'name'."
        }

        [void](Get-DewitTaskResourceBlock -Task $task)
    }
}
