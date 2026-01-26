# Phase 6.1 Test Harness - Contact Import V3 Review Workflow

This document provides a repeatable test harness for verifying Phase 6 endpoints.

## Prerequisites

### Required: Session Cookies

Obtain a valid session by logging into the application and extracting the session cookie:
- `CFID=xxx`
- `CFTOKEN=xxx`

Example format for curl:
```
COOKIES="CFID=12345;CFTOKEN=abc123def456"
```

### Required: CSRF Token

CSRF tokens are stored in `session.csrf_token`. Options:
1. Extract from a hidden input on a page: `<input type="hidden" name="csrf_token" value="...">`
2. Create a new import job - the page load will generate the token
3. For testing, inspect session via CF admin or debug output

Example:
```
CSRF_TOKEN="1234ABCD-5678-EFGH-9012-IJKL3456MNOP"
```

### Required: Job ID and Row ID

1. Create a test import job by uploading a CSV file
2. Advance it to `reviewing` status (parse + validate steps)
3. Note the `job_id` from the URL or API response
4. Get a `row_id` from the rows.cfm response

```
JOB_ID=42
ROW_ID=123
```

---

## Test Scripts

### Environment Variables

Set these before running tests:

```bash
# Windows PowerShell
$env:BASE_URL = "https://dev.theactorsoffice.com"
$env:COOKIES = "CFID=xxx;CFTOKEN=xxx"
$env:CSRF_TOKEN = "xxx"
$env:JOB_ID = "42"
$env:ROW_ID = "123"

# Linux/Mac bash
export BASE_URL="https://dev.theactorsoffice.com"
export COOKIES="CFID=xxx;CFTOKEN=xxx"
export CSRF_TOKEN="xxx"
export JOB_ID="42"
export ROW_ID="123"
```

---

## Test 1: rows.cfm - Stats Only Mode

**Purpose:** Verify stats_only=1 returns only stats, no rows.

```bash
curl -s "${BASE_URL}/ajax/importv3/rows.cfm?bypass=1&job_id=${JOB_ID}&stats_only=1" \
  --cookie "${COOKIES}" | jq .
```

**Expected Response:**
```json
{
  "success": true,
  "code": "",
  "message": "",
  "data": {
    "stats": {
      "total": 50,
      "ready": 45,
      "problem": 3,
      "dupe": 2,
      "ignored": 0,
      "imported": 0
    },
    "stats_only": true,
    "debug": ["start", "auth_ok", "job_id_ok", "params_parsed", "service_init", "job_loaded", "status_ok", "stats_fetched", "done"],
    "elapsed_ms": 15
  }
}
```

**Verification Checklist:**
- [ ] `success: true`
- [ ] `data.stats_only: true`
- [ ] `data.stats` contains: total, ready, problem, dupe, ignored, imported
- [ ] No `data.rows` present
- [ ] `data.debug` is an array (no PII)
- [ ] `data.elapsed_ms` is present (number)
- [ ] Response Content-Type is `application/json; charset=utf-8`

---

## Test 2: rows.cfm - Paginated Rows with Status Filter

**Purpose:** Verify pagination and status filtering work correctly.

```bash
curl -s "${BASE_URL}/ajax/importv3/rows.cfm?bypass=1&job_id=${JOB_ID}&status=ready&page=1&page_size=10" \
  --cookie "${COOKIES}" | jq .
```

**Expected Response:**
```json
{
  "success": true,
  "code": "",
  "message": "",
  "data": {
    "rows": [
      {
        "row_id": 123,
        "row_num": 1,
        "status": "ready",
        "user_action": "",
        "data": { "firstName": "John", "lastName": "Doe" },
        "validation": { "firstName": true, "lastName": true },
        "errors": []
      }
    ],
    "total": 45,
    "page": 1,
    "page_size": 10,
    "total_pages": 5,
    "stats": { "total": 50, "ready": 45, "problem": 3, "dupe": 2, "ignored": 0, "imported": 0 },
    "debug": ["start", "auth_ok", "job_id_ok", "params_parsed", "service_init", "job_loaded", "status_ok", "rows_fetched", "done"],
    "elapsed_ms": 42
  }
}
```

**Verification Checklist:**
- [ ] `success: true`
- [ ] `data.rows` is an array
- [ ] All rows have `status: "ready"`
- [ ] `data.total` <= stats.ready
- [ ] `data.total_pages` = ceil(total / page_size)
- [ ] Each row has: row_id, row_num, status, data, validation, errors
- [ ] `data.stats` is present and consistent

---

## Test 3: rows.cfm - Status Gate Rejection

**Purpose:** Verify 409 INVALID_STATE when job status is wrong.

First, use a job that is in `parsing` or `pending` status (not reviewing/finalizing/completed):

```bash
curl -s -w "\nHTTP_CODE:%{http_code}" \
  "${BASE_URL}/ajax/importv3/rows.cfm?bypass=1&job_id=${JOB_ID_WRONG_STATUS}" \
  --cookie "${COOKIES}"
```

**Expected:**
- HTTP 409
- `code: "INVALID_STATE"`
- `data.current_status` shows actual status
- `data.allowed` shows allowed statuses

---

## Test 4: row.cfm - Single Row Detail

**Purpose:** Verify full row detail including facts and duplicates.

```bash
curl -s "${BASE_URL}/ajax/importv3/row.cfm?bypass=1&job_id=${JOB_ID}&row_id=${ROW_ID}" \
  --cookie "${COOKIES}" | jq .
```

**Expected Response:**
```json
{
  "success": true,
  "code": "",
  "message": "",
  "data": {
    "row": {
      "row_id": 123,
      "row_num": 1,
      "job_id": 42,
      "status": "ready",
      "user_action": "",
      "data": { "firstName": "John", "lastName": "Doe", "email_business": "john@example.com" },
      "validation": { "firstName": true, "lastName": true, "email_business": true },
      "errors": [],
      "facts": [
        {
          "fact_id": 456,
          "column_id": 1,
          "field_name": "firstName",
          "raw_value": "John",
          "normalized_value": "John",
          "is_valid": true,
          "validation_code": "",
          "validation_message": ""
        }
      ],
      "duplicates": [],
      "warnings": []
    },
    "debug": ["start", "auth_ok", "params_ok", "service_init", "job_loaded", "status_ok", "row_fetched", "done"],
    "elapsed_ms": 25
  }
}
```

**Verification Checklist:**
- [ ] `success: true`
- [ ] `data.row.facts` is an array with full fact details
- [ ] `data.row.duplicates` is an array (may be empty)
- [ ] `data.row.warnings` is an array
- [ ] Each fact has: fact_id, field_name, raw_value, normalized_value, is_valid

---

## Test 5: row.cfm - Row Not Found

**Purpose:** Verify 404 NOT_FOUND for nonexistent row.

```bash
curl -s -w "\nHTTP_CODE:%{http_code}" \
  "${BASE_URL}/ajax/importv3/row.cfm?bypass=1&job_id=${JOB_ID}&row_id=999999" \
  --cookie "${COOKIES}"
```

**Expected:**
- HTTP 404
- `code: "NOT_FOUND"`

---

## Test 6: fact_update.cfm - Update Single Field

**Purpose:** Verify fact update with revalidation and status recompute.

```bash
curl -s -X POST "${BASE_URL}/ajax/importv3/fact_update.cfm?bypass=1" \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: ${CSRF_TOKEN}" \
  -d "{\"job_id\": ${JOB_ID}, \"row_id\": ${ROW_ID}, \"fields\": {\"firstName\": \"UpdatedName\"}}" \
  --cookie "${COOKIES}" | jq .
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Row updated",
  "code": "",
  "data": {
    "row": {
      "row_id": 123,
      "status": "ready",
      "data": { "firstName": "UpdatedName", ... }
    },
    "debug": ["start", "auth_ok", "csrf_ok", "params_ok", "service_init", "job_loaded", "status_ok", "update_called", "facts_updated", "done"],
    "elapsed_ms": 55
  }
}
```

**Verification Checklist:**
- [ ] `success: true`
- [ ] `data.row.data.firstName` = "UpdatedName"
- [ ] Status recomputed if validation changed
- [ ] CSRF validated (try without token - should get 403)

---

## Test 7: fact_update.cfm - CSRF Rejection

**Purpose:** Verify 403 CSRF_INVALID when token missing or wrong.

```bash
# Missing CSRF token
curl -s -w "\nHTTP_CODE:%{http_code}" \
  -X POST "${BASE_URL}/ajax/importv3/fact_update.cfm?bypass=1" \
  -H "Content-Type: application/json" \
  -d "{\"job_id\": ${JOB_ID}, \"row_id\": ${ROW_ID}, \"fields\": {\"firstName\": \"Test\"}}" \
  --cookie "${COOKIES}"

# Wrong CSRF token
curl -s -w "\nHTTP_CODE:%{http_code}" \
  -X POST "${BASE_URL}/ajax/importv3/fact_update.cfm?bypass=1" \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: INVALID_TOKEN" \
  -d "{\"job_id\": ${JOB_ID}, \"row_id\": ${ROW_ID}, \"fields\": {\"firstName\": \"Test\"}}" \
  --cookie "${COOKIES}"
```

**Expected:**
- HTTP 403
- `code: "CSRF_INVALID"`

---

## Test 8: fact_update.cfm - Status Gate Rejection

**Purpose:** Verify editing blocked when job not in reviewing status.

Use a job in `finalizing` or `completed` status:

```bash
curl -s -w "\nHTTP_CODE:%{http_code}" \
  -X POST "${BASE_URL}/ajax/importv3/fact_update.cfm?bypass=1" \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: ${CSRF_TOKEN}" \
  -d "{\"job_id\": ${JOB_ID_FINALIZING}, \"row_id\": ${ROW_ID}, \"fields\": {\"firstName\": \"Test\"}}" \
  --cookie "${COOKIES}"
```

**Expected:**
- HTTP 409
- `code: "INVALID_STATE"`
- `data.current_status` shows actual status
- `data.allowed: ["reviewing"]`

---

## Test 9: row_action.cfm - Ignore Single Row

**Purpose:** Verify ignore action sets status to ignored.

```bash
curl -s -X POST "${BASE_URL}/ajax/importv3/row_action.cfm?bypass=1" \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: ${CSRF_TOKEN}" \
  -d "{\"job_id\": ${JOB_ID}, \"row_id\": ${ROW_ID}, \"action\": \"ignore\"}" \
  --cookie "${COOKIES}" | jq .
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Row action updated",
  "code": "",
  "data": {
    "row_id": 123,
    "action": "skip",
    "status": "ignored",
    "stats": { "total": 50, "ready": 44, "problem": 3, "dupe": 2, "ignored": 1, "imported": 0 },
    "debug": ["start", "auth_ok", "csrf_ok", "params_ok", "service_init", "job_loaded", "status_ok", "action_called", "action_applied", "done"],
    "elapsed_ms": 30
  }
}
```

**Verification Checklist:**
- [ ] `success: true`
- [ ] `data.action: "skip"` (internal DB value)
- [ ] `data.status: "ignored"`
- [ ] `data.stats.ignored` incremented

---

## Test 10: row_action.cfm - Bulk Create

**Purpose:** Verify bulk action on multiple rows.

```bash
curl -s -X POST "${BASE_URL}/ajax/importv3/row_action.cfm?bypass=1" \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: ${CSRF_TOKEN}" \
  -d "{\"job_id\": ${JOB_ID}, \"row_ids\": [${ROW_ID}, ${ROW_ID2}, ${ROW_ID3}], \"action\": \"create\"}" \
  --cookie "${COOKIES}" | jq .
```

**Expected Response:**
```json
{
  "success": true,
  "message": "3 row(s) updated",
  "code": "",
  "data": {
    "updated_count": 3,
    "requested_count": 3,
    "action": "import_new",
    "stats": { ... },
    "debug": [...],
    "elapsed_ms": 45
  }
}
```

---

## Test 11: row_action.cfm - UPDATE_NOT_SUPPORTED

**Purpose:** Verify update action is rejected in create-only mode.

```bash
curl -s -w "\nHTTP_CODE:%{http_code}" \
  -X POST "${BASE_URL}/ajax/importv3/row_action.cfm?bypass=1" \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: ${CSRF_TOKEN}" \
  -d "{\"job_id\": ${JOB_ID}, \"row_id\": ${ROW_ID}, \"action\": \"update\"}" \
  --cookie "${COOKIES}"
```

**Expected:**
- HTTP 400
- `code: "UPDATE_NOT_SUPPORTED"`
- Message explains create-only mode

---

## Test 12: row_action.cfm - CSRF Rejection

**Purpose:** Verify CSRF required for state-changing endpoint.

```bash
curl -s -w "\nHTTP_CODE:%{http_code}" \
  -X POST "${BASE_URL}/ajax/importv3/row_action.cfm?bypass=1" \
  -H "Content-Type: application/json" \
  -d "{\"job_id\": ${JOB_ID}, \"row_id\": ${ROW_ID}, \"action\": \"ignore\"}" \
  --cookie "${COOKIES}"
```

**Expected:**
- HTTP 403
- `code: "CSRF_INVALID"`

---

## Test 13: Authentication Required

**Purpose:** Verify 401 when not logged in.

```bash
curl -s -w "\nHTTP_CODE:%{http_code}" \
  "${BASE_URL}/ajax/importv3/rows.cfm?bypass=1&job_id=${JOB_ID}"
```

**Expected:**
- HTTP 401
- `code: "AUTH_REQUIRED"`

---

## SQL Verification Queries

Run these against the database to verify endpoint data matches.

### 1. Row Counts by Status

```sql
SELECT status, COUNT(*) as count
FROM import_v3_rows
WHERE job_id = ?
GROUP BY status
ORDER BY status;
```

Compare to `stats` object from rows.cfm.

### 2. Facts for a Specific Row

```sql
SELECT fact_id, field_name, raw_value, normalized_value, is_valid, validation_code, validation_message
FROM import_v3_facts
WHERE row_id = ?
ORDER BY field_name;
```

Compare to `facts` array from row.cfm.

### 3. Verify Status Recomputation Logic

```sql
-- Check if row has validation errors (should be status='problem')
SELECT r.row_id, r.status,
       (SELECT COUNT(*) FROM import_v3_facts WHERE row_id = r.row_id AND is_valid = 0) as error_count,
       r.dupe_candidates_json
FROM import_v3_rows r
WHERE r.row_id = ?;
```

Status should be:
- `problem` if error_count > 0
- `dupe` if no errors but dupe_candidates_json is not empty
- `ready` otherwise

### 4. Verify Ignored Rows

```sql
SELECT row_id, row_num, status, user_action
FROM import_v3_rows
WHERE job_id = ? AND status = 'ignored'
ORDER BY row_num;
```

### 5. Verify Denormalized Job Counts Match Actual

```sql
SELECT
  j.valid_rows as job_valid,
  j.problem_rows as job_problem,
  j.dupe_rows as job_dupe,
  j.skipped_rows as job_skipped,
  (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = j.job_id AND status = 'ready') as actual_ready,
  (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = j.job_id AND status = 'problem') as actual_problem,
  (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = j.job_id AND status = 'dupe') as actual_dupe,
  (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = j.job_id AND status = 'ignored') as actual_ignored
FROM import_v3_jobs j
WHERE j.job_id = ?;
```

All "job_*" columns should match "actual_*" columns.

---

## Performance Verification

### Batch Fact Loading

The rows.cfm endpoint should use batch fact loading (one query for all facts on the page, not N queries for N rows).

To verify:
1. Enable MySQL query logging or use slow query log
2. Call rows.cfm with page_size=50
3. Verify there is only ONE facts query, not 50

Expected query pattern:
```sql
SELECT f.row_id, f.field_name, f.normalized_value, f.is_valid, ...
FROM import_v3_facts f
WHERE f.row_id IN (1, 2, 3, ..., 50)
ORDER BY f.row_id, f.field_name
```

### Timing Expectations

Typical elapsed_ms values (on reasonable hardware):
- rows.cfm stats_only: < 50ms
- rows.cfm with 50 rows: < 200ms
- row.cfm single row: < 100ms
- fact_update.cfm: < 150ms
- row_action.cfm single: < 100ms
- row_action.cfm bulk (100 rows): < 500ms

---

## Acceptance Checklist

| Test | Expected | Status |
|------|----------|--------|
| Test 1: Stats only mode | Only stats, no rows | [ ] PASS / [ ] FAIL |
| Test 2: Paginated with filter | Correct pagination + filter | [ ] PASS / [ ] FAIL |
| Test 3: Status gate rejection | 409 INVALID_STATE | [ ] PASS / [ ] FAIL |
| Test 4: Row detail | Full facts + duplicates | [ ] PASS / [ ] FAIL |
| Test 5: Row not found | 404 NOT_FOUND | [ ] PASS / [ ] FAIL |
| Test 6: Fact update | Field updated + revalidated | [ ] PASS / [ ] FAIL |
| Test 7: CSRF rejection (fact_update) | 403 CSRF_INVALID | [ ] PASS / [ ] FAIL |
| Test 8: Status gate (fact_update) | 409 for non-reviewing | [ ] PASS / [ ] FAIL |
| Test 9: Ignore single row | Status = ignored | [ ] PASS / [ ] FAIL |
| Test 10: Bulk create | Multiple rows updated | [ ] PASS / [ ] FAIL |
| Test 11: UPDATE_NOT_SUPPORTED | 400 error | [ ] PASS / [ ] FAIL |
| Test 12: CSRF rejection (row_action) | 403 CSRF_INVALID | [ ] PASS / [ ] FAIL |
| Test 13: Auth required | 401 AUTH_REQUIRED | [ ] PASS / [ ] FAIL |
| SQL: Counts match stats | DB counts = API stats | [ ] PASS / [ ] FAIL |
| SQL: Denormalized counts valid | job counts = actual | [ ] PASS / [ ] FAIL |
| Performance: Batch loading | 1 facts query per page | [ ] PASS / [ ] FAIL |
| All responses JSON | Content-Type correct | [ ] PASS / [ ] FAIL |
| All responses have debug | Array, no PII | [ ] PASS / [ ] FAIL |
| All responses have elapsed_ms | Number present | [ ] PASS / [ ] FAIL |

---

## Manual UI Test Script

### Test A: Tab Switching Reflects Stats

1. Open import review page for a job in `reviewing` status
2. Note the counts on each tab (Ready, Problems, Duplicates, Ignored)
3. Click each tab
4. Verify the rows shown match the tab count
5. Verify network requests show correct `status` filter

### Test B: Editing Field Moves Row Between Tabs

1. Go to Problems tab
2. Open a row with a validation error
3. Fix the error (e.g., correct an invalid email)
4. Save
5. Verify the row is no longer in Problems tab
6. Verify the row appears in Ready tab (or Duplicates if dupes exist)
7. Verify tab counts updated

### Test C: Bulk Ignore Updates Stats

1. Go to Ready or Duplicates tab
2. Select multiple rows (checkbox)
3. Click "Ignore Selected"
4. Verify rows disappear from current tab
5. Verify rows appear in Ignored tab
6. Verify stats update immediately

### Test D: Network Expectations

Using browser dev tools Network tab:

1. Verify all AJAX calls include `bypass=1`
2. Verify all responses have `Content-Type: application/json; charset=utf-8`
3. Verify all responses follow envelope: `{ success, code, message, data }`
4. Verify POST calls include CSRF (header or body)

---

## DONE_TOKEN: PHASE6_1_TESTS_COMPLETE
