# PROPOSED — DIR-LNK-WO-8 PLAN LOCK (MASTER AUTO-SYNC FOR LINKED CONTACTS)

> Saved verbatim at P0b. Numbered sections 1-7, END marker closes.
> Binding spec MD5 078d926d governs over this summary. Halt-don't-guess.
> Relays carry payloads; committed repo files count as payloads.
>
> P0a binding verification (this session): repo root
> C:\Users\kevin\TAO\dev-subdomain, branch dev, clean tree, origin/dev HEAD =
> 05b20a1696a7d2ea6a6301a46baada2a6a108ddd (WO-7 close). PASS.

---

SECTION 1 — BINDING + AUTHORIZATION
project: TAO master-linking program (DIR-LNK series)
repo: kevinlawrenceking/dev-subdomain
root: C:\Users\kevin\TAO\dev-subdomain
branch: dev (verify origin/dev HEAD at P0; last known = the WO-7 close SHA)
workstream: DIR-LNK-WO-8. Binding spec MD5 078d926d governs over this
summary. WO-8 is the auto-sync rung: it keeps the three MASTER-MANAGED
COLUMNS (contactCompany, contactEmail, contactPhone) on already-linked
contacts current with the Book. It is DIR-LNK ladder work, distinct from
the DIR-CRUD ladder (master EDITING) and DIR-VAL ladder (master
VALIDATION); the DIR-CRUD relationship is a recon dependency question
(Section 4 P1), not a merge.
AUTHORIZATION: approval authorizes P0-P2 ONLY. P3 authoring requires
explicit approval of the P2 design memo and the rulings. Commit, push,
and dev deploy are separately gated at P4. No prod anything.

SECTION 2 — WHAT WO-8 DELIVERS (scope of record)
a) THE SYNC SURFACE IS EXACTLY THREE COLUMNS: contactCompany,
   contactEmail, contactPhone — the only master values COPIED into
   contactdetails_tbl (per WO-5, for view read-performance). Address and
   IMDB render live from co_locations/co_contacts at page load; the
   photo renders live from the master image URL. Those three are
   ALWAYS-CURRENT by construction and WO-8 does NOT sync them. WO-8
   touches only the three copied columns, and only where the relevant
   _src column = 'master'. It never writes a field whose _src='user'.
b) THE SYNC OPERATION REUSES WO-7 MACHINERY: for a linked contact,
   re-derive the master snapshot using the stored master_co_contact_id
   and company_location_id (the same derivation writeLinkSnapshot uses),
   compare field-by-field to the stored columns, and UPDATE only the
   fields that differ. This is writeLinkSnapshot run again, gated on
   "changed", audited as MASTER_AUTO_UPDATE instead of
   MASTER_SNAPSHOT_POPULATED.
c) CHANGE DETECTION IS BY VALUE COMPARISON, NOT TIMESTAMP. Re-derive and
   compare actual values; update mismatches. This sidesteps the
   registered N-1 one-second-granularity trap entirely (no reliance on
   master_last_sync or any event/version id to decide "changed"), and it
   is robust to same-second master edits. master_last_sync is UPDATED on
   a sync that writes, as a record of last-touch, but is NOT the change
   discriminator.
d) THE BLANK-OFFICE-RESOLVES CASE IS A HEADLINE FEATURE. A contact
   linked to an office that had no email/phone (the WO-7 modal's amber
   "check this one" row, Q4) must, when the Book later gains that
   office's email/phone, have the field FILLED by sync — the amber gap
   resolves itself. This is the clearest user-visible payoff of WO-8.
e) FIRST-RUN BACKFILL of the existing linked set (the ~14 bridge-era
   links plus any others) — ratified at WO-7 P2 as Q6 (WO-8's first run
   IS the backfill). Because the operation is value-comparison, it
   no-ops on contacts already correct and only writes genuine drift.
f) AUDIT: every sync write emits MASTER_AUTO_UPDATE to master_audit_tbl
   via the existing MasterAuditService, per-field granularity,
   old_value -> new_value recorded, governed vocabulary (no new actions,
   no schema change). NOTE: master_audit_tbl is CORRECTNESS-CRITICAL
   (WO-7 link-epoch derives from MAX(auditID)); WO-8 audit writes must
   not disturb that — confirm the epoch mechanism is unaffected by a new
   high-volume writer.
g) THE TRIGGER MECHANISM (when sync runs) is the central design question,
   decided at P2 on recon (Section 4). Candidate models in Section 4 P2.

SECTION 3 — WHAT WO-8 IS EXPLICITLY NOT
- Corrections / "Suggest a correction" / "Not the right person" / "wrong
  name in the Book" (WO-9). The Ben Pollack "and Seth Yanklewitz"
  co_contact is a WO-9 specimen, not a WO-8 concern.
- Wrong-match detection and the D-18 duplicate-master guard (WO-10).
- The in-place relink UI that would make MASTER_RELINKED fire (dormant;
  future scope, unscheduled).
- Editing master data (DIR-CRUD ladder) or validating it (DIR-VAL).
- Syncing photo, address, or IMDB (live-rendered; nothing to sync).
- Historical bridge-item cleanup (WO-11) and the soft-delete-strands-
  pointer hygiene item (WO-11).
- Prod anything (WO-12).

SECTION 4 — PHASES AND GATES
P0 — BINDING VERIFICATION, THEN BOOTSTRAP (read-only until the commit)
  a) Verify repo root, branch=dev, CLEAN tree, origin/dev HEAD (report
     the SHA). Read the canonical role/project instructions. HALT on
     mismatch.
  b) Save this lock verbatim to docs/plans/DIR-LNK-WO8-PLANLOCK.md;
     commit docs-class.
  c) Required reading (one-line gist each): binding spec sections on
     sync, staleness, and master identity fields;
     DIR-LNK-WO7-BUNDLE.md (the whole carry-forward register — the
     sync join key, the dormant MASTER_RELINKED, the blank-office
     fields, the 14 links awaiting snapshot); the V3_12 migration
     (MASTER_AUTO_UPDATE is the action WO-8 activates); WO-7's
     confirmLink / writeLinkSnapshot / MasterDirectoryService derivation
     (the machinery WO-8 reuses).
  d) SPEC EXTRACTION (exhaustive): every section governing sync,
     staleness, master-value propagation, blank handling, and the
     managed-vs-live field distinction. Quote anchors verbatim. Silence
     routes to an operator ruling at P2.
  Then proceed to P1; no STOP unless P0a halts.
P1 — RECON (read-only), then STOP. Deliver DIR-LNK-WO8-P1-RECON.md.
  THE CENTRAL RECON QUESTION is master-data VOLATILITY, because it
  determines the whole shape of WO-8:
  a) HOW is master data (co_contacts, co_locations) edited today? By
     whom, how often, through what UI or process? Is it essentially
     STATIC imported reference data, or is it actively changed in TAO?
     If static, sync is near-trivial (backfill + a manual "re-sync after
     re-import" trigger); if actively edited, sync needs an ongoing
     mechanism. REPORT what you find; do not assume.
  b) Do co_contacts / co_locations carry reliable change markers
     (updated timestamps, version columns)? What granularity? (Informs
     whether value-comparison is the only viable detector — it likely
     is, but confirm there is no cleaner signal.)
  c) SCHEDULER RECON: does CF Admin scheduled-tasks work on this Hostek
     instance? Is there an existing scheduled-task pattern in the
     codebase (the sched/ files)? What is the CURRENT state of the
     request.svc scheduler shim / initServiceFactory pattern registered
     as a known gap — does a scheduled context have service-factory
     access today, or must WO-8 build the shim?
  d) DIR-CRUD DEPENDENCY: if master edits are (or will be) routed through
     an audited CRUD funnel (E10), that funnel's audit log would be a
     clean change stream for sync. Is that funnel BUILT? If not, confirm
     value-comparison sync needs NO change stream and therefore has NO
     hard dependency on DIR-CRUD — report the sequencing implication for
     the operator (proceed now vs wait for the funnel).
  e) THE LINKED SET: exact count of currently linked contacts and their
     per-field snapshot state (which have _src='master' on which of the
     three columns; which have stale or null values vs the current
     master; which sit on the blank-office Q4 case). This sizes the
     first-run backfill and proves the value-comparison plan against
     real rows.
  f) DERIVATION PROOF: confirm that master_co_contact_id +
     company_location_id are sufficient to re-derive all three columns
     for every linked contact (company name from the master record,
     email/phone from the office). Flag any linked contact where the
     derivation cannot reproduce the current value (would indicate a
     stored value with no live master source — a finding).
  g) READ-PATH SURFACE: enumerate where the three columns are READ
     (contact panel, contacts_ss list, exports) — this bounds where a
     lazy/on-read sync trigger would need to hook, and where staleness
     would be visible if sync is deferred/periodic.
P2 — DESIGN MEMO + RULINGS GATE, then STOP. DIR-LNK-WO8-P2-DESIGN.md.
  a) Sync engine design: the re-derive/compare/update-diffs operation,
     reusing WO-7's derivation and MasterAuditService; enforcement shape
     (conditional UPDATE keyed contactid+userid, _src='master' guard, no
     client input — sync is server-internal); transaction and audit
     mapping (MASTER_AUTO_UPDATE, per-field).
  b) TRIGGER DESIGN against the recon. Present the candidate models with
     the recon-informed tradeoffs and pick one to recommend:
       (i)  LAZY / ON-READ: when a linked contact's panel (and/or list
            row) is read, re-derive+compare+update-if-changed inline.
            No scheduler, no shim, no cron; fits the existing request
            lifecycle. Cost: a conditional write on read (no-ops when
            unchanged); contacts nobody views stay stale in the stored
            column until viewed (acceptable if the column is only read
            on view/list/export).
       (ii) ON-DEMAND ADMIN: a "re-sync all linked contacts" action for
            after a master re-import. Pairs naturally with (i).
       (iii) SCHEDULED: a CF scheduled task sweeping linked contacts on
            a cadence. Requires the request.svc shim to be solved and
            CF Admin scheduling to work on Hostek (recon P1c).
       (iv) CHANGE-DRIVEN: enqueue affected contacts when a master edit
            occurs — only viable if master edits route through an
            audited funnel (recon P1d), i.e. depends on DIR-CRUD.
     ARCHITECT LEAN: (i)+(ii) as the v1 — lazy on-read plus an on-demand
     admin re-sync — because it needs no scheduler, no shim, and no
     change stream, and value-comparison makes it self-correcting and
     cheap. Defer (iii)/(iv) until recon shows master data is volatile
     enough to warrant them or DIR-CRUD provides the funnel. Present this
     as the operator's call with the recon volatility finding in front
     of them.
  c) FIRST-RUN BACKFILL design: how the existing linked set is brought
     current (value-comparison sweep; no-ops where correct). Confirm it
     rides the chosen trigger (e.g. the on-demand admin action doubles as
     the backfill runner).
  d) RULINGS REQUESTED (spec-answer where extraction covers it; operator
     rules the silent ones):
     Q8  TRIGGER MECHANISM: which model(s) from P2b. Architect lean
         (i)+(ii); (iii)/(iv) deferred.
     Q9  POPULATED -> BLANK (the one with teeth): when the Book HAD a
         value for a managed field and it is later REMOVED, does sync (a)
         mirror the blank per the §7.5 default and audit it, or (b) keep
         the last-known value flipped to _src='user' (so a working number
         the user sees is not silently erased), or (c) keep it as
         _src='master' but flag stale. NOTE: unlike link time, sync is
         SILENT — there is no modal to disclose the blanking. Architect
         lean: (a) mirror-and-audit for consistency with the ratified Q4
         link-time rule, because keeping a value the Book no longer
         vouches for contradicts "managed by the Book" — but this is the
         operator's call precisely because it is silent and
         potentially-destructive. If the operator picks (a), the WO-9
         "suggest a correction" path becomes the user's recourse for a
         wrongly-blanked field.
     Q10 FIRST-RUN SCOPE: sweep ALL linked contacts (value-comparison
         no-ops where correct) or only those with null/absent snapshots.
         Architect lean: ALL — it is idempotent and catches bridge-era
         drift.
     Q11 CADENCE: only if Q8 includes (iii) scheduled — how often.
     Q12 BLANK-RESOLVES (Section 2d): confirm that an office GAINING an
         email/phone propagates to already-linked contacts as a sync
         write (the amber Q4 gap self-resolving). Architect lean: YES,
         it is the headline feature.
     Q13 PHOTO/ADDRESS/IMDB NON-SYNC: ratify that these are live-rendered
         and therefore out of sync scope (nothing to propagate).
         Architect lean: ratify.
  e) STOP. P3 opens only on explicit operator approval of the memo and
     these rulings.
P3 — AUTHORING (post-approval; no commit until commit-approved), STOP.
  Standards: cfqueryparam on every input; conditional-UPDATE enforcement
  keyed contactid+userid with the _src='master' guard; server-internal
  derivation only (sync trusts no client input); transactions for the
  multi-field write; MASTER_AUTO_UPDATE audit per field; idempotent
  (value-comparison makes a repeat sync a no-op); no view DDL; no schema
  changes unless recon proves a genuine gap (surfaced at the STOP as a
  separate migration decision, never assumed); no emojis; the ## /
  #-in-selector escaping lessons stand. If the trigger is (i) on-read,
  the hook must add negligible cost on the unchanged path (compare
  first, write only on diff) and must not break the WO-6 enforcement or
  the WO-7 panel render. Stage as service-then-trigger if it makes line
  review cleaner. Deliver diffs + file list for line review, STOP.
P4 — COMMIT + PUSH + DEPLOY (each separately authorized). Pre-deploy
  rollback SHA captured FIRST; D-17 deploy (pull, cache clear or service
  restart, liveness probe on a linked contact page).
P5 — ACCEPTANCE (dev, evidence-cited; A-5 fixture discipline — baseline
  first, every fixture registered, delta stated, cleanup to baseline
  proven). Matrix:
  a) A linked contact whose master value CHANGED -> sync updates the
     column, MASTER_AUTO_UPDATE audited with old->new, contacts_ss
     reflects it. (To create the change, edit the master value by the
     controlled means recon P1a identifies.)
  b) A linked contact already CURRENT -> sync is a no-op, zero writes,
     zero audit rows (value-comparison idempotency).
  c) BLANK-RESOLVES (Q12) -> an office gains an email/phone -> the
     linked contact's blank field FILLS, audited.
  d) POPULATED -> BLANK (Q9) -> behavior matches the ruling exactly,
     audited.
  e) FIRST-RUN BACKFILL -> the existing linked set is brought current;
     contacts already correct are untouched; genuine drift is written
     and audited.
  f) _src='user' UNTOUCHED -> a linked contact with a user-owned field
     (if Q4 produced any) is never overwritten by sync.
  g) EPOCH INTEGRITY -> WO-7 relink/unlink still work after WO-8's audit
     writes; the link-epoch (MAX(auditID)) is unaffected by
     MASTER_AUTO_UPDATE volume; run a relink+double-unlink regression.
  h) If trigger (i): the on-read hook adds no visible latency on the
     unchanged path and does not regress the WO-6 panel or enforcement.
  i) If trigger (iii): the scheduled task runs in its context with
     service-factory access (the shim works), and a run is idempotent.
P6 — BUNDLE + STOP. DIR-LNK-WO8-BUNDLE.md: per-criterion PASS/FAIL,
  diffs by SHA, deploy+rollback evidence, acceptance pastes, fixture
  register with baseline restoration, rulings of record, remaining gaps,
  push set. STOP for architect review -> operator docs PUSH GO -> close.

SECTION 5 — HOLD POINTS
No DDL unless recon proves a gap and the operator authorizes a migration
as a separate decision. No DML outside P5 fixtures. Audit writes only via
the service layer using the existing vocabulary (MASTER_AUTO_UPDATE);
zero triggers. No push without a named PUSH GO; no deploy without the
operator executing D-17 with a rollback pin in hand. Operator self-pushes
are self-authorizing but declared in-channel. Halt-don't-guess.

SECTION 6 — ARCHITECT INPUTS ON RECORD (not rulings)
Trigger lean (i)+(ii) lazy+on-demand, (iii)/(iv) deferred pending
volatility recon / DIR-CRUD. Q9 lean (a) mirror-and-blank-audit, flagged
as the operator's call because sync is silent. Q10 lean sweep-all. Q12
lean yes (headline feature). Q13 lean ratify non-sync of
photo/address/IMDB. Value-comparison change detection is the recommended
detector (sidesteps N-1). WO-8 reuses WO-7's derivation and
MasterAuditService rather than building new write logic. Registered
carry-ins from WO-7: company_location_id is the join key; contactPhoto_src
is a per-contact choice sync must never stomp; the 14 bridge-era links
await first snapshot; master_audit_tbl is correctness-critical; the
panel title-subline (co_contacts.jobtitle_type query widen) was deferred
to this UI pass and may ride WO-8 if cheap, else re-defer.

SECTION 7 — OPEN SEQUENCING NOTE FOR THE OPERATOR
Recon P1a/P1d may show that master data is barely edited today (imported
reference), in which case WO-8's ongoing-sync value is low until DIR-CRUD
makes master editing real and audited — and the honest v1 might be just
the first-run backfill plus an on-demand admin re-sync, with periodic/
change-driven sync explicitly deferred. Conversely, if master data is
already volatile, the trigger question sharpens. This lock does not
presume; the P1 recon decides it and the P2 rulings sheet puts the
volatility finding in front of you before you choose the trigger.
END PROPOSAL — 7 sections.
