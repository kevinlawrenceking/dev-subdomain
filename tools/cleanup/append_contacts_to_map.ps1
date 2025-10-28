# Append ContactsService mappings to qry_map.csv

# Read the existing map
$existingMap = Import-Csv -Path "tools/cleanup/qry_map.csv"

# Read the contacts mappings
$contactsMappings = Import-Csv -Path "tools/cleanup/contacts_service_mappings.csv"

# Combine them
$combinedMap = $existingMap + $contactsMappings

# Export back to qry_map.csv
$combinedMap | Export-Csv -Path "tools/cleanup/qry_map.csv" -NoTypeInformation

Write-Host "Successfully appended $($contactsMappings.Count) ContactsService entries to qry_map.csv" -ForegroundColor Green
Write-Host ""
Write-Host "Total entries in qry_map.csv: $($combinedMap.Count)" -ForegroundColor Cyan
Write-Host ""
Write-Host "ContactsService entries added:" -ForegroundColor Yellow
$contactsMappings | Format-Table -Property legacy_qry, method -AutoSize
