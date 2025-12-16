# Contact Importer V2 - Implementation Plan

## Overview

This plan describes the implementation of a failsafe contact importer for TAO that:
- Accepts CSV, XLS, XLSX files
- Never hard-crashes on malformed data
- Uses two-phase commit (stage then finalize)
- Provides review grid with inline editing
- Detects and surfaces duplicates before commit
- Maintains idempotency on retry

---

## Phase 1: Database Schema

### New Tables

#### import_jobs
Primary tracking table for import batches.

```sql
CREATE TABLE import_jobs (
    job_id INT IDENTITY(1,1) PRIMARY KEY,
    userid INT NOT NULL,
    source_filename VARCHAR(255) NOT NULL,
    file_type VARCHAR(10) NOT NULL, -- csv, xls, xlsx
    file_size BIGINT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
        -- pending, parsing, parsed, reviewing, importing, completed, failed
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME NOT NULL DEFAULT GETDATE(),
    started_at DATETIME,
    finished_at DATETIME,
    total_rows INT DEFAULT 0,
    parsed_rows INT DEFAULT 0,
    valid_rows INT DEFAULT 0,
    problem_rows INT DEFAULT 0,
    dupe_rows INT DEFAULT 0,
    imported_rows INT DEFAULT 0,
    options_json TEXT, -- delimiter, encoding, sheet name, etc.
    CONSTRAINT FK_import_jobs_userid FOREIGN KEY (userid) REFERENCES taousers(userid)
);

CREATE INDEX IX_import_jobs_userid_status ON import_jobs(userid, status);
CREATE INDEX IX_import_jobs_created ON import_jobs(created_at DESC);
```

#### import_job_columns
Stores column mapping decisions per job.

```sql
CREATE TABLE import_job_columns (
    column_id INT IDENTITY(1,1) PRIMARY KEY,
    job_id INT NOT NULL,
    source_column_index INT NOT NULL,
    source_column_name VARCHAR(255),
    normalized_field VARCHAR(50), -- mapped TAO field name
    confidence DECIMAL(3,2), -- auto-map confidence 0.00-1.00
    user_confirmed BIT DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_import_job_columns_job FOREIGN KEY (job_id) REFERENCES import_jobs(job_id) ON DELETE CASCADE
);

CREATE INDEX IX_import_job_columns_job ON import_job_columns(job_id);
```

#### import_job_rows
Individual row data with validation and duplicate info.

```sql
CREATE TABLE import_job_rows (
    row_id INT IDENTITY(1,1) PRIMARY KEY,
    job_id INT NOT NULL,
    row_num INT NOT NULL, -- 1-based row number from source file
    raw_json TEXT NOT NULL, -- exact cell values as strings, JSON object
    normalized_json TEXT, -- mapped fields with normalized types, JSON object
    validation_json TEXT, -- field errors/warnings, JSON object
    dupe_json TEXT, -- candidate matches with reasons, JSON array
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
        -- pending, ready, problem, dupe, ignored, imported
    matched_contactid INT, -- if dupe, the matched contact
    created_contactid INT, -- after import, the new/updated contactid
    user_action VARCHAR(20), -- import_new, skip, update_existing, merge
    updated_at DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_import_job_rows_job FOREIGN KEY (job_id) REFERENCES import_jobs(job_id) ON DELETE CASCADE
);

CREATE INDEX IX_import_job_rows_job_status ON import_job_rows(job_id, status);
CREATE INDEX IX_import_job_rows_job_rownum ON import_job_rows(job_id, row_num);
```

#### import_job_events
Audit trail for import operations.

```sql
CREATE TABLE import_job_events (
    event_id INT IDENTITY(1,1) PRIMARY KEY,
    job_id INT NOT NULL,
    event_type VARCHAR(50) NOT NULL,
        -- created, parsing_started, parsing_completed, parsing_failed,
        -- row_updated, columns_mapped, import_started, import_completed,
        -- row_imported, row_skipped, row_failed
    event_detail TEXT, -- JSON with specifics
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_import_job_events_job FOREIGN KEY (job_id) REFERENCES import_jobs(job_id) ON DELETE CASCADE
);

CREATE INDEX IX_import_job_events_job ON import_job_events(job_id);
```

### Canonical Field List

| Internal Field | Display Name | Category | Type | Required |
|----------------|--------------|----------|------|----------|
| firstName | First Name | contact | string | yes |
| lastName | Last Name | contact | string | no |
| contactFullName | Full Name | contact | string | computed |
| email_business | Business Email | email | email | no |
| email_personal | Personal Email | email | email | no |
| phone_work | Work Phone | phone | phone | no |
| phone_mobile | Mobile Phone | phone | phone | no |
| phone_home | Home Phone | phone | phone | no |
| company | Company | company | string | no |
| department | Department | company | string | no |
| jobTitle | Job Title | company | string | no |
| address_street | Street Address | address | string | no |
| address_extended | Address Line 2 | address | string | no |
| address_city | City | address | string | no |
| address_state | State/Province | address | string | no |
| address_zip | Postal Code | address | string | no |
| address_country | Country | address | string | no |
| tag1 | Tag 1 | tag | string | no |
| tag2 | Tag 2 | tag | string | no |
| tag3 | Tag 3 | tag | string | no |
| website | Website | url | url | no |
| birthday | Birthday | contact | date | no |
| meetingDate | Meeting Date | contact | date | no |
| meetingLocation | Meeting Location | contact | string | no |
| notes | Notes | note | text | no |

---

## Phase 2: Backend Service Architecture

### ContactImportV2Service.cfc

Main service component with these public methods:

```
// Job Management
createJob(userid, filename, filetype, options) -> job_id
getJob(job_id) -> job struct
getJobsByUser(userid, status_filter) -> query
updateJobStatus(job_id, status) -> void
deleteJob(job_id) -> void

// File Parsing
parseFile(job_id, file_path) -> boolean (success)
getParseProgress(job_id) -> struct {parsed, total, status}

// Column Mapping
getColumnMapping(job_id) -> query
autoMapColumns(job_id) -> array of mappings
confirmColumnMapping(job_id, mappings_array) -> void

// Row Operations
getRows(job_id, filters, pagination) -> struct {rows, total}
updateRow(row_id, normalized_json) -> validation_json
revalidateRow(row_id) -> validation_json
setRowAction(row_id, action) -> void
bulkSetAction(job_id, row_ids, action) -> void

// Duplicate Detection
detectDuplicates(job_id) -> void (populates dupe_json)
getDuplicateCandidates(row_id) -> array

// Import Execution
validateForImport(job_id) -> struct {can_import, issues}
executeImport(job_id, row_ids) -> struct {imported, failed, skipped}
getImportAudit(job_id) -> query
```

### FileParserService.cfc

Handles file reading with tolerance:

```
// Detection
detectFileType(file_path) -> string (csv, xls, xlsx)
detectEncoding(file_path) -> string (utf-8, etc.)
detectDelimiter(file_path) -> string (comma, tab, etc.)

// CSV Parsing
parseCSV(file_path, options) -> struct {headers, rows, errors}
// Options: encoding, delimiter, has_header, quote_char

// Excel Parsing
parseExcel(file_path, options) -> struct {headers, rows, errors}
// Options: sheet_name, sheet_index, has_header

// Streaming for large files
streamParse(file_path, callback) -> void
```

### ValidationService.cfc

Field-level validation:

```
// Individual Field Validators
validateEmail(value) -> struct {valid, normalized, error}
validatePhone(value) -> struct {valid, normalized, error}
validateDate(value, formats) -> struct {valid, normalized, error}
validateRequired(value, field_name) -> struct {valid, error}
validateLength(value, max_length) -> struct {valid, error}
validateEnum(value, allowed_values) -> struct {valid, error}

// Row-level Validation
validateRow(normalized_json, field_rules) -> validation_json
```

### DuplicateMatcherService.cfc

Duplicate detection logic:

```
// Matching
findCandidates(userid, email, phone, name, company) -> array of candidates
scoreMatch(row_data, candidate_contact) -> struct {score, reasons}

// Configuration
getMatchingRules() -> array of rules
setMatchingThreshold(threshold) -> void
```

---

## Phase 3: AJAX Endpoints

All endpoints in `/ajax/import/` directory:

### POST /ajax/import/upload.cfm
Upload file and create job.

**Request:** multipart/form-data with file
**Response:**
```json
{
  "success": true,
  "job_id": 123,
  "filename": "contacts.xlsx",
  "file_type": "xlsx"
}
```

### POST /ajax/import/parse.cfm
Start parsing uploaded file.

**Request:**
```json
{
  "job_id": 123,
  "options": {
    "delimiter": ",",
    "encoding": "utf-8",
    "sheet_index": 0
  }
}
```

### GET /ajax/import/status.cfm
Get job status and progress.

**Request:** ?job_id=123
**Response:**
```json
{
  "status": "parsing",
  "total_rows": 500,
  "parsed_rows": 250,
  "valid_rows": 200,
  "problem_rows": 30,
  "dupe_rows": 20
}
```

### GET /ajax/import/columns.cfm
Get column mapping with auto-suggestions.

**Request:** ?job_id=123
**Response:**
```json
{
  "columns": [
    {
      "source_index": 0,
      "source_name": "First Name",
      "suggested_field": "firstName",
      "confidence": 0.95,
      "confirmed": false
    }
  ],
  "available_fields": [...]
}
```

### POST /ajax/import/map-columns.cfm
Confirm column mapping.

**Request:**
```json
{
  "job_id": 123,
  "mappings": [
    {"source_index": 0, "field": "firstName"},
    {"source_index": 1, "field": "lastName"}
  ]
}
```

### GET /ajax/import/rows.cfm
Get rows with filtering and pagination.

**Request:** ?job_id=123&status=problem&page=1&limit=50
**Response:**
```json
{
  "rows": [
    {
      "row_id": 456,
      "row_num": 5,
      "status": "problem",
      "data": {
        "firstName": "John",
        "lastName": "Doe",
        "email_business": "invalid-email"
      },
      "validation": {
        "email_business": {"valid": false, "error": "Invalid email format"}
      },
      "duplicates": null
    }
  ],
  "total": 30,
  "page": 1,
  "pages": 1
}
```

### POST /ajax/import/update-row.cfm
Update row data and revalidate.

**Request:**
```json
{
  "row_id": 456,
  "data": {
    "email_business": "john@example.com"
  }
}
```
**Response:**
```json
{
  "success": true,
  "new_status": "ready",
  "validation": {}
}
```

### POST /ajax/import/row-action.cfm
Set user action for row.

**Request:**
```json
{
  "row_id": 456,
  "action": "import_new"
}
```

### POST /ajax/import/bulk-action.cfm
Set action for multiple rows.

**Request:**
```json
{
  "job_id": 123,
  "row_ids": [456, 457, 458],
  "action": "ignore"
}
```

### POST /ajax/import/finalize.cfm
Execute import for approved rows.

**Request:**
```json
{
  "job_id": 123
}
```
**Response:**
```json
{
  "success": true,
  "imported": 45,
  "skipped": 5,
  "failed": 0,
  "contacts": [...]
}
```

---

## Phase 4: UI Components

### Main Import Page
`/include/import-contacts-v2.cfm`

Structure:
```
+------------------------------------------+
| Contact Import                           |
+------------------------------------------+
| Step 1: Upload File                      |
| [Drop zone or file picker]               |
| Supported: CSV, XLS, XLSX                |
+------------------------------------------+
| Step 2: Map Columns (if needed)          |
| [Column mapping grid]                    |
+------------------------------------------+
| Step 3: Review & Fix                     |
| [Tab bar: All | Ready | Problems | Dupes]|
| [Review grid with inline editing]        |
| [Bulk actions bar]                       |
+------------------------------------------+
| Step 4: Import                           |
| [Summary + Finalize button]              |
+------------------------------------------+
```

### Review Grid Features

#### Filters/Tabs
- **All**: All rows
- **Ready (N)**: Rows ready to import (status=ready)
- **Problems (N)**: Rows with validation errors (status=problem)
- **Duplicates (N)**: Rows matching existing contacts (status=dupe)
- **Ignored (N)**: Rows marked to skip (status=ignored)
- **Imported (N)**: Already imported rows (status=imported)

#### Row Display
Each row shows:
- Row number from source file
- Key fields: Name, Email, Phone, Company
- Status indicator (icon + color)
- Validation errors per field (red outline + tooltip)
- For dupes: matched contact link + match reason

#### Inline Editing
- Click to edit any field
- Text inputs for strings
- Date picker for date fields
- Dropdown for enumerated fields (country, state)
- Save on blur or Enter
- Auto-revalidate after save

#### Bulk Actions Bar
- Checkbox column for multi-select
- "Select all on page" / "Select all matching filter"
- Actions: Mark as Ignored, Mark as Import, Clear Selection

#### Duplicate Row Expansion
Click to expand duplicate row to see:
- Matched existing contact details
- Field-by-field comparison
- Actions: Import as New, Skip, Update Existing

### Progress Indicators
- Upload progress bar
- Parsing progress with row count
- Import progress with success/fail counts

---

## Phase 5: Parsing Implementation Details

### CSV Parser Rules

1. **BOM Detection**: Check first 3 bytes for UTF-8 BOM (EF BB BF), skip if present
2. **Encoding**: Default UTF-8, detect Windows-1252 if UTF-8 decode fails
3. **Delimiter Detection**: Count commas, tabs, semicolons in first 5 lines
4. **Quoted Fields**: Handle RFC 4180 compliant quoted fields with escaped quotes
5. **Newlines in Quotes**: Preserve newlines inside quoted strings
6. **Trailing Columns**: Pad short rows with empty strings
7. **Header Row**: First row treated as headers by default

### Excel Parser Rules

1. **Date Detection**: Recognize Excel serial date format, convert to ISO date
2. **Number Preservation**: Preserve leading zeros by reading as text
3. **Long Numbers**: Prevent scientific notation by reading as text
4. **Formula Results**: Read computed value, not formula
5. **Sheet Selection**: Default to first sheet, allow user override
6. **Merged Cells**: Expand merged cells to individual cells

### Error Capture

Each parsing error stored as:
```json
{
  "row_num": 5,
  "column_index": 3,
  "column_name": "Birthday",
  "error_type": "parse_error",
  "error_message": "Could not parse date from '13/45/2024'",
  "raw_value": "13/45/2024"
}
```

---

## Phase 6: Validation Rules

### Email Validation
```
1. Trim whitespace
2. Lowercase
3. Check format: /^[^\s@]+@[^\s@]+\.[^\s@]+$/
4. Check max length: 254 chars
5. Return: {valid, normalized, error}
```

### Phone Validation
```
1. Extract digits and plus sign
2. Preserve leading plus for international
3. Accept: 7-15 digits
4. Normalize US: (XXX) XXX-XXXX for 10 digits
5. Return: {valid, normalized, error}
```

### Date Validation
```
1. Try parse multiple formats:
   - ISO: YYYY-MM-DD
   - US: MM/DD/YYYY, M/D/YYYY
   - EU: DD/MM/YYYY, D/M/YYYY
   - US Long: Month D, YYYY
2. Check valid date (not 13/45/2024)
3. Check reasonable range (1900-2100)
4. Return: {valid, normalized (ISO), error}
```

### Required Fields
```
- firstName OR contactFullName required
- If only lastName provided, mark warning not error
```

### Length Limits
```
- Names: 255 chars
- Emails: 254 chars
- Phones: 50 chars
- Tags: 40 chars (hard limit, truncate with warning)
- Notes: 65535 chars
- Address fields: 255 chars
```

---

## Phase 7: Duplicate Detection

### Matching Keys

#### Hard Match (High Confidence)
- Email exact match (normalized, case-insensitive)
- Phone exact match (digits only)

#### Soft Match (Medium Confidence)
- Full name exact match (case-insensitive)
- First name + Last name + Company
- First name + Last name + City + State

### Scoring Algorithm
```
score = 0

if email matches existing contact:
    score += 50
    reason.add("Email matches")

if phone matches existing contact:
    score += 40
    reason.add("Phone matches")

if fullname exact match:
    score += 30
    reason.add("Name matches exactly")

if firstname + lastname + company match:
    score += 25
    reason.add("Name and company match")

if firstname + lastname + city match:
    score += 15
    reason.add("Name and location match")

// Return top 3 candidates with score >= 25
```

### Duplicate JSON Structure
```json
{
  "candidates": [
    {
      "contactid": 123,
      "contactFullName": "John Doe",
      "score": 90,
      "reasons": ["Email matches", "Phone matches"],
      "matched_fields": {
        "email": "john@example.com",
        "phone": "(555) 123-4567"
      }
    }
  ],
  "best_match_score": 90
}
```

---

## Phase 8: Finalize Import

### Pre-Import Validation
```
1. Check job status is 'reviewing'
2. Count rows with status 'ready' or explicit import action
3. Verify no rows have blocking errors
4. Return validation result
```

### Import Execution
```
BEGIN TRANSACTION

FOR each row with status='ready' OR user_action='import_new':
    1. Create contact via ContactService.create()
    2. Create contactitems for emails, phones, company, address, tags, url
    3. Create note if notes field populated
    4. Update import_job_rows.created_contactid
    5. Update import_job_rows.status = 'imported'
    6. Log import_job_events

FOR each row with user_action='update_existing':
    1. Update contactdetails via ContactService.update()
    2. Merge contactitems (add new, don't duplicate)
    3. Update import_job_rows.created_contactid = matched_contactid
    4. Update import_job_rows.status = 'imported'
    5. Log import_job_events

UPDATE import_jobs SET status='completed', finished_at=GETDATE()

COMMIT TRANSACTION
```

### Idempotency
- Check row status before processing; skip if already 'imported'
- Store created_contactid to prevent double-insert
- Use job_id + row_num as composite unique key

### Audit Trail
Each import logs to import_job_events:
```json
{
  "event_type": "row_imported",
  "event_detail": {
    "row_id": 456,
    "row_num": 5,
    "contactid": 789,
    "action": "created_new"
  }
}
```

---

## Phase 9: File Deliverables

### Database Migration
```
/database/migrations/V2_0__contact_import_staging_tables.sql
```

### Services
```
/services/ContactImportV2Service.cfc
/services/FileParserService.cfc
/services/ValidationService.cfc
/services/DuplicateMatcherService.cfc
```

### AJAX Endpoints
```
/ajax/import/upload.cfm
/ajax/import/parse.cfm
/ajax/import/status.cfm
/ajax/import/columns.cfm
/ajax/import/map-columns.cfm
/ajax/import/rows.cfm
/ajax/import/update-row.cfm
/ajax/import/row-action.cfm
/ajax/import/bulk-action.cfm
/ajax/import/finalize.cfm
```

### UI Pages
```
/include/import-contacts-v2.cfm
/include/import-contacts-v2-grid.cfm
/include/import-contacts-v2-mapping.cfm
```

### CSS/JS
```
/assets/css/contact-import-v2.css
/assets/js/contact-import-v2.js
```

### Tests
```
/tests/services/ContactImportV2ServiceTest.cfc
/tests/services/FileParserServiceTest.cfc
/tests/services/ValidationServiceTest.cfc
/tests/services/DuplicateMatcherServiceTest.cfc
/tests/fixtures/malformed-csv/
/tests/fixtures/malformed-excel/
```

---

## Implementation Order

1. **Database Migration** - Create staging tables
2. **FileParserService** - CSV and Excel parsing with tolerance
3. **ValidationService** - Field validators
4. **DuplicateMatcherService** - Candidate detection
5. **ContactImportV2Service** - Main orchestration service
6. **AJAX Endpoints** - API layer
7. **UI Components** - Upload, mapping, review grid
8. **Integration Tests** - End-to-end flows
9. **Documentation** - User guide

---

## Acceptance Criteria Checklist

- [ ] Uploading malformed CSV never crashes; errors captured per row/field
- [ ] Uploading malformed XLS/XLSX never crashes; errors captured per row/field
- [ ] CSV with BOM, quoted newlines, mixed delimiters handled correctly
- [ ] Excel date serials converted to dates correctly
- [ ] Excel leading zeros preserved
- [ ] Grid shows problem rows with per-field error messages
- [ ] Grid allows inline editing with appropriate widgets
- [ ] Date fields show date picker
- [ ] Enum fields show dropdown
- [ ] Duplicates flagged with match reasons before import
- [ ] User can choose: import new, skip, update existing for dupes
- [ ] Finalize imports only approved rows
- [ ] Double-click finalize does not double-insert
- [ ] Import does not break relationship system workflows
- [ ] Audit trail records all import operations
- [ ] Large files (10k+ rows) handled via streaming
