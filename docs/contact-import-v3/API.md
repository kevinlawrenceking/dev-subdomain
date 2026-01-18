# Contact Import V3 API Documentation

**Version:** 3.0  
**Created:** 2026-01-17  
**Status:** Implementation in progress

---

## Overview

The Contact Import V3 API provides endpoints for uploading, parsing, mapping, validating, and finalizing contact imports.

---

## Response Envelope Format

All API responses use a consistent JSON envelope format.

### Success Response

```json
{
    "success": true,
    "message": "Optional success message",
    "data": { }
}
```

### Error Response

```json
{
    "success": false,
    "code": "ERROR_CODE",
    "message": "Human-readable error description",
    "data": { }
}
```

---

## Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| ACCESS_DENIED | 403 | User does not own the requested resource |
| NOT_FOUND | 404 | Requested resource does not exist |
| INVALID_STATE | 400 | Operation not allowed in current job status |
| INVALID_STATUS | 400 | Requested status value is not valid |
| MISSING_ERROR_MESSAGE | 400 | Error message required when setting failed status |
| LOCK_FAILED | 409 | Could not acquire lock (another operation in progress) |
| VALIDATION_ERROR | 400 | Input validation failed |
| PARSE_ERROR | 400 | File parsing failed |
| INTERNAL_ERROR | 500 | Unexpected server error |

---

## Ownership Rules

**CRITICAL SECURITY REQUIREMENT**

1. All job operations require ownership verification
2. Every request that references a job_id MUST verify that session.userid owns the job
3. Ownership is enforced in SQL WHERE clauses, NOT via post-query IF checks

SQL-level enforcement pattern:

```sql
WHERE job_id = :job_id AND userid = :userid
```

Never expose jobs belonging to other users:
- A non-owner receives ACCESS_DENIED, not NOT_FOUND
- Exception: if job truly does not exist, return NOT_FOUND

---

## Locking Rules

### Purpose

Locking prevents concurrent modifications during long-running operations.

### Implementation

The V3 schema does not have dedicated lock columns. Locking is implemented via status transitions:

- reviewing -> finalizing (lock for finalize operation)
- uploaded -> parsing (lock for parse operation)

### Lock Acquisition

1. Atomically update status only if in expected pre-lock state
2. If update affects 0 rows, lock acquisition failed
3. On failure, check if already locked or in wrong state

### Lock Release

- On success: transition to completion state
- On abort/failure: transition back to pre-lock state

### Limitations

- No explicit lock tokens in database (stored in options_json for validation only)
- No lock timeout mechanism (must be handled by application)
- No queuing of lock requests

---

## Job Status Flow

```
created -> uploaded -> parsing -> parsed -> mapping -> reviewing -> finalizing -> completed
                                                                              \-> failed
    \-> cancelled (from any state)
```

### Valid Status Transitions

| From | Allowed To |
|------|------------|
| created | uploaded, failed, cancelled |
| uploaded | parsing, failed, cancelled |
| parsing | parsed, failed, cancelled |
| parsed | mapping, failed, cancelled |
| mapping | reviewing, failed, cancelled |
| reviewing | finalizing, failed, cancelled |
| finalizing | completed, failed, cancelled |
| completed | (terminal) |
| failed | (terminal) |
| cancelled | (terminal) |

---

## Planned Endpoints

### POST /ajax/import-v3/upload.cfm

Upload a file and create a new import job.

### GET /ajax/import-v3/status.cfm

Get current job status and statistics.

Parameters:
- job_id (required): The import job ID

### GET /ajax/import-v3/columns.cfm

Get column mappings for the job.

### POST /ajax/import-v3/mapping.cfm

Save column mapping configuration.

### GET /ajax/import-v3/preview.cfm

Get preview of import results (dry run).

### POST /ajax/import-v3/finalize.cfm

Execute the import (create/update contacts).

---

## Service Layer

The ContactImportV3Service.cfc provides the following public methods:

### Response Helpers

- ok(data, message) - Build success envelope
- fail(code, message, data) - Build error envelope

### Job Operations

- getJob(job_id) - Get job by ID (no ownership check)
- assertJobOwnership(job_id, userid) - Verify ownership
- getJobForUser(job_id, userid) - Get job with ownership enforcement

### Event Logging

- logEvent(job_id, userid, event_type, detail, row_id, correlation_id) - Log audit event

### Locking

- acquireJobLock(job_id, userid, lock_token, lock_purpose) - Acquire operation lock
- releaseJobLock(job_id, userid, lock_token) - Release operation lock

### Status Management

- setJobStatus(job_id, userid, new_status, error_message) - Transition job status

---

## Audit Events

All significant operations are logged to import_v3_events table:

| Event Type | Description |
|------------|-------------|
| created | Job created |
| status_changed | Job status transition |
| lock_acquired | Operation lock acquired |
| lock_released | Operation lock released |
| lock_error | Lock acquisition failed |
| error_get_job | Error retrieving job |
| status_change_error | Status transition failed |

---

## Database Tables

V3 uses these tables (see V3_0__contact_import_v3_tables.sql):

- import_v3_jobs - Job tracking
- import_v3_columns - Column mappings
- import_v3_rows - Row data and validation
- import_v3_facts - EAV field values
- import_v3_events - Audit log
- import_v3_row_results - Finalize results

---

## Security Considerations

1. No SQL injection - All queries use cfqueryparam
2. Ownership at SQL level - WHERE clauses include userid
3. No secrets in responses - Never expose internal details
4. Rate limiting - Consider adding for upload endpoint
5. File validation - Validate file types and sizes before processing
