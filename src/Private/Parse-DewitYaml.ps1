function Parse-DewitYaml {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (-not (Test-Path -Path $Path)) {
        throw "YAML file was not found: $Path"
    }

    if (-not (Get-Command ConvertFrom-Yaml -ErrorAction SilentlyContinue)) {
        throw "Dewit requires the 'powershell-yaml' module for YAML parsing. Install it with: Install-Module powershell-yaml -Scope CurrentUser"
    }

    try {
        $content = Get-Content -Path $Path -Raw -ErrorAction Stop
        return $content | ConvertFrom-Yaml -ErrorAction Stop
    }
    catch {
        throw "Failed to parse YAML file '$Path'. $($_.Exception.Message)"
    }
}
