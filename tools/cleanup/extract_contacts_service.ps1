# Extract all ContactsService mappings from proposed map
$proposed = Import-Csv -Path "tools/cleanup/qry_map_proposed.csv"
$contactsEntries = $proposed | Where-Object { $_.service -eq 'ContactsService' }

Write-Host "Found $($contactsEntries.Count) ContactsService entries:" -ForegroundColor Green
Write-Host ""

$contactsEntries | Format-Table -AutoSize

# Export to a separate file for review
$contactsEntries | Export-Csv -Path "tools/cleanup/contacts_service_mappings.csv" -NoTypeInformation

Write-Host ""
Write-Host "Exported to: tools/cleanup/contacts_service_mappings.csv" -ForegroundColor Cyan
