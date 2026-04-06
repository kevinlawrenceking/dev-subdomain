# TAO Hardening & Modernization Project Plan

**Created:** 2026-03-15
**Source:** Full-site audit (TAO-FULL-SITE-AUDIT-2026-03-15.md) + owner directives
**Methodology:** Fix what's dangerous first, then stabilize, then clean up

---

## Owner Directives (incorporated throughout)

| # | Directive | Impact |
|---|-----------|--------|
| 1 | Remove `dev_backup/` entirely | Phase 0 |
| 2 | `sched/` is a mix of scheduled tasks and one-off utilities — classify and restrict | Phase 1 + Phase 5 |
| 3 | Remove `?u=` impersonation entirely — no preservation, no admin gate cleanup | Phase 0 |
| 4 | Pick one password hashing standard, migrate legacy hashes | Phase 2 |
| 5 | No duplicate active enrollments in `fusystemusers` | Phase 3 |
| 6 | Unknown orphan notification / stuck system counts — discover first | Phase 3 |
| 7 | `_tbl` is always the base table; non-`_tbl` is the view | Phase 2 |
| 8 | Use view for active records, base table only when deleted records needed; `isdeleted` filtered by view, not exposed as field | Phase 2 |
| 9 | `actionDaysRecurring` applies to ALL future recurrences, not just next | Phase 3 |
| 10 | Unknown if `UPDfunotifications_24253` is on an active code path — investigate | Phase 3 |
| 11 | Unknown if multiple maintenance systems can exist per scope — investigate | Phase 3 |
| 12 | Query fragment files have bad naming; identify unused and remove | Phase 5 |

---

## Phase Overview

| Phase | Name | Duration | Focus |
|-------|------|----------|-------|
| 0 | Emergency Triage | 1 day | Remove dangerous artifacts, kill backdoors |
| 1 | Security Hardening | 1 week | SQL injection, LFI, XSS, auth gaps, sched/ restriction |
| 2 | Data Integrity | 1 week | Password standardization, _tbl/view enforcement, isdeleted consistency |
| 3 | Relationship System Stabilization | 1–2 weeks | Race conditions, duplicates, recurrence, orphan cleanup |
| 4 | Query & Performance | 1–2 weeks | N+1 fixes, datasource consolidation, parameterization |
| 5 | Code Cleanup | 1 week | Dead query fragments, sched/ classification, dead service code |
| 6 | Frontend & UX | 1 week | AJAX error handling, accessibility, debug removal |

**Total estimated duration:** 6–8 weeks sequential, 4–5 weeks with parallelism between phases 4/5/6.

---

## Phase 0 — Emergency Triage (1 day)

Goal: Remove the highest-risk artifacts that require zero investigation.

### WO-0.1: Remove `dev_backup/` directory

**Directive:** #1

- Delete the entire `dev_backup/` directory (158 files, 16 MB)
- No active code references it (only the audit report mentions it)
- Contains obsolete copies of `sched/`, `share/`, `setup/` files from Feb 2026
- Some copies contain legacy password handling (`psw_fix.cfm` using unsalted SHA)

**Files:** `dev_backup/**`
**Risk:** None — no code references this directory
**Verification:** `grep -r "dev_backup" --include="*.cfm" --include="*.cfc"` returns zero results (excluding docs)
**Rollback:** Git history preserves all content

---

### WO-0.2: Remove `?u=` impersonation parameter entirely

**Directive:** #3

The `?u=` parameter was a personal backdoor. Remove it completely — do not preserve or gate it.

**Changes required:**

| File | Change |
|------|--------|
| `app/Application.cfc` (lines 241–297) | Delete the entire `?u=` handler block. Keep the post-login session setup block (lines ~299–341) which runs for any authenticated request |
| `login/login2.cfm` (line 386) | Change `<cflocation url="#loginQuery.status_url#?u=#loginquery.userid#" addtoken="true">` → `<cflocation url="#loginQuery.status_url#" addtoken="true">` |
| `login/login2.cfm` (lines 299, 301) | Remove `?u=` from debug verdict display |
| `loginform.cfm` (line 55) | Remove `<cfparam name="url.u" default="">` |
| `loginform.cfm` (lines 121–123) | Remove any `?u=` form field or hidden input |
| `app/Application.cfc` (line 215) | Remove `"u"` from the URL parameter keys array |

**Decision: `share.cfm` (lines 31–32)** uses `?u=#left(passwordhash,10)#` for public sharing links. This is a *different* use case (public token, not impersonation). Two options:
- **(A)** Rename parameter to `?share=` or `?token=` to avoid confusion — recommended
- **(B)** Leave as-is since share.cfm has its own handler separate from Application.cfc

**Session setup impact:** The post-login block in Application.cfc already handles session initialization for any request where `session.userid` exists. Login sets `session.userid` before redirecting. The redirect works via `addtoken="true"` preserving the session. No session variables are lost.

**Verification:**
1. Log in → lands on correct status_url page
2. Session variables populated (check `session.userid`, `session.userMediaPath`, etc.)
3. `?u=123` in URL bar does nothing (parameter ignored)
4. Share links still work (if using option A, verify new parameter name)

---

### WO-0.3: Turn off login debug mode

**Context:** `debugLogin = true` was set in `login/login2.cfm` during the login investigation. Must be turned off before any user encounters it.

**File:** `login/login2.cfm` (line ~30)
**Change:** `<cfset debugLogin = true>` → `<cfset debugLogin = false>`
**Verification:** Login page no longer dumps diagnostic output to browser

---

### WO-0.4: Fix GETDATE() → NOW()

**Audit finding:** MSSQL syntax in a MySQL codebase.

**File:** `include/update_reminder_status.cfm` (line 17)
**Change:** `last_updated = GETDATE()` → `last_updated = NOW()`
**Also fix:** Hardcoded datasource `"abod"` → `application.dsn` (or `application.datasource`)
**Verification:** Run the reminder status update and confirm `last_updated` column populates

---

## Phase 1 — Security Hardening (1 week)

Goal: Close all remotely exploitable vulnerabilities.

### WO-1.1: Fix SQL injection in query fragments (CRITICAL — 6 confirmed vectors)

**Audit finding:** SEC-C-01 through SEC-C-06

At least 6 query fragment files have confirmed SQL injection via unparameterized `#url.*#` or `#form.*#` variables in WHERE clauses. These are the most dangerous because they accept user input directly from URL or form scope.

**Approach:**
1. Search all files in `include/qry/` for `#url.` and `#form.` inside `<cfquery>` blocks
2. For each match, wrap in `<cfqueryparam value="#url.xxx#" cfsqltype="cf_sql_xxx">`
3. Determine correct `cfsqltype` from context (integer IDs → `cf_sql_integer`, strings → `cf_sql_varchar`, dates → `cf_sql_date`)

**Priority files** (confirmed injection vectors from audit):
- Files with `#url.contactid#`, `#url.userid#`, `#url.eventid#` in WHERE clauses
- Files with `#form.` variables in INSERT/UPDATE statements
- Any file accepting `#url.` in ORDER BY or LIMIT (second-order injection)

**Scope note:** The audit says 98% of the 1,267 query fragments use unparameterized variables, but many of those variables come from `session` or `variables` scope (server-controlled, not user input). Focus on `url.*` and `form.*` first. Session/variables scope is lower priority (Phase 4).

**Verification:**
- `grep -r "#url\." include/qry/ --include="*.cfm" | grep -i "cfquery"` returns zero unparameterized instances
- `grep -r "#form\." include/qry/ --include="*.cfm" | grep -i "cfquery"` returns zero unparameterized instances

---

### WO-1.2: Fix Local File Inclusion (LFI) vectors (CRITICAL — 3 confirmed)

**Audit finding:** SEC-C-07 through SEC-C-09

Files that use unvalidated user input in `<cfinclude template="#...#">` paths.

**Approach:**
1. Identify all dynamic `cfinclude` where the path contains `#url.` or `#form.`
2. Whitelist allowed template names — reject any value not in the whitelist
3. Strip path separators (`/`, `\`, `..`) from input before inclusion

**Verification:** Attempt path traversal (`?page=../../etc/passwd`) — returns error page, not file contents

---

### WO-1.3: Add authentication to `/setup/` directory

**Audit finding:** SEC-H-01

The `/setup/` directory contains user provisioning scripts accessible without authentication.

**Approach:**
- Add `<cfinclude template="/database/admin-guard.cfm">` to all `.cfm` files in `/setup/`
- Or create a `/setup/Application.cfc` that enforces auth at the directory level

**Verification:** Unauthenticated request to `/setup/` returns 403 or redirects to login

---

### WO-1.4: Fix unvalidated file uploads (3 endpoints)

**Audit finding:** SEC-H-02

File upload endpoints that don't validate file type, size, or content.

**Approach:**
1. Identify all `<cffile action="upload">` calls
2. Add `accept` attribute to restrict MIME types
3. Validate file extension against whitelist
4. Enforce maximum file size
5. Store uploads outside webroot or with randomized names

**Verification:** Upload a `.cfm` file — rejected. Upload a `.php` file — rejected. Upload a valid image — accepted.

---

### WO-1.5: Fix XSS vectors (11+ confirmed)

**Audit finding:** SEC-H-03

Output of user-controlled values without `encodeForHTML()` or `htmlEditFormat()`.

**Approach:**
1. Search for `#url.` and `#form.` in HTML output context (outside `<cfquery>`)
2. Wrap in `encodeForHTML()`: `#encodeForHTML(url.searchterm)#`
3. For JavaScript context, use `encodeForJavaScript()`
4. For URL context, use `encodeForURL()`

**Verification:** Inject `<script>alert(1)</script>` in URL params — rendered as text, not executed

---

### WO-1.6: Add CSRF tokens to state-changing endpoints

**Audit finding:** SEC-M-01

Import finalize and other state-changing AJAX endpoints lack CSRF protection.

**Approach:**
1. Generate CSRF token in session: `session.csrfToken = generateSecretKey("AES")`
2. Include token in AJAX requests as header or form field
3. Validate token server-side before processing

**Priority endpoints:**
- `ajax/importv3/finalize.cfm`
- `ajax/import/finalize.cfm`
- Any endpoint that deletes, updates, or creates records

---

### WO-1.7: Restrict `sched/` directory HTTP access

**Directive:** #2

The `sched/` folder has 124 files. About 45 are scheduled tasks (cron targets), ~79 are one-off utilities/reports. All are HTTP-accessible.

**Approach:**
1. Create `sched/Application.cfc` with IP whitelist or admin-only auth gate
2. Scheduled tasks should only be callable from localhost or ColdFusion scheduler
3. One-off utilities should require admin authentication

**Implementation:**
```cfml
<!--- sched/Application.cfc --->
<cfcomponent>
  <cffunction name="onRequestStart">
    <cfif CGI.REMOTE_ADDR NEQ "127.0.0.1" AND CGI.REMOTE_ADDR NEQ "::1">
      <cfif NOT structKeyExists(session, "userid")>
        <cfheader statuscode="403">
        <cfabort>
      </cfif>
      <!--- Optionally: also check userRole = Admin --->
    </cfif>
  </cffunction>
</cfcomponent>
```

**Verification:** External request to `sched/actionusers_fix.cfm` returns 403

---

### WO-1.8: Fix path traversal in attachment deletion

**Audit finding:** SEC-H-04

Attachment deletion endpoint accepts a file path without validating it stays within the user's directory.

**Approach:**
1. Resolve the full canonical path
2. Verify it starts with the user's media directory (`session.userMediaPath`)
3. Reject any path containing `..`

---

## Phase 2 — Data Integrity (1 week)

Goal: Standardize data access patterns and ensure writes go to the right tables.

### WO-2.1: Standardize password hashing

**Directive:** #4

**Current state:** All active code paths already use SHA-512 with per-user salt. The standard is:
```
salt = Hash(generateSecretKey("AES"), "SHA-512")
hash = Hash(password & salt, "SHA-512")
```

**Locations (all already consistent):**
| File | Operation | Algorithm |
|------|-----------|-----------|
| `login/login2.cfm:70,379` | Login verification | SHA-512 + salt |
| `recover/setup2.cfm:14-21` | Password reset | SHA-512 + salt |
| `services/UserService.cfc:907-908` | User creation | SHA-512 + salt |
| `services/UserService.cfc:1025-1026` | Admin password change | SHA-512 + salt |

**Legacy concern:** The old migration script `sched/psw_fix.cfm` used unsalted SHA. Any user whose password was set by that script and never reset will have a hash that doesn't match SHA-512+salt. These users cannot log in.

**Actions:**
1. **Discovery query:** Count users with `passwordSalt IS NULL OR passwordSalt = ''` — these are legacy-hashed users
2. **Force password reset:** For any user with empty/null salt:
   - Set `recover = CreateUUID()`
   - Send password reset email
   - Log the action
3. **Remove `app/login2.cfm`** — this is the OLD login handler (not the active one at `login/login2.cfm`). It contains stale password comparison code with a stray `--->` and `<cfabort>` on line 39.
4. **Remove `sched/psw_fix.cfm`** — legacy migration script, no longer needed
5. **Drop `userPassword` column** (plaintext legacy column) — already cleared on reset, never read by active code. Or: set all remaining non-empty values to empty string first, drop column in next release.

**Verification:**
```sql
-- Zero users should have empty/null salt after migration
SELECT COUNT(*) FROM taousers WHERE passwordSalt IS NULL OR passwordSalt = '';

-- Zero users should have non-empty plaintext password
SELECT COUNT(*) FROM taousers WHERE userPassword IS NOT NULL AND userPassword != '';
```

---

### WO-2.2: Fix writes targeting view names instead of `_tbl` base tables

**Directives:** #7, #8

**Confirmed violations (code writes to view name instead of base table):**

| File | Line | Problem | Fix |
|------|------|---------|-----|
| `services/ContactItemService.cfc` | 39 | `INSERT INTO contactitems` | → `INSERT INTO contactitems_tbl` |
| `services/ContactService.cfc` | 57 | `INSERT INTO contactdetails` | → `INSERT INTO contactdetails_tbl` |
| `services/ContactService.cfc` | 125 | `UPDATE contactdetails` | → `UPDATE contactdetails_tbl` |
| `sql/import_v3_query_tests.sql` | 806+ | Multiple `INSERT INTO contactitems` | → `contactitems_tbl` |
| `sql/import_v3_query_audit.sql` | 394+ | Multiple `INSERT INTO contactitems` | → `contactitems_tbl` |

**Additional search required:** Scan all `.cfm` and `.cfc` files for `INSERT INTO contactitems` or `UPDATE contactitems` or `DELETE FROM contactitems` (without `_tbl`) and fix each one. Same for `contactdetails`, `actionusers`, `events`, and any other table that has a `_tbl` variant.

**Systematic check:**
```bash
# Find all _tbl tables referenced in code
grep -roh "[a-zA-Z_]*_tbl" --include="*.cfm" --include="*.cfc" | sort -u

# For each base table, check if writes go to the view name instead
# Example for contactitems:
grep -rn "INSERT INTO contactitems[^_]" --include="*.cfm" --include="*.cfc"
grep -rn "UPDATE contactitems[^_]" --include="*.cfm" --include="*.cfc"
grep -rn "DELETE FROM contactitems[^_]" --include="*.cfm" --include="*.cfc"
```

**Verification:** Zero DML statements target view names for tables that have `_tbl` base tables

---

### WO-2.3: Standardize `isdeleted` filtering

**Directive:** #8

**Problem:** Code uses 4 different patterns inconsistently:
- `WHERE isdeleted = 0` (most common)
- `WHERE isdeleted <> 1`
- `WHERE isdeleted IS FALSE`
- Mixed case: `isDeleted` vs `isdeleted` in same query

**Standard to adopt:** `WHERE isdeleted = 0` (most common, clearest intent)

**Actions:**
1. Audit all `isdeleted` references: `grep -rn "isdeleted" --include="*.cfm" --include="*.cfc" -i`
2. Normalize to lowercase `isdeleted`
3. Normalize comparison to `= 0` (active) or `= 1` (deleted)
4. For views: verify that each view's WHERE clause includes `isdeleted = 0` so callers don't need to add it
5. For code reading from views: remove redundant `isdeleted = 0` filters (the view handles it)
6. For code needing deleted records: switch to `_tbl` base table with explicit `isdeleted` filter

**Verification:**
```bash
# Should return zero results for non-standard patterns:
grep -rn "isDeleted" --include="*.cfm" --include="*.cfc"  # wrong case
grep -rn "isdeleted <> 1" --include="*.cfm" --include="*.cfc"  # non-standard
grep -rn "isdeleted IS FALSE" --include="*.cfm" --include="*.cfc"  # non-standard
```

---

### WO-2.4: Consolidate datasource references

**Audit finding:** 90+ files use hardcoded datasource names (`"abo"`, `"abod"`, `"abodName"`) instead of `application.datasource` or `application.dsn`.

**Actions:**
1. Replace all `datasource="abo"` with `datasource="#application.dsn#"`
2. Replace all `datasource="abod"` with `datasource="#application.dsn#"`
3. Replace all `datasource="abodName"` with `datasource="#application.dsn#"`
4. Concentrate on `sched/` folder first (30+ files), then `include/` files

**Verification:**
```bash
grep -rn 'datasource="abo"' --include="*.cfm" --include="*.cfc"
grep -rn 'datasource="abod"' --include="*.cfm" --include="*.cfc"
# Both should return zero
```

---

## Phase 3 — Relationship System Stabilization (1–2 weeks)

Goal: Fix race conditions, prevent duplicate enrollments, clean orphans, and correct recurrence logic.

### WO-3.1: Prevent duplicate active enrollments in `fusystemusers`

**Directive:** #5

**Current state:** 6 different INSERT code paths, only 2 check for existing enrollment, and those checks are outside the transaction (race condition).

**Fix — two layers:**

**Layer 1: Database constraint**
```sql
-- Step 1: Clean existing duplicates (keep newest suid per group)
UPDATE fusystemusers su1
SET sustatus = 'Completed',
    sunotes = CONCAT(COALESCE(sunotes, ''), ' [auto-deduped]')
WHERE sustatus = 'Active'
  AND isdeleted = 0
  AND EXISTS (
    SELECT 1 FROM (
      SELECT userid, contactid, systemid, MAX(suid) AS keep_suid
      FROM fusystemusers
      WHERE sustatus = 'Active' AND isdeleted = 0
      GROUP BY userid, contactid, systemid
      HAVING COUNT(*) > 1
    ) dups
    WHERE dups.userid = su1.userid
      AND dups.contactid = su1.contactid
      AND dups.systemid = su1.systemid
      AND su1.suid < dups.keep_suid
  );

-- Step 2: Add unique index (partial — only active, non-deleted)
-- MySQL doesn't support filtered unique indexes directly.
-- Option A: Add a generated column + unique index
ALTER TABLE fusystemusers
  ADD COLUMN active_key VARCHAR(100) GENERATED ALWAYS AS (
    CASE WHEN sustatus = 'Active' AND isdeleted = 0
         THEN CONCAT(userid, '-', contactid, '-', systemid)
         ELSE NULL END
  ) STORED,
  ADD UNIQUE INDEX uq_active_enrollment (active_key);
-- NULL values are excluded from unique checks in MySQL, so completed/deleted rows won't conflict.

-- ROLLBACK:
-- ALTER TABLE fusystemusers DROP INDEX uq_active_enrollment, DROP COLUMN active_key;
```

**Layer 2: Application code — move check inside transaction**

In `services/RelationshipService.cfc`, function `startSystemForContact()`:
```cfml
<!--- Move duplicate check INSIDE the transaction with FOR UPDATE lock --->
<cftransaction>
  <cfquery name="checkExisting">
    SELECT suid FROM fusystemusers
    WHERE contactid = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
      AND systemid = <cfqueryparam value="#arguments.systemid#" cfsqltype="CF_SQL_INTEGER">
      AND userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
      AND sustatus = 'Active'
      AND isdeleted = 0
    FOR UPDATE
  </cfquery>

  <cfif checkExisting.recordCount GT 0>
    <cfset result.message = "Contact already enrolled in this system" />
    <cfset result.data.suid = checkExisting.suid />
    <cfreturn result />
  </cfif>

  <cfquery name="insertSystem" result="insertResult">
    INSERT INTO fusystemusers (systemid, contactid, userid, sustartdate, sustatus, sunotes)
    VALUES (...)
  </cfquery>
  <!--- ... create first notification ... --->
</cftransaction>
```

Apply the same pattern to:
- `ContactImportV2Service.cfc` — `enrollContactInSystem()`
- `RelationshipService.cfc` — `startMaintenanceIfNeeded()`

**Layer 3: Consolidate INSERT paths**

Route all enrollment through `RelationshipService.startSystemForContact()`:
- `SystemUserService.cfc` functions (`addfuSystemUsers`, `INSfusystemusers_batch`, `INSfusystemusers_23934`, `INSfusystemusers_24427`) — deprecate, redirect to RelationshipService
- `include/qry/addSystem*.cfm` variants — update to call RelationshipService
- `sched/events_completed.cfm` — update to call RelationshipService

**Verification:**
```sql
-- Should return zero after cleanup:
SELECT userid, contactid, systemid, COUNT(*) AS cnt
FROM fusystemusers
WHERE sustatus = 'Active' AND isdeleted = 0
GROUP BY userid, contactid, systemid
HAVING COUNT(*) > 1;
```

---

### WO-3.2: Discovery — orphaned notifications and stuck systems

**Directive:** #6

Run these diagnostic queries to establish baseline counts:

```sql
-- Orphaned notifications (notification exists but parent suid is completed/deleted/missing)
SELECT COUNT(*) AS orphaned_notifications
FROM funotifications n
LEFT JOIN fusystemusers su ON su.suid = n.suid
WHERE n.notstatus = 'Pending'
  AND n.isdeleted = 0
  AND (su.suid IS NULL OR su.sustatus = 'Completed' OR su.isdeleted = 1);

-- Stuck systems (active enrollment with zero pending notifications)
SELECT COUNT(*) AS stuck_systems
FROM fusystemusers su
WHERE su.sustatus = 'Active'
  AND su.isdeleted = 0
  AND NOT EXISTS (
    SELECT 1 FROM funotifications n
    WHERE n.suid = su.suid
      AND n.notstatus IN ('Pending', 'Future')
      AND n.isdeleted = 0
  );

-- Multiple pending notifications per suid (should be at most 1 with notstartdate set)
SELECT n.suid, COUNT(*) AS pending_count
FROM funotifications n
WHERE n.notstatus = 'Pending'
  AND n.notstartdate IS NOT NULL
  AND n.isdeleted = 0
GROUP BY n.suid
HAVING COUNT(*) > 1;
```

**Action after discovery:**
- If orphaned count > 0: soft-delete orphaned notifications
- If stuck count > 0: either complete the system or create the next notification
- If multiple-pending count > 0: keep the earliest, mark others as 'Skipped'

Document the counts and cleanup actions for the team.

---

### WO-3.3: Fix `actionDaysRecurring` to apply to all future recurrences

**Directive:** #9

**Current behavior (needs verification):** When a recurring notification is completed, the next notification is created using `actionDaysRecurring` from `actionusers`. The question is whether this interval applies only once or to every subsequent recurrence.

**Expected behavior:** The recurrence interval should create the next notification every time, indefinitely, until the system is completed or the contact is unenrolled.

**Investigation steps:**
1. Read `services/RelationshipService.cfc` → `completeNotification()` function
2. Trace what happens when a recurring action's notification is completed
3. Verify the new notification also gets `actionDaysRecurring` so the chain continues
4. Check `include/complete_not.cfm` and `include/complete_not_ajax.cfm` for the same logic

**Fix:** If the recurrence chain breaks after one iteration, ensure the newly created notification inherits the same `actionid` and recurrence settings, so that completing it triggers another creation.

---

### WO-3.4: Investigate `UPDfunotifications_24253`

**Directive:** #10

**Action:** Determine if this query fragment file is still on an active code path.

```bash
# Search for references to this file
grep -r "UPDfunotifications_24253" --include="*.cfm" --include="*.cfc"
```

- If referenced: document where and what it does
- If unreferenced: mark for removal in Phase 5

---

### WO-3.5: Investigate multiple maintenance systems per scope

**Directive:** #11

**Question:** Can a contact have multiple active maintenance systems? If so, which one wins?

**Investigation:**
```sql
-- Check for contacts with multiple active maintenance enrollments
SELECT su.userid, su.contactid, s.systemname, su.suid, su.sustartdate
FROM fusystemusers su
INNER JOIN fusystems s ON s.systemid = su.systemid
WHERE s.systemtype = 'Maintenance List'
  AND su.sustatus = 'Active'
  AND su.isdeleted = 0
ORDER BY su.userid, su.contactid;
```

**Also check `startMaintenanceIfNeeded()`** in RelationshipService.cfc:
- Does it check for ANY existing maintenance system, or only the specific one?
- If a contact completes Follow-Up System A (which triggers Maintenance A) and later completes Follow-Up System B (which triggers Maintenance B), should both maintenance systems be active?

**Decision needed from owner:** Should the rule be "one active maintenance system per contact per user" or "one per follow-up system"?

**Action after decision:**
- Add appropriate uniqueness constraint
- Update `startMaintenanceIfNeeded()` to enforce the rule

---

### WO-3.6: Remove dead code in NotificationService.cfc

**Audit finding:** 782-line file with multiple redundant INSERT/UPDATE function variants.

**Dead functions identified** (not called from any other file):
- (List to be populated by running the dead-code detection query from the audit)

**Approach:**
1. For each function in NotificationService.cfc, search codebase for callers
2. Functions with zero external callers → remove
3. Functions that duplicate logic of another function → consolidate, update callers, remove duplicate

---

## Phase 4 — Query & Performance (1–2 weeks)

Goal: Fix N+1 patterns, parameterize remaining SQL, add bounds to queries.

### WO-4.1: Refactor N+1 queries in scheduled tasks

**Audit finding:** 30+ files with queries inside cfloop

**Priority targets (highest impact):**

| File | Current Pattern | Fix |
|------|----------------|-----|
| `sched/actionusers_fix.cfm` | Triple-nested loop: users → actions → INSERT per missing row | Single `INSERT ... SELECT ... LEFT JOIN` |
| `sched/avatar_loop.cfm` | Loop 1000 contacts, 3 UPDATEs each | `UPDATE ... CASE WHEN` batch pattern |
| `sched/birthday_fix.cfm` | Loop all contacts, UPDATE per row | `UPDATE ... CASE WHEN` batch pattern |
| `sched/import-contacts.cfm` | 11+ INSERT/UPDATE per contact in loop | Wrap in `<cftransaction>`, batch where possible |
| `sched/events_completed.cfm` | Nested loops creating system records | Refactor to use RelationshipService |
| `sched/auddialects_fix.cfm` | Nested user × dialect loop | `INSERT ... SELECT ... LEFT JOIN` |
| `sched/audgenres_fix.cfm` | Same pattern | Same fix |
| `sched/audnetworks_fix.cfm` | Same pattern | Same fix |
| `sched/audplatforms_fix.cfm` | Same pattern | Same fix |
| `sched/audtones_fix.cfm` | Same pattern | Same fix |

**Example refactor for `actionusers_fix.cfm`:**
```sql
-- BEFORE: 3 nested loops = N × M queries
-- AFTER: Single set-based INSERT
INSERT INTO actionusers (actionid, userid, actionDaysNo, actionDaysRecurring)
SELECT f.actionid, u.userid, f.actionDaysNo, f.actionDaysRecurring
FROM fuactions f
CROSS JOIN taousers u
LEFT JOIN actionusers a ON a.actionid = f.actionid AND a.userid = u.userid
WHERE a.actionid IS NULL;
```

---

### WO-4.2: Parameterize remaining raw SQL

**Audit finding:** ~35 files in `sched/` with `#variable#` in cfquery without cfqueryparam

**Priority:** Files where the variable comes from a previous query result (lower injection risk than `url.*`/`form.*`, but still bad practice and breaks with special characters).

**Approach:** For each file, wrap every `#variable#` inside a cfquery with `<cfqueryparam>`:
```cfml
<!-- BEFORE -->
WHERE actionid = #xs.actionid# AND userid = #u.userid#

<!-- AFTER -->
WHERE actionid = <cfqueryparam value="#xs.actionid#" cfsqltype="cf_sql_integer">
  AND userid = <cfqueryparam value="#u.userid#" cfsqltype="cf_sql_integer">
```

---

### WO-4.3: Add LIMIT/MAXROWS to unbounded SELECTs

**Audit finding:** 10+ scheduled task files SELECT without bounds

**Files to fix:**
- `sched/import-contacts.cfm` (line 3) — add `LIMIT 1000` or `maxrows="1000"`
- `sched/birthday_fix.cfm` (line 4) — add reasonable limit
- `sched/psw_fix.cfm` — add limit (or remove file per WO-2.1)
- `sched/hash_loop.cfm` — add limit

---

### WO-4.4: Add missing transactions to multi-table writes

**Critical files needing `<cftransaction>` wrapping:**

| File | Statements | Risk |
|------|-----------|------|
| `sched/import-contacts.cfm` | 11+ INSERT/UPDATE per contact | Partial contact creation on failure |
| `services/ActionUserService.cfc:42-63` | DELETE then INSERT | Gap between delete and insert |

---

## Phase 5 — Code Cleanup (1 week)

Goal: Remove dead code, classify utilities, improve maintainability.

### WO-5.1: Remove unused query fragment files

**Directive:** #12

**Finding:** 278 files in `include/qry/` are not referenced by any other file in the codebase.

**Approach:**
1. Generate list of all `.cfm` files in `include/qry/`
2. For each file, search entire codebase for its filename (excluding itself)
3. Files with zero references → candidate for removal
4. **Before deletion:** Check for dynamic includes — some files may be included via variable: `<cfinclude template="/include/qry/#variable#.cfm">`. Search for dynamic cfinclude patterns and cross-reference.
5. Remove confirmed dead files in a single commit with the full list in the commit message

**Naming convention cleanup:**
- Files with `_NUMBER_NUMBER.cfm` pattern (e.g., `FINDK_159_4.cfm`) were auto-generated by an older IDE
- 991 files follow this pattern; 105 of those are unused
- For the ~886 that ARE used: consider renaming to descriptive names over time (not urgent, high churn)

**Verification:** Application still functions after removal. Run full smoke test of key pages.

---

### WO-5.2: Classify and relocate `sched/` files

**Directive:** #2

**Classification from audit (124 files):**

| Category | Count | Action |
|----------|-------|--------|
| Active scheduled tasks | ~45 | Keep in `sched/`, ensure cron-only access (WO-1.7) |
| One-off utilities/reports | ~79 | Move to `tools/` or `admin-tools/` with admin auth |
| Test/temp files | ~5 | Remove (`temp.cfm`, `temp_chain.cfm`, `test.cfm`) |
| Duplicate/backup files | ~3 | Remove (`user_setup_core copy.cfm`) |

**Scheduled tasks to keep (examples):**
- `actionusers_fix.cfm` — ensures all users have action overrides
- `avatar_loop.cfm` — syncs gravatars
- `birthday_fix.cfm` — validates birthday data
- `events_completed.cfm` — processes completed events
- `import-contacts.cfm` — legacy batch import
- `thrivecart_process.cfm` — payment webhook processing

**One-off utilities to relocate (examples):**
- `column_details.cfm` — DB schema inspector
- `extract*.cfm` (12 files) — code analysis tools
- `find_*.cfm` (8 files) — codebase search utilities
- `insert_*.cfm` — data seeding scripts
- `dir_*.cfm` — directory scanning tools

---

### WO-5.3: Remove dead service functions

**Target:** `services/NotificationService.cfc` (782 lines)

**Approach:**
1. List all `<cffunction>` names in the file
2. For each, search codebase for callers outside NotificationService.cfc
3. Functions with zero callers → remove
4. Functions that duplicate another function's logic → consolidate

**Also audit:**
- `services/SystemUserService.cfc` — legacy enrollment functions (per WO-3.1, route through RelationshipService)

---

### WO-5.4: Remove `app/login2.cfm` (old login handler)

**Context:** `/app/login2.cfm` is NOT the active login handler. The active one is `/login/login2.cfm`. The old file contains:
- Stray `--->` on line 35 (broken comment)
- `here<cfabort>` debug halt on line 39
- Plaintext password logging (patched to `[REDACTED]` in Fix 6B)
- The `loggins` table INSERT that logs login attempts

**Action:** Delete the file entirely. Verify no redirects or includes point to `/app/login2.cfm`.

---

## Phase 6 — Frontend & UX (1 week)

Goal: Fix client-side issues, remove debug artifacts, improve accessibility.

### WO-6.1: Add AJAX error handlers

**Audit finding:** AJAX calls without `.fail()` or `error:` callbacks

**Approach:**
1. Search for `$.ajax`, `$.post`, `$.get` calls
2. For each, add error handler that shows user-friendly message
3. Standard pattern:
```javascript
$.ajax({
  url: '/ajax/endpoint.cfm',
  // ...
  error: function(xhr, status, error) {
    // Show toast or inline error message
    alert('An error occurred. Please try again.');
    console.error('AJAX error:', status, error);
  }
});
```

---

### WO-6.2: Remove debug `console.log` from production

**Audit finding:** Debug console.log statements in production JavaScript

**Approach:**
1. Search all `.js` and `.cfm` files for `console.log`
2. Remove debug-only statements
3. Keep legitimate error logging (`console.error` for actual errors)

---

### WO-6.3: Add `required` attribute to login form password field

**File:** `loginform.cfm`
**Change:** Add `required` attribute to password input
**Also:** Verify username field has `required`

---

### WO-6.4: Fix accessibility issues

**Findings:**
- Label `for` attributes not matching input `id`s (partially fixed in prior session)
- Missing ARIA attributes on dynamic content
- Color contrast issues

**Approach:** Address incrementally as pages are touched in other phases

---

### WO-6.5: Fix mixed HTTP/HTTPS content

**Finding:** Some resources loaded over HTTP instead of HTTPS

**Approach:**
1. Search for `http://` in `.cfm`, `.js`, `.css` files
2. Replace with `https://` or protocol-relative `//`
3. Verify no mixed-content warnings in browser console

---

## Open Questions (require investigation or owner decision)

| # | Question | Phase | Blocking? |
|---|----------|-------|-----------|
| Q1 | How many users have legacy (unsalted SHA) password hashes? | 2 | No — discovery query will answer |
| Q2 | Should `share.cfm`'s `?u=` parameter be renamed to `?token=`? | 0 | No — can ship with or without rename |
| Q3 | One maintenance system per contact, or one per follow-up system? | 3 | Yes — blocks WO-3.5 |
| Q4 | Is `UPDfunotifications_24253` on an active code path? | 3 | No — investigation will answer |
| Q5 | Should the 886 used query fragments with bad names be renamed? | 5 | No — cosmetic, high churn |
| Q6 | What are the actual orphan/stuck counts in production data? | 3 | Yes — blocks cleanup decisions in WO-3.2 |
| Q7 | Are there ColdFusion scheduler entries for `sched/` files? If so, which? | 1 | No — but informs classification |
| Q8 | Should `sched/import-contacts.cfm` (legacy V1 import) be retired in favor of V3? | 5 | No — but simplifies maintenance |

---

## Dependency Graph

```
Phase 0 (Emergency)
  |
  v
Phase 1 (Security)
  |
  +---> Phase 2 (Data Integrity)
  |       |
  |       +---> Phase 3 (Relationship System)
  |
  +---> Phase 4 (Query & Performance)  [can run parallel with Phase 3]
  |
  +---> Phase 5 (Code Cleanup)         [can run parallel with Phase 3/4]
  |
  +---> Phase 6 (Frontend/UX)          [can run parallel with Phase 3/4/5]
```

**Critical path:** Phase 0 → Phase 1 → Phase 2 → Phase 3

**Parallelizable after Phase 1:** Phases 4, 5, 6 have no dependencies on Phase 3 and can run concurrently.

---

## Work Order Index

| WO | Title | Phase | Priority | Directives |
|----|-------|-------|----------|------------|
| WO-0.1 | Remove dev_backup/ | 0 | CRITICAL | #1 |
| WO-0.2 | Remove ?u= impersonation | 0 | CRITICAL | #3 |
| WO-0.3 | Turn off login debug mode | 0 | CRITICAL | — |
| WO-0.4 | Fix GETDATE() → NOW() | 0 | HIGH | — |
| WO-1.1 | Fix SQL injection (6+ vectors) | 1 | CRITICAL | — |
| WO-1.2 | Fix LFI vectors (3) | 1 | CRITICAL | — |
| WO-1.3 | Auth on /setup/ | 1 | HIGH | — |
| WO-1.4 | Fix file upload validation | 1 | HIGH | — |
| WO-1.5 | Fix XSS vectors (11+) | 1 | HIGH | — |
| WO-1.6 | Add CSRF tokens | 1 | MEDIUM | — |
| WO-1.7 | Restrict sched/ HTTP access | 1 | HIGH | #2 |
| WO-1.8 | Fix path traversal in attachments | 1 | HIGH | — |
| WO-2.1 | Standardize password hashing | 2 | HIGH | #4 |
| WO-2.2 | Fix writes to view names | 2 | HIGH | #7, #8 |
| WO-2.3 | Standardize isdeleted filtering | 2 | MEDIUM | #8 |
| WO-2.4 | Consolidate datasource references | 2 | MEDIUM | — |
| WO-3.1 | Prevent duplicate enrollments | 3 | CRITICAL | #5 |
| WO-3.2 | Discover orphans/stuck systems | 3 | HIGH | #6 |
| WO-3.3 | Fix actionDaysRecurring | 3 | HIGH | #9 |
| WO-3.4 | Investigate UPDfunotifications_24253 | 3 | MEDIUM | #10 |
| WO-3.5 | Investigate maintenance scope | 3 | MEDIUM | #11 |
| WO-3.6 | Remove dead NotificationService code | 3 | LOW | — |
| WO-4.1 | Refactor N+1 queries | 4 | HIGH | — |
| WO-4.2 | Parameterize remaining SQL | 4 | MEDIUM | — |
| WO-4.3 | Add LIMIT/MAXROWS | 4 | MEDIUM | — |
| WO-4.4 | Add missing transactions | 4 | HIGH | — |
| WO-5.1 | Remove 278 unused query fragments | 5 | MEDIUM | #12 |
| WO-5.2 | Classify and relocate sched/ files | 5 | MEDIUM | #2 |
| WO-5.3 | Remove dead service functions | 5 | LOW | — |
| WO-5.4 | Remove app/login2.cfm | 5 | LOW | — |
| WO-6.1 | Add AJAX error handlers | 6 | MEDIUM | — |
| WO-6.2 | Remove debug console.log | 6 | MEDIUM | — |
| WO-6.3 | Add required to password field | 6 | LOW | — |
| WO-6.4 | Fix accessibility issues | 6 | LOW | — |
| WO-6.5 | Fix mixed HTTP/HTTPS | 6 | LOW | — |

---

## Acceptance Criteria (per phase)

### Phase 0 Complete When:
- [ ] `dev_backup/` directory deleted from repo
- [ ] `?u=` parameter has no handler in Application.cfc
- [ ] Login works without `?u=` in redirect
- [ ] `debugLogin = false` in login/login2.cfm
- [ ] `GETDATE()` replaced with `NOW()`

### Phase 1 Complete When:
- [ ] Zero `#url.` or `#form.` variables inside cfquery without cfqueryparam in `include/qry/`
- [ ] Zero dynamic cfinclude with unvalidated user input
- [ ] `/setup/` requires authentication
- [ ] File uploads validate type and size
- [ ] Zero unescaped user input in HTML output
- [ ] `sched/` not accessible from external IPs without auth

### Phase 2 Complete When:
- [ ] All active users have SHA-512+salt password hashes
- [ ] Zero DML statements target view names when _tbl exists
- [ ] All `isdeleted` checks use `= 0` pattern consistently
- [ ] Zero hardcoded datasource names outside Application.cfc

### Phase 3 Complete When:
- [ ] Zero duplicate active enrollments in fusystemusers
- [ ] Unique constraint prevents future duplicates
- [ ] Orphan/stuck counts known and cleaned
- [ ] Recurring notifications chain correctly beyond first recurrence
- [ ] Maintenance system scope rule documented and enforced

### Phase 4 Complete When:
- [ ] Zero N+1 patterns in sched/ files
- [ ] All cfquery variables use cfqueryparam
- [ ] All unbounded SELECTs have LIMIT or maxrows

### Phase 5 Complete When:
- [ ] Dead query fragments removed (278 files)
- [ ] sched/ files classified and one-offs relocated
- [ ] Dead service functions removed

### Phase 6 Complete When:
- [ ] All AJAX calls have error handlers
- [ ] Zero debug console.log in production
- [ ] Login form fields have required + correct labels
