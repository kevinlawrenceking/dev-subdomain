# DIR-WO-1 — Six-File Paste Manifest (for the architect verdict)

**Binding:** TAO / `dev-subdomain` / branch `dev` · Staged 2026-07-07 (CC).
**Purpose:** the exact set to paste to the architect for the six-file verdict + drift
registration (thread C). All six are on disk, committed, on `dev`.

## The six migration files (3 forward + 3 rollback)

| # | File | Role |
|---|------|------|
| 1 | `database/migrations/V3_7__master_directory_wo1_contactdetails_columns.sql` | Forward — 12 cols + 3 idx + contactPhoto widen 255→500 (idempotent) |
| 2 | `database/migrations/V3_7__master_directory_wo1_contactdetails_columns_ROLLBACK.sql` | Rollback for #1 |
| 3 | `database/migrations/V3_8__master_directory_wo1_contactdetails_view.sql` | Forward — `contactdetails` view rebuild (44-col, INVOKER). **DRAFT until the abod `SHOW CREATE VIEW contactdetails` 33-vs-32 reconcile.** |
| 4 | `database/migrations/V3_8__master_directory_wo1_contactdetails_view_ROLLBACK.sql` | Rollback — view back to original 32 cols |
| 5 | `database/migrations/V3_9__master_directory_wo1_contactdetails_fk.sql` | Forward — 3 FKs (SET NULL / RESTRICT), deferred to post-backfill |
| 6 | `database/migrations/V3_9__master_directory_wo1_contactdetails_fk_ROLLBACK.sql` | Rollback — drop the 3 FKs |

## Context to hand alongside (not part of the six, but the architect will want them)

- `docs/plans/evidence/2026-07-06-wo1-execution-runbook.md` — apply order, STOP-on-delta gates, rollback order.
- `docs/plans/evidence/2026-07-06-wo0b-decision-memo-corrected.md` — decisions D-1..D-5 + amendments A1–A6.

## Two flags to state to the architect up front

1. **V3_8 is DRAFT** — do not treat the view rebuild as final until the abod pane's
   `SHOW CREATE VIEW contactdetails` is reconciled (see
   `docs/plans/evidence/2026-07-07-wo0b-pane-abod-ready.sql`, block A-Q2). A 33rd base
   column would force a re-emit.
2. **Dev exec is gated** — F14–F19 dev↔prod drift is not yet registered (abod pane not
   pasted). Architect verdict can proceed on the pack as authored; dev apply waits on the
   drift register (Addendum B).

## One-liner to collect all six for pasting

```bash
for f in \
  database/migrations/V3_7__master_directory_wo1_contactdetails_columns.sql \
  database/migrations/V3_7__master_directory_wo1_contactdetails_columns_ROLLBACK.sql \
  database/migrations/V3_8__master_directory_wo1_contactdetails_view.sql \
  database/migrations/V3_8__master_directory_wo1_contactdetails_view_ROLLBACK.sql \
  database/migrations/V3_9__master_directory_wo1_contactdetails_fk.sql \
  database/migrations/V3_9__master_directory_wo1_contactdetails_fk_ROLLBACK.sql; do
  echo "===== $f ====="; cat "$f"; echo;
done
```
