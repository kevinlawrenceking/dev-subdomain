# DIR-LNK-WO-7 — P6 ACCEPTANCE BUNDLE

**Work order:** DIR-LNK-WO-7 (link-with-preview modal + bridge disable + snapshot population).
**Branch:** dev · **Project:** TAO-MCD-P1 · **Spec MD5:** 078d926d.
**Status:** P5 EXECUTED + ACCEPTED (operator, 2026-07-23), baseline restored EXACT. Assembled for architect review → docs PUSH GO → **WO-7 close**.
**Deploy of record:** origin/dev `ecaec1bf` pulled to dev, caches cleared, verified live; P5 run against that build.

**Commits of record (pushed, origin/dev = `ecaec1bf`):**
- `51edc8c3` — code — fix relink key collision (S-7), neutral not-found on foreign contactid (S-6).
- `ecaec1bf` — code — neutralize legacy link oracle (S-6 sibling).

**Planned P6-era tidy commit (NOT YET MADE — authored after architect ratifies the open items below; batched, not separate):** S-9 unlink-epoch fix + ratified UI fixes + legacy-endpoint guarded rejection.

---

## 1. Operator P5 report (items 1–10, verbatim)

> **1. DEPLOY:** origin/dev ecaec1bf pulled to dev, caches cleared, verified live. P5 executed by the operator against that build.
>
> **2. BASELINE (captured before any fixture):** ss_rows 983 | active 983 | src_company_master 7 | master_audit_rows 117 | item_rows 2524. Audit decomposition at baseline: ADMIN_REPAIR 69, MASTER_SNAPSHOT_POPULATED 18, BACKFILL_FROM_CONTACTITEM 10, LINK_CREATED 6, PRELINK_VALUE_RESTORED 6, PRELINK_VALUE_PRESERVED 5, PRIMARY_FIELD_CLEARED_AFTER_UNLINK 3 — the first link-event audit rows in the program's history.
>
> **3. PRESERVATION ROUND TRIP (132447) — PASS, the headline result.** Fixture created with three hand-typed primaries (My Old Agency / mine@example.com / 555-0301), linked to master 9104 (Joseph Boyle, Discovery Communications, New York office, company_location_id 1350). Preview disclosed three "moves to Additional info" tags and "3 of your values move". Post-link state: company + phone _src='master' with office values, email NULL _src='master' (Q4 mirror-including-blank), three originals present as active items with correct column routing (Company -> valueCompany, Phone/Email -> valuetext). Audit: 10 rows in perfect symmetry — PRELINK_VALUE_PRESERVED x3 carrying the originals as old_value, MASTER_SNAPSHOT_POPULATED x3 (contactEmail new_value NULL — the Q4 blank recorded as a deliberate write), LINK_CREATED, then on unlink PRELINK_VALUE_RESTORED x3 returning the same values as new_value. Panel after unlink: all three originals back in the PRIMARY fields with pencils (editable, _src='user'), Additional information EMPTY (items consumed), both pointers NULL. Sec 11.4 + R-B proven.
>
> **4. EMPTY-LINK CASE (132448) — PASS.** Linked with no prior values: LINK_CREATED + MASTER_SNAPSHOT_POPULATED x3, no PRELINK rows. Unlink produced PRIMARY_FIELD_CLEARED_AFTER_UNLINK x3 and no phantom restores. Two paths, one code, correct outcomes.
>
> **5. BRIDGE-OFF REGRESSION — PASS.** item_rows held at 2524 across every link performed this session. Under the old path each link minted a Company item (D-19); none were created.
>
> **6. S-1 NEGATIVES (preview include) — ALL FOUR PASS, no data leaked in any:** no session (incognito) -> "Your session has expired."; foreign contactid 90835 -> no data (see item 8a); contactid=abc -> "Contact not found."; parameter omitted -> "Contact not found.". L-6 CLOSES as a non-issue — no CF error, no ErrorService ticket in either malformed case.
>
> **7. S-3 OFFICE-SWITCH RECOMPUTE — PASS.** New York -> Silver Spring in the preview: right-column phone and address both recomputed (+1 212 548 5555 / 850 Third Avenue -> +1 240 662 2000 / One Discovery Place), unchanged rows held, the blank-email amber row correctly persisted (company-wide gap, not office-specific).
>
> **8. S-7 (found in P5, fixed at 51edc8c3) — REPRO NOW PASSES.** a) Discovery: relink-after-unlink to the same master returned {"success":false,"message":"Link failed."}. Rollback verified CLEAN — all primaries NULL, _src='user', both pointers NULL, no partial write. b) Post-fix: 132448 relinked to 9104 successfully; panel rendered gold "In the Book" with the office snapshot. Epoch visible in the keys: WO7:132448:9104:LINK (original) vs WO7:132448:9104:e137:LINK (relink) — collision now structurally impossible, and the epoch propagated uniformly to all rows of each event. c) THREE distinct epochs recorded across the session (e137, e152, e159) with values tracking the chosen office correctly: +1 240 662 2000 (Silver Spring) -> +1 212 548 5555 (New York) -> +1 310 551 1611 (Los Angeles).
>
> **9. FLAG-1 OFFICE CHANGE — PASS** on the panel (LA address + phone + advanced sync stamp) and the snapshot re-wrote at a fresh epoch. [OPEN QUESTION — resolved in §5 of this bundle: S-8 vs S-9.] DOUBLE-SUBMIT — PASS: re-confirming with nothing changed wrote ZERO rows (19 -> 19), so the no-op guard catches the all-unchanged case correctly.
>
> **10. CLEANUP + BASELINE RESTORATION — PASS, EXACT.** Both fixtures unlinked and deleted; re-capture: 983 / 983 / 7 / 2524, identical to item 2. No residue, no attribution needed.

**Restoration note (vs WO-6):** unlike WO-6's close, P5 restored cleanly — every fixture swept, every counter home, no operator-merge attribution required.

---

## 2. Per-criterion matrix (lock §P5 a–k + S-1/S-2/S-3)

| # | Criterion | Result | Evidence |
|---|-----------|--------|----------|
| a | Link, NO existing values (short form) | **PASS** (write/audit); short-form density → see fix-batch #4 | item 4 (132448): LINK_CREATED + SNAP×3, no PRELINK. Short-form density did **not** render because the master carried a headshot (see §6 fix #4) — the write path is correct; the density selector is the open item. |
| b | Link, WITH existing values (full diff, PRELINK_VALUE_PRESERVED) | **PASS** | item 3 (132447): full diff matched DB; PRELINK_VALUE_PRESERVED ×3. |
| c | Multi-office (cards / 6+ list, R-A) | **PASS** | items 3 & 7: NY/Silver Spring/LA offices rendered and switched; company_location_id tracked the pick (1350 NY). |
| d | Blank-master (Q4 mirror) | **PASS** | item 3: email NULL `_src='master'`, MASTER_SNAPSHOT_POPULATED with NULL new_value; item 7 amber row persisted. |
| e | Photo picker | **Attested (P5 COMPLETE); not line-itemized in the report** | Master 9104 carried an image (why short form was suppressed); photo-adopt provenance (2b) not separately transcribed. Recommend the architect confirm from the operator's screenshot set. |
| f | Cancel / "Not the right person?" (zero writes) | **Attested; not line-itemized** | item 10 exact baseline restoration (2524 items, 117→post audit delta only) is consistent with zero stray writes. |
| g | Relink to a DIFFERENT master (MASTER_RELINKED) | **Partial — same-master relink heavily exercised (items 8–9); different-master `MASTER_RELINKED` not separately itemized** | The S-7 focus was same-master relink. Recommend one explicit different-master relink at close-out or note as WO-8 coverage. |
| h | Unlink (Q2 / R-B restore precedence, consume item) | **PASS** | item 3 (restore from consumed items) + item 4 (clear, no phantom restore). |
| i | BRIDGE OFF (D-19 regression) | **PASS** | item 5: item_rows held 2524 across every link; zero Company items minted. |
| j | Negatives incl. double-submit | **PASS** | item 6 (foreign id / no-CSRF / injection / malformed) + item 9 double-submit no-op (19→19). |
| k | WO-6 regression (updatePrimary rejects; contacts_ss shows master values) | **Attested; not line-itemized** | Panel rendered gold "In the Book" with lock (item 8b); explicit edit-rejection probe not transcribed. |
| S-1 | Preview auth/ownership (4 negatives) | **PASS** | item 6, all four. |
| S-2 | Export company from column | **Covered pre-P5** (find_new_Company_115_6.cfm repoint, commit 72153800) | not re-run this session; the reader defect fix is already committed. |
| S-3 | Office-switch disclosure recompute | **PASS** | item 7. |

Honesty note: e/f/g/k rest on the operator's "P5 COMPLETE / every fixture swept" attestation and are not individually transcribed in items 1–10. They are flagged so the architect can spot-confirm from the screenshot/HeidiSQL record rather than assume.

---

## 3. S-7 — discovery, misdiagnosis, correction, fix

**Discovery (P5):** link 132448→9104, unlink, relink-to-SAME-master → `{"success":false,"message":"Link failed."}`; rollback CLEAN (all primaries NULL, `_src='user'`, both pointers NULL). Ordinary user behavior, not an edge case; permanent for that contact/master pair (deterministic keys).

**Architect's first diagnosis — WRONG (recorded for the register):** "the audit write reports zero rows and confirmLink rolls the transaction back." confirmLink does **not** check `record()`'s return — the audit calls at `MasterDirectoryService.cfc:438-464` don't gate `ok`.

**Correct mechanism (CC):** on an `INSERT IGNORE` no-op the MySQL driver returns **no `generatedKey`**, so `val(r.generatedKey)` at `MasterAuditService.record:67` **throws** inside the `cftransaction` → auto-rollback → endpoint `cfcatch` → "Link failed." The same throw sat on the concurrent double-submit path. See [[reference_insert_ignore_generatedkey]].

**Fix (51edc8c3), three hunks / two files:**
1. `MasterAuditService.cfc:67` — `structKeyExists(r,"generatedKey") ? val(r.generatedKey) : 0`. Honors the function's own docstring ("0 when an idempotency_key collision made the insert a no-op"); closes the concurrent-double-submit crash.
2. `MasterDirectoryService.cfc:274-279` — **link-epoch** folded once into `idemBase`.
3. `MasterDirectoryService.cfc:298` — S-6 neutral message (see §7).

---

## 4. Epoch design rationale

**Shape:** link-epoch = pre-mutation `COALESCE(MAX(auditID),0)` for the contact, appended once to `idemBase` (`:e<epoch>`), so every link-path key inherits it (PRESERVE / SNAP / LINK / RELINK + the same-master office-change SNAP).

- **(a) deterministic within a request:** read once from committed state before any write → two concurrent submits of one event read the same `MAX(auditID)` → identical keys → `INSERT IGNORE` dedups the retry.
- **(b) differs across events:** a relink-to-same-master is only reachable after an unlink, and unlink writes RESTORE/CLEAR rows that advance `MAX(auditID)` → the next link event gets a strictly higher epoch → fresh keys. (Also fixes office A→B→A and direct M→N→M siblings.)
- **Chosen over a per-request UUID token:** a token differs between two concurrent submits, which would regress the documented "double-submit cannot double-insert" audit guarantee. The append-only audit log is a monotonic, tick-safe, integer epoch needing no schema change — mirroring the house `run_id` precedent (WO4_10).

**V-1 (no zero-row transition) — PASS by construction:** link/relink emit SNAP×3 + LINK/RELINK (`:438-464`); office-change emits SNAP×3 (`:349-363`); unlink emits RESTORE/CLEAR ×3 — on a linked contact all three primaries are `_src='master'` (writeLinkSnapshot `ContactService.cfc:397-402` + WO-6 read-only enforcement), so each field writes a row (`:601-613`). No-op/rollback paths write zero **and** perform zero transition. The epoch never stalls.

**V-2 (epoch read placement) — reported:** the epoch read is at `MasterDirectoryService.cfc:274-278`, **outside** the transaction (txns begin `:391` main / `:338` office-change), not inside as the relay expected. Not a defect: `INSERT IGNORE` dedups on the **committed unique index at insert time**, not a read snapshot; the committed-double-submit case is caught earlier by the `qOwn` same-master no-op guard (`:328/:334`), also pre-transaction. Moving the read inside would anchor the REPEATABLE-READ snapshot earlier and slightly worsen the `qEq` preserve-item dedup. **Recommend keep-as-is;** flagged for ratification.

---

## 5. S-8 vs S-9 triage (item 9) — decided by code read

**Observation:** 132448 shows **four `LINK_CREATED`** rows but only **one `PRIMARY_FIELD_CLEARED_AFTER_UNLINK` set**; the CLEAR keys carry **no epoch** (`WO7:132448:UNLINK:9104:CLEAR:...`).

**S-8 (office-change path emits LINK_CREATED) — FALSE.** `LINK_CREATED` is emitted at exactly one site: the main link branch else-clause `MasterDirectoryService.cfc:461-464` (reached only when `isRelink=false`, i.e. `master_co_contact_id` blank at entry = unlinked). The same-master office-change branch emits **only `MASTER_SNAPSHOT_POPULATED` ×3** (`:349-363`) and returns; `MASTER_RELINKED` is `:454-459`. The office-change path never writes `LINK_CREATED`.

**S-9 (unaudited unlink from missing epoch in unlink keys) — TRUE.** Four `LINK_CREATED` ⟹ four fresh links from the unlinked state ⟹ the contact was unlinked before each ⟹ ≥3 unlinks to master 9104. `unlinkMaster`'s `idemBase` (`MasterDirectoryService.cfc:537`) = `WO7:<cid>:UNLINK:<prevMaster>` with **no epoch**; the CLEAR/RESTORE keys derive from it (`:613` CLEAR, `:607` RESTORE). Repeated unlinks to the same master produce **byte-identical keys** → post-Fix-1b `record()` returns 0 **silently** → only the first unlink's CLEAR set persists; the 2nd+ unlinks changed state (pointers cleared, primaries reset) but wrote **no audit rows**. This exactly reproduces "4 LINK_CREATED, 1 CLEAR set." **The double-submit PASS (item 9, 19→19) rules out a third explanation** — the all-unchanged case is caught by the state no-op guard, so the extra links were genuine fresh links, each preceded by a (2nd+ silently-unaudited) unlink.

**REGISTER — general risk introduced by Fix-1b:** collisions now fail **silently** (return 0) rather than loudly (throw). An unexpected collision is therefore a **missing audit row**, not an error. Invariant to carry forward: *every deterministic-key audit write must carry an event discriminator, or a legitimate repeat-event silently drops its audit rows.* The confirmLink paths satisfy this (epoch via `idemBase`); `unlinkMaster` was the remaining gap (S-9).

**Fix (for the P6-era tidy commit) — fold the epoch into the unlink keys.** At `MasterDirectoryService.cfc:536-537`:

```cfml
<cfset prevMaster = int(qOwn.master_co_contact_id)>
<cfquery name="qEpoch">
    SELECT COALESCE(MAX(auditID), 0) AS unlinkEpoch
    FROM master_audit_tbl
    WHERE contactID = <cfqueryparam value="#arguments.contactid#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfset idemBase = "WO7:" & int(arguments.contactid) & ":UNLINK:" & prevMaster & ":e" & val(qEpoch.unlinkEpoch)>
```

Each unlink-event gets unique keys (every unlink audited); a concurrent double-unlink of the same event still dedups (same committed MAX). **Alternative (P2 §P2e original):** the design specified unlink keys as **NULL** ("inherently-unique per unlink event"); the implementation deviated to deterministic non-epoch'd keys, which is the root of S-9. NULL keys would also fix S-9 (every row inserts) but drop the concurrent-double-unlink dedup. **CC recommends the epoch approach** (operator-directed; preserves concurrent-dedup; consistent with the confirmLink fix). Architect to ratify epoch-vs-NULL.

---

## 6. Fix batch dispositions (item 10) — for the P6-era tidy commit, NOT committed separately

| # | Item | Site | Disposition |
|---|------|------|-------------|
| — | **S-9 unlink epoch** | `MasterDirectoryService.cfc:537` | **READY** (spec in §5). Ratify epoch-vs-NULL. |
| 1 | Footer "N fields" count unverifiable | `master_link_preview.cfm:341,352` (`kept` = non-blank company+email+phone+address) | **READY, needs "managed field" definition.** `kept` counts *non-blank* values, so a Q4 blank email is not counted though it becomes Book-managed — the count can disagree with the managed rows shown. Direction (operator): count **managed** fields (the three primaries the Book owns: company/email/phone), or restate the sentence. |
| 2 | Match-band "Manager · Manager" duplicate | `master_link_preview.cfm:172` (`masterCo · masterRole`) | **READY.** Add a dedup guard: suppress `masterRole` when it equals `masterCo` (case-insensitive). Confirm the underlying master's `coName`/`jobtitle_type` data with the operator. |
| 3 | Single-office shows no office indicator | `master_link_preview.cfm:178` (`<cfif nOffices GT 1>` — 1 office renders nothing) | **READY.** Add an `nOffices EQ 1` branch rendering a one-line office confirmation (location/address), per spec (collapse, don't omit). |
| 4 | Adaptive short form didn't fire on a no-conflict link | `master_link_preview.cfm:94` (`shortForm = nDisplaced==0 AND nOffices<=1 AND NOT len(masterImg)`), render `:209` | **PATH EXISTS, did NOT trigger — NOT dropped.** It was suppressed because the test master carried a headshot (`len(masterImg)` truthy → a photo choice is offered → full diff). **Architect ratifies:** keep the short form (and perhaps let a photo-only choice still use it), or drop it and make the full diff the default. |
| 5 | Panel title subline absent when no local `contacttitle` | `contact_info.cfm:803-804` (subline only when `len(contacttitle)`) | **NEEDS RATIFICATION + query widen.** "Consider" falling back to the Book's role (`co_contacts.jobtitle_type`), which is not currently selected in the panel's details query — a small widen + a fallback. Architect to approve the fallback and the source. |
| 6 | Legacy endpoint retirement | `ajax/master/link.cfm` → `linkContactToMaster` | **READY (guarded rejection, NOT delete).** Replace the service call with a neutral rejection (e.g. `{success:false, message:"This action is no longer available."}` / HTTP 410) so the direct-POST data-integrity bypass (no preservation / no snapshot / no audit) is closed while the file stays for history. Retirement of the method + `ajax/master/link.cfm` file itself is WO-11 cleanup. |

---

## 7. Known gaps carried to close / WO-8 / WO-11 / WO-12

- **Legacy `ajax/master/link.cfm` orphaned but reachable.** Zero UI callers (the live UI posts to `link-confirm.cfm`); sole caller of `linkContactToMaster`. A direct POST bypasses the entire WO-7 flow (no preservation, no email/phone snapshot, no audit). S-6 oracle neutralized at `MasterDirectoryService.cfc:126` (rider `ecaec1bf`). Guarded-rejection retirement = fix-batch #6 (P6 tidy); full delete = WO-11.
- **S-6 sibling neutralized** (rider `ecaec1bf`): both the confirm (`:298`) and legacy-preview (`:126`) master-not-found paths now return the neutral "Contact not found." (no enumeration oracle).
- **`master_audit_tbl` is now CORRECTNESS-CRITICAL, not merely observability.** The link-epoch derives from `MAX(auditID)` per contact, so pruning / archiving / renumbering that table would resurrect S-7. **Carry into WO-12 retention and any future retention decision.** See [[project_dir_lnk_series]].
- **Backlog:** grep the codebase for other `INSERT IGNORE` (+ `ON DUPLICATE`) whose CF `generatedKey` is read unguarded — same throw. See [[reference_insert_ignore_generatedkey]].
- **P5 criteria e/f/g/k** not individually transcribed (see §2) — spot-confirm from the operator record; consider an explicit different-master relink (g) at close-out.

---

## 8. Screenshots of record (operator-captured; attach to this bundle)

Slots for the operator's P5 screenshots (captured during execution; embed or link on attachment):
1. Preview modal with three offices (NY / Silver Spring / LA) — office picker.
2. Preservation panel (132447 post-link): master values in primaries, three originals in Additional information.
3. Restored panel (132447 post-unlink): originals back in primaries with pencils, Additional information empty.
4. Empty-unlink panel (132448): PRIMARY_FIELD_CLEARED_AFTER_UNLINK state.

---

## 9. Close-out sequence

1. Architect reviews this bundle; ratifies the open items (S-9 epoch-vs-NULL, fix-batch #1 "managed field" definition, #4 short-form keep/drop, #5 title fallback).
2. **P6-era tidy commit** (code, one batched commit): S-9 unlink-epoch fix + ratified UI fixes (#1–#3, #6, and #4/#5 as ratified) — then its own SR-1 PUSH GO.
3. Docs PUSH GO for this bundle → **DIR-LNK-WO-7 CLOSED**. Seven of twelve rungs.

**HOLDS:** no code committed in this turn (bundle is docs-class); no push/deploy without a named SR-1 instrument; the tidy commit awaits ratification of the open items. Prod untouched; WO-7 wrote no DDL.
