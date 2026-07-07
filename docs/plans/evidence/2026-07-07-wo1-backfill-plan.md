# WO-1 Backfill — Plan (recon + drafted SQL, PRE-EXECUTION)

**Binding:** TAO / `dev-subdomain` / branch `dev` · **Date:** 2026-07-07 · **Author:** CC
**Status:** PLAN ONLY. **No writes performed.** Drafted SQL below is for review; on approval it
becomes `V3_10` (+ROLLBACK) and runs on **dev first**. Gates `V3_9` (FKs) per A2.
**Prereqs met:** V3_7 columns + V3_8 view applied on dev (`2026-07-07-wo1-dev-apply-v3_7-v3_8.md`);
dev master tables seeded (`co_contacts` 25,200 / `co_locations` 12,617 / `companies` 10,740).
**Engine:** MySQL 8.0.41 — `ROW_NUMBER()` / CTE available (already used by `v_contacts_optimized`).

---

## 1. What has to be populated (12 cols, two independent parts)

| Part | Columns | Source | Nature |
|---|---|---|---|
| **A — hot-field denormalization** | `contactPhone`, `contactEmail`, `contactCompany` | the contact's OWN `contactitems_tbl` rows | deterministic, self-contained, safe |
| **A (provenance)** | `contactPhone_src`, `contactEmail_src`, `contactCompany_src`, `contactPhoto_src` | n/a — stay `'user'` | no-op (V3_7 defaulted them `'user'`) |
| **B — master linkage** | `master_co_contact_id`, `master_coid`, `company_location_id`, `master_linked_date`, `master_last_sync` | `co_contacts` / `companies` / `co_locations` via a MATCH KEY | needs a matching decision (below) |

Part A and Part B are independent. **Recommend running A now** (deterministic) and **gating B on the
match-key decision** in §4.

---

## 2. Part A — hot-field denormalization (DRAFT, ready on approval)

Mirrors the live `contacts_ss` selection (`valueCategory` + `itemStatus='Active'`, Phone/Email use
`valuetext`, Company uses `valueCompany`) but adds the locked A5 secondary tie-break `itemID ASC` for
determinism, and filters `IsDeleted=0` explicitly (base table, not the view). Set-based via
`ROW_NUMBER()` — one pass per category, index-friendly. Idempotent (recomputes from current items).

```sql
-- USE new_development;   -- confirm SELECT DATABASE() first. Wrap all three in one transaction.
START TRANSACTION;

-- A1. contactPhone
UPDATE contactdetails_tbl cd
JOIN (
  SELECT contactID, valuetext,
         ROW_NUMBER() OVER (PARTITION BY contactID ORDER BY primary_YN DESC, itemID ASC) rn
  FROM   contactitems_tbl
  WHERE  valueCategory='Phone' AND itemStatus='Active' AND IsDeleted=0
    AND  TRIM(COALESCE(valuetext,'')) <> ''
) p ON p.contactID = cd.contactID AND p.rn = 1
SET cd.contactPhone = LEFT(p.valuetext, 100)          -- col is varchar(100); active max 57 (Q6)
WHERE cd.IsDeleted = 0;

-- A2. contactEmail
UPDATE contactdetails_tbl cd
JOIN (
  SELECT contactID, valuetext,
         ROW_NUMBER() OVER (PARTITION BY contactID ORDER BY primary_YN DESC, itemID ASC) rn
  FROM   contactitems_tbl
  WHERE  valueCategory='Email' AND itemStatus='Active' AND IsDeleted=0
    AND  TRIM(COALESCE(valuetext,'')) <> ''
) e ON e.contactID = cd.contactID AND e.rn = 1
SET cd.contactEmail = LEFT(e.valuetext, 150)          -- varchar(150); active max 104 (Q6)
WHERE cd.IsDeleted = 0;

-- A3. contactCompany (uses valueCompany, not valuetext)
UPDATE contactdetails_tbl cd
JOIN (
  SELECT contactID, valueCompany,
         ROW_NUMBER() OVER (PARTITION BY contactID ORDER BY primary_YN DESC, itemID ASC) rn
  FROM   contactitems_tbl
  WHERE  valueCategory='Company' AND itemStatus='Active' AND IsDeleted=0
    AND  TRIM(COALESCE(valueCompany,'')) <> ''
) c ON c.contactID = cd.contactID AND c.rn = 1
SET cd.contactCompany = LEFT(c.valueCompany, 255)     -- varchar(255); active max 174 (Q6)
WHERE cd.IsDeleted = 0;

COMMIT;
```
Notes:
- `LEFT(...,n)` is belt-and-suspenders vs the source `valuetext` being `TEXT`; measured maxes fit,
  so no real truncation — but it guarantees no strict-mode abort mid-run.
- Contacts with no item in a category are simply left NULL (JOIN misses them) — correct.
- `_src` columns untouched — they remain `'user'` (V3_7 default), which is right: these values came
  from the user's own items. `'master'` is only stamped later when master linkage overrides a value.
- `itemStatus`/collation is `utf8mb4_unicode_ci` (case-insensitive), so `'Active'` also matches the
  view's lowercase `'active'` Company predicate — no casing hazard.

### Part A validation (run after)
```sql
SELECT
  SUM(contactPhone   IS NOT NULL) AS phone_filled,
  SUM(contactEmail   IS NOT NULL) AS email_filled,
  SUM(contactCompany IS NOT NULL) AS company_filled,
  COUNT(*)                        AS total_active
FROM contactdetails_tbl WHERE IsDeleted = 0;
-- Sanity: filled counts must be <= number of contacts having >=1 active item in that category.
```

---

## 3. Part A rollback (DRAFT)
```sql
UPDATE contactdetails_tbl
SET contactPhone = NULL, contactEmail = NULL, contactCompany = NULL
WHERE IsDeleted = 0;      -- _src stays 'user'; columns themselves are dropped by V3_7 rollback if needed
```

---

## 4. Part B — master linkage (DECISION REQUIRED before drafting to final)

Populating `master_co_contact_id` / `master_coid` / `company_location_id` requires **matching a TAO
contact to a master person**. This is the crux and it needs your call, because a wrong key mass-links
the wrong people (we just saw how noisy fuzzy matching is on the email dimension).

**Candidate match keys (recon):**
1. **`imdbid` (RECOMMENDED, deterministic):** both sides carry it — `contactdetails.imdbid`
   varchar(50) and `co_contacts.imdbid` (Q15: co_contacts is **100% populated** with imdbid). Exact
   match on a stable external ID = high confidence, no fuzz. Caveat: only links TAO contacts that
   *have* an imdbid (unknown coverage on `contactdetails` — a pre-flight count is in the checklist).
   Handle duplicate imdbid in co_contacts with `ROW_NUMBER() … ORDER BY id` (lowest id wins) + report.
2. **Name (`contactFullName` ↔ `co_contacts.fullname`):** wide coverage but fuzzy and collision-prone
   (homonyms, agency inboxes lesson). **Not recommended as the primary key**; at most a second, lower-
   confidence pass, itself gated.

**If imdbid is chosen, the linkage shape (draft, NOT approved):**
```sql
-- B1. link person by imdbid (lowest-id wins on dup); stamp coid + sync dates
UPDATE contactdetails_tbl cd
JOIN (
  SELECT id, coid, imdbid,
         ROW_NUMBER() OVER (PARTITION BY imdbid ORDER BY id ASC) rn
  FROM   co_contacts WHERE TRIM(COALESCE(imdbid,'')) <> ''
) cc ON cc.imdbid = cd.imdbid AND cc.rn = 1
SET cd.master_co_contact_id = cc.id,
    cd.master_coid          = NULLIF(cc.coid, 0),     -- coid is a 0-sentinel (Q15) -> NULL, not 0
    cd.master_linked_date   = NOW(),
    cd.master_last_sync     = NOW()
WHERE cd.IsDeleted = 0 AND TRIM(COALESCE(cd.imdbid,'')) <> '';

-- B2. default office for the linked company (no primary-office flag -> MIN(colocid), memory rule)
UPDATE contactdetails_tbl cd
JOIN (SELECT coid, MIN(colocid) AS default_loc FROM co_locations GROUP BY coid) loc
  ON loc.coid = cd.master_coid
SET cd.company_location_id = loc.default_loc
WHERE cd.master_coid IS NOT NULL;
```

**Open decisions for Part B (need your answers):**
- **D1 — match key:** imdbid-only (recommended), or imdbid + a gated name pass? 
- **D2 — `master_coid` 0-sentinel:** store `NULL` when co_contacts.coid=0 (recommended, drafted), or keep 0?
- **D3 — provenance:** does master linkage OVERWRITE a user's hot field (and flip `_src` to `'master'`),
  or only fill where the user's value is blank? (A1 said user wins — so recommend **fill-blank-only**,
  never overwrite a non-null user value; `_src` stays `'user'` for user values, `'master'` only where
  master supplied a previously-empty value.) This interacts with Part A ordering.
- **D4 — dup imdbid in co_contacts:** lowest-id-wins (drafted) + a report of collisions, acceptable?

---

## 5. What this gates
- **V3_9 (FKs):** after Part B runs on dev, run V3_9's pre-flight orphan/sentinel checks
  (master pointers must reference live PKs or be NULL). With B2's `MIN(colocid)` and B1's real
  `co_contacts.id`, they should be clean; the `NULLIF(coid,0)` avoids a 0→companies orphan. Then apply FKs.
- **Prod promotion:** unchanged — separate deploy auth; re-run V3_8 STOP-on-delta.

---

## 6. STOP
No writes performed. **Part A** is ready to execute on your go (deterministic, low risk).
**Part B** needs decisions D1–D4 first. On approval I formalize the approved parts as
`V3_10__master_directory_wo1_backfill.sql` (+ROLLBACK), dev-first, with the validation block inline.
