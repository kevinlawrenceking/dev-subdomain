# WO-1 Backfill Part B — outcome: imdbid key DEAD, pivot master linkage to UI

**Binding:** TAO / `dev-subdomain` / branch `dev` · **Date:** 2026-07-07 · **Author:** CC
**Status:** DECISION (evidence-based). Part B backfill **ABANDONED**. No writes performed.
**Method:** read-only viability pre-flight on dev + prod (Diagnostic-First / Evidence-First).

## Evidence
Pre-flight against `new_development` (dev) and `actorsbusinessoffice` (prod):

| scope | metric | value |
|---|---|---|
| dev | active contacts | 1,570 |
| dev | with nm-format imdbid | **0** |
| dev | imdbid = literal `"UNKNOWN"` | 368 |
| prod | active contacts | 46,263 |
| prod | with nm-format imdbid | **0** |
| prod | linking to co_contacts by imdbid | **0** |

`contactdetails.imdbid` holds no real IMDb IDs anywhere — dev is placeholder `"UNKNOWN"`, prod is
empty of `nm…` values. `co_contacts.imdbid` is proper `nm…` format (20,296 distinct, 1,346 dup keys),
but there is nothing on the contact side to join to.

## Decision
- **imdbid backfill linkage — ABANDONED.** Zero yield; not viable on dev or prod.
- **Name backfill — REJECTED as an automated pass.** `contactFullName` ↔ `co_contacts.fullname` is
  fuzzy, collision-prone, and the master side is dirty; auto-linking 46,263 prod contacts would mass-
  produce wrong links (same failure class as the email dedupe dimension).
- **Master linkage PIVOTS to going-forward UI.** The pointers (`master_co_contact_id`, `master_coid`,
  `company_location_id`) get set when a user links a contact to a master entry via autocomplete/search
  at create/edit time. Existing contacts stay unlinked (pointers NULL) until a user links them. This
  matches the feature intent ("auto-complete industry contacts from the master directory").

## Consequences
- **Part A stands** — hot-field denormalization (contactPhone/Email/Company) delivered real value
  (V3_10, dev PASS 276/292/435). Unaffected.
- **V3_9 (FKs) UNBLOCKED.** Part B was the only A2 gate. With all pointer columns NULL, V3_9's
  orphan/sentinel pre-flight passes trivially; the FK constraints are safe to add (they simply
  enforce future UI-written pointers). Can proceed on dev when authorized.
- **New build item registered:** master-link UI (autocomplete/search over co_contacts/companies +
  "link to master" action that writes the three pointers + `_src='master'` where it fills a blank).
  This is where the `_src` provenance and D3 (fill-blank-only) logic actually live — not in a backfill.

## Not done
- No V3_11 written (backfill linkage cancelled).
- V3_9 apply — awaiting authorization.
- D-A (`contactitems` root@ DEFINER INVOKER rebuild) — still open.
