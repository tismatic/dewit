# Dewit

Dewit is a PowerShell-native desired-state automation framework for Windows admins.

It gives you an Ansible-like workflow without requiring WSL, Linux, Python, or a Linux control node.

## Quick Start

Import the local module during development:

```powershell
Import-Module .\Dewit.psd1 -Force
```

Create a starter project:

```powershell
dewit init
```

List built-in resources:

```powershell
dewit resources
```

Preview changes:

```powershell
dewit plan .\baseline.yml
```

Apply changes:

```powershell
dewit run .\baseline.yml
```

Check compliance only:

```powershell
dewit test .\baseline.yml
```

Use detailed exit codes for CI-style checks:

```powershell
dewit run .\baseline.yml -DetailedExitCode
```

Exit code behavior:

- `0`: success
- `2`: changes were made, only with `-DetailedExitCode`
- `3`: noncompliant in `test` mode
- `5`: one or more hosts unreachable
- `6`: one or more tasks failed

## Current Scope

This repository currently implements the localhost milestone:

- PowerShell module scaffold
- `Invoke-Dewit`, `Test-Dewit`, `New-DewitProject`, `Test-DewitInventory`, `New-DewitReport`, `Get-DewitResource`
- Friendly `dewit` wrapper
- YAML parsing through `powershell-yaml`
- Built-in `file` and `service` resources
- Built-in `file`, `service`, and `registry` resources
- `run`, `plan`, and `test` modes
- JSON result export

Install the YAML parser dependency:

```powershell
Install-Module powershell-yaml -Scope CurrentUser
```
