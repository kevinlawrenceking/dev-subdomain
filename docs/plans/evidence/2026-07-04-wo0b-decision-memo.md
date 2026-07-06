# WO-0b Decision Memo — Master Contact Directory Phase 1

Prepared 2026-07-04 for Kevin. One page. Five parked product decisions from
`docs/plans/master-contact-directory-phase1.md` §12, each with a recommendation, the
evidence that now bears on it, and what it gates. **Photo policy first (gates WO-5).**
Evidence: abo (prod) pane landed; abod pane + `SHOW GRANTS`/`EXPLAIN` still pending.

---

## D-1 (§12.? Photo policy) — how do master photos land on a contact? **[gates WO-5 populate]**
**Recommendation: store the master photo URL directly in `contactPhoto` (no download-to-disk).**
- **Evidence (PROVEN, abo Q14):** every sampled `contactPhoto` value is already a full external
  IMDb URL (`https://m.media-amazon.com/images/M/...jpg`). The column is `varchar(255)`. The
  on-disk `avatar.jpg` + `avatar_yn` is a **separate** mechanism (mixed driver).
- **Why:** master people carry IMDb image URLs; writing that URL into `contactPhoto` matches the
  established convention with zero new plumbing. `contactPhoto_src` flags it `master`.
- **Watch:** some IMDb URLs may exceed 255 after resize params — spot-check longest master URLs
  when the abod/master data lands; widen to `varchar(500)` if needed. Keep the disk-avatar path
  untouched (user uploads still win via `contactPhoto_src='user'`).

## D-2 (§12.1 Schema location / FK strategy) — real FKs or soft FKs? **[gates WO-1, WO-3] — DECIDED**
**Decision: REAL same-schema foreign keys in prod (`actorsbusinessoffice`).** Soft-FK fallback dropped.
- **Evidence (all PROVEN):** master tables exist **in prod** and are **populated** — companies **10,740**,
  co_contacts **25,200**, co_locations **12,617** (G1); prod's `companies_ss` view already JOINs
  `companies`+`co_locations` (Q9a); app user `kingk436@%` holds `ALL PRIVILEGES` incl. `REFERENCES` on
  `actorsbusinessoffice` (Q9b). Co-located + populated + FK-privileged → real FKs are correct.
- **FK wiring RESOLVED (Q8):** `company_location_id INT → co_locations.`**`colocid`** (plan's "locid" was
  wrong); `master_co_contact_id INT → co_contacts.id`; `master_coid INT → companies.coid`. All PKs, all
  InnoDB → enforceable. WO-1 adds the INT cols; a follow-up ALTER adds the FKs. **Skip `idx_co_name`
  (coName already UNIQUE); master search indexes already exist (F11).**
- **`tao_development` caveat (F6):** three physical copies exist; prod is authoritative for Phase 1.
  Phase 2 scraper writes must target the prod copy (or a sync must feed it) or the FK'd data goes stale.

## D-3 (§12.3 Person vs company link target) — link to person, company, or both? **— DECIDED**
**Decision: person-first — link to `co_contacts.id`, derive `coid → companies.coid → co_locations` (default office); company-only contacts link straight to a `co_locations.colocid` office.**
- **Evidence (Q8/Q15):** `co_contacts` (PK `id`, 25,200 rows, 100% imdbid) carries `coid` (0-sentinel) → derive company. `co_locations` averages 1.27 offices/company (max 46) with **no primary flag** → default-office rule = `address1 IS NOT NULL AND <>''`, tie-break `MIN(colocid)`.
- **Data-quality caveats (F13):** `jobtitle_type` and `location` are dirty/contaminated — WO-5 must normalize `jobtitle_type` (trim/strip-newline/parse `(Category)`) and must **not** hard-depend on `location` as a search filter.

## D-4 (§12.4 "Refresh from master" in Phase 1) — manual pull vs scheduled?
**Recommendation: manual "Refresh from master" button only in Phase 1; scheduled propagation deferred to Phase 2.** Model C's per-field `_src` provenance makes manual refresh safe (only `master`-sourced fields update). No evidence changes this. **Confirm.**

## D-5 (§12.5 Company field semantics) — free-text + structured pointer, or structured-only?
**Recommendation: `contactCompany varchar(255)` free-text (always populated) + `company_location_id` optional structured pointer.**
- **Evidence (PROVEN, abo Q5/Q6):** company data is free-text and dirty today — `valueCompany` max
  174, `valueType` values like `Job`/`Casting Office`/one-offs. Forcing structured-only would strand
  ~28k existing free-text companies. Keep free-text authoritative, structured pointer optional.
- **Sizing (F3):** use `varchar(255)` to match source `valueCompany`, not the plan's 200.

---

## Cross-cutting facts now locked (affect every WO)
1. **`recordname` IS virtual-generated** (`= contactFullName`). WO-4 must never write it and must
   drop the 4 existing writers (F1) — same landmine as WO-G / wizard-P11.
2. **Timestamps = `DATETIME`** (not `TIMESTAMP`) for `master_linked_date`/`master_last_sync` (Q19).
3. **View rebuild is mandatory** post-ALTER — `contactdetails` enumerates 32 columns (Q2).
4. **Backfill needs a deterministic primary tie-break** — Phone alone has 7,644 multi-primary +
   4,337 zero-primary contacts (Q7). Recommend `ORDER BY primary_YN DESC, itemID ASC LIMIT 1`.
5. **`v_contacts_optimized` already exists** (CTE/ROW_NUMBER) — WO-6 should reuse/retarget it (F2).
6. **Reuse existing `imdbid`** column; don't add a master IMDb column (F4).
7. **FK targets:** `company_location_id → co_locations.colocid`, `master_co_contact_id → co_contacts.id`, `master_coid → companies.coid` — all PK, all InnoDB (F10). Skip `idx_co_name`; master indexes already exist (F11).
8. **Master data is dirty/unverified:** companies 100% `Unverified`; `jobtitle_type`/`location` need normalization; `co_contacts.coid` is a 0-sentinel; no primary-office flag (F12/F13).

**Status: all five decisions (D-1…D-5) DECIDED.** One-liners A/B landed; G1/G3 closed; Q8/Q15 PROVEN from prod. **Only open item:** the **dev-vs-prod hot-table DDL drift diff** (run the abod pane, diff vs abo) — a safety check on schema parity, not a decision blocker.
**Gate: no WO-1 until Kevin clears this memo. The abod drift pane can run in parallel; it gates migration-portability, not the design.**
