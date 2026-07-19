# DIR-LNK-WO-7 PLAN LOCK — LINK-WITH-PREVIEW FLOW + BRIDGE DISABLE + SNAPSHOT POPULATION

> Saved verbatim at P0b (2026-07-18). Binding spec MD5 `078d926dfb7c146278180877e32fcbdb` governs over
> this summary. **P0a verification stamp:** root `C:/Users/kevin/TAO/dev-subdomain`, branch `dev`,
> origin/dev HEAD = `257df24e` (advanced one commit from the relay's last-known `d6e9e25d` — that commit
> is the ratified WO-6 close `257df24e`, fully accounted for; not an unexplained mismatch, no halt),
> working tree clean except the untracked mockup committed here. Mockup present
> (`docs/plans/DIR-LNK-WO7-LINK-PREVIEW-MOCKUP.html`, committed docs-class with this lock).
> Authorization: this lock authorizes P0-P2 ONLY; P3 authoring, P4 commit/push/deploy separately gated.

---

SECTION 1 — BINDING + AUTHORIZATION
project: TAO master-linking program (DIR-LNK series)
repo: kevinlawrenceking/dev-subdomain
root: C:\Users\kevin\TAO\dev-subdomain
branch: dev (verify origin/dev HEAD at P0; last known d6e9e25d)
workstream: DIR-LNK-WO-7. Binding spec MD5 078d926d governs over this
summary. WO-7B is DISSOLVED INTO THIS LOCK — the preview modal is the
link flow; a blind link flow is never built.
AUTHORIZATION: approval authorizes P0-P2 ONLY. P3 code authoring
requires explicit approval of the P2 design memo and the rulings.
Code commit, push, and dev deployment remain separately gated at P4.
No prod anything. WO-8..12 untouched.

SECTION 2 — WHAT WO-7 DELIVERS (scope of record)
a) BRIDGE DISABLE — first act of P3. The old DIR-WO-2 link path stops
   writing Company contactitems. Historical cleanup is WO-11; this WO
   stops new residue only. Evidence of record (P5 session): one contact
   accumulated THREE bridge Company items from three link events with
   no dedupe.
b) LINK PREVIEW MODAL — the user-facing flow, spec in Section 3.
c) SNAPSHOT POPULATION AT LINK TIME — on confirm, the chosen office's
   phone/email and the company name are written to contactdetails_tbl
   with _src='master' and master_last_sync stamped. This is what makes
   the WO-6 panel finally render SYNCED ("In the Book", gold) instead
   of INTERIM.
d) PRESERVATION — the user's displaced primary values are written as
   non-primary contactitems (Additional information) before the master
   values land. Nothing is deleted, ever.
e) OFFICE SELECTION — company_location_id is set from the user's choice
   and becomes the join key WO-8's sync job uses.
f) NAME + PHOTO CHOICE — per contact, chosen once at link time, stored
   in the existing _src columns: user keeps theirs -> value untouched,
   _src='user'; user takes the Book's -> value written, _src='master'.
   Sync (WO-8) only ever touches _src='master' rows. This RESOLVES
   PD-4 and PD-5 by design; no global ruling, no new state.
g) UNLINK + RELINK — both run through the same preview, showing what
   changes. Unlink semantics per the Q2 ruling (Section 5).
h) LINK EVENT AUDITING — link, relink, and unlink write
   master_audit_tbl rows using the EXISTING 13-action vocabulary:
   LINK_CREATED, PRELINK_VALUE_PRESERVED, MASTER_SNAPSHOT_POPULATED,
   MASTER_RELINKED, PRELINK_VALUE_RESTORED,
   PRIMARY_FIELD_CLEARED_AFTER_UNLINK. Do not invent actions. Evidence
   of record: today links write ZERO audit rows while merges are fully
   logged.

SECTION 3 — THE PREVIEW MODAL (binding UI spec)
Visual reference: docs/plans/DIR-LNK-WO7-LINK-PREVIEW-MOCKUP.html
(operator places the file; commit it docs-class at P0. If absent at
P0, REPORT and build from this text — the text governs on any
conflict.)
STRUCTURE, top to bottom:
 1. Header: slate bar, solid Book mark, "Add this contact to the Book".
 2. Match band: master person avatar, name, company + role, IMDB link,
    and a "Not the right person?" escape returning to search.
 3. Office picker: one selectable card per co_locations row for that
    company — city label, address lines, office phone. Preselect the
    only office when there is one and collapse the section to a single
    line. Address and phone shown in the diff follow this choice.
 4. Two-column diff, header row "Now" / "From the Book". One row per
    field: leading icon, label, current value left, arrow, incoming
    value right, and a tag beneath each value stating the consequence:
    "moves to Additional info" (grey), "managed by the Book" (gold),
    "new" (green), "check this one" (amber).
    Rows: Company, Email, Phone, Address, IMDB.
    Empty current value renders italic muted "none".
    Empty INCOMING value renders the honest case, e.g. "This office has
    no phone on file" plus a sub-line naming what happens instead, with
    the amber tag. (COPY NOTE: it is the OFFICE that is empty, not the
    person — offices are the sole master source per D-21.)
 5. Name picker: two cards — user's current name vs the Book's name.
 6. Photo picker: two cards with thumbnails — user's upload vs the
    Book's headshot.
 7. Footer: plain-language summary ("N fields will be kept current by
    the Book · N of your values move to Additional information ·
    nothing is deleted. You can unlink at any time."), Cancel, and the
    primary "Add to the Book" button carrying the Book mark.
ADAPTIVE DENSITY (required, not optional): when the user has NO values
that would be displaced and no office choice to make, render the SHORT
FORM — match band, a compact "you'll get:" line listing the incoming
values, and the buttons. The full diff renders only when something is
contested or chosen. Baseline for sizing: on the dev fixture user only
20% of contacts have a phone, 18% an email, 37% a company, so the
short form is the common case.
BEHAVIOR: modal loads via the house pattern (GET load into a modal
container, as app/contact-duplicates uses for the merge interface);
nothing is written until the user confirms; Cancel writes nothing.
RELINK reuses the same modal with the header and summary reworded to
name the move ("moving from X to Y — here's what changes").
No emojis anywhere.

SECTION 4 — PHASES AND GATES
P0 — BINDING VERIFICATION, THEN BOOTSTRAP (read-only until the commit)
  a) FIRST: verify repo root, branch=dev, CLEAN working tree, and
     origin/dev HEAD (report the SHA). Read the canonical role/project
     instructions from the working tree. HALT on any mismatch.
  b) Save this lock verbatim to docs/plans/DIR-LNK-WO7-PLANLOCK.md;
     commit docs-class together with the mockup HTML if present.
  c) Required reading (one-line gist each): binding spec;
     DIR-LNK-WO6-BUNDLE.md (all findings, especially D-23 and the Q1a
     specimen); the V3_12 migration defining master_audit_tbl and its
     13-action vocabulary; the WO-0b prod master capture
     (evidence/2026-07-04-wo0b-prod-Q8-Q15-master.txt).
  d) SPEC EXTRACTION (exhaustive): every section governing link
     creation, snapshot population, value preservation, office
     selection, unlink/relink semantics, blank-master handling, and
     master identity fields (name/photo/imdb/address). Quote anchors
     verbatim. Where silent, say silent — silence routes to an operator
     ruling at P2.
  Then proceed to P1; no STOP unless P0a halts.
P1 — RECON (read-only), then STOP
  a) CURRENT LINK PATH: full trace of the DIR-WO-2 link/unlink control
     (contact_info.cfm JS + its endpoints + MasterDirectoryService) —
     file:line, what each step writes, what it does NOT write. Confirm
     against D-23: stamps master_last_sync always; writes
     contactCompany + _src='master' only when the column was blank;
     never touches email/phone; relink overwrites a master-sourced
     company; UNLINK CLEARS the master-sourced company (evidenced live
     2026-07-18).
  b) BRIDGE WRITE SITE: exact file:line where the Company contactitem
     is created on link, and everything that would break if it stops.
  c) SEARCH/MATCH UI: how "Find in the Book" currently searches
     co_contacts, what it returns, and where a preview step would
     insert.
  d) SCHEMA PROBES (report values, do not assume):
     - does contactFullName_src exist on contactdetails_tbl?
       (contactPhoto_src is known to exist; the name column's
       provenance twin is UNPROVEN and may require a migration —
       flag it, do not create it)
     - is company_location_id written by ANY current code path?
     - co_locations columns of record: colocid, address1, address2,
       city, state, zip (+ report phone/email columns present)
     - co_contacts columns of record: id, image_url, imdbid, name_url,
       page_url (+ report name/title/company-pointer columns)
     - how many companies have more than one co_locations row (drives
       how often the office picker is non-trivial)
     - office phone/email population rates (the blank-master magnitude;
       last known 27.4% of companies without phone, 37.7% without
       email — verify against offices, not companies)
  e) EXISTING LINKED SET: count of currently linked contacts and their
     snapshot state (which have _src='master' on which fields), so the
     go-forward vs existing-links question (Q6) is decided on numbers.
  f) Deliver DIR-LNK-WO7-P1-RECON.md (docs-class), STOP.
P2 — DESIGN MEMO + RULINGS GATE, then STOP
  a) Write-path design: the link transaction end to end — preserve
     displaced values as items, write the snapshot, set
     company_location_id, apply name/photo choices, write audit rows,
     all in ONE transaction with rollback on any failure. Enforcement
     shape inherited from WO-6 Section 2c (conditional UPDATE keyed on
     contactid + userid, rowcount-verified, no client-suppliable
     provenance).
  b) Modal design against Section 3, including the adaptive short form,
     the office picker data shape, and the confirm payload (what the
     client sends; the server re-derives master values from the
     database, never trusting client-supplied master data).
  c) Unlink + relink flows per the Q2 ruling.
  d) Bridge disable: the exact change and its blast radius.
  e) Audit mapping: which of the 13 actions fire on which event, with
     the idempotency key shape.
  f) RULINGS REQUESTED (spec-answer where P0 extraction covers it;
     operator rules the silent ones):
     Q2  UNLINK SEMANTICS: on unlink, do the managed primaries (i)
         restore the preserved pre-link values, (ii) keep the last
         master values but flip _src to 'user', or (iii) blank. NOTE
         FOR THE OPERATOR: the WO-2 vocabulary already contains
         PRELINK_VALUE_RESTORED, which is evidence the spec author
         intended (i). Architect lean: (i), with the preserved item
         consumed on restore.
     Q4  BLANK-MASTER RULE (the modal's amber row): when the chosen
         office has no phone or email, does the managed field go blank
         (today's PC-1 rule) or keep the user's value marked _src='user'
         while the contact is linked? Architect lean: keep the user's
         value — a linked contact should never be less useful than an
         unlinked one — but this contradicts the current blanket
         "linked means master-managed" reading, so it is the operator's.
     Q5  PRESERVED-ITEM LIFECYCLE: if the user later unlinks (Q2-i),
         is the preserved item consumed, or does it remain and produce
         a duplicate? Architect lean: consumed, audited.
     Q6  EXISTING LINKS: do the ~14 bridge-era links get re-snapshotted
         by WO-7, or does WO-8's first sync run do it? Architect lean:
         WO-8 — its sync job IS the backfill, and doing it twice risks
         two write paths for one outcome.
     Q7  NAME/PHOTO CHOICE PERSISTENCE: confirm the _src-column
         mechanism (Section 2f) is the storage of record, and rule
         whether the choice is revisitable later from the panel or only
         at link/relink time. Architect lean: revisitable at relink;
         no separate control in WO-7.
  g) STOP. P3 opens only on explicit operator approval of the memo and
     these rulings.
P3 — AUTHORING (post-approval; no commit until commit-approved), STOP
  Order of work: (1) bridge disable, (2) service-layer link/unlink/
  relink with audit writes, (3) preview modal + confirm endpoint.
  Deliverable may be staged as two commits (service, then UI) if that
  makes line review cleaner — state which at delivery.
  Standards: cfqueryparam on every input; CSRF via the central /ajax
  gate (no in-file checks — WO-6 L-3 ruling of record); {success,
  message, data} returns; idempotent confirm endpoint; transactions for
  the multi-table write; conditional-UPDATE enforcement; server-derived
  master values only; no view DDL; no schema changes unless P1d proves
  a genuine gap (surfaced at the STOP as a separate migration
  decision, never assumed); no emojis; the ## escaping lesson stands.
  Deliver diffs + file list for line review, STOP.
P4 — COMMIT + PUSH + DEPLOY (each separately authorized)
  a) Commit-approved -> code-class commit(s), SHAs reported.
  b) Named PUSH GO -> push.
  c) PRE-DEPLOY ROLLBACK CAPTURE: record the deployed SHA and the exact
     rollback sequence before pulling.
  d) OPERATOR DEV DEPLOY per D-17: panel pull -> CF Admin template +
     component cache clear (or service restart) -> liveness probe on a
     FULL contact page.
P5 — ACCEPTANCE (dev, evidence-cited)
  Fixture discipline per WO-6 A-5: baseline capture first, every
  fixture ID registered at creation, expected delta stated, cleanup to
  baseline proven. Test matrix:
  a) Link a contact with NO existing values -> short form renders ->
     confirm -> snapshot populated, _src='master', panel flips to gold
     "In the Book", audit rows written (LINK_CREATED +
     MASTER_SNAPSHOT_POPULATED).
  b) Link a contact WITH existing values -> full diff renders and
     matches the DB -> confirm -> user values preserved as items,
     master values in columns, PRELINK_VALUE_PRESERVED rows written.
  c) Multi-office company -> picker renders every office -> chosen
     office's address/phone land and company_location_id is set.
  d) Blank-master case -> behavior matches the Q4 ruling exactly.
  e) Name/photo pickers -> both branches produce the correct _src.
  f) Cancel at every step -> zero writes.
  g) Relink -> MASTER_RELINKED audited, snapshot replaced, no duplicate
     preserved items.
  h) Unlink -> behavior matches Q2 exactly, audited.
  i) BRIDGE OFF: linking creates ZERO new Company contactitems (the
     D-19 regression test).
  j) Negatives: tenant isolation (another user's contactid), CSRF,
     client-supplied master values ignored, double-submit idempotency.
  k) Regression: WO-6 enforcement still rejects primary edits on the
     newly linked contact; contacts_ss shows the new values.
P6 — BUNDLE + STOP
  DIR-LNK-WO7-BUNDLE.md: per-criterion PASS/FAIL, diffs by SHA, deploy
  and rollback evidence, acceptance pastes, fixture register with
  baseline restoration, rulings of record, remaining gaps, push set.
  STOP for architect review -> operator docs PUSH GO -> close.

SECTION 5 — OUT OF SCOPE (hard)
Automatic sync of already-linked contacts when master data changes
(WO-8); correction workflow (WO-9) — the "check this one" tag and
"Not the right person?" link may point at a stub; wrong-match detection
and the D-18 duplicate-master guard (WO-10); historical bridge-item
cleanup including the Q1a orphaned-pointer specimen 131204/132419
(WO-11); merge behavior and the Q1a link transfer (merge-owning WO);
prod anything (WO-12); import primary adoption (WO-6B).

SECTION 6 — HOLD POINTS
No DDL unless P1d proves a gap and the operator authorizes a migration
as a separate decision. No DML outside P5 fixtures. Audit writes only
via the service layer using the existing vocabulary — zero triggers.
No push without a named PUSH GO; no deploy without the operator
executing D-17 with a rollback pin in hand. Operator self-pushes are
self-authorizing but declared in-channel. Halt-don't-guess.

SECTION 7 — ARCHITECT INPUTS ON RECORD (not rulings)
Q2 lean (i) restore, on the PRELINK_VALUE_RESTORED evidence. Q4 lean
keep-user-value, flagged as contradicting the current blanket reading.
Q5 lean consumed-and-audited. Q6 lean defer to WO-8. Q7 lean
revisitable at relink only. PD-4/PD-5 are resolved by the Section 2f
design and need no separate ruling unless the operator disagrees with
per-contact choice. Registered carry-ins: D-23 bridge behavior; audit
asymmetry (links unaudited, merges logged); D-19 quantified (3 items
from 3 link events, no dedupe); the office-is-the-source copy rule
(D-21); the MDI nonexistent-class sweep (backlog).
END PROPOSAL — 7 sections.
