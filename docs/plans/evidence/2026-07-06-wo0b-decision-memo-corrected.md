# WO-0b Decision Memo (CORRECTED) — Master Contact Directory Phase 1

> **Supersedes** `docs/plans/evidence/2026-07-04-wo0b-decision-memo.md` for its
> evidence header only. Re-emitted 2026-07-06 per amendment **A6** to remove the
> contradiction between the memo's evidence header ("SHOW GRANTS/EXPLAIN pending")
> and its status line ("one-liners A/B landed"). The five decisions D-1…D-5 are
> unchanged; the 07-04 file is retained for history. **Memo status: CLEARED WITH
> AMENDMENTS (A1–A6), 2026-07-06.**

## Authoritative evidence status (single source of truth)

All WO-0b one-liners have **landed**; only the abod drift pane remained, and it
gates migration-portability, not the design:

| Evidence | Status | File |
|----------|--------|------|
| abo (prod) DDL pane | **LANDED** | `2026-07-04-wo0b-pane-abo.txt` |
| One-liner A — `SHOW GRANTS` (Q9b) | **LANDED** | `2026-07-04-wo0b-oneliner-A-grants.txt` |
| One-liner B — `EXPLAIN` baseline (Q13) | **LANDED** | `2026-07-04-wo0b-oneliner-B-explain.txt` |
| Prod master-table counts (G1) | **LANDED** | `2026-07-04-wo0b-prod-master-counts.txt` |
| Prod Q8/Q15 master DDL + quality (G2) | **LANDED** | `2026-07-04-wo0b-prod-Q8-Q15-master.txt` |
| abod dev↔prod hot-table drift pane | **PENDING → register F14–F19** | (not yet on disk) |

**Correction:** the original memo's line 6 header ("abo pane landed; abod pane +
`SHOW GRANTS`/`EXPLAIN` still pending") was stale — one-liners A and B **had already
landed** as the two files above, matching the original status line. The header above
is now the one authoritative statement.

## Decisions (unchanged from 07-04) — all DECIDED, now LOCKED with amendments

- **D-1 Photo policy** — store master photo URL directly in `contactPhoto`.
  **Amendment A1:** widen `contactPhoto varchar(255) → varchar(500)` is **mandatory**
  in WO-1 (source `co_contacts.image_url` is `varchar(500)`); the spot-check watch
  item is superseded. `contactPhoto_src='user'` beats `'master'`; disk-avatar path
  untouched. IMDb URL rot / hotlink blocking → Phase-2 risk (register).
- **D-2 Real same-schema FKs** in prod. **Amendment A2:** `ON DELETE SET NULL,
  ON UPDATE RESTRICT` on all three pointers; two-step — WO-1 adds INT NULL columns +
  indexes, FK ALTER is a separate file applied after backfill validation. Ratified
  as architecture.
- **D-3 Person-first link** (`co_contacts.id` → derive `coid`/office). Ratified as
  architecture. Data-quality caveats F13 stand (normalize `jobtitle_type`; don't
  hard-depend on `location`).
- **D-4 Manual "Refresh from master"** in Phase 1; scheduled propagation → Phase 2.
  **Approved.** Refresh idempotency → WO-5 acceptance.
- **D-5 Free-text `contactCompany varchar(255)` + optional `company_location_id`.**
  **Approved.** Sizing uses `varchar(255)` (F3), not the plan's 200.

## Cross-cutting facts locked (affect every WO)

1. `recordname` is VIRTUAL GENERATED (= `contactFullName`) — never write it; WO-4
   drops the 4 writers (F1).
2. `master_linked_date` / `master_last_sync` = **DATETIME**, not TIMESTAMP (Q19).
3. View rebuild mandatory post-ALTER; `contactdetails` enumerates the base columns
   (A4 — rebuild in the same window, INVOKER, mysql CLI, no schema qualifiers).
4. Backfill tie-break `ORDER BY primary_YN DESC, itemID ASC LIMIT 1` (A5).
5. `v_contacts_optimized` already exists — WO-6 reuse (F2).
6. Reuse existing `imdbid`; do not add a master IMDb column (F4).
7. FK targets: `company_location_id → co_locations.colocid`,
   `master_co_contact_id → co_contacts.id`, `master_coid → companies.coid` — all PK,
   all InnoDB, all signed int (F10 / Q8). Skip `idx_co_name`; master indexes exist (F11).
8. Master data dirty/unverified; `co_contacts.coid` is a 0-sentinel — map to NULL on
   backfill (F12/F13).

## Plan deviations (registered — DIR-WO-1 revision R2)

- **No `master_link_status` column.** Plan-v1 §7 service prose referenced
  `master_link_status='linked'`. WO-1 omits the column: link state is **derived** —
  `master_co_contact_id IS NOT NULL` means linked. A redundant status column would
  risk drifting out of sync with the pointer it mirrors. WO-4/WO-5 service code
  derives link state instead. (Also reflected in `master-contact-directory-phase1.md`
  read against this deltas line.)

## Gate

WO-1 **authoring: GO** (delivered for review). WO-1 **dev execution:** gated on the
abod drift record (F14–F19) being registered first (ruling #2). WO-1 remains
otherwise blocked until Kevin's proof-bundle review + commit authorization.
