# QRY Refactoring Inventory Summary

## Overview
Completed initial inventory of all `/include/qry` files in the codebase.

## Statistics
- **Total qry includes**: 1,286 references
- **Unique qry files**: 1,017 files
- **Status**: Inventory complete, mappings proposed

## Files Created
1. `qry_unique.txt` - List of all unique qry filenames
2. `qry_inventory.csv` - Detailed inventory with columns: legacy_qry, call_file, line
3. `qry_map_proposed.csv` - Proposed service.method mappings for all qry files

## Current Mapping File
- `qry_map.csv` - Contains 1 existing mapping:
  - `eventtypes_user` → `eventTypesUserService.listEventTypesUser`

## Key Findings

### Refactoring Progress
Some qry files have already been refactored:
- `getUserDetails.cfm` - Uses UserService.GetUserDetails()
- `addTeam.cfm` - Uses contactService.addMembers()
- `deleteTeam.cfm` - Uses contactItemService.deleteTeam()

### SQL Still Needing Migration
Many numbered qry files (e.g., `systems_452_1.cfm`) still contain:
- Old `<cfquery>` syntax without datasource
- No typed parameters
- Direct SQL in templates

### Pattern Analysis
Common qry file patterns found:
- `get*` - 52 files - Read operations
- `add*`, `insert*`, `ins*` - 289 files - Create operations
- `delete*`, `del*` - 68 files - Delete operations
- `update*`, `upd*` - 127 files - Update operations
- `find*`, `sel*`, `select*` - 234 files - Query operations
- Numbered files (e.g., `*_318_1`) - 445 files - Legacy SQL queries

## Proposed Mappings
The `qry_map_proposed.csv` contains automatically generated mappings based on:
- CRUD naming conventions
- Resource name extraction from filenames
- Standard service naming patterns

### Sample Proposed Mappings
| legacy_qry | service | method |
|-----------|---------|--------|
| getUserDetails | UserdetailsService | getUserdetails |
| addTeam | TeamService | createTeam |
| deleteTeam | TeamService | deleteTeam |
| fetchUsers | UsersService | getUsers |
| contacts | ContactsService | listContacts |

## Next Steps

### Option 1: Full Migration (Recommended)
1. Review and refine `qry_map_proposed.csv`
2. Prioritize high-traffic qry files
3. Create services and CRUD methods in batches
4. Update call sites using `replace_includes.ps1`
5. Delete orphaned qry files
6. Open PRs for each batch

### Option 2: Incremental Migration
1. Focus on specific domains (e.g., all "contact" related queries)
2. Create domain-specific services
3. Migrate and test one domain at a time
4. Repeat for next domain

### Option 3: Focus on Problem Areas
1. Identify qry files with:
   - Security issues (SQL injection risks)
   - Performance problems
   - High usage frequency
2. Prioritize those for immediate refactoring

## Warnings
Several qry includes have no current mappings:
- `core` in `app\admin-users\setup-verification.cfm`
- `fetchUsers` in `app\Application.cfc` (2 occurrences)

These need manual review to determine proper service mappings.

## Tools Available
1. `replace_includes.ps1` - Automates replacement of qry includes with service calls
2. `find_orphans.ps1` - Identifies qry files no longer referenced
3. `create_inventory.ps1` - Regenerate inventory
4. `propose_mappings.ps1` - Regenerate proposed mappings

## Recommendations
1. Review `qry_map_proposed.csv` and correct service/method names
2. Merge corrections into `qry_map.csv`
3. Start with high-priority files (determined by frequency or risk)
4. Follow atomic commit strategy - one qry file migration per PR
5. Include tests for each new service method
