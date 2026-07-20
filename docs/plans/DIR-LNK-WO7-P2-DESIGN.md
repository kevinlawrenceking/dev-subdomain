# DIR-LNK-WO-7 — P2 DESIGN MEMO + RULINGS GATE

**Work order:** DIR-LNK-WO-7 (link-with-preview flow + bridge disable + snapshot population)
**Binding:** project = TAO / repo = dev-subdomain / root = c:\Users\kevin\TAO\dev-subdomain / branch = dev
**Phase:** P2 — DESIGN MEMO + RULINGS, then STOP (per DIR-LNK-WO7-PLANLOCK.md §P2)
**Delivered:** 2026-07-18. Design only: no code, no DDL, no DML, no push. P1 recon ACCEPTED at `68a9982d`.
**Authorization:** P0-P2 only. P3 authoring opens ONLY on explicit operator approval of THIS memo + the §P2f rulings.

## ACCEPTANCE + ADJUDICATIONS OF RECORD (relay items 1-2)
- P1 ACCEPTED at `68a9982d`; lock+mockup `93151c33` accepted; origin `257df24e` reconciled as the WO-6 close.
- **D-23 REFINED (of record):** the bridge writes contactCompany + `_src='master'` when the column is blank **OR already master-sourced** — this is what makes a relink overwrite a prior master company; a `_src='user'` company is preserved.
- **Q2 REMOVED from the rulings sheet** — spec-answered at §11.4 (restore pre-link value, else blank). Designed below as spec-governed, not open.
- **Bridge disable scope accepted:** `ContactItemService.createCompanyItem:851-860`, sole caller `MasterDirectoryService.cfc:156`, two secondary readers.
- **WO-7 confirmed as the first link-event audit writer.**

---

## P2a — WRITE-PATH DESIGN (the link transaction, end to end)

**Shape.** Extend `MasterDirectoryService` with a single transactional engine (working name `confirmLink`) that performs the whole link as one `cftransaction` with rollback on any failure (spec §7.6, §17). The existing `linkContactToMaster` search→locations plumbing is reused as the finder; the WRITE moves behind the modal's confirm.

**Endpoint.** New `POST /ajax/master/link-confirm.cfm` (idempotent), auth+CSRF via the central `/ajax/Application.cfc` gate (no in-file checks — WO-6 L-3). Returns `{success,message,data}`. Client payload is IDS + CHOICES ONLY: `{ contactid, masterCoContactId, colocid, nameChoice:'user'|'master', photoChoice:'user'|'master' }`. **The server re-derives every master value from the database** (coName from companies, office phone/email/address from co_locations by colocid, master fullname/image_url from co_contacts) — client-supplied master data is never trusted (spec-silent-but-safe; mirrors the existing re-derivation at MasterDirectoryService.cfc:127-138).

**Transaction steps (order is spec §7.3 → §7.4; preservation BEFORE population):**
1. **Load + gate.** Confirm the contact is owned by `session.userid` and active (conditional read, rowcount-verified). Validate the master person exists and `colocid` belongs to its company (re-derive `coName`, office `phone/email/address1..zip`). Reject with `{success:false}` on any mismatch — zero writes.
2. **Preserve displaced user values (per primary field).** For each of contactPhone / contactEmail / contactCompany: normalize the current column value (shared normalizer, §18); if it is non-blank AND differs from the incoming master value AND no equivalent active item exists → `INSERT` a non-primary `contactitem` (Additional information) with correct category/display metadata; **never mark primary** (§7.3.5). Audit `PRELINK_VALUE_PRESERVED` (field_name set). Skip-if-equivalent and skip-if-blank exactly per §7.3.3/§7.3.4.
3. **Populate the snapshot (per primary field).** Set contactCompany/contactEmail/contactPhone = master values **including blank** (§7.5 default, see §P2f Q4), each `_src='master'`; set master_co_contact_id, master_coid, company_location_id=colocid; master_last_sync=now(); master_linked_date=now() if currently NULL. Audit `MASTER_SNAPSHOT_POPULATED` (per field) + `LINK_CREATED` (once).
4. **Name/photo choice** (per the §P2f name-branch ruling). Photo (contactPhoto_src EXISTS): `photoChoice='master'` → write the photo value + contactPhoto_src='master'; `'user'` → untouched, _src stays 'user'. Name: only if the name branch (i) is ruled — `nameChoice='master'` → write contactFullName + contactFullName_src='master'; else name stays user-owned (branch ii = no name write ever).
5. **Bridge OFF (§P2d).** Do NOT create a Company `contactitem`. The company value lives solely in the contactCompany column (already the read source post-WO-5).

**Enforcement shape (WO-6 §2c, ratified).** Every contactdetails write is a conditional `UPDATE ... WHERE contactid=? AND userid=?`, rowcount-verified (affected-vs-matched disambiguation, config-independent). Provenance (`_src`) is server-set only; there is no client-suppliable master data. This is the same predicate WO-6 `updatePrimary` uses.

**Idempotency (spec §17).** `link-confirm` is a no-op success when the contact is already linked to the same master (guard on current `master_co_contact_id`). Any retry-guarded audit write carries a deterministic `idempotency_key` (see §P2e); inherently-unique events leave it NULL (V3_12 UNIQUE, NULL-distinct).

---

## P2b — MODAL DESIGN (Section 3 + adaptive short form + office picker + confirm payload)

**Load pattern (house GET-load, reuse of contact-duplicates).** New `showPreviewModal(contactid, masterCoContactId, colocid)` → `$('#masterPreviewContent').load('/include/master_link_preview.cfm?...', () => modal.show())` into a Bootstrap-5 `#masterPreviewModal`/`#masterPreviewContent` container mirroring `app/contact-duplicates/index.cfm:217-234,254-260`. GET-load runs the include's inline `<script>`; no CSRF needed for the load. **`doLink()` (contact_info.cfm:1546-1582) is replaced** by opening this modal; the modal's confirm button POSTs to `link-confirm.cfm`. The finder (`#masterLinkSearch` autocomplete + `loadLocations`) stays and feeds the modal.

**Preview include (`/include/master_link_preview.cfm`, server-rendered).** Re-derives master values + current column values, computes the field-by-field diff, and chooses density:
- **SHORT FORM** (Section 3 adaptive rule) when the contact has NO displaced values AND the office choice is trivial (0/1 office): match band + compact "you'll get:" list + buttons. Dev baseline confirms this is the COMMON case (phone 17.4% / email 14.8% / company 28.1% populated).
- **FULL DIFF** otherwise: the Now/From-the-Book two-column table with per-value consequence tags (moves-to-Additional-info / managed-by-the-Book / new / check-this-one), name picker, photo picker, footer summary — exactly the mockup.

**Office picker + degradation (relay 3c; 16.7% of companies multi-office, max 46 — the mockup's card row fails at scale):**
- **1 office** → collapsed one-line confirmation (no picker), auto-selected.
- **2–5 offices** → selectable cards as mocked.
- **6+ offices** → searchable/scrollable list (max-height, type-to-filter by city/address), not a card wall.
- **Default selection rule (chosen):** the office with `address1` non-blank, tie-break `MIN(colocid)` (the WO-0b default-office rule; there is no is_primary flag). Preselected in every mode; the diff's address/phone follow the current selection.
- **getLocations must be widened** (P3 code change, not schema): return `colocid, location, address1, address2, city, state, zip, phone, email` (today it returns only colocid/location/address1/city/state).

**Confirm payload + trust boundary.** Client sends `{contactid, masterCoContactId, colocid, nameChoice, photoChoice}` + X-CSRF-Token (central shim). Server re-derives all master values; nothing master-authoritative is accepted from the client.

**Blank-office amber row + WO-9 stub (relay 3d).** When the chosen office has no phone/email, render the honest blank ("This office has no email on file") with the amber "check this one" tag, plus a **disabled/stub** "Suggest one" affordance that is the natural entry to the correction workflow. WO-9 owns the workflow; WO-7 renders the affordance inert.

**No emojis anywhere.** Relink reuses the same modal, header/summary reworded ("moving from X to Y — here's what changes").

---

## P2c — UNLINK + RELINK (Q2 spec-governed, §11.4)

**Unlink (spec-governed, NOT an open ruling).** Per §11.4: (1) restore the pre-link user primary values where reliable history exists — read the most recent `PRELINK_VALUE_PRESERVED` audit rows (and/or the preserved contactitems) per field; (2) if no prior value exists, clear the field; (3) preserve alternate contactitems; (4) primaries become user-editable again. Each restored/cleared field flips `_src='user'`; audit `PRELINK_VALUE_RESTORED` or `PRIMARY_FIELD_CLEARED_AFTER_UNLINK`. Preserved item consumed on restore (Q5 lean — §P2f). Pointers → NULL. Presented in the memo as spec-governed.

**Relink (atomic, §11.4 lines 627-633).** One transaction: preserve any newly-displaced values, replace the master identity (new master_co_contact_id/coid/colocid), populate the new snapshot, keep relationship history attached to the same contact; audit `MASTER_RELINKED` + the new snapshot. No duplicate preserved items (§17). Same modal, reworded.

---

## P2d — BRIDGE DISABLE (exact change + blast radius)

**Change.** In the new `confirmLink` write path, do not call `ContactItemService.createCompanyItem` and drop the rename/soft-delete company-item branches (the logic at `MasterDirectoryService.cfc:154-183`). `createCompanyItem` itself is left in place but becomes uncalled from linking (retire in WO-11 cleanup). Result: linking creates ZERO Company contactitems (spec §15.2, §2 rule 20; the D-19 regression test P5(i)).

**Blast radius (2 secondary readers).** Post-WO-5 everything user-visible reads the `contactCompany` COLUMN (contacts_ss, share/optimized views, panel primary field). Only two surfaces still read the bridge item: (1) contact-card "Additional information" grid `include/contact_pane.cfm:73-75` (via `itemsByCatActive`), (2) export `SELcontactitems_23892` → `exportitems.Company`. **Recommendation (A, chosen):** repoint those two readers to the `contactCompany` column (small follow-on within WO-7's UI commit), aligning with WO-5's column-read direction and §15's "no master value in contactitems." Rejected alternative (B): have the snapshot also emit a secondary Company item — reintroduces exactly the residue WO-7 is removing. Contacts with a hand-entered Company item are unaffected either way.

---

## P2e — AUDIT MAPPING (event → action → field → idempotency key)

All writes via the service layer (no triggers, V3_12 policy). `actor_type='user'`, `actor_userid=session.userid`. Value columns are VARCHAR(500) (co_locations-sized).

| Event | action_type | field_name | old/new/src | idempotency_key |
|-------|-------------|-----------|-------------|-----------------|
| Link — value displaced | `PRELINK_VALUE_PRESERVED` | contactPhone/Email/Company | old=user value, previous_source=user | `WO7:PRESERVE:<contactid>:<field>:<master_co_contact_id>` |
| Link — snapshot written | `MASTER_SNAPSHOT_POPULATED` | contactPhone/Email/Company | new=master value, new_source=master | `WO7:SNAP:<contactid>:<field>:<master_co_contact_id>` |
| Link — established | `LINK_CREATED` | (null) | master_co_contact_id/coid/company_location_id set | `WO7:LINK:<contactid>:<master_co_contact_id>` |
| Relink | `MASTER_RELINKED` | (null) | old=prev master, new=new master | `WO7:RELINK:<contactid>:<new_master>:<prev_master>` |
| Unlink — restore | `PRELINK_VALUE_RESTORED` | per field | new=restored user value | NULL (inherently-unique per unlink event) |
| Unlink — clear | `PRIMARY_FIELD_CLEARED_AFTER_UNLINK` | per field | old cleared | NULL |

All six actions are members of the V3_12 governed 13-action vocabulary — none invented. Idempotency keys are deterministic on retry-guarded link/relink writes so a double-submit cannot double-insert (V3_12 UNIQUE UQ_master_audit_idem); unlink/restore events are inherently-unique and leave the key NULL.

---

## P2f — RULINGS REQUESTED (the operator sheet at this STOP)

**Q2 — REMOVED.** Spec-answered §11.4 (restore-else-blank); implemented as spec-governed (§P2c). No ruling needed.

**NAME-CHOICE BRANCH (relay 3a) — architect lean (i).** `contactFullName_src` is ABSENT on contactdetails_tbl (P1 probe); `contactFullName` exists varchar(500); `contactPhoto_src` exists (photo needs no DDL — the photo picker stays under BOTH branches).
- **Branch (i) [lean]:** add `contactFullName_src` via a migration matching the V3_7 `_src` pattern; keep the name picker; name becomes choose-once master-adoptable like photo. **Also note (recon):** the photo VALUE column is not on contactdetails_tbl — the photo picker's write target table must be confirmed at P3 before writing a master photo. **Exact DDL (PROPOSED — NOT CREATED, per relay):**
  - File: `database/migrations/V3_13__master_directory_wo7_contactfullname_src.sql` (V3_11 burned, V3_12 = audit; V3_13 is the next free number). Idempotent, info_schema-guarded, dev+prod via DATABASE(), matching V3_7:
    ```sql
    -- guarded add (temp proc, mirrors V3_7 wo1_add_col):
    ALTER TABLE `contactdetails_tbl`
      ADD COLUMN `contactFullName_src` ENUM('user','master') NOT NULL DEFAULT 'user';
    -- post-check: information_schema.COLUMNS shows contactFullName_src present.
    ```
  - Rollback `V3_13__..._ROLLBACK.sql`: guarded `ALTER TABLE contactdetails_tbl DROP COLUMN contactFullName_src;` (only if present). Dev-apply only; prod DDL is WO-12. The `contactdetails` VIEW (V3_8) is `SELECT`-column-listed — rebuild it to expose the new column if any reader needs it (else the column is write/enforce-only; decide at P3).
- **Branch (ii):** drop the name picker entirely; names remain user-owned forever; zero DDL; the modal shows name as read-only context, never a choice. Photo picker stays.
- **Ruling requested:** (i) or (ii). Lean (i).

**Q4 — BLANK-MASTER (relay 3b) — architect position REVISED to the §7.5 default (mirror master, including blank).**
- Prior lean (keep the user's value on a linked contact) is WITHDRAWN. Reason: WO-6 enforcement keys read-only on `master_co_contact_id IS NOT NULL`, NOT on `_src` (V3_7 header line 35; `ContactService.updatePrimary` gates on the pointer). So a user-sourced value left on a linked contact would be BOTH locked (pointer present → read-only) AND unmanaged (sync only touches `_src='master'`) — a half-managed state the spec explicitly forbids (§13 "no hidden dual-source"). Making keep-user-value work would require changing WO-6's enforcement predicate — out of WO-7 scope.
- **Design follows §7.5:** the managed field mirrors the master, blank included; the pre-link user value is preserved as an item first (§7.5 line 366), then the primary is blanked. **Mitigation:** the modal discloses the blank BEFORE confirm (amber "check this one" row) and the value survives as an Additional-info item; WO-9's correction path is the fix route.
- **Operator may still escalate** (§7.5 "any exception ... requires an explicit product escalation") — presented as their call, with the dev magnitude: offices **22.7% no phone, 35.0% no email**.

**Q5 — PRESERVED-ITEM LIFECYCLE — lean consumed-and-audited.** On unlink-restore (§11.4-i), the preserved item that sources the restored value is consumed (soft-deleted) so it does not become a duplicate of the now-restored primary; audited. If the field is cleared instead (no prior value), the item remains. Ruling requested.

**Q6 — EXISTING-LINK BACKFILL now vs WO-8 — lean WO-8.** Recon: 14 active links, 0 with master email/phone snapshot, only 5 with master company, 3/12 target companies multi-office. WO-8's first sync IS the backfill; doing it in WO-7 too creates two write paths for one outcome. Lean: WO-7 governs go-forward links only; WO-8 snapshots the existing 14. Ruling requested.

**Q7 — NAME/PHOTO CHOICE PERSISTENCE — lean revisitable-at-relink-only.** The `_src` columns (contactPhoto_src, and contactFullName_src under branch i) are the storage of record. The choice is revisitable when the user relinks (the modal reappears); no separate panel control in WO-7. Ruling requested.

**3e — OFFICE-AS-MASTER-SOURCE — ratification requested.** The spec is SILENT on office selection (no co_locations mechanism). The design rests on D-21 (offices are the sole master phone/email source) + the existing code (link already writes company_location_id at MasterDirectoryService.cfc:191). Requesting operator ratification that office (co_locations by colocid, default = address1-non-blank / MIN(colocid)) is the master phone/email/address source of record.

---

## P2g — STOP

P3 authoring opens ONLY on explicit operator approval of this memo + the §P2f rulings (name branch, Q4, Q5, Q6, Q7, 3e ratification). No code, no DDL, no push at this gate.

## HOLDS (unchanged)
No DDL (V3_13 stated, NOT created — gated on the name-branch ruling + a separate migration authorization). No DML, no audit writes. No push without a named PUSH GO. Halt-don't-guess.

*END — DIR-LNK-WO7-P2-DESIGN.md*
