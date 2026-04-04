# TAO — Claude Code Project Prompts (April 2026)

**Generated:** 2026-04-02
**Repo:** `C:\Users\kevin\TAO\dev-subdomain` → branch `dev`
**Remote:** `kevinlawrenceking/dev-subdomain`

---

## Project Index

| #  | Project | Priority | Estimate | Dependencies |
|----|---------|----------|----------|--------------|
| P1 | Saza & Darren — Login/Active User Bug | URGENT | 30 min | None |
| P2 | Aud Module Field Investigation & Normalization | HIGH | 1–2 hrs | None |
| P3 | Product Audit — ThriveCart vs Database | HIGH | 1–2 hrs | None |
| P4 | Dev Record for Mia (New Admin) | LOW | 10 min | None |
| P5 | Admin — View Deleted Users Toggle | MEDIUM | 2–3 hrs | None |
| P6 | Admin — User Status Management (Active/Cancelled/Setup) | MEDIUM | 1–2 hrs | P5 |
| P7 | Ticket Cleanup — Feature Tickets to Next Version | MEDIUM | 1 hr | None |
| P8 | Medium vs Category/Subcategory — Investigation | MEDIUM | 1 hr | P2 |
| P9 | Reports — Ticket Review & Process Audit | MEDIUM | 2–3 hrs | P7 |
| P10 | Audition Import — Synonym Mapping & Custom Options | MEDIUM | 3–4 hrs | P2, P8 |
| P11 | User Setup — Multi-Step Onboarding Wizard | LOW | 8–12 hrs | P5, P6 |
| P12 | Users Admin — Table & UI Review | LOW | 2–3 hrs | P5, P6 |

---

## Execution Notes

### Recommended Execution Order

```
WAVE 1 (This week — urgent/blocking):
  P1  Saza & Darren bug fix
  P4  Dev record for Mia
  P7  Ticket cleanup

WAVE 2 (Next — investigations that inform later work):
  P2  Aud module investigation
  P3  Product audit
  P8  Medium/Category investigation

WAVE 3 (After investigations complete):
  P5  View deleted users toggle
  P6  User status management
  P9  Reports review

WAVE 4 (After admin features):
  P10 Audition import enhancements
  P12 Users admin review

WAVE 5 (Last — largest, needs design approval):
  P11 User setup wizard (design doc first, then phased implementation)
```

### CC Execution Rules (Reminder)

- Feed CC **one project prompt at a time**
- For multi-phase prompts, tell CC to **execute only Phase 1** on the first pass
- All code changes go to branch `dev` in `C:\Users\kevin\TAO\dev-subdomain`
- No new `/include/qry/` files — ever
- No new per-request `createObject` calls
- All queries use `cfqueryparam` — no exceptions
- All variables explicitly scoped
- Tag findings with `// MIGRATE:` and `// TECH-DEBT:` annotations

---

## P1 — Saza & Darren: Login / Active User Bug

**Priority:** URGENT
**Type:** Bug investigation & fix

### Prompt for CC

```
ROLE: Senior ColdFusion developer debugging a user visibility issue in TAO admin.

PROBLEM:
Two users — "Saza" and "Darren" — are not showing up in the active users list. They
should be visible. We need to find out why and fix whatever is filtering them out.

CONTEXT:
- TAO uses a soft-delete view pattern: the `taousers` VIEW filters `taousers_tbl`
  with `WHERE IsDeleted = 0`
- User status is stored in `taousers_tbl.userstatus` with string values:
  'Active', 'Cancelled', 'Setup'
- Admin user list endpoint: `app/admin-users/ajax/list.cfm`
- Admin user detail: `app/admin-users/ajax/get.cfm`
- UserService.cfc (38 functions) handles user queries in `services/UserService.cfc`
- The admin list page is at `app/admin-users/index.cfm`

INVESTIGATION STEPS — execute in order:
1. Query the database directly for these users:
   ```sql
   SELECT userid, fname, lname, email, userstatus, IsDeleted, suIsAdmin,
          DATE_FORMAT(recordcreated, '%Y-%m-%d') as created
   FROM taousers_tbl
   WHERE fname LIKE '%Saza%' OR fname LIKE '%Darren%'
      OR lname LIKE '%Saza%' OR lname LIKE '%Darren%'
      OR email LIKE '%saza%' OR email LIKE '%darren%';
   ```

2. Check if they're filtered out by the `taousers` view (IsDeleted = 1?).

3. Check if the admin list query in `app/admin-users/ajax/list.cfm` has additional
   filters (status, date range, etc.) that would exclude them.

4. Check `fusystemusers` / `fusystemusers_tbl` for matching records and their
   `sustatus` and `isdeleted` columns.

5. Report findings: for each user, state their userid, status, IsDeleted flag,
   and the root cause of why they're not visible.

6. If the fix is a data correction (e.g., flipping IsDeleted or status), write the
   exact SQL UPDATE statement(s) but DO NOT execute — present for review.

7. If the fix is a code bug, identify the file and line, and write a minimal patch.

OUT OF SCOPE:
- Do NOT refactor the admin user list page
- Do NOT modify the view definition
- Do NOT touch any other user records
- Do NOT add new query files to /include/qry/

// MIGRATE: The mixed soft-delete patterns (IsDeleted bit vs userstatus string)
// will need a clean unified approach in the Go user repository.
```

---

## P2 — Aud Module Field Investigation & Normalization

**Priority:** HIGH
**Type:** Investigation + data migration

### Context for Kevin

TAO used to sell the audition module as a paid add-on (`$45/year`, product ID 95813 in ThriveCart, BaseProductID 61 in the database). Now **every user gets the audition module**. There are likely two fields/flags controlling this — we need to find them, understand their downstream effects, and ensure all users have the module enabled.

### Prompt for CC

```
ROLE: Senior ColdFusion/MySQL developer investigating module access flags in TAO.

OBJECTIVE:
The audition module was previously a paid add-on but is now included for all users.
We need to:
1. Find all fields/columns that control audition module access
2. Understand how those fields affect the rest of the application
3. Ensure every user has full audition module access
4. Clean up any legacy add-on gating logic

INVESTIGATION STEPS — execute in order:

PHASE 1: Find the fields
1. Search the database schema for columns related to "aud" module access:
   ```sql
   SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, COLUMN_DEFAULT
   FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = DATABASE()
     AND (COLUMN_NAME LIKE '%aud%module%'
       OR COLUMN_NAME LIKE '%module%'
       OR COLUMN_NAME LIKE '%hasaud%'
       OR COLUMN_NAME LIKE '%audition%access%');
   ```

2. Check `taousers_tbl` and `paymentplans` tables for module-related columns:
   ```sql
   DESCRIBE taousers_tbl;
   DESCRIBE paymentplans;
   ```

3. Search the codebase for references to "aud module" or "audition module" checks:
   - grep for: `audmodule`, `aud_module`, `hasAuditions`, `isAudModule`,
     `module`, `addOn` in `.cfm` and `.cfc` files
   - Focus on conditional checks: `if`, `cfif` blocks that gate audition features

PHASE 2: Map downstream impact
4. For each field found, search the entire codebase for every reference:
   - Which pages check this field before showing audition UI?
   - Which menu items are conditionally shown?
   - Does the billing/IPN handler (`ipn-handler.cfm`) set these fields?
   - Does user setup (`setup/`, `sched/user_setup_core.cfm`) reference them?
   - Do any scheduled tasks in `sched/` check module access?

5. Document findings as a table:
   | Column | Table | Current Values (SELECT DISTINCT) | Files That Reference It | Purpose |
   Build this table with actual data.

PHASE 3: Write the fix
6. Write a SQL migration script that:
   - Sets the audition module flag(s) to "enabled" for ALL users in `taousers_tbl`
   - Include a rollback script
   - Name: `database/migrations/M1_0__enable_aud_module_all_users.sql`

7. Identify any CF code that should be simplified now that everyone has the module.
   Flag with `// TECH-DEBT: Aud module gating — remove conditional, everyone has module`
   Do NOT remove the code yet — just flag it.

OUTPUT:
- Investigation report (fields found, downstream impact table)
- Migration script + rollback
- List of files to simplify (flagged, not modified)

OUT OF SCOPE:
- Do NOT remove any conditional UI gating code yet (flag only)
- Do NOT modify ThriveCart product configuration
- Do NOT touch the audition import module
- Do NOT add new query files to /include/qry/
- Do NOT refactor any service CFCs

// MIGRATE: In the Go rewrite, audition access will be a feature flag in the
// user permissions model, not a column on the users table.
```

---

## P3 — Product Audit: ThriveCart vs Database

**Priority:** HIGH
**Type:** Investigation + report

### Context for Kevin

There's a mismatch between the products configured in ThriveCart and what's in the production database. This prompt will generate a reconciliation report.

### Prompt for CC

```
ROLE: Senior ColdFusion/MySQL developer auditing product/billing data in TAO.

OBJECTIVE:
Reconcile the ThriveCart product catalog with the TAO database product records.
Write a report identifying missing, orphaned, and mismatched products.

KNOWN THRIVECART PRODUCTS (external system — these are the source of truth):
| TC Product ID | Label |
|---------------|-------|
| 95048 | The Actor's Office ($17/month after free trial) |
| 95181 | The Actor's Office ($169/year after free trial) |
| 95803 | The Actor's Office ($17/month no trial) |
| 95804 | The Actor's Office ($169/year no trial) |
| 95805 | The Actor's Office ($8/month) |
| 95806 | The Actor's Office ($79.20/year) |
| 95807 | The Actor's Office ($10/month) |
| 95808 | The Actor's Office ($84.50/year) |
| 95809 | The Actor's Office ($99/year no trial) |
| 95810 | The Actor's Office ($12/month) |
| 95811 | The Actor's Office ($119/year) |
| 95812 | The Actor's Office ($12.75/month) |
| 95813 | The Actor's Office | Auditions Module Add-On ($45/year) |
| 96343 | The Actor's Office ($17/month one month free) |
| 97435 | The Actor's Office (Extended Free Trial) |

KNOWN DATABASE PRODUCTS (from prod query):
| BaseProductID | BaseProductLabel |
|---------------|-----------------|
| 21 | The Actor's Office |
| 33 | The Actor's Office - Partners |
| 37 | The Actor's Office 1 month FREE |
| 51 | TAO 1 month FREE Ajarae Giveaway |
| 62 | The Actor's Office - Full System |
| 61 | The Actor's Office - Yearly Auditions Module |
| 69 | The Actor's Office - Three Months Free |
| 82 | Actor's Office - Course Subscription |
| 86 | The Actor's Office - 5 Day Training Gift |
| 24201 | The Actor's Office |
| 97435 | The Actor's office |

INVESTIGATION STEPS:

1. Query the database for the full product and payment plan schema:
   ```sql
   DESCRIBE paymentplans;
   SELECT * FROM paymentplans ORDER BY BaseProductID;
   ```

2. Query the thrivecart table for all distinct product references:
   ```sql
   DESCRIBE thrivecart_tbl;
   SELECT DISTINCT thrivecart_product_id, thrivecart_product_name
   FROM thrivecart_tbl
   ORDER BY thrivecart_product_id;
   ```
   (Adjust column names based on actual schema.)

3. Check ipn-handler.cfm to understand how ThriveCart product IDs map to
   database BaseProductID values. This is the webhook that processes purchases.
   File: `ipn-handler.cfm` (root directory)

4. Check for any product mapping logic in services:
   - grep for `BaseProductID`, `productid`, `paymentplan` in services/*.cfc

5. Produce a reconciliation report with three sections:

   A. MISSING FROM DATABASE — ThriveCart products with no matching DB record
      (these need to be added)

   B. ORPHANED IN DATABASE — DB products with no matching ThriveCart product
      (may be legacy/retired — flag for review)

   C. MATCHED — Products that exist in both systems with any label mismatches

   D. PRODUCT 95813 (Auditions Module Add-On) — Special attention:
      how is this handled in ipn-handler.cfm? Does it set module flags?
      Cross-reference with P2 findings.

6. For any products MISSING FROM DATABASE, write INSERT statements to add them.
   Match the schema of existing paymentplans records. DO NOT execute — present
   for review.

7. Note product 97435 — it exists in both ThriveCart AND the database (same ID).
   Verify the label matches and the mapping is correct.

OUTPUT:
- Full reconciliation report (sections A–D)
- INSERT statements for missing products
- Recommendations on orphaned products (retire? keep?)
- Notes on product 95813 (audition module add-on) and its relationship to P2

OUT OF SCOPE:
- Do NOT modify ipn-handler.cfm
- Do NOT modify ThriveCart configuration
- Do NOT delete any database records
- Do NOT add new query files to /include/qry/

// MIGRATE: Product/billing model in Go will use a normalized products table
// with a separate subscriptions table. ThriveCart webhook handler becomes a
// Go HTTP handler with idempotent processing.
```

---

## P4 — Dev Record for Mia (New Admin)

**Priority:** LOW
**Type:** Data insert

### Prompt for CC

```
ROLE: ColdFusion/MySQL developer adding an admin record in TAO.

OBJECTIVE:
Create a new dev/admin user record for "Mia" in the system. This is a placeholder
record — Kevin will add full details later.

STEPS:

1. Check the schema for the admin/dev user table:
   ```sql
   DESCRIBE fusystemusers_tbl;
   ```

2. Check existing admin records for the correct pattern:
   ```sql
   SELECT * FROM fusystemusers_tbl WHERE suIsAdmin = 1 LIMIT 5;
   ```

3. Write an INSERT statement that creates a minimal record for Mia:
   - Name: "Mia" (first name only for now)
   - Status: Active
   - IsAdmin: true
   - All other fields: sensible defaults matching existing admin records
   - Add a comment: "Placeholder — Kevin to add full details"

4. Present the INSERT for review. DO NOT execute.

OUT OF SCOPE:
- Do NOT create a taousers_tbl record (this is admin/dev only)
- Do NOT set up any login credentials
- Do NOT modify any existing records
```

---

## P5 — Admin: View Deleted Users Toggle

**Priority:** MEDIUM
**Type:** Feature — UI + query changes

### Prompt for CC

```
ROLE: Senior ColdFusion developer adding soft-delete visibility to the TAO admin panel.

OBJECTIVE:
Add a toggle to the admin users page that lets admins see soft-deleted users, with
the ability to undelete (restore) them.

EXISTING CODE:
- Admin users list page: app/admin-users/index.cfm
- Admin users AJAX list: app/admin-users/ajax/list.cfm
- Admin users AJAX get: app/admin-users/ajax/get.cfm
- Admin users AJAX save: app/admin-users/ajax/save.cfm
- Admin toggle status: app/admin-users/ajax/toggle-status.cfm
- Admin guard: app/admin-users/admin-guard.cfm
- UserService.cfc: services/UserService.cfc

SOFT-DELETE PATTERN:
- Base table: taousers_tbl (has IsDeleted column, 0 or 1)
- View: taousers (filters WHERE IsDeleted = 0)
- Current admin queries use the `taousers` view, so deleted users are invisible

REQUIREMENTS:

1. Add a UI toggle (checkbox or switch) on the admin users list page
   labeled "Show deleted users". Default: OFF (current behavior).

2. When toggled ON:
   - The AJAX list endpoint queries `taousers_tbl` directly instead of the
     `taousers` view
   - Deleted users are visually distinguished (e.g., red text, strikethrough,
     or a "Deleted" badge)
   - A "Restore" button appears for each deleted user

3. When the "Restore" button is clicked:
   - AJAX call to a new endpoint or modified toggle-status.cfm
   - Sets IsDeleted = 0 on taousers_tbl
   - Logs the restore action (cflog to `admin_users` log file)
   - Refreshes the list

4. The toggle state should be passed as a URL/form parameter to the AJAX
   list endpoint (e.g., `showDeleted=1`). Do NOT persist it in session.

IMPLEMENTATION NOTES:
- The list.cfm endpoint already has search and status filter params — add
  showDeleted as another filter
- Use the existing Bootstrap styling and Lucide Icons
- The restore action needs CSRF protection (even though no other forms have it —
  we're doing new code right)
  // TECH-DEBT: This will be one of the first forms with CSRF. Existing 94 forms
  // are unprotected per the security audit.

FILES TO MODIFY:
- app/admin-users/index.cfm (add toggle UI)
- app/admin-users/ajax/list.cfm (add showDeleted filter, query taousers_tbl)
- app/admin-users/ajax/toggle-status.cfm (add restore/undelete action)

FILES NOT TO MODIFY:
- services/UserService.cfc (don't add new service methods for this — keep it
  in the AJAX handlers for now)

OUT OF SCOPE:
- Do NOT add the ability to hard-delete users
- Do NOT modify the taousers view definition
- Do NOT change how other parts of the app query users
- Do NOT add new query files to /include/qry/
- Do NOT refactor the existing admin-users page layout

// MIGRATE: In Go, this becomes a query parameter on GET /api/admin/users
// with ?include_deleted=true. The repository will query the _tbl table directly.
```

---

## P6 — Admin: User Status Management (Active / Cancelled / Setup)

**Priority:** MEDIUM
**Type:** Feature clarification + minor UI fix
**Depends on:** P5

### Context for Kevin

There are three user statuses: **Active**, **Cancelled**, and **Setup**. The "Setup" status is for new users who haven't completed onboarding yet — when they click the email verification link, they land in the setup flow. The admin can currently toggle Active/Cancelled, but we need to make sure "Setup" is properly handled.

### Prompt for CC

```
ROLE: Senior ColdFusion developer reviewing user status logic in TAO.

OBJECTIVE:
Audit and document the three user statuses (Active, Cancelled, Setup) and ensure
the admin panel handles all three correctly.

INVESTIGATION:

1. Check all distinct user statuses in the database:
   ```sql
   SELECT userstatus, COUNT(*) as cnt
   FROM taousers_tbl
   GROUP BY userstatus
   ORDER BY cnt DESC;
   ```

2. Check the userstatuses reference table:
   ```sql
   SELECT * FROM userstatuses;
   ```

3. Review the admin toggle-status endpoint:
   File: app/admin-users/ajax/toggle-status.cfm
   - What statuses can it currently set?
   - Does it handle the "Setup" status?

4. Review the login flow to understand how "Setup" status is used:
   - app/Application.cfc — onRequestStart: does it check userstatus?
   - setup/index.cfm — is this where Setup users land?
   - loginform.cfm — does login redirect Setup users to the setup flow?

5. Search for all userstatus checks in the codebase:
   ```
   grep -rn "userstatus" --include="*.cfm" --include="*.cfc" | head -60
   ```

REQUIREMENTS:

1. The admin toggle-status endpoint should support three transitions:
   - Active → Cancelled
   - Cancelled → Active
   - Setup → Active (admin manually completing setup)
   - Active → Setup should NOT be allowed (one-way out of Setup)

2. The admin user list should display the status with appropriate styling:
   - Active: green badge
   - Cancelled: red badge
   - Setup: yellow/amber badge

3. The admin user detail view should show the status clearly.

OUTPUT:
- Investigation report: how status currently works end-to-end
- Any code changes needed to support all three statuses in admin
- Document the "Setup" → email click → setup flow → Active lifecycle

OUT OF SCOPE:
- Do NOT modify the setup flow itself (that's P11)
- Do NOT modify the login flow
- Do NOT add new user statuses
- Do NOT add new query files to /include/qry/

// MIGRATE: In Go, user status becomes an enum type in the users table.
// Status transitions will be enforced by a state machine in the user service.
```

---

## P7 — Ticket Cleanup: Feature Tickets to Next Version

**Priority:** MEDIUM
**Type:** Data operation + query

### Prompt for CC

```
ROLE: ColdFusion/MySQL developer performing ticket housekeeping in TAO.

OBJECTIVE:
Find all open tickets of type "Feature" and assign them to the next available
pending version.

STEPS:

1. Identify the ticket type ID for "Feature":
   ```sql
   SELECT * FROM tickettypes;
   ```

2. Find the next available pending version:
   ```sql
   SELECT verid, versionlabel, verstatus
   FROM taoversions
   WHERE verstatus = 'Pending'
   ORDER BY versionlabel ASC
   LIMIT 1;
   ```
   If no pending version exists, report that and stop.

3. Find all open feature tickets not already assigned to a version:
   ```sql
   SELECT t.ticketid, t.ticketsubject, t.ticketstatus, t.tickettype,
          t.verid, v.versionlabel
   FROM tickets_tbl t
   LEFT JOIN taoversions v ON t.verid = v.verid
   WHERE t.tickettype = [Feature type ID]
     AND t.ticketstatus NOT IN ('Closed', 'Completed')
     AND (t.verid IS NULL OR t.verid = 0)
   ORDER BY t.ticketid;
   ```

4. Present the list of tickets that will be updated, along with the target
   version, for review.

5. Write the UPDATE statement to assign them:
   ```sql
   UPDATE tickets_tbl
   SET verid = [pending version ID]
   WHERE ticketid IN ([list from step 3])
     AND (verid IS NULL OR verid = 0);
   ```

6. Present the UPDATE for review. DO NOT execute.

OUTPUT:
- Count of feature tickets found
- Target version details
- Full ticket list (ID, subject, current status)
- UPDATE statement ready for review

OUT OF SCOPE:
- Do NOT close or change the status of any tickets
- Do NOT create new versions
- Do NOT modify ticket priorities
- Do NOT touch tickets that already have a version assigned
```

---

## P8 — Medium vs Category/Subcategory Investigation

**Priority:** MEDIUM
**Type:** Investigation
**Depends on:** P2

### Context for Kevin

The audition data model has `categories`, `subcategories`, AND a `medium`/`media` concept. We need to understand what "Medium" is, whether it replaces or supplements category/subcategory, and how the import system should handle it.

### Prompt for CC

```
ROLE: Senior ColdFusion/MySQL developer investigating the audition data model in TAO.

OBJECTIVE:
Document the relationship between Medium (media/mediatypes), Categories, and
Subcategories in the audition module. Determine if Medium is intended to replace
category/subcategory or supplement it.

INVESTIGATION:

1. Check all three tables:
   ```sql
   SELECT * FROM audcategories ORDER BY audcatid;
   SELECT * FROM audsubcategories ORDER BY audsubcatid;
   SELECT * FROM audmediatypes ORDER BY audmediatypeid;
   ```
   Also check for a separate "medium" table:
   ```sql
   SHOW TABLES LIKE '%medium%';
   SHOW TABLES LIKE '%media%';
   ```

2. Check the audition main table for which columns reference these:
   ```sql
   DESCRIBE audprojects;
   -- or
   DESCRIBE audprojects_tbl;
   ```
   Look for: audcatid, audsubcatid, audmediatypeid, mediumid, etc.

3. Check the admin CRUD pages for each:
   - app/aud-categories-Details/index.cfm
   - app/aud-categories-Results/index.cfm
   - app/aud-subcategories-Details/index.cfm
   - app/aud-subcategories-Results/index.cfm
   - app/aud-media-Details/index.cfm
   - app/aud-media-Results/index.cfm
   - app/aud-mediatypes-Details/index.cfm
   - app/aud-mediatypes-Results/index.cfm

4. Check the audition add/update forms:
   - include/audition-add.cfm — which dropdowns appear?
   - include/audition-update.cfm — which dropdowns appear?
   Do they show category + subcategory + medium? Or just some of these?

5. Check the audition import column mapping:
   - ajax/import-auditions/columns.cfm
   - What fields does the import system map for category/subcategory/medium?

6. Check for magic audcatid values in the codebase:
   - Known: audcatid = 5, 6 and audsubcatid = 34 are hardcoded in
     include/audition-add.cfm and include/aud_role_pane.cfm

OUTPUT:
- Data model diagram (text-based) showing the relationship between
  categories, subcategories, media, and mediatypes
- Table: which UI pages use which concept
- Recommendation: is "Medium" a replacement for category, or a separate axis?
- List of hardcoded magic values that need to become configurable
- How the import system should treat these fields

OUT OF SCOPE:
- Do NOT modify any tables or data
- Do NOT change any UI pages
- Do NOT modify the import system
- Do NOT add new query files to /include/qry/

// MIGRATE: In Go, the audition taxonomy (category/subcategory/medium/type)
// needs to be a clean normalized schema. This investigation informs that design.
```

---

## P9 — Reports: Ticket Review & Process Audit

**Priority:** MEDIUM
**Type:** Investigation + report
**Depends on:** P7 (ticket cleanup first)

### Prompt for CC

```
ROLE: Senior ColdFusion developer auditing the TAO reports module.

OBJECTIVE:
Two tasks:
A) Find any user-submitted tickets requesting custom reports. Write up the request
   and assess whether it can become a standard report.
B) Review the entire reports system architecture for simplification opportunities.

PART A — TICKET REVIEW:

1. Query for report-related tickets:
   ```sql
   SELECT t.ticketid, t.ticketsubject, t.ticketdescription, t.ticketstatus,
          t.tickettype, t.recordcreated,
          u.fname, u.lname
   FROM tickets_tbl t
   LEFT JOIN taousers_tbl u ON t.userid = u.userid
   WHERE (t.ticketsubject LIKE '%report%'
      OR t.ticketdescription LIKE '%report%'
      OR t.ticketsubject LIKE '%export%'
      OR t.ticketsubject LIKE '%data%')
   ORDER BY t.recordcreated DESC;
   ```

2. For each relevant ticket found:
   - Summarize the user's request
   - Assess feasibility as a standard report
   - Estimate implementation effort (low/medium/high)

PART B — REPORTS ARCHITECTURE REVIEW:

3. Examine the reports infrastructure:
   - app/reports/index.cfm — main reports page
   - app/reportsrefresh/index.cfm — report refresh mechanism
   - services/ReportsRefreshService.cfc — report generation logic
   - Database tables: reports_master, reports_user, reportcolors

4. Query report definitions:
   ```sql
   SELECT * FROM reports_master ORDER BY reportid;
   SELECT * FROM reports_user LIMIT 20;
   SELECT * FROM reportcolors;
   ```

5. Review ReportsRefreshService.cfc:
   - How many report types exist?
   - How is report data generated (inline SQL? stored procedures?)
   - Note: Known unparameterized SQL at lines 269-270
     (`a.audstepid` and `t.audtypeid` without cfqueryparam)
   - How customizable is it currently?

6. Assess:
   - Could the report setup be simplified?
   - How difficult would it be to allow more customization?
   - Could users create their own custom reports? (lower priority, but assess)

OUTPUT:
- Part A: Table of report-related tickets with feasibility assessments
- Part B: Architecture summary of current report system
- Recommendations for simplification
- Estimated effort for adding user-requested reports
- Note any security issues found (known: unparameterized SQL in
  ReportsRefreshService.cfc)

OUT OF SCOPE:
- Do NOT implement any new reports
- Do NOT modify ReportsRefreshService.cfc
- Do NOT modify the reports UI
- Do NOT add new query files to /include/qry/

// MIGRATE: In Go, reports will use a query builder pattern with parameterized
// filters. The current magic-value-driven approach won't carry over.
// TECH-DEBT: ReportsRefreshService.cfc lines 269-270 have unparameterized SQL.
```

---

## P10 — Audition Import: Synonym Mapping & Custom Options

**Priority:** MEDIUM
**Type:** Feature enhancement
**Depends on:** P2 (aud module), P8 (medium/category investigation)

### Prompt for CC

```
ROLE: Senior ColdFusion developer enhancing the TAO audition import system.

OBJECTIVE:
Three enhancements to the audition import mapping system:
A) Add synonym support so "Character" and "Role" (and variants) map to the same field
B) Allow users to add custom mapping options (not just defaults)
C) Track user mapping choices to improve default suggestions over time

EXISTING CODE:
- Audition import pipeline: ajax/import-auditions/*.cfm
  - upload.cfm, parse.cfm, columns.cfm, rows.cfm, row.cfm
  - row_action.cfm, fact_update.cfm, recompute.cfm, finalize.cfm
- Audition import tables:
  - import_auditions_jobs, import_auditions_columns
  - import_auditions_rows, import_auditions_facts
  - import_auditions_row_results, import_auditions_events
- Contact import (reference implementation): ajax/importv3/*.cfm
  - It uses import_field_mappings and import_field_aliases for auto-mapping
- Import field alias pattern (from contact import):
  ```sql
  SELECT * FROM import_field_aliases LIMIT 20;
  SELECT * FROM import_field_mappings LIMIT 20;
  ```

PART A — SYNONYM SUPPORT:

1. Check the current audition import column mapping logic in:
   - ajax/import-auditions/columns.cfm
   - ajax/import-auditions/parse.cfm
   How does it currently match CSV headers to audition fields?

2. Create or extend an alias table for audition import fields.
   If import_field_aliases already covers auditions, extend it.
   If not, create a new table or add audition-specific rows.

   Minimum synonyms to support:
   | CSV Header Variant | Maps To Field |
   |-------------------|---------------|
   | Character | role_name (or equivalent audition role field) |
   | character | role_name |
   | Character Name | role_name |
   | character_name | role_name |
   | Role | role_name |
   | role | role_name |
   | Role Name | role_name |

3. Modify the column matching logic to use case-insensitive synonym lookup.

PART B — CUSTOM USER MAPPING OPTIONS:

4. Design a mechanism for users to save custom column mappings.
   - When a user maps an unrecognized column header to a field, save that mapping
   - Next time the user imports, that custom mapping should auto-suggest
   - Table design: user_import_mappings or extend import_field_aliases with a userid

5. Write the migration script for any new tables needed.

PART C — MAPPING INTELLIGENCE (lower priority):

6. Design (but don't implement) a system where:
   - Every successful user mapping is logged
   - Popular mappings (used by 3+ users) are promoted to global defaults
   - This is a design doc only — implementation is future work

OUTPUT:
- Part A: Code changes for synonym support in column mapping
- Part B: Migration script for custom user mappings table + code changes
- Part C: Design document for mapping intelligence (no code)
- All new code must use cfqueryparam for ALL parameters

OUT OF SCOPE:
- Do NOT modify the contact import system (importv3)
- Do NOT change the import UI layout
- Do NOT modify finalization logic
- Do NOT add new query files to /include/qry/
  (put queries in the appropriate AJAX handler or a service CFC)
- Do NOT touch the audition import audit blockers (CSRF, schema) —
  those are a separate workstream

// MIGRATE: In Go, import column mapping becomes a service with a strategy
// pattern: GlobalAliases → UserAliases → FuzzyMatch. The alias tables
// translate directly to a Go repository.
```

---

## P11 — User Setup: Multi-Step Onboarding Wizard

**Priority:** LOW (largest project — needs design approval first)
**Type:** New feature — multi-page flow
**Depends on:** P5 (deleted users), P6 (status management)

### Context for Kevin

This is the biggest item. It's a one-time, multi-step onboarding wizard for new users. When a user's status is "Setup" and they click the email verification link, they enter this wizard. Each step collects data, can be skipped, and has an expandable tutorial section. The wizard replaces the current minimal setup flow.

### Prompt for CC — PHASE 1 ONLY (Design Document)

```
ROLE: Senior ColdFusion developer designing a multi-step onboarding wizard for TAO.

OBJECTIVE:
Design (NOT implement) the multi-step user setup process. This prompt produces a
design document only. Implementation will follow in separate phases.

EXISTING SETUP CODE:
- setup/index.cfm — current setup entry point
- setup/setup2.cfm — step 2
- setup/setup-complete.cfm — completion page
- setup/contact_info.cfm — contact info collection
- setup/user_setup_core.cfm — core setup logic
- setup/Filecheck.cfm — file verification
- sched/user_setup_core.cfm — scheduled setup tasks

WIZARD STEPS (proposed — confirm with Kevin):

1. WELCOME & ACCOUNT INFO
   - Name, email (pre-filled from registration)
   - Timezone, date format preference
   - Profile photo / avatar picker
   - Tutorial: "How TAO helps you manage your acting career"

2. ADD YOUR REPRESENTATION
   - Agent, Manager, Publicist contacts
   - Quick-add form (name, company, phone, email)
   - Skip option: "I'll add this later"
   - Tutorial: "Why tracking your team matters"

3. IMPORT OR ADD CONTACTS
   - Option A: Import from CSV/spreadsheet (link to import flow)
   - Option B: Manually add 3-5 key contacts
   - Skip option: "I'll add contacts later"
   - Tutorial: "Contacts are the foundation of your network"

4. IMPORT OR ADD AUDITIONS
   - Option A: Import from CSV/spreadsheet (link to audition import)
   - Option B: Manually add a recent audition
   - Skip option: "I'll add auditions later"
   - Tutorial: "Tracking auditions helps you see patterns"

5. RELATIONSHIP REMINDERS
   - Explain the relationship reminder system
   - Set up 2-3 starter reminders for key contacts
   - Skip option: "I'll set these up later"
   - Tutorial: "How relationship reminders keep you connected"

6. MY LINKS
   - Add key links (casting profiles, social media, website)
   - Pre-populated suggestions (Actors Access, Casting Networks, IMDb)
   - Skip option: "I'll add links later"
   - Tutorial: "Quick access to your most-used sites"

7. COMPLETION
   - Summary of what was set up
   - Quick links to each section for later editing
   - Set userstatus from 'Setup' to 'Active'
   - Redirect to dashboard

DESIGN DOCUMENT REQUIREMENTS:

1. For each step, document:
   - Database tables involved (which tables are read/written)
   - Required fields vs optional fields
   - Skip behavior (what happens if user skips)
   - Tutorial content summary
   - UI wireframe description (layout, components)

2. Technical architecture:
   - URL pattern: setup/step1.cfm, setup/step2.cfm, etc.? Or single page
     with AJAX-loaded steps?
   - Progress tracking: where is the current step stored? (session?
     database column on taousers_tbl?)
   - Back/forward navigation rules
   - What prevents a user from skipping to the dashboard URL directly?
   - How does the setup guard work? (Application.cfc onRequestStart check)

3. Data flow diagram:
   - Which service CFCs are called at each step?
   - Which existing forms/include files can be reused?

4. Migration needs:
   - Any new database columns or tables needed?
   - Any changes to taousers_tbl schema?

OUTPUT:
- Complete design document as markdown
- Database changes needed (schema only, no migration scripts yet)
- List of existing code that can be reused vs. needs new implementation
- Estimated implementation effort per step

OUT OF SCOPE:
- Do NOT write any implementation code
- Do NOT modify any existing files
- Do NOT create database migrations
- This is DESIGN ONLY

// MIGRATE: In Go/Flutter, the setup wizard becomes a Flutter multi-screen
// flow calling Go API endpoints. Each step is a separate API call. The
// wizard state is tracked server-side in the user record.
```

---

## P12 — Users Admin: Table & UI Review

**Priority:** LOW
**Type:** Investigation + recommendations
**Depends on:** P5 (deleted users), P6 (status management)

### Prompt for CC

```
ROLE: Senior ColdFusion developer reviewing the admin users management interface.

OBJECTIVE:
Review the entire admin users table/page for completeness, usability issues, and
missing functionality. Produce a recommendations report.

EXISTING CODE:
- app/admin-users/index.cfm — main admin users page
- app/admin-users/detail.cfm — user detail view
- app/admin-users/admin-guard.cfm — admin access check
- app/admin-users/setup-verification.cfm — setup verification
- app/admin-users/ajax/list.cfm — AJAX list endpoint
- app/admin-users/ajax/get.cfm — AJAX get endpoint
- app/admin-users/ajax/save.cfm — AJAX save endpoint
- app/admin-users/ajax/toggle-status.cfm — status toggle
- app/admin-users/ajax/send-email.cfm — send email to user
- app/admin-users/ajax/preview-email.cfm — email preview

REVIEW AREAS:

1. USERS TABLE COLUMNS
   - What columns are currently shown in the list view?
   - What columns SHOULD be shown? (Consider: name, email, status, plan/product,
     created date, last login, audition module flag, contact count)
   - Is there sorting? Filtering? Pagination?

2. USER DETAIL VIEW
   - What information is shown on the detail page?
   - What's missing? (billing history, login history, activity summary)
   - Can the admin edit all relevant fields?

3. SEARCH & FILTERING
   - Can admin search by name, email?
   - Can admin filter by status, product/plan, date range?
   - Is there an export option for user data?

4. MISSING FEATURES (assess each):
   - Impersonate user (login as user for debugging)
   - View user's subscription/billing history
   - Send custom email to user
   - Bulk actions (bulk status change, bulk email)
   - User activity log (last login, page views)
   - Notes field for admin notes about a user

5. SECURITY REVIEW
   - Is admin-guard.cfm properly protecting all admin endpoints?
   - Are all AJAX endpoints checking admin status?
   - Any admin endpoints accessible without authentication?

OUTPUT:
- Current state summary (what exists, what works)
- Gap analysis table (feature | exists? | priority | effort)
- Recommendations ranked by priority
- Security findings if any

OUT OF SCOPE:
- Do NOT implement any changes
- Do NOT modify any files
- This is REVIEW/REPORT ONLY

// MIGRATE: Admin users in Go will be a proper admin API with role-based
// access control. The Flutter admin panel will consume these endpoints.
```
