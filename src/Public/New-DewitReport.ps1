function New-DewitReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$InputPath,

        [Parameter(Mandatory)]
        [string]$OutFile
    )

    $resolvedInput = Resolve-DewitPath -Path $InputPath
    $results = Get-Content -Path $resolvedInput -Raw | ConvertFrom-Json
    $rows = foreach ($result in $results) {
        '<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td></tr>' -f $result.HostName, $result.TaskName, $result.Resource, $result.Status, [System.Web.HttpUtility]::HtmlEncode($result.Message)
    }

    $html = @"
<!doctype html>
<html>
<head><meta charset="utf-8"><title>Dewit Report</title><style>body{font-family:Segoe UI,Arial,sans-serif;margin:2rem}table{border-collapse:collapse;width:100%}td,th{border:1px solid #ddd;padding:.5rem}th{background:#f3f4f6;text-align:left}</style></head>
<body><h1>Dewit Report</h1><table><thead><tr><th>Host</th><th>Task</th><th>Resource</th><th>Status</th><th>Message</th></tr></thead><tbody>$($rows -join "`n")</tbody></table></body>
</html>
"@

    Set-Content -Path $OutFile -Value $html -Encoding utf8
    Get-Item -Path $OutFile
}
