# PROD SCHEMA DRIFT REPORT — new_development (dev) vs actorsbusinessoffice (prod)

**Workstream:** PROD-SCHEMA-SYNC
**Date:** 2026-08-29
**Author:** Claude Code (read-only discovery; nothing run against prod)
**Server:** MySQL 8.0.41 (single host `www.theactorsoffice.com:3306`, both schemas)
**Channel:** pymysql read-only, `information_schema` SELECT only (metadata; no data reads, no writes, no DDL)
**Capture:** `scratchpad/capture/*.json` — 615 table/view rows, 5,702 columns, 1,124 index rows, 105 FK rows, 177 views, 15 routines, 0 triggers.

---

## HEADLINE — READ THIS FIRST

The relay CONTEXT block predicted three prod-missing DIR-LNK objects: `master_audit_tbl`, the
`master_correction_requests_tbl`, and the `contactdetails_tbl._src` columns. Live probe **refutes two of
the three**:

| Expected prod-missing | Actual prod state (verified 2026-08-29) |
|---|---|
| `master_audit_tbl` | **MISSING on prod** — dev-only. THE real gap. |
| `master_correction_requests_tbl` | **MISSING on prod** — dev-only. THE real gap. |
| `contactdetails_tbl._src` columns (`contactCompany_src` etc.) | **ALREADY ON PROD** — all 4, `enum('user','master') NOT NULL DEFAULT 'user'`, identical to dev. Landed with WO-1 (V3_7/V3_8/V3_9, 2026-07-08). |
| Auditions Tier-1 index (C2, "written-not-applied") | **ALREADY ON PROD** — both `idx_aax_project_contact` and `idx_cd_user_fullname` present, identical columns. The 2026-07-09 perf migration was since applied to prod. |

**Net: the entire authoritative WO-8 prod-promotion schema prerequisite is TWO empty tables.**
`contactdetails_tbl` is column-identical (44/44) between dev and prod; `contactitems_tbl` is
column-identical (21/21). Everything else flagged below is unrelated drift from other workstreams
(auditions, tooling, backups, caches) or the WO-12 view cutover — none of it is a WO-8 dependency.

---

## 1. TABLE ENUMERATION

Base tables: **dev 229 / prod 209**. Views: **dev 90 / prod 87**.

### (a) BASE TABLES in dev, MISSING in prod (25) — categorized

| Category | Tables | Port to prod? |
|---|---|---|
| **DIR-LNK / WO-8 (THE gap)** | `master_audit_tbl`, `master_correction_requests_tbl` | **YES — this migration** |
| Auditions feature (separate WO) | `audition_notifications`, `audition_requests_raw`, `lac_auditions`, `lac_notifications` | No — auditions workstream |
| Perf/cache tables | `cache_contact_last_event`, `cache_contact_meeting_counts`, `sharez_cache` | No — perf workstream, evaluate separately |
| Reference/geo (see note) | `tao_countries`, `tao_regions` | No — see §1(b): prod archived these to `_zzq_*` |
| Dev tooling / qry-elimination metadata | `components`, `functions`, `functions_backup`, `models`, `qry_types`, `sql_types`, `tao_tables`, `tao_files`, `cfqueryparam_matrix` | No — dev-only tooling |
| Webhook/integration | `court_webhook_data` | No — separate integration |
| Share feature | `shareviews` | No — share workstream (FK to `sharetokens`) |
| Dated backup / remap scratch | `_audprojects_unionid_remap_20260506`, `_audunions_dev_remap_20260506`, `tickets_tbl_old` | **No — backups; never port** |

### (b) BASE TABLES in prod, not in dev (5) — REPORT ONLY, do not touch

`admin_enums`, `auditions_tbl`, `events_tbl_backup`, `_zzq_20260517_tao_countries`,
`_zzq_20260517_tao_regions`.

- `auditions_tbl` is a **live prod table with 6 FK constraints** (see §3) — a real prod object dev lacks.
- `_zzq_20260517_tao_countries` / `_zzq_20260517_tao_regions` are prod's **archived/renamed** copies of
  what dev calls `tao_countries` / `tao_regions`. This is a geo-reference reorganization that diverged
  between the two schemas — a separate reconciliation, NOT part of WO-8.
- `events_tbl_backup`, `admin_enums` = prod-side objects; leave as-is.

### (c) Views: dev-only (5) — `function_tables`, `sharez_optimized`, `unique_functions`,
`view_conditions`, `view_conditions_final`. Prod-only (2) — `_zzq_20260517_shares_old`,
`_zzq_20260517_sharez_old` (archived). None are WO-8 objects. `sharez_optimized` is dev-only and
unconsumed per the WO-5 record. If any dev-only view is ever ported, its body **must be re-qualified**
(see §4 hazard).

---

## 2. COLUMN-LEVEL DRIFT (shared base tables)

**DIR-LNK tables are clean:** `contactdetails_tbl` 44/44 identical, `contactitems_tbl` 21/21 identical,
including all four `_src` columns already present on prod. **No WO-8 column work is required.**

All other column drift is unrelated and **report-only** (none blocks WO-8):

| Table | Drift | Note |
|---|---|---|
| `audgenres_audition_xref` | dev `audroleid` vs prod `audroleID` | Case-only rename; MySQL identifiers are case-insensitive → cosmetic. |
| `auditionsimport_error` | dev adds `created_at`; `id` dev NOT NULL/prod NULL; `error_msg` dev varchar(500)/prod varchar(100) | Auditions-import workstream. |
| `audprojects` | dev adds `payratex`,`buyoutx`,`conflict_notes_delete`,`conflict_enddate_delete`; prod has `payrate` | Auditions workstream; note dev/prod took different column paths. |
| `audplatforms_user_tbl` | `isDeleted` dev NULL / prod NOT NULL DEFAULT b'0' | Prod is the stricter/safer shape. |
| `audunions`, `audunions_pre_consolidation_*` | `countryid`/`audCatID` nullability differs | Auditions consolidation workstream. |
| `companies`,`notifications_tbl`,`questions` | dev `mediumtext` vs prod `longtext` | **Prod is WIDER (ahead), not behind** — leave. |
| `itemtypes_user_tbl` | `typeID` dev `smallint`/prod `int` AUTO_INCREMENT | Cosmetic capacity diff; prod wider. |
| `tags` | `tagPriority` dev NOT NULL DEFAULT 9999 / prod NULL DEFAULT 999 | Report only. |
| `taousers_tbl` | `userEmail`,`datePrefID` dev NOT NULL/prod NULL; `region_id` dev DEFAULT 3911/prod NULL | Dev tightened defaults; prod is looser. Report only. |

None of these are additive-into-prod items for this WO. Several (mediumtext→longtext, smallint→int) are
**prod ahead of dev**, i.e. drift in the other direction.

---

## 3. INDEX / KEY / FK DRIFT (shared base tables)

### Tier-1 auditions perf index (C2) — RESOLVED: already on prod
Source of truth: `database/migrations/2026-07-09_auditions_perf_indexes.sql`.
- FIX A `idx_aax_project_contact (audprojectid, contactid)` on `audcontacts_auditions_xref` — **PRESENT on prod.**
- FIX B `idx_cd_user_fullname (userID, contactFullName)` on `contactdetails_tbl` — **PRESENT on prod.**
The memory note "written but NOT applied" is stale; both are live on prod. **No action.**

### Dev-only indexes that are REDUNDANT (do NOT port)
- `audcontacts_auditions_xref.idx_audcontacts_xref_contactid (contactid, audprojectid)` — duplicate of
  the existing `idx_audcontacts_auditions_xref (contactid, audprojectid)` in both schemas.
- `audroles.idx_audroles_project_deleted (audprojectID, isDeleted)` — duplicate of prod's existing
  `idx_ar_project_deleted (audprojectID, isDeleted)`.

### Dev-only indexes genuinely absent on prod (OPTIONAL perf group — §6 Section 3, NOT WO-8)
`audprojects.idx_audprojects_deleted_date (isDeleted, projDate)`;
`events_tbl.idx_events_id_start (eventID, eventStart, eventTypeName)`;
`contactdetails_tbl` composites (`idx_contactdetails_tbl_contactid`, `_isdeleted`, `_user_deleted`,
`_userid`, `_userid_deleted`, `idx_contactdetails_userid_contactid`);
`contactitems_tbl.idx_contactitems_lookup (contactID, valueCategory, itemStatus)`;
`eventcontactsxref_tbl.idx_eventcontactsxref_contact`;
`noteslog_tbl` composites (3);
`tickets_tbl.idx_tickets_active_user_status_priority_type_ver_created`.
These are additive/safe but belong to a **perf-tuning review**, not WO-8. Prod also carries its own
composites dev lacks (e.g. `contactdetails_active_date`, `fusystemusers…contact_system_start`,
`events…contact_status_type_start`) — index tuning diverged both ways.

### FK constraints — REPORT ONLY
Dev FKs 51 / prod FKs 52. Divergence tracks the table divergence above:
- **Prod-only FKs** (dev lacks): 5 on `auditions_tbl` (prod-only table), `FK_audroles_audprojects`,
  `FK_unions_countries`, `_zzq_20260517_tao_regions_ibfk_1`.
- **Dev-only FKs** (prod lacks): all on dev-only tables — `shareviews`, `import_job_rows`, `tao_files`,
  `functions`, `lac_notifications`, `tao_regions`. They arrive only if those (out-of-scope) tables are
  ever ported.
- **The two WO-8 tables have NO foreign keys** (by design — audit history outlives deleted referents),
  so promotion has no parent-ordering dependency.

---

## 4. VIEW DRIFT

Shared views: 85. **Genuinely-differing bodies (8):** `contacts_ss`, `contacts_ss_followup`,
`contacts_ss_maint`, `contacts_ss_target`, `sharez`, `sharezz`, `v_contacts_optimized`, `pgcomps`.

The first seven are exactly the **WO-5 read-cutover family** — dev was repointed to the master-managed
primary columns; **prod still runs the old inline item-subquery definitions.** Flipping them on prod is
the **WO-12 atomic operation** (64,653-row backfill → prod view flip, DEFINER→INVOKER; ref `beb6c4c0`).
It is **NOT additive**, changes read results, and **is explicitly OUT OF SCOPE** of this migration.
`pgcomps` differs too — verify separately; not a WO-8 dependency.

**Schema-qualifier hazard check (item 4):**
- **No prod view references `new_development`.** Zero cross-schema leaks in prod today. Good.
- Every *dev* view self-references `new_development` only because `information_schema` fully-qualifies
  the current schema in `VIEW_DEFINITION` — this is normal, not a defect. **But it is the live trap:**
  any dev view ported to prod (or any prod view rebuilt from a dev capture) must have the
  `new_development.` qualifier stripped, or prod would read dev data. This migration ports **no views**,
  so the trap is not triggered here; it is a standing rule for WO-12 and any future view port.

---

## 5. STORED ROUTINES / TRIGGERS

- **Triggers:** 0 in both schemas. Nothing to sync. (Consistent with the DIR-LNK "no triggers" ruling.)
- **Routines:** 15 total; identical set names across schemas — **no routine drift.** No dev-only routine
  to promote. (The `AddIndexIfNotExists`/`AddColumnIfNotExists` helpers used by migrations are created
  and dropped within their scripts, so they do not persist as drift.)

---

## 6. FORWARD MIGRATION (authored, NOT run)

**File:** `database/migrations/2026-08-29_wo8_prod_promotion_master_audit_correction.sql`

Grouped by feature so subsets can be chosen:
- **Section 1 — WO-8 objects (the only DDL that changes prod):** `CREATE TABLE IF NOT EXISTS`
  `master_audit_tbl` and `master_correction_requests_tbl`, **verbatim from the reviewed V3_12** DDL
  (utf8mb4_unicode_ci, no FKs, no triggers, generated `active_guard` column + partial-unique dedup).
  Ordered correctly (no interdependency; correction table references no parent). Idempotent.
- **Section 2 — already-present verification (guarded no-ops):** guarded `ADD COLUMN`/`CREATE INDEX`
  for the four `_src` columns and the two Tier-1 indexes. These **already exist on prod** as of
  2026-08-29; the guards make the block a documented no-op and let the operator run the whole file safely.
- **Section 3 — OPTIONAL other perf indexes (commented OUT by default):** the genuinely-absent dev perf
  indexes from §3. Operator opt-in only; NOT a WO-8 dependency; must EXPLAIN-verify per environment.

Strips any `new_development` qualifier (none needed — no views/qualified refs in Section 1). Every add
is guarded via the house `AddIndexIfNotExists`/`AddColumnIfNotExists` procedure pattern.

## 7. ROLLBACK

**File:** `database/migrations/2026-08-29_wo8_prod_promotion_master_audit_correction_ROLLBACK.sql`

- Section 1 reverse: `DROP TABLE IF EXISTS` for both tables. **REVERSIBILITY FLAG:** cleanly reversible
  ONLY while the tables are empty (i.e. rolled back before any WO-8 code writes audit/correction rows on
  prod). Once rows are written, DROP permanently destroys audit history — treated as a two-stage,
  named-authorization destructive rollback (mirrors V3_12's split; precheck counts first).
- Section 2 reverse: **NONE — DO NOT DROP.** The `_src` columns and Tier-1 indexes predate this
  migration and are in active use by deployed prod code; dropping them would break prod. Explicitly
  flagged non-reversible / must-not-touch.
- Section 3 reverse: guarded `DROP INDEX` for whichever optional indexes were applied.

---

## 8. RISK CALL

### (a) Safe additive vs needs care
- **SAFE ADDITIVE (Section 1):** two brand-new, empty, FK-less InnoDB tables. No lock on existing
  tables, no data movement, idempotent, reversible-while-empty. Lowest-risk class of DDL. Can be applied
  during business hours.
- **NO-OP / ALREADY PRESENT (Section 2):** `_src` columns + both Tier-1 indexes. No action needed;
  guards prove it.
- **NEEDS CARE / OUT OF SCOPE:**
  - WO-12 view cutover (8 views) — requires the 64,653-row backfill first; changes read results; NOT
    additive; separate atomic operation.
  - Other dev-only tables (auditions/court/lac/cache/tooling/backup) — separate workstreams; several
    (backups, remap scratch, dev tooling) should **never** go to prod.
  - Column type/nullability diffs — mostly cosmetic or prod-ahead; leave.
  - `tao_countries`/`tao_regions` vs prod's `_zzq_*` archives — a geo-reference reorg needing its own
    reconciliation.
  - Redundant dev-only indexes — do not port.

### (b) Does deploying A1 (the Book-UI prod-gate) REQUIRE this schema change?

**NO. A1 is fully independent. Confirmed by reading the gate (commit `c213a4d8`,
`include/contact_info.cfm`).** A1 is a pure hostname check —
`masterBookEnabled = ( ListFirst(cgi.server_name,".") NEQ "app" )` — that (1) hides the entire Book UI
band on prod and (2) short-circuits the WO-8 on-read `syncLinkedContact` call so it never fires on prod.
Its whole purpose is to gate the Book **OFF** prod precisely *because* `master_audit_tbl` and
`master_link_preview.cfm` are absent. A feature that gates something off cannot depend on the very
objects it is gating out. **A1 can and should be deployed with no schema migration.**

Therefore the schema migration is a **separate WO-8-prod-promotion prerequisite**, needed later to
*remove* the A1 gate and turn the Book on for prod — not to deploy A1 now.

**One caveat, surfaced from the A1 commit comment (not schema, but part of the eventual promotion):** the
gate documents a *second* prod dependency — `/include/master_link_preview.cfm` **is not deployed to
prod** (GET → 404). That is a code/file-deploy gap, out of scope for this schema report, but it must be
resolved alongside the two tables before the A1 gate is lifted. WO-8 prod promotion = **this 2-table
migration + deploy of the WO-8 code files + gate removal**, executed as one reviewed sequence.

---

## HOLDS
- Nothing was run against prod. All findings are from `information_schema` SELECTs (read-only metadata).
- The forward + rollback scripts are **authored for line review only — unexecuted, unpushed.**
- No DDL/DML on either schema. Deliverables are docs/SQL for review.
