# Contact Import V3 - Technical Reference Document

> **Purpose:** Complete reference for how Contact Import V3 works, to serve as the blueprint for building the Auditions Import module.

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [File Inventory](#2-file-inventory)
3. [Database Schema](#3-database-schema)
4. [Import Flow (4 Phases)](#4-import-flow)
5. [AJAX Endpoints](#5-ajax-endpoints)
6. [JavaScript Controller](#6-javascript-controller)
7. [Services Layer](#7-services-layer)
8. [Duplicate Detection](#8-duplicate-detection)
9. [Validation Rules](#9-validation-rules)
10. [Finalization Process](#10-finalization-process)
11. [UI Components](#11-ui-components)
12. [Patterns and Standards](#12-patterns-and-standards)
13. [Adaptation Guide for Auditions Import](#13-adaptation-guide-for-auditions-import)

---

## 1. Architecture Overview

Contact Import V3 is a multi-phase, AJAX-driven import system with:

- **Staging-first design** - raw data goes into staging tables, never directly into production
- **EAV fact storage** - each field value is a separate row in `import_v3_facts`, enabling per-field validation and conflict resolution
- **Weighted duplicate detection** - in-memory index of existing contacts, scored matching algorithm
- **Per-row transactions** - each contact creation is an isolated transaction
- **Idempotent finalization** - double-finalize won't double-insert (checked via `import_v3_row_results`)
- **Feature flags** - global toggle + per-user allowlist

```
Browser                     Server                          Database
  |                           |                               |
  |-- Upload File ----------->|-- upload.cfm -------> import_v3_jobs (CREATE)
  |                           |                               |
  |-- Parse ----------------->|-- parse.cfm --------> import_v3_columns (INSERT)
  |                           |                        import_v3_rows (INSERT)
  |                           |                        import_v3_facts (INSERT)
  |                           |                               |
  |-- Map Columns ----------->|-- columns.cfm ------> import_v3_columns (UPDATE)
  |                           |                               |
  |-- Recompute ------------->|-- recompute.cfm ----> import_v3_facts (validate)
  |                           |   DuplicateMatcherService     |
  |                           |                        import_v3_rows (status update)
  |                           |                               |
  |-- Review Grid ----------->|-- rows.cfm ---------> SELECT rows + facts
  |-- Edit Row -------------->|-- row_action.cfm ---> UPDATE rows
  |                           |                               |
  |-- Finalize -------------->|-- finalize.cfm -----> contacts (INSERT)
  |                           |                        contactitems (INSERT)
  |                           |                        import_v3_row_results (INSERT)
  |                           |                        fusystemusers (INSERT, if system enrollment)
```

---

## 2. File Inventory

### Application Pages
| File | Purpose |
|------|---------|
| `app/contacts-import-v3/index.cfm` | Entry point page |
| `include/import-contacts-v3.cfm` | Main HTML template (all steps, modals, hidden inputs) |
| `app/admin-import-v3/index.cfm` | Admin dashboard for feature flags and allowlist |

### AJAX Endpoints (`ajax/importv3/`)
| File | Method | Purpose |
|------|--------|---------|
| `upload.cfm` | POST | File upload with hash dedup |
| `parse.cfm` | POST | Parse file, extract headers/rows, auto-map columns |
| `columns.cfm` | GET/POST | Read/update column mappings |
| `recompute.cfm` | POST | Validate all facts + run duplicate detection |
| `rows.cfm` | GET | Paginated row list with filtering and stats |
| `row_action.cfm` | POST | Set user action on row(s): skip, import_new, update_existing |
| `row.cfm` | GET/POST | Get or update a single row |
| `finalize.cfm` | POST | Create contacts from approved rows |
| `status.cfm` | POST | Manual job status transitions (unstick jobs) |
| `admin_dashboard.cfm` | GET/POST | Admin stats, flag management, allowlist |
| `admin_cleanup.cfm` | POST | Admin cleanup operations |
| `history.cfm` | GET | Import job history |
| `preview_update.cfm` | GET | Preview what an update would do |
| `finalize_update.cfm` | POST | Finalize update-type rows |
| `fact_update.cfm` | POST | Update individual fact values |
| `normalize_fact_fieldnames.cfm` | POST | Normalize fact field names |

### JavaScript
| File | Purpose |
|------|---------|
| `app/assets/js/contact-import-v3.js` | Main JS controller (~2000 lines) |

### Services (CFC)
| File | Purpose |
|------|---------|
| `services/ContactImportV3Service.cfc` | Job management, ownership, locking, status transitions |
| `services/DuplicateMatcherService.cfc` | Duplicate detection and scoring |
| `services/ContactDuplicateService.cfc` | Contact duplicate utilities |
| `services/ImportV3Logger.cfc` | Structured logging with correlation IDs |

### Database Migrations (`database/migrations/`)
| File | Purpose |
|------|---------|
| `V3_0__contact_import_v3_tables.sql` | Main schema (7 tables) |
| `V3_0__contact_import_v3_tables_ROLLBACK.sql` | Rollback script |
| `V3_2__contact_import_v3_dupe_indexes.sql` | Performance indexes for dupe detection |
| `V3_2__contact_import_v3_dupe_indexes_ROLLBACK.sql` | Rollback |
| `V3_3__import_v3_columns_add_mapping_fields.sql` | Column mapping fields (intent, target_key, transform_json) |
| `V3_3__import_v3_columns_add_mapping_fields_ROLLBACK.sql` | Rollback |

### Other
| File | Purpose |
|------|---------|
| `database/enable-importv3.cfm` | Feature flag enablement script |
| `database/reset_import_v3_data.sql` | Reset all V3 import data |
| `assets/templates/contact_import_template_with_relationships.csv` | Sample template file |

---

## 3. Database Schema

### import_v3_jobs (Master job tracker)

```sql
CREATE TABLE import_v3_jobs (
  job_id          INT AUTO_INCREMENT PRIMARY KEY,
  userid          INT NOT NULL,                    -- FK to taousers
  source_filename VARCHAR(500),
  file_type       VARCHAR(10),                     -- csv, xls, xlsx, vcf
  file_size       BIGINT,
  file_hash       VARCHAR(64),                     -- SHA-256 for dedup
  stored_file_path VARCHAR(1000),
  status          ENUM('pending','parsing','parsed','mapping','validating',
                       'reviewing','importing','completed','failed','cancelled'),
  error_message   TEXT,
  total_rows      INT DEFAULT 0,
  parsed_rows     INT DEFAULT 0,
  valid_rows      INT DEFAULT 0,
  problem_rows    INT DEFAULT 0,
  dupe_rows       INT DEFAULT 0,
  imported_rows   INT DEFAULT 0,
  updated_rows    INT DEFAULT 0,
  skipped_rows    INT DEFAULT 0,
  options_json    TEXT,
  import_mode     VARCHAR(30) DEFAULT 'create_only',  -- create_only|update_existing|create_and_update
  allow_blank_overwrite      TINYINT DEFAULT 0,
  relationship_system_default VARCHAR(50),
  folder_assignment_json     TEXT,
  created_at      DATETIME DEFAULT NOW(),
  updated_at      DATETIME DEFAULT NOW() ON UPDATE NOW(),
  started_at      DATETIME,
  finished_at     DATETIME,

  INDEX (userid, status),
  INDEX (created_at DESC),
  INDEX (status),
  UNIQUE (userid, file_hash)           -- Prevents re-importing same file
) ENGINE=InnoDB;
```

### import_v3_columns (Column mapping)

```sql
CREATE TABLE import_v3_columns (
  column_id           INT AUTO_INCREMENT PRIMARY KEY,
  job_id              INT NOT NULL,                -- FK to import_v3_jobs
  source_column_index INT,                         -- 0-based column position
  source_column_name  VARCHAR(500),                -- Original header text
  mapped_field        VARCHAR(100),                -- Canonical field name
  is_custom_field     TINYINT DEFAULT 0,
  custom_field_id     INT,
  confidence          DECIMAL(3,2) DEFAULT 0.00,   -- 0.00 to 1.00
  user_confirmed      TINYINT DEFAULT 0,
  sample_values       TEXT,                        -- JSON array of first N values
  -- V3.3 additions:
  intent              VARCHAR(50),                 -- ignore|contact_field|contact_item|tag|note|custom_meta
  target_key          VARCHAR(100),                -- Target field when intent requires it
  transform_json      TEXT,                        -- Custom transformations

  INDEX (job_id),
  UNIQUE (job_id, source_column_index)
) ENGINE=InnoDB;
```

### import_v3_rows (Individual rows)

```sql
CREATE TABLE import_v3_rows (
  row_id              INT AUTO_INCREMENT PRIMARY KEY,
  job_id              INT NOT NULL,
  row_num             INT,                         -- 1-based row number
  raw_json            TEXT,                        -- Original cell values by column index
  status              ENUM('pending','validating','ready','problem','dupe',
                           'ignored','importing','imported','updated','failed'),
  error_count         INT DEFAULT 0,
  warning_count       INT DEFAULT 0,
  validation_summary  TEXT,                        -- JSON of all issues
  dupe_candidates_json TEXT,                       -- JSON array of candidate matches
  matched_contactid   INT,                         -- Best match contact ID
  best_match_score    DECIMAL(5,2) DEFAULT 0,
  user_action         VARCHAR(30),                 -- import_new|skip|update_existing|merge
  user_action_at      DATETIME,
  created_contactid   INT,
  updated_contactid   INT,
  import_error        TEXT,
  imported_at         DATETIME,
  created_at          DATETIME DEFAULT NOW(),
  updated_at          DATETIME DEFAULT NOW() ON UPDATE NOW(),

  INDEX (job_id, status),
  INDEX (job_id, row_num),
  INDEX (status),
  INDEX (matched_contactid),
  UNIQUE (job_id, row_num)
) ENGINE=InnoDB;
```

### import_v3_facts (EAV field storage - the key design pattern)

```sql
CREATE TABLE import_v3_facts (
  fact_id             INT AUTO_INCREMENT PRIMARY KEY,
  row_id              INT NOT NULL,                -- FK to import_v3_rows
  column_id           INT,                         -- FK to import_v3_columns
  field_name          VARCHAR(100),                -- Canonical: email_business, phone_mobile, etc.
  raw_value           TEXT,                        -- Original imported value
  normalized_value    TEXT,                        -- Cleaned/normalized value
  is_valid            TINYINT DEFAULT 1,
  validation_code     VARCHAR(50),                 -- Error code if invalid
  validation_message  VARCHAR(500),                -- Human-readable message
  existing_value      TEXT,                        -- Current value in production (for updates)
  has_conflict        TINYINT DEFAULT 0,
  user_choice         VARCHAR(30),                 -- keep_existing|use_import|clear
  created_at          DATETIME DEFAULT NOW(),
  updated_at          DATETIME DEFAULT NOW() ON UPDATE NOW(),

  INDEX (row_id),
  INDEX (field_name),
  INDEX (is_valid, validation_code),
  UNIQUE (row_id, column_id)
) ENGINE=InnoDB;
```

### import_v3_row_results (Finalization audit trail)

```sql
CREATE TABLE import_v3_row_results (
  result_id       INT AUTO_INCREMENT PRIMARY KEY,
  row_id          INT NOT NULL,
  job_id          INT,                             -- Denormalized for fast queries
  action_taken    VARCHAR(20),                     -- created|updated|skipped|failed
  contactid       INT,                             -- Which contact was affected
  fields_written  INT DEFAULT 0,
  fields_skipped  INT DEFAULT 0,
  items_created   INT DEFAULT 0,
  notes_created   INT DEFAULT 0,
  error_code      VARCHAR(50),
  error_message   TEXT,
  undo_available  TINYINT DEFAULT 0,
  undo_json       TEXT,                            -- Data to reverse import
  undone_at       DATETIME,
  created_at      DATETIME DEFAULT NOW(),

  INDEX (job_id),
  INDEX (action_taken),
  INDEX (contactid),
  UNIQUE (row_id)                                  -- Ensures idempotency
) ENGINE=InnoDB;
```

### import_v3_events (Audit log)

```sql
CREATE TABLE import_v3_events (
  event_id    INT AUTO_INCREMENT PRIMARY KEY,
  job_id      INT NOT NULL,
  event_type  VARCHAR(50),     -- created|parsing_started|parsing_completed|...
  event_detail TEXT,           -- JSON
  row_id      INT,             -- Optional, for row-specific events
  userid      INT,
  created_at  DATETIME DEFAULT NOW(),

  INDEX (job_id),
  INDEX (event_type),
  INDEX (created_at DESC),
  INDEX (row_id)
) ENGINE=InnoDB;
```

### contact_custom_fields (User-defined fields)

```sql
CREATE TABLE contact_custom_fields (
  field_id        INT AUTO_INCREMENT PRIMARY KEY,
  userid          INT NOT NULL,
  field_key       VARCHAR(100),          -- Internal name
  field_label     VARCHAR(200),          -- Display name
  field_type      VARCHAR(20),           -- text|email|phone|date|url|select
  options_json    TEXT,                  -- For select type: JSON array of options
  is_required     TINYINT DEFAULT 0,
  max_length      INT,
  validation_regex VARCHAR(500),
  sort_order      INT DEFAULT 0,
  is_active       TINYINT DEFAULT 1,
  show_in_list    TINYINT DEFAULT 0,
  show_in_card    TINYINT DEFAULT 0,
  created_at      DATETIME DEFAULT NOW(),
  updated_at      DATETIME DEFAULT NOW() ON UPDATE NOW(),

  INDEX (userid),
  INDEX (userid, is_active),
  UNIQUE (userid, field_key)
) ENGINE=InnoDB;
```

---

## 4. Import Flow (4 Phases)

### Phase 1: Upload

1. User drops or selects file (CSV, XLS, XLSX, VCF)
2. JS `uploadFile()` sends `POST /ajax/importv3/upload.cfm` (multipart/form-data)
3. Server validates:
   - Auth: `session.userid` required
   - File type whitelist: csv, xls, xlsx, vcf
   - File size max: 50MB
   - Computes SHA-256 hash
   - Checks for duplicate file (UNIQUE index on `userid, file_hash`)
4. Creates `import_v3_jobs` record with `status='uploaded'`
5. Stores file to disk at `stored_file_path`
6. Returns `{success, data: {job: {job_id, status}}}`
7. On duplicate: returns `{code: 'DUPLICATE_FILE', data: {job: {existing_job_id}}}`
8. JS redirects to `/app/contacts-import-v3/?job_id=<jobid>`

### Phase 2: Parse and Map

**Parse:** `POST /ajax/importv3/parse.cfm`

1. Reads file from disk
2. Extracts headers and data rows (format-specific parsers)
3. Inserts `import_v3_columns` (one per column, with `source_column_name`)
4. Inserts `import_v3_rows` (one per data row, with `raw_json`)
5. Inserts `import_v3_facts` (one per cell: row x column, with `raw_value`)
6. Auto-maps columns by header name matching (camelCase canonical names)
7. VCF: auto-maps standard vCard fields with 100% confidence
8. Status: `uploaded -> parsing -> parsed`

**Map Columns:** `GET/POST /ajax/importv3/columns.cfm`

- GET returns all columns with sample values and auto-mapping confidence
- User reviews/adjusts column-to-field mapping in the UI
- POST updates: `intent`, `target_key`, `user_confirmed`, `transform_json`
- Column intents: `ignore`, `contact_field`, `contact_item`, `tag`, `note`, `custom_meta`

**Recompute:** `POST /ajax/importv3/recompute.cfm`

1. Validates every fact using type-specific rules
2. Updates `import_v3_facts`: `normalized_value`, `is_valid`, `validation_code`, `validation_message`
3. Builds in-memory dupe index from user's existing contacts
4. Runs scoring algorithm per row (see Section 8)
5. Updates `import_v3_rows`: `status`, `dupe_candidates_json`, `matched_contactid`, `best_match_score`
6. Denormalizes counts to `import_v3_jobs`: `valid_rows`, `problem_rows`, `dupe_rows`
7. Status: `parsed/mapping -> reviewing`

### Phase 3: Review and Resolve

**Load Rows:** `GET /ajax/importv3/rows.cfm`

- Parameters: `job_id`, `status` (all|ready|problem|dupe|ignored|imported), `page`, `page_size`, `search`
- Returns paginated rows with per-row facts, errors, and dupe candidates
- Stats object with counts per status

**User Actions:**

- **Tab filtering** - switch between All, Ready, Problems, Duplicates, Ignored, Imported
- **Search** - client-side filter by name, email, phone, company
- **Inline edit** - click field to open edit modal, save updates fact and re-validates
- **Duplicate resolution** - modal showing top 5 candidates with scores and comparison
- **Row actions** - Skip, Import as New, Update Existing (via `POST /ajax/importv3/row_action.cfm`)
- **Bulk actions** - select multiple rows, apply action to all
- **Refresh validation** - re-runs recompute after edits

### Phase 4: Finalize

**Finalize:** `POST /ajax/importv3/finalize.cfm`

1. CSRF validation (X-CSRF-Token header, body, or form field)
2. Acquires job lock, transitions `reviewing -> finalizing`
3. For each row where `user_action = 'import_new'`:
   - BEGIN TRANSACTION
   - Create `contacts` record
   - Write facts to contact fields and `contactitems` table
   - Enroll in relationship system if specified
   - Insert `import_v3_row_results` (action_taken, contactid, fields_written)
   - COMMIT
   - Update row: `status='imported'`, `imported_at=NOW()`
4. On error: ROLLBACK, mark row as `failed`, record error in `import_v3_row_results`
5. Finishes: `finalizing -> completed`, sets `finished_at`
6. Returns `{created_count, updated_count, failed_count, total_processed}`

**Idempotency guarantees:**
- File hash UNIQUE index prevents re-uploading same file
- `import_v3_row_results` UNIQUE on `row_id` prevents double-creating contacts
- Re-running finalize skips rows that already have results

---

## 5. AJAX Endpoints Detail

### upload.cfm (POST)
- **Input:** multipart file, `session.userid` (auth)
- **Output:** `{success, data: {job: {job_id, status, file_hash}}}`
- **Error codes:** `AUTH_REQUIRED`, `DUPLICATE_FILE`, `INVALID_FILE_TYPE`, `FILE_TOO_LARGE`

### parse.cfm (POST)
- **Input:** `job_id`
- **Output:** `{success, data: {column_count, row_count, fact_count, auto_mapped}}`
- **Error codes:** `AUTH_REQUIRED`, `ACCESS_DENIED`, `INVALID_STATE`, `PARSE_FAILED`
- **Idempotent:** Returns existing counts if already parsed

### columns.cfm (GET/POST)
- **GET Input:** `job_id`
- **GET Output:** `{columns: [{column_id, source_name, intent, target_key, confidence, sample_values}]}`
- **POST Input:** `job_id`, array of column updates
- **Error codes:** `INVALID_INTENT`, `TARGET_KEY_REQUIRED`, `UPDATE_FAILED`

### recompute.cfm (POST)
- **Input:** `job_id`
- **Output:** `{success, data: {stats: {total, ready, problem, dupe, ignored}}}`
- **Timeout:** 300s (for large datasets)
- **Error codes:** `AUTH_REQUIRED`, `INVALID_STATE`, `LOCKED`, `RECOMPUTE_FAILED`

### rows.cfm (GET)
- **Input:** `job_id`, `status`, `page`, `page_size`, `search`
- **Output:** `{rows: [...], stats: {total, ready, problem, dupe, ignored, imported, page_count}}`
- **Pagination:** Default 50, max 200 per page

### row_action.cfm (POST)
- **Input:** `job_id`, `row_id` (or `row_ids` array), `action` (ignore|create|skip|import_new|update_existing)
- **Output:** `{rows_updated, status}`
- **CSRF required**

### finalize.cfm (POST)
- **Input:** `job_id`, `csrf_token`
- **Optional:** `dry_run=1` for preview without writing
- **Output:** `{created, updated, failed, total_processed}`
- **Status transitions:** `reviewing -> finalizing -> completed`

### status.cfm (POST)
- **Input:** `job_id`, `new_status`, `csrf_token`
- **Purpose:** Manual status transitions for unsticking jobs
- **Allowed:** reviewing<->finalizing, completed->reviewing, failed->reviewing

---

## 6. JavaScript Controller

**File:** `app/assets/js/contact-import-v3.js` (~2000 lines)

### Initialization
- Bounded jQuery wait (up to 2s)
- Uses `$j` alias (noConflict-safe, never global `$`)
- Guard flag prevents double-init
- Calls `initV3()` once jQuery is ready

### State Management
```javascript
state = {
  jobId: 0,
  currentFilter: '',    // Status tab filter
  currentPage: 1,
  pageSize: 50,
  stats: {},            // Row counts by status
  searchQuery: ''
}
```

### Field Definitions
```javascript
fieldDefinitions = {
  firstName:      { type: 'text',   label: 'First Name',     group: 'name' },
  lastName:       { type: 'text',   label: 'Last Name',      group: 'name' },
  email_business: { type: 'email',  label: 'Business Email',  group: 'email' },
  phone_work:     { type: 'phone',  label: 'Work Phone',      group: 'phone' },
  birthday:       { type: 'date',   label: 'Next Birthday',   group: 'dates' },
  state:          { type: 'state',  label: 'State',            group: 'address' },
  category:       { type: 'select', label: 'Category',         group: 'classification', options: [...] },
  // ... 20+ fields total
}
```

### Core Functions

| Function | Purpose |
|----------|---------|
| `initUpload()` | Set up drag-drop and file input listeners |
| `uploadFile(file)` | Validate type/size, POST to upload.cfm |
| `parseFile()` | POST to parse.cfm, auto-triggers on page load if status=uploaded |
| `loadColumnMappings()` | GET columns.cfm, display mapping UI |
| `confirmMappings()` | POST columns.cfm, transition to reviewing |
| `triggerAutoRecompute()` | For VCF with auto-mapped columns |
| `loadRows()` | GET rows.cfm with filters/pagination |
| `initReviewGrid()` | Set up tabs, search, pagination |
| `updateRowsTable()` | Populate tbody from row data |
| `rowAction(rowId, action)` | POST row_action.cfm |
| `editField(rowId, fieldName)` | Open edit modal |
| `populateEditModal(...)` | Render type-specific widget |
| `saveEdit(rowId, fieldName, newValue)` | Update fact, re-validate |
| `showDupeModal(rowId, candidates)` | Show duplicate resolution modal |
| `previewImport()` | GET finalize.cfm?dry_run=1 |
| `finalizeImport()` | POST finalize.cfm with CSRF token |
| `showAlert(type, message)` | Toast notifications |
| `escapeHtml(text)` | XSS prevention |

### UI Step Progression
The JS manages a 4-step breadcrumb/stepper:
1. **Upload** - file selection
2. **Parse & Map** - column mapping
3. **Review** - grid with tabs and editing
4. **Import** - finalize and summary

---

## 7. Services Layer

### ContactImportV3Service.cfc

Core service for job lifecycle management:

- **Job CRUD:** Create job, get job by ID, get jobs for user
- **Ownership checks:** Ensures userid matches job owner
- **Status transitions:** Validates allowed transitions, prevents invalid state changes
- **Job locking:** `acquireJobLock(action)` for exclusive operations (parse, finalize)
- **Stale lock detection:** Jobs stuck in finalizing/parsing for 10+ minutes get warnings
- **Feature flags:** `isImportV3Enabled(userid)` checks global flag + per-user allowlist

### DuplicateMatcherService.cfc

Duplicate detection engine:

- **`buildUserDupeIndex(userid)`** - Queries all email/phone contact items, builds in-memory maps
- **`findDuplicates(row_facts, index)`** - Scores each row against the index
- **Normalization:** email lowercase/trim, phone digits-only/last-10/strip-leading-1
- **Scoring:** Weighted algorithm (email=70, phone=50, name=30, etc.)
- **Thresholds:** HIGH=70, MEDIUM=40, LOW=25
- **Returns:** Top 5 candidates per row with scores

### ImportV3Logger.cfc

Structured logging:

- **Correlation IDs** for tracing requests through the system
- **Log to `cflog` file="importv3"**
- **Phase timing** tracked in recompute
- **First-failure capture** for error diagnosis

---

## 8. Duplicate Detection

### Index Building (buildUserDupeIndex)

1. Query all Email and Phone `contactitems` for user's active contacts
2. Normalize values:
   - **Email:** lowercase, trimmed
   - **Phone:** digits only, last 10 digits, remove leading 1 (US)
3. Build in-memory maps (O(1) lookup):
   - `email_map: {normalized_email -> [contactid, ...]}`
   - `phone_map: {normalized_phone -> [contactid, ...]}`
4. Limits: max 200k items, 50k contact IDs to prevent memory issues

### Matching (per row)

1. Extract normalized email and phone from `import_v3_facts`
2. Look up in email_map, phone_map
3. Collect all candidate contact IDs
4. Score each candidate:

| Match Type | Points |
|-----------|--------|
| Email exact | +70 |
| Phone exact | +50 |
| Last name match | +30 |
| First name match | +20 |
| Company match | +10 |

5. Sort by score descending
6. Return top 5 candidates (`MAX_CANDIDATES = 5`)
7. If best score >= `THRESHOLD_HIGH` (70): set `matched_contactid`, row status = `dupe`

### Thresholds

| Level | Score | Effect |
|-------|-------|--------|
| HIGH | 70+ | Auto-marked as duplicate |
| MEDIUM | 40-69 | Shown as candidate, user decides |
| LOW | 25-39 | May not be shown |

---

## 9. Validation Rules

### Field-Level (in import_v3_facts)

| Field Type | Validation |
|-----------|------------|
| Email | Regex pattern match, valid format |
| Phone | Numeric after normalization, 7-15 digits |
| Date | Valid date, parseable (YYYY-MM-DD or MM/DD/YYYY) |
| URL | Must start with http:// or https:// |
| Required | Error if blank and field marked required |
| Custom | Uses `validation_regex` from `contact_custom_fields` |
| Max length | Enforced per field type |

### Row-Level (in import_v3_rows)

- `error_count > 0` -> `status = 'problem'` (red, blocks import)
- `dupe_candidates found` -> `status = 'dupe'` (yellow, user decides)
- Otherwise -> `status = 'ready'` (green, can import)

### Error vs Warning

- **Error:** Blocks import (invalid email, missing required field)
- **Warning:** Flagged but doesn't block (blank optional field)

### Validation on Edit

When user edits a field inline:
1. New value validated immediately
2. `validation_code` and `validation_message` updated
3. Row status recalculated
4. Grid updates to show new status

---

## 10. Finalization Process

### Pre-Checks
- CSRF token validation (header, body, or form field)
- Job must be in `reviewing` status
- Acquire exclusive lock (`reviewing -> finalizing`)

### Per-Row Processing

```
FOR EACH row WHERE user_action = 'import_new':
    CHECK: Does import_v3_row_results already have this row_id?
           If yes -> SKIP (idempotency)

    BEGIN TRANSACTION
        1. INSERT into contacts table
        2. FOR EACH import_v3_facts for this row:
           - Write to appropriate contact field
           - INSERT contactitems (email, phone, etc.)
        3. IF relationship_system specified:
           - INSERT into fusystemusers
           - Trigger system enrollment
        4. INSERT import_v3_row_results (action_taken='created', contactid=new_id)
    COMMIT

    UPDATE import_v3_rows: status='imported', created_contactid=new_id, imported_at=NOW()

    ON ERROR:
        ROLLBACK
        INSERT import_v3_row_results (action_taken='failed', error_message=...)
        UPDATE import_v3_rows: status='failed', import_error=message
```

### Post-Finalize
- Update job counters: `imported_rows`, `updated_rows`
- Status: `finalizing -> completed`
- Set `finished_at = NOW()`

### Idempotency Guarantees

1. **File hash UNIQUE index** - same file can't create a new job
2. **row_results UNIQUE on row_id** - double-finalize skips already-processed rows
3. **Per-row transactions** - one failure doesn't affect other rows

---

## 11. UI Components

### Review Grid Table
- Columns: # | Name | Email | Phone | Company | Status | Action
- Status badges with color coding:
  - Ready = green
  - Problem = red
  - Duplicate = yellow
  - Ignored = gray
  - Imported = blue

### Filter Tabs (6)
Each shows badge count:
1. **All** - all rows
2. **Ready** - valid, can import
3. **Problems** - validation errors
4. **Duplicates** - potential matches found
5. **Ignored** - user skipped
6. **Imported** - already created

### Stats Bar
4 stat cards at top: Total, Ready, Problems, Duplicates (with color backgrounds)

### Edit Modal
Type-specific widgets:
- Text/Email/Phone: text input
- Date: HTML5 date picker
- Select: dropdown (category, contactType, relationship_system, state)
- Textarea: for notes
- Fields grouped by category (name, email, phone, address, dates, web, other)

### Duplicate Resolution Modal
- Top 5 candidate matches with scores
- Side-by-side comparison: import fields vs. existing contact
- Action buttons: Skip This Row, Update Existing, Import as New

### Stepper/Breadcrumb
4-step visual progress: Upload -> Parse & Map -> Review -> Import

### Pagination
- "Showing X-Y of Z" label
- Previous/Next buttons
- Page numbers
- Default 50 per page, max 200

---

## 12. Patterns and Standards

### Response Envelope (all endpoints)

```json
// Success
{
  "success": true,
  "message": "optional message",
  "data": { "...actual data...", "debug": ["step1", "step2", "..."] }
}

// Error
{
  "success": false,
  "code": "ERROR_CODE",
  "message": "Human-readable error",
  "data": { "debug": ["step1", "step2_failed"], "last_step": "..." }
}
```

### Debug Breadcrumbs
- String array appended at each checkpoint: `["start", "auth_ok", "job_loaded", "done"]`
- No PII in breadcrumbs
- Returned in every response for diagnostics

### SQL Standards
- All user input via `cfqueryparam` with `cfsqltype`
- Ownership checks in WHERE clause (not post-query IF)
- Transactions for multi-table writes
- Composite indexes for common query patterns

### CSRF Protection
- Server generates UUID token on page load -> `session.csrf_token`
- Client sends via: (1) `X-CSRF-Token` header, (2) JSON body `csrf_token`, or (3) form field
- All POST endpoints validate

### Feature Flags
- Global: `application.features.importV3Enabled`
- Per-user: `application.features.importV3AllowedUsers` array
- Cache TTL: 60 seconds
- Check: `isImportV3Enabled(userid)` returns boolean

---

## 13. Adaptation Guide for Auditions Import

### What Changes

| Contact Import V3 | Auditions Import | Notes |
|-------------------|-----------------|-------|
| `import_v3_jobs` | `import_auditions_jobs` | Same structure, different entity |
| `import_v3_rows` | `import_auditions_rows` | Same structure |
| `import_v3_facts` | `import_auditions_facts` | Same EAV pattern |
| `import_v3_columns` | `import_auditions_columns` | Same mapping logic |
| `import_v3_row_results` | `import_auditions_row_results` | Same audit trail |
| `import_v3_events` | `import_auditions_events` | Same logging |
| `contacts` (target table) | `events`/auditions tables | Different target schema |
| `contactitems` | Audition-related detail tables | Different detail schema |
| `fieldDefinitions` (JS) | Audition field definitions | Different fields |
| `DuplicateMatcherService` | Audition dupe matcher | Match on audition-specific fields |
| `ContactImportV3Service` | AuditionImportService | Same patterns, different entity |
| `/ajax/importv3/` | `/ajax/import-auditions/` | New endpoint directory |
| `contact-import-v3.js` | `audition-import.js` | Adapted JS controller |
| `contacts-import-v3/index.cfm` | `auditions-import/index.cfm` | New page |

### What Stays the Same

- 4-phase flow: Upload -> Parse & Map -> Review -> Finalize
- EAV fact pattern for per-field validation
- Staging-first design (never write directly to production)
- Per-row transactions on finalize
- Idempotency via row_results UNIQUE index
- File hash dedup
- CSRF protection pattern
- Response envelope format
- Debug breadcrumbs
- Pagination and tab filtering UI
- Edit modal pattern (type-specific widgets)
- Feature flag pattern

### Key Decisions for Auditions Import

1. **Target tables:** Which audition/event tables get written to on finalize?
2. **Field definitions:** What are the canonical audition fields? (casting director, project, role, date, callback, etc.)
3. **Duplicate detection:** What constitutes a duplicate audition? (same project + date? same casting director + role?)
4. **Relationship system enrollment:** Does importing an audition trigger any follow-up workflows?
5. **File formats:** Same CSV/XLS/XLSX/VCF support, or different formats for audition data?
6. **Column auto-mapping:** What are the expected header names for audition data?
