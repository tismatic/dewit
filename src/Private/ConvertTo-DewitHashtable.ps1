function ConvertTo-DewitHashtable {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [object]$InputObject
    )

    if ($null -eq $InputObject) {
        return @{}
    }

    if ($InputObject -is [hashtable]) {
        $output = @{}
        foreach ($key in $InputObject.Keys) {
            $output[$key] = ConvertTo-DewitValue -InputObject $InputObject[$key]
        }
        return $output
    }

    if ($InputObject -is [System.Collections.IDictionary]) {
        $output = @{}
        foreach ($key in $InputObject.Keys) {
            $output[$key] = ConvertTo-DewitValue -InputObject $InputObject[$key]
        }
        return $output
    }

    $properties = $InputObject.PSObject.Properties | Where-Object MemberType -eq 'NoteProperty'
    $hash = @{}
    foreach ($property in $properties) {
        $hash[$property.Name] = ConvertTo-DewitValue -InputObject $property.Value
    }

    return $hash
}

function ConvertTo-DewitValue {
    param([AllowNull()][object]$InputObject)

    if ($null -eq $InputObject) {
        return $null
    }

    if ($InputObject -is [string]) {
        return $InputObject
    }

    if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [System.Collections.IDictionary]) {
        return @($InputObject | ForEach-Object { ConvertTo-DewitValue -InputObject $_ })
    }

    if ($InputObject -is [hashtable] -or $InputObject -is [System.Collections.IDictionary]) {
        return ConvertTo-DewitHashtable -InputObject $InputObject
    }

    $noteProperties = @($InputObject.PSObject.Properties | Where-Object MemberType -eq 'NoteProperty')
    if ($noteProperties.Count -gt 0) {
        return ConvertTo-DewitHashtable -InputObject $InputObject
    }

    return $InputObject
}
