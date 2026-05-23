# TAO → Go/Flutter Redesign Brief

Audience: the Go/Flutter migration engineering team.
Source: the May 2026 prod DB audit (Phases 0–3). Every claim cites a Phase doc; every number is measured against live prod (`actorsbusinessoffice` @ 46.31.66.114, MySQL 8.0.41) on 2026-05-17.
Purpose: tell the Go team what to design **for** and what to design **against**, before the first line of `migrations/0001_*.sql`.

---

## 1. Schema source-of-truth = live prod, NOT dev, NOT the repo

The single most consequential audit finding (Phase 1 §1). Core tables drift dev↔prod:

| Object | Drift |
|---|---|
| `audprojects` | prod **16 columns**, dev **19** |
| `notifications`, `notifications_tbl` | column signatures differ |
| `contactitems` / `contactitems_tbl` | signatures differ; prod view ≠ base table, dev simplified it |
| `companies`, `pgcomps`, `audgenres_audition_xref`, `audcontacts_auditions_xref` | drift in cols or indexes |
| `contacts_ss_followup/maint/target` | view defs diverged |

`database/audit/verify-indexes.sql` is a *recommendations* doc, not a live snapshot — trusting it for indexes already produced one wrong root-cause claim ([[project_events_completed_timeout_cause]]).

**Action:** at Go schema kickoff, snapshot prod with `mysqldump --no-data --routines --triggers actorsbusinessoffice > prod_schema_YYYYMMDD.sql`. Treat that file as the authoritative starting point. Diff dev to prod periodically through the migration so dev cleanup doesn't silently encode the wrong shape.

---

## 2. The strict-mode time bomb

Prod `sql_mode = IGNORE_SPACE,NO_ENGINE_SUBSTITUTION`. **No `ONLY_FULL_GROUP_BY`. No `STRICT_TRANS_TABLES`.** Modern Go MySQL drivers + most ORMs run with strict mode by default.

Concrete example already in the codebase: `sched/events_completed.cfm` JOB D does `SELECT x.contactid, e.eventtitle, MIN(e.eventstop) ... GROUP BY x.contactid` — `eventtitle` is a non-aggregated, non-grouped column. Today it returns *some* row's title (silently nondeterministic). Under `ONLY_FULL_GROUP_BY` it errors out. There are almost certainly more of these in the CFML.

**Action:** before cutover, run a query-pattern audit (probably best as `EXPLAIN` against a strict-mode replica) of every cfquery in the repo. The migration plan must include a "strict-mode prep" phase that fixes loose-GROUP-BY, missing default values, and silent type coercion. **Do not** rely on the dev DB to surface these — dev runs the same permissive mode.

---

## 3. The legacy core has no real referential integrity

Phase 1 §2 + Phase 2 §4. 50 FKs declared, almost all in the auditions subsystem (`audroles`, `audprojects`, `auditions_tbl` → `audcategories`/`audroles`/`taousers_tbl`) plus the newer well-designed tables (`feature_flag_users`, `import_job_*`, `sharetokens`).

The legacy core has **zero declared FKs**: `contactitems_tbl`, `events_tbl`, `funotifications_tbl`, `notifications_tbl`, `fusystemusers_tbl`. Integrity is enforced in CF application code. Measured orphan debt:

| Relationship | Orphans |
|---|---|
| contactitems → contactdetails | 0 |
| events → taousers | 1 |
| eventcontactsxref → contactdetails | 21 |
| fusystemusers → contactdetails | 13 |
| **funotifications → fusystemusers (suID)** | **1,690** |
| **funotifications → fuactions (actionID)** | **256** |

**Action:** the Go data layer must replicate the app-enforced rules (e.g. `contactdetails.IsDeleted=0` filters in every view). Consider adding real FKs in the Go schema — but only AFTER an orphan investigation (some `suID=0` may be intentional sentinels; do not auto-delete). The relationship subsystem is the same one that produced the events_completed timeout — design with care.

---

## 4. 20 base tables with NO primary key

Phase 0 §5: `_audprojects_crosslist_snapshot_20260506`, `auditionsimport_error`, `audmedia_audroles_xref`, `audpaycycles`, `audunions_pre_consolidation_20260505`, `defstate_xref`, `events_tbl_backup`, `fuactionlinks_tbl`, `imdb`, `import-contacts`, `importcastabout_tbl`, `importtest`, `itemtypes_tbl`, `notstatuses`, `products`, `states`, `useradmin_tbl`, `useradministrator_tbl`, `yesnos_tbl`, `yesnosbit_tbl`.

Most are dead and will be quarantined ([[project_prod_db_audit_2026_05]]). The live ones that matter — `fuactionlinks_tbl`, `audmedia_audroles_xref`, `defstate_xref`, `itemtypes_tbl` — are Go-ORM identity hazards (GORM/sqlx assume a stable primary identity). **Action:** add real PKs in the Go schema; do not migrate PK-less.

---

## 5. The `view + _tbl` pattern needs an explicit replacement strategy

87 views vs 205 base tables (Phase 1). Most views are `SELECT * FROM x_tbl` passthroughs (`actionusers`/`actionusers_tbl` have identical column signatures, etc.). Some encode real business rules: `taousers` hides `passwordHash`; `contactitems`/`funotifications` apply filters. Map both classes in the Go layer:

- **Passthrough views** → eliminate (the Go data layer reads `_tbl` directly).
- **Rule-encoding views** → either keep as DB views (must convert to `SQL SECURITY INVOKER` first — see §6) or move the rule into the Go repository layer.

Caveat: `sharezz` is the live view in `services/ShareService.cfc` (despite the name); `sharez`/`shares_old`/`sharez_old` are unused (Phase 2 §2). Don't assume names imply currency.

---

## 6. DEFINER view landmine: 84 + 1

Phase 1 §4: 84 views with `DEFINER=kingk436@%`, 1 with `DEFINER=root@108.185.100.195` (acutely fragile — breaks on any host/account change), only 2 `INVOKER`. This is the documented TAO landmine ([[feedback_tao_views_use_invoker_security]]): phpMyAdmin silently rewrites DEFINER, causing error 1146 "doesn't exist."

**Action:** the Go cutover is a clean opportunity to retire DEFINER semantics entirely. Either (a) move all rule-encoding views into Go code, or (b) recreate the keepers as `SQL SECURITY INVOKER`. The pattern is already proven in `database/2026-04-18_rebuild_tickets_view_invoker_security.sql`.

---

## 7. Charset / DSN

Server default is **utf8mb3** but all 205 tables are **utf8mb4** (Phase 1 §3). No data problem, just DDL hygiene. **Action:** Go DSN must specify `charset=utf8mb4,utf8` and `collation=utf8mb4_unicode_ci`. The Go schema's `CREATE TABLE`s should always declare charset explicitly.

---

## 8. Three coexisting import subsystems

Phase 0 §4. Live in prod: `import_jobs/import_job_*` (the newest, 0 rows but wired in), `import_v3_*` (active, has data), `import_auditions_*` (active, auditions-specific), plus legacy `contactsimport`, `importcastabout_tbl`, `auditionsimport*`. Each has its own jobs/rows/events/columns/facts table set.

**This is the biggest single structural cleanup opportunity** and the *right* place to resolve it is in the Go redesign, not as a CF-era patch. Design ONE pluggable import pipeline (contact / audition / extensible) with a single jobs/rows/events/facts schema and a type discriminator. The Phase 0 inventory shows exactly what's currently wired vs scratch.

---

## 9. Size concentration → retention is a prereq

| Table | MB | % | Disposition |
|---|---|---|---|
| `bigbrother` | 363 | 43% | Activity log — retention policy required |
| `errors_tbl` | 116 | 14% | ~46 KB/row (blob/stacktrace) — retention + payload pruning |
| `contactitems_tbl` | 109 | 13% | Real EAV core — migrate as-is |
| Top 5 tables | ~660 MB | **77%** | |

**Action:** apply the retention policy (see companion `_retention_policy.md`) on prod *before* the migration. Do NOT carry years of activity logs and stack traces into the Go database — it inflates the migration window, the target storage cost, and the time to first useful query on the new system.

---

## 10. Reference data duplicates

`regions`(4,148) ≈ `tao_regions`(4,149); `countries`(239) ≈ `tao_countries`(240); zero code references to the `tao_*` copies (Phase 2 §2). The May 2026 audit scripts quarantine `tao_*` (gated). **Action:** the Go schema has ONE `regions` and ONE `countries` table.

---

## 11. WIP signals to investigate before reinventing

dev has tables prod lacks that look like in-progress real-time replacements for current cron work:

- `cache_contact_last_event`, `cache_contact_meeting_counts` — likely the intended replacement for `events_completed` JOB D's nightly backfill ([[project_events_completed_timeout_cause]]). **Talk to whoever built these before designing equivalent Go-side caching.**
- `sharez_cache`, `sharez_optimized`, `shareviews` — successor to `shares_old`/`sharez_old`.
- `audition_notifications`, `audition_requests_raw`, `court_webhook_data`, `lac_auditions`, `lac_notifications` — newer integration scaffolding.

---

## 12. Test-bed strategy

Given §1 (dev ≠ prod), **the migration's test environment must be a fresh prod snapshot**, not the existing dev DB. Cadence: snapshot at kickoff, re-snapshot at each integration milestone. dev as it stands is suitable for *Go-app* iteration but NOT for *migration correctness* validation.

---

## 13. Suggested sequencing

1. **Prod snapshot + retention pass** (see retention policy doc) — shrinks the working dataset before any modeling.
2. **Strict-mode query audit** of the CFML repo — produces the to-fix list before any rewrite.
3. **Orphan investigation** — settle the funotifications/fusystemusers debt with the relationship-system owner; rule out sentinels.
4. **Go schema v0** from the cleaned snapshot: real PKs/FKs, no view+_tbl split, ONE import subsystem design, ONE regions/countries.
5. **Cutover dry-runs** against repeat-snapshots; never against dev.

---

## What this brief is NOT

- Not a Go data-layer design — that's the Go team's call.
- Not the exhaustive type-debt scan (varchar-stored dates/numerics across all 205 tables) — Phase 3 deliberately deferred this as a Go-redesign input rather than a CF-era fix.
- Not a final API surface map — see `database/claude-projects/tao-migration-analyst/05-migration-prep.md` (caveat: pre-2026-05-17, partly stale; cross-check against current code).
