function New-DewitProject {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0)]
        [string]$Path = (Get-Location).Path,

        [switch]$Force
    )

    if (-not (Test-Path -Path $Path)) {
        if ($PSCmdlet.ShouldProcess($Path, 'Create Dewit project directory')) {
            New-Item -Path $Path -ItemType Directory -Force | Out-Null
        }
    }

    $inventoryPath = Join-Path $Path 'inventory.yml'
    $baselinePath = Join-Path $Path 'baseline.yml'
    $readmePath = Join-Path $Path 'README.md'

    $files = @(
        @{ Path = $inventoryPath; Content = @'
hosts:
  - localhost
'@ },
        @{ Path = $baselinePath; Content = @'
name: Localhost demo baseline

hosts:
  - localhost

tasks:
  - name: Ensure demo directory exists
    file:
      path: .\DewitDemo
      state: directory

  - name: Ensure demo file exists
    file:
      path: .\DewitDemo\hello.txt
      content: Hello from Dewit.
      state: present
'@ },
        @{ Path = $readmePath; Content = @'
# Dewit Project

Run a dry-run plan:

```powershell
dewit plan .\baseline.yml
```

Apply the baseline:

```powershell
dewit run .\baseline.yml
```
'@ }
    )

    foreach ($file in $files) {
        if ((Test-Path -Path $file.Path) -and -not $Force) {
            Write-Warning "Skipping existing file: $($file.Path)"
            continue
        }

        if ($PSCmdlet.ShouldProcess($file.Path, 'Write Dewit starter file')) {
            Set-Content -Path $file.Path -Value $file.Content -Encoding utf8
        }
    }

    [pscustomobject]@{
        Path      = (Resolve-Path -Path $Path).Path
        Inventory = $inventoryPath
        Playbook  = $baselinePath
    }
}
