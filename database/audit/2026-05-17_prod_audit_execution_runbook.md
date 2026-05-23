# Prod DB Audit — DBA Execution Runbook

Status: scripts SHIP-gated (tao-gatekeeper, round 2). **Nothing executed yet.**
Order: dev (`new_development`) → smoke-test → prod (`actorsbusinessoffice`) → observe ≥2 weeks → (separate) DROP phase.

---

## Step 1 — Capture pre-state on prod (read-only, MCP-safe)

```sql
SELECT TABLE_NAME, TABLE_ROWS
FROM information_schema.TABLES
WHERE TABLE_SCHEMA='actorsbusinessoffice'
  AND TABLE_NAME IN ('clubs','clubmembers','clubgrades','projconxref_tbl','useradmin_tbl',
    'userlinks_tbl','ipn_log','importtest','import-contacts','_audprojects_crosslist_snapshot_20260506',
    'pgpanels_user_xref_delete','shares_old','sharez_old',
    'events_tbl_backup','audprojects_unionid_remap_20260505',
    'audunions_pre_consolidation_20260505','useradministrator_tbl');
```
Paste output as **PRE**. After execution, re-run and confirm the same row counts appear under `_zzq_20260517_*` (rename preserves rows).

---

## Step 2 — Dev run

```bash
mysql -h 46.31.66.114 -u admin -p new_development < database/migrations/2026-05-17_audit_drop_redundant_indexes.sql
mysql -h 46.31.66.114 -u admin -p new_development < database/migrations/2026-05-17_audit_quarantine_dead_tables.sql
```
Paste every `DROPPED:/SKIPPED:/QUARANTINED:` result row plus the final `status` rows.

**Idempotency proof:** re-run both scripts; second run must be all `SKIPPED`.

---

## Step 3 — Dev smoke-test (record URL + HTTP + outcome for each)

- Contacts list/search (`/app/contacts/`)
- Notifications dashboard (`/app/notifications/` or wherever surfaced)
- Auditions list (`/app/auditions/`)
- Import wizard landing (`/app/contacts-import-v3/`)
- Share-token link resolution (any active `/share/...`)

Grep CF logs for `1146 doesn't exist` and `unknown table` — must return nothing new.

---

## Step 4 — Pre-prod: archive the 4 non-empty quarantine objects

```bash
mkdir -p archive
mysqldump -h 46.31.66.114 -u admin -p actorsbusinessoffice events_tbl_backup                     > archive/events_tbl_backup_20260517.sql
mysqldump -h 46.31.66.114 -u admin -p actorsbusinessoffice audprojects_unionid_remap_20260505    > archive/audprojects_unionid_remap_20260505_20260517.sql
mysqldump -h 46.31.66.114 -u admin -p actorsbusinessoffice audunions_pre_consolidation_20260505  > archive/audunions_pre_consolidation_20260505_20260517.sql
mysqldump -h 46.31.66.114 -u admin -p actorsbusinessoffice useradministrator_tbl                 > archive/useradministrator_tbl_20260517.sql
ls -lh archive/*_20260517.sql   # all four must be non-zero
```

Then in a **prod-only working copy** of `2026-05-17_audit_quarantine_dead_tables.sql`, uncomment the four GATED `CALL` lines. **Do not commit the uncommented version** — the dev script must stay archive-gated.

---

## Step 5 — Prod run

```bash
mysql -h 46.31.66.114 -u admin -p actorsbusinessoffice < database/migrations/2026-05-17_audit_drop_redundant_indexes.sql
mysql -h 46.31.66.114 -u admin -p actorsbusinessoffice < <prod-only-uncommented quarantine script>
```
Paste all result rows + status. Re-run Step 1 query, paste **POST**. Diff must show: original names absent, `_zzq_20260517_*` names present with identical row counts.

---

## Step 6 — R7 `tao_*` consolidation (optional, gated)

Run the two verification queries embedded in the quarantine script header. **Both must pass:**
1. `regions`/`countries` populated; `tao_regions`/`tao_countries` are near-duplicate.
2. Zero views reference `tao_regions`/`tao_countries`.

If both pass, archive then manually `RENAME TABLE tao_regions TO _zzq_20260517_tao_regions;` (same for `tao_countries`).

---

## Step 7 — Observation window (≥ 2 weeks)

- Watch CF logs daily for `1146` / `unknown table` / `_zzq_20260517_*`.
- Note any user-reported regressions. If any, run the ROLLBACK scripts (idempotent) to restore the quarantined names instantly.

**DROP phase is a SEPARATE migration**, written only after the observation window closes clean. Calendar date eligible: **2026-05-31** (14 days from 2026-05-17).

---

## Rollback (any time)

```bash
mysql ... < database/migrations/2026-05-17_audit_quarantine_dead_tables_ROLLBACK.sql
mysql ... < database/migrations/2026-05-17_audit_drop_redundant_indexes_ROLLBACK.sql
```
Both idempotent. Index ROLLBACK recreates exact column-for-column definitions (Appendix A in `_phase1.md`).

---

## What this runbook does NOT cover

- Orphan cleanup (R1) — diagnostic only; owner sign-off required.
- `exttypes` silent-bug (R2) — route to AuditionMedia owner; separate functional fix.
- DEFINER→INVOKER view conversion (R8) — defer to Go.
- Import-subsystem consolidation, FK-less core integrity, retention policy on `bigbrother`/`errors_tbl` (R10–R12) — Go-redesign inputs.
