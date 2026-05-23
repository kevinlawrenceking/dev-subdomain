# Prod DB Audit — Phase 1: Schema Analysis (zero prod risk)

Date: 2026-05-17
Method: read-only `information_schema` on prod (`actorsbusinessoffice`) and dev (`new_development`), 46.31.66.114.
All findings are analysis only; no prod changes made.

---

## 1. HEADLINE: dev is NOT a trustworthy mirror of prod

Compared every object's column signature (`BIT_XOR(CRC32(col:type))`) and index signature across both schemas. Result: **bidirectional drift, including in CORE tables.** dev is neither a superset nor a clean copy of prod.

**Core tables whose schema differs dev vs prod (not just dev-only scratch):**

| Object | Drift |
|---|---|
| `audprojects` | prod **16 cols** vs dev **19 cols** — dev has 3 extra columns + different indexes |
| `notifications` / `notifications_tbl` | column signature differs (prod 1260350682 vs dev 2431627878) |
| `contactitems` / `contactitems_tbl` | signatures differ; in prod the view ≠ base table, in dev the view == base table (dev simplified the view) |
| `companies` | column signature differs |
| `pgcomps` | prod view 14 cols vs dev 15 cols (matches the known pgpages generated-column gotcha) |
| `audgenres_audition_xref`, `audcontacts_auditions_xref` | index signatures differ |
| `events_tbl`, `eventcontactsxref_tbl` | index drift (expected — the events_completed index work landed dev-side) |
| `contacts_ss_followup/maint/target` | view definitions diverged (dev unified to 13 cols, prod 11–12) |

**Implication for Go/Flutter:** the migration's schema source-of-truth must be **prod**, captured live (this audit), *not* dev and *not* the repo migration files (already proven stale: `verify-indexes.sql`). Building Go models or a target schema from dev would silently encode the wrong shape for `audprojects`, `notifications`, `contactitems`. This is the highest-value Phase 1 finding.

**dev-only objects worth noting (not all cruft):**
- *Genuine WIP prod lacks:* `audition_notifications`, `audition_requests_raw`, `court_webhook_data`, `lac_auditions`, `lac_notifications`, **`cache_contact_last_event`, `cache_contact_meeting_counts`** (these last two look like the real-time replacement for the `events_completed` JOB D backfill — directly relevant to that earlier work), `sharez_cache`/`sharez_optimized`/`shareviews` (the intended successor to `shares_old`/`sharez_old`).
- *dev scratch/analysis debris (safe to ignore/clean in dev):* `functions`, `functions_backup`, `function_tables`, `unique_functions`, `sql_types`, `qry_types`, `tao_tables`, `tao_files`, `models`, `components`, `cfqueryparam_matrix`, `view_conditions(_final)`, `tickets_tbl_old`, `_audprojects_unionid_remap_20260506`, `_audunions_dev_remap_20260506`.
- *prod-only legacy that dev already removed:* `shares_old`, `sharez_old` — dev runs fine without them → strengthens the drop case (still pending Phase 2 code check).

---

## 2. Referential integrity

- **50 declared FKs**, almost entirely in the **auditions subsystem** (`audroles`, `audprojects`, `auditions_tbl`, `aud*_xref` → `audcategories`/`audroles`/`taousers_tbl`) plus the *newer* well-designed tables (`feature_flag_users`, `import_job_*`, `sharetokens`, `contact_custom_fields`, `tao_regions`).
- **The legacy core has NO declared FKs**: `contactitems_tbl`, `events_tbl`, `funotifications_tbl`, `fusystemusers_tbl`, `notifications_tbl` enforce all integrity in CF app code, not the DB. Migration-critical: Go cannot rely on DB constraints for the core entities; orphan-row risk must be validated in Phase 2 and the Go data layer must replicate the app-level rules.
- **Duplicate FK:** `auditions_tbl` has both `FK_auditions_audsteps` and `FK_auditions_audsteps_2` on the same column `audStepID` → `audsteps`. Redundant constraint + index.
- 20 PK-less base tables (from Phase 0) remain an integrity + Go-ORM-identity hazard.

---

## 3. Charset — Phase 0 concern DOWNGRADED

`information_schema.COLUMNS`: **all 1,468 character columns across 269 objects are `utf8mb4`.** Despite the `utf8mb3` *server default* (Phase 0), there is **no mixed-charset data problem**. The risk is purely future DDL hygiene: a `CREATE TABLE` without an explicit charset inherits mb3. Action is small and reversible — set the schema default to `utf8mb4` and/or always specify; the Go DSN must use `utf8mb4`. Not a data-migration blocker.

---

## 4. DEFINER views — landmine quantified

87 views: **84 `DEFINER=kingk436@%`**, **1 `DEFINER=root@108.185.100.195`**, **2 `INVOKER=admin@%`**.

- The lone `root@108.185.100.195` DEFINER view is acutely fragile — it breaks (error 1146) if that host-pinned root account changes. Highest-priority single fix.
- 84 views depend on `kingk436` continuing to exist with privileges. This is the documented TAO landmine (phpMyAdmin rewrites INVOKER→DEFINER). Recommend a **bulk SQL SECURITY INVOKER conversion** (same approach as the 2026-04-18 tickets-view migration), defer-friendly but valuable before any account/host change or the migration.

---

## 5. Redundant / duplicate indexes (concrete, reversible quick wins)

Clear leftmost-prefix subsumption or exact non-unique duplicates of a unique index. Dropping these is pure write-overhead reduction (no read loss) and reversible. **Gate: Phase 2 must confirm no query pins them via `FORCE/USE INDEX`; never drop an index backing an FK.**

| Table | Drop | Reason (covered by) |
|---|---|---|
| `actionusers_tbl` | `idx_actionusers_actionID` | ⊂ `idx_au_action_user (actionid,userid)` |
| `funotifications_tbl` | `idx_funotifications_notstatus` | ⊂ `idx_funot_status_startdate (notStatus,notStartDate)` |
| `contactdetails_tbl` | `idx_cd_user_deleted` | ⊂ `idx_contactdetails_tbl_dupe_v3 (userID,IsDeleted,contactID)` |
| `contactitems_tbl` | `idx_ci_contact_category_status`, `valueCategory` | ⊂ `idx_contactitems (contactID,valueCategory,itemStatus,primary_YN)` / `idx_contactitems_tbl_category_status` |
| `events_tbl` | `ix_e_event` | exact duplicate of `PRIMARY (eventID)` |
| `auditions` | `idx_auditions_userid_date` | ⊂ `idx_auditions_dupe_detect (userid,audition_date,project_name)` |
| `audunions` | `unionName` | ⊂ `uk_audunions_name_country (unionName,countryid)` |
| `import_job_rows` | `IX_import_job_rows_job_rownum` | non-unique dup of unique `UX_import_job_rows_job_rownum` |
| `import_v3_rows` | `IX_import_v3_rows_job_rownum` | non-unique dup of unique `UX_import_v3_rows_job_rownum` |
| `import_auditions_rows` | `idx_iar_job_rownum` | non-unique dup of unique `idx_iar_job_row (job_id,row_num)` |
| `sharetokens` | `IDX_ShareTokens_Token` | non-unique dup of unique `UC_ShareTokens_Token` |
| `auditions_tbl` | `FK_auditions_audsteps_2` (+constraint) | duplicate FK/index of `FK_auditions_audsteps` on `audStepID` |

**Systemic pattern:** the IX/UX duplicate exists across all three import subsystems — a class fix, not one-offs. `contactitems_tbl` is the worst offender overall: ~88 MB of indexes on a write-hot EAV table, several single-column indexes subsumed by composites — biggest write-amplification reduction opportunity (deeper analysis = Phase 2 with query cross-ref).

---

## 6. View-pattern observations (Go-migration inputs)

- Most entities follow `X` (view) over `X_tbl` (base). Many views are pure `SELECT *` passthroughs (identical column signature, e.g. `actionusers`==`actionusers_tbl`) — candidates for elimination in the Go layer (the passthrough indirection adds nothing).
- Where view ≠ `_tbl` (e.g., `taousers` view 45 cols vs `taousers_tbl` 47 — hides `passwordHash` etc.; `contactitems`, `funotifications`) the view encodes real business rules (column hiding, soft-delete filter) that the Go data layer must replicate explicitly.
- `v_contacts_optimized` in prod has the *identical* column signature as `sharez`/`sharezz` (2031951488) — likely an alias/dup; in dev it diverged. Plus `sharez`==`sharezz` (same signature, the `zz` looks like a typo-twin). Consolidation candidates.

---

## 7. Phase 1 conclusions → carry into Phase 2/3

1. **Migration source-of-truth = live prod, captured by this audit.** dev drift makes it unsafe as the schema baseline. (Highest value.)
2. Reversible quick wins ready for Phase 3 scripts: the §5 redundant-index drops (repo `2026-04-03` pattern), the duplicate `FK_auditions_audsteps_2`, the `utf8mb4` schema default.
3. Defer-to-Go / larger: bulk INVOKER view conversion (84+1 views), passthrough-view elimination, import-subsystem consolidation, app-enforced-integrity replication for the FK-less core.
4. Phase 2 must: code-cross-ref the §5 indexes (no `FORCE INDEX` pins) and the drop candidates (`shares_old`, `sharez_old`, dated snapshots, 0-row tables), and check orphan rows on the FK-less core tables.

---

## Appendix A — exact index/FK definitions captured for Phase 3 scripts

Source artifact for the EVIDENCE block in `migrations/2026-05-17_audit_drop_redundant_indexes.sql`. Captured live from prod 2026-05-17 (`information_schema.STATISTICS` / `KEY_COLUMN_USAGE`). All 12 dropped indexes: `SUB_PART=null`, `NON_UNIQUE=1`.

| Dropped index | Definition | Coverer (survives) |
|---|---|---|
| actionusers_tbl.idx_actionusers_actionID | (actionid) | idx_au_action_user(actionid,userid) |
| funotifications_tbl.idx_funotifications_notstatus | (notStatus) | idx_funot_status_startdate(notStatus,notStartDate) |
| contactdetails_tbl.idx_cd_user_deleted | (userID,IsDeleted) | idx_contactdetails_tbl_dupe_v3(userID,IsDeleted,contactID) |
| contactitems_tbl.idx_ci_contact_category_status | (contactID,valueCategory,itemStatus) | idx_contactitems(contactID,valueCategory,itemStatus,primary_YN) |
| contactitems_tbl.valueCategory | (valueCategory) | idx_contactitems_tbl_category_status(valueCategory,itemStatus,IsDeleted,contactID) |
| events_tbl.ix_e_event | (eventID) | PRIMARY(eventID) |
| auditions.idx_auditions_userid_date | (userid,audition_date) | idx_auditions_dupe_detect(userid,audition_date,project_name[100]) |
| audunions.unionName | (unionName) | uk_audunions_name_country(unionName,countryid) UNIQUE |
| import_job_rows.IX_import_job_rows_job_rownum | (job_id,row_num) | UX_import_job_rows_job_rownum UNIQUE |
| import_v3_rows.IX_import_v3_rows_job_rownum | (job_id,row_num) | UX_import_v3_rows_job_rownum UNIQUE |
| import_auditions_rows.idx_iar_job_rownum | (job_id,row_num) | idx_iar_job_row UNIQUE |
| sharetokens.IDX_ShareTokens_Token | (token) | UC_ShareTokens_Token UNIQUE |

FK safety (`KEY_COLUMN_USAGE`): `contactdetails_tbl` HAS `FK_contactdetails_taousers (userID→taousers_tbl.userID)` — drop of `idx_cd_user_deleted` is safe because `idx_contactdetails_tbl_dupe_v3` keeps `userID` leftmost. `auditions_tbl` has BOTH `FK_auditions_audsteps` and the exact-duplicate `FK_auditions_audsteps_2` on `audStepID→audsteps.audstepid` (the duplicate is dropped in Phase 3).
