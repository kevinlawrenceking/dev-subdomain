<#
Purpose:
  Replace <cfinclude template="/include/qry/*.cfm"> with service calls per a CSV map.

CSV (UTF-8, header required):
  legacy_qry,service,method,returnVar,argsSnippet,action
  add_197_3,auditionSubmitSiteUserService,createAuditionSubmitSiteUser,id,"{submitsitename=new_submitsitename,catlist=sortedCatList,userid=userid}",replace
  fetchUsers,IGNORE,IGNORE,IGNORE,"{}",skip

Notes:
  - Supports /include/qry and /app/qry, '/' or '\' separators, self-closing includes.
  - Use -DryRun first. Creates a single .bak per file on first write.
#>

param(
  [string]$RepoRoot = "$PSScriptRoot\..\..",
  [string]$AppDirRel = "app",
  [string]$MapCsv = "$PSScriptRoot\qry_map.csv",
  [switch]$DryRun
)

function Load-Map {
  param($path)
  if (-not (Test-Path $path)) { throw "Missing map CSV: $path" }
  $rows = Import-Csv -Path $path
  $dict = @{}
  foreach ($r in $rows) {
    if (-not $r.legacy_qry) { continue }
    $key = ($r.legacy_qry.Trim()).ToLower()
    $dict[$key] = @{
      service = ($r.service   ? $r.service.Trim()   : "")
      method  = ($r.method    ? $r.method.Trim()    : "")
      ret     = ($r.returnVar ? $r.returnVar.Trim() : "")
      args    = ($r.argsSnippet ? $r.argsSnippet.Trim() : "")
      action  = ((($r.PSObject.Properties.Match('action')).Count -gt 0) -and $r.action) ? $r.action.Trim().ToLower() : 'replace'
    }
  }
  return $dict
}

$AppDir = Join-Path $RepoRoot $AppDirRel
$map = Load-Map $MapCsv

# Robust matcher: /include/qry or /app/qry, any slashes, self-closing optional, case-insensitive, dotall
$pattern = [regex]@'
(?is)<cfinclude\s+template\s*=\s*["'](?:\\|/)?(?:app|include)?(?:\\|/)?qry(?:\\|/)([^"']+?)\.cfm["']\s*/?>
'@

$files = Get-ChildItem $AppDir -Recurse -Include *.cfm,*.cfc | Select-Object -ExpandProperty FullName
$changed = 0

foreach ($f in $files) {
  $text = Get-Content -LiteralPath $f -Raw -ErrorAction SilentlyContinue
  if ([string]::IsNullOrEmpty($text)) { continue }
  if (-not $pattern.IsMatch($text)) { continue }

  $new = $pattern.Replace($text, {
    param($m)
    $legacyPath = $m.Groups[1].Value                      # e.g. add_197_3 or contact/add_197_3
    $key = ($legacyPath -replace '\\','/').Replace('/','.').ToLower()

    if (-not $map.ContainsKey($key)) {
      Write-Warning "No mapping for $legacyPath ($key) in $f"
      return $m.Value
    }

    $entry = $map[$key]
    if ($entry.action -eq 'skip') {
      Write-Host "Skipping by map: $legacyPath ($key) in $f"
      return $m.Value
    }

    $svc  = $entry.service
    $met  = $entry.method
    $ret  = $entry.ret
    $args = $entry.args

    if ([string]::IsNullOrWhiteSpace($svc) -or [string]::IsNullOrWhiteSpace($met)) {
      Write-Warning "Incomplete mapping for $legacyPath ($key) in $f"
      return $m.Value
    }

    if ([string]::IsNullOrWhiteSpace($ret)) {
      return "<cfset application.services.$svc.$met($args)>"
    } else {
      return "<cfset $ret = application.services.$svc.$met($args)>"
    }
  })

  if ($new -ne $text) {
    if ($DryRun) {
      Write-Host "[DRY] Would modify: $f"
    } else {
      if (-not (Test-Path "$f.bak")) { Copy-Item -LiteralPath $f -Destination "$f.bak" }
      Set-Content -LiteralPath $f -Value $new -Encoding UTF8
      Write-Host "Modified: $f"
      $changed++
    }
  }
}

Write-Host "Done. Files changed: $changed"
