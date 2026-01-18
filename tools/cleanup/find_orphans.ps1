param(
  [string]$RepoRoot = "$PSScriptRoot\..\..",
  [string]$QryDirRel = "app\qry",
  [int]$MaxList = 2000
)

$QryDir = Join-Path $RepoRoot $QryDirRel
if (-not (Test-Path $QryDir)) { Write-Error "Not found: $QryDir"; exit 1 }

# All .cfm under /qry
$qryFiles = Get-ChildItem $QryDir -File -Recurse | Select-Object -ExpandProperty FullName

# All include usages pointing at /qry
$usage = rg -n --iglob '*.cfm' --iglob '*.cfc' 'include.*?/qry/([^\"]+)\.cfm' $RepoRoot
$usedRel = ($usage | ForEach-Object {
    if ($_ -match 'qry/([^\"]+)\.cfm') { $matches[1] + ".cfm" }
  }) | Sort-Object -Unique

$usedFull = $usedRel | ForEach-Object { Join-Path $QryDir $_ }
$orphans = Compare-Object $qryFiles $usedFull -PassThru | Where-Object { $_ -in $qryFiles } | Select-Object -First $MaxList

$outFile = Join-Path $PSScriptRoot "orphans.txt"
$orphans | Set-Content $outFile
Write-Host "Orphans listed: $outFile"
