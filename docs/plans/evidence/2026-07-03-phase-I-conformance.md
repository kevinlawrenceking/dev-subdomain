# Phase I conformance statement — contact merge repoint

Date: 2026-07-03
Baseline: `docs/plans/contact-merge-repoint-locked.md` (LOCKED SPEC).
Change: `services/ContactDuplicateService.cfc` `mergeContacts()` — 611 insertions,
18 deletions (diff: `docs/plans/evidence/2026-07-03-mergeContacts.diff`).
Revision (2026-07-03): authorized refer_contact_id ordering fix folded in (Flag 3) —
in-txn order is now applyMergedFields -> avatar -> A1 pri-first edge.
Evidence: `2026-07-03-merge-repoint-sqlpack.txt`, `2026-07-03-contact-fk-inventory.txt`,
recon `2026-07-03-phase-I-recon.md`.

## Cross-check gate (all PASS — no STOP)

- BASE-TABLE `contactid` FK confirmed on all eight new/guarded targets + taousers_tbl.
- PRIMARYs match locked cells: eventID / audprojectID / audition_id / audRoleID /
  ID(notifications_tbl) / contactid(shares) / contactgroupid / id(audcontacts) /
  eventContactID(eventcontactsxref) / suID(fusystemusers) / itemID / noteID.
- All 17 tables InnoDB. shares PRIMARY UNIQUE = contactid (two-branch stands).
- No UNIQUE on tmpcontactgroups_tbl membership (straight repoint safe).
- audroles UNIQUE (audprojectID,audRoleID) excludes contactid (no collision).
- auditions has 0 contactid rows today; notifications_tbl 3,308; phonebook ABSENT.
- `ux_taousers_active_email` \N is the functional-index artifact (ignored, per note).
- Full FK inventory swept: every BASE-TABLE contactid bearer is in-scope or exempt
  (`_zzq_*`/`*_bak`/`*_backup`/import*/export*/co_contacts/bigbrother/merge log-map/
  casting_notifications). NO new cell.
- Datasource: `application.datasource` only (61 refs, 0 `application.dsn`) — single name.

## Conformance by step (as built)

- Step 0 D1 pre-flight on taousers_tbl.contactid; standard envelope, flip message, zero
  writes; pri as user record allowed. `:441`
- qGuard extended to pull contactphoto for the avatar pre-read. `:453`
- 2a-2c contactitems collision(`item_deleted`)+repoint — unchanged (maps before delete).
- 3 noteslog straight. `:570`
- 4 eventcontactsxref C-D: pkcol -> eventContactID; collision soft-deletes now mapped
  `deleted` before delete; deletes precede repoint. `:584`
- 5 audcontacts C-E: xrefnotes salvage -> map collisions `deleted` (pkcol id) -> hard
  delete -> map+repoint (pkcol id). `:635`
- 6 fusystemusers `enroll_deleted`+repoint — unchanged (WO-3.1 uq ordering preserved).
- 7A-7F straight NEW: events_tbl / audprojects / auditions (0-row no-op) / audroles /
  notifications_tbl / tmpcontactgroups_tbl. `:745`
- 8 shares two-branch guarded on PK contactid (delete-branch / repoint-branch). `:840`
- 9 referral A1b blanket `referral_repointed` with `contactid NOT IN (:pri,:dup)` (never
  touches pri/dup, so position is order-independent). `:880`
- 10 contact_not_duplicate cleanup, information_schema existence-guarded; clean skip
  logged when absent. `:904`
- 11 applyMergedFields (unchanged body; now positioned before avatar/edge). `:938`
- 12 avatar column carry inside txn: only if the pre-txn copy succeeded AND keep.contactphoto
  is STILL empty in current (post-applyMergedFields) state; mapped `avatar_carried`; else
  logged skip. `:940`
- 13 referral A1a pri-first edge (`referral_inherited`/`referral_cleared`), now AFTER
  applyMergedFields so it reads the current keep referrer and corrects a user-submitted
  `refer_contact_id = :dup` with no new code. `:974`
- 14 soft-delete dup `softdeleted`. `:1019`
- rows_affected auto-sums map rows; COMMIT; post-commit fireIcsRegen (non-fatal).
- Ordering rule honored: inside every guarded table, deletes precede updates.

## Isolation

`grep -n cfthrow services/ContactDuplicateService.cfc` -> nothing. The failure-injection
throw lives only in the runbook and is never staged.

## Flag rulings (resolved)

1. `avatar_carried` — APPROVED, kept as-is. The row mutates the KEEP contact's row
   (pkval=:pri, old=:dup, new=:pri): a value carry-over is semantically distinct from a
   contactid repoint, so a ninth label is correct, not drift. Present in
   `database/migrations/README.md` vocabulary and this doc.
2. Enrichment writes — ACCEPTED with documentation (see exception paragraph below).
3. refer_contact_id ordering — FIXED (authorized, in-scope). No change to
   `applyMergedFields`; the call sequence inside `mergeContacts()` is now
   applyMergedFields -> avatar column update -> A1 pri-first edge. The edge's existing
   inherit/clear logic now reads post-applyMergedFields state, correcting a user-submitted
   `refer_contact_id = :dup` with zero new code; the avatar empty-check reads current state
   so an explicit modal photo choice wins and the carry skips.

## Map exception paragraph (the only two unmapped mutations)

Every contactid transition and every row deletion is mapped. Exactly two writes are NOT
mapped, by design:
(a) audcontacts_auditions_xref `xrefnotes` salvage (step 5a) mutates the SURVIVOR row
without a map row. A2 governs contactid transitions and row deletions; this is neither.
Provenance of the salvaged note is the deleted source row's own map entry
(`deleted`, pkcol=`id`).
(b) `applyMergedFields` writes user-chosen plain columns on the keep row; pre-existing and
unmapped. REGISTERED and cross-registered to the item-1 value-level-union rework, which
must design map-writes in when it replaces the category-skip logic.

## Confirm-present resolutions

1. PHONEBOOK reachability: the `INNER JOIN phonebook` at
   `services/AuditionImportService.cfc:1618-1630` is on the PROD-reachable V3
   audition-import row path (contact resolution by email), gated only by
   `len(trim(audData.contact_email)) > 0` — it is NOT dev-gated. Because `phonebook` is
   ABSENT in all schemas (pack E_phonebook), that branch fails
   (ER_NO_SUCH_TABLE) in every environment whenever an imported audition row carries an
   email. Register-only; the fix is to resolve emails via `contactitems`
   (valueCategory='Email') as the rest of the codebase does.
2. uq_active_enrollment ordering: verified by code cite. The collision path soft-deletes
   the duplicate's colliding ACTIVE enrollments (step 6a, `:696-723`, `enroll_deleted`)
   BEFORE the repoint of the remaining rows (step 6b, `:724-739`). Soft-delete recomputes
   `active_guard` to NULL, freeing the prod unique index
   (userid, contactID, systemID, active_guard), so the repoint cannot fire it.

## Registers carried (do not action)

Audit-drift (phonebook: pack ABSENT beats 09-database-schema.md #153; reachability of
AuditionImportService.cfc:1621 owed). Retirement-review (notifications_tbl 3,308 /
casting_notifications 0 / tmpcontactgroups_tbl 2,943, all zero readers). Doc-drift
(17-contact-data-model.md mischaracterizes include/tmpcontactgroups.cfm). tmpcontactgroups
possible duplicate memberships (cosmetic). Historical merges (7) + map backfill (34 FK
pkcol rows) — new merges only. Index note (audprojects/audroles contactid unindexed).
Display-side LEFT JOIN exemptions (bigbrother, updatelog).

## STOP boundary

Delivery stops here: staged diff + static proofs + runbook. Commit authorization follows
Kevin's runbook outputs at proof-bundle review. Nothing committed.
