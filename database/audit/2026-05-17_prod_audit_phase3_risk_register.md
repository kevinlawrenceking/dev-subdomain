# Prod DB Audit — Phase 3: Risk Register + Remediation Plan

Date: 2026-05-17
Consolidates Phases 0–2. Scope policy (assumed): reversible-now only; structural/destructive deferred to the Go redesign.
**Execution model: a DBA runs every script (dev `new_development` → prod `actorsbusinessoffice`). The MCP is read-only; nothing here was executed. All scripts are idempotent + have a ROLLBACK.**

---

## Severity-ranked register

| # | Finding | Sev | Effort | Reversible | Disposition |
|---|---|---|---|---|---|
| R1 | Relationship-engine orphans: funotifications→fusystemusers **1,690**, →fuactions **256**, fusystemusers→contactdetails **13** | High | Med | Data — investigate | **Investigate, do NOT auto-delete** (sentinel caveat). Owner sign-off. Script = diagnostic only. |
| R2 | `exttypes` empty but `LEFT JOIN`ed ~14× in `AuditionMediaService.cfc` → silent NULL media typing | High | Low | Yes (seed data) | Functional bug — route to AuditionMedia owner. Not a schema change. |
| R3 | dev↔prod core drift (`audprojects` 16 vs 19 cols, `notifications`, `contactitems`, `pgcomps`) | High | Med | N/A | **Migration source-of-truth = live prod, not dev/repo.** Feeds Go schema design. |
| R4 | ~13 redundant/duplicate indexes; write-amplification on hot tables (`contactitems_tbl` 88 MB idx) | Med | Low | **Yes** | **Script A** (this phase). Index-pin safety cleared (0 `FORCE INDEX`). |
| R5 | Duplicate FK `FK_auditions_audsteps_2` on `auditions_tbl.audStepID` | Low | Low | Yes | **Script A** (FK section). |
| R6 | ~16 dead tables/views (dated snapshots, `events_tbl_backup`, `shares_old`/`sharez_old`, abandoned `clubs*`/`useradmin*`) | Med | Low | **Yes (quarantine)** | **Script B**: rename→observe→drop; archive non-empty first. |
| R7 | Duplicate reference data `tao_regions`/`tao_countries` vs `regions`/`countries`, 0 code refs | Low | Low | Yes (quarantine) | **Script B (gated)** — verification query must pass first. |
| R8 | 84 `DEFINER=kingk436@%` + 1 `DEFINER=root@108.185.100.195` views (the root one acutely fragile) | Med | Med | Yes | **Defer to Go** / separate INVOKER-conversion pass (like 2026-04-18 tickets-view). Documented, not scripted here. |
| R9 | utf8mb3 server default vs all-utf8mb4 tables (future-DDL hazard only; no data problem) | Low | Low | Yes | Defer: set schema default `utf8mb4`; Go DSN must force utf8mb4. |
| R10 | Permissive `sql_mode` (no `ONLY_FULL_GROUP_BY`/`STRICT`); loose-GROUP-BY queries (e.g. events_completed JOB D) break under strict mode | High | High | N/A | **Go-migration blocker input** — query audit required before cutover. |
| R11 | 20 PK-less base tables; FK-less core (integrity app-enforced) | Med | High | N/A | Go redesign: add PKs/FKs; Go layer must replicate app rules. |
| R12 | 3+ parallel import subsystems; ~853 MB dominated by `bigbrother`(363)/`errors_tbl`(116)/import staging | Med | High | N/A | Go redesign + retention policy (biggest size ROI). Documented. |

**Do-now (this phase): R4, R5, R6, R7. Everything else is documented Go-redesign / owner-routed input — deliberately not scripted.**

---

## Scripts delivered (idempotent, dev→prod, each with ROLLBACK)

- `migrations/2026-05-17_audit_drop_redundant_indexes.sql` (+ `_ROLLBACK`) — R4, R5. Drops 12 redundant indexes + the duplicate FK; rollback recreates exactly.
- `migrations/2026-05-17_audit_quarantine_dead_tables.sql` (+ `_ROLLBACK`) — R6, R7. **Renames** (does not DROP) dead tables to `_zzq_20260517_*`; rollback renames back. Legacy views handled with a DDL-capture prerequisite. `tao_*` gated behind a verification query.

### Mandatory operating procedure
1. Run on **dev first**, confirm `OK`/`SKIPPED` output, smoke-test the app.
2. **Archive before quarantine** (non-empty): `events_tbl_backup`, `audprojects_unionid_remap_20260505`, `audunions_pre_consolidation_20260505`, `useradministrator_tbl` via `mysqldump`.
3. Quarantine = rename only. **Observe ≥2 weeks** (watch error logs for missing-table). Only then a follow-up `DROP` (separate script, not in this phase).
4. `tao-gatekeeper` review must return SHIP before any prod run.

---

## Explicitly NOT done (faithful scope statement)
- No orphan rows deleted (R1 is diagnostic-only pending owner sign-off).
- No tables dropped — only rename-quarantined, reversibly.
- No DEFINER→INVOKER conversion (R8), no import consolidation (R12), no exhaustive varchar-type-debt column scan — all carried as Go-redesign inputs.
- Nothing executed against any database by this audit.
