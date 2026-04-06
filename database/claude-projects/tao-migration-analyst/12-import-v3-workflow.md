# Contact Import V3 -- Technical Documentation

The Actors Office (TAO) -- ColdFusion + MySQL Web Application

---

## Table of Contents

1. [Overview](#1-overview)
2. [Architecture](#2-architecture)
3. [Database Schema](#3-database-schema)
4. [Workflow States (Job Status Machine)](#4-workflow-states-job-status-machine)
5. [AJAX Endpoints](#5-ajax-endpoints)
6. [Security Features](#6-security-features)
7. [Finalization Logic](#7-finalization-logic)
8. [Logging and Observability](#8-logging-and-observability)
9. [Known Limitations and Future Work](#9-known-limitations-and-future-work)
10. [Query Audit Summary](#10-query-audit-summary)

---

## 1. Overview

Contact Import V3 is a staged import workflow for importing contacts into The Actors Office from CSV, XLS, and XLSX files. VCF (vCard) file acceptance is planned but parsing is not yet implemented.

### Core Design Principles

- **Two-phase pattern**: Stage (upload, parse, validate) then Review and Finalize. Raw input is never written directly to production tables. All data is first staged into import-specific tables, validated, and presented for user review before any production writes occur.

- **Idempotent finalization**: Double-finalizing a job will not double-insert contacts. Each row is checked against `import_v3_row_results` before processing. If a row was already imported, it is skipped with a `skipped_already_imported` result.

- **Per-row transaction isolation**: During finalization, each row is processed in its own database transaction. A failure on row N does not roll back the successfully imported rows 1 through N-1.

- **Staged validation**: Per-field validation errors and warnings are recorded in staging tables during the parse and mapping phases. Users review and correct problems before finalization.

- **File hash duplicate detection**: SHA-256 hashing prevents the same file from being uploaded twice by the same user.

---

## 2. Architecture

### Backend

- **Language**: ColdFusion (CFML)
- **Service layer**: `ContactImportV3Service.cfc` -- a component containing all core business logic (job management, locking, status transitions, row processing, event logging)
- **AJAX endpoints**: Individual `.cfm` files under `ajax/importv3/` that handle HTTP requests, perform auth/CSRF checks, and delegate to the service layer
- **Database**: MySQL with the `reach` datasource

### Frontend

- **JavaScript controller**: jQuery-driven SPA-like interface with AJAX tab navigation
- **UI template**: Server-rendered ColdFusion template that bootstraps the JavaScript application
- **Pattern**: Single-page flow with step-based UI (upload, column mapping, review grid, finalize)

### Key Files

| File | Purpose | Approximate Size |
|------|---------|-----------------|
| `include/import-contacts-v3.cfm` | Main UI template (HTML/CSS/CFML) | ~585 lines |
| `app/assets/js/contact-import-v3.js` | JavaScript controller (all client-side logic) | ~1655 lines |
| `services/ContactImportV3Service.cfc` | Core service (jobs, locking, validation, finalization) | ~2850 lines |
| `ajax/importv3/upload.cfm` | File upload endpoint | ~217 lines |
| `ajax/importv3/parse.cfm` | File parsing endpoint | ~573 lines |
| `ajax/importv3/columns.cfm` | Column mapping endpoint (GET/POST) | ~492 lines |
| `ajax/importv3/rows.cfm` | Paginated row listing endpoint | ~203 lines |
| `ajax/importv3/row.cfm` | Single row detail endpoint | ~165 lines |
| `ajax/importv3/row_action.cfm` | Row action endpoint (ignore/create, single/bulk) | ~368 lines |
| `ajax/importv3/fact_update.cfm` | Inline fact editing endpoint | ~287 lines |
| `ajax/importv3/finalize.cfm` | Finalization endpoint | ~270 lines |
| `ajax/importv3/status.cfm` | Job status change endpoint | ~297 lines |

### Data Flow

```
User uploads file
    |
    v
upload.cfm --> SHA-256 hash --> duplicate check --> create job row (status: uploaded)
    |
    v
parse.cfm --> read file --> extract headers + rows --> insert columns, rows, facts (status: parsed)
    |
    v
columns.cfm (GET) --> display column mapping with sample values
columns.cfm (POST) --> user confirms/changes mappings (status: mapping)
    |
    v
[Service validates and computes row statuses: ready, problem, dupe]
    |
    v
rows.cfm --> paginated review grid (status: reviewing)
row.cfm --> single row detail with all facts
row_action.cfm --> user sets ignore/create per row or in bulk
fact_update.cfm --> inline editing of cell values, revalidation
    |
    v
finalize.cfm --> acquireJobLock --> process eligible rows --> create contacts (status: completed)
    |
    v
status.cfm --> manual status resets (completed/failed/cancelled -> reviewing)
```

---

## 3. Database Schema

### import_v3_jobs

Master job record. One row per import job.

| Column | Type | Purpose |
|--------|------|---------|
| `job_id` | INT AUTO_INCREMENT PK | Primary key |
| `userid` | INT | Owner user ID (foreign key to taousers) |
| `source_filename` | VARCHAR(255) | Original uploaded filename |
| `file_type` | VARCHAR(10) | File extension: csv, xls, xlsx, vcf |
| `file_size` | BIGINT | File size in bytes |
| `file_hash` | VARCHAR(64) | SHA-256 hash for duplicate detection |
| `stored_file_path` | VARCHAR(500) | Server-side file path |
| `status` | VARCHAR(20) | Current job status (see state machine) |
| `error_message` | TEXT | Error details if status is failed |
| `total_rows` | INT | Total data rows parsed |
| `parsed_rows` | INT | Rows successfully parsed |
| `valid_rows` | INT | Rows passing validation |
| `problem_rows` | INT | Rows with validation errors |
| `dupe_rows` | INT | Rows flagged as potential duplicates |
| `imported_rows` | INT | Rows successfully imported |
| `updated_rows` | INT | Rows updated (future use) |
| `skipped_rows` | INT | Rows skipped (user ignored or already imported) |
| `import_mode` | VARCHAR(20) | Import mode (create_only currently) |
| `allow_blank_overwrite` | TINYINT | Whether blanks overwrite existing values |
| `relationship_system_default` | VARCHAR(50) | Default relationship system for new contacts |
| `folder_assignment_json` | TEXT | JSON folder assignment rules |
| `options_json` | TEXT | Additional import options as JSON |
| `created_at` | DATETIME | Job creation timestamp |
| `updated_at` | DATETIME | Last modification timestamp |
| `started_at` | DATETIME | Finalization start timestamp |
| `finished_at` | DATETIME | Finalization completion timestamp |

### import_v3_columns

Parsed column headers with mapping configuration.

| Column | Type | Purpose |
|--------|------|---------|
| `column_id` | INT AUTO_INCREMENT PK | Primary key |
| `job_id` | INT | Parent job |
| `source_column_index` | INT | Zero-based column index from source file |
| `source_column_name` | VARCHAR(255) | Original header name |
| `mapped_field` | VARCHAR(100) | Auto-detected target field |
| `is_custom_field` | TINYINT | Whether mapped to a custom field |
| `custom_field_id` | INT | Custom field reference |
| `confidence` | VARCHAR(20) | Auto-mapping confidence level |
| `user_confirmed` | TINYINT | Whether user has confirmed the mapping |
| `sample_values` | TEXT | JSON array of sample values from the file |
| `intent` | VARCHAR(20) | Mapping intent: ignore, contact_field, contact_item, tag, note, custom_meta |
| `target_key` | VARCHAR(100) | Target field key (required for contact_field, contact_item, custom_meta) |
| `transform_json` | TEXT | JSON transformation rules |
| `created_at` | DATETIME | Row creation timestamp |
| `updated_at` | DATETIME | Last modification timestamp |

### import_v3_rows

Individual data rows from the parsed file.

| Column | Type | Purpose |
|--------|------|---------|
| `row_id` | INT AUTO_INCREMENT PK | Primary key |
| `job_id` | INT | Parent job |
| `row_num` | INT | One-based row number from source file |
| `raw_json` | TEXT | Original cell values as JSON object (column index -> value) |
| `status` | VARCHAR(20) | Row status: pending, ready, problem, dupe, imported, failed |
| `user_action` | VARCHAR(20) | User decision: skip, import_new |
| `error_count` | INT | Number of validation errors |
| `warning_count` | INT | Number of validation warnings |
| `dupe_contact_ids` | TEXT | Comma-separated IDs of matching existing contacts |
| `dupe_match_reasons` | TEXT | JSON describing why each duplicate matched |
| `created_contactid` | INT | Contact ID created on import |
| `imported_at` | DATETIME | When the row was imported |
| `import_error` | VARCHAR(500) | Error message if import failed |
| `created_at` | DATETIME | Row creation timestamp |
| `updated_at` | DATETIME | Last modification timestamp |

### import_v3_facts

EAV (Entity-Attribute-Value) cell values. One row per cell per data row.

| Column | Type | Purpose |
|--------|------|---------|
| `fact_id` | INT AUTO_INCREMENT PK | Primary key |
| `row_id` | INT | Parent row |
| `column_id` | INT | Parent column |
| `field_name` | VARCHAR(50) | Mapped field name (e.g., firstName, email_business) |
| `raw_value` | TEXT | Original value from the file (immutable after parse) |
| `normalized_value` | TEXT | Cleaned/validated value used for import |
| `is_valid` | TINYINT | Whether the value passes validation |
| `validation_error` | VARCHAR(500) | Validation error message if invalid |
| `created_at` | DATETIME | Fact creation timestamp |
| `updated_at` | DATETIME | Last modification timestamp |

### import_v3_events

Audit trail for all operations.

| Column | Type | Purpose |
|--------|------|---------|
| `event_id` | INT AUTO_INCREMENT PK | Primary key |
| `job_id` | INT | Parent job |
| `userid` | INT | Acting user |
| `event_type` | VARCHAR(50) | Event type (upload, parse_started, parse_completed, finalize_started, etc.) |
| `event_detail` | TEXT | JSON detail payload |
| `row_id` | INT | Optional row reference |
| `created_at` | DATETIME | Event timestamp |

### import_v3_row_results

Per-row import results for finalization tracking and idempotency.

| Column | Type | Purpose |
|--------|------|---------|
| `result_id` | INT AUTO_INCREMENT PK | Primary key |
| `row_id` | INT | Parent row (unique -- one result per row) |
| `job_id` | INT | Parent job |
| `action_taken` | VARCHAR(20) | Result: created, updated, skipped, failed |
| `contactid` | INT | Contact ID created or updated |
| `fields_written` | INT | Number of fields written to the contact |
| `items_created` | INT | Number of contact items created |
| `error_code` | VARCHAR(50) | Error code if failed |
| `error_message` | VARCHAR(500) | Error message if failed |
| `created_at` | DATETIME | Result timestamp |

### feature_flag_users

Per-user allowlist for V3 access control.

| Column | Type | Purpose |
|--------|------|---------|
| `id` | INT AUTO_INCREMENT PK | Primary key |
| `flag_name` | VARCHAR(100) | Feature flag name |
| `userid` | INT | Allowed user ID |

### feature_flags

Global feature toggles.

| Column | Type | Purpose |
|--------|------|---------|
| `id` | INT AUTO_INCREMENT PK | Primary key |
| `flag_name` | VARCHAR(100) | Feature flag name (e.g., import_v3_enabled) |
| `flag_value` | VARCHAR(255) | Flag value (true/false or other) |

---

## 4. Workflow States (Job Status Machine)

### State Diagram

```
created --> uploaded --> parsing --> parsed --> mapping --> reviewing --> finalizing --> completed
                                       |                                    |              |
                                       +-----> reviewing                    |              |
                                       (skip mapping)                       v              v
                                                                         failed        reviewing
                                                                           |           (reset)
                                                                           v
                                                                        reviewing
                                                                        (reset)
```

### Valid Status Values

| Status | Description |
|--------|-------------|
| `created` | Job record exists but no file uploaded yet |
| `uploaded` | File uploaded and stored, awaiting parse |
| `parsing` | File is being parsed (lock held) |
| `parsed` | File parsed successfully, columns and rows populated |
| `mapping` | User is configuring column mappings |
| `reviewing` | User is reviewing rows, editing facts, setting actions |
| `finalizing` | Finalization in progress (lock held) |
| `completed` | All eligible rows imported successfully |
| `failed` | Job encountered an unrecoverable error |
| `cancelled` | Job cancelled by user |

### Status Transition Map

```
created     -> uploaded, failed, cancelled
uploaded    -> parsing, failed, cancelled
parsing     -> parsed, failed, cancelled
parsed      -> mapping, reviewing, failed, cancelled
mapping     -> reviewing, failed, cancelled
reviewing   -> finalizing, failed, cancelled
finalizing  -> completed, failed, cancelled, reviewing
completed   -> reviewing
failed      -> reviewing
cancelled   -> reviewing
```

### Terminal States

- `completed` -- all eligible rows were imported
- `failed` -- an unrecoverable error occurred
- `cancelled` -- the user cancelled the job

All three terminal states allow a reset transition back to `reviewing` via the `status.cfm` endpoint.

### Stuck Recovery

If a job is stuck in `finalizing` (e.g., due to a server crash or timeout), the system detects stale locks. The `releaseJobLock` method reverts a `finalizing` job back to `reviewing`. The UI also allows manual reset via `status.cfm`.

---

## 5. AJAX Endpoints

All endpoints return JSON with a standard envelope structure:

```json
{
    "success": true|false,
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "data": { ... }
}
```

Endpoints using debug breadcrumbs include `data.debug` (an array of step markers) and `data.elapsed_ms` for timing.

### CSRF Protection Pattern (Belt + Suspenders)

Write endpoints (POST) require a CSRF token. The token is read from three sources in priority order:

1. `X-CSRF-Token` HTTP header (preferred for JavaScript clients)
2. `csrf_token` field in JSON request body
3. `csrf_token` form field (fallback for traditional form POST)

The token is validated against `session.csrf_token`. If missing or mismatched, the endpoint returns `CSRF_INVALID` with HTTP 403.

---

### 5.1 upload.cfm

**URL**: `POST /ajax/importv3/upload.cfm`
**Content-Type**: `multipart/form-data`

**Required Parameters**:
- `file` (form file field): The file to upload

**Response Codes**:

| Code | HTTP Status | Meaning |
|------|-------------|---------|
| (success) | 200 | File uploaded, new job created |
| `AUTH_REQUIRED` | 200 | No valid session userid |
| `UPLOAD_FAILED` | 200 | File upload or storage failed |
| `INVALID_FILE_TYPE` | 200 | Extension not in whitelist (csv, xls, xlsx, vcf) |
| `FILE_TOO_LARGE` | 200 | File exceeds 50MB limit (52,428,800 bytes) |
| `DUPLICATE_FILE` | 200 | Same SHA-256 hash already uploaded by this user (returns existing job) |

**Notes**:
- The `DUPLICATE_FILE` response has `success: true` and returns the existing job details
- File is uploaded first, then validated; invalid files are deleted after detection
- SHA-256 hash is computed via Java `MessageDigest`
- Job is created with status `uploaded`

---

### 5.2 parse.cfm

**URL**: `POST /ajax/importv3/parse.cfm`
**Content-Type**: `application/json` or `application/x-www-form-urlencoded`

**Required Parameters**:
- `job_id` (from JSON body, form, or URL): The import job ID

**Response Codes**:

| Code | HTTP Status | Meaning |
|------|-------------|---------|
| (success) | 200 | File parsed, columns/rows/facts created |
| `AUTH_REQUIRED` | 200 | No valid session userid |
| `ACCESS_DENIED` | 200 | Job does not belong to user |
| `NOT_FOUND` | 200 | Job does not exist |
| `LOCKED` | 200 | Job is locked by another operation |
| `UNSUPPORTED_FILE_TYPE` | 200 | VCF parsing not yet supported |
| `PARSE_FAILED` | 200 | File parsing error |
| `ALREADY_PARSED` | 200 | Job already has parsed data (idempotent return with existing counts) |
| `VALIDATION_ERROR` | 200 | Missing or invalid job_id |
| `SERVICE_ERROR` | 200 | Service initialization or method call error |

**Processing Steps**:
1. Validate auth and job_id
2. Check idempotency (if already parsed, return existing counts)
3. Acquire job lock (status transitions to `parsing`)
4. Read file based on type:
   - CSV: Auto-detect delimiter (comma vs tab), parse with quote handling
   - XLS/XLSX: Read via `cfspreadsheet`
5. Insert column definitions into `import_v3_columns` (INSERT IGNORE)
6. Insert data rows into `import_v3_rows` (INSERT IGNORE)
7. Insert cell facts into `import_v3_facts` (INSERT IGNORE)
8. Update job row counts
9. Transition status to `parsed`

**Debug Breadcrumbs**: Yes (in `response.debug` array)

---

### 5.3 columns.cfm

**URL**: `GET/POST /ajax/importv3/columns.cfm`

#### GET: Retrieve Columns

**Required Parameters**:
- `job_id` (URL): The import job ID

**Response Data**:
- `columns`: Array of column objects with `column_id`, `source_name`, `intent`, `target_key`, `sample_values`, `user_confirmed`, `confidence`, etc.
- `available_fields`: Array of available contact fields for the mapping dropdown (firstName, lastName, email_business, phone_mobile, company, etc.)

#### POST: Update Column Mapping

**Required Parameters**:
- `job_id` (form): The import job ID
- `column_id` (form): The column to update

**Optional Parameters**:
- `intent` (form): ignore, contact_field, contact_item, tag, note, custom_meta
- `target_key` (form): Target field key (required for contact_field, contact_item, custom_meta intents)
- `transform_json` (form): JSON transformation rules
- `user_confirmed` (form): 1 to confirm, 0 to unconfirm

**Response Codes**:

| Code | HTTP Status | Meaning |
|------|-------------|---------|
| (success) | 200 | Columns returned or mapping updated |
| `AUTH_REQUIRED` | 200 | No valid session userid |
| `ACCESS_DENIED` | 200 | Job or column does not belong to user |
| `NOT_FOUND` | 200 | Job does not exist |
| `MISSING_JOB_ID` | 200 | job_id parameter missing |
| `MISSING_COLUMN_ID` | 200 | column_id parameter missing for POST |
| `INVALID_INTENT` | 200 | Intent value not in allowed list |
| `TARGET_KEY_REQUIRED` | 200 | target_key required for this intent |
| `INVALID_JSON` | 200 | transform_json is not valid JSON |
| `UPDATE_FAILED` | 200 | Column update failed |
| `INVALID_METHOD` | 200 | Only GET and POST methods are supported |

**Notes**:
- Auto-transitions job from `parsed` to `mapping` when a user confirms a column
- Sample values are pulled from `import_v3_facts` (up to 5 distinct non-empty values), falling back to stored `sample_values` JSON
- POST returns the full updated columns list (same format as GET)

---

### 5.4 rows.cfm

**URL**: `GET /ajax/importv3/rows.cfm`

**Required Parameters**:
- `job_id` (URL): The import job ID

**Optional Parameters**:
- `status` (URL): Filter by status -- ready, problem, dupe, ignored, imported, all (default: all)
- `page` (URL): Page number (default: 1)
- `page_size` (URL): Rows per page (default: 50, max: 200)
- `stats_only` (URL): If 1, return only stats without row data
- `search` (URL): Search term to filter rows

**Response Codes**:

| Code | HTTP Status | Meaning |
|------|-------------|---------|
| (success) | 200 | Rows returned successfully |
| `AUTH_REQUIRED` | 401 | No valid session userid |
| `ACCESS_DENIED` | 403 | Job does not belong to user |
| `NOT_FOUND` | 404 | Job does not exist |
| `MISSING_PARAMS` | 400 | job_id parameter missing |
| `INVALID_STATE` | 409 | Job not in allowed status (reviewing, finalizing, completed) |
| `INTERNAL_ERROR` | 500 | Unexpected error |

**Status Gate**: Only allows rows view from `reviewing`, `finalizing`, or `completed` states.

**Debug Breadcrumbs**: `["start","auth_ok","job_id_ok","params_parsed","service_init","job_loaded","status_ok","rows_fetched","done"]`

---

### 5.5 row.cfm

**URL**: `GET /ajax/importv3/row.cfm`

**Required Parameters**:
- `job_id` (URL): The import job ID
- `row_id` (URL): The row ID

**Response Codes**:

| Code | HTTP Status | Meaning |
|------|-------------|---------|
| (success) | 200 | Row detail returned successfully |
| `AUTH_REQUIRED` | 401 | No valid session userid |
| `ACCESS_DENIED` | 403 | Job does not belong to user |
| `NOT_FOUND` | 404 | Job or row does not exist |
| `MISSING_PARAMS` | 400 | job_id or row_id missing |
| `INVALID_STATE` | 409 | Job not in allowed status (reviewing, finalizing, completed) |
| `INTERNAL_ERROR` | 500 | Unexpected error |

**Status Gate**: Only allows row detail from `reviewing`, `finalizing`, or `completed` states.

**Debug Breadcrumbs**: `["start","auth_ok","params_ok","service_init","job_loaded","status_ok","row_fetched","done"]`

---

### 5.6 row_action.cfm

**URL**: `POST /ajax/importv3/row_action.cfm`
**Content-Type**: `application/json`

**Required Parameters**:
- `job_id` (URL, body, or form): The import job ID
- `action` (body or form): `ignore` or `create` (mapped internally to `skip` or `import_new`)
- `csrf_token` (header, body, or form): CSRF protection token

**Row Selection (one required)**:
- `row_id` (body, URL, or form): Single row ID
- `row_ids` (body): Array of row IDs for bulk operations
- `select_all_filter` (body): Status filter to apply action to all matching rows

**Response Codes**:

| Code | HTTP Status | Meaning |
|------|-------------|---------|
| (success) | 200 | Action applied successfully |
| `AUTH_REQUIRED` | 401 | No valid session userid |
| `CSRF_INVALID` | 403 | Invalid or missing CSRF token |
| `ACCESS_DENIED` | 403 | Job does not belong to user |
| `NOT_FOUND` | 404 | Job or row does not exist |
| `MISSING_PARAMS` | 400 | Required parameters missing |
| `INVALID_ACTION` | 400 | Action value not in allowed list |
| `UPDATE_NOT_SUPPORTED` | 400 | Update action not supported in create-only mode |
| `INVALID_STATE` | 409 | Job not in allowed status (reviewing, finalizing, completed) |
| `NO_ROWS_MATCH` | 400 | No rows match the select_all_filter |
| `UPDATE_FAILED` | 500 | Database update failed |

**Action Mapping**:
- UI sends `ignore` -> stored as `skip`
- UI sends `create` -> stored as `import_new`

**Status Gate**: Allows row actions from `reviewing`, `finalizing`, and `completed` states.

**Debug Breadcrumbs**: `["start","auth_ok","csrf_ok","body_parsed","params_ok","service_init","job_loaded","status_ok","action_called","action_applied","done"]`

---

### 5.7 fact_update.cfm

**URL**: `POST /ajax/importv3/fact_update.cfm`
**Content-Type**: `application/json`

**Required Parameters**:
- `job_id` (URL, body, or form): The import job ID
- `row_id` (URL, body, or form): The row ID
- `fields` (body only): Object with `field_name: new_value` pairs to update
- `csrf_token` (header, body, or form): CSRF protection token

**Response Codes**:

| Code | HTTP Status | Meaning |
|------|-------------|---------|
| (success) | 200 | Facts updated and row revalidated |
| `AUTH_REQUIRED` | 401 | No valid session userid |
| `CSRF_INVALID` | 403 | Invalid or missing CSRF token |
| `ACCESS_DENIED` | 403 | Job does not belong to user |
| `NOT_FOUND` | 404 | Job or row does not exist |
| `MISSING_PARAMS` | 400 | Required parameters missing |
| `INVALID_STATE` | 409 | Job not in allowed status (reviewing, finalizing) |
| `VALIDATION_ERROR` | 400 | Field validation failed |
| `UPDATE_FAILED` | 500 | Database update failed |

**Notes**:
- Updates the `normalized_value` of facts; `raw_value` is immutable and never modified
- After updating facts, the row is revalidated and its status recomputed
- Only allowed during `reviewing` and `finalizing` states

**Debug Breadcrumbs**: `["start","auth_ok","csrf_ok","body_parsed","params_ok","service_init","job_loaded","status_ok","update_called","facts_updated","done"]`

---

### 5.8 finalize.cfm

**URL**: `POST /ajax/importv3/finalize.cfm`
**Content-Type**: `application/json`

**Required Parameters**:
- `job_id` (URL, body, or form): The import job ID
- `csrf_token` (header, body, or form): CSRF protection token

**Response Codes**:

| Code | HTTP Status | Meaning |
|------|-------------|---------|
| (success) | 200 | Finalization completed |
| `AUTH_REQUIRED` | 401 | No valid session userid |
| `CSRF_INVALID` | 403 | Invalid or missing CSRF token |
| `ACCESS_DENIED` | 403 | Job does not belong to user |
| `NOT_FOUND` | 404 | Job does not exist |
| `MISSING_JOB_ID` | 400 | job_id parameter missing |
| `INVALID_STATE` | 409 | Job not in allowed status (reviewing, finalizing) |
| `ALREADY_RUNNING` | 409 | Finalize already in progress for this job |
| `ALREADY_COMPLETED` | 409 | Job has already been finalized |
| `LOCK_FAILED` | 409 | Could not acquire job lock |
| `NO_ROWS_ELIGIBLE` | 200 | No rows eligible for import (reverts to reviewing) |
| `INTERNAL_ERROR` | 500 | Finalize operation failed |

**Response Data (on success)**:
```json
{
    "counts": {
        "attempted": 10,
        "imported_new": 8,
        "updated_existing": 0,
        "skipped_already_imported": 0,
        "skipped_ignored": 0,
        "skipped_not_ready": 0,
        "failed": 2
    },
    "metrics": {
        "total_rows_processed": 10,
        "elapsed_ms_total": 1234,
        "elapsed_ms_per_row_avg": 123
    },
    "failures": [
        { "row_id": 5, "row_num": 5, "code": "MISSING_NAME", "message": "Contact name is required" }
    ],
    "warnings": []
}
```

**Debug Breadcrumbs**: `["start","auth_ok","csrf_ok","body_parsed","job_id_ok","service_init","job_loaded","status_ok","finalize_called","done"]`

---

### 5.9 status.cfm

**URL**: `POST /ajax/importv3/status.cfm`
**Content-Type**: `application/json`

**Required Parameters**:
- `job_id` (URL, body, or form): The import job ID
- `new_status` (body, URL, or form): The target status
- `csrf_token` (header, body, or form): CSRF protection token

**UI-Allowed Transitions**:
- `completed` -> `reviewing` (re-open for review)
- `failed` -> `reviewing` (re-open for review)
- `cancelled` -> `reviewing` (re-open for review)
- `finalizing` -> `reviewing` (unstick a stuck job)

The UI only allows `reviewing` as the target status. All other transitions are handled internally by the system.

**Response Codes**:

| Code | HTTP Status | Meaning |
|------|-------------|---------|
| (success) | 200 | Status changed successfully |
| `AUTH_REQUIRED` | 401 | No valid session userid |
| `CSRF_INVALID` | 403 | Invalid or missing CSRF token |
| `ACCESS_DENIED` | 403 | Job does not belong to user |
| `NOT_FOUND` | 404 | Job does not exist |
| `MISSING_PARAMS` | 400 | job_id or new_status missing |
| `INVALID_STATUS` | 400 | new_status not in UI-allowed list |
| `INVALID_STATE` | 409 | Transition not allowed by service status transition map |
| `INTERNAL_ERROR` | 500 | Status update failed |

**Debug Breadcrumbs**: `["start","auth_ok","csrf_ok","body_parsed","job_id_ok","status_param_ok","service_init","job_loaded","status_called","done"]`

---

## 6. Security Features

### SQL Injection Prevention

All 87 SQL queries across the workflow use `cfqueryparam` with typed parameters. No string concatenation is used in SQL construction. Two previously identified `arrayToList` injection risks have been fixed.

### CSRF Protection

Write endpoints use a belt-and-suspenders CSRF pattern:
1. Check `X-CSRF-Token` HTTP header
2. Fall back to `csrf_token` in JSON request body
3. Fall back to `csrf_token` form field
4. Validate against `session.csrf_token`
5. Return `CSRF_INVALID` (HTTP 403) on failure

The CSRF token is initialized as a UUID when the import page loads and persists for the session.

### Job Ownership Verification

Every endpoint verifies that the requesting user owns the job. The service method `getJobForUser()` uses a WHERE clause with both `job_id` and `userid`, not a post-query IF check. This means ownership is enforced at the SQL level.

If a job exists but belongs to another user, the response is `ACCESS_DENIED`. If the job does not exist at all, the response is `NOT_FOUND`.

### File Security

- **Hash-based duplicate detection**: SHA-256 hash prevents re-uploading the same file
- **File type whitelist**: Only csv, xls, xlsx, vcf extensions are accepted (validated both by `cffile accept` attribute and post-upload extension check)
- **File size limit**: 50MB maximum (52,428,800 bytes)
- **Invalid file cleanup**: If a file fails validation after upload, it is deleted from disk

### Input Validation

- All numeric parameters are validated with `isNumeric()` and `val()` checks
- Status filter values are validated against allowed lists
- Intent values are validated against the `VALID_INTENTS` array
- JSON body parsing is tolerant (BOM removal, empty body handling) but validated
- Page size is clamped to a maximum of 200

### Debug Breadcrumbs

Debug breadcrumbs included in responses contain no personally identifiable information (PII). They consist of step markers like `auth_ok`, `job_loaded`, `status_ok` that indicate progress through the endpoint without exposing user data, file contents, or contact information.

---

## 7. Finalization Logic

### Overview

Finalization is the process of creating actual contacts from approved import rows. It is the only operation that writes to production tables (`contactdetails`, `contactitems`).

### Lock Acquisition

1. `acquireJobLock()` attempts to transition the job from `reviewing` to `finalizing` using an atomic UPDATE with a WHERE clause that checks the current status
2. If the UPDATE affects 1 row, the lock is acquired
3. If 0 rows are affected, the lock fails (job is not in `reviewing` state)
4. If the job is already `finalizing`, the endpoint returns `ALREADY_RUNNING`
5. If the job is already `completed`, the endpoint returns `ALREADY_COMPLETED`

### Stale Lock Detection

If a job is stuck in `finalizing` (e.g., server crashed mid-finalize), the `releaseJobLock()` method can revert it back to `reviewing`. The UI provides a manual reset button via `status.cfm` that allows transitioning from `finalizing` to `reviewing`.

### Per-Row Processing

Each row is processed by `processRowForImport()` in its own transaction:

1. **Idempotency check**: If `created_contactid` is already set and a result exists in `import_v3_row_results`, the row is skipped with `skipped_already_imported`
2. **Load facts**: Fetch all valid, non-empty `normalized_value` facts for the row
3. **Validate minimum requirements**: Contact must have at least a name (`contactFullName`)
4. **Transaction block**:
   - Insert into `contactdetails` (userid, contactFullName, recordname)
   - Insert contact items via `insertContactItems()` (emails, phones, company, address fields)
   - Update `import_v3_rows` with status `imported`, `created_contactid`, and `imported_at`
   - Insert/update `import_v3_row_results` with action `created`, contactid, fields_written, items_created
5. **Log success event** (no PII in event payload)

### Row Eligibility

Rows are eligible for import if:
- `status = 'ready'` (passed all validation), OR
- `status = 'dupe'` AND `user_action = 'import_new'` (user explicitly approved the duplicate)

### Completion Logic

After processing all rows, the finalization determines the final job status:

- If `newlyImported` (imported_new + updated_existing) > 0: Job status set to `completed`
- If all rows were `skipped_already_imported` and none failed: Job status set to `completed` (idempotent re-run)
- If no rows were actually imported (all failed or skipped for other reasons): Lock is released, job reverts to `reviewing`, warning message added

### Error Recovery

If finalization throws an exception:
1. The error is logged to both the `importv3` log file and `import_v3_events` table
2. The job lock is released (status reverts from `finalizing` to `reviewing`)
3. The endpoint returns `INTERNAL_ERROR` with the error message

Individual row failures do not halt the entire finalization. Each row processes independently, and failures are counted in the `counts.failed` metric and detailed in the `failures` array.

---

## 8. Logging and Observability

### File Logging

All endpoints log to the `importv3` log file using `cflog` or `writeLog`:

- **START**: Logged at the beginning of every endpoint with userid
- **SUCCESS**: Logged on successful completion with timing (elapsed_ms)
- **ERROR**: Logged on any exception with message and detail

Example log entries:
```
[upload] START userid=123
[upload] HASH_COMPUTED userid=123 hash=abc123... file_type=csv file_size=45678
[upload] JOB_CREATED userid=123 job_id=456 file_type=csv file_size=45678 elapsed_ms=234
[parse] START userid=123
[parse] FILE_FOUND userid=123 job_id=456 file_type=csv
[parse] DB_INSERTS_DONE userid=123 job_id=456 columns=12 rows=150 facts=1800
[parse] SUCCESS userid=123 job_id=456 columns=12 rows=150 facts=1800
[finalize] START userid=123
[finalize] CALLING_SERVICE userid=123 job_id=456 status=reviewing
[finalizeJob] ROW_PROCESSED job_id=456 row_id=789 success=true action=created
[finalizeJob] COMPLETED job_id=456 userid=123 imported=8 failed=2 skipped=0 elapsed_ms=3456
```

### Database Event Logging

The `import_v3_events` table records structured events via the `logEvent()` service method:

| Event Type | When Logged |
|------------|-------------|
| `upload` | File uploaded successfully |
| `duplicate_file` | Duplicate file detected |
| `parse_started` | Parse operation begins |
| `parse_completed` | Parse operation completes |
| `parse_already_done` | Idempotent parse check |
| `parse_failed` | Parse operation fails |
| `columns_updated` | Column mapping changed |
| `lock_acquired` | Job lock acquired |
| `lock_released` | Job lock released |
| `lock_error` | Lock operation failed |
| `finalize_started` | Finalization begins |
| `finalize_completed` | Finalization completes with counts |
| `finalize_no_rows` | No eligible rows to finalize |
| `finalize_all_failed` | All rows failed during finalization |
| `finalize_error` | Finalization exception |
| `row_imported` | Single row imported successfully |
| `row_import_error` | Single row import failed |
| `status_changed` | Job status transitioned |
| Various `*_endpoint_error` | Endpoint-level exceptions |

### Debug Breadcrumbs

Every endpoint (except `upload.cfm` and early `parse.cfm`) includes a debug breadcrumbs array in the response. This is an array of string step markers that trace execution flow without exposing PII:

```json
{
    "data": {
        "debug": ["start", "auth_ok", "csrf_ok", "params_ok", "service_init", "job_loaded", "status_ok", "action_applied", "done"],
        "last_step": "done",
        "elapsed_ms": 45
    }
}
```

On error, `last_step` indicates the last successful step before the failure, aiding in diagnosis.

### JavaScript Console Logging

The frontend JavaScript controller (`contact-import-v3.js`) logs all AJAX calls, responses, and errors to the browser console for client-side debugging.

---

## 9. Known Limitations and Future Work

### Not Yet Implemented

- **VCF (vCard) parsing**: The upload endpoint accepts VCF files and creates a job, but `parse.cfm` returns `UNSUPPORTED_FILE_TYPE` for VCF files. VCF parsing logic needs to be built.

- **Update mode**: The `import_mode` field exists on `import_v3_jobs` but only `create_only` mode is implemented. Updating existing contacts based on matched rows is not yet supported.

- **Relationship system enrollment**: The `relationship_system` column mapping target and `relationship_system_default` job option exist in the schema, but enrollment into Target or Maintenance relationship systems after contact creation is not yet active.

### Current Limitations

- **No batch progress indicator**: During finalization of large imports, the UI shows only a timing message after completion. There is no real-time progress bar or row-by-row progress indicator during the finalize operation.

- **Excel file size**: Excel parsing uses ColdFusion's `cfspreadsheet` tag, which loads the entire spreadsheet into memory. Very large Excel files (tens of thousands of rows) may encounter memory limits depending on the ColdFusion server's JVM heap configuration.

- **CSV delimiter detection**: The parser auto-detects comma vs. tab delimiters based on character counts in the first line. Other delimiters (semicolon, pipe) are not detected.

- **Single-user locking**: The job lock is per-job, per-user. There is no mechanism for multiple users to collaborate on the same import job (which is by design -- each job is owned by one user).

---

## 10. Query Audit Summary

### Total Queries

87 SQL queries across the entire Contact Import V3 workflow.

### Parameterization Status

All 87 queries are fully parameterized using `cfqueryparam`. Two previously identified `arrayToList` injection risks (where dynamic list values were concatenated into SQL) have been fixed to use the `list: true` parameter in `cfqueryparam`.

### Tables Touched

| Table | Operations |
|-------|-----------|
| `import_v3_jobs` | SELECT, INSERT, UPDATE |
| `import_v3_columns` | SELECT, INSERT (IGNORE), UPDATE |
| `import_v3_rows` | SELECT, INSERT (IGNORE), UPDATE |
| `import_v3_facts` | SELECT, INSERT (IGNORE), UPDATE |
| `import_v3_events` | INSERT |
| `import_v3_row_results` | SELECT, INSERT (ON DUPLICATE KEY UPDATE) |
| `contactdetails` | INSERT (during finalization) |
| `contactitems` | INSERT (during finalization) |
| `taousers` | SELECT (user validation) |
| `feature_flag_users` | SELECT (access control) |
| `feature_flags` | SELECT (global feature toggles) |

### Query Distribution by File

| File | Query Count |
|------|-------------|
| `ContactImportV3Service.cfc` | ~55 |
| `upload.cfm` | ~3 |
| `parse.cfm` | ~12 |
| `columns.cfm` | ~8 |
| `rows.cfm` | ~3 |
| `row.cfm` | ~1 |
| `row_action.cfm` | ~2 |
| `fact_update.cfm` | ~1 |
| `finalize.cfm` | ~1 |
| `status.cfm` | ~1 |

### Test Script

A comprehensive query test script is available at `sql/import_v3_query_audit.sql`. This script:

- Verifies all import_v3 tables exist in the schema
- Checks index presence on all tables
- Tests every query pattern with sample parameter values
- Wraps all destructive queries in transactions that ROLLBACK
- Includes EXPLAIN for complex SELECT queries to verify index usage
- Can be run safely against the `new_development` schema without modifying data
