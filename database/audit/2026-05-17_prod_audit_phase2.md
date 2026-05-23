# Prod DB Audit — Phase 2: Code Cross-Reference + Integrity/Data-Quality

Date: 2026-05-17
Method: CFML repo grep (`*.cfm`/`*.cfc`) + `sched/` scan + read-only prod orphan/data-quality SELECTs.
No prod changes.

---

## 1. Index-drop safety — CLEARED

`grep -i '(FORCE|USE|IGNORE) INDEX'` across the entire CFML codebase: **zero matches.** No query pins any index. Therefore every redundant/duplicate index in Phase 1 §5 is **unconditionally safe to drop** (the only remaining rule — never drop an index backing an FK — was already applied in that list). This list is ready for a Phase 3 reversible migration following the repo `2026-04-03_drop_redundant_single_column_indexes` pattern.

---

## 2. Drop register — full 4-part evidence

Evidence pillars: **rows** (Phase 0), **frozen/dated**, **code refs** (CFML grep), **scheduled-task refs** (`sched/` grep). All below have **0 code refs and 0 sched refs**.

| Object | Rows | Why dead | Verdict |
|---|---|---|---|
| `_audprojects_crosslist_snapshot_20260506` | 0 | dated migration snapshot | DROP (archive first) |
| `audprojects_unionid_remap_20260505` | 1,483 | dated remap scratch (2026-05 audunions migration) | DROP after archive |
| `audunions_pre_consolidation_20260505` | 59 | dated pre-migration backup | DROP after archive |
| `events_tbl_backup` | 13,710 | frozen 2026-01-11 manual backup | DROP after archive |
| `shares_old`, `sharez_old` | (views) | superseded; **dev already lacks them** | DROP |
| `clubs`, `clubmembers`, `clubgrades` | 0 | abandoned feature, no refs | DROP |
| `projconxref_tbl` | 0 | no refs | DROP |
| `useradmin_tbl` (0), `useradministrator_tbl` (2) | 0/2 | legacy pair, no refs | DROP after archive |
| `userlinks_tbl` | 0 | no refs | DROP |
| `ipn_log` | 0 | no refs (IPN logs go elsewhere) | DROP |
| `importtest`, `import-contacts` | 0 | scratch; the `import-contacts` code hits are a *filename* coincidence (`include/import-contacts.cfm`), not the table | DROP |
| `pgpanels_user_xref_delete` | 0 | name literally says "delete"; no refs | DROP |

Quarantine procedure for Phase 3: `RENAME TABLE x TO _zz_drop_x` → observe ≥1–2 weeks → `DROP`. Archive non-empty ones (`events_tbl_backup`, the dated snapshots, `useradministrator_tbl`) via `mysqldump` first. All reversible until the final DROP.

**Duplicate reference data (consolidate, don't blind-drop):** `regions`(4,148) vs `tao_regions`(4,149); `countries`(239) vs `tao_countries`(240) — near-identical supersets, `tao_*` have **zero code refs**. Strong candidates to retire the `tao_*` copies, but Phase 3 must first confirm `regions`/`countries` are the live canonical set (and that no view selects `tao_*`).

---

## 3. KEEP — live-but-empty (NOT drop) + a real bug

- `viewtypes` (0 rows) — `LEFT JOIN`ed in `services/UserService.cfc:172`. Empty lookup the code expects; dropping breaks the join. Keep; seed data.
- **`exttypes` (0 rows) — silent-degradation bug.** `LEFT JOIN exttypes e ON e.mediaext=m.mediaext` appears **~14 times across `services/AuditionMediaService.cfc`**. The table is empty, so every media-extension type lookup yields NULL. This is a feature quietly returning blanks, not a drop candidate — flag to the AuditionMedia owner. (Severity: medium; functional, not structural.)
- 0-row tables that ARE code-referenced infrastructure (new/unused, not dead): `feature_flags`/`feature_flag_users` (referenced in `Application.cfc`, ContactImportV3/V2), `import_jobs`/`import_job_*` (referenced in `ajax/import/*`, import services), `contact_custom_fields`, `casting_notifications`. **Explicitly excluded from the drop register** — Phase 0's tentative inclusion was wrong; code proves them wired.

---

## 4. Referential integrity — orphan-row scan (FK-less core)

Integrity is app-enforced for the core (Phase 1 §2). Measured actual breakage:

| Relationship | Orphans | Read |
|---|---|---|
| contactitems → contactdetails | **0** | EAV core is clean |
| events → taousers | **1** | one event for a hard-deleted user (invisible to events_completed JOB C) |
| notifications → taousers | 0 | clean |
| eventcontactsxref → events | 0 | clean |
| eventcontactsxref → contactdetails | **21** | dangling contact refs |
| **funotifications → fusystemusers (suID)** | **1,690** | significant dangling reminders |
| **funotifications → fuactions (actionID)** | **256** | notifications citing non-existent action templates |
| fusystemusers → contactdetails | **13** | enrollments for deleted contacts |
| fusystemusers → taousers | 0 | clean |

**Pattern:** the contact/event core is essentially pristine; integrity debt is concentrated in the **relationship engine** (`funotifications`/`fusystemusers`) — 1,690+256+13 orphans. This is the same subsystem the `events_completed` cron drives. **Caveat / non-negotiable:** do **not** auto-delete these — some `suID`/`actionID` orphans may be intentional sentinels (e.g. `0`/NULL). Phase 3 deliverable = an *investigation* query (group orphans by suID/actionID value) + a proposed cleanup, reviewed by the relationship-system owner, not a blind DELETE.

---

## 5. Phase 2 → Phase 3 handoff

- **Ready to script (reversible, low risk):** Phase 1 §5 redundant-index drops (safety cleared here); the `regions`/`countries` ↔ `tao_*` consolidation (after canonical confirm); drop-register quarantine (rename→observe→drop, archive non-empty).
- **Needs owner sign-off before scripting:** funotifications/fusystemusers orphan cleanup (sentinel caveat); the `exttypes` empty-lookup bug (functional fix, separate from the audit).
- **Deferred to Go redesign:** 84+1 DEFINER→INVOKER view conversion; passthrough-view elimination; import-subsystem consolidation; replicating app-enforced integrity as real FKs.
- **Carried (not yet done):** exhaustive type-debt scan (varchar-stored dates/numerics across all 205 tables) — scoped as a Phase 3 input, deliberately not claimed complete here.
