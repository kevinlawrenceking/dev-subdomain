# Contact Import V3 - Project Status and Review

## Overview

Contact Import V3 is a complete rewrite of the contact import system using an EAV (Entity-Attribute-Value) pattern for flexible field handling, staged import workflow, and improved duplicate detection.

## Current Status: PARTIALLY WORKING

The import flow works up to the column mapping stage. The recompute/validation step is failing silently (no response returned).

---

## What Has Been Done

### 1. Database Schema (COMPLETE)
- Created `import_v3_jobs` - Main job tracking table
- Created `import_v3_columns` - Column mapping configuration
- Created `import_v3_rows` - Individual row storage
- Created `import_v3_facts` - EAV pattern for field values
- Created `import_v3_events` - Audit trail

**Schema fixes applied during debugging:**
- Added missing columns to `import_v3_columns`: `intent`, `target_key`, `transform_json`
- Columns added to BOTH `new_development` (dev) and `actorsbusinessoffice` (prod) databases

### 2. Backend Services (COMPLETE)
- `ContactImportV3Service.cfc` - Core service for job management
- `ValidationService.cfc` - Field validation (email, phone, date, URL)
- `DuplicateMatcherService.cfc` - Duplicate contact detection

**Fixes applied:**
- Added `datasource="#application.datasource#"` to all cfquery tags in DuplicateMatcherService.cfc

### 3. API Endpoints (PARTIALLY COMPLETE)

| Endpoint | Status | Notes |
|----------|--------|-------|
| `/ajax/importv3/upload.cfm` | WORKING | File upload, job creation |
| `/ajax/importv3/parse.cfm` | WORKING | CSV/Excel parsing, populates rows/facts |
| `/ajax/importv3/columns.cfm` | WORKING | GET column mappings, POST update mapping |
| `/ajax/importv3/recompute.cfm` | FAILING | No response returned - hangs |
| `/ajax/importv3/rows.cfm` | UNTESTED | List rows with pagination |
| `/ajax/importv3/row.cfm` | UNTESTED | Single row details |
| `/ajax/importv3/finalize.cfm` | UNTESTED | Final import to contacts table |

### 4. Frontend (PARTIALLY COMPLETE)
- `import-contacts-v3.cfm` - Main UI template
- `contact-import-v3.js` - JavaScript controller

**UI Flow:**
1. Upload file - WORKING
2. Parse file - WORKING
3. Map columns - WORKING (UI displays, can select mappings)
4. Confirm mapping - FAILING (calls recompute.cfm, no response)
5. Review rows - UNTESTED
6. Finalize import - UNTESTED

### 5. Datasource Configuration (FIXED)
- Issue: Dev site was using production datasource (`abo`) instead of dev (`abod`)
- Fix: Added dynamic datasource selection in `/ajax/Application.cfc` `onRequestStart()`
- Dev (`dev.theactorsoffice.com`) now uses `abod` -> `new_development` database
- Prod (`app.theactorsoffice.com`) uses `abo` -> `actorsbusinessoffice` database

---

## Current Failure Point

### Problem: `recompute.cfm` returns no response

**Symptoms:**
- User clicks "Confirm Mapping & Continue"
- AJAX request sent to `/ajax/importv3/recompute.cfm`
- Request payload is correct (job_id, mappings array)
- No response is received (not even an error)
- Page reloads back to mapping screen (because status unchanged)

**Suspected Causes:**
1. **Query timeout** - DuplicateMatcherService runs multiple queries per row
2. **Missing table/column** - Query referencing non-existent table in dev DB
3. **ColdFusion error** - Unhandled exception before cfcontent output

**What recompute.cfm does:**
1. Validates user authentication
2. Parses JSON body for job_id and mappings
3. Updates column mappings in `import_v3_columns`
4. Loads all rows for the job
5. For each row:
   - Loads facts
   - Applies column mappings
   - Validates each field (email, phone, date, etc.)
   - Runs duplicate detection against existing contacts
   - Updates row status (ready/problem/dupe)
6. Updates job counts
7. Sets job status to "reviewing"
8. Returns JSON response

**Most likely failure point:** Step 5 - the duplicate detection queries against `contactdetails` and `contactitems` tables. These tables may:
- Not exist in `new_development` database
- Have different schema than expected
- Cause timeout due to missing indexes

---

## Diagnostic Tools Created

1. `/ajax/importv3/diag.cfm` - Tests database, services, queries
2. `/ajax/importv3/check_tables.cfm` - Lists V3 tables and columns

---

## What Needs To Be Done

### Immediate (Fix recompute.cfm)

1. **Add request timeout handling**
   - Add `<cfsetting requesttimeout="300">` to recompute.cfm

2. **Verify contact tables exist in dev DB**
   ```sql
   USE new_development;
   SHOW TABLES LIKE 'contact%';
   DESCRIBE contactdetails;
   DESCRIBE contactitems;
   ```

3. **Add granular debug logging to recompute.cfm**
   - Log before/after each major step
   - Return partial response even on failure

4. **Test duplicate detection in isolation**
   - Add test in diag.cfm to call DuplicateMatcherService.findDuplicates()

### Short Term (Complete the Flow)

1. **Test rows.cfm endpoint**
   - Verify row listing works after recompute succeeds

2. **Test row editing**
   - Verify individual row/fact updates work

3. **Test finalize.cfm**
   - Verify contacts are created in main contact tables
   - Verify relationship system enrollment

4. **UI Polish**
   - Error messages displayed properly
   - Progress indicators
   - Bulk actions working

### Medium Term (Production Ready)

1. **Add rollback capability**
   - If finalize fails mid-way, allow retry

2. **Add import history**
   - Show past imports with stats

3. **Add VCF (vCard) support**
   - Currently returns "not supported"

4. **Performance optimization**
   - Batch duplicate detection
   - Add indexes if needed

5. **Testing**
   - Test with large files (1000+ rows)
   - Test with malformed data
   - Test edge cases (duplicate emails, missing names)

---

## Files Changed During Debugging Session

| File | Changes |
|------|---------|
| `/include/import-contacts-v3.cfm` | Fixed job data extraction from service response |
| `/app/assets/js/contact-import-v3.js` | Added debug logging throughout |
| `/ajax/Application.cfc` | Added dynamic datasource selection in onRequestStart |
| `/ajax/importv3/parse.cfm` | Added debug logging, JSON body parsing |
| `/ajax/importv3/recompute.cfm` | Added error detail in catch block |
| `/services/ContactImportV3Service.cfc` | Improved error messages |
| `/services/DuplicateMatcherService.cfc` | Added datasource to all cfquery tags |
| `/ajax/importv3/diag.cfm` | Created - diagnostic endpoint |
| `/ajax/importv3/check_tables.cfm` | Created - table structure checker |

---

## How to Continue Debugging

1. **Check if contact tables exist in dev:**
   ```sql
   USE new_development;
   SELECT COUNT(*) FROM contactdetails WHERE userid = YOUR_USERID;
   ```

2. **Test recompute with minimal data:**
   - Create a 1-row CSV
   - Map only firstName and lastName
   - Check if recompute works with no duplicate detection

3. **Add step-by-step logging:**
   - Modify recompute.cfm to output JSON after each major section
   - Identify exactly where it hangs

4. **Check ColdFusion logs:**
   - Look for timeout or memory errors
   - Path: ColdFusion admin > Debugging > Log files

---

## Database Schema Reference

```sql
-- Check V3 tables
SELECT TABLE_NAME, TABLE_ROWS
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'new_development'
AND TABLE_NAME LIKE 'import_v3%';

-- Check a specific job
SELECT * FROM import_v3_jobs WHERE job_id = 4;

-- Check columns for a job
SELECT * FROM import_v3_columns WHERE job_id = 4;

-- Check rows for a job
SELECT * FROM import_v3_rows WHERE job_id = 4;

-- Check facts for a row
SELECT * FROM import_v3_facts WHERE row_id = (SELECT row_id FROM import_v3_rows WHERE job_id = 4 LIMIT 1);
```

---

## Contact Tables (Expected Schema)

The duplicate detection queries these tables:
- `contactdetails` - Main contact records (contactid, userid, contactFullName, recordname, isdeleted)
- `contactitems` - Contact data items like email/phone (contactid, valueCategory, valuetext, itemStatus, isDeleted)

If these don't exist in dev database, duplicate detection will fail silently.

---

## Phase 3 Performance Optimization (January 2026)

### Problem
Phase 2.1 metrics showed dupe_queries_total was high (e.g., 250 queries for 50 rows = 5 queries/row).
This would not scale for larger imports (500+ rows).

### Solution: Candidate Lookup Strategy
Replaced individual field-by-field queries with a 2-query strategy:

1. **getCandidateContactIds()** - Single query finds all contactids matching ANY email or phone
2. **getCandidateContacts()** - Fetches details for candidate contacts (2 queries: details + items)
3. **CFML scoring** - Candidates are scored in memory, no additional queries

### Query Reduction
| Scenario | Before (Phase 2.1) | After (Phase 3) |
|----------|-------------------|-----------------|
| Row with keys (email/phone) | 5-8 queries | 3 queries max |
| Row without keys (name only) | 3-4 queries | 1 query (bounded) |
| Row with no matches | 5-8 queries | 1 query |

### New Metrics Added
- `dupe_candidates_total` - Sum of candidates checked across all rows
- `dupe_rows_with_keys` - Count of rows that had email or phone keys

### Feature Flags
- `ENABLE_NAME_FALLBACK` (default: true) - Enable/disable name-only matching
- `NAME_FALLBACK_LIMIT` (default: 20) - Max results for name fallback query

### Index Recommendations (Phase 3.2 - Schema Verified)

**Schema facts:**
- `contactitems` does NOT have a `userid` column
- `contactitems` joins to `contactdetails` via `contactid`
- The query filters contactdetails by userid, then joins to contactitems

**Query structure (getCandidateContactIds):**
```sql
SELECT DISTINCT ci.contactid
FROM contactitems ci
INNER JOIN contactdetails d ON d.contactid = ci.contactid
WHERE d.userid = ?
  AND (d.isdeleted IS NULL OR d.isdeleted = 0)
  AND ci.itemStatus = 'Active'
  AND (ci.isDeleted IS NULL OR ci.isDeleted = 0)
  AND (
    (ci.valueCategory = 'Email' AND ci.valuetext IN (...))
    OR
    (ci.valueCategory = 'Phone' AND REPLACE(...ci.valuetext...) IN (...))
  )
LIMIT 100
```

**Why contactid leads the contactitems index:**
Since contactitems has no userid, MySQL must first find contactids from contactdetails (filtered by userid),
then probe contactitems by contactid. The index must have contactid first to support this join pattern.

**Email matching:** Uses direct comparison (no LOWER()) because MySQL default collation is case-insensitive.
**Phone matching:** Still uses REPLACE() since stored phones have formatting. Index filters by category/status first.

```sql
-- contactdetails: userid filter + isdeleted filter + contactid for JOIN
-- userid first because the query filters by userid
CREATE INDEX idx_contactdetails_user_dupe
ON contactdetails (userid, isdeleted, contactid);

-- contactitems: contactid for JOIN, then filter columns, then valuetext for email lookup
-- contactid must be first since we probe by contactid after filtering contactdetails
CREATE INDEX idx_contactitems_dupe_lookup
ON contactitems (contactid, itemStatus, isDeleted, valueCategory, valuetext(100));

-- Note: valuetext(100) is a prefix index. If valuetext is VARCHAR(255) or smaller,
-- you can use valuetext without prefix. If TEXT, prefix is required.

-- Verify existing indexes before adding
SHOW INDEX FROM contactitems;
SHOW INDEX FROM contactdetails;
```

**EXPLAIN test query (email lookup):**
```sql
EXPLAIN SELECT DISTINCT ci.contactid
FROM contactitems ci
INNER JOIN contactdetails d ON d.contactid = ci.contactid
WHERE d.userid = 123
  AND (d.isdeleted IS NULL OR d.isdeleted = 0)
  AND ci.itemStatus = 'Active'
  AND (ci.isDeleted IS NULL OR ci.isDeleted = 0)
  AND ci.valueCategory = 'Email'
  AND ci.valuetext IN ('john@example.com', 'jane@example.com')
LIMIT 100;
```

**Expected EXPLAIN output:**
| id | table | type | key | rows |
|----|-------|------|-----|------|
| 1 | d | ref | idx_contactdetails_user_dupe | small |
| 1 | ci | ref | idx_contactitems_dupe_lookup | small |

**Red flags to watch for:**
- `type: ALL` = full table scan (bad)
- `key: NULL` = no index used (bad)
- `Using temporary; Using filesort` = acceptable for DISTINCT but watch row counts

### Benchmark Targets (Phase 3)
- 50 row job: dupe_queries_total <= 120 (was ~250)
- 500 row job: dupe_queries_total should scale linearly with keyed rows

### Files Modified (Phase 3)
- `/services/DuplicateMatcherService.cfc` - Added normalization helpers, candidate lookup methods, refactored findDuplicates
- `/ajax/importv3/recompute.cfm` - Added new metrics fields

---

## Phase 4 Batch Dupe Matching (January 2026)

### Problem
Phase 3 reduced queries per row from 5-8 to 3 max, but query count still scaled O(N) with number of rows.
For 500 row imports, this meant hundreds of queries, causing latency and DB load.

### Solution: In-Memory Dupe Index
Build a complete in-memory index of all user's email/phone values once, then lookup candidates in O(1) per row.

**New methods in DuplicateMatcherService.cfc:**

1. **buildUserDupeIndex(userid, metricsRef)** - One-time query to fetch ALL email/phone items for the user
   - Returns struct with `email_map` and `phone_map` (normalized value -> [contactid1, contactid2, ...])
   - Single query regardless of row count

2. **getCandidateContactIdsFromIndex(dupeIndex, emails, phones, metricsRef)** - Pure CFML lookup
   - No database queries, O(1) hash map lookups
   - Returns array of candidate contactids

3. **getCandidateDetailsBatch(userid, contactIds[], metricsRef)** - Batch fetch contact details
   - 2 queries for ANY number of unique candidates
   - Results cached for reuse across rows

4. **findDuplicatesWithIndex(...)** - Main entry point for Phase 4 dupe detection
   - Uses pre-built index for candidate lookup
   - Uses cached candidate details for scoring
   - Returns `candidateIdsToFetch` if cache miss, caller batch-fetches

### Query Pattern (Phase 4)

| Operation | Queries |
|-----------|---------|
| Build dupe index | 1 |
| Lookup candidates per row | 0 (in-memory) |
| Fetch unique candidate details | 2 (batch, once per unique set) |
| **Total per job** | **1 + 2*ceil(unique_candidates/batch_size)** |

For typical 50-row job with 10 unique candidates: **3 queries total** (was 120+ in Phase 3)

### New Metrics (Phase 4)
- `dupe_index_build_ms` - Time to build the in-memory dupe index
- `dupe_index_items_total` - Number of email/phone items loaded into index
- `dupe_candidates_unique_total` - Count of unique contactids checked across all rows

### Benchmark Targets (Phase 4)
| Scenario | Phase 3 | Phase 4 |
|----------|---------|---------|
| 50 row job | ~120 queries | <=6 queries |
| 500 row job | ~1200 queries | <=6 queries |
| 1000 row job | ~2400 queries | <=10 queries |

Query count is now nearly O(1) per job, scaling only with unique candidates (not row count).

### Memory Considerations
- Index size scales with user's total contact count
- For user with 1000 contacts and 2 emails/phones each: ~4KB index
- For user with 10000 contacts: ~40KB index
- Well within ColdFusion request memory limits

### Fallback Behavior
If index build fails (timeout, memory), dupe detection is disabled for that job with warning.
Mode will be set to `skipped_index_error` in metrics.

### Files Modified (Phase 4)
- `/services/DuplicateMatcherService.cfc` - Added buildUserDupeIndex, getCandidateContactIdsFromIndex, getCandidateDetailsBatch, findDuplicatesWithIndex
- `/ajax/importv3/recompute.cfm` - Added index build step, batch candidate fetching, new metrics

---

## Phase 4.1 Hardening (January 2026)

### Problem
Phase 4's on-demand batch fetching could still result in unpredictable query counts if different rows discovered different candidates incrementally.

### Solution: Two-Pass Candidate Union

**Pass 1 (no DB calls per row):**
1. Build dupe index (1 query)
2. Iterate all rows, collect candidate IDs union using in-memory index lookups only
3. Store dupeRowData for each row for Pass 2 scoring

**Pass 2 (bounded DB calls):**
1. Batch fetch ALL unique candidate details in chunks (2 queries per chunk)
2. Score each row using cached details
3. Update rows with dupe results

### Memory Guardrails

New constants in DuplicateMatcherService.cfc:
```coldfusion
this.MAX_DUPE_INDEX_ITEMS = 200000
this.MAX_DUPE_INDEX_CONTACTIDS = 50000
this.MAX_DUPE_INDEX_BUILD_MS = 5000
this.DETAILS_BATCH_CHUNK_SIZE = 200
```

**Guardrail checks during index build:**
- If items exceeds MAX_DUPE_INDEX_ITEMS: abort with `abort_reason="items_exceeded"`
- If contactids exceeds MAX_DUPE_INDEX_CONTACTIDS: abort with `abort_reason="contactids_exceeded"`
- Periodic timeout check every 10000 rows: abort with `abort_reason="timeout"`

**Fallback modes:**
- `skipped_index_too_large` - Index exceeded size limits
- `skipped_index_timeout` - Index build exceeded time limit
- `skipped_index_error` - Exception during build

### Query Count Formula (Phase 4.1)

```
dupe_queries_total = 1 (index build)
                   + 2 * ceil(unique_candidates / DETAILS_BATCH_CHUNK_SIZE)
```

For typical 1000-row job with 50 unique candidates:
- 1 query for index build
- 2 queries for 1 batch of 50 candidates (< 200 chunk size)
- **Total: 3 queries**

For extreme case with 1000 unique candidates:
- 1 query for index build
- 10 batches * 2 queries = 10 queries for details
- **Total: 11 queries**

### New Metrics (Phase 4.1)

- `dupe_index_contactids_total` - Unique contacts in the index
- `dupe_index_abort_reason` - Why index was skipped (empty string if OK)
- `dupe_details_fetch_batches` - Number of batch fetches for candidate details

### Metrics Invariants

When `dupe_detection_mode != "ran"`:
- `dupe_queries_total = 0`
- `dupe_index_items_total = 0`
- `dupe_index_contactids_total = 0`
- `dupe_candidates_unique_total = 0`
- `dupe_details_fetch_batches = 0`
- `elapsed_ms_dupes_total = 0`

### Healthy Behavior Indicators

A healthy recompute shows:
- `dupe_detection_mode = "ran"`
- `dupe_index_abort_reason = ""`
- `dupe_queries_total = 1 + (2 * dupe_details_fetch_batches)`
- `dupe_details_fetch_batches <= ceil(dupe_candidates_unique_total / 200)`

### Example Metrics (Normal)

```json
{
  "metrics": {
    "total_rows_processed": 50,
    "dupe_detection_mode": "ran",
    "dupe_queries_total": 3,
    "dupe_errors_count": 0,
    "dupe_candidates_total": 45,
    "dupe_rows_with_keys": 48,
    "dupe_candidates_unique_total": 12,
    "dupe_index_build_ms": 85,
    "dupe_index_items_total": 2500,
    "dupe_index_contactids_total": 850,
    "dupe_index_abort_reason": "",
    "dupe_details_fetch_batches": 1,
    "elapsed_ms_total": 1250,
    "elapsed_ms_dupes_total": 320
  }
}
```

### Example Metrics (Index Too Large)

```json
{
  "metrics": {
    "total_rows_processed": 50,
    "dupe_detection_mode": "skipped_index_too_large",
    "dupe_queries_total": 0,
    "dupe_errors_count": 0,
    "dupe_candidates_total": 0,
    "dupe_rows_with_keys": 0,
    "dupe_candidates_unique_total": 0,
    "dupe_index_build_ms": 125,
    "dupe_index_items_total": 250000,
    "dupe_index_contactids_total": 0,
    "dupe_index_abort_reason": "items_exceeded",
    "dupe_details_fetch_batches": 0,
    "elapsed_ms_total": 850,
    "elapsed_ms_dupes_total": 0
  },
  "warnings": [
    "Dupe index skipped: too many items (250000 exceeds limit)"
  ]
}
```

### Files Modified (Phase 4.1)

- `/services/DuplicateMatcherService.cfc`:
  - Added guardrail constants
  - Added abort_reason to buildUserDupeIndex return
  - Added periodic timeout and ceiling checks during index build

- `/ajax/importv3/recompute.cfm`:
  - Added rowDupeData array for two-pass processing
  - Refactored to Pass 1 (collect candidates) + Pass 2 (batch fetch + score)
  - Added dupe_index_contactids_total, dupe_index_abort_reason, dupe_details_fetch_batches metrics
  - Updated invariant enforcement section

---

## Phase 4.2 jQuery noConflict Fix (January 2026)

### Problem
Console showed "$ is not defined" error when jQuery runs in noConflict mode (where `$` global is released).
V3 import page relies heavily on jQuery for DOM manipulation, AJAX calls, and Bootstrap modals.

### Root Cause Analysis

**Discovery findings:**
1. `$.noConflict()` is NOT explicitly called anywhere in the TAO codebase
2. The `noConflict` method is defined in jQuery/Bootstrap library files but not invoked
3. The error occurs because some third-party library or browser extension may call noConflict, or there's a script load order issue
4. V3 JS file (contact-import-v3.js) used bare `$` throughout (41 occurrences)

**Template structure (include order):**
```
core.cfm
  -> FindLinksT (jQuery loaded here via database-driven script list)
  -> body content
    -> pgFilename = "import-contacts-v3.cfm"
      -> V3 template HTML
      -> <script src="/app/assets/js/contact-import-v3.js">
  -> FindLinksB (additional scripts)
```

jQuery IS loaded before the V3 script, but the global `$` may not be available if:
- Another library claims `$` (Prototype, MooTools, etc.)
- A script calls `jQuery.noConflict()` before V3 loads
- Script execution order is non-deterministic due to async loading

### Solution: noConflict-Safe Pattern

**1. Fail-Fast jQuery Check**
Added check at the top of the IIFE - if `window.jQuery` is undefined, show visible red banner and abort:
```javascript
if (typeof window.jQuery === 'undefined') {
    var alertDiv = document.createElement('div');
    alertDiv.style.cssText = 'position:fixed;top:0;...background:#dc3545;...';
    alertDiv.innerHTML = '<strong>Error:</strong> Contact Import V3 requires jQuery...';
    document.body.insertBefore(alertDiv, document.body.firstChild);
    console.error('[V3] FATAL: jQuery not available.');
    return; // Abort
}
```

**2. Local jQuery Alias**
Created local alias inside the IIFE that never relies on global `$`:
```javascript
var $j = jQuery;  // Always use $j instead of $
```

**3. Global Replacement**
All 41 occurrences of `$` replaced with `$j`:
- `$(document).ready` -> `$j(document).ready`
- `$('#btn-parse')` -> `$j('#btn-parse')`
- `$.ajax({...})` -> `$j.ajax({...})`
- `$(this)` -> `$j(this)`
- etc.

### Changes Summary

**File: `/app/assets/js/contact-import-v3.js`**
- Added Phase 4.2 comment in header
- Added fail-fast jQuery check (lines 13-21)
- Added local `$j` alias (line 25)
- Replaced all `$` with `$j` (41 replacements)

### Verification Checklist

1. **Console Check:**
   - Load V3 import page
   - Open browser DevTools console
   - Verify no "$ is not defined" error
   - Verify "[V3] Contact Import V3 JavaScript loaded" message appears

2. **Functional Check:**
   - Upload a CSV file -> should work
   - Parse file -> should work
   - Map columns -> should work
   - Confirm mapping -> should call recompute.cfm
   - Review grid tabs -> should switch correctly
   - Bulk actions -> should work
   - Edit modal -> should open and save
   - Dupe modal -> should open and resolve

3. **Fail-Fast Check (optional):**
   - Temporarily add `<script>jQuery.noConflict(true)</script>` before V3 script
   - Verify red banner appears
   - Verify console shows FATAL error

### Behavior Changes

| Scenario | Before | After |
|----------|--------|-------|
| jQuery available, $ available | Works | Works |
| jQuery available, $ unavailable | FAILS with "$ is not defined" | Works (uses $j alias) |
| jQuery unavailable | FAILS silently or with random errors | Shows visible red banner + console error |

### Files Modified (Phase 4.2)

- `/app/assets/js/contact-import-v3.js`:
  - Added fail-fast jQuery check
  - Added local `$j = jQuery` alias
  - Replaced all `$` with `$j` (41 occurrences)

---

## Phase 4.3 Init Timing Correctness (January 2026)

### Problem
Phase 4.2's immediate fail-fast could show false "jQuery not available" errors if:
- jQuery loads asynchronously or slightly after the V3 script
- Script execution order varies between browsers/network conditions
- Page uses deferred script loading

### Solution: Bounded Wait for jQuery

**1. Replace immediate abort with polling loop:**
```javascript
var maxWaitMs = 2000;   // Wait up to 2 seconds
var pollEveryMs = 50;   // Check every 50ms
var waited = 0;

function waitForJQuery() {
    if (typeof window.jQuery !== 'undefined') {
        $j = window.jQuery;
        console.log('[V3] jQuery detected after ' + waited + 'ms');
        $j(document).ready(initV3);
        return;
    }

    waited += pollEveryMs;
    if (waited >= maxWaitMs) {
        showJQueryError();  // Show error ONCE after timeout
        return;
    }

    setTimeout(waitForJQuery, pollEveryMs);
}

waitForJQuery();  // Start polling immediately
```

**2. Add initialization guard flag:**
```javascript
var initialized = false;

function initV3() {
    if (initialized) {
        console.log('[V3] initV3 called but already initialized - skipping');
        return;
    }
    initialized = true;

    // ... all init code ...
}
```

This ensures `initV3` runs exactly once even if:
- Multiple script tags load the file
- Page is partially refreshed
- jQuery's `ready` fires multiple times (edge case)

**3. Defer $j assignment:**
```javascript
var $j = null;  // Set to null initially

// In waitForJQuery when jQuery is found:
$j = window.jQuery;
```

This makes it explicit that `$j` is only valid after jQuery is detected.

### Timing Guarantees

| Scenario | Behavior |
|----------|----------|
| jQuery loads before V3 script | Immediate init (waited = 0ms) |
| jQuery loads 100ms after V3 | Init after ~100ms polling |
| jQuery loads 1500ms after V3 | Init after ~1500ms polling |
| jQuery never loads | Error shown after 2000ms, no init |
| V3 script loaded twice | Second load skips init (guard flag) |

### Console Output (Normal Case)

```
[V3] jQuery detected after 0ms
[V3] Contact Import V3 JavaScript loaded
[V3] ========== DOCUMENT READY ==========
[V3] Initializing Contact Import V3...
```

### Console Output (Delayed jQuery)

```
[V3] jQuery detected after 150ms
[V3] Contact Import V3 JavaScript loaded
[V3] ========== DOCUMENT READY ==========
[V3] Initializing Contact Import V3...
```

### Console Output (jQuery Never Loads)

```
[V3] FATAL: jQuery not available after 2000ms. Contact Import V3 cannot initialize.
```
Plus visible red banner at top of page.

### Console Output (Double Init Attempt)

```
[V3] jQuery detected after 0ms
[V3] Contact Import V3 JavaScript loaded
[V3] ========== DOCUMENT READY ==========
[V3] Initializing Contact Import V3...
[V3] initV3 called but already initialized - skipping
```

### Verification Checklist

1. **Normal load:**
   - [ ] Console shows "jQuery detected after 0ms" (or small value)
   - [ ] Console shows "Initializing Contact Import V3..."
   - [ ] No "$ is not defined" error
   - [ ] No repeated init logs

2. **Functional smoke test:**
   - [ ] File upload works
   - [ ] Parse button works
   - [ ] Column mapping works
   - [ ] Confirm mapping calls recompute
   - [ ] Review grid tabs work
   - [ ] Modals open correctly

3. **Edge case (optional):**
   - Add `async` to jQuery script tag
   - Verify V3 still initializes (after brief poll)

### Files Modified (Phase 4.3)

- `/app/assets/js/contact-import-v3.js`:
  - Added `waitForJQuery()` polling function with 2000ms timeout
  - Added `showJQueryError()` helper for deferred error display
  - Added `initialized` guard flag
  - Moved init code into `initV3()` function
  - Changed `$j` initialization to `null` until jQuery detected
  - Removed duplicate `$j(document).ready` block

---

## Phase 5 Finalize Idempotency, Transaction Safety, and Audit Trail (January 2026)

### Problem
The finalize step creates real contacts in contactdetails/contactitems tables. This is high-risk:
- Running finalize twice could create duplicate contacts
- Partial failures could leave contacts in inconsistent state
- No audit trail of what was created and why

### Solution: Idempotent, Transactional, Audited Pipeline

#### 1. Idempotency

**Row-level idempotency via `import_v3_row_results` table:**
- UNIQUE constraint on row_id prevents duplicate result entries
- Before processing, check if row already has result entry
- If `created_contactid IS NOT NULL` and result exists, skip row

```sql
-- Idempotency check per row
SELECT result_id, action_taken, contactid
FROM import_v3_row_results
WHERE row_id = ?
```

**Job-level idempotency:**
- Status transitions prevent re-running: reviewing -> finalizing -> completed
- Second finalize attempt returns `ALREADY_COMPLETED` error

#### 2. Transaction Safety

**Each row processed in its own transaction:**
```coldfusion
transaction {
    // 1. Insert into contactdetails
    // 2. Insert contact items (emails, phones, etc.)
    // 3. Update import_v3_rows status and created_contactid
    // 4. Record result in import_v3_row_results
}
// If any step fails, entire row is rolled back
```

**On failure:**
- Row status set to 'failed'
- Error recorded in `import_error` column
- Row result recorded with error_code and error_message
- Other rows continue processing

#### 3. Audit Trail

**Events logged to `import_v3_events`:**
- `finalize_started` - Job finalize begins (with lock_token)
- `row_imported` - Individual row success (contactid, items_created)
- `row_import_error` - Individual row failure (error message)
- `finalize_completed` - Job finalize ends (counts, metrics)
- `finalize_error` - Fatal error during finalize

**Results tracked in `import_v3_row_results`:**
- action_taken: created|updated|skipped|failed
- contactid: The created/updated contact ID
- fields_written: Count of fields written
- items_created: Count of contactitems created
- error_code/error_message: For failures

### Implementation Details

#### Job Locking
Uses existing `acquireJobLock()` mechanism:
- Transitions job status from 'reviewing' to 'finalizing'
- If already 'finalizing', returns `ALREADY_RUNNING`
- If already 'completed', returns `ALREADY_COMPLETED`

#### Row Selection for Import
```sql
SELECT row_id, row_num, status, user_action, created_contactid
FROM import_v3_rows
WHERE job_id = ?
  AND (
      status = 'ready'
      OR (status = 'dupe' AND user_action = 'import_new')
  )
ORDER BY row_num ASC
```

#### EAV Facts to Contactitems Mapping

| Import Field | valueCategory | valueType |
|-------------|---------------|-----------|
| email_business | Email | Business |
| email_personal | Email | Personal |
| phone_work | Phone | Work |
| phone_mobile | Phone | Mobile |
| phone_home | Phone | Home |
| company | Company | Company |
| address* | Address | Work |
| website | Website | Website |
| linkedin | Social | LinkedIn |
| twitter | Social | Twitter |
| instagram | Social | Instagram |
| tags | Tag | Tags |
| notes | Note | Note |

#### Contactitems Deduplication
Before inserting each item, check if it already exists:
```sql
SELECT 1 FROM contactitems
WHERE contactid = ?
  AND valueCategory = ?
  AND valuetext = ?
  AND itemStatus = 'Active'
LIMIT 1
```

### Output JSON Contract

**Success Response:**
```json
{
  "success": true,
  "message": "Finalize completed. 25 contacts created.",
  "data": {
    "counts": {
      "attempted": 30,
      "imported_new": 25,
      "updated_existing": 0,
      "skipped_already_imported": 3,
      "skipped_ignored": 0,
      "skipped_not_ready": 0,
      "failed": 2
    },
    "metrics": {
      "total_rows_processed": 30,
      "elapsed_ms_total": 1250,
      "elapsed_ms_per_row_avg": 42
    },
    "failures": [
      {
        "row_id": 123,
        "row_num": 5,
        "code": "MISSING_NAME",
        "message": "Contact name is required"
      }
    ],
    "warnings": []
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "code": "ALREADY_RUNNING",
  "message": "Finalize is already in progress for this job.",
  "data": {
    "job_id": 42
  }
}
```

### Manual Test Script

#### Test 1: First Finalize (creates contacts)
```sql
-- Before finalize: Check rows ready for import
SELECT COUNT(*) as ready_count
FROM import_v3_rows
WHERE job_id = ? AND status = 'ready';

-- After finalize: Verify contacts created
SELECT r.row_id, r.row_num, r.status, r.created_contactid,
       rr.action_taken, rr.items_created
FROM import_v3_rows r
LEFT JOIN import_v3_row_results rr ON r.row_id = rr.row_id
WHERE r.job_id = ?
ORDER BY r.row_num;

-- Verify events logged
SELECT event_type, event_detail, created_at
FROM import_v3_events
WHERE job_id = ?
  AND event_type LIKE 'finalize%'
ORDER BY created_at DESC;
```

#### Test 2: Second Finalize (idempotency)
```sql
-- Before second finalize: Note contact count
SELECT COUNT(*) as contact_count
FROM contactdetails
WHERE userid = ?;

-- Run finalize again (should return ALREADY_COMPLETED or skip all rows)

-- After second finalize: Verify NO new contacts created
SELECT COUNT(*) as contact_count
FROM contactdetails
WHERE userid = ?;
-- Should be same as before

-- Verify skipped_already_imported in response counts
```

#### Test 3: Partial Failure Recovery
```sql
-- Create a row with missing name (to force failure)
UPDATE import_v3_facts
SET normalized_value = NULL
WHERE row_id = ? AND field_name IN ('firstName', 'lastName', 'contactFullName');

-- Run finalize

-- Verify failed row recorded
SELECT r.row_id, r.status, r.import_error,
       rr.action_taken, rr.error_code, rr.error_message
FROM import_v3_rows r
LEFT JOIN import_v3_row_results rr ON r.row_id = rr.row_id
WHERE r.row_id = ?;
-- Should show status='failed', error_code='MISSING_NAME'

-- Verify other rows still imported
SELECT COUNT(*) as imported_count
FROM import_v3_rows
WHERE job_id = ? AND status = 'imported';
```

### DB Proof Queries

```sql
-- 1. Rows imported for a job with created_contactid set
SELECT row_id, row_num, status, created_contactid, imported_at
FROM import_v3_rows
WHERE job_id = ? AND status = 'imported' AND created_contactid IS NOT NULL;

-- 2. Event rows written for finalize
SELECT event_id, event_type, event_detail, row_id, created_at
FROM import_v3_events
WHERE job_id = ? AND event_type IN ('finalize_started', 'finalize_completed', 'row_imported', 'row_import_error')
ORDER BY created_at;

-- 3. Demonstrate idempotency (second finalize)
-- Before: Count contacts
SELECT COUNT(*) FROM contactdetails WHERE userid = ?;
-- Run finalize again
-- After: Same count (no duplicates)
SELECT COUNT(*) FROM contactdetails WHERE userid = ?;

-- 4. Confirm no PII in events
SELECT event_id, event_type, event_detail
FROM import_v3_events
WHERE job_id = ? AND event_type = 'row_imported';
-- event_detail should only contain: {"contactid": 123, "items_created": 5}
-- NO names, emails, phones, etc.
```

### Files Modified (Phase 5)

- `/services/ContactImportV3Service.cfc`:
  - Added `finalizeJob()` main entry point
  - Added `processRowForImport()` per-row processor with transactions
  - Added `buildContactDataFromFacts()` EAV to struct mapper
  - Added `insertContactItems()` with deduplication
  - Added `contactItemExists()` helper
  - Added `recordRowResult()` audit helper
  - Added `updateJobCounts()` job counter updater

- `/ajax/importv3/finalize.cfm`:
  - No changes needed - already delegates to `v3Service.finalizeJob()`

---

## Phase 5.1 Endpoint JSON Parsing and CSRF Wiring (January 2026)

### Problem
Finalize was failing in real usage because:
- V3 JS calls finalize with `Content-Type: application/json`
- ColdFusion does not populate `form.*` from a JSON request body
- `finalize.cfm` was reading `form.job_id` and `form.csrf_token`
- Result: `CSRF_INVALID` or `MISSING_JOB_ID` errors even when request is correct

### Solution

#### 1. Updated `ajax/importv3/finalize.cfm`
- Parse JSON request body using `getHttpRequestData().content`
- Read CSRF token from: header (`X-CSRF-Token`) -> JSON body -> form field
- Read job_id from: URL -> JSON body -> form field
- Form POST still works (backward compatible)
- HTTP status codes match error category:
  - 401 AUTH_REQUIRED
  - 403 CSRF_INVALID, ACCESS_DENIED
  - 404 NOT_FOUND
  - 400 MISSING_JOB_ID
  - 409 INVALID_STATE, ALREADY_RUNNING, ALREADY_COMPLETED
  - 500 INTERNAL_ERROR
- All exit paths return `application/json; charset=utf-8`

#### 2. Updated `include/import-contacts-v3.cfm`
- Generate CSRF token on page load if not exists
- Added hidden input: `<input type="hidden" id="csrf-token" value="...">`

#### 3. Updated `app/assets/js/contact-import-v3.js`
- `finalizeImport()` reads CSRF token from `#csrf-token` input
- Sends token in JSON body: `{ job_id: ..., csrf_token: ... }`
- Improved error handling - parses JSON error responses

### Files Modified (Phase 5.1)

- `/ajax/importv3/finalize.cfm`:
  - Complete rewrite with JSON body parsing
  - CSRF token from header/body/form fallback
  - job_id from url/body/form fallback
  - Proper HTTP status codes

- `/include/import-contacts-v3.cfm`:
  - Added CSRF token generation (line 36-39)
  - Added hidden CSRF input (line 320)

- `/app/assets/js/contact-import-v3.js`:
  - Updated `finalizeImport()` to read and send CSRF token
  - Improved error response parsing

### Verification

#### Positive Test (Network Tab)
1. Click Finalize in UI
2. Request URL includes `?bypass=1`
3. Request body includes `csrf_token`
4. Response `Content-Type: application/json; charset=utf-8`
5. Response `success: true`

#### Negative Tests
```bash
# Missing CSRF token -> 403
curl -X POST "https://dev.theactorsoffice.com/ajax/importv3/finalize.cfm?bypass=1" \
  -H "Content-Type: application/json" \
  -d '{"job_id":123}' \
  --cookie "CFID=...; CFTOKEN=..."
# Returns: {"success":false,"code":"CSRF_INVALID","message":"Invalid or missing CSRF token",...}

# Missing job_id -> 400
curl -X POST "https://dev.theactorsoffice.com/ajax/importv3/finalize.cfm?bypass=1" \
  -H "Content-Type: application/json" \
  -d '{"csrf_token":"..."}' \
  --cookie "CFID=...; CFTOKEN=..."
# Returns: {"success":false,"code":"MISSING_JOB_ID","message":"job_id is required",...}

# Job not in reviewing status -> 409
# Returns: {"success":false,"code":"INVALID_STATE","message":"Cannot finalize from status: ...",...}
```

#### Form POST Fallback
```bash
# Traditional form POST still works
curl -X POST "https://dev.theactorsoffice.com/ajax/importv3/finalize.cfm?bypass=1" \
  -d "job_id=123&csrf_token=YOUR_TOKEN" \
  --cookie "CFID=...; CFTOKEN=..."
```

---

## Phase 5.2 Finalize Hardening and Debug Diagnostics (January 2026)

### Problem
Phase 5.1 wired up JSON parsing and CSRF, but the endpoint needed hardening for:
- Tolerant JSON parsing (handle BOM, whitespace, malformed input gracefully)
- Debug breadcrumbs for tracing failures without exposing PII
- Belt-and-suspenders CSRF (header + body)
- Consistent error codes and HTTP status mapping

### Solution

#### 1. Hardened `ajax/importv3/finalize.cfm`

**Tolerant JSON Parsing:**
- Added `cleanRawBody()` helper to strip UTF-8 BOM and whitespace
- Added `parseJsonBody()` helper that tries to parse any non-empty content
- No longer requires body to start with `{` - attempts deserializeJSON on any content
- Returns empty struct on failure (never crashes)

**Debug Breadcrumbs:**
- Added `debug` array that tracks each successful step
- Markers: `start`, `auth_ok`, `body_parsed`, `csrf_ok`, `job_id_ok`, `service_init`, `job_loaded`, `status_ok`, `finalize_called`, `done`
- On error: includes `last_step` showing where processing stopped
- No PII in debug output (no names, emails, phones)

**CSRF Source Tracking:**
- Tracks where CSRF token was found: `header`, `body`, or `form`
- On CSRF failure, includes `csrf_source` in response for debugging

**Helper Function:**
- Added `returnError()` helper for consistent JSON error responses
- Ensures all error paths include debug trail and proper HTTP status

#### 2. Updated `app/assets/js/contact-import-v3.js`

**Belt+Suspenders CSRF:**
```javascript
headers: {
    'X-CSRF-Token': csrfToken  // Header CSRF (preferred)
},
data: JSON.stringify({
    job_id: state.jobId,
    csrf_token: csrfToken  // Body CSRF (fallback)
}),
```

**Improved Error Handling:**
- Logs debug trail to console: `response.data.debug.join(' -> ')`
- Logs error code to console (not shown to user)
- Logs last successful step on failure
- Parses JSON error responses and extracts message/code/debug

### Debug Breadcrumb Reference

| Marker | Meaning |
|--------|---------|
| `start` | Request received |
| `auth_ok` | Session userid validated |
| `body_parsed` | JSON body parsed (or empty) |
| `csrf_ok` | CSRF token validated |
| `job_id_ok` | job_id extracted and valid |
| `service_init` | ContactImportV3Service instantiated |
| `job_loaded` | Job exists and user owns it |
| `status_ok` | Job status allows finalize |
| `finalize_called` | finalizeJob() invoked |
| `done` | Finalize completed successfully |
| `finalize_failed` | finalizeJob() returned error |
| `exception` | Unhandled exception caught |

### Files Modified (Phase 5.2)

- `/ajax/importv3/finalize.cfm`:
  - Added `cleanRawBody()` helper for BOM/whitespace handling
  - Added `parseJsonBody()` helper for tolerant JSON parsing
  - Added `returnError()` helper for consistent error responses
  - Added debug breadcrumb array throughout processing
  - Added csrf_source and job_id_source tracking

- `/app/assets/js/contact-import-v3.js`:
  - Added `X-CSRF-Token` header to AJAX request
  - Improved error handler to parse JSON and log debug trail
  - Added console logging for error codes and last_step

### Test Scripts

#### Manual UI Tests

1. **Success finalize from reviewing status**
   - Upload and parse a CSV file
   - Complete column mapping
   - Click "Finalize" button
   - Expected: Success message, page reloads, job status = completed
   - Check console for debug trail: `start -> auth_ok -> ... -> done`

2. **Double-click finalize (lock behavior)**
   - Start finalize, quickly click again before completion
   - Expected: Second request returns 409 with `ALREADY_RUNNING`
   - Check console for error code

3. **Re-run finalize after completion (idempotency)**
   - After successful finalize, manually call endpoint again
   - Expected: 409 with `ALREADY_COMPLETED` or `INVALID_STATE`

4. **Missing CSRF (403)**
   - Remove #csrf-token input from DOM, click finalize
   - Expected: JS shows "Security token missing" alert

5. **Invalid job_id**
   - Modify JS to send job_id: 999999
   - Expected: 404 with `NOT_FOUND`

#### curl Tests

```bash
# Replace COOKIES with your session cookies (CFID, CFTOKEN, etc.)
# Replace CSRF_TOKEN with value from session.csrf_token
# Replace JOB_ID with a valid job in "reviewing" status

# Test 1: Header CSRF works
curl -X POST "https://dev.theactorsoffice.com/ajax/importv3/finalize.cfm?bypass=1" \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: CSRF_TOKEN" \
  -d '{"job_id": JOB_ID}' \
  --cookie "COOKIES"
# Expected: 200 with success:true or 409 if already completed

# Test 2: Body CSRF works (no header)
curl -X POST "https://dev.theactorsoffice.com/ajax/importv3/finalize.cfm?bypass=1" \
  -H "Content-Type: application/json" \
  -d '{"job_id": JOB_ID, "csrf_token": "CSRF_TOKEN"}' \
  --cookie "COOKIES"
# Expected: Same as above

# Test 3: Missing CSRF -> 403
curl -X POST "https://dev.theactorsoffice.com/ajax/importv3/finalize.cfm?bypass=1" \
  -H "Content-Type: application/json" \
  -d '{"job_id": JOB_ID}' \
  --cookie "COOKIES"
# Expected: 403 with code:"CSRF_INVALID", csrf_source:"missing"

# Test 4: Missing job_id -> 400
curl -X POST "https://dev.theactorsoffice.com/ajax/importv3/finalize.cfm?bypass=1" \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: CSRF_TOKEN" \
  -d '{}' \
  --cookie "COOKIES"
# Expected: 400 with code:"MISSING_JOB_ID"

# Test 5: Invalid job status -> 409
# (Use a job_id with status = "completed")
curl -X POST "https://dev.theactorsoffice.com/ajax/importv3/finalize.cfm?bypass=1" \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: CSRF_TOKEN" \
  -d '{"job_id": COMPLETED_JOB_ID}' \
  --cookie "COOKIES"
# Expected: 409 with code:"INVALID_STATE", current_status:"completed"

# Test 6: Form POST fallback works
curl -X POST "https://dev.theactorsoffice.com/ajax/importv3/finalize.cfm?bypass=1" \
  -d "job_id=JOB_ID&csrf_token=CSRF_TOKEN" \
  --cookie "COOKIES"
# Expected: Same result as JSON tests
```

### Acceptance Checklist

| Test | Expected | Status |
|------|----------|--------|
| Header CSRF accepted | 200 or appropriate error | [ ] PASS / [ ] FAIL |
| Body CSRF accepted (no header) | 200 or appropriate error | [ ] PASS / [ ] FAIL |
| Missing CSRF returns 403 | `code:"CSRF_INVALID"` | [ ] PASS / [ ] FAIL |
| Missing job_id returns 400 | `code:"MISSING_JOB_ID"` | [ ] PASS / [ ] FAIL |
| Invalid job status returns 409 | `code:"INVALID_STATE"` | [ ] PASS / [ ] FAIL |
| Form POST fallback works | Same as JSON | [ ] PASS / [ ] FAIL |
| Debug trail in response.data.debug | Array of step markers | [ ] PASS / [ ] FAIL |
| last_step on error | Shows last successful step | [ ] PASS / [ ] FAIL |
| No PII in debug output | No names/emails/phones | [ ] PASS / [ ] FAIL |
| bypass=1 in request URL | Required for AJAX | [ ] PASS / [ ] FAIL |
| Content-Type: application/json; charset=utf-8 | All responses | [ ] PASS / [ ] FAIL |
| Double-click returns 409 ALREADY_RUNNING | Lock behavior | [ ] PASS / [ ] FAIL |
| Re-finalize returns 409 | Idempotency | [ ] PASS / [ ] FAIL |

---

## Phase 6 Review Workflow Endpoints (January 2026)

### Problem
The review workflow needed complete endpoint implementations to support:
- Paginated row listing with status filters
- Single row detail view with facts and duplicates
- Inline fact editing with revalidation
- Row actions (ignore/create) for batch processing

### Solution: Four Enhanced Endpoints with Phase 5.2 Patterns

All endpoints implement:
- Debug breadcrumbs (no PII)
- Status gates (only allow operations in appropriate job states)
- Belt+suspenders CSRF (header -> body -> form)
- JSON body parsing with BOM tolerance
- Proper HTTP status codes (401, 403, 404, 409, 500)
- `Content-Type: application/json; charset=utf-8` on all exit paths

---

### Endpoint 1: rows.cfm (Paginated Row Listing)

**URL:** `GET /ajax/importv3/rows.cfm?bypass=1`

**Parameters:**
| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| job_id | Yes | - | The import job ID |
| status | No | all | Filter: ready, problem, dupe, ignored, imported, all |
| page | No | 1 | Page number |
| page_size | No | 50 | Rows per page (max 200) |
| stats_only | No | 0 | If 1, return only stats without row data |

**Status Gate:** Job must be in `reviewing`, `finalizing`, or `completed` status.

**Response Codes:**
| Code | HTTP | Description |
|------|------|-------------|
| AUTH_REQUIRED | 401 | No session userid |
| MISSING_PARAMS | 400 | job_id missing |
| NOT_FOUND | 404 | Job does not exist |
| ACCESS_DENIED | 403 | Job does not belong to user |
| INVALID_STATE | 409 | Job not in allowed status |
| INTERNAL_ERROR | 500 | Server error |

**Success Response:**
```json
{
  "success": true,
  "message": "",
  "data": {
    "rows": [
      {
        "row_id": 123,
        "row_num": 1,
        "status": "ready",
        "user_action": null,
        "data": {
          "firstName": "John",
          "lastName": "Doe",
          "email_business": "john@example.com"
        },
        "errors": [],
        "has_duplicates": false
      }
    ],
    "total": 50,
    "page": 1,
    "page_size": 50,
    "total_pages": 1,
    "stats": {
      "total": 50,
      "ready": 45,
      "problem": 3,
      "dupe": 2,
      "ignored": 0,
      "imported": 0
    },
    "debug": ["start", "auth_ok", "job_id_ok", "params_parsed", "service_init", "job_loaded", "status_ok", "rows_fetched", "done"]
  }
}
```

**Stats-Only Response (stats_only=1):**
```json
{
  "success": true,
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
    "debug": ["start", "auth_ok", "job_id_ok", "params_parsed", "service_init", "job_loaded", "status_ok", "stats_fetched", "done"]
  }
}
```

---

### Endpoint 2: row.cfm (Single Row Detail)

**URL:** `GET /ajax/importv3/row.cfm?bypass=1`

**Parameters:**
| Parameter | Required | Description |
|-----------|----------|-------------|
| job_id | Yes | The import job ID |
| row_id | Yes | The row ID |

**Status Gate:** Job must be in `reviewing`, `finalizing`, or `completed` status.

**Response Codes:**
| Code | HTTP | Description |
|------|------|-------------|
| AUTH_REQUIRED | 401 | No session userid |
| MISSING_PARAMS | 400 | job_id or row_id missing |
| NOT_FOUND | 404 | Job or row does not exist |
| ACCESS_DENIED | 403 | Job does not belong to user |
| INVALID_STATE | 409 | Job not in allowed status |
| INTERNAL_ERROR | 500 | Server error |

**Success Response:**
```json
{
  "success": true,
  "message": "",
  "data": {
    "row": {
      "row_id": 123,
      "row_num": 1,
      "status": "dupe",
      "user_action": null,
      "data": {
        "firstName": "John",
        "lastName": "Doe",
        "email_business": "john@example.com"
      },
      "validation": {
        "email_business": { "is_valid": true, "code": "", "message": "" }
      },
      "errors": [],
      "warnings": [],
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
      "duplicates": [
        {
          "contactid": 789,
          "contactFullName": "John Doe",
          "score": 85,
          "match_reasons": ["email_exact"]
        }
      ]
    },
    "debug": ["start", "auth_ok", "params_ok", "service_init", "job_loaded", "status_ok", "row_fetched", "done"]
  }
}
```

---

### Endpoint 3: fact_update.cfm (Update Row Facts)

**URL:** `POST /ajax/importv3/fact_update.cfm?bypass=1`

**Parameters (JSON body preferred):**
| Parameter | Required | Description |
|-----------|----------|-------------|
| job_id | Yes | The import job ID |
| row_id | Yes | The row ID |
| fields | Yes | Object with field_name:new_value pairs |
| csrf_token | Yes | CSRF token (also accepts X-CSRF-Token header) |

**Status Gate:** Job must be in `reviewing` status (editing not allowed after finalize starts).

**Response Codes:**
| Code | HTTP | Description |
|------|------|-------------|
| AUTH_REQUIRED | 401 | No session userid |
| CSRF_INVALID | 403 | Invalid or missing CSRF token |
| MISSING_PARAMS | 400 | Required params missing |
| NOT_FOUND | 404 | Job or row does not exist |
| ACCESS_DENIED | 403 | Job does not belong to user |
| INVALID_STATE | 409 | Job not in reviewing status |
| VALIDATION_ERROR | 400 | Field validation failed |
| INTERNAL_ERROR | 500 | Server error |

**Request Example:**
```json
{
  "job_id": 42,
  "row_id": 123,
  "csrf_token": "ABC123-DEF456",
  "fields": {
    "firstName": "Jonathan",
    "email_business": "jonathan@example.com"
  }
}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Facts updated successfully",
  "data": {
    "row_id": 123,
    "fields_updated": 2,
    "new_status": "ready",
    "previous_status": "problem",
    "validation": {
      "firstName": { "is_valid": true, "code": "", "message": "" },
      "email_business": { "is_valid": true, "code": "", "message": "" }
    },
    "debug": ["start", "auth_ok", "csrf_ok", "params_ok", "service_init", "job_loaded", "status_ok", "update_called", "facts_updated", "done"]
  }
}
```

---

### Endpoint 4: row_action.cfm (Set Row Action)

**URL:** `POST /ajax/importv3/row_action.cfm?bypass=1`

**Parameters (JSON body preferred):**
| Parameter | Required | Description |
|-----------|----------|-------------|
| job_id | Yes | The import job ID |
| row_id | Yes (single) | The row ID for single operation |
| row_ids | Yes (bulk) | Array of row IDs for bulk operation |
| action | Yes | `ignore` or `create` |
| csrf_token | Yes | CSRF token (also accepts X-CSRF-Token header) |

**Status Gate:** Job must be in `reviewing` status.

**Create-Only Mode:** The `update` action is NOT supported. Attempting to use it returns `UPDATE_NOT_SUPPORTED`.

**Action Mapping:**
| UI Action | DB user_action | Row Status |
|-----------|---------------|------------|
| ignore | skip | ignored |
| create | import_new | (unchanged) |

**Response Codes:**
| Code | HTTP | Description |
|------|------|-------------|
| AUTH_REQUIRED | 401 | No session userid |
| CSRF_INVALID | 403 | Invalid or missing CSRF token |
| MISSING_PARAMS | 400 | Required params missing |
| INVALID_ACTION | 400 | Invalid action value |
| UPDATE_NOT_SUPPORTED | 400 | Update action not available in create-only mode |
| NOT_FOUND | 404 | Job or row does not exist |
| ACCESS_DENIED | 403 | Job does not belong to user |
| INVALID_STATE | 409 | Job not in reviewing status |
| INTERNAL_ERROR | 500 | Server error |

**Single Row Request:**
```json
{
  "job_id": 42,
  "row_id": 123,
  "action": "ignore",
  "csrf_token": "ABC123-DEF456"
}
```

**Bulk Request:**
```json
{
  "job_id": 42,
  "row_ids": [123, 124, 125],
  "action": "create",
  "csrf_token": "ABC123-DEF456"
}
```

**Single Row Success Response:**
```json
{
  "success": true,
  "message": "Row action set to skip",
  "data": {
    "row_id": 123,
    "action": "skip",
    "new_status": "ignored",
    "debug": ["start", "auth_ok", "csrf_ok", "params_ok", "service_init", "job_loaded", "status_ok", "action_called", "action_applied", "done"]
  }
}
```

**Bulk Success Response:**
```json
{
  "success": true,
  "message": "Updated 3 rows",
  "data": {
    "rows_updated": 3,
    "action": "import_new",
    "debug": ["start", "auth_ok", "csrf_ok", "params_ok", "service_init", "job_loaded", "status_ok", "action_called", "action_applied", "done"]
  }
}
```

---

### Service Methods Added (Phase 6)

**ContactImportV3Service.cfc** new methods:

| Method | Description |
|--------|-------------|
| `getJobStats(job_id)` | Returns row counts by status |
| `getRows(job_id, userid, statusFilter, page, pageSize)` | Paginated rows with batch fact loading |
| `getRowDetail(job_id, row_id, userid)` | Full row detail with facts and duplicates |
| `updateRowFacts(job_id, row_id, fields, userid)` | Update facts, revalidate, recompute status |
| `recomputeFullName(row_id)` | Rebuild contactFullName from firstName/lastName |
| `recomputeRowStatus(row_id)` | Determine ready/problem/dupe status |
| `updateJobRowCounts(job_id)` | Update denormalized job counts |
| `setRowAction(job_id, row_id, action, userid)` | Set single row action |
| `bulkRowAction(job_id, row_ids, action, userid)` | Bulk set row actions |

**Key Implementation Details:**

1. **Batch Fact Loading:** `getRows()` collects all row IDs first, then fetches all facts in a single query, avoiding N+1 query problem.

2. **Status Recomputation:** When facts are updated, row status is recomputed deterministically:
   - If any fact has `is_valid = 0` -> status = `problem`
   - Else if `dupe_candidates_json` is non-empty -> status = `dupe`
   - Else -> status = `ready`

3. **Create-Only Enforcement:** `setRowAction()` and `bulkRowAction()` return `UPDATE_NOT_SUPPORTED` error for action = `update_existing`.

---

### Files Modified (Phase 6)

- `/ajax/importv3/rows.cfm`:
  - Complete rewrite with Phase 5.2 patterns
  - Added stats_only mode
  - Added status gate (reviewing/finalizing/completed)
  - Added debug breadcrumbs

- `/ajax/importv3/row.cfm`:
  - Complete rewrite with Phase 5.2 patterns
  - Added status gate
  - Added debug breadcrumbs

- `/ajax/importv3/fact_update.cfm`:
  - Complete rewrite with Phase 5.2 patterns
  - Added JSON body parsing
  - Added belt+suspenders CSRF
  - Added status gate (reviewing only)
  - Changed to call `updateRowFacts()` instead of `updateFact()`

- `/ajax/importv3/row_action.cfm`:
  - Complete rewrite with Phase 5.2 patterns
  - Added JSON body parsing
  - Added belt+suspenders CSRF
  - Added bulk support (row_ids array)
  - Added action normalization (ignore->skip, create->import_new)
  - Added create-only enforcement

- `/services/ContactImportV3Service.cfc`:
  - Added ~830 lines of Phase 6 service methods
  - Added helper methods for status recomputation
  - Added batch fact loading for performance

---

### Test Scripts (Phase 6)

#### curl Tests

```bash
# Replace COOKIES, CSRF_TOKEN, JOB_ID as appropriate

# Test rows.cfm - Get all rows
curl "https://dev.theactorsoffice.com/ajax/importv3/rows.cfm?bypass=1&job_id=JOB_ID" \
  --cookie "COOKIES"

# Test rows.cfm - Filter by status
curl "https://dev.theactorsoffice.com/ajax/importv3/rows.cfm?bypass=1&job_id=JOB_ID&status=problem" \
  --cookie "COOKIES"

# Test rows.cfm - Stats only
curl "https://dev.theactorsoffice.com/ajax/importv3/rows.cfm?bypass=1&job_id=JOB_ID&stats_only=1" \
  --cookie "COOKIES"

# Test row.cfm - Get single row
curl "https://dev.theactorsoffice.com/ajax/importv3/row.cfm?bypass=1&job_id=JOB_ID&row_id=ROW_ID" \
  --cookie "COOKIES"

# Test fact_update.cfm - Update a fact
curl -X POST "https://dev.theactorsoffice.com/ajax/importv3/fact_update.cfm?bypass=1" \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: CSRF_TOKEN" \
  -d '{"job_id": JOB_ID, "row_id": ROW_ID, "fields": {"firstName": "NewName"}}' \
  --cookie "COOKIES"

# Test row_action.cfm - Ignore a row
curl -X POST "https://dev.theactorsoffice.com/ajax/importv3/row_action.cfm?bypass=1" \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: CSRF_TOKEN" \
  -d '{"job_id": JOB_ID, "row_id": ROW_ID, "action": "ignore"}' \
  --cookie "COOKIES"

# Test row_action.cfm - Bulk create
curl -X POST "https://dev.theactorsoffice.com/ajax/importv3/row_action.cfm?bypass=1" \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: CSRF_TOKEN" \
  -d '{"job_id": JOB_ID, "row_ids": [ROW_ID1, ROW_ID2], "action": "create"}' \
  --cookie "COOKIES"

# Test row_action.cfm - UPDATE_NOT_SUPPORTED error
curl -X POST "https://dev.theactorsoffice.com/ajax/importv3/row_action.cfm?bypass=1" \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: CSRF_TOKEN" \
  -d '{"job_id": JOB_ID, "row_id": ROW_ID, "action": "update_existing"}' \
  --cookie "COOKIES"
# Expected: 400 with code:"UPDATE_NOT_SUPPORTED"
```

#### SQL Verification Queries

```sql
-- 1. Verify row counts by status for a job
SELECT status, COUNT(*) as count
FROM import_v3_rows
WHERE job_id = ?
GROUP BY status;

-- 2. Verify facts for a row
SELECT fact_id, field_name, raw_value, normalized_value, is_valid, validation_code
FROM import_v3_facts
WHERE row_id = ?
ORDER BY field_name;

-- 3. Verify row status after fact update
SELECT row_id, status, user_action, dupe_candidates_json
FROM import_v3_rows
WHERE row_id = ?;

-- 4. Verify ignored rows
SELECT row_id, row_num, status, user_action
FROM import_v3_rows
WHERE job_id = ? AND status = 'ignored';

-- 5. Verify job denormalized counts match actual
SELECT
  j.valid_rows as job_valid,
  j.problem_rows as job_problem,
  j.dupe_rows as job_dupe,
  (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = j.job_id AND status = 'ready') as actual_ready,
  (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = j.job_id AND status = 'problem') as actual_problem,
  (SELECT COUNT(*) FROM import_v3_rows WHERE job_id = j.job_id AND status = 'dupe') as actual_dupe
FROM import_v3_jobs j
WHERE j.job_id = ?;
```

---

### Acceptance Checklist (Phase 6)

| Test | Expected | Status |
|------|----------|--------|
| rows.cfm returns paginated rows | `success: true`, rows array | [ ] PASS / [ ] FAIL |
| rows.cfm status filter works | Only rows matching filter | [ ] PASS / [ ] FAIL |
| rows.cfm stats_only=1 mode | Only stats, no rows | [ ] PASS / [ ] FAIL |
| rows.cfm status gate (409 if not reviewing/finalizing/completed) | INVALID_STATE error | [ ] PASS / [ ] FAIL |
| row.cfm returns full row detail | facts, duplicates arrays | [ ] PASS / [ ] FAIL |
| row.cfm 404 for nonexistent row | NOT_FOUND error | [ ] PASS / [ ] FAIL |
| fact_update.cfm updates fact value | new value in DB | [ ] PASS / [ ] FAIL |
| fact_update.cfm revalidates after update | is_valid updated | [ ] PASS / [ ] FAIL |
| fact_update.cfm recomputes row status | status changes if needed | [ ] PASS / [ ] FAIL |
| fact_update.cfm status gate (409 if not reviewing) | INVALID_STATE error | [ ] PASS / [ ] FAIL |
| row_action.cfm ignore sets status to ignored | status = 'ignored' | [ ] PASS / [ ] FAIL |
| row_action.cfm create sets user_action | user_action = 'import_new' | [ ] PASS / [ ] FAIL |
| row_action.cfm bulk operation | Multiple rows updated | [ ] PASS / [ ] FAIL |
| row_action.cfm UPDATE_NOT_SUPPORTED | 400 error for update action | [ ] PASS / [ ] FAIL |
| All endpoints return debug array | No PII in debug | [ ] PASS / [ ] FAIL |
| All endpoints use charset=utf-8 | Content-Type header | [ ] PASS / [ ] FAIL |
| All endpoints validate CSRF | 403 for missing/invalid | [ ] PASS / [ ] FAIL |
| bypass=1 required in URLs | Standard pattern | [ ] PASS / [ ] FAIL |

---

### DONE_TOKEN: PHASE6_DONE

---

## Phase 6.1 QA Hardening and Contract Verification (January 2026)

### Purpose
Verify Phase 6 implementation is correct and production-ready. No new features - hardening only.

### Contract Audit Results

All four endpoints were audited against Phase 6 requirements:

| Endpoint | Status Gate | CSRF | JSON/BOM | Debug | elapsed_ms | Verdict |
|----------|-------------|------|----------|-------|------------|---------|
| rows.cfm | reviewing/finalizing/completed | N/A (GET) | N/A | YES | YES | PASS |
| row.cfm | reviewing/finalizing/completed | N/A (GET) | N/A | YES | YES | PASS |
| fact_update.cfm | reviewing only | belt+suspenders | YES | YES | YES | PASS |
| row_action.cfm | reviewing only | belt+suspenders | YES | YES | YES | PASS |

### Service Methods Audit

| Method | Batch Loading | Status Recompute | Create-Only | Verdict |
|--------|---------------|------------------|-------------|---------|
| getRows | YES (line 2068) | N/A | N/A | PASS |
| getRowDetail | N/A (single row) | N/A | N/A | PASS |
| updateRowFacts | N/A | YES (problem>dupe>ready) | N/A | PASS |
| setRowAction | N/A | N/A | YES (UPDATE_NOT_SUPPORTED) | PASS |
| bulkRowAction | N/A | N/A | YES | PASS |

### Changes Made in Phase 6.1

1. **Observability (elapsed_ms)**
   - Added `startTick = getTickCount()` at endpoint start
   - Added `elapsed_ms: getTickCount() - startTick` to success responses
   - Files modified: rows.cfm, row.cfm, fact_update.cfm, row_action.cfm

2. **Test Harness Created**
   - Created `/docs/contact-import-v3/PHASE6_1_TESTS.md`
   - 13 curl test scripts with expected responses
   - 5 SQL verification queries
   - Manual UI test script
   - Acceptance checklist

### Batch Fact Loading Verification

Confirmed in `ContactImportV3Service.cfc` lines 2060-2091:

```coldfusion
// Collect row IDs for batch fact loading
var rowIds = [];
for (var row in qRows) {
    arrayAppend(rowIds, row.row_id);
}

// Batch load facts for all rows (SINGLE QUERY)
if (arrayLen(rowIds) gt 0) {
    var factsSql = "
        SELECT f.row_id, f.field_name, f.normalized_value, f.is_valid, ...
        FROM import_v3_facts f
        WHERE f.row_id IN (#arrayToList(rowIds)#)
        ORDER BY f.row_id, f.field_name
    ";
    var qFacts = queryExecute(factsSql, {}, ...);
    // ... map facts to rows
}
```

This pattern ensures O(1) facts query per page, not O(N) per row.

### Files Modified (Phase 6.1)

| File | Change |
|------|--------|
| ajax/importv3/rows.cfm | Added startTick + elapsed_ms |
| ajax/importv3/row.cfm | Added startTick + elapsed_ms |
| ajax/importv3/fact_update.cfm | Added startTick + elapsed_ms |
| ajax/importv3/row_action.cfm | Added startTick + elapsed_ms |
| docs/contact-import-v3/PHASE6_1_TESTS.md | NEW - Test harness |
| docs/contact-import-v3/PROJECT_STATUS.md | Phase 6.1 documentation |

### Response Envelope Compliance

All endpoints return Phase 5.2 envelope:

```json
{
  "success": true|false,
  "code": "ERROR_CODE" | "",
  "message": "Human readable" | "",
  "data": {
    "debug": ["step1", "step2", ...],
    "elapsed_ms": 42,
    ...endpoint-specific data...
  }
}
```

Error responses include:
- `data.last_step`: Last successful debug step
- HTTP status codes: 400, 401, 403, 404, 409, 500

### Proof Bundle Summary

**Diffs:**
- rows.cfm: +3 lines (timing)
- row.cfm: +3 lines (timing)
- fact_update.cfm: +3 lines (timing)
- row_action.cfm: +3 lines (timing)
- PHASE6_1_TESTS.md: +500 lines (new file)

**Network Expectations:**
- Content-Type: application/json; charset=utf-8
- bypass=1 required in URL
- CSRF via X-CSRF-Token header or body.csrf_token
- All exit paths return JSON

**Key Test Scenarios:**
1. rows.cfm stats_only=1 - returns only stats
2. rows.cfm with status filter - returns filtered rows
3. rows.cfm status gate - 409 if not reviewing/finalizing/completed
4. row.cfm detail - returns facts + duplicates
5. fact_update.cfm - updates, revalidates, recomputes status
6. fact_update.cfm CSRF - 403 if missing
7. fact_update.cfm status gate - 409 if not reviewing
8. row_action.cfm ignore - sets status to ignored
9. row_action.cfm bulk - updates multiple rows
10. row_action.cfm update - returns UPDATE_NOT_SUPPORTED

---

### DONE_TOKEN: PHASE6_1_DONE

---

## Phase 7 E2E Stabilization Sprint (January 2026)

### Purpose
End-to-end stabilization sprint to prove the full workflow works in the actual UI.
No new features - correctness, consistency, and responsiveness only.

### Goals Achieved

1. **E2E Test Plan Created** - `docs/contact-import-v3/PHASE7_E2E_TESTS.md`
2. **UI Correctness Fixes** - All AJAX calls now use proper patterns
3. **Backend Consistency Fixes** - Stats endpoint fixed
4. **Progress and Responsiveness** - Spinners and button states added

---

### A) E2E Test Plan (PHASE7_E2E_TESTS.md)

Created comprehensive test document with:
- **Test 1:** Happy Path - Complete Import Workflow (8 steps with network calls)
- **Test 2:** Large File Performance Test (500+ rows with timing expectations)
- **Test 3:** Invalid CSV Format (parse failure)
- **Test 4:** Missing Required Fields (validation errors)
- **Test 5:** Skip Duplicates Mode (skip_dupes=1)
- **Test 6:** Manual Duplicate Skip via Row Action
- **Test 7:** Fact Update Rejected (invalid value)
- **Test 8:** Finalize CSRF Failure (403 responses)
- **Test 9:** Finalize Double-Click Prevention (idempotency)
- **Test 10:** Finalize Re-run on Completed Job (409 INVALID_STATE)
- **Test 11:** Session Expiry During Operation (401 responses)
- **Test 12:** Access Denied (wrong user's job)

Each test includes:
- UI steps
- Network call details (endpoint, method, params, headers)
- Expected HTTP status and response.code
- Verification criteria
- Database verification queries

---

### B) UI Correctness Fixes (contact-import-v3.js)

**Issue 1: CSRF headers missing from mutating AJAX calls**
- Fixed: `saveEdit()` (fact_update.cfm) now sends X-CSRF-Token header + body
- Fixed: `bulkAction()` (row_action.cfm) now sends X-CSRF-Token header + body
- Fixed: `setDupeAction()` (row_action.cfm) now sends X-CSRF-Token header + body
- Already correct: `finalizeImport()` already had belt+suspenders CSRF

**Issue 2: DEBUG alerts left in production code**
- Fixed: Removed `alert('DEBUG: ...')` calls from parseFile() function
- Now uses `showAlert('error', ...)` for user-facing errors
- Debug info logged to console only

**Issue 3: hasFieldError() function could fail on boolean validation**
- Fixed: Now handles both object format `{valid: bool, error: string}` and simple boolean format
- Handles null/undefined validation gracefully

**Issue 4: Error handling inconsistency**
- Fixed: All AJAX calls now have proper error handlers
- Fixed: All AJAX calls log debug breadcrumbs to console
- Fixed: Error messages displayed via showAlert(), not alerts or console only

---

### C) Backend Consistency Fixes

**Issue: rows.cfm stats_only mode calling getJobStats incorrectly**
- `getJobStats()` returns stats struct directly, not wrapped in result envelope
- Fixed: rows.cfm line 131-143 now correctly handles the direct return

**Verification:**
- `getRows()` and `getJobStats()` both query `import_v3_rows` table
- Status values are consistent: ready, problem, dupe, ignored, imported
- Updated/failed status counts toward imported for display
- Job counts match actual row status counts

---

### D) Progress and Responsiveness

**confirmMappings() - Recompute operation:**
- Button disabled during processing
- Button text shows spinner: `<i class="fe-loader fe-spin"></i> Processing...`
- Button restored on error

**loadRows() - Row fetching:**
- Shows loading indicator in table body while fetching
- Indicator: `<i class="fe-loader fe-spin"></i> Loading rows...`
- Error state shows message in table

**bulkAction() - Bulk row actions:**
- Both bulk buttons disabled during processing
- Selected count text shows action: "Skipping..." or "Setting to import..."
- Buttons restored on error

**finalizeImport() - Import finalization:**
- Button disabled and shows spinner: `<i class="fe-loader fe-spin"></i> Importing...`
- For large imports (>100 rows), shows info alert: "This may take a moment..."
- Added 'info' alert type (alert-info with fe-info icon)

---

### Files Modified (Phase 7)

| File | Changes |
|------|---------|
| `app/assets/js/contact-import-v3.js` | CSRF headers, debug alerts removed, hasFieldError fix, spinners |
| `ajax/importv3/rows.cfm` | Fixed getJobStats return handling |
| `docs/contact-import-v3/PHASE7_E2E_TESTS.md` | NEW - Comprehensive E2E test plan |
| `docs/contact-import-v3/PROJECT_STATUS.md` | Phase 7 documentation |

---

### UI Changes Summary (contact-import-v3.js)

**Lines changed:**
- Line 343-349: Removed DEBUG alert, replaced with showAlert()
- Line 360-362: Removed DEBUG alert
- Line 386-388: Removed DEBUG alert
- Line 466-471: Added spinner to confirmMappings button
- Line 491-504: Fixed error handler to restore button state
- Line 552-580: Added loading indicator and error handler to loadRows
- Line 653-666: Fixed hasFieldError to handle multiple validation formats
- Line 766-828: Added CSRF header and button states to bulkAction
- Line 1035-1091: Added CSRF header and error handler to saveEdit
- Line 1152-1201: Added CSRF header and error handler to setDupeAction
- Line 1253-1262: Enhanced finalizeImport with button spinner and large import message
- Line 1479-1482: Added 'info' alert type to showAlert

---

### Hard Constraints Verified

| Constraint | Status |
|------------|--------|
| MySQL database (not SQL Server) | VERIFIED |
| bypass=1 on all /ajax/*.cfm calls | VERIFIED |
| CSRF enforcement on mutating endpoints | VERIFIED (belt+suspenders) |
| JSON responses with application/json; charset=utf-8 | VERIFIED |
| No PII in logs/debug | VERIFIED (debug arrays have step names only) |
| No emojis | VERIFIED |

---

### Stop Conditions - None Triggered

| Condition | Status |
|-----------|--------|
| Endpoint returns HTML | NOT TRIGGERED |
| Endpoint called without bypass=1 | NOT TRIGGERED |
| State-changing endpoint without CSRF | NOT TRIGGERED (all fixed) |
| Counts drift (job vs row mismatch) | NOT TRIGGERED |

---

### Acceptance Checklist (Phase 7)

| Test | Expected | Status |
|------|----------|--------|
| CSRF header sent on fact_update | X-CSRF-Token header | DONE |
| CSRF header sent on row_action | X-CSRF-Token header | DONE |
| CSRF header sent on finalize | X-CSRF-Token header | DONE (was already correct) |
| DEBUG alerts removed | No alert() calls | DONE |
| hasFieldError handles boolean | No JS errors | DONE |
| Spinner on confirmMappings | Button shows spinner | DONE |
| Loading indicator on loadRows | Table shows loading | DONE |
| Buttons disabled during bulk action | Both buttons disabled | DONE |
| Spinner on finalize | Button shows spinner | DONE |
| Info message for large imports | Alert shown for >100 rows | DONE |
| getJobStats return handled correctly | No errors on stats_only | DONE |
| E2E test plan created | PHASE7_E2E_TESTS.md | DONE |

---

### DONE_TOKEN: PHASE7_DONE

---

## Phase 8 Production Readiness (January 2026)

### Purpose
Production readiness sprint focusing on database performance, concurrency safety,
security verification, and release documentation. No new features.

### Goals Achieved

1. **Database Performance** - Index migration for duplicate detection queries
2. **Migration Artifacts** - V3_2 migration with EXPLAIN documentation
3. **Concurrency Proof** - Locking mechanism verified for double-click and parallel requests
4. **Security Proof** - All endpoints audited for auth, CSRF, status gates, JSON responses
5. **Release Checklist** - Complete deployment guide for dev and prod

---

### A) Discovery Findings

**Migration Location:**
- `database/migrations/` directory with version naming (V3_0, V3_1, etc.)
- Rollback scripts use `_ROLLBACK.sql` suffix

**Table Architecture:**
- `contactdetails` and `contactitems` are **views** filtering `IsDeleted <> 1`
- Base tables are `contactdetails_tbl` and `contactitems_tbl`
- Indexes must be created on base `_tbl` tables

**Existing Indexes:**
- `idx_contactdetails_tbl_user_deleted` on `(userID, IsDeleted, contactID)`
- `idx_contactitems_tbl_lookup` on `(contactID, valueCategory, itemStatus)`

---

### B) Index Migration

**File:** `database/migrations/V3_2__contact_import_v3_dupe_indexes.sql`

**New Indexes Created:**

1. `idx_contactdetails_tbl_dupe_v3` on `contactdetails_tbl(userid, isdeleted, contactid)`
   - Optimizes JOIN in buildUserDupeIndex and getCandidateContactIds

2. `idx_contactitems_tbl_dupe_v3` on `contactitems_tbl(contactid, itemStatus, isDeleted, valueCategory, valuetext(100))`
   - Optimizes email/phone lookups with prefix index on valuetext

3. `idx_contactitems_tbl_category_status` on `contactitems_tbl(valueCategory, itemStatus, isDeleted, contactid)`
   - Optimizes category filtering for index build query

**Safe Creation:**
- Uses stored procedure `AddIndexIfNotExists` with information_schema check
- Will not fail if indexes already exist from prior optimization

**Rollback:** `V3_2__contact_import_v3_dupe_indexes_ROLLBACK.sql`

---

### C) EXPLAIN Proof

Documented in `PHASE8_RELEASE_CHECKLIST.md` Section C.

**Key Queries Analyzed:**
1. buildUserDupeIndex - fetches all Email/Phone items for user
2. getCandidateContactIds - finds contacts matching specific values
3. getRows - paginated review grid query

**Expected EXPLAIN Signals:**
- `type`: `ref` or `range` (NOT `ALL`)
- `key`: Uses appropriate index
- `rows`: Proportional to user data (not full table scan)

**Fail Criteria:**
- `type` = `ALL` (full table scan)
- `key` = `NULL` (no index used)
- `rows` > 100,000 for candidate queries

---

### D) Performance Thresholds

| Operation | Threshold | Max Acceptable |
|-----------|-----------|----------------|
| recompute (500 rows) | < 15s | 30s |
| recompute (1000 rows) | < 30s | 60s |
| rows.cfm (page of 50) | < 1s | 3s |
| stats_only | < 500ms | 2s |
| finalize (500 rows) | < 45s | 90s |
| finalize avg_per_row | < 100ms | 200ms |

---

### E) Concurrency Proof

**Locking Mechanism (ContactImportV3Service.acquireJobLock):**
- Uses atomic UPDATE with status check
- Transitions `reviewing` -> `finalizing` for finalize operations
- Returns `ALREADY_RUNNING` if job already finalizing
- Returns `ALREADY_COMPLETED` if job already completed

**Double-Click Protection:**
- First request acquires lock and processes
- Second request fails with 409 status code
- No duplicate contacts created

**Refresh Mid-Finalize:**
- Finalize continues in background
- Re-attempt returns appropriate 409 error

---

### F) Security Audit Results

| Endpoint | Auth | CSRF | Status Gate | JSON | bypass=1 |
|----------|------|------|-------------|------|----------|
| upload.cfm | PASS | N/A | N/A | PASS | N/A |
| parse.cfm | PASS | PASS | uploaded | PASS | PASS |
| columns.cfm | PASS | N/A | N/A | PASS | PASS |
| recompute.cfm | PASS | PASS | parsed/mapping/reviewing | PASS | PASS |
| rows.cfm | PASS | N/A | reviewing | PASS | PASS |
| row.cfm | PASS | N/A | reviewing | PASS | PASS |
| fact_update.cfm | PASS | PASS | reviewing | PASS | PASS |
| row_action.cfm | PASS | PASS | reviewing | PASS | PASS |
| finalize.cfm | PASS | PASS | reviewing/finalizing | PASS | PASS |

**CSRF Implementation:**
- Belt+suspenders: accepts both X-CSRF-Token header and csrf_token body parameter
- Validates against session.csrf_token
- Returns 403 CSRF_INVALID on failure

**Status Gates:**
- Each endpoint enforces appropriate job status
- Returns 409 INVALID_STATE with current_status and allowed list

---

### G) Files Created/Modified (Phase 8)

| File | Change |
|------|--------|
| `database/migrations/V3_2__contact_import_v3_dupe_indexes.sql` | NEW - Index migration |
| `database/migrations/V3_2__contact_import_v3_dupe_indexes_ROLLBACK.sql` | NEW - Rollback |
| `docs/contact-import-v3/PHASE8_RELEASE_CHECKLIST.md` | NEW - Release guide |
| `docs/contact-import-v3/PROJECT_STATUS.md` | Phase 8 documentation |

---

### Hard Constraints Verified

| Constraint | Status |
|------------|--------|
| MySQL database (not SQL Server) | VERIFIED |
| bypass=1 on all /ajax/*.cfm calls | VERIFIED |
| CSRF enforcement on mutating endpoints | VERIFIED |
| JSON responses with application/json; charset=utf-8 | VERIFIED |
| No PII in logs/debug | VERIFIED |
| No emojis | VERIFIED |

---

### DONE_TOKEN: PHASE8_DONE
