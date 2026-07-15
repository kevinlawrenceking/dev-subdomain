# DIR-LNK-WO-6 PLAN LOCK v-final (LINKED/UNLINKED UI ENFORCEMENT + PRIMARY WRITE PATHS) — OPERATOR AMENDMENTS A-1..A-6 FOLDED

> Saved verbatim from the operator relay (2026-07-15). Numbered sections 1-6, END marker closes.
> Halt-don't-guess. Relays carry payloads; committed repo files count as payloads.

## SECTION 1 — BINDING + AUTHORIZATION
project: TAO master-linking program (DIR-LNK series)
repo: kevinlawrenceking/dev-subdomain
root: C:\Users\kevin\TAO\dev-subdomain
branch: dev
workstream: DIR-LNK-WO-6 (spec ladder step 6: linked/unlinked UI enforcement). Binding spec MD5
078d926d governs over this summary.
AUTHORIZATION (per operator amendment A-2): approval of this lock authorizes P0-P2 ONLY. P3 code
authoring requires explicit approval of the P2 design memo and the Q1 rulings. Code commit, push, and
dev deployment remain separately gated at their P4 marks. No prod anything. WO-7..12 untouched.

## SECTION 2 — RULED BEHAVIOR OF RECORD (implement, do not relitigate)
a) Unlinked contacts: primary phone/email/company are directly user-editable contact fields. Linked
   contacts (master_co_contact_id IS NOT NULL): all three primaries are READ-ONLY and master-managed.
   contactitems = additional information, always editable on any contact.
b) Primary edits write contactdetails_tbl columns ONLY (house rule: _tbl for writes, views for reads).
   Primary edits never write items; item edits never write primaries. Post-WO-5, list/share surfaces
   read columns, so item edits on a linked contact visibly change ONLY the item panes — expected, not a
   defect.
c) ENFORCEMENT SHAPE (per operator amendment A-3 — binding implementation requirements, not guidance):
   - Server-side at the service/endpoint layer; zero triggers; UI read-only states are presentation on
     top of it.
   - Every user primary update MUST: verify the contact belongs to the authenticated user; reassert the
     unlinked predicate AT THE WRITE SITE; prefer a single conditional UPDATE keyed on contactID +
     userid + master_co_contact_id IS NULL; verify exactly the expected row count was affected; treat
     zero-row results as REJECT with no data modified. No read-then-update sequence that can race.
   - The system/master write path (MasterDirectoryService's own writes; the old bridge remains live
     until WO-7 by spec bridge-sequencing) bypasses enforcement ONLY via a separate trusted internal
     service method or server-created execution context. NO client-supplied parameter (system flag,
     actor type, bypass token, or similar) may disable enforcement.
   - Rejected requests return {success:false, message:...} and write nothing: no primary column, no
     _src, no item, no general edit log entry, no master audit row.
d) User primary edits are ordinary contact edits: ZERO master_audit_tbl rows (the 13-action vocabulary
   is master-link lifecycle only — do not invent actions). General edit logging is governed by the P2
   ruling under amendment A-6 (see P2e) — do not assume the existing mechanism covers these columns.
e) Unlinked primary writes set the matching _src='user' defensively. Photo (contactPhoto/_src) is OUT
   of WO-6 unless the spec's enforcement sections explicitly include it — extract and report at P0, do
   not assume.
f) D-22 accepted-by-progression: the go-forward write gap closes via this WO's write paths. Old
   DIR-WO-2 link/unlink control stays as-is (bridge disable is WO-7's first act; dev-only exposure
   until then, registered).

## SECTION 3 — PHASES AND GATES
P0 — BINDING VERIFICATION, THEN BOOTSTRAP (per operator amendment A-1; read-only until the lock commit)
  a) FIRST ACTIONS, in order, before writing or committing anything: verify repo root, branch=dev,
     CLEAN working tree, and origin/dev HEAD (report the SHA found); read the canonical role/project
     instructions from the working tree (00-PROJECT-INSTRUCTIONS.md or successor). HALT on any mismatch
     — dirty tree, wrong branch, unexpected HEAD, or instruction conflict with this lock.
  b) Only after (a) passes: save this lock verbatim to docs/plans/DIR-LNK-WO6-PLANLOCK.md, docs-class
     local commit.
  c) Required reading (one-line gist each in the echo): binding spec; DIR-LNK-WO5-P1-DELTA.md (Class-B
     inventory); DIR-LNK-WO5-P5-BUNDLE + addendum; WO1-RECON §3 reader/WRITER inventory; the WO-DUPES
     merge commits touching merge behavior (57c261b5 lineage) as they exist on dev.
  d) SPEC EXTRACTION (exhaustive, not list-limited): every section governing linked read-only
     enforcement, unlinked editability, items-as-additional framing/copy, photo scope, master-managed
     indicator/badge presentation, and ANY spec coverage of merge or import against linked contacts (Q1
     material). Quote anchors verbatim in the recon doc. Where the spec is silent, say silent.
  Then proceed to P1 — no STOP unless P0a halts or something contradicts this lock.
P1 — RECON (read-only; code + ratified DB read channel), then STOP
  a) WRITE-SURFACE INVENTORY: every surface and endpoint that can create or modify phone/email/company
     data today — contact page item editors, add-contact form, setup wizard steps, Import V2/V3
     staging+finalize, merge, phonebook, every /ajax/ item endpoint. For each: file:line, what it writes
     (items vs columns), auth/CSRF posture.
  b) CREATE-PATH STATUS: confirm live whether ContactService.create() still inserts via the
     contactdetails VIEW (registered defect); document the exact insert target and column list.
  c) CLASS-B FINAL LIST: the per-item editor surfaces (contact_pane.cfm, contact_info.cfm loops, +any
     P1-delta candidates) with the exact blocks needing the "Additional info" reframe and the
     primary-block insertion point (include UI-1/UI-2/UI-3 polish targets: trigger size/affordance,
     last-sync line, blank-company placeholder — they live on this block).
  d) EDIT-LOGGING STATUS: what UpdateLogService/updatelog_tbl currently capture for contact edits; state
     plainly whether primary-COLUMN edits would be captured today. This feeds the P2e ruling — no
     "unchanged" hand-wave.
  e) MERGE TRACE (read code, no test writes): current behavior when a merge involves a linked contact —
     link pointers on keep and discard; risk statement for Q1a/Q1b.
  f) Deliver DIR-LNK-WO6-P1-RECON.md (docs-class), STOP.
P2 — DESIGN MEMO + RULINGS GATE, then STOP
  a) ENFORCEMENT MATRIX: surface x link-state x behavior (edit allowed / read-only / rejected), with the
     exact service methods and endpoints enforcing, each conforming to the Section 2c shape. The matrix
     is the authoritative endpoint list for P5's negative tests.
  b) Write-path design: primary edit UI on the contact page; add-form and wizard create paths writing
     primaries to _tbl (fixing or routing around the view-insert defect for these columns — whichever is
     smaller, stated); reject shape and message copy; oversized-value handling = clean reject, never
     silent truncation.
  c) UI spec: primary fields block (editable vs read-only + master badge reuse from the DIR-WO-2 shell),
     "Additional info" reframe copy, UI-1/2/3 disposition (in if confined to this block; defer with
     reason if not).
  d) IMPORT/MERGE PRIMARY ADOPTION recommendation: whether Import V2/V3 and merge begin writing
     primaries for unlinked contacts in WO-6 or a named follow-on. Architect default: DEFER to a named
     pass (WO-6B or ride WO-7) — recommend with counts, do not assume.
  e) EDIT-LOGGING RULING (per operator amendment A-6): if P1d proves primary-column edits are NOT
     captured today, the memo must present the explicit choice — (i) extend the ordinary contact-edit
     logging mechanism within WO-6, or (ii) accept these edits as not generally logged — with the
     architect recommendation and cost. Operator rules at this gate. No silent default.
  f) Q1 RULINGS REQUESTED (spec-answer where P0 extraction covers it; operator rules the silent ones):
     Q1a merge, discard is linked: transfer link to keep, or drop with audit trail.
     Q1b merge, both linked to different masters: architect lean = BLOCK the merge, require deliberate
         unlink first.
     Q1c merge vs linked keep: master-managed primaries untouchable; discard's differing values
         preserved as non-primary items (PC-1 pattern); PD-1 value-union applies to items only.
     Q1d import rows targeting a linked contact's p/e/c: divert to non-primary items + flag in import
         summary; never write master-managed primaries; WO-9 corrections are the sanctioned change path.
     Q1e (=D-22) unlinked go-forward: create/edit paths write primaries directly; items additional.
         (This lock presumes Q1e for its core scope; the ruling formalizes it.)
     WO-6 implements only what its scope needs (enforcement + Q1e + the merge GUARD if Q1b rules block);
     Q1a/c/d implementations land in their owning WOs — rulings captured now so WO-7..9 inherit them.
  g) STOP. P3 authoring begins only on explicit operator approval of this memo + rulings (per amendment
     A-2).
P3 — AUTHORING (post-P2-approval; no commit until commit-approved), then STOP
  Minimal diffs; cfqueryparam on every input; CSRF per house /ajax/ convention; {success,message,data}
  returns; idempotent endpoints; transactions where a save touches multiple tables; conditional-UPDATE
  enforcement per Section 2c in every user write path; no view DDL; no schema changes (columns exist — a
  genuine gap is a separate migration decision surfaced at the STOP, not assumed); no emojis anywhere.
  Deliver diffs + file list for line review, STOP.
P4 — COMMIT + PUSH + DEPLOY (each its own authorization)
  a) Commit-approved -> code-class commit(s), SHAs reported.
  b) Named PUSH GO -> push (this push exists to feed the Hostek pull).
  c) PRE-DEPLOY ROLLBACK CAPTURE (per amendment A-6): record the prior known-good deployed SHA and write
     the exact rollback sequence into the runbook — Hostek re-pin/pull to that SHA -> CF Admin template +
     component cache clear -> full contact-page liveness probe.
  d) OPERATOR DEV DEPLOY per D-17: Hostek panel git pull on dev-subdomain -> CF Admin cache clear
     (template + component) -> liveness probe = load the FULL contact page for a modified-file contact,
     not the /include fragment.
P5 — ACCEPTANCE (dev, evidence-cited; per operator amendments A-4/A-5), then P6
  FIXTURE DISCIPLINE FIRST (A-5): capture the pre-test canonical baseline counts (contacts_ss membership
  for user 30 + canonical populated-column counts); register EVERY fixture contactID created (add-form
  and wizard creations included) before assertions run; state the expected fixture delta; after
  acceptance, clean up all fixtures per established fixture doctrine (soft-delete) and prove the
  canonical counts return exactly to baseline. All fixtures under test user 30.
  a) LINKED READ-ONLY, EVERY DOOR (A-4): using the P2 enforcement matrix as the authoritative endpoint
     list, negative-test phone, email, AND company through EVERY user-accessible endpoint capable of
     reaching a primary — each rejected server-side (paste responses); after each rejection prove NO
     change to: primary columns, _src, items, general edit log, master_audit_tbl. Contact 132419 is the
     linked target of record.
  b) TENANT ISOLATION (A-4): authenticated as test user 30, attempt a primary edit on a contact owned by
     ANOTHER user by substituting contactID — rejected, zero writes.
  c) BYPASS SPOOF (A-4): attempt the system/master write path from the client (inject the internal
     flag/parameter shape if any exists) — rejected; enforcement not client-disableable.
  d) OVERSIZED VALUES (A-4): submit primaries exceeding column widths (100/150/255) — clean reject with
     message, no truncation, no write.
  e) UNLINKED EDIT ROUND-TRIP: fixture contact — edit each primary via UI; columns update in _tbl; value
     visible in contacts_ss immediately; _src='user'; edit-log behavior matches the P2e ruling.
  f) CREATE PATH: new contact via add form (and wizard step if in scope) -> primaries populated ->
     visible in contacts_ss (D-22 closure proof). Created IDs -> fixture register.
  g) MERGE GUARD per Q1b ruling if implemented: attempt on a linked pair -> blocked with message; no
     writes.
  h) CLASS-B: "Additional info" reframe renders; item editing works on linked and unlinked contacts;
     item edit on a linked contact changes item panes only.
  i) REGRESSION: baseline counts restored post-cleanup (A-5); no change to unrelated contact-page
     functions. Jodie eyeball pass RECOMMENDED (first user-visible UI change of the program) —
     operator's call.
P6 — BUNDLE + STOP
  DIR-LNK-WO6-BUNDLE.md: per-criterion PASS/FAIL; diffs by SHA; deploy/cache/liveness evidence;
  rollback-capture record (prior SHA + sequence); acceptance pastes incl. every negative test; fixture
  register + baseline-restoration proof; D-22 closure statement; Q1 rulings of record; P2e logging
  ruling of record; remaining risks; push set. FINAL PUSH GO at this gate is the EVIDENCE/DOCS push only
  (per amendment A-6) — the code push already occurred at P4b; this gate must not ambiguously authorize
  another code push. STOP for architect review -> operator PUSH GO (docs) -> close.

## SECTION 4 — OUT OF SCOPE (hard)
Linking-flow changes and bridge disable (WO-7); master sync (WO-8); correction workflow (WO-9); unlink /
wrong-match (WO-10); item retirement (RQ-5i post-WO-5 pass, separate); bridge-row cleanup (WO-11); prod
anything (WO-12); photo unless spec-mandated; import/merge primary adoption unless P2 rules it in.

## SECTION 5 — HOLD POINTS
No DDL. No DML outside P5 acceptance fixtures (test user 30, registered IDs, baseline-restored). No
audit-table writes. No push without named PUSH GO; no deploy without the operator executing D-17 with
the rollback capture in hand. Operator self-pushes remain self-authorizing but declared in-channel.
Halt-don't-guess.

## SECTION 6 — ARCHITECT INPUTS ON RECORD (not rulings)
Q1a: two defensible answers; genuinely operator's. Q1b: block-merge lean. Q1c/Q1d: as written in P2f.
Import/merge adoption: defer-lean. UI-1/2/3: fold in if confined to the link/company block. P2e logging:
lean = extend the ordinary mechanism if the delta is small; accept-unlogged only if extension is
disproportionate.

END LOCK — 6 sections.
