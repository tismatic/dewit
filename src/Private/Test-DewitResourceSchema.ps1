function Test-DewitResourceSchema {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$TaskName,

        [Parameter(Mandatory)]
        [string]$ResourceName,

        [Parameter(Mandatory)]
        [hashtable]$DesiredState,

        [Parameter(Mandatory)]
        [object]$ResourceInfo
    )

    if (-not (Test-Path -Path $ResourceInfo.Schema)) {
        return
    }

    try {
        $schema = Get-Content -Path $ResourceInfo.Schema -Raw | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        throw "Could not read schema for resource '$ResourceName' at '$($ResourceInfo.Schema)'. $($_.Exception.Message)"
    }

    foreach ($requiredName in @($schema.required)) {
        if (-not $DesiredState.ContainsKey($requiredName) -or $null -eq $DesiredState[$requiredName] -or [string]$DesiredState[$requiredName] -eq '') {
            throw "Task '$TaskName' resource '$ResourceName' is missing required field '$requiredName'."
        }
    }

    $allowedProperties = @($schema.properties.PSObject.Properties.Name)
    if ($schema.additionalProperties -eq $false) {
        foreach ($propertyName in $DesiredState.Keys) {
            if ($propertyName -notin $allowedProperties) {
                throw "Task '$TaskName' resource '$ResourceName' has unsupported field '$propertyName'. Allowed fields: $($allowedProperties -join ', ')."
            }
        }
    }

    foreach ($propertyName in $DesiredState.Keys) {
        $schemaProperty = $schema.properties.$propertyName
        if (-not $schemaProperty) {
            continue
        }

        $enumProperty = $schemaProperty.PSObject.Properties['enum']
        if (-not $enumProperty -or $null -eq $enumProperty.Value) {
            continue
        }

        $enumValues = @($enumProperty.Value)
        if ($enumValues.Count -gt 0 -and [string]$DesiredState[$propertyName] -notin $enumValues) {
            throw "Task '$TaskName' resource '$ResourceName' field '$propertyName' has invalid value '$($DesiredState[$propertyName])'. Allowed values: $($enumValues -join ', ')."
        }
    }
}
