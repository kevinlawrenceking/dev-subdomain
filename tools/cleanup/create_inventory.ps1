# Create detailed inventory of all qry includes
$results = rg -n --iglob '*.cfm' --iglob '*.cfc' '/qry/[a-zA-Z0-9_-]+\.cfm'

$inventory = @()

foreach ($line in $results) {
    # Parse: filepath:linenum:content
    if ($line -match '^([^:]+):(\d+):.*\/qry\/([^/]+)\.cfm') {
        $inventory += [PSCustomObject]@{
            legacy_qry = $matches[3]
            call_file = $matches[1]
            line = $matches[2]
        }
    }
}

# Export to CSV
$inventory | Export-Csv -Path "tools/cleanup/qry_inventory.csv" -NoTypeInformation

Write-Host "Inventory created with $($inventory.Count) entries"
Write-Host "Unique qry files: $(($inventory | Select-Object -Unique legacy_qry).Count)"
