# WO-0b Addendum B — dev↔prod drift register + V3_8 reconcile verdict

**Binding:** TAO / `dev-subdomain` / branch `dev` · **Date:** 2026-07-07 · **Author:** CC
**Inputs:** dev pane `2026-07-07-wo0b-pane-abod.txt` (abod/new_development), prod pane
`2026-07-04-wo0b-pane-abo.txt` (abo/actorsbusinessoffice) + the 2026-07-07 prod DDL capture.
**Status:** EVIDENCE. Resolves the DIR-WO-1 ruling-2 STOP-on-delta gate for V3_8 and registers the
F14–F19 dev↔prod hot-table drift. No code changed by this note.

---

## 1. V3_8 33-vs-32 RECONCILE — RESOLVED to 32 (PASS on both envs)

The live `contactdetails` view enumerates **exactly 32 columns** in **both** environments, in
identical order, with identical `WHERE (IsDeleted = 0)`:

| | prod (abo) | dev (abod) | V3_8 existing-block (lines 84–115) |
|---|---|---|---|
| view colcount | 32 | 32 | 32 |
| column set/order | contactID … avatar_yn | identical | identical |
| WHERE | IsDeleted = 0 | IsDeleted = 0 | IsDeleted = 0 |

The abo pane's "enumerated 33-col list" summary was a **miscount** — no 33rd base column, no alias,
no expression. Per V3_8's own STOP-on-delta rule the only live-vs-file difference is the 12 additive
WO-1 columns being **absent** from the live view = the expected case → **proceed**.

**VERDICT: V3_8 is CLEARED to lift from DRAFT.** Its 32-existing block is byte-correct against both
live views; it requires **zero SQL change**. Only its header DRAFT/STOP-on-delta warning (lines
30–48) should be updated to record this reconcile. (That header edit is a change to a
`database/migrations/` file → CODE; held for Kevin's "commit approved".)

---

## 2. Drift register (F14–F19 basis)

| # | Finding | prod | dev | Impact / disposition |
|---|---|---|---|---|
| **D-A** | `contactitems` view DEFINER | `kingk436@%` | **`root@108.185.100.195`** | **F19 live instance** — the exact phpMyAdmin-rewrite hallmark V3_8's header cites. SECURITY DEFINER + a definer account that likely can't be assumed → fragile. **NOT blocking V3_8** (different view). **Registered follow-up:** rebuild `contactitems` as INVOKER (mirror the tickets/contactdetails fix), mysql CLI only. |
| **D-B** | master data volume | companies 10,740 / co_contacts 25,200 / co_locations 12,617 | companies 10,740 / **co_contacts 0** / **co_locations 0** | FK DDL (V3_9) still **safe** on empty tables (new cols default NULL → no orphan rows). **But master-directory linkage/backfill CANNOT be functionally tested on dev** until co_contacts + co_locations are seeded. Gates any dev proof of the auto-complete/link feature, not the DDL. |
| **D-C** | `contactdetails` view | 32 cols, DEFINER kingk436@% | 32 cols, DEFINER kingk436@% | **No drift.** Identical. |
| **D-D** | `recordname` | varchar(500) VIRTUAL = contactFullName | same | No drift. Confirms D1/C3: code writing it is the bug. |
| **D-E** | `contactPhoto` width | varchar(255) | varchar(255) | No drift. **A1 widen 255→500 required in both envs** (V3_7 handles it). |
| **D-F** | WO-1 new columns present | none | **none (0 of 13)** | No collision in either env. V3_7 clean to apply on dev. |
| **D-G** | hot-table collation | utf8mb4_unicode_ci | utf8mb4_unicode_ci | No drift. |
| **D-H** | master-side indexes | present (coName/fullname/location/coid + PKs) | present (same) | No drift. Plan's "skip redundant index adds" holds on dev. |
| **D-I** | engine / tz | 8.0.41 / SYSTEM | 8.0.41 / SYSTEM | No drift. |

Minor: dev `contacts_ss_target` view carries `collation_connection=utf8mb4_0900_ai_ci` (others
general/unicode) — cosmetic creation-time artifact, noted, not actioned.

---

## 3. What this unblocks / what it does not

- **V3_7** — clean to apply on dev (no collision, contactPhoto widen valid). GO once WO-1 dev-exec opens.
- **V3_8** — reconcile PASSED; clear to lift DRAFT (pending the header edit + Kevin's code-commit auth).
- **V3_9** — FK targets confirmed (co_locations PK `colocid`, companies PK `coid`, co_contacts PK
  `id`); safe to create against empty dev master tables. Its own pre-flight orphan/sentinel checks
  will trivially pass on dev (all new FK cols NULL).
- **Still gated:** functional master-directory testing on dev needs co_contacts + co_locations
  **seeded** (D-B). The DDL chain (V3_7→V3_8→V3_9) does not.

## 4. Follow-ups registered (not started)

1. **`contactitems` INVOKER rebuild** (D-A) — dev definer is `root@108.185.100.195`; converge to
   INVOKER like contactdetails/tickets. Own WO, mysql CLI, own proof.
2. **Seed dev master tables** (D-B) — populate `new_development.co_contacts` / `co_locations` (from
   prod or a fixture) so the linkage feature is testable on dev before prod promotion.
