# DIR-LNK-WO-5 — P5 BUNDLE (READ CUTOVER: dev views → primary columns). STOP.

**Binding (verified this session — NN#10 PROCEED):** project TAO-MCD-P1 · series DIR-LNK-WO-1..12 ·
repo `kevinlawrenceking/dev-subdomain` · root `C:\Users\kevin\TAO\dev-subdomain` · branch `dev`.
Binding spec MD5 `078d926d…` (WO-1 header). **Mode:** docs-class — no code, no DDL, no DML, no push.
**Scope of this bundle:** dev-only read cutover (`new_development`). **Prod views UNCHANGED until
WO-12.**

**Provenance:** operator execution capture =
`evidence/2026-07-15-dir-lnk-wo5-p3-operator-execution-paste.md` (Kevin, HeidiSQL, 2026-07-15).
Authoring/validation = `DIR-LNK-WO5-P2-PACKAGE.md` +
`evidence/2026-07-15-dir-lnk-wo5-p2-explain-validation.txt`. Plan of record =
`DIR-LNK-WO5-PLANLOCK.md` (v-final). Runbook = `DIR-LNK-WO5-P3-RUNBOOK.md`.

---

## 1. WHAT CHANGED (dev only)
Five `new_development` views were `CREATE OR REPLACE`-swapped so each single-value Company/Phone/Email
**display** read comes from the `contactdetails` **primary columns** instead of a correlated
`contactitems` item-pick subquery. **Zero CFM/CFC changed** (Class-A reader diffs = 0; every
single-value p/e/c path already reads through a view). Family views `_target/_followup/_maint` were
**not touched** — they `SELECT … FROM contacts_ss` and inherit the repoint.

**Authoritative view DDL (verbatim, class of record):** `database/wo5/WO5_01_views_dev.sql` @
**`beb6c4c0`** (+ rollback `database/wo5/WO5_01_views_dev_ROLLBACK.sql` @ same SHA). Referenced by
SHA rather than re-inlined here to prevent drift; WO-12 prod flip references this SHA.

| view | repoint | live CFM consumer |
|---|---|---|
| `contacts_ss` | `col3→d.contactPhone`, `col4→d.contactEmail`, `col5→d.contactCompany` (tags/col2*, Title, joins, order byte-preserved) | `contacts_ss.cfm` SSP ← `contacts_table.cfm` ← `contacts_all*.cfm`, `contacts_gallery.cfm` |
| `sharezz` | Company scalar subquery → `cd.contactCompany` | `share_contact_details.cfm`, `share.cfm`, `remoteShareViewC.cfm`, `index.cfm`, `export.cfm` |
| `sharez` | Company → `cd.contactCompany` | none (legacy) |
| `sharez_optimized` | Company → `d.contactCompany`; drop `ci_company` LEFT JOIN | none (perf alt) |
| `v_contacts_optimized` | add `contactCompany` to `base` CTE; Company → `b.contactCompany`; drop `company_pick` CTE | none (perf alt) |

---

## 2. BEFORE / AFTER PER SURFACE (operator-attested, `new_development`, userid 30)

| surface / field | BEFORE (item-subquery view) | AFTER (primary-column view) | verdict |
|---|---|---|---|
| `contacts_ss` plan | 10 subqueries, **3 filesort** | 7 subqueries, **0 filesort** | **PASS** (G-8 win by plan) |
| `contacts_ss` COUNT | 979 | **979** (unchanged) | PASS |
| `contacts_ss_followup` plan | 10 subqueries, **3 filesort** | 7 subqueries, **0 filesort** | **PASS** |
| `contacts_ss_followup` COUNT | (no pre-flip COUNT) | **68** (verbatim VIEW_DEFINITION replay == 68) | PASS (flip-independent) |
| Phone display (contacts_ss / family) | item-pick | column; `changes_val=0`, `goes_blank=4` (addendum) | PASS |
| Email display (contacts_ss / family) | item-pick | column; `changes_val=0`, `goes_blank=60` (addendum) | PASS |
| Company display (contacts_ss / sharez / sharezz) | item-pick | column; `changes_val=0`, `company_mismatch=0` | PASS |
| `v_contacts_optimized` Company (8 IDs, unconsumed) | alpha-pick divergent | harmonized to SoT column (R-1) | PASS (harmonized-by-cutover) |

Contacts without a primary render **blank** — the correct post-cutover state, **not a defect**
(RQ-6a / bucket-(b)). The only value movement is the intended 64 value→blank cleanup from the WO-4
addendum (run_id `WO4-DEV-ADDENDUM-20260715-01`, 64 ADMIN_REPAIR audit rows).

---

## 3. BUCKET-(b) ADJUDICATION (the G-2 headline STOP finding)
- **64 exception-class residue** (4 phone + 60 email) nulled by the WO-4 addendum (Option-2 cleanup),
  fully audited (append-only ADMIN_REPAIR rows, reversible). Post-cutover BLOCK C:
  `phone_mismatch = email_mismatch = company_mismatch = 0`; `changes_val = 0`; `goes_blank` == exactly
  the 64. **No surface shows a *different* value** — only value→blank where the item held stale/junk
  the primary column does not. **Adjudication: ACCEPTED as intended cleanup.**
- **8 `v_contacts_optimized` Company divergences** (`130878, 130885, 130891, 130944, 131069, 131089,
  131235, 131294`) — dead view's `ORDER BY valueCompany` alpha-pick vs SoT column. **R-1 (Kevin,
  2026-07-15): HARMONIZATION ACCEPTED, addendum NOT extended.** Unconsumed (no live CFM); cutover
  resolves all 8 to the canonical column. Edge `130943` (empty-alpha) also unconsumed/harmonized.

---

## 4. RQ-6(a) FAMILY BEHAVIOR
Family views inherit `contacts_ss` col3/4/5 unchanged. `contacts_ss_followup` COUNT = 68, confirmed
by replaying the view's **own** `VIEW_DEFINITION` verbatim (userid 30) — the 75 architect base-table
recount was `_tbl`-too-wide and is discarded. Membership is **enrollment-driven, flip-independent.**
**WO-12 carry-forward:** `_followup` filters SystemType + suStatus only; `IsDeleted` is inherited from
the joined views, not explicit — record in the prod family rebuild.

---

## 5. G-8 PERF SPOT-CHECK
**Win by plan comparison** (the required sanity, delivered): 10 subqueries / 3 filesort → 7 subqueries
/ 0 filesort on both `contacts_ss` and `contacts_ss_followup`; the three item-pick filesort subqueries
(phone/email/company) are eliminated; plans strictly lighter; row cardinality unchanged (979).
**Timing caveat (honest):** wall-clock `COUNT` durations were **not captured** either side (one COUNT
lost to a batch-fragment mangle). No timing improvement is *claimed* — the win is structural.

---

## 6. EYEBALL — PASS (operator screenshot + architect row-level verification)
**Attribution corrected (P5-ADDENDUM 4b):** this was the **operator's** full-page screenshot of
Relationships:All (user 30) with **architect row-level verification** — **not** a Jodie pass (Jodie's
optional pass did not occur). Footer **"Showing 1 to 500 of 979 entries"** (== COUNT); rows match DB
capture (`132214` BFR Management, `131171` aj@ajwedding.com, `131680` SH Entertainment, `131068`
Criminal Minds); blanks blank; partial rows correct; family tabs present. Screenshot retained by
operator.

---

## 7. ROLLBACK
- **Two-part rollback authored + committed (class of record @ `beb6c4c0`):**
  1. `database/wo5/WO5_01_views_dev_ROLLBACK.sql` — restores all 5 prior view definitions verbatim
     (P1 live capture).
  2. `database/backfill/wo4/WO4_39_addendum_rollback.sql` — audit-driven restore of the 64 residue
     values (`fwd_rows = restored_cols = 64`; set `@fwd = WO4-DEV-ADDENDUM-20260715-01`).
  - Order for a full revert: **views first, then data** (no reader pointed at a column mid-rollback).
- **Rollback-cycle TEST (G-7 mechanism proof): PASS — full down-and-back exercised by operator**
  (HeidiSQL, `new_development`; see `DIR-LNK-WO5-P5-ADDENDUM.md` §A). Rollback restored the OLD
  item-subquery plan (10 dependent subqueries, ids 3-5 filesort); re-flip restored the NEW
  primary-column plan (7 correlated subqueries #3-#9 per MySQL note 1276), COUNT 979, mismatch 0/0/0.
  Rollback readiness fully proven — script + mechanism + live cycle.

---

## 8. DEV-ONLY DELTA STATEMENT / H-1
- **Prod views UNCHANGED.** This cutover is `new_development` only. Prod family + share views carry
  the old inline subqueries until **WO-12** (backfill + prod view flip); the accepted prod tab drop-off
  (inactive enrollments off `_target/_followup/_maint`) is carried on the WO-12 record.
- **H-1 (restated):** WO-5 changes **zero reader code**, so the reader-code prod hold is
  **satisfied-by-architecture** — the dev branch remains **prod-safe**. The cherry-pick-only doctrine
  is **retained as the general rule** for any future dev-prod-unsafe merge, but no such condition
  exists now.

---

## 9. PASS / FAIL PER CRITERION

| # | criterion | result |
|---|---|---|
| C1 | 5 dev views repointed to primary columns (CREATE OR REPLACE) | **PASS** (5/5) |
| C2 | Zero CFM/CFC reader diffs (cutover is view-DDL-only) | **PASS** (Class-A = 0) |
| C3 | Displayed Phone/Email/Company == primary columns; no-primary → blank | **PASS** (mismatch 0/0/0) |
| C4 | Bucket-(b) 64 adjudicated (value→blank, audited, reversible) | **PASS** (accepted cleanup) |
| C5 | RQ-6(a) family behavior evidenced (`_followup` = 68, flip-independent) | **PASS** |
| C6 | R-1: 8 `v_contacts_optimized` divergences harmonized to SoT | **PASS** |
| C7 | G-8 perf sanity (no regression) | **PASS by plan** (timing not captured — not claimed) |
| C8 | Eyeball (operator screenshot + architect row-level verify) | **PASS** (attribution corrected — §6 / ADDENDUM 4b) |
| C9 | Rollback script covers all 5 views + data | **PASS** (committed @ `beb6c4c0`) |
| C10 | Rollback-cycle test (full down-and-back) | **PASS** — operator ran rollback→OLD plan→re-flip→NEW plan (P5-ADDENDUM §A) |
| C11 | COUNT integrity (979 before == 979 after) | **PASS** |

**Overall: dev read cutover ACCEPTED.** One honest qualifier remains — C7 (G-8 win proven by plan
comparison, not wall-clock; no timing claimed). C10 upgraded PARTIAL→**PASS** by the operator's
down-and-back cycle (see `DIR-LNK-WO5-P5-ADDENDUM.md`). Neither blocks dev acceptance.

---

## 10. SESSION INCIDENTS (no schema/data effect)
Three batch-fragment 1064s (paste contamination) — zero impact; statement-at-a-time + cleared-editor
discipline adopted. One read-only architect side-check error chain (guessed `fusystemtypeid`, guessed
`'Followup'`, `_tbl`-vs-view recount) — resolved by look-don't-guess; no DB effect.

---

## 11. PUSH SET — ⚠ STATE DISCREPANCY (read before any push decision)

The WO instructed me to present the final push set (`a7592171`, `bf85d363`, `a0ac8f8b`, `beb6c4c0`
+ this bundle) and STOP pending a named PUSH GO. **On inspection, those four are already on
`origin/dev`:**

- `git reflog show origin/dev` → `@{0} 989f6732 update by push`, `@{1} 66e49781 update by push`.
- Local `dev` == `origin/dev` == `989f6732`; `git rev-list --count origin/dev..HEAD = 0` (**nothing
  to push**).
- The push at `@{0}` carried `66e49781..989f6732` = the four WO-5 commits **plus an unrelated commit
  `989f6732` "update VSCode settings"** that is **not** part of the declared WO-5 push set but rode
  the same push to `dev`.

**Consequence:** the four-commit "push set" is a no-op — already deployed to `origin/dev`. The **only
uncommitted/unpushed WO-5 artifact is this P5 bundle + P4 evidence** (committed docs-class this turn;
SHA reported below). Given "Auto-deploy CLOSED for dev-subdomain" and "no push without named PUSH GO,"
this prior push is surfaced for the record — it is not something to silently ratify or to rewrite
(pushed history; destructive to unwind). **Decision belongs to the operator.**

**Push set as it actually stands (awaiting named PUSH GO):**
- Already on `origin/dev` (no action): `a7592171`, `bf85d363`, `a0ac8f8b`, `beb6c4c0` (+ non-WO
  `989f6732`).
- **Local-only, pending PUSH GO:** this P5 bundle commit (SHA in the turn report).

---

## 12. HOLD POINTS (unchanged)
No prod DDL/DML; no prod reader-code deploy until WO-12 (H-1); no `contactitems` changes; no linking
work; no item retirement; **no pushes without named PUSH GO**; halt-don't-guess.

**STOP.** Awaiting operator direction on (a) the already-pushed WO-5 docs commits, and (b) PUSH GO for
the P5 bundle commit.

END P5.
