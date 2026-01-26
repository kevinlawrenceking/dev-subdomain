# Contact Import V3 - Phase 8 Release Checklist

## Overview

This document provides a complete checklist for releasing Contact Import V3 to production.
Phase 8 focuses on production readiness: database performance, concurrency safety, and security verification.

**Release Date:** (TBD)
**Prepared By:** Phase 8 E2E Stabilization Sprint
**Last Updated:** 2026-01-25

---

## Pre-Release Requirements

### A) Migration Apply Steps

**Migration File:** `database/migrations/V3_2__contact_import_v3_dupe_indexes.sql`

#### Development Environment

1. Back up the `new_development` schema (optional but recommended):
   ```sql
   mysqldump -u [user] -p new_development > backup_new_development_pre_v3_2.sql
   ```

2. Run the migration:
   ```sql
   SOURCE database/migrations/V3_2__contact_import_v3_dupe_indexes.sql;
   ```

3. Verify indexes were created:
   ```sql
   SHOW INDEX FROM contactdetails_tbl WHERE Key_name LIKE '%dupe_v3%';
   SHOW INDEX FROM contactitems_tbl WHERE Key_name LIKE '%dupe_v3%' OR Key_name LIKE '%category_status%';
   ```

   **Expected output:**
   - `idx_contactdetails_tbl_dupe_v3` on `contactdetails_tbl(userid, isdeleted, contactid)`
   - `idx_contactitems_tbl_dupe_v3` on `contactitems_tbl(contactid, itemStatus, isDeleted, valueCategory, valuetext(100))`
   - `idx_contactitems_tbl_category_status` on `contactitems_tbl(valueCategory, itemStatus, isDeleted, contactid)`

#### Production Environment

1. **IMPORTANT:** Run during low-traffic window (early morning or weekend)

2. Check table sizes before migration:
   ```sql
   SELECT
       table_name,
       table_rows,
       ROUND(data_length / 1024 / 1024, 2) AS data_mb,
       ROUND(index_length / 1024 / 1024, 2) AS index_mb
   FROM information_schema.TABLES
   WHERE table_schema = 'actorsbusinessoffice'
     AND table_name IN ('contactdetails_tbl', 'contactitems_tbl');
   ```

3. Estimate index creation time:
   - Small tables (<100K rows): ~10 seconds
   - Medium tables (100K-1M rows): ~1-5 minutes
   - Large tables (>1M rows): ~10-30 minutes

4. Run the migration:
   ```sql
   SOURCE database/migrations/V3_2__contact_import_v3_dupe_indexes.sql;
   ```

5. Monitor for lock issues. If CREATE INDEX takes too long:
   - Check `SHOW PROCESSLIST;` for blocked queries
   - Consider using `pt-online-schema-change` for zero-downtime

6. Verify indexes created (same as dev step 3)

### B) Rollback Guidance

**Rollback File:** `database/migrations/V3_2__contact_import_v3_dupe_indexes_ROLLBACK.sql`

**When to rollback:**
- Index creation causes unacceptable lock duration
- Index causes unexpected query plan changes
- Disk space issues

**Rollback steps:**
```sql
SOURCE database/migrations/V3_2__contact_import_v3_dupe_indexes_ROLLBACK.sql;
```

**Note:** Rollback only removes the V3.2 indexes. Existing indexes from prior optimizations remain.

---

## C) EXPLAIN Proof

### Query 1: buildUserDupeIndex (Index Build Query)

This query fetches all Email/Phone items for a user to build the in-memory dupe index.

```sql
EXPLAIN SELECT ci.contactid, ci.valueCategory, ci.valuetext
FROM contactitems_tbl ci
INNER JOIN contactdetails_tbl d ON d.contactid = ci.contactid
WHERE d.userid = 12345
  AND (d.isdeleted IS NULL OR d.isdeleted = 0)
  AND ci.itemStatus = 'Active'
  AND (ci.isDeleted IS NULL OR ci.isDeleted = 0)
  AND ci.valueCategory IN ('Email', 'Phone');
```

**Expected EXPLAIN signals:**
- `type`: `ref` or `range` (NOT `ALL`)
- `key`: Uses `idx_contactdetails_tbl_dupe_v3` or `idx_contactdetails_tbl_user_deleted` for contactdetails_tbl
- `key`: Uses `idx_contactitems_tbl_category_status` for contactitems_tbl
- `rows`: Proportional to user's contact count (not full table scan)

### Query 2: getCandidateContactIds (Candidate Lookup Query)

This query finds contacts matching specific email/phone values.

```sql
EXPLAIN SELECT DISTINCT ci.contactid
FROM contactitems_tbl ci
INNER JOIN contactdetails_tbl d ON d.contactid = ci.contactid
WHERE d.userid = 12345
  AND (d.isdeleted IS NULL OR d.isdeleted = 0)
  AND ci.itemStatus = 'Active'
  AND (ci.isDeleted IS NULL OR ci.isDeleted = 0)
  AND (
      (ci.valueCategory = 'Email' AND ci.valuetext IN ('john@example.com', 'jane@example.com'))
      OR
      (ci.valueCategory = 'Phone' AND REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ci.valuetext, ' ', ''), '-', ''), '(', ''), ')', ''), '+', '') IN ('5551234567'))
  )
LIMIT 100;
```

**Expected EXPLAIN signals:**
- `type`: `ref` or `range` (NOT `ALL`)
- `key`: Uses `idx_contactitems_tbl_dupe_v3` for email lookups
- `rows`: Low estimate based on matched values

### Query 3: getRows (Review Pagination Query)

```sql
EXPLAIN SELECT r.row_id, r.row_num, r.status, r.user_action
FROM import_v3_rows r
WHERE r.job_id = 123
  AND r.status = 'ready'
ORDER BY r.row_num ASC
LIMIT 50 OFFSET 0;
```

**Expected EXPLAIN signals:**
- `type`: `ref`
- `key`: `IX_import_v3_rows_job_status`
- `rows`: Low estimate based on job row count

### Run EXPLAIN Commands

**Development:**
```sql
-- Replace 12345 with a real userid from dev
-- Replace 123 with a real job_id from dev

-- Query 1
EXPLAIN SELECT ci.contactid, ci.valueCategory, ci.valuetext
FROM contactitems_tbl ci
INNER JOIN contactdetails_tbl d ON d.contactid = ci.contactid
WHERE d.userid = 12345 AND (d.isdeleted IS NULL OR d.isdeleted = 0)
  AND ci.itemStatus = 'Active' AND (ci.isDeleted IS NULL OR ci.isDeleted = 0)
  AND ci.valueCategory IN ('Email', 'Phone')\G

-- Query 2
EXPLAIN SELECT DISTINCT ci.contactid
FROM contactitems_tbl ci
INNER JOIN contactdetails_tbl d ON d.contactid = ci.contactid
WHERE d.userid = 12345 AND (d.isdeleted IS NULL OR d.isdeleted = 0)
  AND ci.itemStatus = 'Active' AND (ci.isDeleted IS NULL OR ci.isDeleted = 0)
  AND (ci.valueCategory = 'Email' AND ci.valuetext IN ('test@test.com'))
LIMIT 100\G

-- Query 3
EXPLAIN SELECT r.row_id, r.row_num, r.status, r.user_action
FROM import_v3_rows r WHERE r.job_id = 123 AND r.status = 'ready'
ORDER BY r.row_num ASC LIMIT 50\G
```

**Fail criteria (STOP and fix if any of these occur):**
- `type` = `ALL` (full table scan)
- `key` = `NULL` (no index used)
- `rows` estimate > 100,000 for candidate queries

---

## D) E2E Tests Before Release

Run these tests from `docs/contact-import-v3/PHASE7_E2E_TESTS.md`:

### Required Tests

| Test | Description | Pass Criteria |
|------|-------------|---------------|
| Test 1 | Happy Path (10 rows) | All steps succeed, job completes |
| Test 2 | Large File (500+ rows) | Completes without timeout, metrics captured |
| Test 8 | CSRF Failure | Returns 403 CSRF_INVALID |
| Test 9 | Double-Click Finalize | Second request returns 409 ALREADY_RUNNING or ALREADY_COMPLETED |
| Test 10 | Re-run Finalize | Returns 409 INVALID_STATE |

### Performance Thresholds

| Metric | Threshold | Max Acceptable |
|--------|-----------|----------------|
| recompute elapsed_ms (500 rows) | < 15s | 30s |
| recompute elapsed_ms (1000 rows) | < 30s | 60s |
| rows.cfm elapsed_ms (page of 50) | < 1s | 3s |
| stats_only elapsed_ms | < 500ms | 2s |
| finalize elapsed_ms (500 rows) | < 45s | 90s |
| finalize avg_per_row | < 100ms | 200ms |

### Capture Metrics

After running Test 2 (Large File), capture these from the JSON response:

```
recompute:
  elapsed_ms_total: ___
  dupe_index_build_ms: ___
  dupe_detection_mode: ___
  dupe_queries_total: ___
  total_rows_processed: ___

finalize:
  elapsed_ms_total: ___
  counts.imported_new: ___
  counts.failed: ___
  metrics.elapsed_ms_per_row_avg: ___
```

---

## E) Concurrency Tests

### Test 1: Double-Click Recompute

1. Open browser dev tools Network tab
2. Click "Save Mappings" button
3. Immediately click again (within 500ms)

**Expected:**
- First request succeeds (200 OK)
- Second request returns 409 with `INVALID_STATE` or `LOCKED`
- Job status ends in `reviewing` (not corrupted)

### Test 2: Double-Click Finalize

1. Open browser dev tools Network tab
2. Click "Finalize Import" button
3. Immediately click again (within 500ms)

**Expected:**
- First request succeeds (200 OK) or starts processing
- Second request returns 409 with `ALREADY_RUNNING` or `ALREADY_COMPLETED`
- No duplicate contacts created

**Verification Query:**
```sql
-- Count contacts created by job
SELECT COUNT(*) FROM contactdetails_tbl
WHERE created_by_import_job = [JOB_ID];

-- Should equal imported_rows from job record
SELECT imported_rows FROM import_v3_jobs WHERE job_id = [JOB_ID];
```

### Test 3: Refresh Mid-Finalize

1. Start finalize on a large job (100+ rows)
2. Immediately refresh the page
3. Attempt to finalize again

**Expected:**
- First finalize continues in background
- Second attempt returns 409 `ALREADY_RUNNING` or `ALREADY_COMPLETED`
- Job eventually completes

### Test 4: Two Browser Sessions

1. Open import in two different browsers (or incognito)
2. Log in as same user in both
3. Start operations on same job simultaneously

**Expected:**
- Only one session succeeds
- Other gets 409 or appropriate error
- No data corruption

---

## F) Security Verification

### Endpoint Audit Results

| Endpoint | Auth | CSRF | Status Gate | JSON Response | bypass=1 |
|----------|------|------|-------------|---------------|----------|
| upload.cfm | PASS | N/A (multipart) | N/A | PASS | N/A |
| parse.cfm | PASS | PASS | uploaded only | PASS | PASS |
| columns.cfm | PASS | N/A (GET) | N/A | PASS | PASS |
| recompute.cfm | PASS | PASS | parsed/mapping/reviewing | PASS | PASS |
| rows.cfm | PASS | N/A (GET) | reviewing | PASS | PASS |
| row.cfm | PASS | N/A (GET) | reviewing | PASS | PASS |
| fact_update.cfm | PASS | PASS | reviewing | PASS | PASS |
| row_action.cfm | PASS | PASS | reviewing | PASS | PASS |
| finalize.cfm | PASS | PASS | reviewing/finalizing | PASS | PASS |

### Security Tests

1. **Auth Test:** Call any endpoint without session.userid
   - Expected: 401 AUTH_REQUIRED

2. **CSRF Test:** POST to fact_update without csrf_token
   - Expected: 403 CSRF_INVALID

3. **Access Test:** Try to access another user's job_id
   - Expected: 403 ACCESS_DENIED

4. **Status Test:** Try to finalize a completed job
   - Expected: 409 INVALID_STATE

---

## G) Smoke Tests Post-Release

Run these tests after deploying to production:

### Immediate (within 1 hour)

1. **Upload Test:**
   - Upload a small CSV (5 rows)
   - Verify file uploads successfully
   - Verify job_id returned

2. **Parse Test:**
   - Parse the uploaded file
   - Verify columns detected
   - Verify rows staged

3. **Recompute Test:**
   - Map columns and run recompute
   - Verify stats returned
   - Note elapsed_ms

4. **Review Test:**
   - Load rows with rows.cfm
   - Verify rows render in UI
   - Test pagination

5. **Finalize Test:**
   - Finalize the import
   - Verify contacts created
   - Verify job status = completed

### Extended (within 24 hours)

1. **Large Import Test:**
   - Import 100-500 row file
   - Monitor for timeouts
   - Verify all rows processed

2. **Duplicate Detection Test:**
   - Import file with known duplicates
   - Verify duplicates detected
   - Test skip/import decisions

3. **Error Handling Test:**
   - Import file with invalid data
   - Verify problem rows identified
   - Verify error messages clear

---

## H) Known Limitations

Document these for support and users:

1. **Create-Only Mode:**
   - V3 only creates new contacts
   - No update_existing functionality
   - Duplicate rows must be manually resolved or skipped

2. **Relationship Enrollment:**
   - Not yet implemented
   - relationship_system_default field exists but not used

3. **VCF Support:**
   - Partial implementation
   - May not handle all vCard formats

4. **Batch Size Limits:**
   - Duplicate index capped at 200,000 items (Phase 4.1)
   - Files over 10,000 rows may be slow
   - Consider batch imports for very large files

5. **Concurrent Access:**
   - Single user per job enforced
   - No multi-user collaboration support

---

## I) Database Verification Queries

Run after deployment to verify data integrity:

```sql
-- 1. Check for orphan rows
SELECT COUNT(*) as orphan_rows FROM import_v3_rows r
LEFT JOIN import_v3_jobs j ON r.job_id = j.job_id
WHERE j.job_id IS NULL;
-- Expected: 0

-- 2. Check for orphan facts
SELECT COUNT(*) as orphan_facts FROM import_v3_facts f
LEFT JOIN import_v3_rows r ON f.row_id = r.row_id
WHERE r.row_id IS NULL;
-- Expected: 0

-- 3. Check job counts consistency
SELECT j.job_id, j.total_rows, j.imported_rows,
       COUNT(r.row_id) as actual_rows,
       SUM(CASE WHEN r.status = 'imported' THEN 1 ELSE 0 END) as actual_imported
FROM import_v3_jobs j
LEFT JOIN import_v3_rows r ON j.job_id = r.job_id
WHERE j.status = 'completed'
GROUP BY j.job_id, j.total_rows, j.imported_rows
HAVING j.total_rows != actual_rows OR j.imported_rows != actual_imported
LIMIT 10;
-- Expected: 0 rows

-- 4. Check for stuck finalizing jobs
SELECT job_id, status, userid, updated_at
FROM import_v3_jobs
WHERE status = 'finalizing'
  AND updated_at < DATE_SUB(NOW(), INTERVAL 1 HOUR);
-- Expected: 0 rows (or investigate if any found)

-- 5. Verify indexes exist
SHOW INDEX FROM contactdetails_tbl WHERE Key_name LIKE '%dupe%';
SHOW INDEX FROM contactitems_tbl WHERE Key_name LIKE '%dupe%' OR Key_name LIKE '%category%';
```

---

## J) Release Sign-Off

### Pre-Release Checklist

| Item | Status | Verified By | Date |
|------|--------|-------------|------|
| V3_2 migration applied to dev | [ ] | | |
| V3_2 indexes verified in dev | [ ] | | |
| EXPLAIN queries show expected plans | [ ] | | |
| Test 1 (Happy Path) passed | [ ] | | |
| Test 2 (Large File) passed | [ ] | | |
| Test 9 (Double-Click) passed | [ ] | | |
| Performance thresholds met | [ ] | | |
| Security audit complete | [ ] | | |
| Rollback script tested | [ ] | | |

### Production Release Checklist

| Item | Status | Verified By | Date |
|------|--------|-------------|------|
| Backup taken | [ ] | | |
| V3_2 migration applied to prod | [ ] | | |
| V3_2 indexes verified in prod | [ ] | | |
| Smoke tests passed | [ ] | | |
| Database verification queries passed | [ ] | | |
| No errors in CF logs | [ ] | | |
| No support tickets related to import | [ ] | | |

---

## Appendix: Files Changed in Phase 8

| File | Purpose |
|------|---------|
| `database/migrations/V3_2__contact_import_v3_dupe_indexes.sql` | NEW - Index migration |
| `database/migrations/V3_2__contact_import_v3_dupe_indexes_ROLLBACK.sql` | NEW - Rollback script |
| `docs/contact-import-v3/PHASE8_RELEASE_CHECKLIST.md` | NEW - This document |
| `docs/contact-import-v3/PROJECT_STATUS.md` | Updated with Phase 8 section |

---

*Document Version: Phase 8.0*
*DONE_TOKEN: PHASE8_DONE*
