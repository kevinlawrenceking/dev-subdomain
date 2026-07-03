# Phase I recon + reconciliation — contact merge repoint conformance

Date: 2026-07-03
Scope: services/ContactDuplicateService.cfc `mergeContacts()` conformance to
docs/plans/contact-merge-repoint-locked.md (LOCKED SPEC).
Status: ACCEPTED in full by Kevin, 2026-07-03. This file is the code-cite baseline the
Phase I proof bundle references. It supersedes no locked cell; it settles the
"verify/reconcile by code cite" gates the LOCKED SPEC left open.

Baseline commit context: mergeContacts already implements the 2026-06-25 audited merge
plus the WO-3.1 fusystemusers uq_active_enrollment fix. All line numbers below are
against the working-tree services/ContactDuplicateService.cfc at recon time.

## 1. Reconciliation table (ACCEPTED)

| Item | Finding (file:line) | Conformance action |
|---|---|---|
| audcontacts current behavior (Phase R vs Phase P) | Both correct about different query blocks. `:539-547` hard-DELETEs colliding rows UNMAPPED (Phase R). `:548-555` maps the repoint with pkcol=`audprojectid` (Phase P "wrong pkcol"). | C-E RETROFIT: map colliding deletes with true PK `id` + action='deleted'; xrefnotes salvage before delete; then delete; then repoint (repoint map pkcol=`id`). |
| C-D eventcontactsxref | Map writes pkcol=`eventid` (the FK) at `:524`. Colliding soft-delete at `:510-521` writes NO map row (map-completeness gap today). | Fix pkcol -> `eventContactID`. Map the collision soft-deletes with action='deleted', pkcol=`eventContactID`, BEFORE the delete. |
| contactitems C-E verify | Already maps BEFORE delete (`:447` map, `:464` delete). | No ordering change. Label stays `item_deleted` (see vocab ruling). |
| Avatar driver (A3) | MIXED: `contactdetails.contactphoto` is a real VARCHAR column (`services/ContactService.cfc:89,180,289`); on-disk per-contact convention `<contactFolder>\avatar.jpg` (`services/ContactImportV2Service.cfc:1738`); `d.avatar` synthesized in `contacts_ss` view (`services/ContactService.cfc:1706`). | Column/mixed branch (see avatar ruling). |
| PHONEBOOK register | `services/AuditionImportService.cfc:1621` `INNER JOIN phonebook` confirmed. Offline doc `09-database-schema.md` lists phonebook as table #153. | Live pack (ABSENT sentinel) wins -> audit-drift register. Reachability statement for :1621 owed in proof. Register-only, not actioned. |
| notifications_tbl readers | Zero repo readers (only name-map at `database/diag-table-index-audit.cfm:41`). | Straight repoint stands; retirement-review register. |
| xrefnotes column | Real column, `services/ContactAuditionService.cfc:9-10` inserts (contactid, audprojectid, xrefnotes). | Enables the audcontacts salvage rule. |

## 2. Standing rulings folded into the one-pass implementation

- Vocabulary: KEEP existing label `item_deleted` (same precedent as `enroll_deleted` --
  existing labels are never renamed). Full documented set (migrations README):
  repointed / deleted / item_deleted / enroll_deleted / referral_repointed /
  referral_inherited / referral_cleared / softdeleted (existing soft-delete label at
  `:646`).
- tmpcontactgroups_tbl RULING: guarded -> STRAIGHT repoint. Basis: zero repo
  readers/writers; `include/tmpcontactgroups.cfm` contains no tmpcontactgroups_tbl SQL
  (it is a relationship-system bulk-assign page); pane shows PRIMARY=contactgroupid only,
  no unique on membership. Map-first: pkcol=`contactgroupid`, action='repointed'.
- Avatar (A3 mixed branch): trigger ONLY when keep.contactphoto is empty/NULL AND dup's
  is non-empty. Derive the folder exactly as the existing writer
  (`services/ContactImportV2Service.cfc:1738`). Copy file BEFORE the txn; update
  `contactdetails_tbl.contactphoto` INSIDE the txn and map it -- but ONLY if the copy
  succeeded. Copy failure: cflog + register, non-fatal, no column update, no map row.
- eventcontactsxref collision soft-deletes (`:510-521`): accepted into C-D scope -- map
  with action='deleted', pkcol=`eventContactID`.
- uq_active_enrollment ordering VERIFIED by code cite: fusystemusers collision soft-delete
  (step 6a, `enroll_deleted`) precedes the repoint of the remaining rows (step 6b). The
  soft-delete recomputes `active_guard` to NULL, freeing the prod unique index
  (userid, contactID, systemID, active_guard), so the repoint cannot fire it.
- Proof split (Blocker 3): implementation + staged diff + migrations README + conformance
  statement + static proof artifacts + DEV-PROOF-RUNBOOK.md are delivered; Kevin runs the
  runbook on dev and returns outputs; failure-injection is an env-guarded dev-only
  cfthrow inside the txn, documented in the runbook and ABSENT from the staged diff
  (isolation verification must show it never staged). EXPLAIN on UPDATE substitutes
  EXPLAIN on the equivalent `SELECT ... WHERE contactid = :dup` when tooling rejects
  EXPLAIN UPDATE; state the substitution.

## 3. Registers to carry into the proof bundle (do not action)

1. Audit-drift: phonebook -- live pack ABSENT sentinel beats `09-database-schema.md` #153
   (09 joins 06/14 for this entry). Reachability RESOLVED: the `INNER JOIN phonebook` at
   `services/AuditionImportService.cfc:1618-1630` is on the PROD-reachable V3
   audition-import row path (email-based contact resolution), gated only by
   `len(trim(audData.contact_email)) > 0` -- NOT dev-gated. With phonebook absent
   everywhere, that branch throws ER_NO_SUCH_TABLE on any imported audition row carrying an
   email, in every environment. Register-only fix: resolve emails via `contactitems`
   (valueCategory='Email'), as the rest of the codebase does.
2. Retirement-review list: notifications_tbl (3,308 rows, zero readers),
   casting_notifications (0 rows, zero refs), tmpcontactgroups_tbl (2,943 rows, zero code
   refs).
3. Doc-drift: `17-contact-data-model.md` mischaracterizes `include/tmpcontactgroups.cfm`
   (it is a relationship-system bulk-assign page, not contact-group membership).
4. tmpcontactgroups possible duplicate memberships post-merge: cosmetic, zero readers.
5. Historical merges (7 prod) predate these repoints -- follow-up WO for zero-dangling
   check. Map backfill: 34 existing map rows carry FK pkcols; acceptance (b) applies to
   new merges only.
6. Index note: audprojects/audroles contactid unindexed -> EXPLAIN pair. auditions is
   indexed (idx_auditions_contactid); auditions has 0 contactid rows today (note the zero
   in proof). audroles unique FK_audroles_audprojects(audprojectID,audRoleID) contains
   the PK, so the straight contactid repoint cannot collide.

## 4. Cross-check gate (PENDING evidence files)

Before writing the transaction, cross-check both pasted artifacts against the LOCKED
list; ANY mismatch -> STOP:
- docs/plans/evidence/2026-07-03-merge-repoint-sqlpack.txt (pane, sections A-E)
- docs/plans/evidence/2026-07-03-contact-fk-inventory.txt (information_schema COLUMNS)

Expected (must all hold):
- BASE-TABLE contactid FK on: events_tbl, audprojects, auditions, audroles,
  notifications_tbl, shares, taousers_tbl, tmpcontactgroups_tbl.
- PRIMARYs: eventID / audprojectID / audition_id / audRoleID / ID(notifications_tbl) /
  contactid(shares) / contactgroupid(tmpcontactgroups_tbl). All 17 tables InnoDB.
- shares PRIMARY UNIQUE = contactid (pane C_indexes) -> two-branch guarded mode stands.
- Row facts: notifications_tbl 3,308; auditions 0 contactid rows; phonebook ABSENT.
