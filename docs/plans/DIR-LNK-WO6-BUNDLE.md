# DIR-LNK-WO-6 — P6 BUNDLE

**Work order:** DIR-LNK-WO-6 (linked-contact primary fields: read-only enforcement + unlinked inline edit)
**Binding:** project = TAO / repo = dev-subdomain / root = c:\Users\kevin\TAO\dev-subdomain / branch = dev
**Phase:** P6 — BUNDLE + STOP (per DIR-LNK-WO6-PLANLOCK.md §P6)
**Assembled:** 2026-07-18
**Status:** Assembled for architect review. Docs-class commit only. NO docs push until architect review -> operator PUSH GO (docs). Code push already occurred (P4b + P5 tidy batch, see §Push Set).

## A-6 PIN RECORD (as-executed)

| Pin | Runbook expected | As-deployed (ratified) | Notes |
|-----|------------------|------------------------|-------|
| PIN_PRIOR | a4b68bad | **d1450c2e** | superseded by the ratified UI-4/UI-5 pushes |
| PIN_TARGET (P4b deploy) | 2a4e8dcd | **ae125b98** | superseded by UI-6 + the D-23 predicate fix |
| P5 tidy batch | n/a | **2ecf3d26** | this session; PUSH GO Kevin 2026-07-18 |

Pin read from FETCH_HEAD. Rollback-capture: prior SHA = d1450c2e; sequence = fetch -> checkout target -> **full CF service restart** (flushes template + component + application/session scopes). Tidy-batch rollback: revert 2ecf3d26 / redeploy ae125b98.

Every P5 negative response carried the build marker `"_build":"wo6-update-primary-2026-07-16-v1"` — an unplanned deployment fingerprint proving the SERVICE layer recompiled on dev (the answer to the D-17/B-6 freshness question).

---

## ITEM 1 — SECTION A/B AS-EXECUTED (variance from runbook, all ratified)

PIN_PRIOR = d1450c2e (runbook expected a4b68bad; superseded by the ratified UI-4/UI-5 pushes). PIN_TARGET as deployed = ae125b98 (runbook said 2a4e8dcd; superseded by UI-6 + the D-23 predicate fix). Pin read from FETCH_HEAD. Cache step satisfied by a FULL CF SERVICE RESTART (flushes template + component + application/session scopes). B-1/B-4 landing-check flip NOT captured; superseded by stronger evidence: three-state browser eyeball, architect-verified row-level, screenshots on record — 132436 SYNCED (gold "In the Book", glowing mark, Wilhelmina + office address, sync line), 131068 INTERIM (gray "Linked", dim mark, "Awaiting first sync" pill, no stamp, no provenance claim), 131123 UNLINKED (pencil rows, "Add company/email/phone", outline-book "Find in the Book"). B-5/B-6 PASS.

**Deploy evidence set (of record):** three P4 screenshots — 132436 SYNCED, 131068 INTERIM, 131123 UNLINKED.

## ITEM 2 — SECTION C BASELINE (BASE-1..5, captured before any fixture)

ss_rows 981 | phone_pop 198 | email_pop 180 | company_pop 364 | active_contacts 981 | _src distribution: 975 all-user + 6 with contactCompany_src='master' | master_audit_rows 79 | updatelog_rows 125 (user 30) | item_rows 2524.

Audit decomposition (new evidence): ADMIN_REPAIR 69 + BACKFILL_FROM_CONTACTITEM 10 = 79 (64 = WO-4 addendum, remainder = WO-4 dev fixture-lifecycle proof rows). ZERO LINK_CREATED rows.

## ITEM 3 — TARGETS + FIXTURE REGISTER

T_LINKED 132419 (master 3518) · T_UNLINKED 132439 (fixture) · T_FOREIGN 90835 (userid 1) · Pair X 132441 (master 16251) + 132442 (master 22125) · Pair Y both at 16251 after unlink/relink.

FIXTURE REGISTER (all created this session, all soft-deleted at E-1): 132438, 132439, 132440, 132441, 132442. Stated delta +5 (981 -> 986).

## ITEM 4 — NEGATIVE BATTERY — ALL PASS

Every response carried the build marker `"_build":"wo6-update-primary-2026-07-16-v1"` — an unplanned deployment fingerprint proving the SERVICE layer recompiled (the D-17 freshness question B-6 exists to answer). Results:

- **D-1** no token -> 403 `{"success":false,"message":"CSRF token required"}`
- **D-1b** bad token -> 403 `{"success":false,"message":"Invalid CSRF token"}`
- **D-1c** no session -> 401 `{"success":false,"message":"Authentication required"}`
- **D-2** linked-reject on 132419, ALL THREE FIELDS -> 200 + success:false + the linked-managed message. Zero-write proof: 132419 byte-identical (NULL phone/email, "Morman Boling Casting", company_src master, sync 2026-07-13), leaked=0, audit 79, updatelog 125.
- **D-3** tenant isolation (90835 while authed as user 30) -> 200 "Contact not found." (no enumeration oracle). Row unchanged (userid 1, phone 9176876293), leaked=0.
- **D-4** oversize: 101 chars -> "Primary phone is limited to 100 characters. Nothing was saved."; 153 -> email/150 equivalent; 256 -> company/255 equivalent. Clean rejects, no truncation. TRIM BOUNDARY: 100 nines + 3 encoded trailing spaces -> success:true; stored LENGTH=100, has_trailing_space=0 — the length test provably runs AFTER trim().
- **D-5a** extra contactPhone_src=master param riding a legit save -> success:true with data.src="user" (param never read).
- **D-5b** field=contactPhone_src -> success:false "Unknown field." (cfdefaultcase).
- **D-5c** bypass-shaped params (isMaster=1&trusted=1&bypass=1&master_co_contact_id=&userid=99) -> phone saved only; final row 555-0112, src user, userid still 30. non_user_src=6 (the legitimate bridge rows), leaked=0.
- **D-6** CREATE injection via the real door (/include/remoteAddNameAdd.cfm, 302 -> contactid=132442) carrying BOTH injected _src=master AND injected primaries: every _src='user', pointer NULL — AND the primaries did not land either. FINDING: that handler builds its own field struct (name/birthday/meeting date+loc/pronoun/referral) and drops everything else, so create()'s new allowedFields entries for the three primaries are currently UNEXERCISED (no caller passes them). The other half of Option A (INSERT target view -> contactdetails_tbl) IS exercised by every create and shows no regression.
- **D-7** same-value re-submit x2 -> both success:true "Saved." The zero-affected-rows disambiguation working; endpoint is connector-config independent as designed.

## ITEM 5 — D-5d (adjacent door, /include/remoteUpdateNameUpdate.cfm) — SATISFIED-BY-GATE + PARTIAL, with CORRECTION OF RECORD

First attempt (no token) returned 403 "Security token missing or invalid". **CORRECTION OF RECORD:** the /include tier is NOT uniformly ungated — remoteUpdateNameUpdate.cfm AND remoteAddNameAdd.cfm both validate csrfToken. The P1/P2 characterization must be amended in the bundle; do not report a nonexistent exposure. Retry WITH a token returned 500 (ticket ERR-A5DD559C) because the architect's probe payload omitted the handler's required name fields — malformed probe, not a defect; zero writes confirmed (leaked=0). Incidental: ErrorService caught it, minted the ticket, rendered the branded error page — unplanned proof of the Phase-2 error pipeline on dev. **ERR-A5DD559C is a P5 TEST ARTIFACT** — registered as such so it is not investigated.

## ITEM 6 — D-8 MERGE GUARD (Q1b) — BOTH HALVES PASS

On the real UI door (/include/merge_contacts_interface.cfm, reachable directly with any two contactIds; the duplicates page is only a convenience list):

- **PAIR X** (132441 master 16251 vs 132442 master 22125) -> BLOCKED, banner verbatim: *"These contacts are linked to two different TAO Master Directory records. Unlink one of them first, then merge."* Zero writes: both rows active, both pointers intact, audit 79. (NOTE: this verbatim banner is the pre-tidy copy; the P5 tidy batch 2ecf3d26 reworded the guard to *"...two different records in the Book..."* — see §Tidy Batch.)
- **PAIR Y** (132442 unlinked then relinked to 16251, same master) -> "Contacts merged successfully. (merge #16)". Post-state: 132441 active, company "The Operating Room", company_src master, pointer 16251; 132442 isdeleted=1.

The guard discriminates correctly — different masters blocked, same master passes.

## ITEM 7 — D-9 ROUND-TRIP + D-22 CLOSURE — PASS

Fixture 132439 edited through the panel UI; contactdetails_tbl shows 555-0199 / wo6.final@example.com / "Fixture Co Edited" with all three _src='user'; contacts_ss col3/col4/col5 show the IDENTICAL values with no intermediate step. That is D-22 closed end to end: WO-5 made the views read columns, WO-6 made the app write them. updatelog_rows unchanged at 125 after all of D-9 -> the P2e (ii) accept-unlogged ruling holds empirically.

Class-B: 132439 carries a user-added Email item (another@gmail.com, active) proving item editing works on an unlinked contact.

- **[PENDING operator confirm]** item grid header reads "Additional information": YES / NO.
- **[PENDING operator confirm]** item add/edit on a LINKED contact (132436) works and moves item panes only, locked primaries unmoved: YES / NO.

## ITEM 8 — SECTION E — CLEANUP + E-2 VARIANCE (honest record)

All five fixtures soft-deleted (132438/39/40/41 by UI delete, 132442 via merge #16). E-2 one-row capture: ss_rows 979 | 199 | 180 | 363 | active 979 | src_all_user 974 | src_company_master 5 | audit 79 | updatelog 125 | item_rows 2524.

**TEST-RESIDUE COUNTERS EXACT:** audit 79, updatelog 125, item_rows 2524 all returned to baseline — the battery left no residue.

**CONTACT-MEMBERSHIP VARIANCE -2**, FULLY ATTRIBUTED via contact_merge_log to two OPERATOR merges run during the session, outside the fixture set: merge #17 (2026-07-18 14:32:47, keeper 131308 <- discard 131376, both unlinked; explains src_all_user -1 and phone_pop +1 via the merge field-picker) and merge #18 (14:33:08, keeper 131204 <- discard 132419; explains src_company_master -1 and company_pop -1).

**RULING (architect):** E-2 records as "baseline not restored to 981; drift fully attributed to operator merges #17/#18; test-residue counters exact; baseline restated to 979 going forward." No undelete, no correction.

## ITEM 9 — NEW FINDINGS FOR THE REGISTER (all evidenced this session)

a) **D-23 EXTENDED** — old bridge behavior of record: stamps master_last_sync on EVERY link; writes contactCompany + _src='master' ONLY when the column was blank; never writes email or phone; a RELINK overwrites a master-sourced company with the new master's value (132436 went Wilhelmina Models -> DVD Plus International at 2026-07-17 13:45); an UNLINK CLEARS the master-sourced company (132442 rendered "Add company" immediately after unlink). The unlink-clears behavior is direct input to WO-7's Q2 sanctioned-unlink semantics: leave / blank / restore pre-link.

b) **AUDIT ASYMMETRY:** merges are logged (contact_merge_log + contact_merge_map, with keeper/discard/timestamp/rows_affected) while LINKS ARE NOT — zero LINK_CREATED rows against ~14 linked contacts. WO-7 wiring link events into the 13-action vocabulary is the first time linking becomes auditable.

c) **D-19 QUANTIFIED:** contact 132441 accumulated THREE bridge-created Company items from three link events (Fonco Creative Services, "The Operating Room" TWICE — no dedupe on relink). WO-11 scope is larger than the single registered row 312621; WO-11 recon must count bridge items fleet-wide, including duplicates.

d) **Q1a LIVE SPECIMEN (D-15 class):** merge #18 left discard 132419 soft-deleted WITH master_co_contact_id=3518 STILL SET, while keeper 131204 has a NULL pointer and inherited nothing. An orphaned pointer on a deleted contact, plus that contact's bridge-created item (312621) now hanging off a deleted row. This is the exact shape Q1a rules on (TRANSFER the link to the keep) — registered as a live known gap owned by the merge-owning WO, NOT a WO-6 failure.

e) **CLASSIFICATION SET CORRECTION** (by enumeration query, superseding every screenshot-derived list): SYNCED = 131075, 131171, 131949, 132097, 132419, 132436. 131667 is INTERIM. Two earlier architect readings (132419 and 131667) were wrong and mutually canceling, which is why the count of 6 always held. The bundle carries the enumerated set as authoritative.

f) **D-24 .git EXPOSURE:** the repo lives in the docroot (C:\home\theactorsoffice.com\wwwroot\dev-subdomain\.git). HTTP probes of /.git/refs/heads/dev and /.git/FETCH_HEAD both 404 via the IIS rewrite/extensionless handler — ACCIDENTALLY blocked, not explicitly denied. Add an explicit web.config deny at the next code touch; VERIFY PROD BLOCKS IT — mandatory WO-12 checklist item. (Status: the P5 tidy batch 2ecf3d26 did NOT carry the deny — item 10 scoped the code touch to three changes only; the deny remains OPEN and registered to WO-12.)

g) **COOKIE INFO DISCLOSURE** (pre-existing, backlog): BROWSER_CONTACT_AVATAR_FILENAME and UPLOADDIR_CONTACT carry absolute filesystem paths to the browser.

h) **BUG-1** (pre-existing, UI-7 candidate): the contact-name lookup in the Add modal fires its XHR and returns rows, but the suggestion dropdown never renders — backend alive, frontend suppressed inside the modal.

i) **UI-7 CANDIDATE:** the Add modal has no company/phone/email fields, so D-22 closure rests entirely on the panel path (proven working). Adding them would activate create()'s already-built whitelist entries. Operator ruling pending; NOT WO-6 scope.

j) **MERGE INTERFACE COPY** predates primary fields ("All emails, phones, notes, events, auditions and reminders from the removed contact move to the kept one") and says nothing about links — copy pass owned by the merge-owning WO.

---

## PER-CRITERION PASS/FAIL (against DIR-LNK-WO6-PLANLOCK.md §P5 a–i)

| Criterion | Verdict | Evidence |
|-----------|---------|----------|
| **a) LINKED READ-ONLY, EVERY DOOR** | **PASS** | D-2 (all three fields rejected server-side on 132419, byte-identical zero-write proof: columns/_src/items/updatelog/audit all unchanged); reinforced by D-5a/b/c (param spoof ignored/rejected) and D-6 (create-door injection dropped). Negative battery D-1/D-1b/D-1c gate every door on CSRF/auth. |
| **b) TENANT ISOLATION** | **PASS** | D-3 — authed as user 30, edit on 90835 (userid 1) -> "Contact not found", no enumeration oracle, row unchanged, leaked=0. |
| **c) BYPASS SPOOF** | **PASS** | D-5a (extra _src param never read, data.src="user"); D-5b (field=contactPhone_src -> "Unknown field." via cfdefaultcase); D-5c (isMaster/trusted/bypass/userid=99 all inert; userid still 30, src user). Enforcement not client-disableable. |
| **d) OVERSIZED VALUES** | **PASS** | D-4 — 101/153/256 clean rejects with per-field messages, no truncation, no write; trim boundary proves length test runs AFTER trim() (stored LENGTH=100, trailing_space=0). |
| **e) UNLINKED EDIT ROUND-TRIP** | **PASS** | D-9 — 132439 edited via panel; contactdetails_tbl + contacts_ss col3/4/5 identical, no intermediate step; all _src='user'; updatelog unchanged=125 (P2e (ii) accept-unlogged holds empirically). |
| **f) CREATE PATH** | **PASS (with finding)** | D-6 — create via /include/remoteAddNameAdd.cfm succeeds; INSERT target view -> contactdetails_tbl exercised by every create, no regression. FINDING: the handler builds its own field struct and drops the three new primaries, so create()'s new whitelist entries for company/email/phone are UNEXERCISED (no caller passes them). D-22 closure therefore rests on the panel path (criterion e, proven). Activating them = UI-7 candidate (item 9i), not WO-6 scope. |
| **g) MERGE GUARD (Q1b)** | **PASS** | D-8 — Pair X (different masters) BLOCKED with banner, zero writes; Pair Y (same master after relink) merged #16. Guard fires before the transaction opens. |
| **h) CLASS-B** | **PARTIAL — 2 operator confirms pending** | D-9 Class-B proves item editing on an UNLINKED contact (132439 user-added email item). PENDING: (1) item grid header reads "Additional information"; (2) item add/edit on a LINKED contact (132436) moves item panes only with locked primaries unmoved. Both are operator eyeball confirms. |
| **i) REGRESSION** | **PASS (with attributed variance)** | Test-residue counters EXACT (audit 79 / updatelog 125 / item_rows 2524 all back to baseline). Membership -2 fully attributed to operator merges #17/#18 (outside the fixture set). Architect ruling: baseline restated to 979 going forward; no undelete. |

**Overall:** all enforcement/round-trip/guard criteria PASS. Two operator eyeball confirms (h) outstanding; one create-path finding (f) recorded as an unexercised-whitelist observation, not a defect.

---

## DEPLOY / CACHE / LIVENESS / ROLLBACK-CAPTURE RECORD

- **Deploy (P4b):** d1450c2e -> ae125b98, pin read from FETCH_HEAD.
- **Cache:** full CF service restart (template + component + application/session scope flush).
- **Liveness:** build marker `"_build":"wo6-update-primary-2026-07-16-v1"` on every P5 response = service layer recompiled on dev. B-5/B-6 PASS.
- **Rollback capture:** prior SHA d1450c2e; sequence fetch -> checkout d1450c2e -> full CF service restart.

## CODE PUSH SET (SHAs)

| SHA | Class | Gate | Pushed |
|-----|-------|------|--------|
| ae125b98 | code | P4b (UI-6 + D-23 predicate) | prior (ratified) |
| **2ecf3d26** | code | P5 tidy batch | 2026-07-18 (PUSH GO Kevin) |

The P6 gate authorizes the DOCS push of THIS bundle only (amendment A-6). No further code push is authorized here.

## ENUMERATED CLASSIFICATION OF RECORD (authoritative, by enumeration query)

- **SYNCED** (linked AND contactCompany_src='master'): 131075, 131171, 131949, 132097, 132419, 132436.
- **INTERIM** (linked, not yet synced): 131667.
- Supersedes every screenshot-derived list. Two earlier architect readings (132419, 131667) were wrong and mutually canceling, so the count of 6 held throughout.

## CORRECTED /include CSRF CHARACTERIZATION (amends P1/P2)

The /include tier is **NOT uniformly ungated**. Both `/include/remoteUpdateNameUpdate.cfm` AND `/include/remoteAddNameAdd.cfm` validate `csrfToken` (403 without a valid token). The P1/P2 characterization that implied a broad /include exposure is amended here; **do not report a nonexistent exposure.** ERR-A5DD559C (the token-carrying retry) was a malformed probe (missing required name fields) -> 500 with zero writes -> registered as a P5 TEST ARTIFACT, not a defect. The error was caught by ErrorService, ticketed, and rendered the branded error page — incidental live proof of the Phase-2 error pipeline on dev.

## LIVE KNOWN GAPS (restated as gaps, NOT WO-6 failures)

1. **Q1a live specimen (D-15 class):** merge #18 left discard 132419 with master_co_contact_id=3518 still set while keeper 131204 inherited nothing (NULL pointer); bridge item 312621 now hangs off a deleted row. Ruling shape: TRANSFER the link to the keep. Owned by the merge-owning WO.
2. **/include exposure profile (as corrected):** both remote handlers gate on csrfToken (above). No broad /include primary-write exposure exists.
3. **selfCsrfPaths opt-outs:** `/ajax/importv3/` + `/ajax/import-auditions/` remain CSRF opt-out paths — pre-existing, unrelated to WO-6, registered.
4. **create() whitelist admits userid/isdeleted with no session override:** the create allowedFields set includes userid/isdeleted; no session-scoped override guards them. Pre-existing shape, registered; the D-6 spoof did not exploit it (userid=99 was inert because the handler never passed it), but it stays on the register.
5. **D-24 .git exposure:** repo in docroot; /.git/* accidentally 404s via IIS rewrite, not explicitly denied. Explicit web.config deny + PROD verification = mandatory WO-12 checklist item. The P5 tidy batch did NOT carry the deny (item 10 scoped to three changes); OPEN.
6. **Cookie info disclosure** (9g), **Add-modal lookup dropdown BUG-1** (9h), **UI-7 create-modal primary fields** (9i), **merge interface copy** (9j) — all registered, none WO-6 scope.

---

## P5 TIDY BATCH — commit 2ecf3d26 (as-built, with variances)

One code-class commit (commit-approved; PUSH GO Kevin 2026-07-18), pushed to origin/dev. Confirmed origin/dev == 2ecf3d26.

- **(a) Company primary-field icon** — `mdi-office-building-outline` -> `mdi-briefcase-outline` (include/contact_info.cfm:821). **Root cause:** `mdi-office-building-outline` is not a class in the loaded MDI set (only `mdi-office-building` and `mdi-briefcase-outline` exist), so the company row rendered no icon while its `mdi-email-outline` / `mdi-phone-outline` siblings did — exactly the architect's "phone/email carry icons, company does not." **AS-BUILT VARIANCE** from the relay's literal "reuse fe-briefcase verbatim": the row `<i>` hardcodes the `mdi` font family (contact_info.cfm:827) and its siblings are mdi-outline; a feather `fe-briefcase` glyph would not render inside `class="mdi fe-briefcase"` and would clash visually with the outline siblings. `mdi-briefcase-outline` is the in-family briefcase and matches the sibling style. Flagged for architect ratification.
- **(b) L-4 comment (contact_info.cfm:163)** — **NO CHANGE; already satisfied.** The current-tree comment (committed 6121b8375, 2026-07-16) already states the file is still included by include/qry/findcompany.cfm:4 and registers the pair to the qry-elimination list as a dead chain. The stale "its only consumer" wording the relay quotes survives only in docs/plans/DIR-LNK-WO6-P4-RUNBOOK.md:461 (docs), not in the code. (Third instance this program of the flagged stale-relay pattern — verified against current tree, no fabricated diff.)
- **(c) Book vocabulary in user-facing reject/guard copy:**
  - ContactService.updatePrimary() linked-managed message: "the TAO Master Directory ... managed by the directory" -> "the Book ... managed by the Book" (services/ContactService.cfc:358).
  - ContactDuplicateService Q1b block: "two different TAO Master Directory records" -> "two different records in the Book" (services/ContactDuplicateService.cfc:522).
  - contact_info.cfm unlink confirm: "Unlink this contact from the directory?" -> "... from the Book?" (contact_info.cfm:1585) — the one remaining user-facing straggler; the panel already speaks "the Book" throughout. Filesystem "directory" comments (751/756) left untouched.

Diff: 3 files, 4 insertions(+), 4 deletions(-).

---

## RULINGS OF RECORD

- **Q1a** (merge inheritance / orphaned pointer): TRANSFER the link to the keep — owned by the merge-owning WO; live specimen at 132419 (item 9d).
- **Q1b** (merge guard on two-different-masters): BLOCK — implemented and proven (item 6); guard fires pre-transaction.
- **P2e (ii)** (accept-unlogged): primary edits do NOT write the general edit log — holds empirically (updatelog steady at 125 across the full battery).
- **D-22** (columns write -> views read): CLOSED end to end via the panel path (item 7).
- **E-2** (baseline): baseline restated to 979; drift attributed to operator merges #17/#18; test-residue counters exact; no undelete (item 8).

## OUTSTANDING BEFORE CLOSE

1. Operator confirm (h): item grid header = "Additional information".
2. Operator confirm (h): item add/edit on a LINKED contact (132436) moves item panes only, locked primaries unmoved.
3. Architect ratification of the tidy-batch icon variance (mdi-briefcase-outline vs literal fe-briefcase).
4. Architect review of this bundle -> operator PUSH GO (docs) -> close.

---

**STOP for architect review.** No further pushes beyond the P5 tidy commit (2ecf3d26) without a named PUSH GO. The P6 docs push of this bundle is a separate gate after architect review. No DDL, no DML, no audit writes.

*END — DIR-LNK-WO6-BUNDLE.md*
