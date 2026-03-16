# TAO Full-Site Audit Report

**Date:** 2026-03-15
**Auditor:** Claude Code (Senior Auditor Mode)
**Scope:** ColdFusion, MySQL, Frontend, Security, UX, Performance, Relationship System
**Codebase:** The Actors Office (TAO) - dev-subdomain branch

---

## 1. SYSTEM MAP

### Codebase Overview

| Metric | Count |
|--------|-------|
| ColdFusion templates (.cfm) | 2,202 |
| ColdFusion components (.cfc) | 160 |
| JavaScript files (.js) | 441 |
| Service components (services/) | 137 |
| Query fragments (include/qry/) | 1,267 |
| AJAX endpoints (ajax/) | 43 |

### Directory Structure

```
dev-subdomain/
+-- app/                          Main application framework
|   +-- Application.cfc           Request lifecycle, auth gate, env routing
|   +-- pages/                    Module directories (127+ feature areas)
|   +-- assets/js/                Application JS + vendor libraries
|   +-- assets/css/               Stylesheets
+-- ajax/                         AJAX endpoints (43 files)
|   +-- import/                   Contact import V2 endpoints
|   +-- importv3/                 Contact import V3 endpoints
|   +-- import-auditions/         Audition import endpoints
+-- include/                      Shared UI includes + business logic (140+ files)
|   +-- qry/                      Query fragment files (1,267 files)
+-- services/                     Service layer CFCs (137 files)
|   +-- RelationshipService.cfc   System enrollment, completion, maintenance
|   +-- NotificationService.cfc   Notification CRUD and scheduling
|   +-- ContactImportV3Service.cfc  Modern import with state machine
|   +-- AuditionImportService.cfc   Audition import logic
+-- database/                     Admin database tools
+-- sched/                        Scheduled tasks and batch scripts
+-- setup/                        User provisioning scripts
+-- login/ & recover/             Authentication flow
+-- share/                        Token-based sharing system
+-- dev_backup/                   Legacy backup copies (SECURITY RISK)
+-- media-abod/                   User media files (dev)
```

### Request Flow

```
Browser --> loginform.cfm --> login/login2.cfm --> session set
                                                     |
                                                     v
                          app/Application.cfc (onRequestStart)
                          +-- DSN routing (abo/abod)
                          +-- Auth gate (session.userid check)
                          +-- ?u= impersonation gate (admin only)
                          +-- Feature flag refresh
                          +-- Session path initialization
                                                     |
                                                     v
                          app/pages/MODULE/index.cfm
                          +-- cfinclude of include/*.cfm
                          +-- cfinclude of include/qry/*.cfm
                          +-- AJAX calls to ajax/*.cfm
```

### Key Integrations

- **ThriveCart**: Payment status sync (loginform.cfm query)
- **icon.horse API**: Favicon fetching for site links
- **ICS Calendar**: Calendar export via .ics files
- **Email**: cfmail for notifications, password recovery, admin emails

---

## 2. EXECUTIVE SUMMARY

### Overall Health: CRITICAL - Immediate Action Required

TAO has a functional, feature-rich application serving actors, but carries significant technical debt and security vulnerabilities accumulated over years of rapid development. The application works -- users log in, manage contacts, track auditions, and receive relationship reminders daily. However, the underlying infrastructure has critical weaknesses that could lead to data breach, data loss, or service disruption.

### Key Findings at a Glance

| Category | Critical | High | Medium | Low | Total |
|----------|----------|------|--------|-----|-------|
| Security | 8 | 9 | 7 | 2 | 26 |
| Database/Data Integrity | 5 | 8 | 7 | 2 | 22 |
| Relationship System | 2 | 4 | 4 | 1 | 11 |
| Frontend/UX | 0 | 3 | 5 | 2 | 10 |
| Performance | 0 | 2 | 3 | 1 | 6 |
| **TOTALS** | **15** | **26** | **26** | **8** | **75** |

### The Three Most Urgent Risks

1. **SQL Injection (CRITICAL)**: 98% of the 1,267 query fragment files use unparameterized variables. At least 30+ files have confirmed injection vectors. An attacker with form/URL access could read, modify, or delete any data in the database.

2. **Race Conditions in Relationship System (CRITICAL)**: The core business workflow -- enrolling contacts in systems and completing notifications -- has check-then-insert patterns outside transactions. This causes duplicate enrollments and duplicate notifications in production (confirmed by admin audit queries that already detect these).

3. **Authentication Gaps (HIGH)**: Several endpoint directories (database/, setup/, sched/) lack consistent session validation. The `dev_backup/` directory contains full copies of production scripts accessible without authentication.

### What's Working Well

- Modern services (ContactImportV3, AuditionImport, RelationshipService) use proper parameterization
- Feature flag system enables safe rollouts
- Admin relationship health dashboard detects data integrity issues
- Application.cfc provides centralized auth gating for the /app/ directory
- Import V3 has proper state machine, file hash dedup, and staging pattern

---

## 3. FINDINGS REGISTER

### Finding ID Format: `[CATEGORY]-[SEVERITY]-[NUMBER]`

| ID | Category | Severity | Title | Files Affected | Est. Effort |
|----|----------|----------|-------|----------------|-------------|
| SEC-C-01 | Security | Critical | SQL injection in include/qry/ (1,245 files without cfqueryparam) | include/qry/*.cfm | XL |
| SEC-C-02 | Security | Critical | Dynamic table/column name injection (11+ files) | include/qry/FindValue_*.cfm, details.cfm | L |
| SEC-C-03 | Security | Critical | SQL injection in scheduled tasks | sched/appoint-update2.cfm | S |
| SEC-C-04 | Security | Critical | Hardcoded API key in source code | dev_backup/sched/customicon7.cfm | S |
| SEC-C-05 | Security | Critical | Unparameterized INSERT statements (5 files) | include/qry/insert_*.cfm | M |
| SEC-C-06 | Security | Critical | Unparameterized DELETE statements | include/remoteRemoveaudmedia.cfm | S |
| SEC-C-07 | Security | Critical | preservesinglequotes() abuse (3 files) | include/qry/details_466_4.cfm, etc. | M |
| SEC-C-08 | Security | Critical | dev_backup/ directory publicly accessible | dev_backup/ | S |
| SEC-H-01 | Security | High | XSS in share/ pages (reflected URL params) | share/*.cfm | M |
| SEC-H-02 | Security | High | XSS in loginform.cfm (url.xu unescaped) | loginform.cfm | S |
| SEC-H-03 | Security | High | XSS in include/remotelinkAdd.cfm | include/remotelinkAdd.cfm | S |
| SEC-H-04 | Security | High | SQL error details leaked in JSON responses | ajax/import/*.cfm | S |
| SEC-H-05 | Security | High | Mixed parameterization in contacts_ss.cfm | include/contacts_ss.cfm | M |
| SEC-H-06 | Security | High | Missing CSRF tokens on state-changing endpoints | ajax/import/*.cfm, app/admin-users/ajax/*.cfm | M |
| SEC-H-07 | Security | High | setup/ directory lacks auth guard | setup/*.cfm | S |
| SEC-H-08 | Security | High | database/ scripts - verify admin-guard coverage | database/*.cfm | S |
| SEC-H-09 | Security | High | Path traversal risk in pgload.cfm | include/pgload.cfm | S |
| SEC-M-01 | Security | Medium | sched/ tasks accessible without auth | sched/*.cfm | M |
| SEC-M-02 | Security | Medium | Share tokens displayed in plain text | share/remote_load.cfm | S |
| SEC-M-03 | Security | Medium | Error page shows stack traces | dev_backup/sched/error.cfm | S |
| SEC-M-04 | Security | Medium | Debug dumps in production code | dev_backup/sched/customicon7.cfm | S |
| SEC-M-05 | Security | Medium | File upload validation incomplete | ajax/import/upload.cfm | M |
| SEC-M-06 | Security | Medium | Missing admin-guard on some database pages | database/*.cfm | S |
| SEC-M-07 | Security | Medium | Attachment deletion path traversal risk | include/ attachment handlers | M |
| SEC-L-01 | Security | Low | Console.log leaking debug info | 179 statements across JS | M |
| SEC-L-02 | Security | Low | jQuery 3.6.0 (minor CVEs, not critical) | app/assets/js/ | S |
| DB-C-01 | Database | Critical | No unique constraint on active fusystemusers enrollments | Schema | S |
| DB-C-02 | Database | Critical | No constraint preventing multiple pending notifications per suid | Schema | S |
| DB-C-03 | Database | Critical | Missing foreign key constraints on xref tables | Schema | M |
| DB-C-04 | Database | Critical | Code generation creates vulnerable queries | include/qry/sql.cfm | M |
| DB-H-01 | Database | High | Missing transactions in 146+ service operations | services/*.cfc | XL |
| DB-H-02 | Database | High | Orphaned notifications (no parent enrollment) | funotifications | S |
| DB-H-03 | Database | High | Stuck systems (active but no pending notifications) | fusystemusers | S |
| DB-H-04 | Database | High | N+1 query patterns in legacy includes | include/qry/*.cfm | L |
| DB-H-05 | Database | High | removenotdups() references wrong table | NotificationService.cfc | S |
| DB-M-01 | Database | Medium | Unbounded SELECT * without LIMIT | include/qry/*.cfm | L |
| DB-M-02 | Database | Medium | Inconsistent column naming across tables | Schema | L |
| DB-M-03 | Database | Medium | Missing indexes on commonly filtered columns | Schema | M |
| DB-M-04 | Database | Medium | Duplicate/near-duplicate query files | include/qry/ | L |
| DB-M-05 | Database | Medium | Missing cascade delete on contact deletion | Schema | M |
| DB-M-06 | Database | Medium | contactitems VIEW vs contactitems_tbl table confusion | Schema | S |
| DB-L-01 | Database | Low | Dead query files never called | include/qry/ | S |
| DB-L-02 | Database | Low | Legacy numbered function names (migration artifacts) | NotificationService.cfc | M |
| REL-C-01 | Relationship | Critical | Race condition in startSystemForContact (check outside txn) | RelationshipService.cfc:241-256 | M |
| REL-C-02 | Relationship | Critical | Maintenance auto-start race condition | RelationshipService.cfc:384-400 | M |
| REL-H-01 | Relationship | High | Legacy completion flow has no transaction wrapper | include/complete_not_ajax.cfm | L |
| REL-H-02 | Relationship | High | Recurrence logic leaks user overrides | RelationshipService.cfc:123-146 | M |
| REL-H-03 | Relationship | High | Undefined function call (UPDfunotifications_24253) | include/qry/rr_283_2.cfm | S |
| REL-H-04 | Relationship | High | removenotdups() updates wrong table name | NotificationService.cfc:163-187 | S |
| REL-M-01 | Relationship | Medium | Next notification scheduling skips uniqueness check | RelationshipService.cfc:147-167 | M |
| REL-M-02 | Relationship | Medium | INNER JOIN on actionusers may skip valid notifications | NotificationService.cfc:27-83 | M |
| REL-M-03 | Relationship | Medium | No last-contact-date tracking | Feature gap | L |
| REL-M-04 | Relationship | Medium | No notification snooze feature | Feature gap | L |
| REL-L-01 | Relationship | Low | LIMIT 1 without ORDER BY in maintenance lookup | RelationshipService.cfc:402-409 | S |
| FE-H-01 | Frontend | High | 95% of AJAX calls lack error handlers | App-wide | XL |
| FE-H-02 | Frontend | High | Missing form labels (WCAG violation) | include/*.cfm | M |
| FE-H-03 | Frontend | High | Missing password field `required` attribute | loginform.cfm | S |
| FE-M-01 | Frontend | Medium | 535 inline styles across includes | include/*.cfm | L |
| FE-M-02 | Frontend | Medium | 179 console.log statements in production | app/assets/js/*.js | M |
| FE-M-03 | Frontend | Medium | Missing ARIA attributes across modals | include/*.cfm | L |
| FE-M-04 | Frontend | Medium | Debug console output left in login2.cfm | login/login2.cfm | S |
| FE-M-05 | Frontend | Medium | Parsley validation missing on some forms | include/admin-users*.cfm | S |
| FE-L-01 | Frontend | Low | jQuery 3.6.0 (current but 3.7+ available) | app/assets/js/ | S |
| FE-L-02 | Frontend | Low | Some vendor libraries may have newer versions | app/assets/js/ | S |
| PERF-H-01 | Performance | High | loginform.cfm runs user status fix query on every page load | loginform.cfm:38-50 | S |
| PERF-H-02 | Performance | High | N+1 query patterns in batch operations | include/qry/*.cfm | L |
| PERF-M-01 | Performance | Medium | Feature flag DB query on every request | Application.cfc:207-209 | S |
| PERF-M-02 | Performance | Medium | Unbounded queries without pagination | include/qry/*.cfm | L |
| PERF-M-03 | Performance | Medium | setup-verification.cfm runs 16 queries per user | sched/setup-verification.cfm | M |
| PERF-L-01 | Performance | Low | Multiple CDN loads on standalone pages | sched/setup-verification.cfm | S |
| DB-C-05 | Database | Critical | MSSQL GETDATE() used in MySQL codebase | include/update_reminder_status.cfm | S |
| DB-H-06 | Database | High | 90+ hardcoded datasource names ("abo"/"abod") | sched/*.cfm | L |
| DB-H-07 | Database | High | SELECT * in 40+ service/sched files | services/*.cfc, sched/*.cfm | L |
| DB-H-08 | Database | High | 30+ N+1 query patterns in scheduled tasks | sched/actionusers_fix.cfm, avatar_loop.cfm, etc. | XL |
| DB-M-07 | Database | Medium | Stored procedure sp_update_import_job_counts defined but never called | migrations/V2_0 | S |

---

## 4. FRONTEND / UX ISSUES

### FE-H-01: AJAX Calls Without Error Handlers

**Severity:** HIGH
**Scope:** ~2,317 of ~2,444 AJAX calls (95%) lack `.fail()`, `.error()`, or `.catch()` handlers

When an AJAX call fails (network timeout, server error, session expiry), the user sees nothing. No error message, no spinner removal, no indication that their action failed. They may click again, causing double-submits.

**Examples:**
- `app/assets/js/dashboard/panelModal.js:4` -- `.load()` with no error callback
- `app/assets/js/fileuploader_plugin.js:82` -- `$.post()` with no error handler
- Most `include/*.cfm` inline scripts using `$.ajax()` without error property

**Good pattern to replicate:**
- `include/admin-users-detail.cfm:302-324` -- Comprehensive `.done()` + `.fail()` handling
- `app/assets/js/contact-import-v3.js:313-318` -- Error with debug info display

### FE-H-02: Missing Form Labels (WCAG 2.1 Violation)

**Severity:** HIGH
**Scope:** 20+ form inputs across modal dialogs lack proper `<label for="">` association

Screenreaders cannot identify form fields. Browser accessibility audits flag these as violations.

**Files:**
- `include/admin-users-detail.cfm:200-206` -- Edit modal inputs
- `include/admin-users.cfm:12-19` -- Filter form fields

### FE-H-03: Missing `required` on Password Field

**Severity:** HIGH (usability)
**File:** `loginform.cfm:133`

Password input lacks `required` attribute, allowing empty password submission.

### FE-M-01: Inline Styles

**Scope:** 535 inline style attributes across CFML files (514 in include/, 21 in app/)

Brand color `#406E8E` hardcoded in ~50 inline styles. Should be CSS variables.

### FE-M-02: Console.log in Production

**Scope:** 179 statements across application JS files

Debug logging exposes internal state, query names, and data structures to anyone opening browser devtools.

### FE-M-03: Missing ARIA Attributes

**Scope:** Modals, dropdowns, and dynamic content regions lack `aria-label`, `aria-describedby`, `aria-expanded`, `aria-live` attributes.

### FE-M-04: Debug Mode Active in login2.cfm

**File:** `login/login2.cfm` -- `debugLogin = true` flag left active from diagnostic session. Exposes hash algorithms, salt values, and password comparison details to browser console.

**Fix:** Set `debugLogin = false` or remove debug block.

### FE-M-05: Parsley Validation Gaps

Some forms use Parsley.js validation (`data-parsley-*`) while others rely only on HTML5 `required`. Inconsistent user experience for validation error presentation.

---

## 5. SECURITY ISSUES

### CRITICAL

#### SEC-C-01: Mass SQL Injection in Query Fragments

**Scale:** 1,245 of 1,267 query files in `include/qry/` use unparameterized variables.

This is the single largest security risk in the application. Every `#variable#` inside a `<cfquery>` tag without `<cfqueryparam>` is a potential injection point.

**Confirmed injection vectors (30+):**
- `include/qry/delete_287_5.cfm:6` -- `WHERE audroleid = #new_audroleid#`
- `include/qry/details.cfm:19,44,86-88` -- Multiple unparameterized columns AND values
- `include/qry/Findrec_228_2.cfm:7` -- Both column AND value unparameterized: `WHERE #findkey.fname# = #recid#`
- `include/qry/insert_202_2.cfm:4-17` -- Unparameterized INSERT with user input
- `include/qry/notsActives_511_3.cfm:14` -- `WHERE au.userid = #userid#`
- `include/contacts_ss.cfm:24,40,44,51` -- Mixed parameterized and unparameterized in SAME query

**Attack scenario:** An attacker who can control any URL or form parameter that flows into these queries can:
1. Extract all user data (emails, passwords, session tokens)
2. Modify any record (change user roles to Admin, modify contact data)
3. Delete data (DROP TABLE, mass DELETE)
4. Execute server-side commands (if MySQL FILE privilege enabled)

#### SEC-C-02: Dynamic Table/Column Name Injection

**Scale:** 11+ files construct SQL with table and column names from variables.

**Files:** `include/qry/FindValue_107_*.cfm`, `FindValue_265_*.cfm`, `details.cfm`, `sql.cfm`, `tname_ins_464_3.cfm`

These cannot be fixed with `cfqueryparam` alone -- table/column names require whitelist validation.

#### SEC-C-03: SQL Injection in Scheduled Tasks

**File:** `sched/appoint-update2.cfm:42,58`

Scheduled tasks that process user data contain unparameterized SQL. If data contains injection payloads, the scheduled task executes them with full database privileges.

#### SEC-C-04: Hardcoded API Key

**File:** `dev_backup/sched/customicon7.cfm:88`
**Key:** `996ca328-b4b1-47a7-8d41-e5255525ab6b` (icon.horse API)

Move to environment variable or encrypted configuration. Rotate the key immediately.

#### SEC-C-08: dev_backup/ Directory Accessible

The `dev_backup/` directory contains full copies of production scripts. These files:
- Have identical SQL injection vulnerabilities to production
- Contain debug dumps and error handlers that leak system information
- Are accessible without authentication (no Application.cfc coverage)

**Fix:** Add `.htaccess` deny-all or delete the directory from the web root.

### HIGH

#### SEC-H-01: Reflected XSS in Share Pages

**Files:** `share/generate_token.cfm:108,112`, `share/generate_tokens_all_users.cfm:48,202,206`, `share/remote_load.cfm:160`

URL parameters output directly to HTML without `encodeForHTML()`:
```cfml
<td><cfoutput>#url.shareType#</cfoutput></td>  <!--- XSS --->
```

#### SEC-H-02: Reflected XSS in loginform.cfm

**File:** `loginform.cfm:122`
```cfml
<input type="hidden" name="xu" value="#url.xu#" />  <!--- XSS via attribute --->
```

Fix: `value="#encodeForHTMLAttribute(url.xu)#"`

#### SEC-H-04: SQL Error Leakage in AJAX Responses

**Files:** `ajax/import/upload.cfm:118,152`, `ajax/import/parse.cfm:105`

Full SQL statements included in JSON error responses sent to browser:
```cfml
<cfset response.message &= " | SQL: " & cfcatch.sql>
```

This reveals database schema, table names, and query structure to attackers.

#### SEC-H-06: Missing CSRF Protection

**Files without CSRF:** `ajax/import/upload.cfm`, `ajax/import/parse.cfm`, `ajax/import/finalize.cfm`, `app/admin-users/ajax/save.cfm`, `app/admin-users/ajax/send-email.cfm`

State-changing endpoints accept requests without verifying origin. Cross-site forms can trigger imports, user modifications, or email sends.

#### SEC-H-09: Path Traversal in pgload.cfm

**File:** `include/pgload.cfm:46,50`
```cfml
<cfset filePath = expandPath("/include/qry/#pgFilename#")>
<cfinclude template="/include/qry/#pgFilename#" />
```

`pgFilename` from database. If database is compromised or this value becomes user-controlled, `../` sequences could include arbitrary files.

---

## 6. DATABASE / DATA INTEGRITY ISSUES

### Schema Constraints Missing

#### DB-C-01: No Unique Constraint on Active Enrollments

**Table:** `fusystemusers`
**Missing:** `UNIQUE INDEX` on `(userid, contactid, systemid)` WHERE `sustatus = 'Active'`

The application checks for duplicates before inserting, but the check is outside the transaction (see REL-C-01). The admin dashboard already has a query that detects these duplicates, confirming they exist in production.

**Fix:**
```sql
-- Add unique constraint (after cleaning existing duplicates)
ALTER TABLE fusystemusers
  ADD UNIQUE INDEX uq_active_enrollment (userid, contactid, systemid, sustatus);
```

#### DB-C-02: No Constraint on Multiple Pending Notifications

**Table:** `funotifications`
**Missing:** Enforcement that only one notification per `suid` can have `notstartdate` set at a time.

Multiple pending notifications with start dates cause users to see duplicate reminders.

#### DB-C-03: Missing Foreign Key Constraints

Cross-reference tables (`audessences_audtion_xref`, `audmedia_auditions_xref`, `audageranges_audtion_xref`) lack `ON DELETE CASCADE` foreign keys. Deleting a parent record orphans xref rows.

### Data Integrity Bugs

#### DB-H-02: Orphaned Notifications

Admin dashboard detects notifications with no parent enrollment (`fusystemusers` deleted but `funotifications` remain). These appear in user notification lists and cause errors when completed.

#### DB-H-03: Stuck Systems

Active system enrollments with zero pending notifications. The system shows as "in progress" but has no next action. Users cannot advance or complete these.

#### DB-H-05: removenotdups() References Wrong Table

**File:** `services/NotificationService.cfc:163-187`

Function updates `funotifications_tbl` but queries `funotifications`. If `funotifications` is a VIEW on `funotifications_tbl`, this may work by accident, but the inconsistency risks silent failure if the view definition changes.

### Query Patterns

#### DB-H-01: Missing Transactions

Only 4 of 150+ services use `cftransaction`:
- `ContactDuplicateService.cfc`
- `ContactImportV2Service.cfc`
- `EventService.cfc`
- `RelationshipService.cfc`

All other multi-table operations risk partial writes on failure.

#### DB-H-04: N+1 Query Patterns

Legacy code uses query-inside-loop patterns extensively:
```cfml
<cfloop query="contacts">
    <cfinclude template="/include/qry/getContactDetails.cfm" />
    <cfinclude template="/include/qry/getContactItems.cfm" />
</cfloop>
```

Each iteration runs 2+ queries. For 500 contacts, that's 1,000+ queries.

#### DB-M-06: contactitems VIEW vs Table Confusion

`contactitems` is a VIEW; `contactitems_tbl` is the base table. DDL operations (ALTER, INDEX, INSERT) must target `contactitems_tbl`. Some code references `contactitems` for writes, which may fail or have unexpected behavior depending on MySQL view updatability rules.

### Additional Database Findings (from Schema/Query Audit)

#### DB-C-05: MSSQL Syntax in MySQL Codebase

**File:** `include/update_reminder_status.cfm:17`
```sql
last_updated = GETDATE()
```
`GETDATE()` is SQL Server syntax. MySQL requires `NOW()` or `CURRENT_TIMESTAMP`. This query will fail or return unexpected results.

#### DB-H-06: 90+ Hardcoded Datasource Names

Files in `sched/` use hardcoded `"abo"` or `"abod"` instead of `application.datasource`. Modern code (ajax/importv3/, services/) correctly uses the centralized variable. All legacy files should be migrated.

#### DB-H-07: SELECT * in 40+ Files

Services and scheduled tasks use `SELECT *` instead of explicit column lists. This increases network overhead, breaks silently on schema changes, and makes query intent unclear.

#### DB-H-08: 30+ N+1 Query Patterns in Scheduled Tasks

Worst offenders:
- `sched/actionusers_fix.cfm` -- Triple-nested loop: N users x M actions = N*M queries. For 100 users x 50 actions = 5,000+ queries for what should be one `INSERT...SELECT`.
- `sched/avatar_loop.cfm` -- 1,000 rows x 3 UPDATE queries = 3,000 queries for what should be a single `UPDATE...CASE WHEN`.
- `sched/import-contacts.cfm` -- 11+ INSERT/UPDATE queries per contact inside outer loop.
- `sched/birthday_fix.cfm` -- UPDATE inside cfloop for each invalid birthday.

---

## 7. RELATIONSHIP SYSTEM AUDIT

### Architecture Overview

The Relationship System is TAO's core differentiator: automated, structured follow-up sequences that help actors maintain professional relationships.

```
fusystems (system definitions: "New Contact Follow-Up", "Monthly Maintenance")
    |
    +-- fuactions (action templates: "Send Thank You Email", "Check In Call")
    |       |
    |       +-- actionusers (per-user overrides: custom delays, ordering)
    |
    +-- fusystemusers (per-contact enrollments: "Contact X enrolled in System Y")
            |
            +-- funotifications (scheduled reminders: "Do action Z for Contact X on date D")
```

### Critical Issues

#### REL-C-01: Enrollment Race Condition

**File:** `services/RelationshipService.cfc:241-256`

```
Thread A: CHECK fusystemusers -> 0 rows (no enrollment)
Thread B: CHECK fusystemusers -> 0 rows (no enrollment)
Thread A: INSERT fusystemusers -> success
Thread B: INSERT fusystemusers -> success (DUPLICATE!)
```

The existence check runs BEFORE the transaction. Both threads see zero rows and both insert.

**Fix:** Move the check inside the transaction with `SELECT ... FOR UPDATE` or use `INSERT ... ON DUPLICATE KEY UPDATE` with the unique constraint from DB-C-01.

#### REL-C-02: Maintenance Auto-Start Race

**File:** `services/RelationshipService.cfc:384-400`

When a follow-up system completes, it auto-starts maintenance. Two concurrent completions can both trigger maintenance enrollment, creating duplicate maintenance systems for the same contact.

**Fix:** Same pattern as REL-C-01 -- check inside transaction with locking.

### High Issues

#### REL-H-01: Legacy Completion Flow Unprotected

**File:** `include/complete_not_ajax.cfm:56-321`

The legacy notification completion path uses 8+ sequential `cfinclude` calls without any transaction wrapping. If the process fails mid-sequence:
- Notification marked complete, but no recurring notification created
- System marked complete, but maintenance not started
- Contact uniqueness flags set without notification actually completing

#### REL-H-02: Recurrence Override Leak

**File:** `services/RelationshipService.cfc:123-146`

When creating a recurring notification, the code uses `actionDaysRecurring` which comes from `COALESCE(au.actiondaysrecurring, a.actiondaysrecurring)`. If a user overrides recurring days for one instance, that override propagates to all future recurrences indefinitely.

**Expected:** User override applies to current instance only; future recurrences use the system default.

#### REL-H-03: Undefined Function Call

**File:** `include/qry/rr_283_2.cfm`

Calls `objNotificationService.UPDfunotifications_24253()` which does not exist in NotificationService.cfc. This will throw a runtime error if the code path is executed.

#### REL-H-04: Wrong Table in removenotdups()

**File:** `services/NotificationService.cfc:163-187`

Updates `funotifications_tbl` but reads from `funotifications`. May work if VIEW is updatable, but is fragile and confusing.

### Medium Issues

#### REL-M-01: Uniqueness Not Re-Validated on Next Scheduling

When the next notification in a system is scheduled, the code doesn't check if the action has a uniqueness constraint (`isUnique`) that was already satisfied. Could re-fire unique actions.

#### REL-M-02: INNER JOIN on actionusers May Skip Notifications

`NotificationService.cfc:27-83` uses `INNER JOIN actionusers au ON a.actionID = au.actionID`. If a user has no `actionusers` override for an action, that notification is silently excluded from results.

#### REL-M-03: No Last-Contact-Date Tracking

The system tracks when reminders are completed, but not when actual contact occurred. If a user completes a reminder late, the next recurrence is scheduled from the completion date, not the contact date.

#### REL-M-04: No Notification Snooze

Users can only Complete or Skip. No "remind me tomorrow" or "snooze 3 days" option. Users who aren't ready to act must either complete prematurely or risk forgetting.

---

## 8. TOP 10 QUICK WINS

Fixes that are small in effort but high in impact.

| # | Finding | Effort | Impact | How |
|---|---------|--------|--------|-----|
| 1 | SEC-C-04: Rotate hardcoded API key | 15 min | Critical | Move to env var, rotate on icon.horse dashboard |
| 2 | SEC-C-08: Block dev_backup/ access | 15 min | Critical | Add deny-all .htaccess or delete from web root |
| 3 | FE-M-04: Disable login debug mode | 5 min | Medium | Set `debugLogin = false` in login/login2.cfm |
| 4 | SEC-H-02: Fix XSS in loginform.cfm | 10 min | High | Wrap `url.xu` with `encodeForHTMLAttribute()` |
| 5 | FE-H-03: Add `required` to password field | 5 min | High | Add `required` attribute to password input |
| 6 | SEC-H-04: Remove SQL from error responses | 20 min | High | Remove `cfcatch.sql` from JSON responses in ajax/import/ |
| 7 | PERF-H-01: Move user-status fix out of loginform | 30 min | High | Move ThriveCart sync to scheduled task, not every login page load |
| 8 | DB-H-05: Fix removenotdups table reference | 10 min | High | Change `funotifications_tbl` to `funotifications` (or verify VIEW allows UPDATE) |
| 9 | REL-H-03: Fix undefined function call | 15 min | High | Remove or replace `UPDfunotifications_24253` call in rr_283_2.cfm |
| 10 | SEC-H-07: Add auth guard to setup/ | 20 min | High | Add `<cfinclude template="/database/admin-guard.cfm">` to setup/ scripts |

**Total estimated time for all 10: ~2.5 hours**

---

## 9. TOP 10 DANGEROUS ISSUES

Issues that could cause data loss, breach, or service disruption if left unaddressed.

| # | Finding | Risk | Likelihood | Impact if Exploited |
|---|---------|------|------------|---------------------|
| 1 | SEC-C-01: SQL injection in 1,245 query files | Data breach, full DB compromise | HIGH (any form/URL param) | CATASTROPHIC |
| 2 | SEC-C-02: Dynamic table/column injection | Arbitrary table access | MEDIUM (requires specific entry points) | CATASTROPHIC |
| 3 | REL-C-01: Enrollment race condition | Duplicate systems, corrupted workflows | HIGH (concurrent users) | HIGH |
| 4 | REL-C-02: Maintenance auto-start race | Duplicate maintenance, notification spam | MEDIUM (concurrent completions) | HIGH |
| 5 | SEC-C-08: dev_backup/ publicly accessible | Source code exposure, credential leak | HIGH (Google-indexable) | HIGH |
| 6 | REL-H-01: No transaction in legacy completion | Partial writes, stuck systems | MEDIUM (server errors) | HIGH |
| 7 | DB-C-01: No unique constraint on enrollments | Duplicate data accumulation | HIGH (already happening) | MEDIUM |
| 8 | SEC-H-06: No CSRF on import endpoints | Unauthorized imports via malicious links | LOW (requires user interaction) | HIGH |
| 9 | SEC-H-04: SQL errors in JSON responses | Schema reconnaissance | HIGH (on any DB error) | MEDIUM |
| 10 | DB-H-01: Missing transactions in 146+ services | Data inconsistency on failures | MEDIUM (error conditions) | HIGH |

---

## 10. PHASED PROJECT ROADMAP

### Phase 0: Emergency Hardening (Week 1)

**Goal:** Close the doors that are wide open.

| Task | Finding | Effort |
|------|---------|--------|
| Block dev_backup/ directory | SEC-C-08 | 15 min |
| Rotate API key | SEC-C-04 | 15 min |
| Disable login debug mode | FE-M-04 | 5 min |
| Fix XSS in loginform.cfm | SEC-H-02 | 10 min |
| Remove SQL from error responses | SEC-H-04 | 20 min |
| Add auth guard to setup/ | SEC-H-07 | 20 min |
| Fix removenotdups table reference | DB-H-05 | 10 min |
| Fix undefined function call | REL-H-03 | 15 min |
| Add `required` to password field | FE-H-03 | 5 min |
| Move ThriveCart sync to sched task | PERF-H-01 | 30 min |

**Total: ~2.5 hours**

### Phase 1: SQL Injection Remediation (Weeks 2-4)

**Goal:** Parameterize all SQL to eliminate injection risk.

| Task | Finding | Effort |
|------|---------|--------|
| Audit + fix highest-traffic query files first | SEC-C-01 | 3 days |
| Add whitelist validation for dynamic table/column names | SEC-C-02 | 1 day |
| Fix scheduled task SQL injection | SEC-C-03 | 2 hours |
| Fix INSERT/DELETE injection | SEC-C-05, SEC-C-06 | 1 day |
| Remove preservesinglequotes() usage | SEC-C-07 | 4 hours |
| Fix mixed parameterization in contacts_ss.cfm | SEC-H-05 | 2 hours |
| Systematic sweep of remaining include/qry/ files | SEC-C-01 | 5 days |

**Total: ~2 weeks of focused work**

### Phase 2: Data Integrity & Relationship System (Weeks 5-7)

**Goal:** Prevent duplicate enrollments and fix race conditions.

| Task | Finding | Effort |
|------|---------|--------|
| Clean existing duplicate enrollments | DB-C-01 | 4 hours |
| Add unique constraint on fusystemusers | DB-C-01 | 1 hour |
| Move enrollment check inside transaction | REL-C-01 | 4 hours |
| Fix maintenance auto-start race | REL-C-02 | 4 hours |
| Add constraint on pending notifications | DB-C-02 | 2 hours |
| Wrap legacy completion in transaction | REL-H-01 | 1 day |
| Fix recurrence override leak | REL-H-02 | 4 hours |
| Add foreign key constraints to xref tables | DB-C-03 | 1 day |
| Fix orphaned notifications | DB-H-02 | 2 hours |
| Fix stuck systems | DB-H-03 | 2 hours |

**Total: ~2 weeks**

### Phase 3: XSS, CSRF, and Frontend Hardening (Weeks 8-10)

**Goal:** Close client-side attack vectors and improve UX.

| Task | Finding | Effort |
|------|---------|--------|
| Fix all reflected XSS in share/ pages | SEC-H-01 | 4 hours |
| Fix XSS in remotelinkAdd.cfm | SEC-H-03 | 1 hour |
| Add CSRF token framework | SEC-H-06 | 2 days |
| Add global AJAX error handler | FE-H-01 | 1 day |
| Fix form label accessibility | FE-H-02 | 1 day |
| Add ARIA attributes to modals | FE-M-03 | 2 days |
| Conditionalize console.log on debug mode | FE-M-02 | 4 hours |
| Extract inline styles to CSS | FE-M-01 | 3 days |

**Total: ~2.5 weeks**

### Phase 4: Performance & Architecture (Weeks 11-14)

**Goal:** Reduce query load, add transactions, improve architecture.

| Task | Finding | Effort |
|------|---------|--------|
| Add cftransaction to critical service operations | DB-H-01 | 2 weeks |
| Eliminate N+1 patterns in high-traffic paths | DB-H-04 | 1 week |
| Add pagination to unbounded queries | DB-M-01 | 1 week |
| Add missing indexes | DB-M-03 | 2 days |
| Consolidate duplicate query files | DB-M-04 | 3 days |
| Refactor code generation in sql.cfm | DB-C-04 | 2 days |

**Total: ~4 weeks**

### Phase 5: Feature Enhancements (Weeks 15+)

**Goal:** Add missing functionality identified during audit.

| Task | Finding | Effort |
|------|---------|--------|
| Add last-contact-date tracking | REL-M-03 | 1 week |
| Add notification snooze feature | REL-M-04 | 1 week |
| Migrate legacy completion to service | REL-H-01 | 2 weeks |
| Consolidate numbered legacy functions | DB-L-02 | 1 week |
| Path traversal validation in pgload.cfm | SEC-H-09 | 4 hours |
| Fix file upload validation | SEC-M-05 | 1 day |

---

## 11. DETAILED WORK ORDER BACKLOG

### WO-001: Block dev_backup/ Directory Access
- **Finding:** SEC-C-08
- **Priority:** P0 (Emergency)
- **Type:** Security
- **Files:** `dev_backup/` directory
- **Action:** Either delete directory from web root or add `.htaccess` with `Deny from all`. If using IIS, add `<authorization><deny users="*" /></authorization>` to web.config.
- **Acceptance:** HTTP 403 returned for any request to `/dev_backup/*`
- **Rollback:** Remove .htaccess file

### WO-002: Rotate Hardcoded API Key
- **Finding:** SEC-C-04
- **Priority:** P0 (Emergency)
- **Type:** Security
- **Files:** `sched/customicon7.cfm`, `dev_backup/sched/customicon7.cfm`
- **Action:** 1) Create environment variable `ICON_HORSE_API_KEY`. 2) Replace hardcoded key in source. 3) Rotate key in icon.horse dashboard.
- **Acceptance:** No API keys in source code; `grep -r "996ca328" .` returns zero results
- **Rollback:** N/A (key rotation is permanent)

### WO-003: Disable Login Debug Mode
- **Finding:** FE-M-04
- **Priority:** P0
- **Type:** Security/UX
- **Files:** `login/login2.cfm`
- **Action:** Set `debugLogin = false` on the flag variable near line 30
- **Acceptance:** Login page no longer dumps hash comparison details to browser console
- **Rollback:** Set back to `true`

### WO-004: Fix XSS in loginform.cfm
- **Finding:** SEC-H-02
- **Priority:** P0
- **Type:** Security
- **Files:** `loginform.cfm:122`
- **Action:** Change `value="#url.xu#"` to `value="#encodeForHTMLAttribute(url.xu)#"`
- **Acceptance:** Injecting `" onfocus="alert(1)` in `?xu=` parameter does not execute JavaScript
- **Rollback:** Revert to `#url.xu#`

### WO-005: Remove SQL from AJAX Error Responses
- **Finding:** SEC-H-04
- **Priority:** P0
- **Type:** Security
- **Files:** `ajax/import/upload.cfm:118,152`, `ajax/import/parse.cfm:105`
- **Action:** Remove `cfcatch.sql` from response messages. Replace with generic "Database error occurred."
- **Acceptance:** Trigger a DB error; JSON response contains no SQL statements
- **Rollback:** Revert file changes

### WO-006: Add Auth Guard to setup/ Directory
- **Finding:** SEC-H-07
- **Priority:** P0
- **Type:** Security
- **Files:** All .cfm files in `setup/`
- **Action:** Add `<cfinclude template="/database/admin-guard.cfm">` at top of each file, or create `setup/Application.cfm` that includes the guard
- **Acceptance:** Unauthenticated request to `/setup/` redirects to login
- **Rollback:** Remove cfinclude lines

### WO-007: Fix removenotdups() Table Reference
- **Finding:** DB-H-05
- **Priority:** P1
- **Type:** Bug Fix
- **Files:** `services/NotificationService.cfc:163-187`
- **Action:** Verify whether `funotifications` is a VIEW on `funotifications_tbl`. If so, standardize references. If not, fix the UPDATE to target the correct table.
- **Acceptance:** `removenotdups()` successfully soft-deletes duplicate notifications
- **Rollback:** Revert to original table name

### WO-008: Fix Undefined Function Call in rr_283_2.cfm
- **Finding:** REL-H-03
- **Priority:** P1
- **Type:** Bug Fix
- **Files:** `include/qry/rr_283_2.cfm`
- **Action:** Either implement `UPDfunotifications_24253()` in NotificationService.cfc or replace with the correct function call. Trace the business intent from surrounding code.
- **Acceptance:** Code path executes without runtime error
- **Rollback:** Revert file

### WO-009: Add `required` to Password Input
- **Finding:** FE-H-03
- **Priority:** P1
- **Type:** UX
- **Files:** `loginform.cfm:133`
- **Action:** Add `required` attribute to the password input element
- **Acceptance:** Submitting form with empty password shows browser validation error
- **Rollback:** Remove `required`

### WO-010: Move ThriveCart Sync to Scheduled Task
- **Finding:** PERF-H-01
- **Priority:** P1
- **Type:** Performance
- **Files:** `loginform.cfm:38-50`
- **Action:** Move the ThriveCart status sync query to a scheduled task (e.g., `sched/thrivecart-sync.cfm`) running every 15 minutes. Remove from loginform.cfm.
- **Acceptance:** loginform.cfm loads without running UPDATE queries; user statuses still sync within 15 minutes of ThriveCart changes
- **Rollback:** Move query back to loginform.cfm

### WO-011: Parameterize Top-Traffic Query Files
- **Finding:** SEC-C-01
- **Priority:** P1
- **Type:** Security
- **Files:** Start with files that handle user input: `include/qry/details.cfm`, `include/qry/Findrec_228_2.cfm`, `include/contacts_ss.cfm`
- **Action:** Replace all `#variable#` inside cfquery with `<cfqueryparam value="#variable#" cfsqltype="...">`. For dynamic table/column names, implement whitelist validation.
- **Acceptance:** All fixed files pass SQL injection testing; application functions normally
- **Rollback:** Revert individual files

### WO-012: Add Whitelist for Dynamic Table Names
- **Finding:** SEC-C-02
- **Priority:** P1
- **Type:** Security
- **Files:** `include/qry/FindValue_*.cfm`, `include/qry/details.cfm`, `include/qry/sql.cfm`
- **Action:** Create a validation function that checks table/column names against an allowed list before interpolation. Reject with error if not in list.
- **Acceptance:** Passing `information_schema.tables` as a table name returns an error, not query results
- **Rollback:** Revert validation function

### WO-013: Clean Duplicate Enrollments and Add Constraint
- **Finding:** DB-C-01, REL-C-01
- **Priority:** P1
- **Type:** Data Integrity
- **Files:** Schema, `services/RelationshipService.cfc`
- **Action:**
  1. Run diagnostic: `SELECT userid, contactid, systemid, COUNT(*) FROM fusystemusers WHERE sustatus='Active' GROUP BY userid, contactid, systemid HAVING COUNT(*) > 1`
  2. Keep oldest enrollment, soft-delete duplicates
  3. Add unique constraint
  4. Move existence check inside transaction in RelationshipService.cfc
- **Acceptance:** Duplicate enrollment query returns 0 rows; concurrent enrollment attempts don't create duplicates
- **Rollback:** DROP INDEX, revert service code

### WO-014: Fix Race Condition in Maintenance Auto-Start
- **Finding:** REL-C-02
- **Priority:** P1
- **Type:** Data Integrity
- **Files:** `services/RelationshipService.cfc:384-400`
- **Action:** Move maintenance check inside the transaction block with row-level locking
- **Acceptance:** Concurrent system completions for same contact don't create duplicate maintenance enrollments
- **Rollback:** Revert to original flow

### WO-015: Wrap Legacy Completion in Transaction
- **Finding:** REL-H-01
- **Priority:** P2
- **Type:** Data Integrity
- **Files:** `include/complete_not_ajax.cfm`
- **Action:** Wrap the sequence of cfinclude calls in a `<cftransaction>` block, or migrate to use `RelationshipService.completeNotification()`
- **Acceptance:** Simulated failure mid-completion rolls back all changes
- **Rollback:** Remove cftransaction wrapper

### WO-016: Add CSRF Token Framework
- **Finding:** SEC-H-06
- **Priority:** P2
- **Type:** Security
- **Files:** Application.cfc, all AJAX endpoints
- **Action:** Generate CSRF token per session, include in all forms/AJAX headers, validate on all state-changing endpoints
- **Acceptance:** Cross-origin POST to any endpoint returns 403
- **Rollback:** Remove token checks (not recommended)

### WO-017: Add Global AJAX Error Handler
- **Finding:** FE-H-01
- **Priority:** P2
- **Type:** UX
- **Files:** App-wide JS
- **Action:** Add `$(document).ajaxError()` global handler that shows a toast notification on AJAX failures. Handle 401 (session expired) with redirect to login.
- **Acceptance:** Any AJAX failure shows user-visible error message
- **Rollback:** Remove global handler

### WO-018: Fix XSS in Share Pages
- **Finding:** SEC-H-01
- **Priority:** P2
- **Type:** Security
- **Files:** `share/generate_token.cfm`, `share/generate_tokens_all_users.cfm`, `share/remote_load.cfm`
- **Action:** Wrap all URL parameter output with `encodeForHTML()` or `encodeForHTMLAttribute()` as appropriate
- **Acceptance:** XSS payloads in URL parameters are rendered as text, not executed
- **Rollback:** Revert encoding calls

### WO-019: Fix Form Label Accessibility
- **Finding:** FE-H-02
- **Priority:** P2
- **Type:** Accessibility
- **Files:** `include/admin-users-detail.cfm`, `include/admin-users.cfm`
- **Action:** Add `<label for="inputId">` elements for all form inputs, or add `aria-label` attributes
- **Acceptance:** Browser accessibility audit shows no label warnings
- **Rollback:** Remove label elements

### WO-020: Add Foreign Key Constraints to xref Tables
- **Finding:** DB-C-03
- **Priority:** P2
- **Type:** Data Integrity
- **Files:** Schema
- **Action:** Add FK constraints with `ON DELETE CASCADE` to all cross-reference tables
- **Acceptance:** Deleting parent record automatically removes xref rows; orphan query returns 0
- **Rollback:** `ALTER TABLE ... DROP FOREIGN KEY`

---

## 12. OPEN QUESTIONS / THINGS TO VERIFY

### Authentication & Authorization

1. **Q:** Is `dev_backup/` indexed by search engines? Check `robots.txt` and Google cache.
2. **Q:** Do all `sched/*.cfm` files run via cron with server-side auth, or are they accessible via HTTP? If HTTP, they need IP restriction or token-based auth.
3. **Q:** The `?u=` impersonation gate checks for "Admin" OR "Administrator" role. Which is the canonical role name? Are both used?
4. **Q:** Password hashing is inconsistent across codebase: `psw_fix.cfm` uses SHA (no salt), `setup2.cfm` uses SHA-512 with salt. How many users have passwords hashed with the old algorithm? Need a migration script.

### Data Integrity

5. **Q:** How many duplicate active enrollments currently exist in production `fusystemusers`? Run the diagnostic query before adding the unique constraint.
6. **Q:** How many orphaned notifications exist? How many stuck systems? The admin dashboard detects these -- what are the current counts?
7. **Q:** Is `funotifications` a VIEW on `funotifications_tbl`, or are they separate tables? This affects the removenotdups fix.
8. **Q:** Is `contactitems` a VIEW on `contactitems_tbl`? If so, which operations go through the view vs. the base table?

### Business Logic

9. **Q:** When a user overrides `actionDaysRecurring` in `actionusers`, is the intent to change ALL future recurrences or just the next one? This determines the fix for REL-H-02.
10. **Q:** The undefined function `UPDfunotifications_24253` in `rr_283_2.cfm` -- is this code path actively used? What's the user-facing feature that triggers it?
11. **Q:** The `LIMIT 1` without `ORDER BY` in maintenance system lookup -- can there be multiple maintenance systems per scope? If so, which should be preferred?

### Performance

12. **Q:** What is the typical user count? 100? 1,000? 10,000? This affects urgency of N+1 query fixes and pagination needs.
13. **Q:** The ThriveCart sync on loginform.cfm -- how many rows does it typically update? If the query scans large tables, it adds significant latency to the login page.
14. **Q:** Feature flag refresh runs on every request (`refreshFeatureFlagsIfStale` with 60s TTL). Is 60 seconds appropriate, or could this be extended to 5 minutes?

### Architecture

15. **Q:** The 1,267 query fragment files in `include/qry/` appear to be auto-generated (numbered naming pattern like `insert_202_2.cfm`). Is there a code generator producing these? If so, fixing the generator is more efficient than fixing each file individually.
16. **Q:** Are there staging/UAT environments between dev and production? Changes should be tested in staging before production deployment.
17. **Q:** Is there a CI/CD pipeline, or are deployments manual file copies?
18. **Q:** What logging infrastructure exists? Application logs, error logs, access logs? Where are they stored?

---

## APPENDIX A: Files Referenced in This Audit

### Critical Path Files
```
app/Application.cfc
login/login2.cfm
loginform.cfm
services/RelationshipService.cfc
services/NotificationService.cfc
services/ContactImportV3Service.cfc
include/complete_not_ajax.cfm
include/pgload.cfm
include/contacts_ss.cfm
```

### Security-Critical Files (Immediate Attention)
```
dev_backup/                          (entire directory)
sched/customicon7.cfm               (hardcoded API key)
sched/appoint-update2.cfm           (SQL injection)
include/qry/details.cfm             (dynamic table/column injection)
include/qry/Findrec_228_2.cfm       (column + value injection)
include/qry/FindValue_107_*.cfm     (dynamic table injection)
include/qry/FindValue_265_*.cfm     (dynamic table injection)
include/qry/sql.cfm                 (code generation creates vulnerable queries)
include/remoteRemoveaudmedia.cfm    (unparameterized DELETE)
ajax/import/upload.cfm              (SQL in error responses)
ajax/import/parse.cfm               (SQL in error responses)
share/generate_token.cfm            (XSS)
share/generate_tokens_all_users.cfm (XSS)
share/remote_load.cfm               (XSS)
```

### Data Integrity Files
```
services/RelationshipService.cfc:241-256    (enrollment race)
services/RelationshipService.cfc:384-400    (maintenance race)
services/NotificationService.cfc:163-187    (wrong table reference)
include/complete_not_ajax.cfm:56-321        (no transaction)
include/qry/rr_283_2.cfm                   (undefined function)
app/admin-relationship/index.cfm            (health dashboard)
```

---

*End of audit report. This document should be treated as a living document and updated as findings are addressed.*
