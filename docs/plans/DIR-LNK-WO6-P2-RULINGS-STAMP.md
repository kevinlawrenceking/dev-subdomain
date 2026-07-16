# DIR-LNK-WO-6 — P2 APPROVAL + RULINGS + P3 GO (OPERATOR STAMP BLOCK)

> Saved verbatim from the operator relay. Rulings of record for DIR-LNK-WO-6; sits beside
> `DIR-LNK-WO6-P2-DESIGN.md` (@ `565e8154`). Kevin, 2026-07-16.

Kevin, 2026-07-16. Commit this block verbatim (docs-class) beside the
P2 memo as the rulings of record, then open P3.

P2 MEMO: APPROVED (operator), with architect design approval on
record. P2b Option A ratified (create() INSERT target swaps view ->
contactdetails_tbl + allowedFields gains the primary/_src columns).
P2c UI approved incl. UI-1/2/3. P2d ratified: import/merge primary
adoption DEFERRED to registered placeholder WO-6B.

P2e RULING: (ii) ACCEPT-UNLOGGED for WO-6, consistent with the
neighboring unlogged contact modals. Backlog item registered: a
coherent edit-logging pass across ALL contact-detail modals as a
future named work item. The new endpoint gains no bespoke logging.

Q1 RULINGS (captured now; each implements in its owning WO):
Q1a: TRANSFER the link to the keep when the discard is linked and the
     keep is not, executing full PC-1 preservation semantics on the
     keep's differing values. Implementation = the merge-owning WO;
     until then the current orphaned-pointer behavior is a registered
     known gap (D-15 class).
Q1b: BLOCK the merge when both contacts are linked to different
     masters; require deliberate unlink first. WO-6 BUILDS THIS GUARD:
     server-side pre-check, reject with message, zero writes.
Q1c: Linked keep's master-managed primaries are untouchable in merge;
     the discard's differing values are preserved as non-primary
     items; PD-1 value-level union applies to items only.
Q1d: Import rows targeting a linked contact's phone/email/company are
     diverted to non-primary items and flagged in the import summary;
     master-managed primaries are never import-writable; WO-9
     corrections are the sanctioned change path.
Q1e: FORMALIZED — unlinked contacts' create/edit paths write the
     primary columns directly (_src='user'); contactitems are
     additional information. This is WO-6 core scope and closes D-22.

P3 GO: authoring opens per lock A-2. Scope = the P2 memo + the Q1b
guard + Q1e write paths. Deliver diffs + file list for line review,
then STOP. No commit until commit-approved; no push; no deploy.

END STAMP BLOCK.
