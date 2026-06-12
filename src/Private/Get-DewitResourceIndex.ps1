function Get-DewitResourceIndex {
    [CmdletBinding()]
    param()

    $resourceRoot = Join-Path $script:DewitModuleRoot 'src/Resources'
    $index = @{}

    if (-not (Test-Path -Path $resourceRoot)) {
        return $index
    }

    Get-ChildItem -Path $resourceRoot -Directory | ForEach-Object {
        $manifestPath = Join-Path $_.FullName 'dewit.resource.json'
        if (-not (Test-Path -Path $manifestPath)) {
            return
        }

        try {
            $manifest = Get-Content -Path $manifestPath -Raw | ConvertFrom-Json -ErrorAction Stop
        }
        catch {
            throw "Failed to load resource manifest '$manifestPath'. $($_.Exception.Message)"
        }

        $entrypointPath = Join-Path $_.FullName $manifest.entrypoint
        $schemaPath = Join-Path $_.FullName $manifest.schema

        $index[$manifest.name] = [pscustomobject]@{
            Name       = $manifest.name
            DisplayName = $manifest.displayName
            Description = $manifest.description
            Version    = $manifest.version
            Source     = 'Dewit'
            Path       = $_.FullName
            Manifest   = $manifestPath
            Entrypoint = $entrypointPath
            Schema     = $schemaPath
        }
    }

    return $index
}
