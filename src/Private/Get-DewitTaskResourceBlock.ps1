function Get-DewitTaskResourceBlock {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object]$Task
    )

    $reserved = @('name', 'when', 'tags', 'ignoreErrors', 'register')

    if ($Task -is [System.Collections.IDictionary]) {
        $keys = @($Task.Keys | Where-Object { $_ -notin $reserved })
        if ($keys.Count -ne 1) {
            throw "Task '$($Task.name)' must contain exactly one resource block. Found $($keys.Count)."
        }

        return [pscustomobject]@{
            Name  = $keys[0]
            Value = $Task[$keys[0]]
        }
    }

    $properties = @($Task.PSObject.Properties | Where-Object { $_.Name -notin $reserved -and $_.MemberType -eq 'NoteProperty' })

    if ($properties.Count -ne 1) {
        throw "Task '$($Task.name)' must contain exactly one resource block. Found $($properties.Count)."
    }

    [pscustomobject]@{
        Name  = $properties[0].Name
        Value = $properties[0].Value
    }
}
