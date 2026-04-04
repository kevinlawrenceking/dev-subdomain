# TAO Project Results — April 2, 2026

**Status:** Wave 1 + Wave 2 investigations complete (P1-P4, P7, P8)
**Branch:** `dev`

---

## Summary Dashboard

| # | Project | Status | Action Needed |
|---|---------|--------|---------------|
| P1 | Saza & Darren Bug | INVESTIGATED | Kevin: run diagnostic SQL, then execute fix |
| P2 | Aud Module Fields | INVESTIGATED | Kevin: run pre-flight counts, then execute migration |
| P3 | Product Audit | INVESTIGATED | Kevin: run verification queries against prod DB |
| P4 | Mia Admin Record | READY | Kevin: review INSERT and execute |
| P7 | Ticket Cleanup | READY | Kevin: run queries A-C, then execute UPDATE |
| P8 | Medium vs Category | INVESTIGATED | No action needed — documentation complete |
| P5 | Deleted Users Toggle | NOT STARTED | Wave 3 — implementation |
| P6 | User Status Mgmt | NOT STARTED | Wave 3 — depends on P5 |
| P9 | Reports Review | NOT STARTED | Wave 3 — depends on P7 |
| P10 | Aud Import Synonyms | NOT STARTED | Wave 4 — depends on P2, P8 |
| P11 | Setup Wizard | NOT STARTED | Wave 5 — design doc only |
| P12 | Users Admin Review | NOT STARTED | Wave 4 — depends on P5, P6 |

---

## P1 — Saza & Darren: Login / Active User Bug

### Root Cause (High Confidence)

The admin users list queries the `taousers` VIEW, which filters `WHERE IsDeleted = 0`. These users almost certainly have `IsDeleted = 1` in `taousers_tbl`.

**Two mechanisms could have set IsDeleted = 1:**
1. `sched/events_completed.cfm` (lines 60-73) — auto-soft-deletes users with `userstatus = 'cancelled'` whose ThriveCart `canceldate` has passed
2. `setup/setup2.cfm` (line 6) — soft-deletes old user row on ThriveCart re-signup

### Diagnostic SQL (Run First)

```sql
-- Find users in the BASE TABLE (bypasses IsDeleted filter)
SELECT userid, userFirstName, userLastName, userEmail, userstatus,
       IsDeleted, customerid, isSetup
FROM taousers_tbl
WHERE userFirstName LIKE '%Saza%'
   OR userLastName LIKE '%Saza%'
   OR userFirstName LIKE '%Darren%'
   OR userLastName LIKE '%Darren%'
   OR userEmail LIKE '%saza%'
   OR userEmail LIKE '%darren%';

-- Check VIEW vs base table counts
SELECT
  (SELECT COUNT(*) FROM taousers_tbl) AS base_table_total,
  (SELECT COUNT(*) FROM taousers) AS view_total,
  (SELECT COUNT(*) FROM taousers_tbl WHERE IsDeleted = 1) AS soft_deleted,
  (SELECT COUNT(*) FROM taousers_tbl WHERE IsDeleted IS NULL) AS null_deleted;

-- Check ThriveCart cancel status
SELECT u.userid, u.userFirstName, u.userLastName, u.userstatus, u.IsDeleted,
       t.canceldate, t.status AS tc_status
FROM taousers_tbl u
LEFT JOIN thrivecart t ON u.customerid = t.id
WHERE u.userFirstName LIKE '%Saza%'
   OR u.userLastName LIKE '%Saza%'
   OR u.userFirstName LIKE '%Darren%'
   OR u.userLastName LIKE '%Darren%';
```

### Fix SQL (After Confirming UserIDs)

```sql
-- Replace <SAZA_USERID> and <DARREN_USERID> with actual IDs
UPDATE taousers_tbl
SET IsDeleted = 0
WHERE userid IN (<SAZA_USERID>, <DARREN_USERID>)
  AND IsDeleted = 1;

-- If their status also needs correction:
UPDATE taousers_tbl
SET userstatus = 'Active'
WHERE userid IN (<SAZA_USERID>, <DARREN_USERID>)
  AND userstatus != 'Active';
```

### Re-deletion Risk

If they have `userstatus = 'Cancelled'` AND a past ThriveCart `canceldate`, the `events_completed.cfm` scheduled job will re-soft-delete them. Must also set `userstatus = 'Active'`.

---

## P2 — Aud Module Field Investigation

### Fields Found

| Column | Table | Purpose | Behavioral Impact |
|--------|-------|---------|-------------------|
| `isAuditionModule` | `taousers_tbl` | Primary gating flag (0/1) | **YES — blocks audition pages, reports, calendar button** |
| `isAudition` | `taousers_tbl` | Legacy flag, meaning unclear | **NONE — never used in any conditional** |

### Where `isAuditionModule` Is Checked (Gates)

| File | Lines | What It Gates | When 0 |
|------|-------|---------------|--------|
| `include/audition_check.cfm` | 6-13 | Audition list, detail, new audition pages | Shows "no access" + cfabort |
| `include/reports.cfm` | 2-5 | Reports page | Shows "no access" + cfabort |
| `include/calendarSectionCalendar.cfm` | 105-111 | "Add Audition" button on calendar | Button hidden |
| `services/EventTypesUserService.cfc` | 83-85 | Event type dropdown | Removes "Audition" from generic list |

### Where `isAuditionModule` Is Set (Writes)

| File | Mechanism |
|------|-----------|
| `sched/thrivecart_process_audition.cfm` line 80 | Scheduled job: sets to 1 on purchase (product 61, plan 88221) |
| `services/UserService.cfc` line 1016-1017 | Admin panel save |
| `app/admin-users/ajax/save.cfm` line 52 | Passes form value to UserService |

### Migration Script

```sql
-- Pre-flight counts (run first):
SELECT COUNT(*) AS users_to_enable FROM taousers_tbl WHERE isAuditionModule = 0 AND IsDeleted = 0;
SELECT COUNT(*) AS users_already_enabled FROM taousers_tbl WHERE isAuditionModule = 1 AND IsDeleted = 0;

-- Enable for all non-deleted users:
UPDATE taousers_tbl
SET isAuditionModule = 1
WHERE isAuditionModule = 0
  AND IsDeleted = 0;

-- Verify:
SELECT isAuditionModule, COUNT(*) AS cnt
FROM taousers_tbl WHERE IsDeleted = 0
GROUP BY isAuditionModule;
```

### Rollback

```sql
-- CAUTION: blunt rollback. Take a snapshot first:
-- SELECT userid, isAuditionModule FROM taousers_tbl WHERE IsDeleted = 0;

-- Precise rollback using ThriveCart purchase history:
UPDATE taousers_tbl tu
LEFT JOIN thrivecart th ON tu.customerid = th.id AND th.BaseProductid = 61
SET tu.isAuditionModule = CASE WHEN th.id IS NOT NULL THEN 1 ELSE 0 END
WHERE tu.IsDeleted = 0;
```

### Files to Simplify Later (Flag Only)

| File | What to Remove |
|------|----------------|
| `include/audition_check.cfm` | Remove `cfif isAuditionModule is not "1"` block |
| `include/reports.cfm` | Remove `cfif isauditionmodule eq 0` block |
| `include/calendarSectionCalendar.cfm` | Remove `cfif isAuditionModule is "1"` wrapper |
| `sched/thrivecart_process_audition.cfm` | Can be decommissioned entirely |
| `app/audition_check.cfm` | Dead code — can be deleted |
| `app/audition-add/audition_check.cfm` | Dead code — can be deleted |

### Dead Feature Flags

`application.features.auditionImportEnabled` and `application.features.auditionImportAllowedUsers` are checked in `AuditionImportService.cfc` but **never set** in Application.cfc. Dead code.

---

## P3 — Product Audit: ThriveCart vs Database

### Critical Architecture Discovery

The field mapping between ThriveCart webhooks and the database is **non-obvious**:

| ThriveCart Field | DB Column | Meaning |
|------------------|-----------|---------|
| `campaign_id` | `BaseProductID` | Product grouping (campaign) |
| `product_id` | `BasePaymentPlanID` | Specific pricing variant |

**The two lists in the prompt are in different ID namespaces.** ThriveCart product IDs (95048, 95181, etc.) are `BasePaymentPlanID` values. Database product IDs (21, 33, etc.) are `BaseProductID` (campaign) values.

### High-Risk Finding: 88221 vs 95813 Discrepancy

`sched/thrivecart_process_audition.cfm` hardcodes `BasePaymentPlanID = 88221`, but the ThriveCart product ID for audition module is `95813`. If these don't match, **audition purchases are silently dropped**.

### INNER JOIN Risk

`sched/thrivecart_process.cfm` uses INNER JOINs on `paymentplans` and `products`. Any missing row = order sits in `Pending` forever, customer never gets setup email.

### Verification Queries (Must Run Against DB)

```sql
-- Check paymentplans
SELECT * FROM paymentplans ORDER BY BasePaymentPlanId;

-- Check products
SELECT * FROM products ORDER BY BaseProductId;

-- Find stuck orders (missing plan or product match)
SELECT th.id, th.CustomerEmail, th.BaseProductID, th.BasePaymentPlanID,
       th.BaseProductLabel, th.status, th.OrderDate
FROM thrivecart th
LEFT JOIN paymentplans pp ON pp.BasePaymentPlanId = th.BasePaymentPlanId
LEFT JOIN products pr ON pr.BaseProductId = th.BaseProductId
WHERE th.status = 'Pending'
  AND (pp.BasePaymentPlanId IS NULL OR pr.BaseProductId IS NULL)
ORDER BY th.OrderDate DESC;

-- Check audition module plan IDs
SELECT * FROM paymentplans WHERE BasePaymentPlanId IN (88221, 95813);
```

### Template INSERTs for Missing Plans

```sql
-- Run ONLY for IDs confirmed missing after verification
INSERT INTO paymentplans (BasePaymentPlanId, planName) VALUES (95048, 'TAO $17/month after free trial') ON DUPLICATE KEY UPDATE planName = VALUES(planName);
INSERT INTO paymentplans (BasePaymentPlanId, planName) VALUES (95181, 'TAO $169/year after free trial') ON DUPLICATE KEY UPDATE planName = VALUES(planName);
INSERT INTO paymentplans (BasePaymentPlanId, planName) VALUES (95803, 'TAO $17/month no trial') ON DUPLICATE KEY UPDATE planName = VALUES(planName);
INSERT INTO paymentplans (BasePaymentPlanId, planName) VALUES (95804, 'TAO $169/year no trial') ON DUPLICATE KEY UPDATE planName = VALUES(planName);
INSERT INTO paymentplans (BasePaymentPlanId, planName) VALUES (95805, 'TAO $8/month') ON DUPLICATE KEY UPDATE planName = VALUES(planName);
INSERT INTO paymentplans (BasePaymentPlanId, planName) VALUES (95806, 'TAO $79.20/year') ON DUPLICATE KEY UPDATE planName = VALUES(planName);
INSERT INTO paymentplans (BasePaymentPlanId, planName) VALUES (95807, 'TAO $10/month') ON DUPLICATE KEY UPDATE planName = VALUES(planName);
INSERT INTO paymentplans (BasePaymentPlanId, planName) VALUES (95808, 'TAO $84.50/year') ON DUPLICATE KEY UPDATE planName = VALUES(planName);
INSERT INTO paymentplans (BasePaymentPlanId, planName) VALUES (95809, 'TAO $99/year no trial') ON DUPLICATE KEY UPDATE planName = VALUES(planName);
INSERT INTO paymentplans (BasePaymentPlanId, planName) VALUES (95810, 'TAO $12/month') ON DUPLICATE KEY UPDATE planName = VALUES(planName);
INSERT INTO paymentplans (BasePaymentPlanId, planName) VALUES (95811, 'TAO $119/year') ON DUPLICATE KEY UPDATE planName = VALUES(planName);
INSERT INTO paymentplans (BasePaymentPlanId, planName) VALUES (95812, 'TAO $12.75/month') ON DUPLICATE KEY UPDATE planName = VALUES(planName);
INSERT INTO paymentplans (BasePaymentPlanId, planName) VALUES (95813, 'TAO Auditions Module $45/year') ON DUPLICATE KEY UPDATE planName = VALUES(planName);
INSERT INTO paymentplans (BasePaymentPlanId, planName) VALUES (96343, 'TAO $17/month one month free') ON DUPLICATE KEY UPDATE planName = VALUES(planName);
INSERT INTO paymentplans (BasePaymentPlanId, planName) VALUES (97435, 'TAO Extended Free Trial') ON DUPLICATE KEY UPDATE planName = VALUES(planName);
```

### Orphaned Database Products (Review)

| BaseProductID | Label | Likely Status |
|---------------|-------|---------------|
| 33 | Partners | Promotional — verify active users |
| 51 | Ajarae Giveaway | One-off — likely retired |
| 82 | Course Subscription | Separate product — verify |
| 86 | 5 Day Training Gift | Gift/promo — likely retired |

---

## P4 — Dev Record for Mia

### Key Discovery

**`suIsAdmin` does NOT exist.** Admin access is controlled by `userRole IN ('Admin', 'Administrator')` — checked in `app/admin-users/admin-guard.cfm`.

### INSERT Statement

```sql
-- Placeholder admin user: Mia
-- Placeholder -- Kevin to add full details
INSERT INTO taousers_tbl (
    userFirstName, userLastName, userEmail, userRole,
    userstatus, passwordHash, passwordSalt, avatarname,
    IsDeleted, isSetup, shareID
) VALUES (
    'Mia',
    '',
    'mia@placeholder.tao',
    'Admin',
    'Active',
    SHA2(CONCAT('temp_change_me', UUID()), 512),
    SHA2(UUID(), 512),
    'Mia',
    0,
    0,
    UUID()
);
```

**Notes:**
- Password hash is non-functional — Kevin must set real password via admin UI
- Email `mia@placeholder.tao` must be changed before real use
- `shareID` is required (NOT NULL UNIQUE) — `UUID()` generates one

### Verification

```sql
SELECT userid, userFirstName, userLastName, userEmail, userRole,
       userstatus, IsDeleted, shareID
FROM taousers_tbl WHERE userRole IN ('Admin', 'Administrator');
```

### Rollback

```sql
UPDATE taousers_tbl SET IsDeleted = 1, userstatus = 'Cancelled'
WHERE userFirstName = 'Mia' AND userEmail = 'mia@placeholder.tao' AND IsDeleted = 0;
```

---

## P7 — Ticket Cleanup

### Schema Corrections

The original prompt had incorrect column names:
- `ticketsubject` -> **`ticketName`**
- `versionlabel` -> computed via **`CONCAT(major, '.', minor, '.', patch, '.', version, '.', build, ' - ', versiontype)`**
- `verstatus` -> **`versionstatus`**
- `tickettype` is a **string** (e.g. 'Feature'), not a numeric ID

### SQL Queries (Run in Order)

```sql
-- A. Get ticket types
SELECT tickettype AS id, tickettype AS name FROM tickettypes ORDER BY tickettype;

-- B. Get next pending version
SELECT v.verid,
       CONCAT(v.major, '.', v.minor, '.', v.patch, '.', v.version, '.', v.build, ' - ', v.versiontype) AS versionlabel,
       v.versionstatus, v.hoursavail
FROM taoversions v
WHERE v.versionstatus = 'Pending'
ORDER BY v.major ASC, v.minor ASC, v.patch ASC
LIMIT 1;

-- C. Find open Feature tickets without a version
SELECT t.ticketid, t.ticketName, t.ticketstatus, t.tickettype,
       t.ticketpriority, t.esthours, t.verid
FROM tickets t
WHERE t.tickettype = 'Feature'
  AND t.ticketstatus NOT IN ('Closed', 'Completed', 'Implemented')
  AND (t.verid IS NULL OR t.verid = 0)
ORDER BY t.ticketid;

-- D. Count before update
SELECT COUNT(*) AS tickets_to_update FROM tickets t
WHERE t.tickettype = 'Feature'
  AND t.ticketstatus NOT IN ('Closed', 'Completed', 'Implemented')
  AND (t.verid IS NULL OR t.verid = 0);

-- E. UPDATE (replace [VERID] with value from Query B)
UPDATE tickets_tbl
SET verid = [VERID]
WHERE tickettype = 'Feature'
  AND ticketstatus NOT IN ('Closed', 'Completed', 'Implemented')
  AND (verid IS NULL OR verid = 0)
  AND ticketActive = 'Y';

-- F. Rollback
UPDATE tickets_tbl SET verid = 0
WHERE tickettype = 'Feature' AND verid = [VERID]
  AND ticketstatus NOT IN ('Closed', 'Completed', 'Implemented')
  AND ticketActive = 'Y';

-- G. Verify
SELECT t.ticketid, t.ticketName, t.ticketstatus,
       CONCAT(v.major, '.', v.minor, '.', v.patch) AS version_assigned
FROM tickets t
LEFT JOIN taoversions v ON t.verid = v.verid
WHERE t.tickettype = 'Feature' AND t.verid = [VERID]
ORDER BY t.ticketid;
```

---

## P8 — Medium vs Category/Subcategory

### Answer: Medium is a SEPARATE DIMENSION, not a replacement

Four distinct taxonomies exist:

| Dimension | Storage | Normalized? | Used In |
|-----------|---------|-------------|---------|
| **Category + Subcategory** | `audprojects.audSubCatID` -> `audsubcategories` -> `audcategories` | Yes (FK chain) | Add/edit forms, role pane, conditional UI logic |
| **AudType** | `events_tbl.audtypeid` -> `audtypes` | Yes (FK) | Event-level: In-Person vs Self-Tape |
| **Medium** | `auditions.medium` (VARCHAR) | No (flat text) | Import only, dupe detection only |
| **AudMedia/AudMediaTypes** | `audmedia` + `audmediatypes` | Yes | File attachments (unrelated naming collision) |

### Hardcoded Magic Values

| Value | File | Line | Likely Meaning |
|-------|------|------|----------------|
| `audcatid = 5` | `audition-add.cfm` | 195 | Commercial — hides Role Type, forces `audroletypeid = 33` |
| `audcatid = 5` | `aud_role_pane.cfm` | 109 | Hides Genre section |
| `audcatid = 6` | `aud_role_pane.cfm` | 142 | Shows Dialect field (likely Theater/Voiceover) |
| `audsubcatid = 34` | `aud_role_pane.cfm` | 125, 162 | Shows Genre + Vocal Quality (likely Animation/VO) |
| `audcatid = 1, audsubcatid = 6` | `appoint-add2.cfm` | 111-112 | Default for new appointments |
| `audStepID = 1` | `AuditionImportService.cfc` | 1608 | Default step for imports (likely "Initial Audition") |

### Import Recommendation

- `category` mapping is adequate — uses `resolveCategoryToSubCatId()` with fuzzy matching
- `medium` is a dead-end field (written to flat `auditions` table only, never displayed)
- No import mapping exists for `audtypeid` — determined by `self_tape` flag instead

---

## Cross-Project Findings

### P2 + P3 Connection: Audition Module Product

- P2 found the gating flag is `isAuditionModule` on `taousers_tbl`
- P3 found the purchase processor hardcodes `BasePaymentPlanID = 88221` for product 61
- ThriveCart lists the product ID as `95813`
- **These may not match** — needs DB verification
- Once P2 migration runs (enable for all users), `thrivecart_process_audition.cfm` becomes dead code

### P1 + P5 Connection: Deleted Users Visibility

- P1 confirms the `taousers` VIEW hides deleted users from admin
- P5 (View Deleted Users Toggle) would prevent this class of bug entirely
- Recommend implementing P5 to give admins permanent visibility

### P4 Correction: suIsAdmin Myth

- The original prompt referenced `suIsAdmin` — this column does NOT exist
- Admin access = `userRole IN ('Admin', 'Administrator')` in `admin-guard.cfm`

---

## Next Steps

### Immediate (Kevin to execute)
1. **P1**: Run diagnostic SQL, fix Saza & Darren
2. **P4**: Execute Mia INSERT (or use admin UI)
3. **P7**: Run queries A-D, then execute UPDATE E

### This Week
4. **P2**: Take pre-migration snapshot, run migration
5. **P3**: Run verification queries, reconcile paymentplans, investigate 88221 vs 95813

### Next Wave (Implementation)
6. **P5**: View Deleted Users Toggle — ready to implement
7. **P6**: User Status Management — after P5
8. **P9**: Reports Review — after P7 ticket cleanup

### Later
9. **P10**: Audition Import Synonyms — after P2, P8
10. **P12**: Users Admin Review — after P5, P6
11. **P11**: Setup Wizard — design doc first, then phased build
