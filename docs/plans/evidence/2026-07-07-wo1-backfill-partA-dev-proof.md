# WO-1 Backfill Part A — dev apply proof (V3_10)

**Binding:** TAO / `dev-subdomain` / branch `dev` · **Date:** 2026-07-07 · **Executor:** Kevin (HeidiSQL)
**Env:** dev — `new_development` (confirmed `SELECT DATABASE()`). **Scope:** Part A only (hot fields).
**File:** `database/migrations/V3_10__master_directory_wo1_backfill_partA.sql` (+ROLLBACK).

## Result — PASS
- `preflight` = "OK: contactPhone/Email/Company present -- backfilling"
- Filled (active contacts): **phone 276 | email 292 | company 435** (of 1,570 active contacts)
- Naive ceiling (item-owners incl. deleted/orphan contacts): phone 454 | email 470 | company 614
- **Active-eligible ceiling** (item-owner JOIN active contact): **phone 276 | email 292 | company 435**
  → **equals filled exactly.** The 454/470/614-vs-filled gap was entirely soft-deleted / orphaned
  contacts, correctly skipped by the UPDATE's `cd.IsDeleted = 0` guard. No under-fill, no bug.
- Spot-check (contactID DESC): real values, e.g. 132413 phone `9176876293` / email
  `jodie@jodiebentley.com` / company `Wood Street Pictures LLC`; NULLs only where the contact
  lacks that item type.

## Semantics confirmed
- `_src` columns remain `'user'` (untouched) — values came from the user's own items. Correct.
- Idempotent: re-running recomputes identical values.
- FK-independent: touches none of V3_9's constrained columns.

## Not done / next
- **Part B (master linkage)** — `master_co_contact_id / master_coid / company_location_id` — still
  gated on decisions D1-D4 (recommend imdbid key). See `2026-07-07-wo1-backfill-plan.md`.
- **V3_9 (FKs)** — after Part B on dev + orphan/sentinel pre-flight.
- **Prod promotion** — separate deploy auth; V3_10 re-runs verbatim (`DATABASE()`-scoped).
