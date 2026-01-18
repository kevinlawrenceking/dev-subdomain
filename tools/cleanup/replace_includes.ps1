<#
Purpose:
  Replace cfinclude calls to /qry/*.cfm with service method calls using a mapping file.

Input mapping CSV (UTF-8, header required):
  legacy_qry,service,method,returnVar,argsSnippet
  contact.create,contactService,createContact,contactID,"formData"
  contact.get,contactService,getContact,contact,"id"

Behavior:
  - Scans *.cfm and *.cfc under /app for include lines that target /qry/{legacy_qry}.cfm
  - Replaces the include with:
      <cfset {returnVar} = application.services.{service}.{method}({argsSnippet})>
  - Writes changes in-place and creates a .bak backup once per file
Notes:
  - Use dry-run first.
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
    $key = ($r.legacy_qry.Trim()).ToLower()  # e.g., contact.create
    $dict[$key] = @{
      service = $r.service.Trim()
      method  = $r.method.Trim()
      ret     = $r.returnVar.Trim()
      args    = $r.argsSnippet.Trim()
    }
  }
  return $dict
}

$AppDir = Join-Path $RepoRoot $AppDirRel
$map = Load-Map $MapCsv

$files = Get-ChildItem $AppDir -Recurse -Include *.cfm,*.cfc | Select-Object -ExpandProperty FullName

$pattern = [regex]'(?i)<cfinclude\s+template\s*=\s*["'']\/?app?\/?qry\/([^"']+)\.cfm["'']\s*\/?>'

$changed = 0
foreach ($f in $files) {
  $text = Get-Content $f -Raw
  if (-not $pattern.IsMatch($text)) { continue }

  $new = $pattern.Replace($text, {
    param($m)
    $legacyPath = $m.Groups[1].Value  # e.g. contact/create or contact.create
    $key = ($legacyPath -replace '\\','/').Replace('/','.').ToLower()
    if (-not $map.ContainsKey($key)) {
      Write-Warning "No mapping for $legacyPath ($key) in $f"
      return $m.Value
    }
    $entry = $map[$key]
    $ret = $entry.ret
    $svc = $entry.service
    $met = $entry.method
    $args = $entry.args
    $snippet = "<cfset #$ret# = application.services.#$svc#.#$met#(#$args#)>"
    return $snippet
  })

  if ($new -ne $text) {
    if ($DryRun) {
      Write-Host "[DRY] Would modify: $f"
    } else {
      if (-not (Test-Path "$f.bak")) { Copy-Item $f "$f.bak" }
      Set-Content $f $new -NoNewline
      Write-Host "Modified: $f"
      $changed++
    }
  }
}

Write-Host "Done. Files changed: $changed"
