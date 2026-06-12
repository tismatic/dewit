function Get-DewitResource {
    [CmdletBinding()]
    param()

    Get-DewitResourceIndex | ForEach-Object {
        $_.GetEnumerator()
    } | Sort-Object Name | ForEach-Object {
        [pscustomobject]@{
            Name        = $_.Value.Name
            DisplayName = $_.Value.DisplayName
            Version     = $_.Value.Version
            Source      = $_.Value.Source
            Path        = $_.Value.Path
        }
    }
}
