# DIR-LNK-WO-7 — P1 RECON (read-only)

**Work order:** DIR-LNK-WO-7 (link-with-preview flow + bridge disable + snapshot population)
**Binding:** project = TAO / repo = dev-subdomain / root = c:\Users\kevin\TAO\dev-subdomain / branch = dev
**Phase:** P1 — RECON, then STOP (per DIR-LNK-WO7-PLANLOCK.md §P1)
**Delivered:** 2026-07-18. Read-only: no writes, no DDL, no DML. DB probe via ratified read-only pymysql channel (new_development).
**Lock:** committed docs-class at `93151c33` (lock + mockup), held local (no push).

## P0a BINDING VERIFICATION (stamp)
root `C:/Users/kevin/TAO/dev-subdomain` ✓ · branch `dev` ✓ · binding-spec MD5 `078d926dfb7c146278180877e32fcbdb` ✓ ·
origin/dev HEAD = `257df24e` (one commit past the relay's last-known `d6e9e25d` = the ratified WO-6 close;
accounted-for, not an unexplained mismatch → **no halt**) · tree clean except the untracked mockup (committed at P0b).
Canonical role doc read: `database/claude-projects/tao-coldfusion-expert/00-PROJECT-INSTRUCTIONS.md` (ACF 2021 / MySQL /
soft-delete `_tbl` write discipline / service `{success,message,data}` / central `/ajax` CSRF gate / NN#10 binding rule).

## P0c REQUIRED READING (one-line gists)
- **Binding spec** (`TAO_Master_Contact_Linking_Revised_Technical_Specification.md`, MD5 078d926d): primary phone/email/
  company are master-managed COLUMNS on contactdetails_tbl when linked; contactitems is secondary-only; master p/e/c
  never written to contactitems; corrections (not edits) on linked; offices are the sole master p/e source; displaced
  user primaries preserved as non-primary items. (Verbatim anchors in §P0d below.)
- **DIR-LNK-WO6-BUNDLE.md:** WO-6 CLOSED — primary read-only enforcement (linked) + inline edit (unlinked) shipped;
  **D-23** bridge behavior of record; **Q1a specimen** 131204/132419 (orphaned pointer on a merged-away discard);
  **audit asymmetry** (links write ZERO master_audit rows while merges are logged); enforcement = `ContactService.updatePrimary`
  conditional UPDATE keyed contactid+userid, provenance server-set.
- **V3_12 migration** (`database/migrations/V3_12__master_directory_wo2_audit_correction.sql`): creates `master_audit_tbl`
  (append-only, no view, no FK; value cols VARCHAR(500) sized for co_locations 500-wide source; `idempotency_key` UNIQUE
  with NULL-distinct semantics) + `master_correction_requests_tbl`. Governed **13-action** VARCHAR vocabulary + actor_type
  {user|admin|system|migration}. **No triggers** (audit must be explicit + testable via the service layer).
- **WO-0b prod master capture** (`evidence/2026-07-04-wo0b-prod-Q8-Q15-master.txt`): co_contacts PK=id (coid 0-sentinel,
  fullname/location indexed, imdbid 100%, jobtitle_type DIRTY — leading space + embedded newlines + "(Category)" suffix),
  co_locations **PK=colocid** (→ company_location_id), companies PK=coid (coName UNIQUE; coPhone/coEmail ~0% populated).
  Offices-per-company min=1 avg=1.27 max=46, **no is_primary flag** → default-office rule needed (address1 non-blank, tie MIN(colocid)).

---

## P1a — CURRENT LINK / UNLINK PATH (full trace, file:line)

**UI (all in one IIFE, `include/contact_info.cfm:1471-1602`; `contactid` from `#masterLinkWrap[data-contactid]` :1474):**
- `#masterLinkToggle` click :1477-1480 — reveals the search box only (no write).
- `#masterLinkSearch` jQuery-UI autocomplete :1482-1499 — GET `/ajax/master/search.cfm` `{term, limit:10}`.
- autocomplete `select` → `loadLocations(coid)` :1500-1513, :1515-1544 — GET `/ajax/master/locations.cfm` `{coid}`; 0/1 office auto-selects, >1 shows a `<select>` + Link button (:1538-1540).
- `doLink()` :1546-1582 — **POST** `/ajax/master/link.cfm` `{contactid, masterCoContactId, coid||0, colocid||0}` (:1551-1556). (The "last sync" label is stamped client-side from `new Date()` :1567-1570 — cosmetic only.)
- `#masterUnlinkBtn` click :1584-1602 — **POST** `/ajax/master/unlink.cfm` `{contactid}` (:1590).

**Endpoints (`ajax/master/`):** `search.cfm`, `locations.cfm`, `link.cfm`, `unlink.cfm`. Auth+CSRF via the central `/ajax/Application.cfc` gate (no in-file checks — WO-6 L-3 ruling). `link.cfm:22-27` validates positive ints, strips `recordname` (:17), calls `MasterDirectoryService.linkContactToMaster(contactid, masterCoContactId, coid, colocid, userid=session.userid)` (:30-35). `unlink.cfm:18-27` → `MasterDirectoryService.unlinkMaster(contactid, userid=session.userid)`. **Client `coid`/`colocid` are re-derived server-side and validated** (MasterDirectoryService.cfc:127-138) — client values not trusted.

**Service (`services/MasterDirectoryService.cfc`): `linkContactToMaster` :91-235 (cftransaction :143); `unlinkMaster` :240-311.** All contactdetails writes flow through `ContactService.update` (:140-274), a key-gated whitelist UPDATE — the `upd` struct is the sole gate.

**LINK writes (upd :188-216):** master_co_contact_id (:189) · master_coid (:190) · company_location_id=newColoc (:191) · master_last_sync=now() (**:192 unconditional**) · contactCompany=coName (**:201 prev-blank OR :204 prev `_src='master'`**; or `""` :209 relink-to-no-company-master) · contactCompany_src (:202/:205 `'master'`; :210 `'user'`) · master_linked_date=now() (**only when NULL** :214-216) · **bridge Company contactitem** via `ContactItemService.createCompanyItem` (:156-158) / rename (:162-170) / soft-delete (:175-183).
**LINK does NOT write:** contactPhone, contactEmail (no such branch exists in ContactService.update at all), contactFullName, photo, name/photo `_src`, and **no master_audit_tbl row**.

**UNLINK writes (upd :293-302):** pointers → NULL (:294-296) · contactCompany_src='user' (**:297 unconditional**) · master_last_sync=now() (**:298 unconditional**) · contactCompany → NULL (**only if preSrc='master'** :300-302) · soft-delete matching Active Company items (**only if preSrc='master'**, R-1 exact-name match :279-290). Idempotent no-op if all three pointers already NULL (:257-261). **No master_audit_tbl row.**

**D-23 claim-by-claim (verified against code):**
1. `master_last_sync` stamped on EVERY link — **CONFIRMED** (:192, unconditional).
2. contactCompany+`_src='master'` written **only when column was blank** — **REFUTED AS STATED.** Written when blank (:200-202) **OR when already `_src='master'`** (:203-205); i.e. it will not overwrite a `_src='user'` company, but it DOES overwrite an existing master-sourced one. Corrected D-23 wording: *"written when the column is blank **or already master-sourced**; a user-sourced company is left intact."*
3. email/phone never written by the link path — **CONFIRMED** (structurally absent from ContactService.update).
4. relink overwrites a master-sourced company with the new master's value — **CONFIRMED** (:203-205, item rename :160-170; relink-to-no-company clears :207-211).
5. unlink clears the master-sourced company — **CONFIRMED, conditional on `preSrc='master'`** (:300-302); `_src` always reset to 'user' (:297); a user-sourced company is preserved.
- company_location_id set by link? **YES** (:191). Cleared on unlink (:296). Name/photo or their `_src` written? **NO** (never in `upd`). Audit row on link/unlink/relink? **NO** (grep `master_audit` in services/ = zero; only `cflog file="master_link"` :221-222/:307-308).

## P1b — BRIDGE WRITE SITE + BLAST RADIUS

**INSERT:** `services/ContactItemService.cfc:851-860`, function `createCompanyItem` (:847-864). Columns written (5 only): `CONTACTID`, `VALUETYPE='Company'`, `VALUECATEGORY='Company'`, `ValueCompany=trim(companyName)`, `ITEMSTATUS='Active'`. NOT written: userid, primary_YN, IsDeleted, valuetext, `_src` (Company value lives in `valueCompany`, not `valuetext`).
**Sole caller:** `MasterDirectoryService.cfc:156` inside `linkContactToMaster`'s transaction, when the Active-Company pre-read `qItems` (:145-152, filtered `itemStatus='Active' AND IsDeleted=0`) returns zero rows.
**Dedupe:** guard is **Active-rows-only** — it never considers soft-deleted rows or reuses one. Unlink soft-deletes (:280-288); the next link sees `recordCount=0` and INSERTs a **fresh physical row** → accumulation across relink cycles (matches D-19: 312620→312621→…; `evidence/2026-07-14-dir-lnk-D19-132419-provenance.md:18-19`). No unique constraint anywhere on the path.
**Blast radius if disabled (Section 2a):** only **two secondary readers** still consume the bridge Company item —
(1) contact-card **"Additional information"** grid `include/contact_pane.cfm:73-75` (via `ContactItemService.itemsByCatActive` :83-114), and
(2) **contact export** `include/exportContacts.cfm:100-104` → `SELcontactitems_23892` (:388-401) → `exportitems.Company`.
Everything else reads the `contactCompany` **column** post-WO-5: contacts_ss, sharez/sharezz/sharez_optimized/v_contacts_optimized (`database/wo5/WO5_01_views_dev.sql`), and the panel's **primary** company field (`contact_info.cfm:821` from `qMasterLink.contactCompany` :654-656). Net: disabling the bridge removes only the master-sourced **duplicate** from those two surfaces; contacts with a hand-entered Company item are unaffected. **WO-7 snapshot writes the column, so the panel/list stay correct; the two secondary readers are the design consideration for P2** (do they read the column too, or does snapshot also emit a preserved/secondary item?).

## P1c — SEARCH / MATCH UI (where preview inserts)

- Search endpoint `ajax/master/search.cfm` → `MasterDirectoryService.searchPeople` (:31-42): `SELECT cc.id AS master_co_contact_id, cc.fullname, cc.jobtitle_type, cc.coid, co.coName FROM co_contacts cc LEFT JOIN companies co ON co.coid=cc.coid WHERE cc.fullname LIKE '<term>%' ORDER BY cc.fullname LIMIT <1..25>`. JSON: `{success,message,data:[{master_co_contact_id,fullname,jobtitle_type,coid,coName}],_build}`. (No co_locations join in search.)
- Locations endpoint `ajax/master/locations.cfm` → `getLocations` (:61-85): `SELECT colocid, location, address1, city, state FROM co_locations WHERE coid=?`. **NOTE:** getLocations returns NO phone/email/zip/address2 today — the office picker (Section 3 item 3) needs office phone + full address, so **getLocations must be widened at P3** (phone, email, address2, zip). Flag, not a schema gap.
- On select (:1500-1512): captures `masterCoContactId, coid, coName, colocid`. `doLink()` (:1546-1582) POSTs those to `link.cfm`.
- **Preview insertion point:** today search-select → (auto/office-select) → immediate `doLink()`. WO-7 replaces the direct `doLink()` with **open the preview modal** (GET-load, see house pattern below); the confirm button becomes the write. `#masterLinkSearch`/`loadLocations` stay as the finder feeding the modal.
- **House modal pattern to reuse** (`app/contact-duplicates/index.cfm`): trigger `showMergeModal(ids)` :254-260 does `$('#mergeContent').load('/include/merge_contacts_interface.cfm?...', ()=>modal.show())` into Bootstrap-5 modal `#mergeModal`/`#mergeContent` (:217-234). GET `.load` runs the include's inline `<script>` and needs no CSRF. WO-7: `showPreviewModal(...)` → `$('#previewContent').load('/include/<preview>.cfm?contactid=..&masterCoContactId=..&colocid=..', ()=>modal.show())`.

## P1d — SCHEMA PROBES (dev = new_development; values, not assumptions)

- **contactFullName_src: ABSENT.** `contactFullName` PRESENT varchar(500), but its provenance twin does NOT exist. **`contactPhoto_src` PRESENT** `enum('user','master')` — but the photo **value** column `contactphoto` is **NOT on contactdetails_tbl** (photo value lives on another table; the panel reads `details.contactphoto` from a different query). → **GENUINE GAP for Section 2f:** photo has a `_src` twin, name does NOT. Storing name provenance via `_src` (Section 2f) requires **adding `contactFullName_src`** (a migration) OR handling name-choice differently. **FLAGGED — do not create; operator migration decision at P2/P3.**
- All primary `_src` columns present as `enum('user','master')`: contactCompany_src, contactEmail_src, contactPhone_src. Widths: contactCompany varchar(255), contactEmail varchar(150), contactPhone varchar(100).
- **company_location_id: PRESENT `int`, and WRITTEN today** (MasterDirectoryService.cfc:191) → co_locations.colocid. Master pointers present: master_co_contact_id, master_coid, master_last_sync (datetime), master_linked_date (datetime).
- **co_locations columns (dev):** page_url, colocid(PK), location, address1, address2, city, state, zip, country, **phone varchar(500)**, fax, **email varchar(500)**, website, timestamp, current_time, page_title, coImdbID, coid(FK). (Matches prod capture.)
- **co_contacts columns (dev):** id(PK), title, page_url, **image_url**, name_url, **fullname**, suffix, starmeter, **jobtitle_type**, location, **coid**, **imdbid**, timestamp, coimdbid, tag, contactid(legacy — do not reuse).
- **Master volumes (dev):** co_contacts 25,200 · co_locations 12,617 · companies 10,740.
- **Offices-per-company (dev):** **1,661 companies have >1 office** (of 9,955 with ≥1 = **16.7%**); max 46. → the office picker is non-trivial for ~1 in 6 companies (no is_primary flag; default = address1 non-blank, tie MIN(colocid)).
- **Office phone/email population (dev, co_locations, the blank-master magnitude):** total 12,617 · **no_phone 2,870 (22.7%)** · **no_email 4,422 (35.0%)**. (Measured against OFFICES per the relay; slightly below the company-level 27.4%/37.7% last-known.) → the amber "check this one" row fires often; Q4 is a real, frequent case.

## P1e — EXISTING LINKED SET (dev; decides Q6 on numbers)

- **14 linked & active** (17 incl soft-deleted).
- Per-field `_src` among the 14: **contactCompany_src {user:9, master:5}** · **contactEmail_src {user:14}** · **contactPhone_src {user:14}**. → only 5 have a master-sourced company; **ZERO have master-sourced email or phone** (the bridge never snapshotted p/e — matches D-23 #3).
- 13/14 have `company_location_id` set · 14/14 have `master_last_sync` · only 5 have contactEmail populated / 6 have contactPhone populated (all `_src='user'`, i.e. user-entered, not master).
- Linked-target companies: **12 distinct, 3 multi-office** (~25%).
- **Q6 read:** the 14 existing links are genuine snapshot-backfill candidates (9 lack a master company; 14 lack any master email/phone). A backfill is real work; doing it in BOTH WO-7 and WO-8 risks two write paths for one outcome (architect lean = WO-8's first sync IS the backfill). Numbers support deferring existing-link snapshotting to WO-8.
- Adaptive-density baseline (dev, 1571 active contacts): contactPhone 17.4% · contactEmail 14.8% · contactCompany 28.1% populated (relay cited 20/18/37 — directionally right, slightly high). → **short form is the common link case** (most contacts have nothing to displace), confirming Section 3's adaptive-density requirement.

---

## P0d — SPEC EXTRACTION (verbatim anchors)

**Framing:** the spec (MD5 078d926d) is written at product altitude and deliberately does not name physical columns/tables (§5 lines 163-164 "inspect the actual schema and reuse existing columns"; §24 lines 1179-1180). Many WO-7 physical artifacts (`_src`, `master_last_sync`, `company_location_id`, `co_locations`, `contactPhoto`, `contactFullName`, `master_audit_tbl`) are therefore **SILENT by name** — the spec gives the concept, the physical binding routes to recon + operator ruling.

- **LINK — order of ops (§7.3, lines 334-345):** *"Before replacing a primary field: 1. Normalize the current user value. 2. Compare it with the incoming master value. 3. If the user value is blank, do nothing. 4. If the user value matches the master value, do not create an additional item. 5. If the user value differs ... Insert it as an additional `contactitem`, unless an equivalent active item already exists. ... Do not mark it primary. 6. Complete the preservation and primary replacement in one transaction."* Preservation is BEFORE population (§7.4 line 349 "After preservation:"). Atomic (§7.6 lines 371-382; §17 line 852).
- **SNAPSHOT (§7.4, lines 347-360):** *"Set primary phone to master phone. - Set primary email to master email. - Set primary company to master company. - Store the linked master contact ID. - Set link status active. - Store link timestamp. - Store synchronization timestamp/version. - Mark primary fields master-managed if source columns are retained. - Write audit history."* Provenance values (§5.1 lines 190-194): *"valid values should remain simple, such as: - `user` - `master`"* (conditional, "If retained"). `MASTER_SNAPSHOT_POPULATED` (§16 line 828).
- **PRESERVATION (§2 rule 11, line 50):** *"Any differing pre-link user primary value must be preserved as an additional `contactitem` before replacement."* "Additional Information" destination (§7.2 line 331, §13.2 line 732). Nothing deleted (§2 rule 7 line 46; §23 lines 1141-1143). Skip-if-equivalent (§7.3). `PRELINK_VALUE_PRESERVED` (§16 line 827). No dup preserved items (§17 line 858).
- **OFFICE SELECTION — SILENT (largest gap):** no `company_location_id` / `co_locations` / office / default-office / multi-office mechanism anywhere. The master's three values are abstract ("Master primary phone/email/company", §4.2 lines 106-109). "Alternate office" appears only as a user contactitems example (§8.2 line 410). **How the master derives phone/email is spec-silent → operator ruling.** (Code + D-21 already answer it: offices are the source.)
- **UNLINK (§11.4, lines 616-626):** *"The preferred behavior is: 1. Restore the pre-link user primary values where reliable history exists. 2. If no prior value exists, clear the affected primary field. 3. Preserve any alternate values already stored in `contactitems`. 4. Allow the user to edit the primary fields after unlinking."* → **restore-else-blank**; keep-but-flip-src is NOT offered. `PRELINK_VALUE_RESTORED` / `PRIMARY_FIELD_CLEARED_AFTER_UNLINK` (§16 lines 835-836). Restoration reads the preservation audit history (§16 lines 841-842). Unlink is bad-match-only, guarded label (§11.1 lines 572-589).
- **RELINK (§11.4, lines 627-633):** atomic relink — *"Preserve user-specific data - Replace the master identity - Populate new master snapshots - Keep relationship history attached to the same user contact."* `MASTER_RELINKED` (§16 line 834).
- **BLANK-MASTER (§7.5, lines 361-369):** *"If the master value ... is blank: ... Pre-link user data must first be preserved as an additional item. ... The expected default is that linked primary fields mirror the master, including blank master fields. - Any exception to this rule requires an explicit product escalation."* → **default = blank (mirror master); keeping the user value is the exception that requires escalation.** ("PC-1" is an external label for this section.)
- **MASTER IDENTITY = THREE FIELDS ONLY (§1, §2 rule 1 line 40, §9.1 line 446, §25 line 1197).** Name is UNVERIFIED / not default scope (§9.2 lines 460-462: *"Claude Code must verify whether standardized name fields ... are also part of the current link model. Do not expand synchronization beyond approved scope without escalation."*). Photo/`contactPhoto`/imdb/address as master identity = **SILENT** (address only a contactitems example). No per-contact field-choice concept; linking is all-or-nothing over the three primaries (§2 rule 10 line 49).
- **CORRECTION = WO-9 boundary (§8.3 lines 416-437, §10 lines 524-566).** WO-7's only obligation is to surface the affordance "Suggest a correction" in a guarded location (§13.2 lines 730-734) — the workflow behind it is Phase-7/WO-9.
- **AUDIT (§16, line 806):** *"Use an existing audit mechanism if it fully supports the requirements. Otherwise create a dedicated history structure."* → physical store (reuse vs `master_audit_tbl`) is a ruling; the table exists (V3_12). Conceptual fields §16 lines 808-820; auditability binding rule §2 rule 18 line 57; idempotency-key dup guard §17 line 859; PII-not-in-broad-logs §22 lines 1127-1129.
- **Governing sections (nothing missed):** §1, §2 (rules 1/4/7/9/10/11/12/17/18/20), §4.1-4.5, §5/5.1, §6 (backfill prerequisite, line 200), **§7.1-7.6 (primary)**, §8.1-8.3, §9.1-9.5, §10, §11.1-11.5, §12, §13, §14, §15 (bridge removal), §16, §17, §18 (normalization), §19 (Phase 5 = WO-7), §20, §21 (tests 8-17/29-32/36), §22, §23, §24-25.
- **SILENCE REGISTER (→ operator ruling):** (1) `_src='master'` literal naming; (2) `master_last_sync` name; (3) **office selection mechanism entirely**; (4) blank-master "PC-1" label (substance = §7.5); (5) name as a synced field (UNVERIFIED); (6) photo/imdb/address as master identity; (7) per-contact/global choice + name/photo `_src` columns; (8) `master_audit_tbl` table name.

---

## RECON-DERIVED FLAGS FOR P2 (not decisions)

1. **Q4 is NOT silent — the spec has a default that contradicts the architect lean.** §7.5 sets the default to *"linked primary fields mirror the master, including blank master fields,"* and *"Any exception to this rule requires an explicit product escalation."* The architect's Q4 lean (keep the user's value when the office is blank) IS that exception → Q4 is an escalation decision, not a free pick. The modal's amber "check this one" row is exactly where §7.5's default becomes visible. Dev magnitude: 22.7% of offices blank-phone, 35.0% blank-email — this fires constantly.
2. **Q2 is largely spec-answered.** §11.4 = *restore pre-link where reliable history exists, else clear* — i.e. option **(i) with a blank fallback**; option (ii) keep-but-flip-`_src` is not offered by the spec. The architect lean (i) is spec-aligned; the preserved-item-as-restore-source (Q5) is the mechanism §16 lines 841-842 depend on.
3. **Name/photo choice (Section 2f) exceeds the spec's approved scope AND is schema-gapped.** Spec caps master control at the THREE primaries (§1/§2.1/§9.1/§25); name is explicitly UNVERIFIED and "do not expand ... without escalation" (§9.2); photo/imdb/address as master identity are SILENT. Separately, **`contactFullName_src` is ABSENT** (probe) — even if approved, name-provenance-via-`_src` needs a migration (`contactFullName_src enum('user','master')`). `contactPhoto_src` exists, but the photo VALUE column is not on contactdetails_tbl (home table TBD). → Section 2f is a **double gate: product escalation + migration.** Do not create; operator decision at P2.
4. **Office-as-master-source is spec-SILENT but code-real + D-21-ruled.** `company_location_id` and the whole search→locations→link spine already exist (link writes colocid at MasterDirectoryService.cfc:191). The spec never mandates offices; the design rests on D-21 (offices sole master p/e source) + existing code. → P2 should have the operator RATIFY office-as-source explicitly (it is the spec's silent gap #3).
5. **D-23 wording correction of record:** link writes contactCompany+`_src='master'` when blank **or already master-sourced** (not "blank only"); a `_src='user'` company is preserved.
6. **getLocations must be widened** (phone/email/address2/zip) to feed the office picker + diff — code change, not schema.
7. **The link plumbing is not greenfield** — WO-7 is largely (a) insert the preview modal before the write (reuse the contact-duplicates GET-load pattern), (b) add snapshot population of email/phone + preservation + [name/photo if escalated] + audit, all in one transaction, (c) disable the bridge.
8. **Bridge-disable blast radius = 2 secondary readers** (contact_pane "Additional information" grid `:73` + export `SELcontactitems_23892`). P2 must decide whether snapshot also emits a secondary item those readers see, or whether they repoint to the `contactCompany` column.
9. **Audit is greenfield for links** (zero rows today; §16 "reuse existing OR dedicated" → the existing `master_audit_tbl` fits). WO-7 is the first link-event audit writer; use only the governed vocabulary (LINK_CREATED / PRELINK_VALUE_PRESERVED / MASTER_SNAPSHOT_POPULATED / MASTER_RELINKED / PRELINK_VALUE_RESTORED / PRIMARY_FIELD_CLEARED_AFTER_UNLINK — all present in V3_12), with a deterministic `idempotency_key` on any retry-guarded write (UNIQUE, NULL-distinct).
10. **Existing 14 links** carry no master email/phone snapshot and only 5 a master company; 3 of 12 target companies are multi-office → supports **Q6 = defer existing-link backfill to WO-8** (its sync IS the backfill; two write paths for one outcome otherwise).

**STOP — P1 recon delivered. Awaiting architect/operator review to open P2 (design memo + Q2/Q4/Q5/Q6/Q7 rulings).** No code, no DDL, no DML. Lock + mockup committed docs-class (`93151c33`), held local; no push without a named PUSH GO.

*END — DIR-LNK-WO7-P1-RECON.md*
