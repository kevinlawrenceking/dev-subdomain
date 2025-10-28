# Verify qry_map.csv contents
$csv = Import-Csv -Path "tools/cleanup/qry_map.csv"

Write-Host "=== QRY_MAP.CSV SUMMARY ===" -ForegroundColor Green
Write-Host ""
Write-Host "Total mappings: $($csv.Count)" -ForegroundColor Cyan
Write-Host ""

# Group by service
$grouped = $csv | Group-Object -Property service
Write-Host "Mappings by service:" -ForegroundColor Yellow
foreach ($group in $grouped) {
    Write-Host "  $($group.Name): $($group.Count) entries" -ForegroundColor White
}

Write-Host ""
Write-Host "=== CONTACTSSERVICE MAPPINGS ===" -ForegroundColor Green
$contacts = $csv | Where-Object { $_.service -eq 'ContactsService' }
$contacts | Format-Table legacy_qry, method, returnVar -AutoSize
