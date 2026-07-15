# DIR-LNK-WO-5 — P5 BUNDLE ADDENDUM (C10 cycle evidence + adjudications). STOP.

**Binding:** TAO-MCD-P1 · repo `kevinlawrenceking/dev-subdomain` · root `C:\Users\kevin\TAO\dev-subdomain`
· branch `dev`. **Mode:** docs-class. Amends `DIR-LNK-WO5-P5-BUNDLE.md` (@ `39fe6b30`) per the operator
relay of 2026-07-15 (BUNDLE ACCEPTED + PUSH RATIFICATION + C10 CYCLE EVIDENCE, 6 items).

**Bundle verdict: ACCEPTED.** C7 qualifier accepted as-is (G-8 win proven by plan comparison; no timing
claim). This addendum upgrades **C10 PARTIAL → PASS**, corrects the eyeball attribution, and records two
architect adjudications (security, byte-preservation).

---

## §A. C10 — ROLLBACK DOWN-AND-BACK CYCLE (operator, HeidiSQL, `new_development`) → **PASS**
Full mechanism proof: revert to the OLD item-subquery views, confirm the OLD plan, re-apply the
committed flip, confirm the NEW plan + data integrity. Operator-attested; raw HeidiSQL grids retained
by operator (paste distilled to the values below).

**a) Rollback run** — `database/wo5/WO5_01_views_dev_ROLLBACK.sql`: **5 statements, clean** (all 5 prior
view definitions restored verbatim).

**b) Revert verified** — `EXPLAIN contacts_ss WHERE userid = 30` = **OLD plan**: **10 dependent
subqueries**, **ids 3-5 "Using filesort"** (the item-pick phone/email/company subqueries are back). This
is byte-for-byte the pre-WO-5 state, including `SQL SECURITY DEFINER` (see §C).

**c) Re-flip** — `database/wo5/WO5_01_views_dev.sql` (identical committed file, quote-aware splitter):
**6 queries, 0.562 sec, only `utf8mb3` warnings** (no errors; deterministic re-application).

**d) Restore verified** —
- **MySQL note 1276** block: **7 correlated subqueries (SELECT #3-#9)** resolved — i.e. the NEW
  primary-column plan with the 3 item-pick filesort subqueries eliminated (matches the first-flip G-8
  AFTER shape of 7 subqueries / 0 filesort).
- `SELECT COUNT(*) … userid = 30` = **979** (== baseline).
- Inverse-direction mismatch summary = **0 / 0 / 0** (phone / email / company).
- **Post-re-flip EXPLAIN grid:** where the raw grid was not re-captured, the plan shape is evidenced by
  (i) the note-1276 count of 7 correlated subqueries #3-#9 and (ii) deterministic re-run of the identical
  committed `WO5_01_views_dev.sql`, per the first-flip **G-8 AFTER** grid (`contacts_ss`: 7 subqueries,
  0 filesort). No independent timing claimed (consistent with C7).

**Result:** the rollback script and the forward flip are both clean, deterministic, and reversible on a
live view set. **C10 PARTIAL → PASS.** Rollback readiness = script (committed @ `beb6c4c0`) + mechanism +
live down-and-back cycle.

---

## §B. EYEBALL ATTRIBUTION CORRECTION (item 4b)
The P4 eyeball pass was the **operator's** full-page screenshot of Relationships:All (user 30) with
**architect row-level verification** (979-entry footer; row matches to the DB capture). **Jodie's optional
pass did not occur.** Bundle §6 heading + C8 label and the P4 evidence §9 heading corrected accordingly;
no change to the PASS result or the underlying observations.

---

## §C. SECURITY FINDING — `SQL SECURITY` mode (architect-adjudicated, item 4c)
- The pre-flip dev views were **`SQL SECURITY DEFINER`** (definer `kingk436@%`) — the MySQL default at
  their creation time, not an intentional privilege choice.
- **WO5_01 upgraded all five views to `SQL SECURITY INVOKER`** per the lock (RQ-6a / PC-4). The rollback
  script restores the prior **DEFINER** state **byte-for-byte** by design (verbatim prior definitions —
  confirmed by §A(b), where the reverted plan is the exact pre-WO-5 view set).
- **INVOKER proven safe on dev** by the live page render (§6 eyeball: the SSP/share surfaces resolve and
  render for the app user with INVOKER semantics; no privilege regression observed).
- **WO-12 carry-note:** the prod flip performs the **same DEFINER → INVOKER upgrade**. At rollout, verify
  the prod app-user table privileges (the account the CF datasource `abo` connects as) can `SELECT` the
  underlying `contactdetails_tbl` / `contactitems_tbl` / enrollment tables the views read — confirm with
  an **eyeball-class check** (render the live Relationships list in prod) before sign-off. INVOKER means
  the querying user's own grants apply, not the definer's.

---

## §D. BYTE-PRESERVATION NOTES (item 4d)
Deliberately preserved verbatim from the P1 live captures (hygiene backlog, **not** WO-5 scope — WO-5
swaps only the p/e/c source expression):
- **`utf8mb3` charset references** — legacy charset on the captured view bodies; surface as deprecation
  warnings on apply/re-apply (§A(c)); byte-preserved, not modified.
- **`sharez` `itemStatus = 'active'` lowercase literal** — legacy case artifact in the captured `sharez`
  definition; preserved as-is.
Both are tracked as hygiene backlog for a future charset/style normalization pass, independent of WO-5.

---

## §E. C10 STATUS — UPDATED CRITERION LINE
`C10 | Rollback-cycle test (full down-and-back) | PASS — operator ran rollback→OLD plan→re-flip→NEW plan
(§A).` Bundle §7 and §9 table updated to match.

**STOP.** This addendum + the P4/P5 bundle (`39fe6b30`) are the closing record for DIR-LNK-WO-5 dev read
cutover. Prod cutover = WO-12 atomic (backfill 64,653 + prod view flip referencing `beb6c4c0`, now
carrying the DEFINER→INVOKER note in §C).

END ADDENDUM.
