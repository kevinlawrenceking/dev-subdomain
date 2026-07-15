# DIR-LNK-WO-4 — P3 Proof Bundle (Dev Backfill Write-Path Proof, Fixture Lifecycle)

**Date:** 2026-07-14 · **Binding:** DIR-LNK series · repo `kevinlawrenceking/dev-subdomain` · branch `dev` · binding spec MD5 `078d926d` (governs).
**Lock:** `DIR-LNK-WO4-PLANLOCK.md` (`f948bc3d`) + line-review relay (`DIR-LNK-WO4-LINEREVIEW-RELAY.md`) + **stamp block D-1..D-4** (`DIR-LNK-WO4-STAMP-BLOCK-D1-D4.md`, `bf618480` — authorization of record).
**Executor:** CC via ratified pymysql write runner (D-3 named exception), schema hard-locked `new_development`, verb+table whitelist enforced in-code before execution, pre-COMMIT gate automation. Fingerprints throughout: `A35-51-468 · kingk436@% · MySQL 8.0.41`.

---

## 0. Executive result

**PASS — all fixture-lifecycle criteria met.** The WO-4 write path (engine selection → paired
audit insert → column update → verification → audit-driven rollback → W-1 re-application →
same-run replay) has now **executed live end-to-end** on new_development against 8 registered
fixtures, with zero effect on any real row. Real-data expected writes were re-proven ZERO
(the WO-3 no-op finding); post-cleanup, every real-data canonical count returned exactly to
its WO-3 baseline. 15 permanent audit rows (D-4) document the full lifecycle.

| Criterion (lock P3 + protocol h) | Result |
|---|---|
| Before/after per-field populated counts reconcile | **PASS** (276/292/436 → 279/293/437 → 276/292/436 post-cleanup) |
| Audit-row count == populated-column count, exactly | **PASS** (3/1/1 per field, both runs; V-2) |
| Idempotent re-run → zero writes (empty selection + key collisions) | **PASS** (F-8: 0 inserts / 0 updates ×3) |
| Exception queue untouched (real buckets unchanged) | **PASS** (real populated counts identical; F8 fixture skipped; all real exceptions unmigrated) |
| Actuals vs live expectation set, delta explained | **PASS** (F-3 predicted 3/1/1 writes + 1 G-LNK + 1 G-WIDTH; actuals identical, delta zero) |
| W-1 lifecycle proof (post-rollback re-application) | **PASS** (F-7: new run_ids inserted 3/1/1 and re-filled 3/1/1) |
| G-REG containment (no audit row outside register) | **PASS** (0, checked after run 1 and after run 2) |
| Real-data zero-write expectation evidence | **PASS** (F-3: 0 real expected writes; every audited contactID ∈ register) |
| `_src` never written | **PASS** (V-3: all 'user') |
| contactitems never mutated by backfill/rollback | **PASS** (5024/122/312647 constant through F-3→F-9; only F-1 setup +13 and F-10 soft-delete touched fixture items) |
| Fixture setup/cleanup wrote zero audit rows | **PASS** (audit count 0→0 across F-1; 15→15 across F-10) |
| Audit append-only held through rollback | **PASS** (15 rows, none deleted/edited; reversal added ADMIN_REPAIR rows) |

---

## 1. Per-case field and expected-outcome table (stamp-block requirement)

Register: `evidence/2026-07-14-dir-lnk-wo4-fixture-register.txt` (`b55295b7`, committed BEFORE
execution per protocol a). Contacts 132428–132435, items 312635–312647 (8 contacts / 13 items).

| Case | contactID | Field | Shape | Expected outcome | Actual (F-5/F-9) | Verdict |
|---|---|---|---|---|---|---|
| F1 one | 132428 | Phone | 1 item 312635 '(310) 555-0141' | write '(310) 555-0141', src item 312635 | exact, sel_case=one | **PASS** |
| F2 multi_one_primary | 132429 | Email | 312636 primary Y + 312637 N | write primary's 'wo4.f2.primary@example.invalid' | exact, src item 312636 | **PASS** |
| F3 rq1 mzp-dupnorm | 132430 | Company | 312638/312639 same name, spacing differs, p=0 | write LOWEST itemID raw 'WO4 Fixture Testing Co' | exact, src item 312638 (raw-representative rule ii) | **PASS** |
| F4 rq1 mm-dupnorm | 132431 | Phone | 312640 '(310) 555-0144' + 312641 '1-310-555-0144', both primary | norm-identical (N-P2 leading-1) → write lowest itemID raw '(310) 555-0144' | exact, src item 312640 | **PASS** |
| F5 rq2 Business+WorkFax | 132432 | Phone | 312642 Business Y + 312643 Work Fax Y, different numbers | write Business '(310) 555-0145'; fax item untouched | exact; 312643 still Active/IsDeleted=0 (V-9) | **PASS** |
| F6 G-LNK probe | 132433 | Phone | linked (master_co_contact_id=1) + usable item | EXCLUDED; counted excluded_G_LNK=1; zero audit | column stayed empty; V-7=0 | **PASS** |
| F7 G-WIDTH probe | 132434 | Phone | 107-char raw (norm non-empty) | EXCLUDED; counted excluded_G_WIDTH=1; zero write | column stayed empty | **PASS** |
| F8 negative mm conflict | 132435 | Phone | 2 different numbers, both primary, same type | NOT eligible; absent from expectation set; zero write | column stayed empty; absent from EX-P | **PASS** |

F-3 expectation set (live, fixtures present): EX-P `one=1, rq1_carveout=1, rq2=1` writes +
`excluded_G_LNK=1` + `excluded_G_WIDTH=1`; EX-E `multi_one_primary=1`; EX-C `rq1_carveout=1`;
real-data rows: **zero**. Actuals matched with zero delta.

## 2. run_id register (permanent audit history, D-4)

| run_id | action_type | field | rows |
|---|---|---|---|
| WO4-DEV-FIXTURE-20260714-PH1 | BACKFILL_FROM_CONTACTITEM | contactPhone | 3 |
| WO4-DEV-FIXTURE-20260714-EM1 | BACKFILL_FROM_CONTACTITEM | contactEmail | 1 |
| WO4-DEV-FIXTURE-20260714-CO1 | BACKFILL_FROM_CONTACTITEM | contactCompany | 1 |
| WO4-DEV-FIXTURE-20260714-PH1-RB | ADMIN_REPAIR | contactPhone | 3 |
| WO4-DEV-FIXTURE-20260714-EM1-RB | ADMIN_REPAIR | contactEmail | 1 |
| WO4-DEV-FIXTURE-20260714-CO1-RB | ADMIN_REPAIR | contactCompany | 1 |
| WO4-DEV-FIXTURE-20260714-PH2 | BACKFILL_FROM_CONTACTITEM | contactPhone | 3 |
| WO4-DEV-FIXTURE-20260714-EM2 | BACKFILL_FROM_CONTACTITEM | contactEmail | 1 |
| WO4-DEV-FIXTURE-20260714-CO2 | BACKFILL_FROM_CONTACTITEM | contactCompany | 1 |

**Total 15 rows** (5 + 5 + 5), append-only proven: nothing deleted or edited at any stage.
W-1 keys observed live, e.g. `BACKFILL:contactPhone:132428:WO4-DEV-FIXTURE-20260714-PH1`.

## 3. Lifecycle narrative (evidence: `evidence/2026-07-14-dir-lnk-wo4-fixture-lifecycle-output.txt`)

F-1 setup: **first attempt GATE-FAILED (8,13 ≠ expected 8,12) and auto-ROLLED-BACK with zero
residue** — the expected count in my sanity comment was an authoring arithmetic error (13 items
is correct: 1+2+2+2+2+1+1+2); corrected + committed (`fe76227d`) before the clean re-run. The
gate mechanism itself is thereby also proven. F-2 register committed pre-execution
(`b55295b7`). F-4 run 1: 3/1/1 audit + 3/1/1 updates, in-transaction sanity equal, gates PASS.
F-5 verification: all criteria green (§0). F-6 rollback ×3: match-guarded reversal, 3/1/1
ADMIN_REPAIR rows, columns re-emptied, diverged_will_skip=0. F-7 run 2 under -PH2/-EM2/-CO2:
inserts succeeded and columns re-filled — **the W-1 deadlock (old key format would have
collided to zero) is empirically disproven**. F-8 same-run_id replay ×3: 0 inserts, 0 updates,
state unchanged — two-layer idempotency proven. F-9 final verify: §0 table. F-10 cleanup:
precheck 8/13 == register, soft-delete, 0/0 live fixtures, gate PASS.

Two script defects were found and fixed during execution (committed before the affected step
ran successfully): in-literal semicolons in the audit `reason` string broke the client
statement splitter (`7697d37b`, `e3580538` — no semantic change); and the runner was taught to
drop comment remnants after inline trailing comments (runner-side only). Neither defect
executed anything wrong — both aborted BEFORE any statement ran.

## 4. Scope and zero-violation confirmations

- **DML scope held:** INSERTs only into contactdetails_tbl/contactitems_tbl (fixtures, user 30)
  and master_audit_tbl (backfill/rollback rows); UPDATEs only on fixture rows (columns + soft-
  delete). **Zero non-fixture rows touched** — proven by G-REG (0 outsiders) and by real-data
  counts returning to exact WO-3 baselines (276/292/436, 1,571 active; items 5024/122/312647
  minus the 13 now-soft-deleted fixture items).
- **Zero DDL. Zero prod access** in the entire stamp-block cycle (every statement ran against
  the hard-locked new_development connection).
- **Runner guardrails:** verb whitelist, INSERT/UPDATE table whitelist, forbidden-token scan
  (DROP/ALTER/CREATE/TRUNCATE/DELETE/GRANT/RENAME), schema assert, pre-COMMIT gates — all
  enforced in-code before execution; one live GATE FAIL → ROLLBACK demonstrated.
- **No pushes:** all commits local; awaiting named PUSH GO.

## 5. WO-4 commit register (this cycle, all local)

| SHA | Content |
|---|---|
| `f948bc3d` | Plan Lock saved verbatim (P0a) |
| `27d366cd` | P1 authoring: scripts + runbook + zero-write validation evidence |
| `ac926fee` | W-1/W-2 applied; fixture assets authored; relay saved (unstamped note) |
| `bf618480` | D-1..D-4 stamp block (authorization of record) |
| `fe76227d` | Fixture item count 12→13 (gate-caught correction) |
| `b55295b7` | Fixture register (pre-execution, protocol a) |
| `7697d37b` / `e3580538` | In-literal semicolon fixes (splitter safety, no semantic change) |
| (this commit) | Consolidated lifecycle output + this bundle |

## 6. Working-file manifest (local, outside repo: `C:\Users\kevin\TAO\_dryrun\dir-lnk-wo3\`)

| File | Bytes | SHA-256 |
|---|---|---|
| wo4-F1-setup-output.txt | 2,790 | `8ffdef299db74ccd0bd26b74da3d9e4e93489cdef1ec619b6312fce3cc99fd1c` |
| wo4-F3-expectation-output.txt | 1,124 | `ce3b44440e20821fcbdd23427985ed0d7d945bad894336bbd5c50ae419fa482c` |
| wo4-F4-run1-output.txt | 1,244 | `d38a1b2f0c1d515c5b766c5750b7ad2c34dd1fe83c62a5e82d1cfe81f0be6a76` |
| wo4-F5-verify1-output.txt | 4,079 | `3a625a85e9718aa0fadca43bd084e50cb96bed2195d89ff19ad5fe938601eb20` |
| wo4-F6-rollback-output.txt | 2,624 | `b5709e7c6668e9f15e8b4dd6231e73d3b753f225a853f1412ce567751fa9c754` |
| wo4-F7-run2-output.txt | 1,203 | `608e0de6b36d3f830b8ef6e4395ecab8501945774d4e14e7b2cb107fbbb0078e` |
| wo4-F8-replay-output.txt | 1,209 | `5109ff1fe9dab804874e1509f994e2337c9e9c8991dbaad249e73e15add895f9` |
| wo4-F9-finalverify-output.txt | 1,857 | `4428508462d77ee06d799c95c5ab02fd8d940df5c59c3400025854ea587dda35` |
| wo4-F10-cleanup-output.txt | 455 | `c64ab235706c0731e6fe6d7f3432068d16aaf31ecd64afeb48569b836693cd05` |

These are also consolidated verbatim into the committed
`evidence/2026-07-14-dir-lnk-wo4-fixture-lifecycle-output.txt` (fixture data is synthetic —
no personal values exist in any WO-4 output).

## 7. What WO-12 inherits

- Scripts of record (reference **by commit SHA** per line review): `database/backfill/wo4/`
  as of this bundle's commit. Prod execution sets WO12-class run_ids and its own chunking; the
  engine, guards, W-1 keys, pairing, gates, and rollback are now execution-proven.
- The fixture contacts/items (132428–132435 / 312635–312647) are soft-deleted, permanently
  registered; the 15 `WO4-DEV-FIXTURE-*` audit rows are permanent test history (D-4).
- Real-data dev backfill remains a structural no-op (V3_10 already did it); the ~1,280-contact
  exception queue and the 73 true conflicts remain unmigrated and active per the standing
  rulings.

**STOP** — bundle delivered per protocol h. No push without a named PUSH GO. WO-5 (read
cutover) is a separate lock.
