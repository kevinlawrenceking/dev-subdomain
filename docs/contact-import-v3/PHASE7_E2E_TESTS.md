# Contact Import V3 - Phase 7 E2E Test Plan

## Overview

This document provides end-to-end test scripts for the Contact Import V3 system.
Each test includes UI steps, expected network calls, and verification criteria.

**Test Environment Requirements:**
- MySQL database (schema: `new_development` for dev, `actorsbusinessoffice` for prod)
- ColdFusion server running
- Valid session with `session.userid` set
- Valid `session.csrf_token` available

**Common Headers for All Requests:**
```
Content-Type: application/json; charset=utf-8
X-CSRF-Token: {csrf_token}  (for POST/mutating endpoints)
```

**Response Envelope (Phase 5.2 standard):**
```json
{
  "success": true|false,
  "code": "SUCCESS|ERROR_CODE",
  "message": "Human-readable message",
  "data": {
    "debug": ["step1", "step2", ...],
    "elapsed_ms": 123,
    ...additional fields...
  }
}
```

---

## Test 1: Happy Path - Complete Import Workflow

### Preconditions
- User is logged in
- No existing import job in progress for this user
- Test CSV file: 10 rows, all valid data, no duplicates

### Test CSV Content
```csv
first_name,last_name,email,phone,company
John,Smith,john.smith@test.com,555-0101,Acme Corp
Jane,Doe,jane.doe@test.com,555-0102,Beta Inc
Bob,Wilson,bob.wilson@test.com,555-0103,Gamma LLC
...
```

### Step 1: Upload File

**UI Action:** Click "Choose File", select test.csv, click "Upload"

**Network Call:**
```
POST /ajax/importv3/upload.cfm?bypass=1
Content-Type: multipart/form-data

file: [test.csv binary]
csrf_token: {csrf_token}
```

**Expected Response:**
```json
{
  "success": true,
  "code": "SUCCESS",
  "message": "File uploaded successfully",
  "data": {
    "job_id": 123,
    "file_name": "test.csv",
    "file_size": 456,
    "debug": ["start", "auth_ok", "csrf_ok", "file_received", "job_created", "done"],
    "elapsed_ms": 50
  }
}
```

**HTTP Status:** 200
**Verification:**
- `response.success` === true
- `response.data.job_id` is positive integer
- UI shows "File uploaded" message
- UI advances to column mapping step

### Step 2: Parse File

**UI Action:** Automatic after upload (or manual trigger)

**Network Call:**
```
POST /ajax/importv3/parse.cfm?bypass=1
Content-Type: application/json
X-CSRF-Token: {csrf_token}

{
  "job_id": 123,
  "csrf_token": "{csrf_token}"
}
```

**Expected Response:**
```json
{
  "success": true,
  "code": "SUCCESS",
  "message": "File parsed successfully",
  "data": {
    "job_id": 123,
    "total_rows": 10,
    "columns": ["first_name", "last_name", "email", "phone", "company"],
    "preview_rows": [...first 5 rows...],
    "debug": ["start", "auth_ok", "csrf_ok", "job_loaded", "file_parsed", "rows_staged", "done"],
    "elapsed_ms": 150
  }
}
```

**HTTP Status:** 200
**Verification:**
- `response.data.total_rows` === 10
- `response.data.columns` contains expected headers
- UI shows column mapping interface

### Step 3: Get Column Definitions

**UI Action:** Automatic after parse

**Network Call:**
```
GET /ajax/importv3/columns.cfm?bypass=1
```

**Expected Response:**
```json
{
  "success": true,
  "code": "SUCCESS",
  "data": {
    "columns": [
      {"name": "first_name", "label": "First Name", "required": true, "type": "text"},
      {"name": "last_name", "label": "Last Name", "required": true, "type": "text"},
      {"name": "email", "label": "Email", "required": false, "type": "email"},
      ...
    ],
    "debug": ["start", "auth_ok", "columns_loaded", "done"],
    "elapsed_ms": 10
  }
}
```

**HTTP Status:** 200

### Step 4: Save Column Mappings and Recompute

**UI Action:** Map columns via dropdowns, click "Save Mappings"

**Network Call:**
```
POST /ajax/importv3/recompute.cfm?bypass=1
Content-Type: application/json
X-CSRF-Token: {csrf_token}

{
  "job_id": 123,
  "mappings": {
    "first_name": "first_name",
    "last_name": "last_name",
    "email": "email",
    "phone": "phone",
    "company": "company"
  },
  "skip_dupes": 0,
  "csrf_token": "{csrf_token}"
}
```

**Expected Response:**
```json
{
  "success": true,
  "code": "SUCCESS",
  "message": "Recompute completed",
  "data": {
    "job_id": 123,
    "status": "reviewing",
    "stats": {
      "total": 10,
      "ready": 10,
      "problem": 0,
      "duplicate": 0,
      "skipped": 0
    },
    "debug": ["start", "auth_ok", "csrf_ok", "job_loaded", "mappings_saved", "validation_run", "dupes_checked", "status_updated", "done"],
    "elapsed_ms": 200
  }
}
```

**HTTP Status:** 200
**Verification:**
- Job status is now "reviewing"
- All 10 rows are "ready" (no problems, no dupes)
- UI shows review tabs with counts

### Step 5: Load Rows for Review

**UI Action:** Click "Ready" tab (default)

**Network Call:**
```
GET /ajax/importv3/rows.cfm?bypass=1&job_id=123&status=ready&page=1&page_size=50
```

**Expected Response:**
```json
{
  "success": true,
  "code": "SUCCESS",
  "data": {
    "rows": [
      {
        "row_id": 1,
        "row_index": 1,
        "row_status": "ready",
        "user_action": "import_new",
        "facts": {
          "first_name": {"raw_value": "John", "clean_value": "John", "valid": true},
          "last_name": {"raw_value": "Smith", "clean_value": "Smith", "valid": true},
          ...
        }
      },
      ...
    ],
    "total": 10,
    "page": 1,
    "page_size": 50,
    "total_pages": 1,
    "debug": ["start", "auth_ok", "params_ok", "job_loaded", "status_ok", "rows_fetched", "facts_loaded", "done"],
    "elapsed_ms": 50
  }
}
```

**HTTP Status:** 200

### Step 6: Update Stats (Tab Counts)

**UI Action:** Automatic after loadRows()

**Network Call:**
```
GET /ajax/importv3/rows.cfm?bypass=1&job_id=123&stats_only=1
```

**Expected Response:**
```json
{
  "success": true,
  "code": "SUCCESS",
  "data": {
    "stats": {
      "total": 10,
      "ready": 10,
      "problem": 0,
      "duplicate": 0,
      "skipped": 0
    },
    "debug": ["start", "auth_ok", "params_ok", "job_loaded", "status_ok", "stats_computed", "done"],
    "elapsed_ms": 20
  }
}
```

**HTTP Status:** 200

### Step 7: Finalize Import

**UI Action:** Click "Finalize Import" button

**Network Call:**
```
POST /ajax/importv3/finalize.cfm?bypass=1
Content-Type: application/json
X-CSRF-Token: {csrf_token}

{
  "job_id": 123,
  "csrf_token": "{csrf_token}"
}
```

**Expected Response:**
```json
{
  "success": true,
  "code": "SUCCESS",
  "message": "Import finalized successfully",
  "data": {
    "job_id": 123,
    "status": "completed",
    "imported_count": 10,
    "skipped_count": 0,
    "error_count": 0,
    "debug": ["start", "auth_ok", "csrf_ok", "job_loaded", "status_ok", "rows_imported", "job_completed", "done"],
    "elapsed_ms": 500
  }
}
```

**HTTP Status:** 200
**Verification:**
- Job status is now "completed"
- `imported_count` === 10
- UI shows success message with counts
- New contacts appear in contacts table

### Database Verification Queries

```sql
-- Verify job completed
SELECT job_id, status, total_rows, imported_count, error_count
FROM contact_import_jobs
WHERE job_id = 123;
-- Expected: status='completed', total_rows=10, imported_count=10, error_count=0

-- Verify rows all finalized
SELECT row_status, COUNT(*) as cnt
FROM contact_import_rows
WHERE job_id = 123
GROUP BY row_status;
-- Expected: imported=10

-- Verify contacts created
SELECT COUNT(*) FROM contacts
WHERE created_by_import_job = 123;
-- Expected: 10

-- Verify no orphan facts
SELECT COUNT(*) FROM contact_import_facts f
LEFT JOIN contact_import_rows r ON f.row_id = r.row_id
WHERE r.row_id IS NULL;
-- Expected: 0
```

---

## Test 2: Large File Performance Test (500+ Rows)

### Preconditions
- User is logged in
- Test CSV file: 500-1000 rows with varied data
- Some rows should have validation issues (5-10%)
- Some rows should be potential duplicates (5-10%)

### Timing Expectations

| Step | Expected Time | Max Acceptable |
|------|---------------|----------------|
| Upload (500 rows) | < 2s | 5s |
| Parse (500 rows) | < 5s | 15s |
| Recompute (500 rows) | < 10s | 30s |
| Load Rows (page of 50) | < 1s | 3s |
| Stats Update | < 500ms | 2s |
| Finalize (450 ready rows) | < 30s | 60s |

### Step 1: Upload Large File

**Network Call:** Same as Happy Path Step 1

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "job_id": 456,
    "file_size": 125000,
    "elapsed_ms": 1500
  }
}
```

**Verification:**
- `elapsed_ms` < 5000
- UI shows upload progress indicator

### Step 2: Parse Large File

**Network Call:** Same as Happy Path Step 2

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "total_rows": 500,
    "elapsed_ms": 4500
  }
}
```

**Verification:**
- `elapsed_ms` < 15000
- UI shows "Parsing..." indicator during operation
- UI updates when complete

### Step 3: Recompute with Duplicate Detection

**Network Call:**
```
POST /ajax/importv3/recompute.cfm?bypass=1
Content-Type: application/json
X-CSRF-Token: {csrf_token}

{
  "job_id": 456,
  "mappings": {...},
  "skip_dupes": 0,
  "csrf_token": "{csrf_token}"
}
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "stats": {
      "total": 500,
      "ready": 450,
      "problem": 25,
      "duplicate": 25,
      "skipped": 0
    },
    "elapsed_ms": 8500
  }
}
```

**Verification:**
- `elapsed_ms` < 30000
- Stats add up: ready + problem + duplicate + skipped === total
- UI shows spinner during recompute
- UI enables interaction after complete

### Step 4: Paginated Row Loading

**Network Call:**
```
GET /ajax/importv3/rows.cfm?bypass=1&job_id=456&status=ready&page=1&page_size=50
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "rows": [...50 rows...],
    "total": 450,
    "page": 1,
    "page_size": 50,
    "total_pages": 9,
    "elapsed_ms": 250
  }
}
```

**Verification:**
- Returns exactly 50 rows
- `total_pages` calculated correctly (ceil(450/50) = 9)
- `elapsed_ms` < 3000
- Pagination controls work correctly

### Step 5: Navigate to Page 5

**Network Call:**
```
GET /ajax/importv3/rows.cfm?bypass=1&job_id=456&status=ready&page=5&page_size=50
```

**Verification:**
- Returns rows 201-250
- Page indicator shows "Page 5 of 9"
- Previous/Next buttons enabled appropriately

### Step 6: Switch to Problems Tab

**UI Action:** Click "Problems" tab

**Expected Behavior:**
- `state.currentPage` resets to 1
- New request made with `status=problem&page=1`
- Problem rows displayed
- Pagination shows correct total for problems (25)

### Step 7: Finalize Large Import

**Network Call:** Same as Happy Path Step 7

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "imported_count": 450,
    "skipped_count": 50,
    "error_count": 0,
    "elapsed_ms": 25000
  }
}
```

**Verification:**
- `elapsed_ms` < 60000
- UI shows progress indicator during finalize
- Buttons disabled during operation
- Success message shows accurate counts

---

## Test 3: Invalid CSV Format

### Preconditions
- File with no valid CSV structure (e.g., binary file renamed to .csv)

### Step 1: Upload Invalid File

**Network Call:**
```
POST /ajax/importv3/upload.cfm?bypass=1
Content-Type: multipart/form-data

file: [invalid.csv binary - actually a PNG]
csrf_token: {csrf_token}
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "job_id": 789
  }
}
```

**HTTP Status:** 200 (upload succeeds - file is stored)

### Step 2: Parse Invalid File

**Network Call:**
```
POST /ajax/importv3/parse.cfm?bypass=1
Content-Type: application/json
X-CSRF-Token: {csrf_token}

{
  "job_id": 789,
  "csrf_token": "{csrf_token}"
}
```

**Expected Response:**
```json
{
  "success": false,
  "code": "PARSE_ERROR",
  "message": "Unable to parse file as CSV",
  "data": {
    "debug": ["start", "auth_ok", "csrf_ok", "job_loaded", "parse_failed"],
    "last_step": "parse_failed"
  }
}
```

**HTTP Status:** 400
**Verification:**
- `response.success` === false
- `response.code` === "PARSE_ERROR"
- UI shows error message
- UI does NOT advance to mapping step
- Job status remains "uploaded" or "parse_error"

---

## Test 4: Missing Required Fields

### Preconditions
- CSV file missing required columns (e.g., no first_name or last_name)

### CSV Content
```csv
email,phone,company
john@test.com,555-0101,Acme
jane@test.com,555-0102,Beta
```

### Step 1-2: Upload and Parse

Same as Happy Path - succeeds

### Step 3: Recompute with Incomplete Mappings

**Network Call:**
```
POST /ajax/importv3/recompute.cfm?bypass=1
Content-Type: application/json
X-CSRF-Token: {csrf_token}

{
  "job_id": 890,
  "mappings": {
    "email": "email",
    "phone": "phone",
    "company": "company"
  },
  "skip_dupes": 0,
  "csrf_token": "{csrf_token}"
}
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "stats": {
      "total": 2,
      "ready": 0,
      "problem": 2,
      "duplicate": 0,
      "skipped": 0
    }
  }
}
```

**Verification:**
- All rows marked as "problem" due to missing required fields
- Finalize button disabled or warns user
- Problem tab shows validation errors for each row

---

## Test 5: Skip Duplicates Mode (skip_dupes=1)

### Preconditions
- CSV with rows matching existing contacts
- User wants to auto-skip duplicates

### Step 3: Recompute with skip_dupes=1

**Network Call:**
```
POST /ajax/importv3/recompute.cfm?bypass=1
Content-Type: application/json
X-CSRF-Token: {csrf_token}

{
  "job_id": 901,
  "mappings": {...},
  "skip_dupes": 1,
  "csrf_token": "{csrf_token}"
}
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "stats": {
      "total": 10,
      "ready": 7,
      "problem": 0,
      "duplicate": 0,
      "skipped": 3
    }
  }
}
```

**Verification:**
- Duplicate rows automatically set to `user_action: skip`
- `duplicate` count is 0 (they're in `skipped`)
- Ready rows exclude skipped duplicates
- Finalize will import 7 rows

---

## Test 6: Manual Duplicate Skip via Row Action

### Preconditions
- Import job with some duplicates identified
- User wants to manually skip specific duplicates

### Step: Skip Duplicate Row

**Network Call:**
```
POST /ajax/importv3/row_action.cfm?bypass=1
Content-Type: application/json
X-CSRF-Token: {csrf_token}

{
  "job_id": 123,
  "row_id": 5,
  "action": "ignore",
  "csrf_token": "{csrf_token}"
}
```

**Expected Response:**
```json
{
  "success": true,
  "code": "SUCCESS",
  "message": "Row action applied",
  "data": {
    "row_id": 5,
    "action": "skip",
    "debug": ["start", "auth_ok", "csrf_ok", "params_ok", "service_init", "job_loaded", "status_ok", "action_called", "action_applied", "done"],
    "elapsed_ms": 30
  }
}
```

**HTTP Status:** 200
**Verification:**
- Row 5 now has `user_action: skip`
- Stats update: `skipped` increases by 1, `duplicate` or `ready` decreases by 1
- Row moves to "Skipped" tab

---

## Test 7: Fact Update Rejected (Invalid Value)

### Preconditions
- Import job in reviewing state
- Row with editable facts

### Step: Update Email to Invalid Value

**Network Call:**
```
POST /ajax/importv3/fact_update.cfm?bypass=1
Content-Type: application/json
X-CSRF-Token: {csrf_token}

{
  "job_id": 123,
  "row_id": 1,
  "fields": {
    "email": "not-an-email"
  },
  "csrf_token": "{csrf_token}"
}
```

**Expected Response:**
```json
{
  "success": true,
  "code": "SUCCESS",
  "message": "Facts updated",
  "data": {
    "row_id": 1,
    "updated_fields": ["email"],
    "validation": {
      "email": {
        "valid": false,
        "error": "Invalid email format"
      }
    },
    "row_status": "problem",
    "debug": ["start", "auth_ok", "csrf_ok", "params_ok", "service_init", "job_loaded", "status_ok", "update_called", "facts_updated", "done"],
    "elapsed_ms": 40
  }
}
```

**HTTP Status:** 200 (update succeeds, but row becomes problem)
**Verification:**
- Fact value updated to "not-an-email"
- Row status changed to "problem"
- Validation shows error for email field
- UI shows validation error in row editor
- Stats update: `problem` increases, `ready` decreases

---

## Test 8: Finalize CSRF Failure

### Preconditions
- Valid import job ready to finalize
- CSRF token missing or invalid

### Step: Finalize Without CSRF Token

**Network Call:**
```
POST /ajax/importv3/finalize.cfm?bypass=1
Content-Type: application/json

{
  "job_id": 123
}
```

**Expected Response:**
```json
{
  "success": false,
  "code": "CSRF_INVALID",
  "message": "CSRF token is required",
  "data": {
    "csrf_source": "missing",
    "debug": ["start", "auth_ok", "body_parsed"],
    "last_step": "body_parsed"
  }
}
```

**HTTP Status:** 403
**Verification:**
- `response.success` === false
- `response.code` === "CSRF_INVALID"
- Job status unchanged (still "reviewing")
- No contacts created
- UI shows CSRF error message

### Step: Finalize With Invalid CSRF Token

**Network Call:**
```
POST /ajax/importv3/finalize.cfm?bypass=1
Content-Type: application/json
X-CSRF-Token: invalid-token-12345

{
  "job_id": 123,
  "csrf_token": "invalid-token-12345"
}
```

**Expected Response:**
```json
{
  "success": false,
  "code": "CSRF_INVALID",
  "message": "Invalid CSRF token",
  "data": {
    "csrf_source": "header",
    "debug": ["start", "auth_ok", "body_parsed"],
    "last_step": "body_parsed"
  }
}
```

**HTTP Status:** 403

---

## Test 9: Finalize Double-Click Prevention

### Preconditions
- Valid import job ready to finalize
- User double-clicks finalize button

### Step: Rapid Double Finalize

**First Request:**
```
POST /ajax/importv3/finalize.cfm?bypass=1
Content-Type: application/json
X-CSRF-Token: {csrf_token}

{
  "job_id": 123,
  "csrf_token": "{csrf_token}"
}
```

**First Response:**
```json
{
  "success": true,
  "data": {
    "imported_count": 10
  }
}
```

**Second Request (sent immediately):**
```
POST /ajax/importv3/finalize.cfm?bypass=1
Content-Type: application/json
X-CSRF-Token: {csrf_token}

{
  "job_id": 123,
  "csrf_token": "{csrf_token}"
}
```

**Second Response:**
```json
{
  "success": false,
  "code": "INVALID_STATE",
  "message": "Cannot finalize from status: completed. Allowed: reviewing",
  "data": {
    "current_status": "completed",
    "allowed": ["reviewing"],
    "debug": ["start", "auth_ok", "csrf_ok", "params_ok", "service_init", "job_loaded"],
    "last_step": "job_loaded"
  }
}
```

**HTTP Status:** 409
**Verification:**
- Second request fails with INVALID_STATE
- No duplicate contacts created
- `imported_count` matches original count
- UI prevents double-click (button disabled after first click)

---

## Test 10: Finalize Re-run on Completed Job

### Preconditions
- Import job already in "completed" status

### Step: Attempt to Re-finalize

**Network Call:**
```
POST /ajax/importv3/finalize.cfm?bypass=1
Content-Type: application/json
X-CSRF-Token: {csrf_token}

{
  "job_id": 123,
  "csrf_token": "{csrf_token}"
}
```

**Expected Response:**
```json
{
  "success": false,
  "code": "INVALID_STATE",
  "message": "Cannot finalize from status: completed. Allowed: reviewing",
  "data": {
    "current_status": "completed",
    "allowed": ["reviewing"]
  }
}
```

**HTTP Status:** 409
**Verification:**
- Request rejected with 409 Conflict
- No additional contacts created
- Job remains in "completed" status
- UI shows appropriate error

---

## Test 11: Session Expiry During Operation

### Preconditions
- Valid import job in progress
- Session expires mid-operation

### Step: Request After Session Expiry

**Network Call:**
```
GET /ajax/importv3/rows.cfm?bypass=1&job_id=123&status=ready&page=1
```

**Expected Response:**
```json
{
  "success": false,
  "code": "AUTH_REQUIRED",
  "message": "Authentication required",
  "data": {
    "debug": ["start"],
    "last_step": "start"
  }
}
```

**HTTP Status:** 401
**Verification:**
- All endpoints return AUTH_REQUIRED
- UI redirects to login or shows session expired message
- No partial operations completed

---

## Test 12: Access Denied (Wrong User's Job)

### Preconditions
- Import job belongs to user A
- User B tries to access

### Step: Access Another User's Job

**Network Call (as User B):**
```
GET /ajax/importv3/rows.cfm?bypass=1&job_id=123&status=ready&page=1
```

**Expected Response:**
```json
{
  "success": false,
  "code": "ACCESS_DENIED",
  "message": "You do not have access to this import job",
  "data": {
    "debug": ["start", "auth_ok", "params_ok", "service_init"],
    "last_step": "service_init"
  }
}
```

**HTTP Status:** 403
**Verification:**
- Request rejected with ACCESS_DENIED
- No job data leaked
- Works for all endpoints: rows, row, fact_update, row_action, finalize

---

## Database Verification Queries (Run After All Tests)

```sql
-- Check for orphan rows (rows without jobs)
SELECT COUNT(*) as orphan_rows FROM contact_import_rows r
LEFT JOIN contact_import_jobs j ON r.job_id = j.job_id
WHERE j.job_id IS NULL;
-- Expected: 0

-- Check for orphan facts (facts without rows)
SELECT COUNT(*) as orphan_facts FROM contact_import_facts f
LEFT JOIN contact_import_rows r ON f.row_id = r.row_id
WHERE r.row_id IS NULL;
-- Expected: 0

-- Check job counts match row counts
SELECT j.job_id, j.total_rows, j.imported_count + j.error_count as job_processed,
       COUNT(r.row_id) as actual_rows,
       SUM(CASE WHEN r.row_status = 'imported' THEN 1 ELSE 0 END) as actual_imported
FROM contact_import_jobs j
LEFT JOIN contact_import_rows r ON j.job_id = r.job_id
WHERE j.status = 'completed'
GROUP BY j.job_id, j.total_rows, j.imported_count, j.error_count
HAVING j.total_rows != actual_rows OR j.imported_count != actual_imported;
-- Expected: 0 rows (no mismatches)

-- Check for stuck jobs (reviewing for > 24 hours)
SELECT job_id, status, created_at, updated_at
FROM contact_import_jobs
WHERE status IN ('reviewing', 'finalizing')
AND updated_at < DATE_SUB(NOW(), INTERVAL 24 HOUR);
-- Expected: Review manually if any exist

-- Verify all completed jobs have correct status trail
SELECT job_id, status FROM contact_import_jobs
WHERE status = 'completed'
AND imported_count = 0 AND error_count = 0 AND total_rows > 0;
-- Expected: 0 rows (completed jobs should have processed rows)
```

---

## Acceptance Checklist

### Happy Path
- [ ] Upload succeeds and returns job_id
- [ ] Parse extracts correct row count and columns
- [ ] Column definitions load correctly
- [ ] Recompute validates and detects duplicates
- [ ] Rows load with pagination
- [ ] Stats update correctly after each operation
- [ ] Finalize creates contacts and completes job
- [ ] All responses have correct Content-Type (application/json; charset=utf-8)

### Error Handling
- [ ] Invalid CSV shows parse error
- [ ] Missing required fields creates problem rows
- [ ] CSRF failures return 403 with CSRF_INVALID
- [ ] Auth failures return 401 with AUTH_REQUIRED
- [ ] Access denied returns 403 with ACCESS_DENIED
- [ ] Invalid state returns 409 with INVALID_STATE

### Performance
- [ ] 500-row import completes in < 60 seconds total
- [ ] Page loads complete in < 3 seconds
- [ ] Stats updates complete in < 2 seconds

### UI Behavior
- [ ] Spinner shows during long operations
- [ ] Buttons disabled during submissions
- [ ] Double-click prevented on finalize
- [ ] Tab switches reset pagination to page 1
- [ ] Error messages display code and message
- [ ] Debug info logged to console only (not displayed)

### Data Integrity
- [ ] No orphan rows or facts
- [ ] Job counts match row counts
- [ ] No duplicate contacts from double-finalize
- [ ] Completed jobs have accurate imported_count

---

## Test Data Files

### test-happy-10.csv
```csv
first_name,last_name,email,phone,company
John,Smith,john.smith@test.com,555-0101,Acme Corp
Jane,Doe,jane.doe@test.com,555-0102,Beta Inc
Bob,Wilson,bob.wilson@test.com,555-0103,Gamma LLC
Alice,Brown,alice.brown@test.com,555-0104,Delta Co
Charlie,Davis,charlie.davis@test.com,555-0105,Echo Ltd
Diana,Miller,diana.miller@test.com,555-0106,Foxtrot Inc
Edward,Garcia,edward.garcia@test.com,555-0107,Golf Corp
Fiona,Martinez,fiona.martinez@test.com,555-0108,Hotel LLC
George,Anderson,george.anderson@test.com,555-0109,India Co
Helen,Taylor,helen.taylor@test.com,555-0110,Juliet Ltd
```

### test-invalid.csv
(Binary PNG file renamed to .csv for parse failure test)

### test-missing-required.csv
```csv
email,phone,company
john@test.com,555-0101,Acme
jane@test.com,555-0102,Beta
```

### test-large-500.csv
(Generated file with 500 rows, ~5% validation issues, ~5% duplicates)

---

*Document Version: Phase 7.0*
*Last Updated: 2026-01-25*
