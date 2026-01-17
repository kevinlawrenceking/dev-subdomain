# Contact Import V3 - Inventory of V2 Entry Points, Data Paths, and Contact Write Surfaces

**Created:** 2026-01-17
**Purpose:** Provide a concrete, repo-grounded inventory of all existing Contact Import V2 components so V3 can be built without breaking TAO.

---

## 1. Scope and Intent

### What This Inventory Covers

- All `/ajax/import/*.cfm` endpoints and their responsibilities
- The `ContactImportV2Service.cfc` orchestration service and helper methods
- All staging tables (`import_jobs`, `import_job_rows`, `import_job_columns`, `import_job_events`)
- Contact write paths: exactly how and where V2 creates/updates contacts
- Relationship system enrollment logic triggered by import
- UI components and JavaScript controller behavior
- Known risks identified through code inspection

### What This Inventory Does NOT Cover

- Legacy V1 import code (located in `sched/import-contacts.cfm` - separate system)
- Future V3 implementation details (see `SPEC.md` for that)
- Mobile app integration (not part of contact import)
- Bulk delete or merge operations (separate from import)

---

## 2. Import V2 Entry Points

All endpoints are located in `/ajax/import/` and require `session.userid` authentication.

### 2.1 POST /ajax/import/upload.cfm

**Purpose:** Accept file upload, compute hash, create job record.

**Inputs:**
- `file` (multipart form) - CSV, XLS, XLSX, or VCF file (max 50MB)

**Outputs:**
```json
{
  "success": true,
  "job_id": 123,
  "is_duplicate_file": false,
  "existing_job": null
}
```

**Tables Touched:**
- `import_jobs` - INSERT new job record
- `import_job_events` - INSERT "created" event

**Key Logic:**
- Lines 95-207: Creates `ContactImportV2Service`, computes file hash via `computeFileHash()`
- Hash stored in `import_jobs.file_hash` for idempotency
- Returns warning if duplicate file detected (same hash + userid)

---

### 2.2 POST /ajax/import/parse.cfm

**Purpose:** Parse uploaded file, extract headers and rows, store in staging.

**Inputs:**
```json
{ "job_id": 123, "options": {} }
```

**Outputs:**
```json
{
  "success": true,
  "total_rows": 500,
  "parsed_rows": 500
}
```

**Tables Touched:**
- `import_jobs` - UPDATE status to 'parsing' then 'parsed'
- `import_job_rows` - INSERT one row per data row from file
- `import_job_columns` - INSERT column mappings with auto-detection
- `import_job_events` - INSERT parsing events

**Key Logic:**
- Calls `FileParserService.parseFile()` for CSV/Excel/VCF handling
- Auto-maps columns via `import_field_aliases` table lookup
- Stores raw cell values as JSON in `import_job_rows.raw_json`

---

### 2.3 GET /ajax/import/columns.cfm

**Purpose:** Retrieve column mappings for review.

**Inputs:**
- `job_id` (URL param)

**Outputs:**
```json
{
  "success": true,
  "columns": [...],
  "available_fields": [...]
}
```

**Tables Touched:**
- `import_job_columns` - SELECT
- `import_field_mappings` - SELECT

---

### 2.4 GET /ajax/import/rows.cfm

**Purpose:** Retrieve rows with filtering and pagination.

**Inputs:**
- `job_id` (required)
- `status` (optional): `pending`, `ready`, `problem`, `dupe`, `ignored`, `imported`
- `page` (default: 1)
- `limit` (default: 50)
- `row_id` (optional): fetch specific row

**Outputs:**
```json
{
  "success": true,
  "rows": [...],
  "total": 500,
  "page": 1,
  "pages": 10
}
```

**Tables Touched:**
- `import_job_rows` - SELECT with pagination

---

### 2.5 POST /ajax/import/update-row.cfm

**Purpose:** Update row data and revalidate.

**Inputs:**
```json
{ "row_id": 456, "data": { "email_business": "fixed@email.com" } }
```

**Tables Touched:**
- `import_job_rows` - SELECT then UPDATE
- `import_jobs` - UPDATE counts via stored procedure

**Key Logic:**
- Lines 71-100: Ownership check joins `import_job_rows` to `import_jobs` on `job_id` and verifies `userid`
- Calls `ValidationService.validateRow()` and `DuplicateMatcherService.findDuplicates()`

---

### 2.6 POST /ajax/import/row-action.cfm

**Purpose:** Set user action for a single row.

**Inputs:**
```json
{ "row_id": 456, "action": "import_new|skip|update_existing" }
```

**Tables Touched:**
- `import_job_rows` - UPDATE `user_action` and possibly `status`
- `import_jobs` - UPDATE counts

**Key Logic:**
- Lines 53-70: Ownership verification via JOIN
- If action is "skip", sets `status = 'ignored'`

---

### 2.7 POST /ajax/import/bulk-action.cfm

**Purpose:** Set action for multiple rows at once.

**Inputs:**
```json
{
  "job_id": 123,
  "row_ids": [1, 2, 3],
  "action": "skip"
}
```

**Tables Touched:**
- `import_job_rows` - UPDATE multiple rows
- `import_jobs` - UPDATE counts

---

### 2.8 GET /ajax/import/status.cfm

**Purpose:** Get job statistics.

**Inputs:**
- `job_id` (URL param)

**Outputs:**
```json
{
  "success": true,
  "stats": {
    "total": 500,
    "ready": 450,
    "problem": 10,
    "dupe": 30,
    "ignored": 5,
    "imported": 5
  }
}
```

**Tables Touched:**
- `import_jobs` - SELECT
- `import_job_rows` - SELECT COUNT GROUP BY status

---

### 2.9 POST /ajax/import/dry-run.cfm

**Purpose:** Preview import without executing.

**Inputs:**
```json
{ "job_id": 123 }
```

**Outputs:**
```json
{
  "success": true,
  "summary": {
    "will_import": 100,
    "will_update": 20,
    "will_skip": 5,
    "problems_remaining": 3,
    "dupes_unresolved": 2
  },
  "warnings": [...],
  "preview": [...]
}
```

**Tables Touched:**
- `import_job_rows` - SELECT (read-only analysis)

---

### 2.10 POST /ajax/import/finalize.cfm

**Purpose:** Execute the import - create/update contacts.

**Inputs:**
```json
{ "job_id": 123 }
```

**Outputs:**
```json
{
  "success": true,
  "imported": 450,
  "skipped": 30,
  "failed": 5,
  "contacts": [{ "contactid": 789, "action": "created" }],
  "errors": []
}
```

**Tables Touched:**
- `import_jobs` - UPDATE status to 'importing' then 'completed'
- `import_job_rows` - UPDATE status to 'imported' or 'failed'
- `contactdetails` - INSERT (new contacts) or UPDATE (existing)
- `contactitems` - INSERT (emails, phones, addresses, tags, etc.)
- `noteslog` - INSERT (if notes provided)
- `fusystemusers` - INSERT (if relationship_system specified)
- `funotifications` - INSERT (initial notifications for enrolled contacts)

**Key Logic:**
- Lines 62-70: Atomic lock acquisition via `tryAcquireImportLock()`
- Lines 73-82: Pre-import validation via `validateForImport()`
- Lines 85: Calls `executeImport()` which wraps in `<cftransaction>`
- Lock prevents concurrent double-finalize

---

## 3. Import V2 Services

### 3.1 ContactImportV2Service.cfc

**Location:** `/services/ContactImportV2Service.cfc`
**Lines:** ~1800

**Dependencies:**
```cfml
<cfset variables.fileParserService = new FileParserService()>
<cfset variables.validationService = new ValidationService()>
<cfset variables.duplicateMatcherService = new DuplicateMatcherService()>
<cfset variables.contactService = new ContactService()>
<cfset variables.contactItemService = new ContactItemService()>
```

**Key Public Methods:**

| Method | Purpose | Critical Notes |
|--------|---------|----------------|
| `createJob()` | Create import_jobs record | Checks for duplicate file hash |
| `getJob()` | Retrieve job by ID | Returns `{found: false}` if not found |
| `parseFile()` | Parse uploaded file | Calls FileParserService, stores rows |
| `processRows()` | Validate and detect duplicates | Bulk operation on all pending rows |
| `getRows()` | Paginated row retrieval | Supports status filter |
| `updateRow()` | Update single row data | Revalidates after update |
| `setRowAction()` | Set user decision on row | skip/import_new/update_existing |
| `bulkSetAction()` | Set action for multiple rows | |
| `tryAcquireImportLock()` | Atomic lock for finalize | Prevents concurrent imports |
| `validateForImport()` | Pre-flight check | Returns issues if not ready |
| `executeImport()` | Main import execution | Wrapped in transaction |
| `getJobStats()` | Get counts by status | |

**Key Private Methods:**

| Method | Purpose | Tables Written |
|--------|---------|----------------|
| `createContactFromRow()` | Create new contact | contactdetails, contactitems, noteslog |
| `updateExistingContact()` | Update existing contact | contactdetails, contactitems, noteslog |
| `addContactItem()` | Insert email/phone/etc | contactitems |
| `addCompanyItem()` | Insert company info | contactitems |
| `addAddressItem()` | Insert address | contactitems |
| `addNote()` | Insert note | noteslog |
| `itemExists()` | Check for duplicate item | contactitems (SELECT) |
| `enrollInRelationshipSystem()` | Enroll in Target/Maintenance | fusystemusers, funotifications |
| `createSystemNotifications()` | Create initial notifications | funotifications |
| `createContactFolders()` | Create file system folders | None (filesystem only) |
| `logEvent()` | Audit trail | import_job_events |

---

### 3.2 Supporting Services

**FileParserService.cfc** - `/services/FileParserService.cfc`
- Parses CSV, XLS, XLSX, VCF files
- Returns `{ success, headers, rows, totalRows, parsedRows, errors }`

**ValidationService.cfc** - `/services/ValidationService.cfc`
- Validates individual row data against field rules
- Returns `{ valid, normalized, validation, errorCount, warningCount }`

**DuplicateMatcherService.cfc** - `/services/DuplicateMatcherService.cfc`
- Finds potential duplicate contacts by name/email/phone
- Returns `{ hasDuplicate, candidates, bestMatchContactId, bestMatchScore }`

**ContactService.cfc** - `/services/ContactService.cfc`
- Standardized CRUD for contactdetails table
- `create(dataStruct)` returns `contactid`
- `update(contactid, data)` partial update support

**ContactItemService.cfc** - `/services/ContactItemService.cfc`
- CRUD for contactitems table
- `add()` creates email/phone/address/tag items

---

## 4. Staging Tables (V2)

### 4.1 import_jobs

**Role:** Primary tracking table for import batches.

**Key Columns:**
| Column | Type | Purpose |
|--------|------|---------|
| `job_id` | INT AUTO_INCREMENT | Primary key |
| `userid` | INT NOT NULL | Owner (FK to taousers) |
| `source_filename` | VARCHAR(255) | Original filename |
| `file_type` | VARCHAR(10) | csv, xls, xlsx, vcf |
| `file_hash` | VARCHAR(64) | SHA-256 for idempotency |
| `status` | VARCHAR(20) | Job state |
| `stored_file_path` | VARCHAR(500) | Server path to uploaded file |
| `options_json` | TEXT | Parsing options |
| `total_rows` | INT | Total data rows |
| `valid_rows` | INT | Ready for import |
| `problem_rows` | INT | Validation errors |
| `dupe_rows` | INT | Potential duplicates |
| `imported_rows` | INT | Successfully imported |
| `skipped_rows` | INT | Marked ignored |

**Status Values Actually Used:**
- `pending` - Job created, file uploaded, not yet parsed
- `parsing` - Currently parsing file
- `parsed` - Parsing complete, ready for mapping
- `mapping` - User reviewing column mappings
- `reviewing` - Validation/dupe detection done, user reviewing
- `importing` - Import in progress (lock held)
- `completed` - Import finished successfully
- `failed` - Unrecoverable error occurred
- `cancelled` - User cancelled (not commonly used)

**Indexes:**
- `IX_import_jobs_userid_status (userid, status)`
- `UX_import_jobs_userid_file_hash (userid, file_hash)` - UNIQUE

---

### 4.2 import_job_rows

**Role:** Individual row data with validation and duplicate detection results.

**Key Columns:**
| Column | Type | Purpose |
|--------|------|---------|
| `row_id` | INT AUTO_INCREMENT | Primary key |
| `job_id` | INT NOT NULL | FK to import_jobs |
| `row_num` | INT | 1-based row number from file |
| `raw_json` | TEXT | Original cell values by column index |
| `normalized_json` | TEXT | Mapped field values after normalization |
| `validation_json` | TEXT | Per-field validation results |
| `dupe_json` | TEXT | Duplicate candidate array |
| `status` | VARCHAR(20) | Row state |
| `error_count` | INT | Validation error count |
| `warning_count` | INT | Validation warning count |
| `matched_contactid` | INT | Best duplicate match contact ID |
| `best_match_score` | INT | Duplicate score 0-100 |
| `user_action` | VARCHAR(20) | User decision |
| `created_contactid` | INT | Resulting contact ID after import |
| `import_error` | TEXT | Error message if failed |

**Status Values:**
- `pending` - Parsed but not validated
- `ready` - Validated, no issues, ready for import
- `problem` - Has validation errors
- `dupe` - Potential duplicate detected
- `ignored` - User marked to skip
- `importing` - Currently being imported
- `imported` - Successfully imported
- `failed` - Import failed for this row

**User Action Values:**
- `import_new` - Create new contact (for dupes)
- `skip` - Do not import
- `update_existing` - Update matched contact (for dupes)
- `merge` - (Reserved, not currently implemented)

---

### 4.3 import_job_columns

**Role:** Column mapping configuration per job.

**Key Columns:**
| Column | Type | Purpose |
|--------|------|---------|
| `column_id` | INT AUTO_INCREMENT | Primary key |
| `job_id` | INT NOT NULL | FK to import_jobs |
| `source_column_index` | INT | 0-based column index |
| `source_column_name` | VARCHAR(255) | Header text from file |
| `normalized_field` | VARCHAR(50) | Mapped TAO field name |
| `confidence` | DECIMAL(3,2) | Auto-map confidence 0.00-1.00 |
| `user_confirmed` | TINYINT(1) | User approved mapping |

---

### 4.4 import_job_events

**Role:** Audit trail for import operations.

**Key Columns:**
| Column | Type | Purpose |
|--------|------|---------|
| `event_id` | INT AUTO_INCREMENT | Primary key |
| `job_id` | INT NOT NULL | FK to import_jobs |
| `event_type` | VARCHAR(50) | Event category |
| `event_detail` | TEXT | JSON details |
| `row_id` | INT | Related row if applicable |
| `created_at` | DATETIME | Event timestamp |

**Event Types:**
- `created` - Job created
- `parsing_started` - Parse began
- `parsing_completed` - Parse finished
- `parsing_failed` - Parse error
- `columns_mapped` - Mappings confirmed
- `row_updated` - Row data edited
- `row_action_set` - User set action on row
- `bulk_action_set` - Bulk action applied
- `import_started` - Import began
- `import_completed` - Import finished
- `row_imported` - Single row imported
- `row_failed` - Single row failed

---

## 5. Contact Write Surfaces

### 5.1 New Contact Creation

**Entry Point:** `ContactImportV2Service.createContactFromRow()` (lines 1120-1220)

**Tables Written:**

1. **contactdetails** (via ContactService.create)
   ```sql
   INSERT INTO contactdetails (userid, contactFullName, contactBirthday, contactMeetingDate, contactMeetingLoc)
   ```
   - Required: `userid`, `contactFullName`
   - Optional: `contactBirthday`, `contactMeetingDate`, `contactMeetingLoc`

2. **contactitems** - Multiple inserts per contact:
   - Emails: `valueCategory='Email'`, `valueType='Business'|'Personal'`
   - Phones: `valueCategory='Phone'`, `valueType='Work'|'Mobile'|'Home'`
   - Company: `valueCategory='Company'`, includes `valueCompany`, `valueDepartment`, `valueTitle`
   - Address: `valueCategory='Address'`, includes street, city, state, zip, country columns
   - Tags: `valueCategory='Tag'`, `valueType='Tags'`
   - Website: `valueCategory='URL'`, `valueType='Company Website'`

3. **noteslog** - If notes field provided:
   ```sql
   INSERT INTO noteslog (contactid, userid, noteDetails, notetimestamp)
   ```

### 5.2 Existing Contact Update

**Entry Point:** `ContactImportV2Service.updateExistingContact()` (lines 1223-1294)

**Tables Written:**

1. **contactdetails** (via ContactService.update)
   - Only updates fields that have values in import data
   - Updates: `contactBirthday`, `contactMeetingDate`, `contactMeetingLoc`
   - Does NOT update `contactFullName` on existing contacts

2. **contactitems** - Additive only
   - Checks `itemExists()` before adding
   - Will NOT create duplicate items
   - Does NOT update or remove existing items

3. **noteslog** - Always appends new note if provided

### 5.3 Contact Write Assumptions

1. **userid is always required** - Enforced at ContactService.create
2. **contactFullName is always required** - Built from firstName/lastName if not provided
3. **primary_yn='Y'** set on first email/phone of each type
4. **itemStatus='Active'** always set on new items
5. **notetimestamp=NOW()** always set on new notes

### 5.4 Generated Keys

- contactdetails: `contactid` via `insertResult.generatedKey` or `LAST_INSERT_ID()`
- contactitems: No key retrieval (fire-and-forget inserts)
- noteslog: No key retrieval

---

## 6. Relationship and Notification Side Effects

### 6.1 When Import Triggers Enrollment

Enrollment occurs when:
1. Import row has `relationship_system` field mapped
2. Field value is "Target" or "Maintenance"
3. Called from both `createContactFromRow()` and `updateExistingContact()`

**Code Location:** `ContactImportV2Service.enrollInRelationshipSystem()` (lines 1417-1541)

### 6.2 Enrollment Logic

1. **Determine System Type:**
   - "Target" maps to systemtype="Targeted List"
   - "Maintenance" maps to systemtype="Maintenance List"

2. **Determine System Scope:**
   - Checks if contact has Tag with `valuetext='Casting Director'`
   - If yes: systemscope="Casting Director"
   - If no: systemscope="Industry"

3. **Find System:**
   ```sql
   SELECT systemid FROM fusystems
   WHERE systemtype = ? AND systemscope = ?
   AND (isActive = 1 OR isActive IS NULL)
   ```

4. **Check Existing Enrollment:**
   ```sql
   SELECT fusystemuserid FROM fusystemusers
   WHERE systemid = ? AND contactid = ? AND userid = ?
   AND (isdeleted IS NULL OR isdeleted = 0)
   ```
   - If already enrolled, returns success without re-enrolling

5. **Create Enrollment:**
   ```sql
   INSERT INTO fusystemusers (systemid, userid, contactid, enrollmentdate, sustartdate, sustatus)
   VALUES (?, ?, ?, NOW(), ?, 'Active')
   ```

### 6.3 Tables Written by Enrollment

1. **fusystemusers**
   - `systemid` - FK to fusystems
   - `userid` - Owner
   - `contactid` - Enrolled contact
   - `enrollmentdate` - NOW()
   - `sustartdate` - Start date (same as enrollment)
   - `sustatus` - 'Active'

2. **funotifications** - Via `createSystemNotifications()`
   - One notification per action in the system
   - Checks `isUnique` flag before creating
   - Sets `notstartdate` based on `actionDaysNo` offset
   - Sets `notstatus='Pending'`

### 6.4 Idempotency

- Enrollment check prevents duplicate fusystemusers records
- `isUnique` actions only create notification once per contact/user/action
- However: Multiple imports of same contact WILL create multiple notes

---

## 7. UI Flow Summary

### 7.1 Main Import Page

**Location:** `/include/import-contacts.cfm`

**States:**
1. **No Active Job:** Shows upload area and import history
2. **Pending Job:** Shows "Parse File" button
3. **Parsed/Mapping Job:** Shows column mapping UI
4. **Reviewing Job:** Shows review grid with tabs
5. **Completed Job:** Shows success message and link to contacts

### 7.2 JavaScript Controller

**Location:** `/app/assets/js/contact-import-v2.js`
**Lines:** ~1170

**State Management:**
```javascript
var state = {
    jobId: 0,
    currentFilter: '',    // status filter for rows
    currentPage: 1,
    pageSize: 50,
    selectedRows: new Set(),
    stats: {}
};
```

**Key Functions:**
| Function | Purpose |
|----------|---------|
| `uploadFile()` | POST to /ajax/import/upload.cfm |
| `parseFile()` | POST to /ajax/import/parse.cfm |
| `loadColumnMappings()` | GET /ajax/import/columns.cfm |
| `confirmMappings()` | POST to /ajax/import/parse.cfm (with options) |
| `loadRows()` | GET /ajax/import/rows.cfm |
| `editRow()` | Opens edit modal |
| `saveEdit()` | POST to /ajax/import/update-row.cfm |
| `resolveDupe()` | Opens duplicate resolution modal |
| `setDupeAction()` | POST to /ajax/import/row-action.cfm |
| `bulkAction()` | POST to /ajax/import/bulk-action.cfm |
| `dryRun()` | POST to /ajax/import/dry-run.cfm |
| `finalizeImport()` | POST to /ajax/import/finalize.cfm |

### 7.3 UI Assumptions Not Enforced by DB

1. **Job ownership** - UI assumes `job.userid = session.userid` but DB has no view constraint
2. **Status progression** - UI expects linear flow but DB allows any status transition
3. **Row counts** - UI displays cached counts that may be stale until `updateStats()` called
4. **Duplicate display** - UI shows first duplicate only; DB may have multiple candidates

---

## 8. Known Risk Areas (From Code Inspection)

### 8.1 Cross-User Access Risk

**Location:** All /ajax/import/*.cfm endpoints

**Finding:** Each endpoint performs ownership check but in different ways:
- Most use: `SELECT ... FROM import_job_rows r INNER JOIN import_jobs j ON j.job_id = r.job_id WHERE j.userid = ?`
- finalize.cfm uses: `job.userid neq userid` check after getJob()

**Risk:** Inconsistent ownership verification patterns could lead to bypass if one endpoint is modified incorrectly.

**Mitigation for V3:** Centralize ownership check in service layer, not endpoints.

### 8.2 Partial Write Risk

**Location:** `ContactImportV2Service.executeImport()` (lines 1027-1114)

**Finding:** Transaction wraps entire import but:
- Individual row failures are caught and logged (lines 1066-1084)
- Row is marked `status='failed'` and import continues
- Other rows in transaction are committed

**Risk:** Partial success state is intentional but can leave data in inconsistent state if system crashes mid-import.

**Mitigation for V3:** Consider batch checkpointing for large imports.

### 8.3 Overwrite-With-Blank Risk

**Location:** `ContactImportV2Service.updateExistingContact()` (lines 1223-1294)

**Finding:** Code checks `len(arguments.rowData.field)` before updating:
```cfml
<cfif structKeyExists(arguments.rowData, "birthday") and len(arguments.rowData.birthday)>
```

**Risk:** Blank values in import file are correctly ignored. However, V3 should explicitly document this behavior and consider allowing "clear field" as explicit action.

### 8.4 Missing Idempotency on Notes

**Location:** `ContactImportV2Service.updateExistingContact()` line 1283-1284

**Finding:** Notes are always appended:
```cfml
<cfif structKeyExists(arguments.rowData, "notes") and len(arguments.rowData.notes)>
    <cfset addNote(arguments.contactid, arguments.userid, arguments.rowData.notes)>
</cfif>
```

**Risk:** Re-running import with same file creates duplicate notes.

**Mitigation for V3:** Hash note content and check for existing identical note before insert.

### 8.5 Missing Transaction on Enrollment

**Location:** `ContactImportV2Service.enrollInRelationshipSystem()` (lines 1435-1538)

**Finding:** Enrollment and notification creation not wrapped in transaction.

**Risk:** If notification creation fails after fusystemusers insert, system is partially enrolled.

**Mitigation for V3:** Wrap in transaction or make notification creation failure non-fatal (already is via try/catch).

### 8.6 Folder Creation Race Condition

**Location:** `ContactImportV2Service.createContactFolders()` (lines 1625-1696)

**Finding:** Directory creation uses:
```cfml
<cfif not directoryExists(userFolder)>
    <cfdirectory directory="#userFolder#" action="create">
</cfif>
```

**Risk:** Race condition if parallel imports for same user. Mitigated by broad catch block.

### 8.7 Lock Release on Validation Failure

**Location:** `/ajax/import/finalize.cfm` (lines 72-82)

**Finding:** If validation fails after lock acquired, lock is released:
```cfml
<cfset importService.updateJobStatus(requestData.job_id, "reviewing")>
```

**Risk:** None identified - this is correct behavior.

---

## 9. Implications for V3

### 9.1 Constraints V3 Must Respect

1. **Table Schema Compatibility:**
   - contactdetails requires `userid` (NOT NULL)
   - contactdetails requires `contactFullName` (NOT NULL via service)
   - contactitems FK to contactid (CASCADE)
   - noteslog FK to contactid

2. **Existing Service Contracts:**
   - `ContactService.create(dataStruct)` returns numeric contactid
   - `ContactService.update(contactid, data)` accepts partial data struct
   - `ContactItemService.add()` handles all item types

3. **Relationship System Integration:**
   - fusystems lookup by systemtype + systemscope
   - fusystemusers unique on (systemid, contactid, userid) when not deleted
   - funotifications created based on fuactions for system

4. **Ownership Model:**
   - All contacts owned by single userid
   - All import jobs owned by single userid
   - Cross-user access must be explicitly denied

### 9.2 Patterns V3 Should NOT Repeat

1. **DO NOT** perform ownership check in endpoints - centralize in service
2. **DO NOT** store raw file on disk without cleanup strategy
3. **DO NOT** allow importing without explicit user confirmation
4. **DO NOT** create duplicate notes on re-import
5. **DO NOT** skip transaction boundaries on multi-table writes
6. **DO NOT** mix SQL dialects (V2 had legacy MSSQL comments that confused MySQL)

### 9.3 Improvements for V3

1. **Audit trail enhancement:** Track which import_job created each contact
2. **Undo capability:** Add `import_job_id` to contactdetails for batch undo
3. **Better dupe handling:** Allow merge (not just skip/update/new)
4. **Field-level conflict UI:** Show which fields differ on update
5. **Progress streaming:** Long imports should stream progress to UI

---

## 10. Open Questions

### 10.1 Must Be Resolved Before V3 Finalize

1. **Should V3 support batch undo?** If yes, need to track import_job_id on created contacts.

2. **What happens to incomplete V2 jobs when V3 launches?** Need migration/cleanup plan.

3. **Should V3 reuse V2 staging tables or create new ones?** Recommendation: New tables with prefix `import_v3_`.

4. **How should V3 handle existing duplicate contacts differently?** V2 only checks name/email/phone. Should V3 use smarter matching?

### 10.2 To Be Clarified with Product

1. **Merge behavior:** If user selects "merge", which fields win - import or existing?

2. **Folder assignment:** Should import support assigning contacts to folders?

3. **Tag handling:** Should import merge tags or replace them?

4. **Relationship enrollment timing:** Should enrollment happen immediately or be queued?

### 10.3 Technical Uncertainties

1. **FileParserService VCF handling:** Edge cases with multi-value vCard fields not fully tested.

2. **Large file performance:** Files > 10,000 rows may timeout during parse. Needs background job?

3. **Concurrent import limit:** No enforcement of one-import-at-a-time per user.

---

## References

- V2 Main Service: `/services/ContactImportV2Service.cfc`
- V2 Endpoints: `/ajax/import/*.cfm`
- V2 UI: `/include/import-contacts.cfm`
- V2 JS: `/app/assets/js/contact-import-v2.js`
- V2 Schema: `/database/migrations/V2_0__contact_import_staging_tables.sql`
- V2 Enhancements: `/database/migrations/V2_1__import_v2_enhancements.sql`
- V3 Spec (future): `/docs/contact-import-v3/SPEC.md`
