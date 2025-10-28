# Extract unique qry filenames from codebase
$matches = rg -N -o --iglob '*.cfm' --iglob '*.cfc' '/qry/[a-zA-Z0-9_-]+\.cfm'

$uniqueQry = $matches | ForEach-Object {
    if ($_ -match '/qry/(.+)\.cfm') {
        $matches[1]
    }
} | Sort-Object -Unique

$uniqueQry | Out-File -FilePath "tools/cleanup/qry_unique.txt"
$uniqueQry
