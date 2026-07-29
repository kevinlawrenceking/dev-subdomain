# DIR-LNK-WO-8 — P4 DEPLOY + P5 ACCEPTANCE RUNBOOK

**Work order:** DIR-LNK-WO-8 (master auto-sync for linked contacts). **Branch:** dev · **Spec MD5:** 078d926d.
**Status:** WO-8 v1 CODE-COMPLETE (local); this runbook prepares P4 (push+deploy, gated) and P5 (acceptance).
**Gates:** no push without a named PUSH GO; no deploy without the operator executing D-17 with the rollback pin in hand. This document is docs-class and commits without pushing.

---

## 0. ROLLBACK PIN (captured FIRST, before any deploy)

**Live dev = `origin/dev` HEAD = `05b20a1696a7d2ea6a6301a46baada2a6a108ddd`** (the WO-7 close). This is the rollback target: if the WO-8 deploy misbehaves, redeploy this SHA.

- Post-push target HEAD = **`5287f3e5d5708bfb7c2c4f5caf7a992489fb07ef`**.
- Push set (`05b20a16..HEAD`, 7 commits, oldest→newest): `3c2dd63b` (lock) · `1b944cd8` (P1) · `be558b49` (P2) · `45e9152a` (Q9) · `51ef9338` (Stage 1 helper) · `7e586e21` (Stage 2 writer/audit) · `5287f3e5` (Stage 3 hook/sweep) — plus this runbook commit.
- **NO DDL** in the set (recon proved none needed): `MASTER_AUTO_UPDATE` is governed (V3_12), `run_id` column exists. Rollback is code-only (redeploy the pin); no schema to unwind.

---

## 1. P4 — DEPLOY (each step operator-executed; gated)

1. **Named PUSH GO required.** On a standalone PUSH GO instrument naming range `05b20a16..5287f3e5` + this runbook commit, push to `origin/dev`. (SR-1: title/"then push"/manifests do not authorize.)
2. **Pre-deploy:** confirm rollback pin `05b20a16` recorded; `git ls-remote origin dev` to confirm the live SHA before the pull.
3. **D-17 deploy on dev:** pull to the dev webroot; clear the CF template/component cache (or restart the CF service) so the changed `.cfc`/`.cfm` recompile; then a **liveness probe**: open a LINKED contact's panel (e.g. contactid 132142) and confirm it renders (the on-read hook must not error).
4. **Post-deploy sanity:** tail `master_sync` log for the on-read `SYNC ...` line on that view; confirm no `on-read sync FAIL`.
5. Rollback path: redeploy `05b20a16` (pull the pin, clear cache) — no data migration to reverse.

---

## 2. P5 — ACCEPTANCE (dev, evidence-cited, A-5 discipline)

### 2.0 A-5 fixture discipline (binding)
- **Baseline FIRST** (§2.1), before any fixture.
- **Register EVERY fixture** (contactid) AND **EVERY master-side test edit** (table, PK, column, old→new) in §2.12.
- Master data is static (no edit path), so several arms require a **direct dev-DB edit to `co_locations` / `co_contacts` / `companies`** to manufacture drift. That is a **legitimate P5 fixture-setup action** (lock §5: DML permitted for P5 fixtures) — but every such edit MUST be registered and **reverted**, and cleanup-to-baseline proven (§2.11). These edits are on `new_development` only; **prod is never touched**.
- `master_audit_tbl` is append-only and will grow — it is **not** expected to restore; every other counter must return to baseline.

### 2.1 Baseline capture (run at P5 start; do NOT assume WO-7 numbers)
```sql
-- Counters (record verbatim)
SELECT (SELECT COUNT(*) FROM contacts_ss)                                                   AS ss_rows,
       (SELECT COUNT(*) FROM contactdetails_tbl WHERE (isdeleted=0 OR isdeleted IS NULL))   AS active_contacts,
       (SELECT COUNT(*) FROM contactitems_tbl  WHERE IsDeleted=0)                            AS item_rows,
       (SELECT COUNT(*) FROM contactdetails_tbl
          WHERE master_co_contact_id IS NOT NULL AND (isdeleted=0 OR isdeleted IS NULL))     AS linked_total,
       (SELECT COUNT(*) FROM master_audit_tbl)                                               AS audit_rows,
       (SELECT COUNT(*) FROM master_audit_tbl WHERE action_type='MASTER_AUTO_UPDATE')        AS auto_update_rows;  -- expect 0 pre-P5
-- Audit decomposition
SELECT action_type, COUNT(*) FROM master_audit_tbl GROUP BY action_type ORDER BY 2 DESC;
```
Expected pre-P5: `auto_update_rows = 0`, `linked_total = 16` (per P1; re-confirm).

### 2.2 Matrix (each row: setup → action → assert → revert)

| # | Criterion | Setup | Action | PASS assertion | Revert |
|---|-----------|-------|--------|----------------|--------|
| a | **COMPARE-update** | Pick a full-snapshot link (132142 → office colocid 5175). Record current `co_locations.phone`. Edit it: `UPDATE co_locations SET phone='+1 999 000 1111' WHERE colocid=5175;` (register old→new) | View 132142's panel (fires on-read sync) | `contactdetails_tbl.contactPhone`=new value, `contactPhone_src='master'`; exactly ONE `MASTER_AUTO_UPDATE` row, `field_name='contactPhone'`, `old_value`→`new_value`, `run_id` set; `contacts_ss` reflects it | restore `co_locations.phone` to old; re-view → syncs back |
| b | **SKIP (derive-or-skip; data-loss-hole proof)** | On a fixture link, point the office at a missing row: `UPDATE contactdetails_tbl SET company_location_id=99999999 WHERE contactid=<fx>;` (register) — office row will not resolve (`colocResolved=false`) | View the panel + run the sweep | contactPhone/contactEmail **UNCHANGED**, **NOT blanked**; ZERO `MASTER_AUTO_UPDATE` for those fields. (Also: set `master_co_contact_id` to a missing id to exercise `found=false` → whole-contact skip, `master_sync` warning logged) | restore `company_location_id` (and `master_co_contact_id`) to originals |
| c | **MIRROR / Q9=(a) — email/phone** | Link a fixture contact to an office that HAS a phone; sync it (phone `_src='master'`, populated). Then blank the office field on the EXISTING row: `UPDATE co_locations SET phone='' WHERE colocid=<office>;` (register) | View the panel | office row still resolves (`colocResolved=true`) → `contactPhone` mirrored to **NULL** `_src='master'`; ONE `MASTER_AUTO_UPDATE`, `old_value`=phone, `new_value` NULL | restore `co_locations.phone` |
| c2 | **MIRROR / Q9 — company (cc_coid=0 path)** | Link a fixture contact to a master person with **no company** (`co_contacts.coid=0`, e.g. person 40). Its `companyResolved=true`, `coName=''` | Link then view | `contactCompany` mirrored blank `_src='master'`; `MASTER_SNAPSHOT_POPULATED` at link (blank), sync no-ops thereafter | unlink + delete fixture |
| d | **BLANK-RESOLVES / Q12 (headline)** | Link a fixture contact to an office with **blank email** (Q4 mirror → `contactEmail` NULL `_src='master'`). Then populate it: `UPDATE co_locations SET email='new@office.com' WHERE colocid=<office>;` (register) | View the panel | `contactEmail` FILLS to `new@office.com` `_src='master'`; ONE `MASTER_AUTO_UPDATE`, `old_value` NULL → `new_value`=email | restore `co_locations.email` to blank |
| e | **ZERO-WRITE / L-5 (chatter proof)** | A current linked contact (132142, unedited) | Capture `auto_update_rows` + `item_rows`; view the panel; capture again | counts **IDENTICAL** before/after (no UPDATE, no `MASTER_AUTO_UPDATE`); the unchanged path is 3 SELECTs, zero writes | none |
| f | **_src='user' UNTOUCHED / Q10 scope** | A bridge link with `contactEmail_src='user'` / `contactPhone_src='user'` (e.g. 131075) | View its panel + run the sweep | the `_src='user'` fields are **never written**; only `_src='master'` fields are ever candidates | none |
| g | **BACKFILL** | current data (post any reverts) | Run `resyncAllLinked` via `POST /ajax/master/resyncall.cfm` (admin) | response `{scanned:16, synced:0, skipped:16, failed:0, fieldsWritten:0}` (no-op against current data); counts visible | none |
| h | **EPOCH INTEGRITY** | after the a/c/d `MASTER_AUTO_UPDATE` writes exist | run a WO-7 relink + double-unlink on a fixture link | relink + both unlinks succeed and audit at **distinct epochs**; `MAX(auditID)` advanced monotonically; no key collision (S-7/S-9 regression clean) | unlink + delete fixture |
| i | **ADMIN GATE (N-3)** | — | `POST /ajax/master/resyncall.cfm` as a non-admin, then as an admin | non-admin → 403 `{success:false, "Admin access required."}`; admin (`taousers.userRole` IN Admin/Administrator) → runs. (Confirms the gate is neither permanently-403 nor open) | none |

### 2.11 Cleanup + baseline restoration (prove EXACT)
- Revert every registered master-table edit (§2.12); unlink + delete every fixture contact; confirm no stranded pointers.
- Re-run §2.1. Assert `ss_rows / active_contacts / item_rows / linked_total` **identical** to baseline. `master_audit_tbl` grew (append-only) — record the delta, do not restore.
- Confirm `co_locations` / `co_contacts` / `companies` fixture rows are byte-restored (`SELECT` the touched PKs vs recorded originals).

### 2.12 Fixture + master-edit register (fill during P5)
| Kind | Ref (contactid / table.PK) | Field | Original | Test value | Reverted? |
|------|----------------------------|-------|----------|-----------|-----------|
| _(fill)_ | | | | | |

---

## 3. Notes carried in
- **N-2:** the SKIP/MIRROR arms are **unexercised by live data** (all 8 `_src='master'` company rows resolve; 0 dangling; 0 blank company names) — hence the constructed fixtures (b/c/c2/d) are mandatory, not optional.
- **L-5:** criterion (e) is the guard against a chattering write-on-GET hook.
- **N-3 register:** ~7 existing admin endpoints gate on the never-set `session.isAdmin` and are likely permanently-403; WO-8's endpoint uses the DB role check instead. Flagged for a separate hardening pass (not WO-8).
- Master-value edits for fixtures are the **only** sanctioned means to create drift (master data has no app edit path); each is registered + reverted (A-5).

## 4. STOP
Runbook committed docs-class (local). **P4 opens only on a named PUSH GO**; the operator executes D-17 with the rollback pin `05b20a16` in hand. Then P5 per the matrix, then P6 bundle. No push, no deploy from here.
