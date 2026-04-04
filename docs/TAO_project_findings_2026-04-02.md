# TAO Project Findings — 2026-04-02

All Wave 1 and Wave 2 investigations complete. This document captures findings, ready-to-run SQL, and next steps for each project.

---

## Table of Contents

- [P1 — Saza & Darren User Bug](#p1--saza--darren-user-bug)
- [P2 — Aud Module Field Investigation](#p2--aud-module-field-investigation)
- [P3 — Product Audit: ThriveCart vs Database](#p3--product-audit-thrivecart-vs-database)
- [P4 — Dev Record for Mia](#p4--dev-record-for-mia)
- [P7 — Ticket Cleanup](#p7--ticket-cleanup)
- [P8 — Medium vs Category/Subcategory](#p8--medium-vs-categorysubcategory)
- [Cross-Project Observations](#cross-project-observations)
- [Remaining Projects (Waves 3-5)](#remaining-projects-waves-3-5)

---

## P1 — Saza & Darren User Bug

**Status:** Ready for DB diagnostic
**Root Cause (most likely):** `IsDeleted = 1` on `taousers_tbl`

### How It Works

The admin list page (`app/admin-users/ajax/list.cfm`) calls `UserService.listUsers()` which queries the `taousers` VIEW. That view filters `WHERE IsDeleted = 0`, making soft-deleted users completely invisible to all admin queries.

Three layers of filtering exist:
1. VIEW: `WHERE IsDeleted = 0` (most likely cause)
2. listUsers WHERE clauses: optional status/role/search filters
3. Pagination: LIMIT/OFFSET

### Diagnostic SQL (run first)

```sql
-- Find Saza and Darren in the BASE TABLE (bypasses view filter)
SELECT userid, userFirstName, userLastName, userEmail, userstatus, 
       IsDeleted, userRole
FROM taousers_tbl
WHERE userFirstName LIKE '%Saza%'
   OR userLastName LIKE '%Saza%'
   OR userFirstName LIKE '%Darren%'
   OR userLastName LIKE '%Darren%';

-- Verify they are absent from the VIEW
SELECT userid, userFirstName, userLastName, userstatus, IsDeleted
FROM taousers
WHERE userFirstName LIKE '%Saza%'
   OR userLastName LIKE '%Saza%'
   OR userFirstName LIKE '%Darren%'
   OR userLastName LIKE '%Darren%';
```

### Fix SQL (DO NOT EXECUTE until diagnostic confirms)

```sql
-- If IsDeleted = 1:
UPDATE taousers_tbl
SET IsDeleted = 0
WHERE userid IN (<saza_userid>, <darren_userid>)
  AND IsDeleted = 1;

-- If userstatus is also wrong:
UPDATE taousers_tbl
SET userstatus = 'Active'
WHERE userid IN (<saza_userid>, <darren_userid>);
```

### Key Files
- `services/UserService.cfc:780` — listUsers() queries the VIEW
- `database/2026-03-19_rebuild_taousers_view_recover.sql` — VIEW definition
- `app/admin-users/admin-guard.cfm` — admin auth also uses VIEW

### Design Note
The admin currently has NO way to see or restore soft-deleted users. This is the structural gap that P5 (View Deleted Users Toggle) addresses.

---

## P2 — Aud Module Field Investigation

**Status:** Ready for migration
**Finding:** Two columns control audition access; new users don't get the flag

### Columns Found

| Column | Table | Purpose |
|--------|-------|---------|
| `isAudition` | `taousers_tbl` | Controls audition feature visibility |
| `isAuditionModule` | `taousers_tbl` | Controls audition module access (was the paid add-on flag) |

### Gating Pattern

Session variables populated from `fetchUsers.cfm` carry these flags. Conditional checks in:

| File | What it gates |
|------|--------------|
| `include/audition_check.cfm` | General audition access |
| `app/audition_check.cfm` | App-level audition access |
| `app/audition-add/audition_check.cfm` | Add audition access |
| `include/reports.cfm` | Report visibility |
| `include/calendarSectionCalendar.cfm` | Calendar audition events |
| `services/EventTypesUserService.cfc` | Event type filtering |
| `include/qry/types_333_2.cfm` | Type filtering |

### How the Flag Gets Set Today
- `sched/thrivecart_process_audition.cfm` sets `isAuditionModule = 1` for product 61/88221
- Admin UI can toggle per-user via `app/admin-users/ajax/save.cfm`
- **Neither** `setup/setup2.cfm` nor `UserService.cfc:createUser` set the flag — new users default to 0

### Migration Script

```sql
-- ============================================================
-- M1_0__enable_aud_module_all_users.sql
-- Enable audition module for ALL existing users
-- ============================================================

-- Enable for all existing users
UPDATE taousers_tbl 
SET isAuditionModule = 1 
WHERE isAuditionModule = 0 OR isAuditionModule IS NULL;

UPDATE taousers_tbl 
SET isAudition = 1 
WHERE isAudition = 0 OR isAudition IS NULL;

-- Fix defaults so new users get the module automatically
ALTER TABLE taousers_tbl ALTER COLUMN isAuditionModule SET DEFAULT 1;
ALTER TABLE taousers_tbl ALTER COLUMN isAudition SET DEFAULT 1;
```

### Rollback Script

```sql
-- ROLLBACK: M1_0__enable_aud_module_all_users
-- WARNING: This removes audition access from users who had it before
-- Only run if the migration caused problems

-- Revert defaults
ALTER TABLE taousers_tbl ALTER COLUMN isAuditionModule SET DEFAULT 0;
ALTER TABLE taousers_tbl ALTER COLUMN isAudition SET DEFAULT 0;

-- Note: Cannot selectively revert existing user flags without 
-- knowing which users had the module before. Full revert:
-- UPDATE taousers_tbl SET isAuditionModule = 0;
-- UPDATE taousers_tbl SET isAudition = 0;
```

### Tech Debt to Flag Later
All `audition_check.cfm` files and conditional blocks can be simplified once confirmed everyone has the module — but don't remove gating code yet.

---

## P3 — Product Audit: ThriveCart vs Database

**Status:** Needs live DB queries to complete reconciliation
**Critical finding:** INNER JOIN in thrivecart_process.cfm silently drops unmatched orders

### Architecture Discovery

Column names in `thrivecart_tbl` are misleading:
- `BaseProductID` actually stores ThriveCart `campaign_id`
- `BasePaymentPlanID` actually stores ThriveCart `product_id`
- `ipn-handler.cfm` is a straight passthrough — no translation layer

### Record Lifecycle

```
1. ThriveCart webhook → ipn-handler.cfm → INSERT thrivecart_tbl (status='Pending')
2. Scheduled: thrivecart_process.cfm → INNER JOIN paymentplans + products
   → generate UUID, send welcome email → status='Emailed'
3. User clicks setup link → setup/index.cfm → setup2.cfm creates taousers record
   → status='Completed'
4. Cancellation: cancel.cfm matches InvoiceID → status='Cancelled'
```

### Critical Risk: INNER JOIN Blocks Processing

In `thrivecart_process.cfm` (line 33-34):
```sql
INNER JOIN paymentplans pp ON pp.BasePaymentPlanId = th.BasePaymentPlanId
INNER JOIN products pr ON pr.BaseProductId = th.BaseProductId
```

If either `paymentplans` or `products` is missing a matching row, the Pending record is **silently skipped**. No error logged. User never gets welcome email.

### Audition Module Product Mapping

| System | ID | DB Column |
|--------|----|-----------|
| ThriveCart campaign_id | 61 | `thrivecart_tbl.BaseProductID` |
| ThriveCart product_id | 88221 | `thrivecart_tbl.BasePaymentPlanID` |
| DB products row | 61 | "The Actor's Office - Yearly Auditions Module" |

`thrivecart_process_audition.cfm` filters on `BasePaymentPlanID = 88221 AND BaseProductid = 61` and sets `taousers.isAuditionModule = 1`.

### Security Issues Found

| File | Line | Issue |
|------|------|-------|
| `sched/thrivecart_process_audition.cfm` | 49, 83 | Unparameterized SQL |
| `sched/cancel2.cfm` | 24 | String interpolation in WHERE |
| `sched/cancel2.cfm` | 44-45 | Unparameterized UPDATE |

### Diagnostic Queries (run on production)

```sql
-- Get actual schemas
DESCRIBE paymentplans;
DESCRIBE products;

-- Find ThriveCart products missing from paymentplans
SELECT DISTINCT th.BasePaymentPlanID
FROM thrivecart th
LEFT JOIN paymentplans pp ON pp.BasePaymentPlanId = th.BasePaymentPlanID
WHERE pp.BasePaymentPlanId IS NULL
ORDER BY th.BasePaymentPlanID;

-- Find ThriveCart campaigns missing from products
SELECT DISTINCT th.BaseProductID
FROM thrivecart th
LEFT JOIN products pr ON pr.BaseProductId = th.BaseProductID
WHERE pr.BaseProductId IS NULL
ORDER BY th.BaseProductID;

-- See every product/plan combo in use
SELECT DISTINCT BaseProductID, BasePaymentPlanID, BaseProductLabel, 
       baseProductName, status, COUNT(*) as cnt
FROM thrivecart
GROUP BY BaseProductID, BasePaymentPlanID, BaseProductLabel, 
         baseProductName, status
ORDER BY BaseProductID;
```

### Recommendations
1. Run the diagnostic queries to identify gaps
2. Insert missing rows into `paymentplans` and `products`
3. Consider changing INNER JOINs to LEFT JOINs with logging in `thrivecart_process.cfm`
4. Fix SQL injection in billing pipeline files

---

## P4 — Dev Record for Mia

**Status:** Ready — recommend using Admin UI instead of raw SQL
**Finding:** Original prompt was wrong about the table

### Corrections to Original Prompt
- Admin users live in `taousers_tbl` with `userRole = 'Admin'`
- NOT in `fusystemusers_tbl` with `suIsAdmin` (that's for follow-up system enrollments)
- Column names are `userFirstName`/`userLastName`, not `fname`/`lname`

### Admin Access Check
`admin-guard.cfm` checks: `userRole EQ "Admin" OR userRole EQ "Administrator"`

### Template INSERT (if raw SQL is preferred)

```sql
-- DO NOT EXECUTE — for Kevin's review
-- Recommend using Admin UI at /app/admin-users/ instead (proper hashing + setup)

SET @password_plain = 'CHANGE_ME';
SET @password_salt  = SHA2(UUID(), 512);
SET @password_hash  = SHA2(CONCAT(@password_plain, @password_salt), 512);

INSERT INTO taousers_tbl (
    userFirstName, userLastName, userEmail, userRole, userstatus,
    passwordHash, passwordSalt, avatarname, IsDeleted, isSetup, shareID
) VALUES (
    'Mia', '', 'mia@placeholder.example', 'Admin', 'Active',
    @password_hash, @password_salt, 'Mia', 0, 0, UUID()
);
```

### Risks
1. **Password hashing mismatch** — ColdFusion `hash()` produces uppercase hex; MySQL `SHA2()` produces lowercase. Login may fail with raw SQL.
2. **shareID** — NOT NULL UNIQUE constraint; `createUser()` in UserService.cfc doesn't supply it (possible latent bug).
3. **Missing setup data** — Raw INSERT skips `user_setup_core.cfm` which populates default actions/systems.

### Recommendation
Use the Admin UI at `/app/admin-users/` to create the account. It handles password hashing correctly and can trigger the setup process.

---

## P7 — Ticket Cleanup

**Status:** Ready for DB queries
**Finding:** Ticket schema well-understood; queries prepared

### Schema Summary

- `tickets_tbl` / `tickets` (view) — soft-delete pattern
- `ticketType` is a VARCHAR string (e.g., `'Feature'`), not an integer
- `verid` FK to `taoversions` — NULL or 0 means unassigned
- When `verid` is set to NULL, code auto-resets `ticketStatus` to `'Pending'`

### Step-by-Step Queries

```sql
-- STEP 1: List all ticket types
SELECT tickettype FROM tickettypes ORDER BY tickettype;

-- STEP 2: Find pending versions with capacity
SELECT v.verid,
    CONCAT(v.major, '.', v.minor, '.', v.patch, '.', v.version, '.', v.build) AS version_label,
    v.versionstatus, v.hoursavail,
    IFNULL((SELECT SUM(t.esthours) FROM tickets t WHERE t.verid = v.verid), 0) AS hours_used,
    (v.hoursavail - IFNULL((SELECT SUM(t.esthours) FROM tickets t WHERE t.verid = v.verid), 0)) AS hours_remaining
FROM taoversions v
WHERE v.versionstatus = 'Pending'
ORDER BY v.major, v.minor, v.patch;

-- STEP 3: Find open Feature tickets without a version
SELECT t.ticketid, t.ticketName, t.ticketStatus, t.ticketType,
       t.ticketPriority, t.esthours, t.ticketCreatedDate
FROM tickets t
WHERE t.ticketType = 'Feature'
  AND t.ticketActive = 'Y'
  AND t.ticketStatus NOT IN ('Closed', 'Completed', 'Implemented')
  AND (t.verid IS NULL OR t.verid = 0)
ORDER BY t.ticketPriority, t.ticketCreatedDate;

-- STEP 4: UPDATE (after reviewing results from steps 1-3)
-- DO NOT EXECUTE until confirmed
-- UPDATE tickets
-- SET verid = <TARGET_VERID>
-- WHERE ticketType = 'Feature'
--   AND ticketActive = 'Y'
--   AND ticketStatus NOT IN ('Closed', 'Completed', 'Implemented')
--   AND (verid IS NULL OR verid = 0);
```

### Notes
- Check hour capacity (`hoursavail`) on target version before bulk-assigning
- Existing UPDATE patterns in `TicketService.cfc` use `tickets` (not `tickets_tbl`)

---

## P8 — Medium vs Category/Subcategory

**Status:** Investigation complete
**Finding:** Medium is an import-only concept, NOT a replacement for Category

### Data Model

```
audcategories (top-level: Film, Television, Voiceover, etc.)
  └── audsubcategories (second-level: Feature, Episodic, etc.)
        └── audprojects.audSubCatID (FK — the ONLY category reference on projects)
  └── audroletypes (scoped by audcatid)
  └── audtypes (scoped by audcatid via comma-separated string)

audmedia / audmediatypes — FILE ATTACHMENTS, not taxonomy
auditions.medium — import-only VARCHAR, no FK to any table
```

### Key Findings

1. **`audprojects` has NO `audcatid` column.** Category is derived by joining through subcategory: `audprojects.audSubCatID → audsubcategories.audCatId → audcategories.audCatId`

2. **"Medium" exists ONLY in the import system:**
   - Mappable column in `ajax/import-auditions/columns.cfm`
   - VARCHAR column in flat `auditions` table
   - Hardcoded validation list in `AuditionImportService.cfc:1147`
   - Values: "film, television, theater, commercial, industrial, new media, voiceover, print, music video, web series, short film, student film, other"

3. **`audmedia`/`audmediatypes` are file attachment tables** — naming similarity to "medium" is coincidental

4. **The import already has a separate `category` field** that resolves to `audsubcatid` via `resolveCategoryToSubCatId()`. Medium flows through as free text only.

### Hardcoded Magic Values

| Value | Files | Meaning |
|-------|-------|---------|
| `audcatid = 5` | audition-add.cfm, roleupdateform.cfm, aud_role_pane.cfm | Voiceover — hides role type, shows vocal quality |
| `audcatid = 6` | aud_role_pane.cfm | Theater — shows dialect |
| `audsubcatid = 34` | aud_role_pane.cfm, roleupdateform.cfm | Animation (under Voiceover) — enables genre |
| `audroletypeid = 33` | audition-add.cfm, roleupdateform.cfm | Hardcoded role type for Voiceover |
| `audtypeid = 1` | audition-add.cfm (JS) | In Person — shows location |
| `audtypeid = 2` | audition-add.cfm (JS) | Self Tape — shows zoom/platform |
| `audtypeid = 23` | audition-add.cfm (JS) | Unknown — hides direct booking |

### Recommendation for Import System

1. **Keep `category` as primary import field** — resolution already works via `resolveCategoryToSubCatId()`
2. **Use `medium` as fallback when `category` is empty** — medium values closely match category names, so route through the same resolver
3. **Deprecate `medium` as a separate concept long-term** — it's redundant with category
4. **Don't remove `auditions.medium` column yet** — used by `AuditionDuplicateMatcherService`

---

## Cross-Project Observations

### P2 + P3 Connection (Audition Module)
- P2 found the flags: `isAudition` and `isAuditionModule` on `taousers_tbl`
- P3 found the billing trigger: `thrivecart_process_audition.cfm` sets `isAuditionModule = 1` for product 61/88221
- Migration: enable flags for all users + change column defaults to 1

### P1 + P5 Connection (Soft Delete Visibility)
- P1 confirmed: admin has NO way to see soft-deleted users
- P5 (View Deleted Users Toggle) directly addresses this gap
- Should be prioritized to prevent future Saza/Darren-type issues

### Security Issues Across Projects
| File | Issue | Severity |
|------|-------|----------|
| `sched/thrivecart_process_audition.cfm:49,83` | Unparameterized SQL | Medium |
| `sched/cancel2.cfm:24,44-45` | SQL injection via string interpolation | Medium |
| `services/ReportsRefreshService.cfc:269-270` | Unparameterized SQL | Medium |
| No CSRF protection on any of 94 forms | Missing CSRF tokens | High |

---

## Remaining Projects (Waves 3-5)

### Wave 3 — Ready to Start After DB Queries

| Project | Status | Blocker |
|---------|--------|---------|
| **P5** View Deleted Users Toggle | Ready to implement | None |
| **P6** User Status Management | Ready to implement | P5 first |
| **P9** Reports Review | Ready to investigate | P7 ticket cleanup first |

### Wave 4 — After Admin Features

| Project | Status | Blocker |
|---------|--------|---------|
| **P10** Audition Import Synonyms | Ready to design | P2 + P8 done |
| **P12** Users Admin Review | Ready to investigate | P5 + P6 first |

### Wave 5 — Needs Design Approval

| Project | Status | Blocker |
|---------|--------|---------|
| **P11** User Setup Wizard | Design doc only | P5 + P6 first, Kevin approval |
