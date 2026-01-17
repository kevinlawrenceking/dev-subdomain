# Contact Import V2 - Complete Process Map

**Generated:** 2026-01-17
**Repository:** C:/Users/kevin/TAO/dev-subdomain
**Branch:** dev

---

## 1. Overview

### What Contact Import V2 Does

Contact Import V2 is a two-phase, staged import system for importing contacts from CSV, XLS, XLSX, and VCF files into TAO's contact management system. The system provides:

1. **File upload and parsing** - Accept files, detect format, extract rows
2. **Column mapping** - Auto-detect field mappings using alias patterns, allow user override
3. **Validation** - Per-field and per-row validation with error/warning capture
4. **Duplicate detection** - Score-based matching against existing contacts
5. **Review UI** - Tabbed interface for problems, duplicates, and ready rows
6. **Finalize** - Atomic import with transaction support, creating contacts and related items

### Guarantees It SHOULD Provide

| Guarantee | Current Status |
|-----------|----------------|
| **Idempotency** - Same file re-import prevented | PARTIAL - file_hash check exists but can be bypassed by nulling hash |
| **Retry safety** - Failed import can resume | NO - failed imports set to "failed" status with no recovery path |
| **Auditability** - All actions logged | PARTIAL - import_job_events captures major milestones but not all row-level decisions |
| **Partial failure handling** - Row failures don't block others | YES - per-row try/catch with individual row status updates |
| **Atomic finalize** - All-or-nothing import | NO - uses transaction but row failures are caught and marked individually |
| **Double-finalize prevention** - Concurrent import blocked | YES - `tryAcquireImportLock()` with atomic UPDATE |

---

## 2. Components and File Inventory

### Core Service

| Path | Purpose | Public Entry Points | Dependencies | Tables Touched |
|------|---------|---------------------|--------------|----------------|
| `/services/ContactImportV2Service.cfc` | Main orchestration | `createJob()`, `parseFile()`, `processRows()`, `getRows()`, `updateRow()`, `setRowAction()`, `bulkSetAction()`, `validateForImport()`, `executeImport()`, `tryAcquireImportLock()` | FileParserService, ValidationService, DuplicateMatcherService, ContactService, ContactItemService | `import_jobs`, `import_job_rows`, `import_job_columns`, `import_job_events`, `import_field_aliases`, `import_field_mappings`, `contactdetails`, `contactitems`, `noteslog`, `fusystems`, `fusystemusers`, `funotifications`, `fuactions` |

### Supporting Services

| Path | Purpose | Key Functions | Tables Touched |
|------|---------|---------------|----------------|
| `/services/FileParserService.cfc` | CSV/XLS/XLSX/VCF parsing | `parseFile()`, `parseCSV()`, `parseVCF()`, `detectFileType()`, `detectEncoding()`, `detectDelimiter()` | None (file system only) |
| `/services/ValidationService.cfc` | Field-level validation | `validateRow()`, `validateEmail()`, `validatePhone()`, `validateDate()` | None |
| `/services/DuplicateMatcherService.cfc` | Duplicate detection | `findDuplicates()`, `findByEmail()`, `findByPhone()`, `findByName()` | `contactdetails`, `contactitems` |
| `/services/ContactService.cfc` | Contact CRUD | `create()`, `read()`, `update()` | `contactdetails` |
| `/services/ContactItemService.cfc` | Contact item CRUD | (referenced but not directly used) | `contactitems` |

### AJAX Endpoints

| Path | HTTP Method | Purpose | Tables Touched |
|------|-------------|---------|----------------|
| `/ajax/import/upload.cfm` | POST | Accept file upload, create job | `import_jobs` |
| `/ajax/import/parse.cfm` | POST | Trigger file parsing | `import_jobs`, `import_job_rows`, `import_job_columns`, `import_job_events` |
| `/ajax/import/columns.cfm` | GET/POST | Get/update column mappings | `import_job_columns` |
| `/ajax/import/rows.cfm` | GET | Fetch rows with pagination/filtering | `import_job_rows` |
| `/ajax/import/update-row.cfm` | POST | Update single row data | `import_job_rows` |
| `/ajax/import/row-action.cfm` | POST | Set user action on row | `import_job_rows` |
| `/ajax/import/bulk-action.cfm` | POST | Set action on multiple rows | `import_job_rows` |
| `/ajax/import/status.cfm` | GET | Get job status and counts | `import_jobs` |
| `/ajax/import/dry-run.cfm` | GET | Preview import without committing | `import_job_rows` |
| `/ajax/import/finalize.cfm` | POST | Execute final import | All contact tables |

### UI Files

| Path | Purpose |
|------|---------|
| `/include/import-contacts.cfm` | Main import page (PHP server-rendered) |
| `/app/assets/js/contact-import-v2.js` | JavaScript controller (frontend orchestration) |

### Database Migrations

| Path | Purpose |
|------|---------|
| `/database/migrations/V2_0__contact_import_staging_tables.sql` | Core tables, stored procedure, view |
| `/database/migrations/V2_1__import_v2_enhancements.sql` | file_hash column, relationship_system field, Google/Apple aliases |
| `/database/run-migration.cfm` | Migration runner |
| `/database/run-import-v2-migrations.cfm` | Combined migration runner |

---

## 3. Pipeline Stages (Current Behavior)

### Stage A: Job Creation

| Attribute | Value |
|-----------|-------|
| **Triggering file** | `/ajax/import/upload.cfm` |
| **Function called** | `ContactImportV2Service.createJob()` |
| **Inputs** | userid, filename, filetype, filesize, storedFilePath, fileHash, options |
| **Outputs** | `{success, job_id, isDuplicateFile, existingJob, message}` |
| **DB reads** | `import_jobs` (duplicate check by file_hash) |
| **DB writes** | INSERT `import_jobs` |
| **Status transitions** | None -> `pending` |
| **Failure modes** | - DB connection failure<br>- Duplicate unique constraint on (userid, file_hash)<br>- Missing userid in session |

**Critical observation:** If `isDuplicateFile` is true, the job is still created but with `file_hash = NULL`, bypassing the unique index. This allows re-importing the same file by design, but the warning message may not be clear to users.

### Stage B: Upload + File Storage

| Attribute | Value |
|-----------|-------|
| **Triggering file** | `/ajax/import/upload.cfm` |
| **Function called** | ColdFusion `<cffile action="upload">` |
| **Inputs** | form.file (multipart) |
| **Outputs** | stored file path, file info |
| **DB reads** | None |
| **DB writes** | None (file system write) |
| **Status transitions** | None |
| **Failure modes** | - No file uploaded<br>- Invalid file type<br>- File too large (>50MB)<br>- Directory creation failure<br>- Disk write failure |

**File storage path:** `{session.userImportsPath}` or `{application.baseMediaPath}\users\{userid}\imports\{filename}`

### Stage C: Parse into Staging Rows

| Attribute | Value |
|-----------|-------|
| **Triggering file** | `/ajax/import/parse.cfm` |
| **Function called** | `ContactImportV2Service.parseFile()` -> `FileParserService.parseFile()` |
| **Inputs** | job_id |
| **Outputs** | `{success, totalRows, parsedRows, message}` |
| **DB reads** | `import_jobs` (get stored file path) |
| **DB writes** | INSERT `import_job_rows`, INSERT `import_job_columns`, UPDATE `import_jobs` (counts, status), INSERT `import_job_events` |
| **Status transitions** | `pending` -> `parsing` -> `parsed` (or `failed`) |
| **Failure modes** | - File not found<br>- Unsupported encoding<br>- Malformed CSV/Excel<br>- Memory exhaustion on large files |

**Row insertion:** Each row is inserted individually in a loop. No batch INSERT. For files with 10,000+ rows, this creates significant DB round-trips.

### Stage D: Column Mapping (Auto-map + User Confirm)

| Attribute | Value |
|-----------|-------|
| **Triggering file** | `/ajax/import/columns.cfm` |
| **Functions called** | `ContactImportV2Service.storeColumnMappings()`, `autoMapColumn()`, `updateColumnMapping()`, `confirmColumnMappings()` |
| **Inputs** | job_id, column_id, normalized_field (for updates) |
| **Outputs** | Query of column mappings |
| **DB reads** | `import_job_columns`, `import_field_aliases` |
| **DB writes** | UPDATE `import_job_columns`, UPDATE `import_jobs` (status) |
| **Status transitions** | `parsed` -> `mapping` (on confirm) |
| **Failure modes** | - Invalid column_id<br>- Invalid normalized_field |

**Auto-mapping algorithm:** Case-insensitive exact match against `import_field_aliases.alias_pattern`. Confidence score from alias table. No fuzzy matching.

### Stage E: Row Processing (Normalize, Validate, Duplicate Detection)

| Attribute | Value |
|-----------|-------|
| **Triggering file** | `/ajax/import/parse.cfm` (after columns confirmed) |
| **Function called** | `ContactImportV2Service.processRows()` |
| **Inputs** | job_id, userid |
| **Outputs** | `{success, processed, valid, problem, dupe}` |
| **DB reads** | `import_job_columns`, `import_job_rows`, `contactdetails`, `contactitems` (for dupe detection) |
| **DB writes** | UPDATE `import_job_rows` (normalized_json, validation_json, dupe_json, status), CALL `sp_update_import_job_counts()`, UPDATE `import_jobs` (status) |
| **Status transitions** | `mapping` -> `reviewing` |
| **Failure modes** | - JSON serialization errors<br>- DB timeout on large datasets |

**Row status values set here:**
- `ready` - Valid, no duplicates
- `problem` - Validation errors
- `dupe` - Duplicate candidates found

### Stage F: Review UI Interactions

| Attribute | Value |
|-----------|-------|
| **Triggering files** | `/ajax/import/rows.cfm`, `/ajax/import/update-row.cfm`, `/ajax/import/row-action.cfm`, `/ajax/import/bulk-action.cfm` |
| **Functions called** | `getRows()`, `updateRow()`, `setRowAction()`, `bulkSetAction()` |
| **Inputs** | job_id, row_id, status filter, page, data, action |
| **Outputs** | Paginated row data, updated row status |
| **DB reads** | `import_job_rows` |
| **DB writes** | UPDATE `import_job_rows`, CALL `sp_update_import_job_counts()` |
| **Status transitions** | Row: `dupe`/`problem` -> `ready` (on fix), `dupe` -> `ignored` (on skip) |
| **Failure modes** | - Invalid row_id<br>- Job ownership mismatch (not checked!) |

**SECURITY ISSUE:** Row-action endpoints do not verify that the row belongs to the current user. A user could potentially modify another user's import rows if they guess the row_id.

### Stage G: Finalize Execution

| Attribute | Value |
|-----------|-------|
| **Triggering file** | `/ajax/import/finalize.cfm` |
| **Functions called** | `tryAcquireImportLock()`, `executeImport()` |
| **Inputs** | job_id |
| **Outputs** | `{success, imported, skipped, failed, contacts[], errors[]}` |
| **DB reads** | `import_jobs`, `import_job_rows` |
| **DB writes** | (see below) |
| **Status transitions** | Job: `reviewing` -> `importing` -> `completed` (or `failed`) |
| **Failure modes** | - Lock not acquired (already importing/completed)<br>- Per-row import failures<br>- Transaction rollback |

**Tables written during finalize:**

| Table | Operation | Condition |
|-------|-----------|-----------|
| `import_jobs` | UPDATE status | Always |
| `import_job_rows` | UPDATE status, created_contactid | Per row |
| `contactdetails` | INSERT or UPDATE | New or update existing |
| `contactitems` | INSERT | Email, phone, company, address, tags, URL |
| `noteslog` | INSERT | If notes field present |
| `fusystemusers` | INSERT | If relationship_system specified |
| `funotifications` | INSERT | If relationship_system enrolls contact |

**Transaction scope:** The entire `executeImport()` runs inside `<cftransaction>`. However, individual row failures are caught and marked, allowing partial success. The transaction only rolls back on catastrophic failures.

### Stage H: Post-Import Side Effects

After each contact is created or updated:

1. **Contact Items Created:**
   - `addContactItem()` - Email (Business, Personal)
   - `addContactItem()` - Phone (Work, Mobile, Home)
   - `addCompanyItem()` - Company with department, title
   - `addAddressItem()` - Address fields
   - `addContactItem()` - Tags (tag1, tag2, tag3)
   - `addContactItem()` - URL (website)
   - `addNote()` - Notes to noteslog

2. **Folder Creation:**
   - `createContactFolders()` - Creates `\users\{userid}\contacts\{contactid}\` and `\attachments\` subdirectory
   - Copies default avatar if available

3. **Relationship System Enrollment:**
   - If `relationship_system` field is "Target" or "Maintenance":
   - `enrollInRelationshipSystem()` determines scope (Casting Director vs Industry based on tags)
   - Creates `fusystemusers` record
   - `createSystemNotifications()` creates `funotifications` for all actions in the system

### Stage I: Logging and Job Status Updates

| Event Type | When Logged | Details Captured |
|------------|-------------|------------------|
| `created` | Job creation | filename, filetype |
| `parsing_started` | Parse begins | {} |
| `parsing_completed` | Parse succeeds | totalRows, parsedRows, parseErrors |
| `parsing_failed` | Parse fails | errors array |
| `columns_mapped` | User confirms mappings | {} |
| `row_updated` | User edits row | row_id |
| `row_action_set` | User sets action | row_id, action |
| `bulk_action_set` | Bulk action | count, action |
| `import_started` | Finalize begins | {} |
| `import_completed` | Finalize succeeds | imported, failed counts |
| `row_imported` | Single row success | row_id, contactid, action |
| `row_failed` | Single row failure | row_id, error |
| `import_failed` | Finalize catastrophic failure | error |

---

## 4. Data Model

### Table: import_jobs

| Column | Type | Purpose | Actual Usage |
|--------|------|---------|--------------|
| job_id | INT AUTO_INCREMENT | Primary key | PK for all operations |
| userid | INT NOT NULL | Owner | FK to taousers, used for filtering |
| source_filename | VARCHAR(255) | Original filename | Display only |
| file_type | VARCHAR(10) | csv/xls/xlsx/vcf | Parser selection |
| file_size | BIGINT | File size in bytes | Validation, display |
| file_hash | VARCHAR(64) | SHA-256 hash | Idempotency check |
| status | VARCHAR(20) | Job state | State machine driver |
| error_message | TEXT | Failure details | Displayed to user on failure |
| created_at | DATETIME | Creation timestamp | Sorting, display |
| updated_at | DATETIME | Last update | Debugging |
| started_at | DATETIME | Parse/import start | Metrics |
| finished_at | DATETIME | Import completion | Metrics |
| total_rows | INT | Total data rows | Progress display |
| parsed_rows | INT | Successfully parsed | Progress display |
| valid_rows | INT | Ready for import | Calculated via stored procedure |
| problem_rows | INT | Validation failures | Tab count |
| dupe_rows | INT | Duplicate matches | Tab count |
| imported_rows | INT | Successfully imported | Final summary |
| skipped_rows | INT | User-skipped | Final summary |
| options_json | TEXT | Import options | Delimiter, encoding settings |
| stored_file_path | VARCHAR(500) | Server file path | Parser input |

**Status values:**
- `pending` - Created, awaiting parse
- `parsing` - Parse in progress
- `parsed` - Parse complete, awaiting mapping
- `mapping` - Column mapping confirmed, awaiting process
- `reviewing` - Rows processed, awaiting finalize
- `importing` - Finalize in progress
- `completed` - Import finished
- `failed` - Unrecoverable error
- `cancelled` - User cancelled (not implemented)

**Missing constraints:**
- No CHECK constraint on status values
- No FK enforcement in MySQL (FK declared but may not be enforced)
- file_hash unique index allows NULL (by design, but creates bypass)

### Table: import_job_rows

| Column | Type | Purpose | Actual Usage |
|--------|------|---------|--------------|
| row_id | INT AUTO_INCREMENT | Primary key | Operations target |
| job_id | INT NOT NULL | Parent job | FK to import_jobs |
| row_num | INT NOT NULL | 1-based row number | Ordering, display |
| raw_json | TEXT NOT NULL | Original cell values | Column mapping reference |
| normalized_json | TEXT | Mapped/validated data | Import source |
| validation_json | TEXT | Per-field errors/warnings | Review UI display |
| dupe_json | TEXT | Duplicate candidates | Review UI display |
| status | VARCHAR(20) | Row state | Filtering, import eligibility |
| error_count | INT | Validation error count | Summary display |
| warning_count | INT | Validation warning count | Summary display |
| matched_contactid | INT | Best duplicate match | Update-existing target |
| best_match_score | INT | Duplicate score 0-100 | Display, sorting |
| created_contactid | INT | Result contact ID | Post-import reference |
| user_action | VARCHAR(20) | User decision | Import behavior |
| import_error | TEXT | Row-level import error | Display on failure |
| updated_at | DATETIME | Last update | Debugging |

**Row status values:**
- `pending` - Awaiting processing
- `ready` - Valid, no duplicates, eligible for import
- `problem` - Validation errors
- `dupe` - Duplicate candidates found
- `ignored` - User chose to skip
- `importing` - (not used, goes straight to imported/failed)
- `imported` - Successfully imported
- `failed` - Import error

**User action values:**
- `import_new` - Create new contact even if duplicate
- `update_existing` - Update matched contact
- `skip` - Ignore row (sets status to `ignored`)
- `merge` - (declared in schema but not implemented)

### Table: import_job_columns

| Column | Type | Purpose | Actual Usage |
|--------|------|---------|--------------|
| column_id | INT AUTO_INCREMENT | Primary key | Update target |
| job_id | INT NOT NULL | Parent job | FK |
| source_column_index | INT NOT NULL | 0-based column index | Raw data key |
| source_column_name | VARCHAR(255) | Header text | Display |
| normalized_field | VARCHAR(50) | Mapped TAO field | Normalization key |
| confidence | DECIMAL(3,2) | Auto-map confidence | Display indicator |
| user_confirmed | TINYINT(1) | User approved | Workflow gate |
| sample_values | TEXT | Preview values | (populated but not displayed) |
| created_at | DATETIME | Creation timestamp | Debugging |

### Table: import_job_events

| Column | Type | Purpose | Actual Usage |
|--------|------|---------|--------------|
| event_id | INT AUTO_INCREMENT | Primary key | Ordering |
| job_id | INT NOT NULL | Parent job | FK |
| event_type | VARCHAR(50) NOT NULL | Event name | Filtering |
| event_detail | TEXT | JSON details | Debugging |
| row_id | INT | Related row | (optional) |
| created_at | DATETIME | Timestamp | Ordering |

### Table: import_field_mappings

Reference table for canonical field definitions. Contains 25 standard fields covering contact, email, phone, company, address, tag, url, note categories.

### Table: import_field_aliases

Reference table for auto-mapping. Contains 100+ alias patterns with confidence scores. Includes patterns for:
- Standard headers (first name, email, phone, etc.)
- Google Contacts exports (given name, e-mail 1 - value, etc.)
- Apple/iCloud vCard fields (fn, n_given, tel_work, etc.)

---

## 5. Frontend Flow (JavaScript)

### File: `/app/assets/js/contact-import-v2.js`

### State Machine

```
INIT -> UPLOADING -> PARSING -> MAPPING -> PROCESSING -> REVIEWING -> FINALIZING -> COMPLETED
          |            |          |           |             |             |
          v            v          v           v             v             v
        ERROR        ERROR      ERROR       ERROR         ERROR         ERROR
```

### Endpoints Called

| Stage | Endpoint | Method | Payload | Response Expected |
|-------|----------|--------|---------|-------------------|
| Upload | `/ajax/import/upload.cfm` | POST (multipart) | file | `{success, job_id, filename, file_hash, is_duplicate_file}` |
| Parse | `/ajax/import/parse.cfm` | POST | `{job_id}` | `{success, totalRows, parsedRows}` |
| Get Columns | `/ajax/import/columns.cfm` | GET | `?job_id=X` | `{columns: [...]}` |
| Update Column | `/ajax/import/columns.cfm` | POST | `{column_id, normalized_field}` | `{success}` |
| Confirm Columns | `/ajax/import/columns.cfm` | POST | `{job_id, action: 'confirm'}` | `{success}` |
| Get Rows | `/ajax/import/rows.cfm` | GET | `?job_id=X&status=Y&page=Z` | `{rows: [...], total, pages}` |
| Update Row | `/ajax/import/update-row.cfm` | POST | `{row_id, data: {...}}` | `{success, new_status, validation}` |
| Set Action | `/ajax/import/row-action.cfm` | POST | `{row_id, action}` | `{success}` |
| Bulk Action | `/ajax/import/bulk-action.cfm` | POST | `{job_id, row_ids: [...], action}` | `{success}` |
| Status | `/ajax/import/status.cfm` | GET | `?job_id=X` | Full job object with counts |
| Dry Run | `/ajax/import/dry-run.cfm` | GET | `?job_id=X` | `{can_import, ready_count, issues[]}` |
| Finalize | `/ajax/import/finalize.cfm` | POST | `{job_id}` | `{success, imported, failed, errors[]}` |

### Fragile UI Assumptions

1. **Polling during parse:** JS polls `/ajax/import/status.cfm` during parsing. If network hiccups, UI may show stale state while parse completes server-side.

2. **No retry on finalize failure:** If finalize returns `{success: false}`, UI shows error but provides no recovery path. User must start over.

3. **Tab counts from job, not rows:** Problem/Dupe/Ready counts come from `import_jobs` columns, which are updated by stored procedure. If procedure fails silently, counts diverge from actual row states.

4. **Row edit assumes JSON structure:** `update-row.cfm` expects specific field names. If normalized_json was corrupted or truncated, UI errors are confusing.

5. **No session timeout handling:** Long review sessions may lose session. Finalize would fail with "Authentication required" and UI doesn't prompt re-login.

---

## 6. Current Problems

### Data Integrity Issues

| Symptom | Root Cause | File/Function | Risk |
|---------|------------|---------------|------|
| Re-importing same file creates duplicate contacts | `createJob()` nulls file_hash on duplicate warning, allowing job creation | `ContactImportV2Service.cfc:138-140` | MEDIUM - User may not realize warning and double-import |
| Update-existing may overwrite with blanks | `updateExistingContact()` updates fields unconditionally if present in rowData | `ContactImportV2Service.cfc:1232-1244` | HIGH - Blank import fields overwrite existing data |
| No validation of matched_contactid ownership | `executeImport()` uses matched_contactid without verifying it belongs to userid | `ContactImportV2Service.cfc:1036-1040` | HIGH - Could update another user's contact if row manipulated |
| Row ownership not verified | Row-action endpoints don't join on userid | `row-action.cfm:53-55`, `update-row.cfm:53-55` | MEDIUM - Cross-user row manipulation possible |

### State Machine Issues

| Symptom | Root Cause | File/Function | Risk |
|---------|------------|---------------|------|
| Failed jobs cannot resume | No transition from `failed` to `reviewing` | `tryAcquireImportLock()` | MEDIUM - User must re-upload and re-map |
| Cancelled status not implemented | UI has no cancel button, status value unused | Throughout | LOW - Cleanup of abandoned jobs requires manual DB intervention |
| Row status can desync from validation | Editing row doesn't re-run duplicate detection if row was `ready` | `updateRow()` logic | LOW - Row could become a duplicate of newer contact |

### Performance Issues

| Symptom | Root Cause | File/Function | Risk |
|---------|------------|---------------|------|
| Large file parse is slow | Individual row INSERTs in loop (no batch) | `parseFile():407-430` | MEDIUM - 10K row file takes 30+ seconds |
| Duplicate detection runs N queries | Each row queries contacts table multiple times | `DuplicateMatcherService.findDuplicates()` | HIGH - 10K rows = 30K+ queries |
| No pagination on processing | `processRows()` loads all pending rows into memory | `processRows():609-614` | HIGH - Very large imports may exhaust memory |

### Missing Idempotency

| Symptom | Root Cause | File/Function | Risk |
|---------|------------|---------------|------|
| Double-click finalize could double-import | Lock prevents concurrent, but rapid sequential still possible before status check | `finalize.cfm` | LOW - Lock mechanism is effective |
| Re-parse could create duplicate rows | No check for existing rows before INSERT | `parseFile():415-429` | MEDIUM - Unusual but possible if parse interrupted |
| Relationship enrollment may duplicate | `enrollInRelationshipSystem()` checks existence but not idempotent notifications | `createSystemNotifications():1552-1612` | LOW - Creates duplicate notifications if re-enrolled |

### Error Handling Gaps

| Symptom | Root Cause | File/Function | Risk |
|---------|------------|---------------|------|
| Parse errors not row-specific | Parser returns first error only | `FileParserService` | LOW - User sees generic "parse failed" |
| Import errors may not save | Row status update in catch may fail if DB error | `executeImport():1067-1083` | MEDIUM - Orphaned `ready` rows after failed import |
| Event logging silently fails | `logEvent()` catches all exceptions | `logEvent():1709-1723` | LOW - Audit trail may have gaps |

### Missing Transactions

| Symptom | Root Cause | File/Function | Risk |
|---------|------------|---------------|------|
| Parse rows not transactional | No transaction around row INSERTs | `parseFile()` | LOW - Partial parse leaves valid rows |
| processRows not transactional | Row status updates not atomic | `processRows()` | LOW - Inconsistent counts during processing |
| Contact + items not atomic per row | Transaction wraps entire import, not individual rows | `executeImport()` | MEDIUM - Single row item failure may leave partial contact |

### Naming Inconsistencies

| Observation | Location |
|-------------|----------|
| `normalized_field` vs `normalizedField` | Column table vs JSON keys |
| `user_action` (underscore) vs `userAction` (camelCase) | DB vs some JS |
| `dupe_json` vs `dupeJSON` | DB vs code |
| `file_hash` in DB, `fileHash` in ColdFusion | Mismatched casing |

---

## 7. Proposed V3 Design (Design Only)

### Goals

1. **Strict state machine** - Each transition explicitly gated
2. **Idempotent operations** - Same request repeated = same result
3. **Row-level transactions** - Each contact import atomic
4. **Background processing** - Parse and process asynchronously
5. **Resumable imports** - Failed imports can retry from where they stopped
6. **Audit trail** - Every state change logged with user context
7. **Ownership validation** - All operations verify userid

### Module Boundaries (CFCs)

```
ImportJobManager.cfc          - Job CRUD, state transitions, locking
  |
  +-- ImportFileProcessor.cfc - File parsing (async-capable)
  |     |
  |     +-- CSVParser.cfc
  |     +-- ExcelParser.cfc
  |     +-- VCardParser.cfc
  |
  +-- ImportRowProcessor.cfc  - Validation, normalization, dupe detection
  |
  +-- ImportColumnMapper.cfc  - Auto-mapping, user overrides
  |
  +-- ImportFinalizer.cfc     - Contact creation with per-row transactions
        |
        +-- ContactCreator.cfc (extracted from ContactService)
        +-- ContactItemCreator.cfc
        +-- RelationshipEnroller.cfc
```

### Endpoint Contracts

All endpoints return:
```json
{
  "success": true|false,
  "error_code": "ENUM_VALUE" (if !success),
  "message": "human readable",
  "data": { ... }
}
```

Error codes:
- `AUTH_REQUIRED` - Session invalid
- `NOT_FOUND` - Job/row doesn't exist
- `ACCESS_DENIED` - Job/row belongs to different user
- `INVALID_STATE` - Operation not allowed in current state
- `VALIDATION_ERROR` - Input validation failed
- `LOCK_FAILED` - Concurrent operation blocked
- `INTERNAL_ERROR` - Unexpected failure

### Job/Row State Machine

```
Job States:
  PENDING --(upload)--> UPLOADED --(parse)--> PARSING
      |                     |                     |
      v                     v                     v
  CANCELLED             CANCELLED            PARSE_FAILED
                                                  |
                                              (retry)
                                                  |
                                                  v
                            PARSED <--------------+
                              |
                         (auto-process)
                              |
                              v
                          PROCESSING --> PROCESS_FAILED
                              |                |
                              v            (retry)
                          REVIEWING <---------+
                              |
                         (finalize)
                              |
                              v
                         IMPORTING --> IMPORT_FAILED
                              |              |
                              v          (resume)
                          COMPLETED <--------+

Row States:
  PENDING --(process)--> READY|PROBLEM|DUPLICATE
                              |
                         (user action)
                              |
                              v
                      APPROVED|SKIPPED
                              |
                         (finalize)
                              |
                              v
                      IMPORTED|FAILED
```

### Error Handling Strategy

1. **Parse errors:** Capture per-row, continue to next row, store in `parse_errors` JSON column
2. **Validation errors:** Store in `validation_json`, set row status to PROBLEM
3. **Duplicate detection errors:** Log and treat as "no duplicate" (safe default)
4. **Finalize errors:** Mark row FAILED with error message, continue to next row
5. **Catastrophic errors:** Set job to IMPORT_FAILED, preserve progress, allow resume

### Idempotency Strategy

1. **File-level:** SHA-256 hash with mandatory check (no bypass). Duplicate = reject with link to existing job.

2. **Job-level:** Each operation checks expected state before proceeding. State mismatch = no-op with current state returned.

3. **Row-level:** `created_contactid` populated = skip on retry. Row re-import only if status explicitly reset.

4. **Request-level:** Optional request_id header. Store in events table. Duplicate request_id = return cached response.

### Key Invariants

1. `import_job_rows.job_id` always points to a job owned by the same user who created the row (enforced by joins)

2. A row with `status = 'imported'` always has a non-null `created_contactid`

3. A job cannot transition to IMPORTING if any row has `status = 'problem'` and `user_action IS NULL`

4. A job cannot transition from COMPLETED or CANCELLED to any other state

5. All contact writes during finalize are wrapped in per-row transactions

---

## 8. Source of Truth

### Job State

| What | Source | Column |
|------|--------|--------|
| Current workflow stage | `import_jobs` | `status` |
| Can import proceed? | Derived from row counts | `problem_rows = 0 AND (dupe_rows = 0 OR all dupes have user_action)` |
| Is job locked? | `import_jobs.status = 'importing'` | Atomic UPDATE gate |

### Row State

| What | Source | Column |
|------|--------|--------|
| Validation result | `import_job_rows` | `validation_json`, `error_count`, `warning_count` |
| Duplicate status | `import_job_rows` | `dupe_json`, `matched_contactid`, `best_match_score` |
| User decision | `import_job_rows` | `user_action` |
| Import result | `import_job_rows` | `status`, `created_contactid`, `import_error` |

### User Actions

| What | Source | Column |
|------|--------|--------|
| What user chose for dupe row | `import_job_rows` | `user_action` |
| Who made the choice | `import_job_events` (incomplete) | `event_detail` should contain userid |

### Errors

| What | Source | Column |
|------|--------|--------|
| Parse failure | `import_jobs` | `error_message` |
| Row validation errors | `import_job_rows` | `validation_json` |
| Row import errors | `import_job_rows` | `import_error` |
| Job-level import failure | `import_jobs` | `error_message` |

### Audit Trail

| What | Source | Notes |
|------|--------|-------|
| All job lifecycle events | `import_job_events` | Comprehensive but missing userid on some events |
| Row-level changes | `import_job_events` | Only major events (action set, imported, failed) |
| Detailed change history | NOT CAPTURED | No before/after snapshots |

---

## Appendix A: Discovery Command Outputs

### Repository Context

```
git rev-parse --show-toplevel
C:/Users/kevin/TAO/dev-subdomain

git status -sb
## dev...origin/dev
```

### Files Found

**Contact Import V2 Files:**
- `/ajax/import/upload.cfm`
- `/ajax/import/parse.cfm`
- `/ajax/import/columns.cfm`
- `/ajax/import/rows.cfm`
- `/ajax/import/update-row.cfm`
- `/ajax/import/row-action.cfm`
- `/ajax/import/bulk-action.cfm`
- `/ajax/import/status.cfm`
- `/ajax/import/dry-run.cfm`
- `/ajax/import/finalize.cfm`
- `/services/ContactImportV2Service.cfc`
- `/services/FileParserService.cfc`
- `/services/ValidationService.cfc`
- `/services/DuplicateMatcherService.cfc`
- `/services/ContactService.cfc`
- `/include/import-contacts.cfm`
- `/app/assets/js/contact-import-v2.js`
- `/database/migrations/V2_0__contact_import_staging_tables.sql`
- `/database/migrations/V2_1__import_v2_enhancements.sql`

### Schema Summary

Tables created by V2_0 migration:
- `import_jobs` - Job tracking with status, counts, file info
- `import_job_rows` - Individual row data with validation and dupe info
- `import_job_columns` - Column mappings per job
- `import_job_events` - Audit trail
- `import_field_mappings` - Canonical field definitions
- `import_field_aliases` - Header-to-field mappings

Stored procedure:
- `sp_update_import_job_counts` - Recalculates row counts by status

View:
- `v_import_jobs_summary` - Job listing with progress percentage

Enhancements from V2_1:
- `file_hash` column on `import_jobs` with unique index on (userid, file_hash)
- `relationship_system` field mapping
- Google Contacts and Apple vCard aliases

### Downstream Effects Traced

Contact creation touches:
- `contactdetails` (INSERT via ContactService.create)
- `contactitems` (INSERT for emails, phones, company, address, tags, URLs)
- `noteslog` (INSERT for notes)
- `fusystemusers` (INSERT for relationship enrollment)
- `funotifications` (INSERT for system actions)
- File system (create folders, copy avatar)

### Relationship System Integration

The import can enroll contacts in Target or Maintenance systems:

1. `enrollInRelationshipSystem()` checks for "Casting Director" tag to determine scope
2. Finds matching `fusystems` record by systemtype + systemscope
3. Creates `fusystemusers` enrollment record
4. `createSystemNotifications()` creates `funotifications` for each `fuactions` in the system

This matches the documented TAO relationship workflow pattern.

---

## Appendix B: Unknowns and Missing Artifacts

1. **VCF parser implementation:** FileParserService references `parseVCF()` but implementation not fully reviewed. May have edge cases with complex vCard files.

2. **Excel parser:** Uses Java/POI libraries. Large .xlsx files may have memory issues.

3. **ContactItemService:** Referenced as dependency but not directly invoked in current flow.

4. **ContactService.create return value:** Returns `insertResult.generatedKey` which may be undefined in some MySQL/ColdFusion configurations.

5. **Session userImportsPath:** Set by Application.cfc but initialization not traced. May be missing for new sessions.

6. **File cleanup:** Uploaded files are not deleted after successful import. May accumulate.

7. **Concurrent user testing:** No evidence of load testing for concurrent imports by same or different users.

8. **Maximum row limits:** No enforced limit on rows per import. Could create very large jobs.

---

*End of Process Map*
