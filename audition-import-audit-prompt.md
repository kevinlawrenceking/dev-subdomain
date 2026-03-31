# TAO Audition Import - Full Audit Request

You have been given a zip file (`audition-import-bundle.zip`) containing all ColdFusion and SQL files for the audition import module of TAO (The Actors Office). Perform a complete, expert-level audit of this code.

---

## What TAO Is

TAO is a ColdFusion (CFML) + MySQL web application that helps actors manage the business side of their careers: contacts, auditions, reminders, relationship workflows, scheduling, and project tracking. The audition import module lets users upload CSV/XLS/XLSX files of audition data and import them into the system.

## Tech Stack

- **Backend:** ColdFusion (CFML) on Lucee/Adobe CF
- **Database:** MySQL (InnoDB). NOT SQL Server.
- **Datasource:** `abo` (production), `abod` (development) -- determined at runtime by hostname
- **Frontend:** HTML, jQuery, Bootstrap 5, heavy AJAX patterns
- **AJAX endpoints:** Under `/ajax/import-auditions/`

---

## Architecture Overview

### The Real Audition Data Model (what the app reads)

The app's audition screens read from a **three-table hierarchy**:

```
audprojects (project-level: name, category, casting contact, date)
  --> audroles (role-level: role name, type, booked/callback flags)
       --> events_tbl (event-level: date, time, location, step)
```

Key relationships:
- `audprojects.audprojectID` (PK) --> `audroles.audprojectID` (FK)
- `audroles.audRoleID` (PK) --> `events_tbl.audRoleID` (FK)
- `audprojects.audSubCatID` --> `audsubcategories.audsubcatid` --> `audcategories.audcatid`
- `audprojects.contactid` --> `contactdetails.contactid` (casting director)

Supporting lookup tables: `audcategories`, `audsubcategories`, `audsteps`, `audroletypes`

### The Flat `auditions` Table (legacy/import-only)

There is also a flat `auditions` table that was the original import target. The app's main audition list page (`include/auditions_new.cfm`) does NOT read from this table. It reads from `audprojects`/`audroles`/`events_tbl`. The flat table is now only used for duplicate detection during import.

### Import Two-Phase Architecture

The import follows a staging-then-finalize pattern:

**Phase 1 - Stage (upload -> parse -> map -> review):**
1. `upload.cfm` - Accept file, compute SHA-256 hash, create job record
2. `parse.cfm` - Parse file, auto-map columns to audition fields, populate staging tables
3. `columns.cfm` - User reviews/adjusts column mappings
4. `recompute.cfm` - Revalidate all rows, run duplicate detection
5. `rows.cfm` / `row.cfm` / `fact_update.cfm` - Review grid with inline editing
6. `row_action.cfm` - User marks rows as import/skip

**Phase 2 - Finalize:**
7. `finalize.cfm` - Triggers `AuditionImportService.finalizeJob()` which calls `processRowForImport()` per row

### Staging Tables (6 tables)

```
import_auditions_jobs        -- Master job tracker (one per upload)
import_auditions_columns     -- Column mapping metadata (source header -> target field)
import_auditions_rows        -- One row per data row from source file
import_auditions_facts       -- EAV: one record per cell (row_id + field_name), UNIQUE(row_id, field_name)
import_auditions_row_results -- Finalization audit trail (one per row, UNIQUE(row_id))
import_auditions_events      -- Event/audit log for all state changes
```

### What processRowForImport() Does (the critical method)

Inside a single MySQL transaction, it:
1. **E1:** INSERT into `audprojects` (with optional `audSubCatID` from category resolution)
2. **E2:** INSERT into `audroles` (linked to project via `audprojectID`)
3. **E3:** INSERT into `events_tbl` (linked to role via `audRoleID`)
4. **E4:** INSERT into flat `auditions` table (backward-compat for dupe detection)
5. **E5:** UPDATE `import_auditions_rows` with `created_audition_id` and status='imported'
6. **E6:** INSERT into `import_auditions_row_results` (idempotency record)

### Category Resolution

`resolveCategoryToSubCatId()` does 5-tier fuzzy matching:
1. Exact "Category - SubCategory" match (e.g., "Film - Feature")
2. Dash separator without spaces (e.g., "Film-Feature")
3. Category name only (picks first subcategory)
4. Subcategory name only
5. LIKE fuzzy match
6. Returns 0 if no match (audition imports with NULL category -- still works)

---

## File Map

### AJAX Endpoints (`ajax/import-auditions/`)
| File | Purpose |
|------|---------|
| `upload.cfm` | File upload, hash dedup, create job |
| `parse.cfm` | Parse file, auto-map columns, populate staging |
| `columns.cfm` | GET/POST column mapping review |
| `recompute.cfm` | Revalidate rows + run dupe detection |
| `rows.cfm` | Paginated row list with stats |
| `row.cfm` | Single row detail with all facts |
| `row_action.cfm` | Set row action (import/skip), single or bulk |
| `fact_update.cfm` | Edit individual field values on a row |
| `finalize.cfm` | Trigger finalization (create real audition records) |
| `status.cfm` | Manual job status transitions (recovery) |
| `history.cfm` | Past import jobs list |

### Services (`services/`)
| File | Purpose |
|------|---------|
| `AuditionImportService.cfc` | **Core service** - job management, locking, status transitions, validation, finalization, processRowForImport, resolveCategoryToSubCatId |
| `AuditionDuplicateMatcherService.cfc` | Dupe detection - builds in-memory index from flat `auditions` table, scores candidates |
| `AuditionImportErrorService.cfc` | Error logging for import |
| `ImportAuditionsLogger.cfc` | Structured event logging |
| `AuditionCategoryService.cfc` | Category/subcategory lookups (reference for how the app does it) |
| `AuditionProjectService.cfc` | Project CRUD (reference for existing INSERT patterns into `audprojects`) |
| `AuditionRoleService.cfc` | Role CRUD (reference for existing INSERT patterns into `audroles`) |
| `EventService.cfc` | Event CRUD (reference for existing INSERT patterns into `events_tbl`) |

### UI Pages (`include/`)
| File | Purpose |
|------|---------|
| `import-auditions.cfm` | Main import UI page (step wizard) |
| `transfer_audition.cfm` | Manual audition creation (reference for column lists) |
| `audition-add.cfm` / `audition-add2.cfm` | Manual add flow (reference) |
| `reset_audition_imports.cfm` | Dev utility to truncate staging tables |
| `fetch_updated_row.cfm` | AJAX helper for row refresh |

### Query Includes (`include/qry/`)
| File | Purpose |
|------|---------|
| `audprojects_ins_399_1.cfm` | Legacy project INSERT (reference for column list) |
| `auditions_ins_373_1.cfm` | Legacy event INSERT (reference for column list) |
| `auditions_import.cfm` | Old import logic (reference) |
| `getAuditionImportResults.cfm` | Query for import results |
| `getAuditionImportErrors.cfm` | Query for import errors |
| `getAuditionUploadDetails.cfm` | Query for upload details |
| `imports_372_1.cfm` / `imports_140_4.cfm` | Legacy import queries |

### Database Migrations (`database/migrations/`)
| File | Purpose |
|------|---------|
| `A1_0__import_auditions_tables.sql` | Core staging table CREATE statements |
| `A1_1__import_auditions_indexes.sql` | Indexes on production `auditions` table for dupe detection |
| `A1_1__audition_facts_unique_key_fix.sql` | Fix: changed UNIQUE(row_id, column_id) to UNIQUE(row_id, field_name) |
| `A1_3__import_auditions_columns_add_timestamps.sql` | Added created_at/updated_at to columns table |
| `*_ROLLBACK.sql` | Rollback scripts for each migration |

---

## Known Issues (Identified But Not Yet Fixed)

These are issues we've already identified. Verify them, assess severity, and find any we missed.

### 1. Retry Idempotency Gap (HIGH)
**File:** `AuditionImportService.cfc`, `processRowForImport()` ~line 1369

The idempotency check only fires when `existing_audition_id > 0`:
```cfml
if (isNumeric(arguments.existing_audition_id) && arguments.existing_audition_id gt 0) {
    // check row_results...
}
```
If a transaction rolls back (E1-E6 all undo), `created_audition_id` stays NULL on the row. On retry, the idempotency check is skipped and duplicate `audprojects`/`audroles`/`events_tbl` records are created.

**Question:** Is the fix as simple as always checking `import_auditions_row_results` regardless of `existing_audition_id`? Or is there a deeper issue?

### 2. Dupe Detection Only Reads Flat Table (HIGH)
**File:** `AuditionDuplicateMatcherService.cfc`, `buildUserDupeIndex()`

Only queries the `auditions` flat table. Auditions created through the normal UI (which writes to `audprojects`/`audroles`/`events_tbl` but NOT the flat table) are invisible to dupe detection. This means the import can create duplicates of manually-entered auditions.

**Question:** Should `buildUserDupeIndex()` be rewritten to join `audprojects` + `audroles` + `events_tbl`? What's the best approach?

### 3. Event Status Not Set (MEDIUM)
**File:** `AuditionImportService.cfc`, E3 INSERT into `events_tbl` ~line 1511

The import captures a `status` field (scheduled/completed/callback/booked/pass) but only writes it to the flat `auditions` table (E4). The `events_tbl` INSERT in E3 does not include `eventstatus`. If `events_tbl` has an `eventstatus` column (it appears to, based on performance index migrations), imported events will have NULL status.

### 4. Casting Director Text Lost from Real Tables (MEDIUM)
The import captures `casting_director` as free text but only writes it to the flat `auditions` table. The real `audprojects` table links casting directors via `contactid` (FK to `contactdetails`). If the CD isn't found in the user's contacts, the text is silently lost from the real tables.

### 5. Hardcoded `audRoleTypeID = 1` and `audStepID = 1` (MEDIUM)
All imported roles get type 1 and all events get step 1 regardless of actual audition type/status. The manual flow also defaults to these, so this may be acceptable.

### 6. `getRows()` Has No Ownership Check in SQL (LOW)
The service method itself doesn't filter by `userid`. All AJAX callers validate ownership before calling it, so it's not exploitable from the UI, but the method is unsafe if called from other code.

### 7. `getJob()` is Public with No Ownership (LOW)
Never called from AJAX endpoints (they all use `getJobForUser()`), but accessible to any internal caller.

---

## What I Need From You

### A. Verify Known Issues
For each issue above, confirm or dispute it. If you dispute it, explain why with code references.

### B. Find New Issues
Audit every file for:

1. **SQL correctness**
   - Do all INSERT column lists match real table schemas? Cross-reference the import's INSERTs against the reference files (`transfer_audition.cfm`, `AuditionProjectService.cfc`, `AuditionRoleService.cfc`, `EventService.cfc`, `audprojects_ins_399_1.cfm`, `auditions_ins_373_1.cfm`).
   - Are there NOT NULL columns without defaults that the import doesn't set?
   - Any MySQL syntax issues?

2. **Security**
   - SQL injection (any string concatenation of user input)?
   - CSRF protection on all POST endpoints?
   - Session/auth validation on all endpoints?
   - File upload validation (type, size, path traversal)?

3. **Data integrity**
   - Transaction boundaries correct? What happens on partial failure?
   - Idempotency guarantees hold under retry?
   - Can finalize create orphaned records?
   - Are foreign keys valid (e.g., does `audRoleTypeID = 1` always exist)?

4. **Race conditions**
   - Lock acquisition safety?
   - Double-finalize prevention?
   - Concurrent user access to same job?

5. **Validation gaps**
   - Missing required field checks?
   - Field validation rules complete (dates, enums, emails)?
   - What happens with empty/null values in required positions?

6. **Dead code and inconsistencies**
   - `mapped_field` column vs `target_key` -- is `mapped_field` truly dead?
   - Any endpoints that reference methods that don't exist?
   - Any status transitions that are impossible?

7. **Performance concerns**
   - Missing indexes for common query patterns?
   - N+1 query patterns in finalization loop?
   - Memory concerns with large imports (10K+ rows)?

### C. Provide Fixes

For each issue found (both known and new), provide:
1. **Severity:** CRITICAL / HIGH / MEDIUM / LOW
2. **Impact:** What breaks or could break
3. **Root cause:** Why it happens
4. **Fix:** Exact code change with file path and line reference
5. **Verification:** How to confirm the fix works

### D. Architecture Assessment

Answer these questions:
1. Is the two-phase staging pattern implemented correctly?
2. Is the `audprojects` -> `audroles` -> `events_tbl` creation order correct and complete?
3. Should the flat `auditions` table write (E4) be kept, removed, or replaced?
4. Is the category resolution approach (5-tier fuzzy match) sound?
5. What's missing to make this production-ready?

---

## Important ColdFusion/MySQL Notes

- All SQL must use `cfqueryparam` (or `queryExecute` with param structs). No string concatenation.
- MySQL functions: `NOW()`, `LIMIT`, `AUTO_INCREMENT`, `INSERT IGNORE`, `ON DUPLICATE KEY UPDATE`
- NOT SQL Server: no `GETDATE()`, `SELECT TOP`, `IDENTITY`, `MERGE`, `GO`
- Use `application.datasource` for datasource name
- ColdFusion scopes: `session.userid` for auth, `application.*` for app-wide config
- `queryExecute()` is the modern pattern; `<cfquery>` is the legacy pattern. Both are used.
