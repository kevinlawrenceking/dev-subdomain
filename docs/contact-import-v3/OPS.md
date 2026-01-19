# Contact Import V3 - Operations Guide

## Overview

This document covers operational procedures for Contact Import V3, including:
- **Rollout control** (feature flags, allowlist management)
- **Admin dashboard** (job monitoring, health metrics)
- **Cleanup procedures** (retention policies, execution)

---

## Rollout Control

Contact Import V3 uses a database-driven feature flag system that allows enabling/disabling the feature **without a code deploy**.

### Database Tables

```sql
-- Global feature flags
CREATE TABLE feature_flags (
    flag_key VARCHAR(50) PRIMARY KEY,
    is_enabled TINYINT(1) DEFAULT 0,
    description VARCHAR(255),
    created_at DATETIME,
    updated_at DATETIME
);

-- Per-user overrides (allowlist)
CREATE TABLE feature_flag_users (
    flag_key VARCHAR(50),
    userid INT,
    is_enabled TINYINT(1) DEFAULT 1,
    notes VARCHAR(255),
    created_at DATETIME,
    PRIMARY KEY (flag_key, userid)
);
```

### Flag Semantics

| Global Flag | Allowlist | Result |
|-------------|-----------|--------|
| `true` | (ignored) | All users have access |
| `false` | User in list | Only allowlist users have access |
| `false` | User not in list | Access denied |

### Initial Production Rollout Steps

1. **Run database migration** (creates tables with flag defaulted to OFF):
   ```bash
   mysql -u admin -p < database/migrations/V3_1__feature_flags_tables.sql
   ```

2. **Verify flag is OFF** (safe default):
   ```sql
   SELECT * FROM feature_flags WHERE flag_key = 'import_v3_enabled';
   -- Expected: is_enabled = 0
   ```

3. **Add beta testers to allowlist** (before enabling globally):
   ```sql
   -- Add specific users for testing
   INSERT INTO feature_flag_users (flag_key, userid, is_enabled, notes, created_at)
   VALUES ('import_v3_enabled', 123, 1, 'Beta tester - support team', NOW());
   ```

4. **Test with allowlist users** - Only allowlisted users see Import V3

5. **Enable globally when ready**:
   ```sql
   UPDATE feature_flags SET is_enabled = 1, updated_at = NOW()
   WHERE flag_key = 'import_v3_enabled';
   ```

### Admin Dashboard

Access the admin dashboard at:
```
/app/admin-import-v3/index.cfm
```

**Requirements**: Admin role (`session.userrole = "Admin"` or `"Administrator"`)

**Features**:
- View/toggle global feature flag
- Manage user allowlist (add/remove users)
- View recent jobs (last 50)
- Monitor health metrics (today's counts, 7-day averages)
- Force refresh feature flag cache

### Admin Dashboard API

The dashboard uses a JSON API at `/ajax/importv3/admin_dashboard.cfm`:

| Action | Method | Parameters | Description |
|--------|--------|------------|-------------|
| (none) | GET | - | Load full dashboard data |
| `refresh_flags` | POST | - | Force refresh feature flag cache |
| `toggle_global` | POST | `enabled=1/0` | Enable/disable global flag |
| `add_user` | POST | `userid, notes` | Add user to allowlist |
| `remove_user` | POST | `userid` | Remove user from allowlist |
| `search_users` | GET | `q=searchterm` | Search users for allowlist |

### Cache Behavior

Feature flags are cached in `application.features` with a 60-second TTL.

- **Automatic refresh**: Cache refreshes automatically on each request if expired
- **Force refresh**: Admin dashboard "Force Refresh Cache" button
- **Application restart**: Cache rebuilds on application restart

### Emergency Disable (Kill Switch)

To immediately disable Import V3 for all users:

```sql
-- Option 1: Disable global flag (allows cache to expire naturally)
UPDATE feature_flags SET is_enabled = 0, updated_at = NOW()
WHERE flag_key = 'import_v3_enabled';

-- Option 2: For immediate effect, also clear allowlist
DELETE FROM feature_flag_users WHERE flag_key = 'import_v3_enabled';
```

After database update, either:
1. Wait 60 seconds for cache to expire, OR
2. Use admin dashboard "Force Refresh Cache", OR
3. Restart the ColdFusion application

### Service Helper Usage

In CFML code, check if a user has access:

```cfml
<cfset importService = new services.ContactImportV3Service()>
<cfif importService.isImportV3Enabled(session.userid)>
    <!--- Show Import V3 UI --->
<cfelse>
    <!--- Show legacy import or access denied --->
</cfif>
```

### Rollback Procedure

To rollback the feature flag system:

```bash
mysql -u admin -p < database/migrations/V3_1__feature_flags_tables_ROLLBACK.sql
```

This removes both `feature_flags` and `feature_flag_users` tables.

---

## Job Monitoring

### Health Metrics (Dashboard)

The admin dashboard displays:

| Metric | Description |
|--------|-------------|
| Completed Today | Jobs finished successfully today |
| Failed Today | Jobs that failed today |
| Active Jobs | Jobs not in terminal state |
| Avg Rows/Job (7d) | Average rows per job over 7 days |
| Jobs (7d) | Total jobs in last 7 days |
| Users (7d) | Unique users who created jobs |

### SQL Monitoring Queries

```sql
-- Jobs by status today
SELECT status, COUNT(*) as cnt
FROM import_v3_jobs
WHERE DATE(created_at) = CURDATE()
GROUP BY status;

-- Failed jobs with errors
SELECT job_id, userid, source_filename, error_message, created_at
FROM import_v3_jobs
WHERE status = 'failed'
ORDER BY created_at DESC
LIMIT 20;

-- Stuck jobs (in progress > 1 hour)
SELECT job_id, userid, source_filename, status, started_at
FROM import_v3_jobs
WHERE status IN ('parsing', 'mapping', 'reviewing', 'finalizing')
  AND started_at < DATE_SUB(NOW(), INTERVAL 1 HOUR);

-- User activity summary
SELECT
    userid,
    COUNT(*) as total_jobs,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed,
    SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed
FROM import_v3_jobs
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY userid
ORDER BY total_jobs DESC;
```

---

## Cleanup Endpoint

### Location
```
POST /ajax/importv3/admin_cleanup.cfm
```

### Security Requirements
- **Authentication**: Valid session with `session.userid`
- **Authorization**: Admin role required (`session.isAdmin = true`)
- **Feature Flag**: `application.features.importV3Enabled` must be `true`

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `csrf_token` | string | required | CSRF protection token from session |
| `retention_days` | integer | 30 | Number of days to retain completed/failed jobs. Minimum: 1 |
| `dry_run` | boolean | false | If true, only reports what would be deleted without deleting |

### Response Format

```json
{
  "success": true,
  "message": "Cleanup completed successfully.",
  "data": {
    "dry_run": false,
    "retention_days": 30,
    "jobs_found": 5,
    "jobs_deleted": 5,
    "events_deleted": 150,
    "facts_deleted": 2500,
    "rows_deleted": 100,
    "columns_deleted": 40,
    "files_deleted": 5,
    "files_skipped": 0,
    "deleted_job_ids": [101, 102, 103, 104, 105],
    "errors": []
  }
}
```

## Retention Rules

### What Gets Deleted
- Jobs with status `completed` or `failed`
- Jobs where `finished_at` is older than `retention_days` from current time

### What Is Preserved
- Jobs with status: `created`, `uploaded`, `parsing`, `parsed`, `mapping`, `reviewing`, `finalizing`, `cancelled`
- Jobs within the retention window (finished less than N days ago)
- Jobs still in progress (no `finished_at` timestamp)

### Deletion Order (FK Dependencies)
1. `import_v3_events` (references job_id, row_id)
2. `import_v3_facts` (references row_id, column_id)
3. `import_v3_rows` (references job_id)
4. `import_v3_columns` (references job_id)
5. `import_v3_jobs` (parent table)
6. Uploaded files (only within allowed upload directory)

## File Deletion Safety

### Allowed Path Restriction
Files are only deleted if they reside within the uploads base directory:
```
{application.baseMediaPath}\users\
```

This prevents arbitrary file deletion outside the designated upload area.

### File Path Validation
- Paths are normalized (lowercase, backslash-unified)
- Strict prefix matching against the allowed base path
- Files outside allowed path are skipped with an error logged

## Running Cleanup

**Important:** The endpoint requires a valid CSRF token from the session. This is typically obtained via the admin UI or by fetching `session.csrf_token` before making the request.

### Dry Run (Recommended First)
Always run a dry run first to verify what will be deleted:

```bash
curl -X POST "https://your-domain/ajax/importv3/admin_cleanup.cfm" \
  -H "Cookie: CFID=xxx; CFTOKEN=xxx" \
  -d "csrf_token=YOUR_SESSION_CSRF_TOKEN&dry_run=true&retention_days=30"
```

### Actual Cleanup
```bash
curl -X POST "https://your-domain/ajax/importv3/admin_cleanup.cfm" \
  -H "Cookie: CFID=xxx; CFTOKEN=xxx" \
  -d "csrf_token=YOUR_SESSION_CSRF_TOKEN&retention_days=30"
```

### Custom Retention Period
```bash
# Keep jobs for 7 days only
curl -X POST "https://your-domain/ajax/importv3/admin_cleanup.cfm" \
  -H "Cookie: CFID=xxx; CFTOKEN=xxx" \
  -d "csrf_token=YOUR_SESSION_CSRF_TOKEN&retention_days=7"

# Keep jobs for 90 days
curl -X POST "https://your-domain/ajax/importv3/admin_cleanup.cfm" \
  -H "Cookie: CFID=xxx; CFTOKEN=xxx" \
  -d "csrf_token=YOUR_SESSION_CSRF_TOKEN&retention_days=90"
```

## Idempotency

The cleanup operation is fully idempotent:
- Running cleanup twice with the same parameters will not cause errors
- Second run will find 0 jobs to delete (already cleaned)
- Safe to run on a schedule or manually multiple times

## Monitoring

### Pre-Cleanup Verification Query
Check what would be affected before running:

```sql
-- Count jobs eligible for cleanup (30-day retention)
SELECT
  status,
  COUNT(*) as job_count
FROM import_v3_jobs
WHERE status IN ('completed', 'failed')
  AND finished_at < DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY status;

-- List specific jobs that would be deleted
SELECT
  job_id, userid, source_filename, status,
  finished_at, stored_file_path
FROM import_v3_jobs
WHERE status IN ('completed', 'failed')
  AND finished_at < DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY finished_at;
```

### Post-Cleanup Verification Query
Verify cleanup was successful:

```sql
-- Should return 0 for properly cleaned data
SELECT COUNT(*) as remaining
FROM import_v3_jobs
WHERE status IN ('completed', 'failed')
  AND finished_at < DATE_SUB(NOW(), INTERVAL 30 DAY);

-- Check for orphaned records (should be 0)
SELECT COUNT(*) as orphaned_rows
FROM import_v3_rows r
LEFT JOIN import_v3_jobs j ON r.job_id = j.job_id
WHERE j.job_id IS NULL;

SELECT COUNT(*) as orphaned_facts
FROM import_v3_facts f
LEFT JOIN import_v3_rows r ON f.row_id = r.row_id
WHERE r.row_id IS NULL;
```

## Rollback Procedures

### Before Cleanup
**There is no automatic rollback.** Data deletion is permanent.

Before running cleanup in production:
1. Run with `dry_run=true` first
2. Review the `deleted_job_ids` in the response
3. If needed, export job data before cleanup:

```sql
-- Export job metadata before deletion
SELECT * FROM import_v3_jobs
WHERE status IN ('completed', 'failed')
  AND finished_at < DATE_SUB(NOW(), INTERVAL 30 DAY)
INTO OUTFILE '/tmp/import_v3_jobs_backup.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
```

### After Cleanup (Recovery)
If cleanup deleted data that shouldn't have been deleted:
1. Restore from database backup
2. Restore uploaded files from filesystem backup
3. Contact database administrator for point-in-time recovery

## Scheduled Cleanup (Optional)

To run cleanup automatically, create a scheduled task:

### ColdFusion Scheduled Task
```cfm
<cfschedule
  action="update"
  task="ImportV3Cleanup"
  operation="HTTPRequest"
  url="https://your-domain/ajax/importv3/admin_cleanup.cfm"
  startdate="01/01/2026"
  starttime="02:00 AM"
  interval="daily"
  requesttimeout="300">
```

**Note**: Scheduled tasks require proper session/auth handling. Consider creating a separate internal endpoint with token-based authentication for automated cleanup.

## Error Handling

### Common Errors

| Error Code | Cause | Resolution |
|------------|-------|------------|
| `AUTH_REQUIRED` | No valid session | Log in as admin user |
| `ADMIN_REQUIRED` | User is not admin | Use admin account |
| `CSRF_INVALID` | Missing/invalid CSRF token | Include valid `csrf_token` from session |
| `FEATURE_DISABLED` | Feature flag off | Enable `importV3Enabled` |
| `CLEANUP_FAILED` | Database/file error | Check error details in response |

### File Deletion Errors
File deletion errors are non-fatal. The job record will still be deleted, but errors are logged:
- Missing files (already deleted): Counted in `files_skipped`
- Permission errors: Logged in `errors` array
- Files outside allowed path: Skipped and logged

## Best Practices

1. **Always dry run first** in production environments
2. **Set appropriate retention** - 30 days is recommended default
3. **Monitor disk space** before/after cleanup
4. **Schedule during low-traffic hours** if running automatically
5. **Review errors** in response to catch permission issues
6. **Keep backups** of production data before major cleanup operations
