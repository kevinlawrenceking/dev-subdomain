# Prod DB Audit — Phase 0: Feasibility + Live Inventory

Date: 2026-05-17
Target: `actorsbusinessoffice` @ 46.31.66.114:3306 (prod), MySQL **8.0.41**
Method: read-only MCP (`admin` user), `information_schema` only
Scope decision (assumed, unconfirmed): objective = inform Go/Flutter migration; policy = reversible-only; cadence = phased.

---

## 1. Capability boundary (what this audit CAN and CANNOT measure)

| Capability | Status | Consequence |
|---|---|---|
| `information_schema` reads | ✅ works | Full schema/size/index/integrity analysis is possible |
| SELECT on base tables & views | ✅ works | Data-quality + orphan-row checks possible |
| DDL/DML (CREATE/ALTER/DROP) | ❌ read-only session | Audit produces scripts; **a DBA executes** |
| `performance_schema` | ❌ OFF *and* privilege-denied | **No runtime stats** |
| `sys` schema | ❌ privilege-denied | No `schema_unused_indexes` |
| EXPLAIN through views | ❌ privilege-denied (prior finding) | No plan-level proof |

**Key limitation:** unused-index and hot-query detection **cannot be data-driven** (no perf_schema/sys). It must be **code-inference**: cross-reference index/table columns against query patterns in the CF repo (Phase 2). State this in every "drop/unused" recommendation — DB evidence alone is never sufficient.

---

## 2. Environment findings (migration-relevant)

- **205 base tables + 87 views = 292 objects; 852.8 MB.** 100% InnoDB (good — no MyISAM landmine).
- **Charset split — landmine.** Server default is legacy `utf8mb3 / utf8mb3_general_ci`, but all 205 tables are `utf8mb4_unicode_ci`. Any table created without an explicit charset inherits mb3. Column-level charset scan needed (Phase 1). The Go driver/DSN must force `utf8mb4`.
- **Permissive `sql_mode`: `IGNORE_SPACE,NO_ENGINE_SUBSTITUTION`** — no `ONLY_FULL_GROUP_BY`, no `STRICT_TRANS_TABLES`. This is *why* latent bugs like the JOB D `eventtitle`-with-`MIN()` (review issue #11) don't error today. A modern/Go stack typically runs strict mode → loose-GROUP-BY and silent-truncation-tolerant queries **will break on migration**. High-value: needs a query audit before cutover.
- **Views: 85 DEFINER vs 2 INVOKER.** TAO requires SQL SECURITY INVOKER (phpMyAdmin silently rewrites to DEFINER → error 1146; documented landmine). 85 DEFINER views = systemic operational + migration risk; candidate for a bulk INVOKER conversion pass.

---

## 3. Size concentration (optimization leverage is top-heavy)

| Table | Rows | Total MB | % of DB | Note |
|---|---|---|---|---|
| `bigbrother` | 2,580,953 | 363.4 | **43%** | Activity/audit log. Single biggest lever — **retention/archival**, not drop. |
| `errors_tbl` | 2,532 | 115.6 | 14% | ~46 KB/row — blob/stacktrace bloat. Prune/retention candidate. |
| `contactitems_tbl` | 263,434 | 109.4 | 13% | Core EAV table (88 MB of indexes). Real hot path. |
| `imdb` | 131,888 | 30.1 | 4% | Scraped reference, **no PK**. |
| `import_v3_facts` | 157,304 | 25.4 | 3% | Import staging — should have retention. |
| top 5 = **~77% of the DB** | | | | Optimization effort should concentrate here, not on the 150+ sub-0.1 MB lookup tables. |

`bigbrother` + `errors_tbl` + the import staging tables alone are ~520 MB (61%). A retention/archival policy is the highest-ROI optimization and is migration-friendly (don't carry years of logs into Go).

---

## 4. Drop / dead-table candidates (DB evidence ONLY — Phase 2 must code-verify)

**Hard rule: nothing here gets dropped on this evidence. Each needs code grep + scheduled-task check + archive + rename-quarantine before DROP.**

- **Dated migration debris (high confidence):** `_audprojects_crosslist_snapshot_20260506` (0 rows), `audunions_pre_consolidation_20260505` (59), `audprojects_unionid_remap_20260505` (1,483), `events_tbl_backup` (13,710 / 2.5 MB, frozen 2026-01-11).
- **Legacy superseded views:** `shares_old`, `sharez_old`.
- **0-row tables (~22):** split into *abandoned* (`clubs`,`clubmembers`,`clubgrades`,`questions`,`viewtypes`,`exttypes`,`projconxref_tbl`,`useradmin_tbl`,`userlinks_tbl`,`pgpanels_user_xref_delete`,`ipn_log`,`importtest`,`import-contacts`) vs *possibly-WIP scaffolding* (`feature_flags`,`feature_flag_users`,`contact_custom_fields`,`casting_notifications`,`import_jobs`,`import_job_*` — created Jan/Feb 2026; could be unfinished, not dead). Phase 2 must distinguish.
- **Redundancy themes (biggest structural opportunity):**
  - **Three+ parallel import subsystems:** `import_jobs`/`import_job_*` vs `import_v3_*` vs `import_auditions_*` plus legacy `contactsimport`, `importcastabout_tbl`, `importtest`, `import-contacts`, `auditionsimport*`. Consolidation candidate — ideally resolved in the Go redesign, not patched in CF.
  - **Duplicate reference data:** `tao_regions`/`regions`, `tao_countries`/`countries` (prefixed copies); plus `states`,`cities`,`regions` overlap.
  - **Near-duplicate pair:** `useradmin_tbl`(0) / `useradministrator_tbl`(2).

---

## 5. Integrity finding: 20 base tables with NO PRIMARY KEY

`_audprojects_crosslist_snapshot_20260506`, `auditionsimport_error`, `audmedia_audroles_xref`, `audpaycycles`, `audunions_pre_consolidation_20260505`, `defstate_xref`, `events_tbl_backup`, `fuactionlinks_tbl`, `imdb`, `import-contacts`, `importcastabout_tbl`, `importtest`, `itemtypes_tbl`, `notstatuses`, `products`, `states`, `useradmin_tbl`, `useradministrator_tbl`, `yesnos_tbl`, `yesnosbit_tbl`.

Triple risk: (1) referential-integrity weakness, (2) **no clean primary identity for a Go ORM / row-level migration**, (3) several overlap the drop candidates. The live ones (`fuactionlinks_tbl`, `audmedia_audroles_xref`, `defstate_xref`, `itemtypes_tbl`) need PKs added or are redesign inputs.

---

## 6. Phase roadmap (as tracked)

- **Phase 0 — DONE (this doc).**
- **Phase 1 (next, zero prod risk):** dev↔prod schema diff; index-health (redundant/duplicate/missing-FK, reconciled vs the 2026-03-20 / 2026-04-03 index migrations); column-level charset scan; referential-integrity orphan checks; the 85 DEFINER views enumerated.
- **Phase 2:** CF code + scheduled-task cross-reference → evidence-backed drop register; data-quality/type-debt; "fix-now-safe" vs "defer-to-Go" tags.
- **Phase 3:** sequenced risk register; idempotent migration+ROLLBACK scripts (repo `AddIndexIfNotExists` convention); rename→observe→drop quarantine plans; `tao-gatekeeper` review before any DBA execution.

**Top themes to carry forward:** (1) retention policy for `bigbrother`/`errors_tbl`/import staging = biggest ROI; (2) import-subsystem consolidation = biggest structural cleanup, best done in the Go redesign; (3) 85 DEFINER views + utf8mb3-default + permissive sql_mode = the three migration-correctness risks.
