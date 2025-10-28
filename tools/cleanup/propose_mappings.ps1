# Propose service.method mappings for qry files based on CRUD patterns

$inventory = Import-Csv -Path "tools/cleanup/qry_inventory.csv"
$uniqueQry = $inventory | Select-Object -Property legacy_qry -Unique

function Get-ProposedMapping {
    param([string]$legacyQry)

    # Strip numbered suffixes like _107_2, _318_1, etc.
    $cleanName = $legacyQry -replace '_\d+(_\d+)*$', ''
    $name = $cleanName.ToLower()

    # Determine operation type and resource
    $operation = ""
    $resource = ""
    $method = ""

    # CRUD Pattern matching
    if ($name -match '^get(.+)') {
        $operation = "get"
        $resource = $matches[1]
        $methodSuffix = (Get-Culture).TextInfo.ToTitleCase($matches[1])
        $method = "get" + $methodSuffix
    }
    elseif ($name -match '^fetch(.+)') {
        $operation = "get"
        $resource = $matches[1]
        $methodSuffix = (Get-Culture).TextInfo.ToTitleCase($matches[1])
        $method = "get" + $methodSuffix
    }
    elseif ($name -match '^list(.+)') {
        $operation = "list"
        $resource = $matches[1]
        $methodSuffix = (Get-Culture).TextInfo.ToTitleCase($matches[1])
        $method = "list" + $methodSuffix
    }
    elseif ($name -match '^(add|insert|ins)(.+)') {
        $operation = "create"
        $resource = $matches[2]
        $methodSuffix = (Get-Culture).TextInfo.ToTitleCase($matches[2])
        $method = "create" + $methodSuffix
    }
    elseif ($name -match '^(delete|del)(.+)') {
        $operation = "delete"
        $resource = $matches[2]
        $methodSuffix = (Get-Culture).TextInfo.ToTitleCase($matches[2])
        $method = "delete" + $methodSuffix
    }
    elseif ($name -match '^(update|upd)(.+)') {
        $operation = "update"
        $resource = $matches[2]
        $methodSuffix = (Get-Culture).TextInfo.ToTitleCase($matches[2])
        $method = "update" + $methodSuffix
    }
    elseif ($name -match '^(find|sel|select)(.+)') {
        $operation = "find"
        $resource = $matches[2]
        $methodSuffix = (Get-Culture).TextInfo.ToTitleCase($matches[2])
        $method = "find" + $methodSuffix
    }
    elseif ($name -match '^(.+?)_(user|byuser|details?|all|active|sel)$') {
        # Pattern like "eventtypes_user", "events_byuser"
        $resource = $matches[1]
        $suffix = $matches[2]
        $resourceTitle = (Get-Culture).TextInfo.ToTitleCase($resource)
        if ($suffix -eq "user" -or $suffix -eq "byuser") {
            $method = "listBy" + $resourceTitle
        } elseif ($suffix -match "detail") {
            $method = "get" + $resourceTitle + "Details"
        } elseif ($suffix -eq "all") {
            $method = "listAll" + $resourceTitle
        } else {
            $method = "list" + $resourceTitle
        }
    }
    else {
        # Default: assume it's a list operation
        $resource = $name
        $method = "list" + (Get-Culture).TextInfo.ToTitleCase($name)
    }

    # Clean up resource name for service
    $resource = $resource -replace '_.*$', ''  # Remove suffix after underscore
    $resource = $resource -replace '^\d+', ''  # Remove leading numbers
    $resource = $resource -replace '\d+$', ''  # Remove trailing numbers

    if ($resource.Length -eq 0 -or $resource.Length -lt 2) {
        $resource = $cleanName -replace '\d', '' -replace '_', ''
    }

    # Create service name
    $serviceName = (Get-Culture).TextInfo.ToTitleCase($resource) + "Service"

    # Create return var name (query result variable) - use clean name without numbers
    $returnVarBase = $cleanName -replace '_', ''
    $returnVar = "q" + (Get-Culture).TextInfo.ToTitleCase($returnVarBase)

    return [PSCustomObject]@{
        legacy_qry = $legacyQry
        service = $serviceName
        method = $method
        returnVar = $returnVar
        argsSnippet = "{}"
        notes = ""
    }
}

$mappings = @()
foreach ($item in $uniqueQry) {
    $mapping = Get-ProposedMapping -legacyQry $item.legacy_qry
    $mappings += $mapping
}

# Export to CSV
$mappings | Export-Csv -Path "tools/cleanup/qry_map_proposed.csv" -NoTypeInformation

Write-Host "Created proposed mappings for $($mappings.Count) qry files"
Write-Host "Review and edit: tools/cleanup/qry_map_proposed.csv"
