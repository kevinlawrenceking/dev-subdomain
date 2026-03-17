# Phase 10 -- Observability Audit

**Date:** 2026-03-16
**Scope:** Entire TAO codebase at `/c/Users/kevin/TAO/dev-subdomain/` (excluding `dev_backup/`)
**Auditor:** Claude Opus 4.6

---

## 10A -- Logging Inventory

### cflog Usage Summary

The codebase contains **~222 `cflog` / `writeLog` calls** spread across approximately **37 files** (excluding `dev_backup/`). Logging is heavily concentrated in two areas: the import pipelines and security-hardened identifier-validation files.

#### Log Files Written To (distinct `file=` targets)

| Log File Name | Purpose | Files Using It |
|---|---|---|
| `importv3` | Contact Import V3 pipeline | ~14 files (upload, parse, columns, rows, row, row_action, finalize, recompute, normalize_fact_fieldnames + services) |
| `importv3_debug` | Structured logger output (ImportV3Logger.cfc) + ValidationService | 3 files |
| `import_auditions` | Audition Import pipeline | ~14 files (same set mirrored) |
| `import_auditions_debug` | Structured logger output (ImportAuditionsLogger.cfc) | 1 file |
| `admin_users` | Admin user management CRUD | 6 files (list, get, save, toggle-status, send-email, preview-email, UserService.cfc) |
| `relationship_system` | RelationshipService.cfc | 1 file |
| `contactService` | ContactService_Consolidated.cfc | 1 file |
| `TAO_errors` | Global error handler (sched/error.cfm) | 1 file |
| `TAO_sched_errors` | Scheduler error handlers (Applicationxx.cfc, Application_last.cfc, sched/Application.cfc) | 3 files |
| `TAO_sched_init_errors` | Scheduler init failures | 2 files |
| `TAO_thrivecart_errors` | ThriveCart payment processing | 1 file |
| `TAO_thrivecart_mail_errors` | ThriveCart email failures | 1 file |
| `ipn_errors` | IPN handler errors | 2 files |
| `ipn_cancelled_debug` | IPN cancellation debug | 1 file |
| `debug_audition` | Headshot/media update debug | 1 file |
| `audition_import` | Legacy audition transfer errors | 1 file |
| `contact_export_errors` | Contact export errors | 1 file |
| `errorLog` | Generic error in contacts_check.cfm | 1 file |
| `email_test_errors` | Email testing errors | 1 file |
| `fetch_favicon_error` | Favicon fetch failures | 2 files |
| `cfoutputErrors` | cfoutput scheduled task | 1 file |
| `UpdateFormUpdate` | Security block log for identifier validation | 1 file |
| `remoteUpdateFormUpdate` | Security block log for identifier validation | 1 file |
| `remoteDeleteForm` | Security block log for identifier validation | 1 file |
| `contacts_ss` | Security block log for contacts table name validation | 1 file |
| `qry_details` | Security block log for details query | 1 file |
| `qry_update` | Security block log for update query | 1 file |
| `release_fix_qry` | Security block log for sched release fix | 1 file |
| `events_completed` | Security block log for events_completed uniquename | 1 file |

**Total distinct log file targets:** ~28

#### Logging Levels Used

- Most cflog calls use the **default level** (no explicit `type=` attribute, which defaults to `information`).
- Explicit `type="error"` appears in ~10 calls.
- Explicit `type="warning"` appears in ~2 calls (ValidationService, sched init).
- Explicit `type="fatal"` appears in 2 calls (recompute outermost catch blocks).
- No use of `type="debug"` at the cflog tag level (only via the structured logger wrappers).

#### Custom Logging Services

**Yes -- two structured loggers exist:**

1. **`/services/ImportV3Logger.cfc`** -- Per-request structured logger for Contact Import V3
   - Generates a correlation ID (8-char UUID prefix)
   - Writes to `importv3_debug` log file
   - Supports levels: DEBUG, INFO, WARN, ERROR, FATAL
   - Maintains in-memory debug trail array
   - Includes `extractErrorDetail()` for safe exception introspection
   - Includes `buildErrorResponse()` for client-safe error responses with correlation IDs
   - Used exclusively in `ajax/importv3/recompute.cfm`

2. **`/services/ImportAuditionsLogger.cfc`** -- Direct port for Audition Import pipeline
   - Same API as ImportV3Logger
   - Writes to `import_auditions_debug` log file
   - Used exclusively in `ajax/import-auditions/recompute.cfm`

3. **`/services/DebugService.cfc`** -- Minimal DB-backed debug logger
   - Single method `insertDebugLog(filename, debugDetails)` writes to a `debugLog` database table
   - No callers found in the current codebase (appears unused)

4. **`/services/RelationshipService.cfc`** -- Has its own internal `logAction()` method
   - Writes to `relationship_system` log file
   - Controlled by `variables.enableLogging` flag (currently `true`)
   - Includes JSON serialization of struct/array data payloads

5. **`/services/UpdateLogService.cfc`** -- Database update audit log
   - Used by `INSERT_266_3.cfm` and `results_331_1.cfm`
   - Not a general-purpose logging service

#### Structured Logging (JSON Format)

**Partial.** The ImportV3Logger and ImportAuditionsLogger serialize `detail` structs to JSON and append them to log lines. However, the log line format itself is key-value pairs (`cid=X job=Y uid=Z ep=A stage=B [LEVEL] message detail={json} elapsed_ms=N`), not pure JSON. No log lines anywhere in the codebase are written as full JSON objects.

### Service Logging Coverage

**Total service CFCs:** 137 (in `/services/`)
**Service CFCs with ANY `cflog` or `writeLog` calls:** 10

| Service | Has Logging |
|---|---|
| ContactImportV3Service.cfc | Yes (32+ writeLog calls) |
| AuditionImportService.cfc | Yes (26+ writeLog calls) |
| DuplicateMatcherService.cfc | Yes (12+ cflog calls) |
| AuditionDuplicateMatcherService.cfc | Yes (6+ cflog calls) |
| ImportV3Logger.cfc | Yes (is the logger itself) |
| ImportAuditionsLogger.cfc | Yes (is the logger itself) |
| RelationshipService.cfc | Yes (via internal logAction method) |
| UserService.cfc | Yes (4 cflog calls) |
| ContactService_Consolidated.cfc | Yes (7 cflog calls) |
| ValidationService.cfc | Yes (1 cflog call) |

**Service CFCs with NO logging at all:** 127 out of 137

> **Percentage of service CFCs with logging: 7.3% (10/137)**

This means core services like NotificationService.cfc, EventService.cfc, ContactService.cfc (the main one with 122 functions), ContactItemService.cfc (166 functions), SystemService.cfc, PageService.cfc, AuditionProjectService.cfc (94 functions), and dozens more operate completely silently -- no error logging, no audit trail, no debug output.

> **TECH-DEBT: No logging infrastructure.** Only the import pipelines (recently built) have meaningful logging. The remaining 92.7% of service functions (covering contacts, events, notifications, auditions, relationships, pages, exports, etc.) have zero observability. There is no centralized logging service, no log aggregation, no application-wide logger instance.

### Files with try/catch but NO logging

Of the 137 service CFCs, only 13 contain any `try/catch` blocks at all (166 total try blocks). Of those 13, only 10 actually log the caught errors. The other 3 (ContactDuplicateService.cfc, ContactImportV2Service.cfc, FileParserService.cfc) silently swallow some exceptions.

---

## 10B -- Error Notification Check

### Application.cfc Error Handlers

There are **9 Application.cfc files** in the codebase. Here is the error handling analysis for each:

#### 1. `/app/Application.cfc` (Main Application)

```
onError handler: YES (lines 357-388)
```

**Behavior:**
- Detects AJAX vs browser requests
- **AJAX path:** Returns JSON with `success: false`, `message`, `detail`, `type`, and partial `sql` (first 300 chars)
- **Browser path:** Runs `<cfdump var="#arguments.exception#" label="CF Error" top="2" />`

**Logging:** NONE. The onError handler does not write to any cflog file.
**Email notification:** NONE. No `cfmail` in any Application.cfc.
**Stack trace logging:** NO. The exception object is available but never logged to file.

**SECURITY FINDING:**

> SECURITY: Raw error exposed to user -- The main app's onError handler exposes internal details in two ways:
>
> 1. **AJAX responses** include `exception.message`, `exception.detail`, `exception.type`, and up to 300 characters of raw SQL (`exception.sql`). These are sent directly to the browser.
> 2. **Browser responses** use `<cfdump>` which renders the full exception structure (including stack traces, file paths, SQL statements) directly in the HTML page.
>
> Both paths leak server internals (file paths, SQL query fragments, exception types) to end users.

#### 2. `/sched/Application.cfc` (Scheduler -- current active)

- Extends `/app/Application` but overrides `onRequestStart` only
- **No onError handler of its own** -- inherits the main app's handler (which dumps to browser)

#### 3. `/sched/Applicationxx.cfc` (Scheduler -- backup/alternative)

```
onError handler: YES (line 142)
```

**Behavior:**
- Logs to `TAO_sched_errors` via cflog
- Outputs full error details including `exception.stackTrace` and `tagContext` as HTML
- No email notification

> SECURITY: Raw error exposed to user -- Full stack trace output to HTTP response (scheduler context, likely lower risk since scheduler requests are internal).

#### 4. `/sched/Application_last.cfc` (Scheduler -- old backup)

```
onError handler: YES (line 108)
```

**Behavior:**
- Logs to `TAO_sched_errors` via cflog
- Outputs minimal error page with Error ID
- No stack trace exposed to user (safe)
- No email notification

#### 5. `/ajax/Application.cfc` (AJAX endpoints)

- **No onError handler.** Does not extend `/app/Application`.
- Unhandled exceptions in AJAX endpoints will produce ColdFusion's default error page (which exposes stack traces).

> SECURITY: Raw error exposed to user -- AJAX Application.cfc has no error handler at all. Default ColdFusion error output will be returned for unhandled exceptions.

#### 6. `/include/Application.cfc`

- Extends `/app/Application`
- No onError handler (inherits main app's cfdump handler)

#### 7. `/sched/error.cfm` (Dedicated Error Page)

This is a standalone error page (not an Application.cfc onError, but likely configured as `cferror` or a site-wide error template):

- **Sends email:** YES -- sends to `kevinking7135@gmail.com` with full error details, stack trace, tag context, and session info
- **Logs to file:** YES -- writes to `TAO_errors` log
- **User-facing page:** Shows friendly error page with Error ID only
- **Debug mode:** Has a `showDebugInfo` flag (defaults to `false`) that can expose error details
- **Stack trace:** Logged in email only, not shown to user (when `showDebugInfo` is false)

This is the **best error handling** in the codebase, but it is only used in the `sched/` context.

### Error Handling Gap Summary

| Component | onError? | Logs Error? | Emails Alert? | Exposes Stack Trace? |
|---|---|---|---|---|
| `/app/Application.cfc` | Yes | NO | NO | **YES** (cfdump + JSON with SQL) |
| `/ajax/Application.cfc` | NO | NO | NO | **YES** (CF default) |
| `/include/Application.cfc` | Inherits | NO | NO | **YES** (inherits cfdump) |
| `/sched/Application.cfc` | Inherits | NO | NO | **YES** (inherits cfdump) |
| `/sched/Applicationxx.cfc` | Yes | Yes | NO | **YES** (full stack trace HTML) |
| `/sched/Application_last.cfc` | Yes | Yes | NO | No (safe) |
| `/sched/error.cfm` | N/A | Yes | Yes | No (safe, unless showDebugInfo) |

> **TECH-DEBT: No error alerting for the main application.** The primary `/app/Application.cfc` onError handler neither logs errors to file nor sends email notifications. Errors in the main app and AJAX endpoints are completely invisible to operations unless a user reports them.

> **SECURITY: Raw error exposed to user.** The main application's onError handler uses `<cfdump>` for browser requests and leaks SQL fragments for AJAX requests. The `/ajax/Application.cfc` has no error handler at all. These expose internal file paths, database query text, and exception types to end users.

---

## 10C -- Performance Instrumentation

### getTickCount() Usage

The codebase has **~80 `getTickCount()` calls** across **~25 files**. All usage is concentrated in two areas:

#### Import Pipelines (majority of usage)

Every import AJAX endpoint measures elapsed time:

| File | Pattern |
|---|---|
| `ajax/importv3/upload.cfm` | `startTick` at entry, `elapsed_ms` in response |
| `ajax/importv3/parse.cfm` | (no timing -- gap) |
| `ajax/importv3/columns.cfm` | `startTick` at entry, `elapsed_ms` in response |
| `ajax/importv3/rows.cfm` | `startTick` at entry, `elapsed_ms` in response + log |
| `ajax/importv3/row.cfm` | `startTick` at entry, `elapsed_ms` in response + log |
| `ajax/importv3/row_action.cfm` | `startTick` at entry, `elapsed_ms` in response |
| `ajax/importv3/fact_update.cfm` | `startTick` at entry, `elapsed_ms` in response + log |
| `ajax/importv3/finalize.cfm` | `startTick` at entry, `elapsed_ms` in log |
| `ajax/importv3/recompute.cfm` | Multi-phase timing with `outerStartTime`, `recomputeStartTime`, per-phase `phaseStart`, dupe timing |
| `ajax/importv3/status.cfm` | `startTick` at entry, `elapsed_ms` in response |
| `ajax/import-auditions/*` | Same pattern for all audition import endpoints |

**Services with timing:**
- `services/DuplicateMatcherService.cfc` -- `buildUserDupeIndex()` and `findDuplicates()` measure elapsed_ms
- `services/AuditionDuplicateMatcherService.cfc` -- index build timing
- `services/ContactImportV3Service.cfc` -- `finalizeJob()` measures total elapsed and per-row timing
- `services/AuditionImportService.cfc` -- `finalizeJob()` measures total elapsed
- `services/ImportV3Logger.cfc` -- `getElapsedMs()` accessor for per-request timing
- `services/ImportAuditionsLogger.cfc` -- same

#### Scripts with timing

- `scripts/relationship_system/repair_relationship_system.cfm` -- total script elapsed
- `scripts/relationship_system/run_audit.cfm` -- total script elapsed
- `test-ipn-cli.cfm` -- response time measurement

### Performance Instrumentation Coverage

| Area | Has Timing? |
|---|---|
| Contact Import V3 pipeline | **Yes** (comprehensive) |
| Audition Import pipeline | **Yes** (comprehensive) |
| Duplicate matching services | **Yes** |
| Relationship system scripts | **Yes** (total only) |
| Core AJAX endpoints (contacts, events, notifications, auditions) | **NO** |
| Page rendering | **NO** |
| Database queries | **NO** |
| Authentication/session setup | **NO** |
| Search/filtering endpoints | **NO** |
| Scheduled tasks (except repair scripts) | **NO** |

> **TECH-DEBT: No performance baseline.** Performance timing exists only in the import pipelines (recently built). The core application -- contact operations, notification engine, event management, audition CRUD, relationship workflows, page rendering -- has zero performance instrumentation. There is no way to detect slow queries, slow endpoints, or performance regressions in the main application.

### Monitoring Endpoints / Health Checks / Status Pages

**No formal health check or monitoring endpoint exists.**

The closest equivalents are:

1. **`/diagnostic.cfm`** -- Requires authenticated session. Shows server info (OS, CF version, Java version) and tests database connectivity. Not a proper health check (no standardized output format, requires login).

2. **`/sched/setup-verification.cfm`** -- Shows user-specific table record counts. Admin diagnostic, not a health check.

3. **`/ajax/importv3/diagnostics.cfm`** -- Import-specific diagnostics (job status, validation error summaries). Not a general health check.

4. **`/services/RelationshipService.cfc` `getSystemHealth()` method** -- Returns relationship system metrics (active systems, pending/overdue notifications, stuck systems, duplicate enrollments). Most sophisticated health check in the codebase, but only covers the relationship subsystem and has no HTTP endpoint.

> **TECH-DEBT: No monitoring endpoints.** There is no unauthenticated `/health` or `/status` endpoint that external monitoring tools (Pingdom, UptimeRobot, etc.) could hit. There is no standardized health check that reports database connectivity, service availability, or queue depths.

---

## Summary of Findings

### Critical Issues

| ID | Category | Finding |
|---|---|---|
| SEC-01 | SECURITY | Main app `onError` uses `<cfdump>` for browser requests, exposing full exception structures (file paths, SQL, stack traces) to end users |
| SEC-02 | SECURITY | Main app `onError` AJAX path returns `exception.sql` (up to 300 chars) in JSON response to browser |
| SEC-03 | SECURITY | `/ajax/Application.cfc` has no `onError` handler -- unhandled exceptions produce ColdFusion's default error page with full stack traces |

### Tech Debt

| ID | Category | Finding |
|---|---|---|
| TD-01 | TECH-DEBT | **No logging infrastructure.** 92.7% of service CFCs (127/137) have zero logging. Core modules (contacts, events, notifications, auditions CRUD, pages) are completely silent. |
| TD-02 | TECH-DEBT | **No centralized logger.** The two structured loggers (ImportV3Logger, ImportAuditionsLogger) are domain-specific and not reusable. No application-wide logging service exists. |
| TD-03 | TECH-DEBT | **Main app onError does not log errors.** Errors in `/app/` and `/ajax/` are not written to any log file or database table. |
| TD-04 | TECH-DEBT | **No error email alerting for main application.** Only `sched/error.cfm` sends email on error. The main app, AJAX, and include contexts have no error notification. |
| TD-05 | TECH-DEBT | **No performance baseline.** Only import pipelines have timing instrumentation. Core application endpoints have zero performance measurement. |
| TD-06 | TECH-DEBT | **No monitoring endpoints.** No `/health` or `/status` endpoint exists for external monitoring tools. |
| TD-07 | TECH-DEBT | **No log aggregation or rotation strategy.** 28 distinct log file targets with no documented rotation, retention, or aggregation approach. |
| TD-08 | TECH-DEBT | **DebugService.cfc appears unused.** The DB-backed debug logger has no callers in the codebase. |
| TD-09 | TECH-DEBT | **Inconsistent log file naming.** Mix of naming conventions: `importv3` vs `importv3_debug`, `TAO_errors` vs `errorLog` vs `contact_export_errors`. No naming standard. |

### Positive Findings

| Finding |
|---|
| Import V3 pipeline has comprehensive observability: structured logging with correlation IDs, per-phase timing, debug trails, and safe error extraction. This is a solid pattern to replicate. |
| RelationshipService.cfc has a well-designed internal `logAction()` method with conditional enable/disable and JSON detail serialization. |
| Security-hardening phase added cflog calls to all identifier-validation blocks, creating an audit trail for injection attempts. |
| `sched/error.cfm` is a well-structured error page: emails developer, logs to file, shows friendly user page, and has a controlled debug mode. |
| The `buildErrorResponse()` pattern in ImportV3Logger sanitizes raw SQL from client-facing messages and provides correlation IDs for support reference. |

---

## Recommended Priority Actions

1. **Immediate (Security):** Replace `<cfdump>` in `/app/Application.cfc` onError with a safe error page. Add `onError` to `/ajax/Application.cfc` that returns sanitized JSON. Stop leaking `exception.sql` to AJAX responses.

2. **High (Observability Foundation):** Create a centralized `LogService.cfc` based on the ImportV3Logger pattern. Register it in `application.services`. Wire it into the main `onError` handlers so all unhandled exceptions are logged + emailed.

3. **High (Error Alerting):** Add email notification to the main app's `onError` handler (same pattern as `sched/error.cfm`).

4. **Medium (Coverage):** Instrument the top 10 most-used services with try/catch logging: ContactService, ContactItemService, NotificationService, EventService, AuditionProjectService, SystemService, SystemUserService, PageService, NoteService, AuditionRoleService.

5. **Medium (Monitoring):** Create a `/health.cfm` endpoint that checks DB connectivity, returns JSON `{"status":"ok","db":"ok","timestamp":"..."}`, and can be polled by external monitoring.

6. **Low (Hygiene):** Standardize log file naming convention. Document log retention policy. Consider consolidating the 28 log targets into fewer, well-structured files.
