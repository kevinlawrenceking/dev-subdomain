# Contact Importer V2 - Current State Analysis

## Executive Summary

The existing TAO contact importer has significant limitations that can cause data loss and poor user experience. This document analyzes the current implementation and identifies failure modes that the V2 importer must address.

---

## Current Implementation Overview

### Endpoints and Flow

| Component | Location | Purpose |
|-----------|----------|---------|
| Upload Handler | `/include/upload.cfm` | Receives file, parses Excel, inserts to staging then production |
| Import Service | `/services/ContactImportService.cfc` | Insert/query staging table |
| Import UI | `/include/import-contacts.cfm` | Upload form + results display |
| Template Download | `/include/download_contact_template.cfm` | Provides Excel template |
| Query Files | `/include/qry/*315*.cfm` | Individual insert operations for contacts, tags, emails, phones, addresses |

### Current Workflow

```
1. User downloads template (ImportTemplate2.xlsx)
2. User fills in contacts (22 columns fixed order)
3. User uploads .xlsx file
4. Server parses with cfspreadsheet
5. INScontactsimport() inserts ALL rows to contactsimport staging table
6. INScontactdetails_24399() checks for duplicates by name, creates/updates contact
7. Separate loops insert: tags (x3), emails (x2), phones (x3), company, address, website, notes
8. If Maintenance flag set, auto-starts Maintenance system
9. Redirect to results page showing imported contacts
```

### Tables Touched

**Staging:**
- `contactsimport` - temporary holding with status (Pending, Added, Duplicate, Error)
- `uploads` - batch tracking with uploadid

**Production (during import):**
- `contactdetails` / `contactdetails_tbl` - main contact record
- `contactitems` - EAV table for emails, phones, addresses, companies, tags, URLs
- `tagtags` - tag associations (legacy, may be deprecated)
- `noteslog` - contact notes
- `fusystemusers` - relationship system enrollment
- `funotifications` - action items/reminders

---

## Identified Failure Modes

### 1. Hard Crash on Malformed Data

**Problem:** `cfspreadsheet` action="read" throws unhandled exceptions on:
- Corrupted Excel files
- Files with macros or complex formatting
- CSV files (expects Excel only)
- Wrong file extension
- Files larger than memory

**Impact:** User sees error page, loses work, no partial recovery.

**Evidence:** No try/catch in `/include/upload.cfm`

### 2. No CSV Support

**Problem:** Only .xlsx/.xls accepted. Many users export contacts as CSV from other systems.

**Impact:** Users must manually convert to Excel, losing data fidelity.

### 3. Fixed Column Order Dependency

**Problem:** Template columns must be in exact order:
```
FirstName,LastName,Tag1,Tag2,Tag3,BusinessEmail,PersonalEmail,WorkPhone,MobilePhone,HomePhone,Company,Address,Address2,City,State,Zip,Country,contactMeetingDate,contactMeetingLoc,Birthday,website,Notes
```

**Impact:** Any column swap causes silent data corruption (wrong data in wrong fields).

### 4. No Field Validation Before Insert

**Problem:** Validation happens at INSERT time or not at all:
- Dates parsed with `dateformat()` without validation
- Emails not format-checked
- Phone numbers not normalized
- No length validation

**Evidence:** `INScontactsimport()` in ContactImportService.cfc lines 407-443 just trims and inserts.

**Impact:** Bad data silently corrupts production tables.

### 5. Weak Duplicate Detection

**Problem:** Current duplicate check in `INScontactdetails_24399()`:
```sql
SELECT contactid FROM contactdetails_tbl
WHERE contactfullname = '#fname# #lname#'
AND userid = ?
```

Only matches on exact full name. No email, phone, or fuzzy matching.

**Impact:** Duplicates proliferate; user has no pre-import visibility.

### 6. No Pre-Import Review

**Problem:** Rows go straight to production. No opportunity to:
- Review before commit
- Fix errors inline
- Choose how to handle duplicates
- Skip specific rows

**Impact:** All-or-nothing import; bad data mixed with good.

### 7. No Idempotency

**Problem:** If import partially fails, re-running creates duplicates.

**Evidence:** No import marker stored with contacts; no dedupe key.

### 8. Direct Production Inserts During Parse

**Problem:** The loop in `upload.cfm` lines 31-49 inserts to production tables immediately after staging.

**Impact:** No rollback possible; partial failures leave orphaned data.

### 9. No Transaction Wrapping

**Problem:** Each INSERT runs independently. No CFTRANSACTION around batch.

**Evidence:** Multiple `<cfinclude template="qry/xxx_insert.cfm">` without transaction.

### 10. Poor Error Reporting

**Problem:** No structured error capture per row/field. Just success/failure status.

**Impact:** User cannot diagnose which row failed or why.

---

## Schema Analysis

### contactsimport (Current Staging Table)

| Column | Type | Notes |
|--------|------|-------|
| id | INT PK | Auto-increment |
| uploadid | INT | Batch FK |
| fname, lname | VARCHAR(100) | Name parts |
| tag1, tag2, tag3 | VARCHAR(100) | Three tag slots |
| business_email, personal_email | VARCHAR(100) | Two email slots |
| work_phone, mobile_phone, home_phone | VARCHAR(100) | Three phone slots |
| company | VARCHAR(200) | Company name |
| address, address_second | VARCHAR(200/100) | Address lines |
| city, state, zip, country | VARCHAR(100) | Address parts |
| contactMeetingDate | DATE | Optional |
| contactMeetingLoc | VARCHAR | Optional |
| birthday | DATE | Optional |
| website | VARCHAR(200) | URL |
| notes | TEXT | Free text |
| status | VARCHAR | Pending/Added/Duplicate/Error |
| contactid | INT | FK after insert |
| timestamp | DATETIME | Created at |

**Limitations:**
- Fixed schema matches fixed template
- No raw data preservation
- No per-field error storage
- No duplicate candidate tracking

### contactdetails (Production)

Required fields:
- `userid` - FK to owner
- `contactFullName` - primary display name

All other fields optional. Soft delete via `isdeleted` bit.

### contactitems (Production EAV)

| valueCategory | valueType examples | Storage field |
|---------------|-------------------|---------------|
| Email | Business, Personal | valuetext |
| Phone | Work, Mobile, Home | valuetext |
| Address | Home, Work | 6 value* fields |
| Company | - | valueCompany, valueDepartment, valueTitle |
| Tag | Tags | valuetext |
| URL | Company Website | valuetext |

---

## Validation Rules to Preserve

From ContactService.cfc and form handlers:

### Required Fields
- `userid` - always required for multi-tenancy
- `contactFullName` - required for create (can be computed from fname + lname)

### Field Types
- `contactBirthday` - CF_SQL_DATE
- `contactMeetingDate` - CF_SQL_DATE
- All name/text fields - CF_SQL_VARCHAR
- `isdeleted` - CF_SQL_BIT

### Phone Format (Client-Side Only)
Pattern: `/^[0-9\+\-\(\)\s]+$/`
Accepts: digits, spaces, plus sign, parentheses, dashes

### Tag Length
Truncated to 40 chars: `LEFT(tagname, 40)`

### Status Values
- contactStatus: 'Active', 'Inactive' (no constraint)
- itemStatus: 'Active', 'Pending', 'Inactive' (no constraint)

---

## Duplicate Detection Logic (Current)

From ContactDuplicateService.cfc:

### By Name
```sql
SELECT contactfirst, contactlast, COUNT(*)
FROM contactdetails
WHERE userid = ? AND isdeleted = 0
GROUP BY contactfirst, contactlast
HAVING COUNT(*) > 1
```

### By Email
```sql
SELECT valuetext AS email, COUNT(*)
FROM contactitems ci
JOIN contactdetails cd ON ci.contactid = cd.contactid
WHERE ci.valueCategory = 'Email'
  AND ci.itemStatus = 'Active'
  AND cd.userid = ?
GROUP BY valuetext
HAVING COUNT(*) > 1
```

**Missing:**
- Phone number matching
- Fuzzy name matching
- Combined scoring

---

## Files to Preserve/Respect

The importer must NOT break these relationship system touchpoints:

1. `fusystems` / `fusystemusers` - system enrollment
2. `funotifications` - action items
3. `fuactions` / `actionusers` - action definitions
4. `contactdetails.uniquename` - uniqueness flags used by workflows
5. Tag-based system scope detection (tagtype='C' for Casting Director)

---

## V2 Requirements Summary

Based on current state analysis:

1. **File Support**: CSV + XLS + XLSX
2. **Parsing**: Tolerant of malformed data, per-cell error capture
3. **Staging**: New tables with raw data preservation and validation results
4. **Column Mapping**: Auto-detect + manual override, not fixed order
5. **Validation**: Email format, phone normalization, date parsing, lengths
6. **Duplicate Detection**: Email, phone, name + company, configurable scoring
7. **Review Grid**: Filter by status, inline editing, per-field errors
8. **User Actions**: Skip, import anyway, update existing
9. **Finalize**: Transaction-wrapped, idempotent, audit trail
10. **No Direct Insert**: Two-phase commit (stage then finalize)
