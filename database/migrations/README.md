# Migrations README — contact merge audit map

## contact_merge_map.action vocabulary (LOCKED)

Every mutation or deletion a merge performs writes one `contact_merge_map` row so the
merge is auditable and reversible. `mergeContacts()`
(`services/ContactDuplicateService.cfc`) uses exactly these `action` values. Per A2 of the
locked spec, `new_contactid` is the primary (keep) contactid on EVERY row, including
`deleted` and `contact_not_duplicate` rows (the column is NOT NULL).

| action | meaning | pkcol / pkval | tables |
|---|---|---|---|
| `repointed` | row's contactid FK rewritten dup -> pri | that table's PK | contactitems_tbl, noteslog_tbl, eventcontactsxref_tbl, audcontacts_auditions_xref, fusystemusers_tbl, events_tbl, audprojects, auditions, audroles, notifications_tbl, tmpcontactgroups_tbl, shares |
| `deleted` | colliding/dup row removed (soft or hard) after being mapped | that table's PK | eventcontactsxref_tbl (soft), audcontacts_auditions_xref (hard), shares (hard), contact_not_duplicate (hard) |
| `item_deleted` | contactitems collision soft-deleted (existing label, kept for continuity) | itemID | contactitems_tbl |
| `enroll_deleted` | fusystemusers active-enrollment collision soft-deleted (existing label, kept) | suID | fusystemusers_tbl |
| `referral_repointed` | another contact whose refer_contact_id pointed at dup is repointed to pri | contactID (the referring row) | contactdetails_tbl |
| `referral_inherited` | keep contact was referred by dup; inherits dup's referrer | contactID (= pri) | contactdetails_tbl |
| `referral_cleared` | keep contact was referred by dup; referrer cleared to avoid a self/dup loop | contactID (= pri) | contactdetails_tbl |
| `avatar_carried` | keep had no photo; dup's contactphoto value carried to pri (file copied pre-txn) | contactID (= pri) | contactdetails_tbl |
| `softdeleted` | the duplicate contact itself is soft-deleted (existing label) | contactid (= dup) | contactdetails_tbl |

Notes:
- Existing labels (`item_deleted`, `enroll_deleted`, `softdeleted`) are never renamed.
- `avatar_carried` is APPROVED as the ninth label. It maps a value carry-over onto the KEEP
  row (pkval=pri, old=dup, new=pri), which is semantically distinct from a contactid
  repoint, so a dedicated label is correct rather than drift.

### Map exception (the only two unmapped mutations)

Every contactid transition and every row deletion writes a map row. Exactly two writes are
NOT mapped, by design:
1. audcontacts_auditions_xref `xrefnotes` salvage mutates the SURVIVOR row without a map
   row. A2 governs contactid transitions and row deletions; this is neither. The salvaged
   note's provenance is the deleted source row's own map entry (`deleted`, pkcol=`id`).
2. `applyMergedFields` writes user-chosen plain columns on the keep row — pre-existing and
   unmapped. REGISTERED and cross-registered to the item-1 value-level-union rework, which
   must design map-writes in when it replaces the category-skip logic.

## Repoint scope (13 in-scope tables) and modes

Straight repoint: events_tbl, audprojects, auditions, audroles, notifications_tbl,
tmpcontactgroups_tbl, noteslog_tbl. Guarded (dedupe/collision, deletes precede updates):
contactitems_tbl, eventcontactsxref_tbl, audcontacts_auditions_xref, fusystemusers_tbl,
shares. Referral + soft-delete + avatar act on contactdetails_tbl. See
`docs/plans/contact-merge-repoint-locked.md` (LOCKED SPEC) and
`docs/plans/evidence/2026-07-03-phase-I-recon.md`.

No schema (DDL) change is required for repoint conformance: all target tables already
exist, and `contact_merge_map.action` is VARCHAR(20) which fits every label above (longest
is `referral_repointed` / `referral_inherited`, 18 chars).
