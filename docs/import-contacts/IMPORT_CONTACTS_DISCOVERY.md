# TAO Contacts Import Discovery

**Document Version:** 1.0
**Date:** 2026-01-07
**Author:** Claude Code (Discovery Agent)

---

## Executive Summary

TAO has **two distinct contact import systems**:

1. **V1 (Legacy)**: A scheduled job-based system with strict template requirements, weak duplicate detection, and relationship system integration (Target/Maintenance workflows).

2. **V2 (New)**: A modern AJAX-based system with column mapping, two-phase commit, robust duplicate detection, but **missing** relationship system integration.

**Critical Finding:** V2 is more robust for data integrity but does not support the Target/Maintenance workflow that enrolls contacts into follow-up systems. Migrating to V2-only would break an important user workflow.

---

## A. What Exists Today (As-Built)

### A.1 System Overview

```
+---------------------------+        +---------------------------+
|     V1 (LEGACY)           |        |     V2 (NEW)              |
+---------------------------+        +---------------------------+
| Entry: upload.cfm         |        | Entry: import-contacts.cfm|
| Template: Fixed 22 cols   |        | Template: Flexible mapping|
| Format: XLSX only         |        | Format: CSV, XLS, XLSX    |
| Staging: contactsimport   |        | Staging: import_job_rows  |
| Processing: Scheduled job |        | Processing: Real-time AJAX|
| Dedupe: Name-only         |        | Dedupe: Multi-field scored|
| Relationship: YES         |        | Relationship: NO          |
+---------------------------+        +---------------------------+
```

### A.2 V1 (Legacy) System

#### Entry Points

| Component | Path | Purpose |
|-----------|------|---------|
| UI Page | `/include/import-contacts_old.cfm` | Upload form, import history |
| Upload Handler | `/include/upload.cfm:1-420` | File validation, staging table insert |
| Scheduled Job | `/sched/import-contacts.cfm:1-315` | Process pending imports |
| Template Download | `/include/download_contact_template.cfm:1-58` | Download XLSX template |
| Service | `/services/ContactImportService.cfc:1-326` | Staging table operations |

#### File Upload Flow (V1)

```
[User uploads XLSX]
       |
       v
/include/upload.cfm
       |
       +-- Validates: XLSX only, 50MB max
       |
       +-- cfspreadsheet: Read Excel file
       |
       +-- Validates: Exactly 22 columns in exact order
       |
       +-- INSERT INTO contactsimport (status='Pending')
       |
       v
[Scheduled Job: /sched/import-contacts.cfm]
       |
       +-- SELECT * FROM contactsimport WHERE status='Pending'
       |
       +-- For each row:
       |      +-- Find user by email
       |      +-- Check duplicate by contactFullName
       |      +-- INSERT INTO contactdetails_tbl
       |      +-- UPDATE contactdetails (meeting info, birthday)
       |      +-- INSERT INTO contactitems (email, phone, company, address, tag)
       |      +-- IF maintenance_or_target:
       |      |     +-- Find fusystem by systemtype/scope
       |      |     +-- cfinclude add_system.cfm (enroll in relationship system)
       |      +-- cfinclude folder_setup.cfm (create contact folders)
       |      +-- UPDATE contactsimport SET status='Completed'
       v
[Contact created with relationship enrollment]
```

#### Supported Format (V1)

**XLSX Only** - No CSV support

**Fixed 22-Column Template** (exact order required):

| Col | Field | Notes |
|-----|-------|-------|
| 1 | First Name | Required |
| 2 | Last Name | Required |
| 3 | Work Phone | |
| 4 | Mobile Phone | |
| 5 | Home Phone | |
| 6 | Business Email | |
| 7 | Personal Email | |
| 8 | Company | |
| 9 | Tag | Single tag only |
| 10 | Address | Street address |
| 11 | Address Second | Unit/Suite |
| 12 | City | |
| 13 | State | |
| 14 | Country | |
| 15 | Zip | |
| 16 | Website | |
| 17 | Meeting Location | |
| 18 | Meeting Date | |
| 19 | Birthday Month | Numeric 1-12 |
| 20 | Birthday Day | Numeric 1-31 |
| 21 | Maintenance or Target | "Maintenance" or "Target" |
| 22 | (Reserved) | Empty column |

**Code Reference:** `/include/upload.cfm:93-128` defines column mappings.

#### Validation (V1)

| Rule | Implementation | Location |
|------|----------------|----------|
| File type | `listFindNoCase("xls,xlsx", fileType)` | upload.cfm:62 |
| File size | 50MB max | upload.cfm:72 |
| Column count | Exactly 22 columns | upload.cfm:93 |
| Name required | `fname is not ""` checked in scheduled job | sched/import-contacts.cfm:24 |

**No field-level validation** - malformed emails, phones accepted as-is.

#### Dedupe Rules (V1)

**Location:** `/sched/import-contacts.cfm:19-22`

```sql
SELECT * FROM contactdetails
WHERE contactfullname = '#trim(x.fname)# #trim(x.lname)#'
  AND contactStatus = 'Active'
  AND userid = #new_userid#
```

**Weakness:** Only matches on exact full name. No email/phone matching.

#### Database Writes (V1)

**Tables touched:**

| Table | Operation | Location |
|-------|-----------|----------|
| contactsimport | INSERT (staging) | upload.cfm:173-196 |
| contactsimport | UPDATE status | sched/import-contacts.cfm:297-307 |
| contactdetails_tbl | INSERT | sched/import-contacts.cfm:26-29 |
| contactdetails | UPDATE | sched/import-contacts.cfm:34-58 |
| contactitems | INSERT (multiple) | sched/import-contacts.cfm:68-220 |
| fusystems | SELECT | sched/import-contacts.cfm:239-242, 271-274 |
| fusystemusers | INSERT (via add_system.cfm) | sched/import-contacts.cfm:248, 280 |

**No transaction wrapping** - partial failures possible.

---

### A.3 V2 (New) System

#### Entry Points

| Component | Path | Purpose |
|-----------|------|---------|
| UI Page | `/include/import-contacts.cfm:1-221` | Multi-step import wizard |
| JS Controller | `/assets/js/contact-import-v2.js:1-1012` | Client-side logic |
| Upload API | `/ajax/import/upload.cfm:1-110` | File upload, job creation |
| Parse API | `/ajax/import/parse.cfm` | Parse file, detect columns |
| Rows API | `/ajax/import/rows.cfm:1-88` | Paginated row retrieval |
| Finalize API | `/ajax/import/finalize.cfm:1-107` | Execute import |
| Status API | `/ajax/import/status.cfm` | Job stats |
| Main Service | `/services/ContactImportV2Service.cfc:1-700+` | Orchestration |
| Parser Service | `/services/FileParserService.cfc:1-697` | File parsing |
| Validation Service | `/services/ValidationService.cfc:1-516` | Field validation |
| Duplicate Service | `/services/DuplicateMatcherService.cfc:1-554` | Duplicate detection |

#### File Upload Flow (V2)

```
[User uploads CSV/XLS/XLSX]
       |
       v
/ajax/import/upload.cfm
       |
       +-- Validates: CSV/XLS/XLSX, 50MB max
       +-- Creates import_jobs record (status='uploaded')
       |
       v
[User clicks Parse]
       |
       v
/ajax/import/parse.cfm
       |
       +-- FileParserService.parseFile()
       +-- Auto-detect encoding, delimiter
       +-- Column name detection + mapping suggestions
       +-- INSERT INTO import_job_columns
       +-- INSERT INTO import_job_rows (status='pending')
       +-- ValidationService.validateRow() for each row
       +-- DuplicateMatcherService.findDuplicates()
       +-- UPDATE status = 'problem'/'dupe'/'ready'
       |
       v
[User reviews in grid: All/Ready/Problems/Duplicates tabs]
       |
       +-- Edit problem rows (inline validation)
       +-- Resolve duplicates (skip/update/import new)
       |
       v
[User clicks Finalize]
       |
       v
/ajax/import/finalize.cfm
       |
       +-- ContactImportV2Service.executeImport()
       +-- BEGIN TRANSACTION
       +-- For each 'ready' row:
       |     +-- INSERT INTO contactdetails_tbl
       |     +-- INSERT INTO contactitems
       |     +-- UPDATE import_job_rows SET status='imported'
       +-- COMMIT TRANSACTION
       +-- UPDATE import_jobs SET status='completed'
       |
       v
[Import complete - NO relationship enrollment]
```

#### Supported Formats (V2)

| Format | Support | Parsing |
|--------|---------|---------|
| CSV | Yes | FileParserService.parseCSV() |
| XLS | Yes | FileParserService.parseExcel() |
| XLSX | Yes | FileParserService.parseExcel() |
| vCard | No | Not implemented |

**Encoding Detection:** `/services/FileParserService.cfc:53-86`
- UTF-8 (default)
- UTF-8 with BOM
- UTF-16 LE/BE

**Delimiter Detection:** `/services/FileParserService.cfc:89-140`
- Comma (default)
- Tab
- Semicolon
- Pipe

#### Column Mapping (V2)

**Available Fields:** `/services/ContactImportV2Service.cfc:24-55`

```javascript
{
    firstName, lastName, contactFullName,
    email_business, email_personal,
    phone_work, phone_mobile, phone_home,
    company, title,
    address1, address2, city, state, zip, country,
    birthday, relationship_start,
    website, linkedin, twitter, instagram,
    notes, tags, category, contactType
}
```

**Auto-Detection:** Matches column headers against known patterns. Confidence score displayed to user.

**Missing Fields:** No `maintenance_or_target` field - cannot trigger relationship system enrollment.

#### Validation (V2)

**Location:** `/services/ValidationService.cfc:1-516`

| Field | Validation | Severity |
|-------|------------|----------|
| firstName/lastName | Non-empty when contactFullName missing | error |
| contactFullName | Non-empty when first/last missing | error |
| email_* | RFC-compliant format | error |
| phone_* | Normalizes, validates 10-digit | warning |
| birthday | Date format validation | warning |
| state | US state code validation | warning |

**Sample validation code:** `/services/ValidationService.cfc:78-120`

```cfml
<cffunction name="validateEmail">
    <cfset var pattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$">
    <cfif len(value) and not reFindNoCase(pattern, value)>
        <cfset error = "Invalid email format">
    </cfif>
</cffunction>
```

#### Dedupe Rules (V2)

**Location:** `/services/DuplicateMatcherService.cfc:1-554`

**Scoring Algorithm:**

| Match Type | Points | Notes |
|------------|--------|-------|
| Email exact match | 50 | Case-insensitive |
| Phone digits match | 40 | Ignores formatting, strips leading 1 |
| Name exact match | 30 | Checks contactFullName and recordname |
| Name + Company | 25 | Combined match |
| Name + City | 15 | Combined match |

**Thresholds:**
- `THRESHOLD_HIGH = 70` - High confidence duplicate
- `THRESHOLD_MEDIUM = 40` - Medium confidence
- `THRESHOLD_LOW = 25` - Low confidence (default minimum)
- `MAX_CANDIDATES = 5` - Maximum duplicates shown

**Code Reference:** `/services/DuplicateMatcherService.cfc:20-175`

#### Database Writes (V2)

**Staging Tables:** (defined in `/database/migrations/V2_0__contact_import_staging_tables.sql`)

| Table | Purpose |
|-------|---------|
| import_jobs | Job metadata, status tracking |
| import_job_rows | Individual row data + validation state |
| import_job_columns | Column mapping configuration |
| import_job_errors | Per-row error details |

**Production Tables:**

| Table | Operation | Location |
|-------|-----------|----------|
| contactdetails_tbl | INSERT | ContactImportV2Service.executeImport() |
| contactdetails | UPDATE | ContactImportV2Service.executeImport() |
| contactitems | INSERT | ContactImportV2Service.executeImport() |

**Transaction-wrapped:** Yes - all inserts within single transaction.

**NOT Touched:** `fusystems`, `fusystemusers`, `funotifications`, `fuactions`, `actionusers`

---

## B. Data Model and Downstream Dependencies

### B.1 Contact Record Structure

```
contactdetails (core contact info)
       |
       +-- contactitems (multi-value fields)
       |     +-- Email (Business, Personal)
       |     +-- Phone (Work, Mobile, Home)
       |     +-- Address (Work, Home)
       |     +-- Company
       |     +-- Tag
       |     +-- Social links
       |
       +-- fusystemusers (relationship system enrollment)
       |     +-- Links contact to a specific follow-up system
       |     +-- Tracks enrollment date, current action
       |
       +-- funotifications (generated reminders)
             +-- Created by relationship system actions
             +-- Drives daily user activity
```

### B.2 Relationship System Dependencies

**Critical Tables (from CLAUDE.md):**

| Table | Purpose | Import Impact |
|-------|---------|---------------|
| fusystems | System definitions (Targeted List, Maintenance List) | V1 looks up by systemtype/scope |
| fusystemusers | Per-contact enrollment | V1 creates enrollment |
| fuactions | Master action templates | Not directly touched |
| actionusers | Per-user action copies | Not directly touched |
| funotifications | Actionable reminders | Created by enrollment trigger |

### B.3 V1 Relationship Enrollment Flow

**Location:** `/sched/import-contacts.cfm:222-284`

```cfml
<cfif x.maintenance_or_target is "Target">
    <cfset new_systemtype = "Targeted List">
    <!--- Determine scope by checking for Casting Director tag --->
    <cfif findscope.recordcount is 1>
        <cfset new_systemscope = "Casting Director">
    <cfelse>
        <cfset new_systemscope = "Industry">
    </cfif>
    <!--- Find matching system --->
    <cfquery name="FindSystem">
        SELECT * FROM fusystems
        WHERE systemtype = #new_systemtype#
          AND systemscope = #new_systemscope#
    </cfquery>
    <!--- Enroll contact --->
    <cfinclude template="add_system.cfm">
</cfif>
```

**V2 does NOT implement this workflow.** Contacts imported via V2 will not be enrolled in Target or Maintenance systems.

### B.4 Other Contact Dependencies

| Feature | Dependency | Impact |
|---------|------------|--------|
| Contact Search | contactdetails.contactFullName | Both V1/V2 populate |
| Tags/Filtering | contactitems.valueCategory='Tag' | Both V1/V2 populate |
| Email/Phone display | contactitems | Both V1/V2 populate |
| Notes | contactitems.valueCategory='Note' | V2 supports, V1 limited |
| Social links | contactitems | V2 supports (linkedin, twitter, instagram) |
| Folders | contact_folders | V1 creates via folder_setup.cfm |

---

## C. Pain Points and Failure Modes

### C.1 V1 (Legacy) Pain Points

| Issue | Severity | Location | Impact |
|-------|----------|----------|--------|
| **XLSX-only** | High | upload.cfm:62 | Users cannot import from Apple/Google CSV exports |
| **Fixed 22-column template** | High | upload.cfm:93 | Any column shift breaks import |
| **No column mapping** | High | - | Users must manually reformat exports |
| **Weak dedupe (name-only)** | High | sched/import-contacts.cfm:19-22 | Creates duplicates when email matches |
| **No transaction wrapping** | Medium | sched/import-contacts.cfm | Partial imports on failure |
| **SQL injection risk** | Critical | sched/import-contacts.cfm:12-13 | `userEmail` not parameterized |
| **Scheduled job delay** | Medium | sched/import-contacts.cfm | Users wait for import |
| **No preview/edit** | Medium | - | Cannot fix errors before import |
| **Silent failures** | Medium | - | No row-level error reporting |
| **Single tag only** | Low | upload.cfm:124 | Cannot import multiple tags |

### C.2 V2 (New) Pain Points

| Issue | Severity | Location | Impact |
|-------|----------|----------|--------|
| **No relationship enrollment** | Critical | - | Imported contacts not enrolled in Target/Maintenance |
| **No folder creation** | Medium | - | Missing folder_setup.cfm call |
| **No vCard support** | Medium | - | Cannot import Apple Contacts export |
| **No Google Contacts preset** | Low | - | Users must map columns manually |
| **No Apple Contacts preset** | Low | - | Users must map columns manually |

### C.3 Edge Cases That Break Import

| Edge Case | V1 Behavior | V2 Behavior |
|-----------|-------------|-------------|
| Doubled names ("John John Doe") | Creates duplicate | Validates, warns |
| Empty emails | Stores as-is | Skips field |
| Multiple emails in one cell | Stores first only | Parses first, warns |
| Commas in company name | N/A (XLSX only) | Handles quoted fields |
| Embedded newlines | N/A (XLSX only) | Handles in parser |
| Unicode characters | May corrupt | UTF-8 detection |
| 50MB+ files | Rejects | Rejects |
| Empty rows | Imports empty contact | Skips empty rows |
| Whitespace-only values | Stores whitespace | Trims, treats as empty |
| Extremely large files (>10k rows) | No chunking, may timeout | No chunking, may timeout |
| Excel date serial numbers | Stores as number | Attempts conversion |

---

## D. Improvement Options (Phased)

### Phase 0: Quick Wins (Low Risk, High Value)

**Effort:** 2-3 days
**Risk:** Minimal

#### 0.1 Add Relationship Enrollment to V2

**What:** Port the `maintenance_or_target` logic from V1 to V2 finalize.

**Changes:**
- Add `relationship_system` field to import_job_rows
- Add column mapping option for "Relationship System" (Target/Maintenance)
- In `ContactImportV2Service.executeImport()`, after contact creation:
  - Check relationship_system value
  - Look up fusystems by systemtype/scope
  - Call add_system.cfm logic (or extract to service)

**Files to modify:**
- `/services/ContactImportV2Service.cfc` - add enrollment logic
- `/assets/js/contact-import-v2.js` - add field to mapping UI

**Migration:** None - new feature.

**Proof Plan:**
1. Import CSV with "Maintenance" in relationship column
2. Verify fusystemusers record created
3. Verify funotifications generated

#### 0.2 Add Folder Creation to V2

**What:** Call folder_setup logic after contact creation.

**Changes:**
- Extract `/sched/folder_setup.cfm` logic to service
- Call from `ContactImportV2Service.executeImport()`

**Files to modify:**
- Create `/services/FolderService.cfc`
- `/services/ContactImportV2Service.cfc` - call folder service

#### 0.3 Fix V1 SQL Injection

**What:** Parameterize `userEmail` query in scheduled job.

**Location:** `/sched/import-contacts.cfm:12-13`

**Before:**
```cfml
Select * from taousers where useremail = '#trim(x.userEmail)#'
```

**After:**
```cfml
Select * from taousers where useremail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(x.userEmail)#">
```

---

### Phase 1: Real UX Upgrade (Medium Risk)

**Effort:** 1-2 weeks
**Risk:** Medium (UI changes, testing required)

#### 1.1 Preset Column Mappings

**What:** Add "Google Contacts" and "Apple Contacts" presets that auto-map columns.

**Google Contacts CSV columns:**
```
Given Name -> firstName
Family Name -> lastName
E-mail 1 - Value -> email_business
E-mail 2 - Value -> email_personal
Phone 1 - Value -> phone_work
Phone 2 - Value -> phone_mobile
Organization 1 - Name -> company
Organization 1 - Title -> title
Address 1 - Street -> address1
Address 1 - City -> city
Address 1 - Region -> state
Address 1 - Postal Code -> zip
Address 1 - Country -> country
Birthday -> birthday
Notes -> notes
```

**Apple Contacts vCard fields:** (if vCard support added)
```
FN -> contactFullName
N -> firstName, lastName
EMAIL -> email_business
TEL -> phone_work
ORG -> company
ADR -> address components
BDAY -> birthday
NOTE -> notes
```

**Changes:**
- Add preset dropdown to mapping UI
- Store presets in code or database
- Allow users to save custom presets

**Files to modify:**
- `/assets/js/contact-import-v2.js` - preset UI, auto-apply
- `/ajax/import/presets.cfm` - new endpoint
- (optional) `import_column_presets` table

#### 1.2 Import Modes

**What:** Let users choose behavior for duplicates.

**Modes:**
1. **Create Only** - Skip if duplicate found (default)
2. **Update Existing** - Merge data into existing contact
3. **Replace Existing** - Overwrite existing contact

**Changes:**
- Add mode selector to UI before finalize
- Modify `executeImport()` to handle each mode

**Files to modify:**
- `/assets/js/contact-import-v2.js` - mode selector
- `/services/ContactImportV2Service.cfc` - mode logic

#### 1.3 Saved Mappings Per User

**What:** Save user's column mappings for reuse.

**Changes:**
- New table: `import_user_mappings`
- UI to name/save/load mappings
- Auto-suggest based on file name pattern

---

### Phase 2: Correctness and Scale (Higher Risk)

**Effort:** 2-3 weeks
**Risk:** Higher (schema changes, migration needed)

#### 2.1 Undo Last Import

**What:** Allow reverting a completed import.

**Changes:**
- Store `import_job_id` on contactdetails
- Add "Undo Import" button on completed jobs
- Soft-delete contacts (set isDeleted=1, preserve data)
- Also revert fusystemusers if enrolled

**Schema:**
```sql
ALTER TABLE contactdetails ADD import_job_id INT NULL;
CREATE INDEX idx_contactdetails_import_job ON contactdetails(import_job_id);
```

**Files to modify:**
- `/services/ContactImportV2Service.cfc` - add import_job_id to inserts
- New endpoint: `/ajax/import/undo.cfm`

#### 2.2 Chunked Processing

**What:** Process large files in batches to avoid timeouts.

**Changes:**
- Parse in chunks of 1000 rows
- Show progress bar during parsing
- Use background job for very large files

**Files to modify:**
- `/services/FileParserService.cfc` - chunked parsing
- `/services/ContactImportV2Service.cfc` - batch inserts
- `/assets/js/contact-import-v2.js` - progress UI

#### 2.3 Background Job + Progress UI

**What:** Move large imports to scheduled task with progress tracking.

**Changes:**
- New `import_job_progress` table
- Scheduled task polls for jobs with status='processing'
- WebSocket or polling for progress updates

---

### Phase 3: Format Support (Lower Priority)

**Effort:** 1-2 weeks per format
**Risk:** Medium

#### 3.1 vCard (.vcf) Import

**What:** Support Apple Contacts vCard exports.

**Changes:**
- Add vCard parser to FileParserService
- Handle multi-value fields (multiple emails, phones)
- Handle embedded photos (skip or store separately)

**vCard parsing complexity:**
- Version detection (2.1, 3.0, 4.0)
- Quoted-printable encoding
- Base64 embedded data
- Folded lines

**Recommend:** Use existing CFML vCard library if available, or port Java library.

#### 3.2 Direct Google Contacts API

**What:** Import directly from Google Contacts via OAuth.

**Changes:**
- OAuth flow for Google authorization
- People API integration
- Pagination for large contact lists

**Complexity:** High (OAuth, API limits, error handling)

---

## E. Recommendation

### Recommended Path

**Optimize for:**
1. Users importing from Apple Contacts and Google Contacts without hand-editing templates
2. Minimizing duplicate contact creation
3. Keeping relationship workflows reliable

### Immediate (Phase 0) - Do First

1. **Add relationship enrollment to V2** - Critical. Without this, V2 cannot replace V1.
2. **Add folder creation to V2** - Important for full feature parity.
3. **Fix V1 SQL injection** - Security issue, quick fix.

### Short-term (Phase 1) - Next Sprint

1. **Add Google Contacts preset** - Most users export from Google.
2. **Add Import Modes** - Let users choose update behavior.

### Medium-term (Phase 2) - Later

1. **Undo Import** - Safety net for mistakes.
2. **Chunked processing** - Handle larger files.

### Defer (Phase 3)

1. **vCard support** - Nice to have but complex.
2. **Google API integration** - High complexity, limited benefit.

### Recommended Dedupe Strategy

Keep V2's scoring approach but add auto-resolution options:

| Score | Default Action |
|-------|----------------|
| 90+ | Auto-skip (high confidence duplicate) |
| 70-89 | Flag for review |
| 40-69 | Allow import with warning |
| <40 | Import as new |

**Add deterministic merge rules:**
1. Email match = same contact (primary key)
2. Phone match + name match = same contact
3. Name-only match = flag for manual review

---

## F. Test Plan

### Functional Tests

| Test | Expected Result | Status |
|------|-----------------|--------|
| Upload CSV, map columns, finalize | Contacts created with correct data | |
| Upload XLSX with preset | Columns auto-mapped | |
| Import with duplicate email | Row flagged as duplicate | |
| Resolve duplicate: Skip | Row not imported | |
| Resolve duplicate: Import New | New contact created | |
| Import with "Target" system | Contact enrolled in fusystemusers | |
| Import with validation error | Row marked as problem | |
| Edit problem row | Row revalidated, status updated | |
| Finalize with 0 ready rows | Error shown, import blocked | |
| Import 5000+ rows | Completes without timeout | |

### Edge Case Tests

| Test | Expected Result |
|------|-----------------|
| CSV with BOM | Parsed correctly |
| CSV with semicolon delimiter | Auto-detected |
| CSV with quoted commas | Parsed correctly |
| Excel with date columns | Dates formatted as YYYY-MM-DD |
| File with empty rows | Empty rows skipped |
| File with 50+ columns | Extra columns ignored |

### Security Tests

| Test | Expected Result |
|------|-----------------|
| XSS in contact name | Escaped in display |
| SQL injection in email | Parameterized, no injection |
| Formula injection (=SUM...) | Treated as text |
| Large file upload | Rejected at 50MB |
| Unauthorized job access | Returns "Access denied" |

---

## Appendix: File Index

### V1 (Legacy) Files

| File | Lines | Purpose |
|------|-------|---------|
| `/include/upload.cfm` | 420 | File upload handler |
| `/include/import-contacts_old.cfm` | 199 | Legacy UI |
| `/sched/import-contacts.cfm` | 315 | Scheduled processor |
| `/services/ContactImportService.cfc` | 326 | Legacy service |
| `/include/download_contact_template.cfm` | 58 | Template download |

### V2 (New) Files

| File | Lines | Purpose |
|------|-------|---------|
| `/include/import-contacts.cfm` | 221 | Import wizard UI |
| `/assets/js/contact-import-v2.js` | 1012 | Client-side controller |
| `/services/ContactImportV2Service.cfc` | 700+ | Main orchestration |
| `/services/FileParserService.cfc` | 697 | File parsing |
| `/services/ValidationService.cfc` | 516 | Field validation |
| `/services/DuplicateMatcherService.cfc` | 554 | Duplicate detection |
| `/ajax/import/upload.cfm` | 110 | Upload endpoint |
| `/ajax/import/parse.cfm` | ~100 | Parse endpoint |
| `/ajax/import/rows.cfm` | 88 | Rows endpoint |
| `/ajax/import/finalize.cfm` | 107 | Finalize endpoint |
| `/ajax/import/status.cfm` | ~60 | Status endpoint |
| `/ajax/import/update-row.cfm` | ~100 | Row update endpoint |
| `/ajax/import/bulk-action.cfm` | ~80 | Bulk actions endpoint |
| `/ajax/import/row-action.cfm` | ~80 | Single row action |

### Database

| File | Purpose |
|------|---------|
| `/database/migrations/V2_0__contact_import_staging_tables.sql` | V2 staging tables |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-07 | Claude Code | Initial discovery |
