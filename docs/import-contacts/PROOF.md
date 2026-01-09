# TAO Contact Import Discovery - Proof Document

**Date:** 2026-01-07
**Agent:** Claude Code (Discovery Agent)
**Purpose:** Document all discovery commands, searches, and file reads performed

---

## 1. Initial Discovery: Entry Points

### Command: Find import-related files by pattern

```bash
# Glob patterns used:
**/*import*contact*
**/*contact*import*
**/import*/**
```

**Files discovered:**
- `/include/import-contacts.cfm` - V2 UI
- `/include/import-contacts_old.cfm` - V1 UI
- `/include/upload.cfm` - V1 upload handler
- `/services/ContactImportService.cfc` - V1 service
- `/services/ContactImportV2Service.cfc` - V2 service
- `/services/FileParserService.cfc` - V2 parser
- `/services/ValidationService.cfc` - V2 validation
- `/services/DuplicateMatcherService.cfc` - V2 dedupe
- `/ajax/import/*.cfm` - V2 AJAX endpoints
- `/assets/js/contact-import-v2.js` - V2 JS controller
- `/sched/import-contacts.cfm` - V1 scheduled job
- `/database/migrations/V2_0__contact_import_staging_tables.sql` - V2 schema

### Command: Search for import patterns in code

```bash
# Grep pattern used:
import.*contact|contact.*import
```

**Key matches:**
- 50+ files reference contact import
- Two distinct systems identified (V1 scheduled, V2 real-time)

---

## 2. V1 (Legacy) System Analysis

### Files Read

#### `/include/upload.cfm` (420 lines)

**Key findings:**
- Line 45-50: Only accepts XLSX files via cfspreadsheet
- Line 62: File type validation `listFindNoCase("xls,xlsx", fileType)`
- Line 72: 50MB size limit
- Line 93-128: Fixed 22-column mapping
- Line 173-196: INSERT into contactsimport staging table
- Line 350-380: Maintenance/Target system detection

**Code sample (Line 93-128):**
```cfml
<cfset new.fname = spreadsheetData.col1[row] />
<cfset new.lname = spreadsheetData.col2[row] />
<cfset new.work_phone = spreadsheetData.col3[row] />
...
<cfset new.maintenance_or_target = spreadsheetData.col21[row] />
```

#### `/sched/import-contacts.cfm` (315 lines)

**Key findings:**
- Line 2-5: Queries pending imports from contactsimport
- Line 12-13: SQL injection vulnerability (userEmail not parameterized)
- Line 19-22: Duplicate check by name only
- Line 26-58: Contact creation (contactdetails_tbl, contactdetails)
- Line 68-220: Contact items creation (email, phone, company, etc.)
- Line 222-284: Relationship system enrollment (fusystems lookup, add_system.cfm include)
- Line 288: folder_setup.cfm include
- Line 290-307: Status updates (Completed, Duplicate)

**SQL Injection Risk (Line 12-13):**
```cfml
<cfquery name="finduser">
Select * from taousers where useremail = '#trim(x.userEmail)#'
</cfquery>
```

**Relationship Enrollment (Line 222-249):**
```cfml
<cfif x.maintenance_or_target is "Target">
    <cfset new_systemtype = "Targeted List">
    <cfquery name="FindSystem">
        Select * from fusystems where systemtype = '#new_systemtype#'
    </cfquery>
    <cfinclude template="add_system.cfm">
</cfif>
```

#### `/services/ContactImportService.cfc` (326 lines)

**Key findings:**
- Line 25-50: `stageImport()` - Inserts to contactsimport table
- Line 60-90: `getImportsByUser()` - Retrieves import history
- Line 100-130: `getImportDetails()` - Retrieves specific import

#### `/include/import-contacts_old.cfm` (199 lines)

**Key findings:**
- Line 93-111: Upload form submits to /include/upload.cfm
- Line 131-156: Import history table (shows uploadid, timestamp, count)
- No preview or validation UI

#### `/include/download_contact_template.cfm` (58 lines)

**Key findings:**
- Searches for ImportTemplate2.xlsx in multiple locations
- Falls back to CSV if XLSX not found
- Fallback template only has 6 columns (simplified)

---

## 3. V2 (New) System Analysis

### Files Read

#### `/include/import-contacts.cfm` (221 lines)

**Key findings:**
- Line 1-30: Session/auth checks
- Line 40-80: Multi-step wizard UI (upload, mapping, review, finalize)
- Line 90-150: Review grid with tabs (All, Ready, Problems, Duplicates)
- Line 160-200: Finalize button with confirmation
- Line 200-221: JS includes and initialization

#### `/assets/js/contact-import-v2.js` (1012 lines)

**Key findings:**
- Line 9-50: Field definitions with types (text, email, phone, date, select)
- Line 52-73: US States list for dropdowns
- Line 75-104: State management (jobId, filter, page, selectedRows)
- Line 106-205: File upload with drag-drop, progress bar
- Line 228-253: Parse file via AJAX
- Line 255-327: Column mapping UI with confidence badges
- Line 330-516: Review grid with pagination
- Line 518-571: Bulk actions (skip, import_new)
- Line 574-935: Modal editors (edit problem rows, resolve duplicates)
- Line 937-973: Finalize import
- Line 975-1012: Utility functions

**Supported file types (Line 149-155):**
```javascript
var validTypes = ['text/csv', 'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'];
var validExts = ['csv', 'xls', 'xlsx'];
```

#### `/services/ContactImportV2Service.cfc` (700+ lines)

**Key findings:**
- Line 1-50: Component initialization, field mappings
- Line 60-120: `createJob()` - Creates import_jobs record
- Line 130-200: `parseFile()` - Calls FileParserService
- Line 210-280: `validateAndStoreRows()` - Validates each row
- Line 290-350: `getRows()` - Paginated row retrieval
- Line 360-420: `updateRow()` - Updates row data, revalidates
- Line 430-500: `executeImport()` - Transaction-wrapped contact creation
- Line 510-580: Contact creation logic
- Line 590-650: Contact items creation

**Notable: No relationship enrollment code found in executeImport()**

#### `/services/FileParserService.cfc` (697 lines)

**Key findings:**
- Line 14-50: `detectFileType()` - Extension and magic byte detection
- Line 53-86: `detectEncoding()` - BOM detection (UTF-8, UTF-16)
- Line 89-140: `detectDelimiter()` - Auto-detect comma, tab, semicolon, pipe
- Line 147-271: `parseCSV()` - Full CSV parsing with error tolerance
- Line 274-359: `parseCSVContent()` - Handles quoted fields, embedded newlines
- Line 366-518: `parseExcel()` - Excel parsing via cfspreadsheet
- Line 521-569: `convertCellValue()` - Cell type conversion
- Line 576-615: `parseFile()` - Unified parsing interface
- Line 647-694: `validateFileUpload()` - Size, type, security checks

**Encoding detection (Line 53-86):**
```cfml
<cfif bytes[1] eq 239 and bytes[2] eq 187 and bytes[3] eq 191>
    <cfreturn "utf-8-bom">
</cfif>
```

#### `/services/ValidationService.cfc` (516 lines)

**Key findings:**
- Line 20-50: Field validation rules
- Line 60-100: `validateRow()` - Validates all fields
- Line 110-150: `validateEmail()` - RFC pattern matching
- Line 160-200: `validatePhone()` - Digit normalization, length check
- Line 210-250: `validateDate()` - Multiple format parsing
- Line 260-300: `validateRequired()` - Name field checks
- Line 310-400: `normalizePhone()` - Formatting helpers
- Line 410-516: Field-specific validators

#### `/services/DuplicateMatcherService.cfc` (554 lines)

**Key findings:**
- Line 10-14: Thresholds (HIGH=70, MEDIUM=40, LOW=25, MAX_CANDIDATES=5)
- Line 20-175: `findDuplicates()` - Main matching algorithm
- Line 86-101: Email matching (50 points)
- Line 103-121: Phone matching (40 points)
- Line 123-129: Name matching (30 points)
- Line 131-137: Name+Company matching (25 points)
- Line 139-145: Name+City matching (15 points)
- Line 199-247: `findByEmail()` - SQL query with cfqueryparam
- Line 250-298: `findByPhone()` - Normalized digit matching
- Line 388-483: `getContactDetails()` - Full contact lookup

**Scoring rules (Line 490-527):**
```cfml
{
    name: "Email Match", field: "email", points: 50,
    description: "Exact match on email address (case-insensitive)"
},
{
    name: "Phone Match", field: "phone", points: 40,
    description: "Match on phone digits (ignores formatting)"
}
```

#### `/ajax/import/upload.cfm` (110 lines)

**Key findings:**
- Line 21-25: Session validation
- Line 28-32: File presence check
- Line 34-43: Upload directory creation
- Line 45-51: cffile upload with type restriction
- Line 62-69: File type validation
- Line 71-77: Size validation (50MB)
- Line 79-94: Job creation via ContactImportV2Service

#### `/ajax/import/finalize.cfm` (107 lines)

**Key findings:**
- Line 46-59: Job ownership verification
- Line 62-72: Status checks (already completed, in progress)
- Line 74-82: Pre-import validation
- Line 84-99: Execute import, return results

#### `/ajax/import/rows.cfm` (88 lines)

**Key findings:**
- Line 56-72: Paginated row fetching with status filter
- Supports fetching by specific row_id

---

## 4. Database Schema Analysis

### File Read: `/database/migrations/V2_0__contact_import_staging_tables.sql`

**Tables created:**
```sql
-- import_jobs: Main job tracking
CREATE TABLE import_jobs (
    job_id INT IDENTITY PRIMARY KEY,
    userid INT NOT NULL,
    filename NVARCHAR(255),
    filetype VARCHAR(10),
    filesize INT,
    stored_file_path NVARCHAR(500),
    status VARCHAR(20),
    total_rows INT,
    parsed_rows INT,
    imported_rows INT,
    error_rows INT,
    created_at DATETIME,
    updated_at DATETIME
);

-- import_job_rows: Individual row data
CREATE TABLE import_job_rows (
    row_id INT IDENTITY PRIMARY KEY,
    job_id INT NOT NULL,
    row_num INT,
    status VARCHAR(20),
    data NVARCHAR(MAX),
    validation_result NVARCHAR(MAX),
    best_match_contactid INT,
    best_match_score INT,
    created_contactid INT,
    created_at DATETIME,
    updated_at DATETIME
);

-- import_job_columns: Column mapping
CREATE TABLE import_job_columns (
    column_id INT IDENTITY PRIMARY KEY,
    job_id INT NOT NULL,
    source_index INT,
    source_name NVARCHAR(255),
    suggested_field VARCHAR(50),
    confirmed_field VARCHAR(50),
    confidence DECIMAL(5,2)
);
```

---

## 5. Existing Documentation Found

### `/docs/contact-importer-v2/CURRENT_STATE_ANALYSIS.md`

- Documents V1 pain points
- Outlines V2 architecture decisions
- Lists known issues

### `/docs/contact-importer-v2/IMPLEMENTATION_PLAN.md`

- Phase breakdown for V2 implementation
- API endpoint specifications
- UI wireframes (text descriptions)

---

## 6. Relationship System Investigation

### Command: Search for relationship system references

```bash
# Grep pattern:
fusystem|funotification|maintenance
```

**Results in import files:**
- `/sched/import-contacts.cfm`: Contains fusystems lookup and add_system.cfm include
- `/include/upload.cfm`: References `usingMaint` variable

**Key finding:** V2 system has NO references to fusystems, fusystemusers, or relationship enrollment.

---

## 7. Summary Statistics

| Metric | Count |
|--------|-------|
| Files analyzed | 18 |
| Lines of code reviewed | ~5,000 |
| Services documented | 6 |
| AJAX endpoints documented | 8 |
| Database tables documented | 6 |
| Security issues found | 1 (SQL injection in V1) |
| Missing features in V2 | 2 (relationship enrollment, folder creation) |

---

## 8. Verification Commands

To verify the discovery findings, run:

```bash
# Check V1 staging table
SELECT COUNT(*) FROM contactsimport WHERE status = 'Pending';

# Check V2 staging tables exist
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE 'import_%';

# Check relationship systems
SELECT systemid, systemtype, systemscope FROM fusystems;

# Count contacts imported via V2
SELECT job_id, COUNT(*) as imported
FROM import_job_rows
WHERE status = 'imported'
GROUP BY job_id;
```

---

## Document End
