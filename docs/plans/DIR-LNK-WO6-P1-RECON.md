# DIR-LNK-WO-6 — P1 RECON (linked/unlinked UI enforcement + primary write paths). STOP.

**Binding (verified this session — NN#10 PROCEED):** project TAO-MCD-P1 · series DIR-LNK-WO-1..12 ·
repo `kevinlawrenceking/dev-subdomain` · root `C:\Users\kevin\TAO\dev-subdomain` · branch `dev` ·
clean tree at start · local HEAD `7f354b55` (P0 lock commit; origin/dev `a4b68bad` — local is one
docs commit ahead, expected) · binding spec MD5 `078d926d` re-verified this session.
**Mode:** read-only recon — code + ratified DB read channel (pymysql, SELECT/SHOW only against
`new_development`). No code, no DDL, no DML, no push. Plan of record = `DIR-LNK-WO6-PLANLOCK.md`
(@ `7f354b55`).

---

## 0. P0c REQUIRED READING — one-line gists

- **Binding spec** (`TAO_Master_Contact_Linking_Revised_Technical_Specification.md`, MD5 078d926d):
  primaries live in contactdetails columns; unlinked = user-editable, linked = read-only
  master-managed; contactitems = additional info only; master values never into contactitems.
- **DIR-LNK-WO5-P1-DELTA.md:** Class-B inventory = the per-item editor loops in
  `contact_pane.cfm` / `contact_info.cfm` — preserved, not repointed, in WO-5; badge already reads
  the primary column.
- **DIR-LNK-WO5-P5-BUNDLE.md (@39fe6b30) + ADDENDUM (@a4b68bad):** dev read cutover ACCEPTED —
  five dev views (contacts_ss, sharez, sharezz, sharez_optimized, v_contacts_optimized) now read
  p/e/c from contactdetails primary columns (DDL of record @ beb6c4c0); C10 down-and-back PASS.
- **DIR-LNK-WO1-RECON.md §3:** reader/writer inventory of record — sole primary-column writer =
  `ContactService.update()` driven by MasterDirectoryService; contactPhone/contactEmail + `_src`
  never written. Re-verified live this session (§4 below): **CONFIRMED**.
- **WO-DUPES merge lineage (57c261b5, ratified 2026-07-06):** conformant merge rewrite of record;
  live code traced this session at `services/ContactDuplicateService.cfc:439-1159` (§7 below).

---

## 1. P0d SPEC EXTRACTION (verbatim anchors; silences stated)

### 1a. Linked read-only enforcement
- Spec §2 rule 9 (line 48): "While a contact is linked, the three primary fields are read-only and
  controlled by the Master Contact Directory."
- Spec §8.1 (lines 387-395): "While linked, the user cannot directly edit: Primary phone / Primary
  email / Primary company ... These values must be displayed read-only."
- Spec §8.3 (line 437): "The user must not directly change the shared master value from the normal
  contact form."
- Phase 5 (line 948): "Make linked primary fields read-only." Acceptance (lines 1015, 1082):
  "Linked primary fields become read-only." / "Linked contact primary fields are read-only."

### 1b. Unlinked editability
- Spec §2 rule 8 (line 47): "While a contact is unlinked, the user may edit the three primary
  fields directly."
- Spec §13.1 (lines 701-718): "Display editable: Primary phone / Primary email / Primary company.
  Display separately: Additional phones / Additional emails / Additional companies / Other
  `contactitems`. Provide: Search/link to Master Contact Directory."

### 1c. Items-as-additional framing
- Spec §2 rule 3 (line 42): "`contactitems` stores additional or secondary information only."
- Spec §2 rule 15 (line 54): "Users may always add additional phone, email, company, address,
  social, date, note, or other supported item data."
- Spec §8.2 (lines 401-414): "While linked, the user may add, edit, and soft-delete additional
  information through `contactitems`." (Examples list: direct number, personal email, assistant's
  email, alternate office, historical affiliation, mailing address, social profile, important date.)
- Spec §13.3 (lines 736-740): "The screen must not silently display a master value while saving
  edits to another field or item source. Display and write behavior must be explicit and consistent."

### 1d. Badge / indicator presentation
- Spec §8.1 (lines 397-399): 'The UI should indicate: "Managed by the TAO Master Directory".'
- Spec §13.2 (lines 720-734): "Display read-only: Primary phone / Primary email / Primary company /
  Master-managed badge / Last synchronized timestamp if useful. Provide: Add additional
  information / Suggest a correction / Correct master match, in a guarded location."

### 1e. Photo scope
- **SPEC IS SILENT.** Zero occurrences of "photo" (case-insensitive) in the spec. Per lock §2e:
  photo (`contactPhoto`/`contactPhoto_src`) is **OUT of WO-6 scope**. (Note: `contactPhoto_src`
  exists in the dev view/table — schema provisioned, spec-unmentioned.)

### 1f. Merge and import against linked contacts (Q1 material)
- **Merge: SPEC IS SILENT on user-level contact merge.** The only merge mentions are §2 rule 16
  (line 55, "merge error" as an unlink justification), line 580 ("A master merge or split requires
  correction" — master-side), and line 884 (company fuzzy-match caution — master-side). No section
  governs what happens when a user merges two of their own contacts and one is linked. Q1a/Q1b/Q1c
  are **operator rulings**, not spec answers.
- **Import: SPEC IS SILENT.** The only "import"-adjacent matches are the §8.2/§5 "Important date"
  item examples (lines 154, 414). Q1d is an **operator ruling**.
- Q1e (unlinked go-forward) IS spec-answered: §2 rules 7-8 + §13.1 (see 1b).

---

## 2. LIVE SCHEMA FACTS (ratified read channel, `new_development`, 2026-07-15)

- `contactdetails` = **VIEW** over `contactdetails_tbl` (BASE TABLE); 1:1, all 44 columns present
  in both, no WHERE-clause divergence material to writes; `is_updatable = YES`. All 12 master
  columns present in the view (contactPhone/Email/Company, three `_src`, contactPhoto_src,
  company_location_id, master_co_contact_id, master_coid, master_linked_date, master_last_sync).
- `contactitems` = **VIEW** over `contactitems_tbl` (BASE TABLE); updatable (`is_updatable = YES`).
- `updatelog` = **VIEW**; base = `updatelog_tbl` (matters for P1d: the logging service writes
  through the view).
- Primary column widths (oversize-test targets, lock P5d): `contactPhone varchar(100)`,
  `contactEmail varchar(150)`, `contactCompany varchar(255)`; `_src` columns are
  `enum('user','master') NOT NULL`; `recordname varchar(500) VIRTUAL GENERATED` (never write).

**Consequence:** writes through the views succeed mechanically today (single-table updatable
views). The registered view-write concern is doctrinal/fragility class (house rule `_tbl` for
writes; a future non-updatable view redefinition turns these into hard errors), **not** a live
silent-drop. See §4 for the create-path verification.

---

## 3. P1a WRITE-SURFACE INVENTORY (every surface that can create/modify p/e/c data)

### 3a. Auth architecture — the two enforcement layers (governs everything below)

- **`/ajax/*` (`ajax/Application.cfc`):** auth ENFORCED — no `session.userid` → 401
  (`ajax/Application.cfc:57-63`). CSRF ENFORCED on POST/PUT/DELETE via `X-CSRF-Token` header or
  `form.csrfToken` (`:80-128`), EXCEPT self-token paths `/ajax/importv3/` and
  `/ajax/import-auditions/` (`:84`).
- **`/include/*` (`include/Application.cfc`):** **NO login gate** — `onRequestStart` (`:2-61`)
  overrides the parent without calling `super`, so `app/Application.cfc:389-393`'s login redirect
  never runs. CSRF is **conditional**: checked only when `session.csrfToken` exists
  (`include/Application.cfc:22`); an unauthenticated session (no token minted —
  `app/Application.cfc:397-398` mints only for logged-in users) skips both gates. The legacy
  contact-page editors all live here.
- **`/app/*` (`app/Application.cfc`):** login gate `:390-394`; CSRF for POST `:401-442`.

### 3b. Item editors (contact page) — write contactitems

| # | Surface | Entry → write | Writes | Target | Ownership at write site | CSRF |
|---|---------|---------------|--------|--------|------------------------|------|
| 1 | Edit item (p/e/c + all cats) | modal `remoteUpdateC#itemid#` (`include/remoteUpdateC.cfm:32`) → `include/remoteUpdateCUpdate.cfm:58,59` → `ContactItemService.UPDcontactitems_24178` (`services/ContactItemService.cfc:1007`, UPDATE `:1026`) + `_24179` (`:1079`, UPDATE `:1084`) | items: valuetext, valuetype, valueCompany, valueDepartment, valueTitle, address fields, itemdate | `contactitems` VIEW | **NONE — `WHERE itemid = ?` only** | include layer: none effective |
| 2 | Add item | `include/remoteAddCAdd.cfm:20,76` → `INScontactitems_24043` (`ContactItemService.cfc:774`, INSERT `:783`) + `UPDcontactitems_24046` (`:802`, UPDATE `:818`) | new item incl. p/e/c | `contactitems` VIEW | **NONE — client-supplied contactid; UPDATE by itemid** | none effective |
| 3 | Add contact + items (main add form, "My Team" modal) | `include/remoteAddContact.cfm:7-62` → `include/remoteAddContactAdd.cfm` (cftransaction `:31-62`) → contact `add_201_1.cfm:3` → `INScontactdetails_24048` (`ContactService.cfc:1078`, INSERT **`contactdetails_tbl`** `:1083`); items `insert_201_2..5.cfm` → `INScontactitems_24049..52` (`ContactItemService.cfc:865-932`, INSERTs `:870,:887,:904,:921`) | contact row + Tag/Email/Phone/Company items (company into `valuetext`, not valueCompany, at `:921`) | contact → **_tbl**; items → VIEW | **NONE — `userid` from POSTed hidden field** (`remoteAddContact.cfm:10`) | none effective |

### 3c. Contact-detail (column) editors

| # | Surface | Entry → write | Writes | Target | Ownership | CSRF |
|---|---------|---------------|--------|--------|-----------|------|
| 4 | Edit contact name/meeting/pronoun/referral | modal `remoteUpdateName` (`contact_info.cfm:752`) → `include/remoteUpdateNameUpdate.cfm:24` → `updatecontact_270_1.cfm:3` → `UPDcontactdetails_24202` (`ContactService.cfc:1167`) → **`ContactService.update()`** (`:126`, UPDATE `contactdetails` VIEW `:139`) | contactdetails columns (not p/e/c today, but the shared writer CAN write contactCompany + `_src` + master pointers if keys are passed) | VIEW | **NONE — `update()` WHERE contactid only (`:257`), no userid; caller passes client contactid** | none effective |
| 5 | Generic RPG updater | `include/remoteUpdateForm.cfm:23` / `share/remoteUpdateForm.cfm:49` / `include/results.cfm:71` → `include/remoteUpdateFormUpdate.cfm` (dynamic `UPDATE #compTable#` via `update_311_2.cfm`, table/column whitelist-validated `:22-29`) | any RPG-registered column on any RPG table — could reach contactdetails columns if RPG metadata maps them | dynamic | RPG metadata-scoped; no explicit userid predicate at write | include layer: none effective |
| 6 | `ContactService.update()` itself | `services/ContactService.cfc:126-260` | ONLY method anywhere writing `contactCompany` (`:238`), `contactCompany_src` (`:243`), `master_co_contact_id` (`:223`), `master_coid` (`:228`), `company_location_id` (`:233`), `master_linked_date` (`:248`), `master_last_sync` (`:253`) | `contactdetails` VIEW | **WHERE contactid only (`:257`)** — ownership must come from callers | n/a (service) |

### 3d. Master path (the trusted internal writer, bridge live until WO-7)

| # | Surface | Write sites | Target | Ownership | CSRF |
|---|---------|-------------|--------|-----------|------|
| 7 | `ajax/master/link.cfm` → `MasterDirectoryService.linkContactToMaster` (`:91`, cftransaction `:143`) | Company item create → `ContactItemService.createCompanyItem` (`ContactItemService.cfc:852`, INSERT **`contactitems_tbl`**) at `MDS:156`; rename `MDS:163`; soft-delete `MDS:177` (both **_tbl**); columns via `ContactService.update` at `MDS:218` | items _tbl; columns VIEW | session userid + in-SQL ownership (`MDS:99-108`) | ajax layer ENFORCED |
| 8 | `ajax/master/unlink.cfm` → `unlinkMaster` (`:240`, cftransaction `:276`) | Company item soft-delete `MDS:281` (_tbl); pointer/snapshot clear via `ContactService.update` (`MDS:293-304`) | same | ownership (`MDS:245-252`) | ENFORCED |

`MasterDirectoryService.cfc:1` header: "sole contactdetails writer is ContactService ... Never
writes contactPhone/contactEmail (PD-L1)". Confirmed by full-repo grep: **no code anywhere writes
contactPhone, contactEmail, contactPhone_src, or contactEmail_src** — read-only columns today
(`ContactService.cfc:100-104` read).

### 3e. Setup wizard (`/ajax/setup-wizard/*` — ajax layer, auth+CSRF enforced, userid = session)

| Step | Handler | Contact write | Items write (p/e/c) | View or _tbl |
|------|---------|---------------|---------------------|--------------|
| 1 Profile | `save-step1.cfm` | UPDATE self-contact `:95` (**`contactdetails_tbl`**) | phone upsert UPDATE `:115` / INSERT `:121` (**`contactitems_tbl`**) | **_tbl both** |
| 2 Representation | `save-step2.cfm` | `ContactService.create()` `:39` → INSERT `contactdetails` **VIEW** (`ContactService.cfc:57`) | email `:49`, phone `:61`, company `:73` (valueCompany), tag `:93` → **`contactitems_tbl`** | contact **VIEW** / items **_tbl** |
| 3 Add Contacts | `save-step3.cfm` | `create()` `:34` → **VIEW** | email `:51`, phone `:61`, company `:74`, tag `:86` → **_tbl** | contact **VIEW** / items **_tbl** |
| 4 Auditions | `save-step4.cfm` | `create()` `:195` (casting directors) → **VIEW** | CD tag via `INScontactitems` `:246` → `contactitems` **VIEW** (`ContactItemService.cfc:250`) | **VIEW both** |
| 5-7 | `save-step5..7.cfm` | none (enrollments / sitelinks / activation only) | none | n/a |

### 3f. Import V2 / V3 (staging is clean; finalize writes items via VIEW)

- **V2** (`/ajax/import/*`, framework CSRF applies; `finalize.cfm` auth `:22` + job ownership
  `:56-60`): staging → `import_jobs`/`import_job_rows`/`import_job_columns` only. Finalize
  (`ContactImportV2Service.executeImport:1016`, per-row cftransaction `:1060`): contact via
  `create()` `V2:1200` (VIEW); email/phone `addContactItem` SQL `V2:1357`, company `addCompanyItem`
  `V2:1379`, address `V2:1401` — all `contactitems` **VIEW**. `updateExistingContact:1271` → core
  fields via `update()` `V2:1291` (VIEW), new items after `itemExists` check `V2:1300-1325`.
- **V3 EXISTS** (`/ajax/importv3/*`, self-CSRF: `finalize.cfm:140-193` token vs `session.csrf_token`;
  auth `:100-102`; ownership `getJobForUser` → `ContactImportV3Service.cfc:256-303`; create-only per
  header `:1174`): staging → `import_v3_*` tables only. Finalize (`processRowForImport:1470`,
  per-row transaction `:1553`): contact direct `INSERT INTO contactdetails` **VIEW** `V3:1557` (no
  ContactService); emails `V3:1871`, phones `V3:1889`, company `V3:1906`, address `V3:1923`, socials
  `V3:1952-1995`, tags/note `V3:2011,2027` — all `contactitems` **VIEW**.
- **Both importers write p/e/c as ITEMS only** — never primary columns (Q1d/adoption input for P2d).

### 3g. Phonebook

**Does not exist as a feature.** No `phonebook` table, page, or service; the sole reference was a
never-functional `INNER JOIN phonebook` in `AuditionImportService.cfc`, removed 2026-07-03
(WO-PHONEBOOK, marker at `AuditionImportService.cfc:1615-1618`; verdict
`docs/plans/evidence/2026-07-03-wo-phonebook-recon.md`). No p/e/c write path.

### 3h. Merge

`/app/contact-duplicates/index.cfm:36` → `ContactDuplicateService.mergeContacts` — app layer
(login gate + CSRF per `index.cfm:21`, PRG pattern `:47-48`), userid = session. Writes traced in §7.

### 3i. Other creators that ride along (contact row, p/e/c as items or none)

| Surface | Contact INSERT target | Cite |
|---------|----------------------|------|
| Quick-create placeholder | `contactdetails` VIEW via `INScontactdetails_23839` → `create()` | `include/contact_add.cfm:2` → `add_82_1.cfm:3` |
| Audition add (new CD) | VIEW via `INScontactdetails` → `create()` | `include/audition-add2.cfm:95-96` → `inscontactdetails.cfm:5` (`ContactService.cfc:853-864`) |
| Audition transfer | VIEW `INSERT INTO contactdetails` `:233`; items VIEW `:253` | `include/transfer_audition.cfm` |
| Appointment quick-create | VIEW, inline cfquery | `sched/appoint-update2.cfm:60-66` |
| Provisioning self-contact | VIEW | `setup/user_setup_core.cfm:954`; `sched/user_setup_core.cfm:982`; `sched/usercontact.cfm:12`; `services/SetupProvisioningService.cfc:678` |
| Scheduled import | **`contactdetails_tbl`** `:55`; items VIEW `:99+` | `sched/import-contacts.cfm` |
| Role update form | VIEW via `INScontactdetails_24294` (`ContactService.cfc:1261`, INSERT `:1266`) | `include/roleupdateform2.cfm:201` → `add_287_20.cfm:3` |
| Setup pgload | `create()` via `INScontactdetails_24000` wrapper (`:1061`) | `include/pgload_setup.cfm:50` → `InsertContact_188_3.cfm:3` |
| Orphans (no live caller found) | `INScontactdetails_24537` (`:1494`, VIEW `:1499`; qry `add_367_4.cfm` uncalled); `INScontactdetails_24399` (`:1325`, **_tbl** `:1347,:1370`, contactsimport-era) | repo-wide grep |

### 3j. Security summary for the P2 enforcement matrix

The exposure concentrates in the **`/include/remote*.cfm` legacy editors** (rows 1-5): no login
gate, conditional CSRF, and service writes keyed on `itemid`/`contactid` with **no userid
predicate**. The `/ajax/*` surfaces (master, wizard, imports, myteam) already carry session auth +
CSRF + ownership. Section 2c's conditional-UPDATE shape (contactID + userid +
`master_co_contact_id IS NULL`) is currently satisfied by **zero** user-facing write paths.
Reference conforming pattern in-repo: `ajax/myteam/add.cfm:21-26` (ownership pre-check) and
`MasterDirectoryService` in-SQL ownership.

---

## 4. P1b CREATE-PATH STATUS + WO1-RECON §3 RECONCILIATION

### 4a. ContactService.create() — actual INSERT, read this session

`services/ContactService.cfc:9-68`. Whitelist-driven dynamic insert; executes at `:56-64`:
`INSERT INTO contactdetails (#arrayToList(columns)#) VALUES (...)` — **target = the `contactdetails`
VIEW** (unqualified name, no `_tbl`).

**Full allowedFields column list (`:21-39`):** userid, contactFullName, contacttitle, recordname,
contactNickname, contactBirthday, contactMeetingDate, contactMeetingLoc, contactPronoun,
refer_contact_id, contactStatus, contactphoto, user_yn, newsletter_yn, googlealert_yn,
socialmedia_yn, isdeleted.

**contactPhone, contactEmail, contactCompany are NOT in the whitelist** — `create()` cannot write a
primary even if passed one. (Hazard note: `recordname` IS whitelisted at `:25` but is VIRTUAL
GENERATED — any caller passing it gets a hard MySQL error; current callers do not pass it. Matches
the registered WO-G item.)

### 4b. Registered "view-insert silent-failure" defect — adjudicated

The insert-via-VIEW is **CONFIRMED as real** (create() `:57`, plus V3 `:1557` and the §3i inline
creators) but the **silent-failure characterization is REFUTED on the current schema**: the dev
`contactdetails` view is a 1:1 single-table updatable view (`is_updatable=YES`, live probe §2;
DDL `database/migrations/V3_8__master_directory_wo1_contactdetails_view.sql:79-126`), so view
inserts land in `contactdetails_tbl`. Corroboration: wizard-created contacts are real rows the
setup test harness must purge (`docs/TAO-SETUP-TEST-HARNESS-01-recon.md:89-104`). The defect class
of record is **house-rule violation + fragility** (a non-updatable future redefinition converts
these to hard errors; `WO0-PROOF-BUNDLE.md:143-145` "three different write targets" conflict C2) —
not present-day data loss. Per-wizard-step view/_tbl disposition is in §3e: steps 2/3/4 insert the
contact through the VIEW; step 1 writes _tbl; items go to _tbl in steps 1-3 and the VIEW in step 4.

### 4c. WO1-RECON §3 "no primary writers" — RESOLVED: WO1-RECON stands (CONFIRMED)

`DIR-LNK-WO1-RECON.md:64` claims: sole primary-column writer = `ContactService.update()`
(`:223-256`), driven by MasterDirectoryService; contactPhone/contactEmail + `_src` never written.
Live verification this session:

- `create()` cannot write p/e/c (whitelist, §4a) — creators are NOT primary writers. No conflict.
- `update()` remains the only writer of contactCompany/_src + pointers (now `:221-256`; company
  `:238-246`) and its only drivers for those keys are `MDS:188-218` (link) and `MDS:293-304`
  (unlink). remoteUpdateNameUpdate reaches `update()` but passes only name/meeting/pronoun/
  referral/isdeleted keys.
- Full-repo grep: zero writers of contactPhone/contactEmail/_src anywhere.
- Non-primary contactdetails_tbl writers found that WO1-RECON's §3A did not enumerate (merge
  `applyMergedFields` `ContactDuplicateService.cfc:1139`, wizard step1 `:95`, scheduled import
  `:55`, add-form `_24048` `:1083`) — none touch p/e/c columns or pointers.

**No 435/436-class evidence refinement is required** — the WO1-RECON claim was scoped to primary
columns and pointers and is accurate. Recorded refinement (minor, non-contradicting): line drift
(`:223-256` → `:221-256`) and the §3i creator inventory above extend, not correct, the WO-1 record.

### 4d. D-22 consequence stated plainly (accepted-by-progression, lock §2f)

Since the WO-5 dev read cutover, list/share surfaces read p/e/c from **columns**, but every create
and edit path still writes p/e/c to **items** (§3). Net: contacts created or item-edited today in
dev show blank/stale primaries on contacts_ss/sharez surfaces until WO-6's write paths land. This
is the registered D-22 gap this WO closes; not a new finding, restated for P2 sizing.

---

## 5. P1c CLASS-B FINAL LIST (reframe blocks + primary-block insertion point + UI-1/2/3)

Container chain: `/app/contact/` (page-registry include) → `include/contact_info.cfm` →
`contact_pane.cfm` at `contact_info.cfm:996` (pgid 117 pane) and `:1133` (Contact tab);
`include/contact_view.cfm:244` also includes `contact_pane.cfm` (legacy/alternate view — carry as
Class-B candidate).

### 5a. contact_pane.cfm — per-item loops (the "Additional info" reframe body)

- Company block `:67-83` — `#valueCompany#` `:69`, edit pencil `:70-72` (modal
  `remoteUpdateC#itemid#`), valueTitle `:74-76`, valueDepartment `:78-80`.
- Phone block `:103-113` — formatted `valuetext` `:105-108`, pencil `:109-111`.
- Email block `:115-122` — `valuetext` `:117`, pencil `:118-120`.
- Remaining item categories (address `:26-64`, date `:86-94`, long `:97-100`, social/URL `:123+`,
  generic text `:146`) stay as-is under the reframe.
- **Defect noted in passing:** stray dead debug `<cfif ... is "company">Company!<CFABORT></CFIF>`
  at `contact_pane.cfm:33` inside the address branch (unreachable; catfieldset cannot be both).
  Candidate cleanup if P2 rules it inside the touched block.

### 5b. contact_info.cfm — company display + the primary/link block (the insertion point)

- Company loop `:686-688` (`findcompany` query → `#valueCompany#` centered div) — renders nothing
  when no company item exists (**UI-3 blank-company placeholder target**).
- DIR-WO-2 master-link block `:690-722`: ownership-scoped read `qMasterLink :691-700` (reads
  primary contactCompany + `_src` + pointers from the view); linked badge `:705-713` ("Linked to
  directory", person/company names, **last-sync line `:710-712` = UI-2 target**, Unlink button
  `:713`); unlinked control `:715-721` — "Link to directory" `btn-link btn-sm p-0`
  font-size 0.75rem `:716` (**UI-1 trigger size/affordance target**) + search box `:717-720`.
- **Primary fields block insertion point:** this `:686-722` region — replace/augment the
  item-derived company loop with the editable-vs-read-only primary p/e/c block per spec §13.1/13.2,
  badge reuse from the DIR-WO-2 shell already in place at `:705`.
- Item-derived read surfaces adjacent (P2 line-verify, per WO5-P1-DELTA): `emailcheck` include
  `:159` (→ `SELcontactitems_24657`), toolbar email `:589-601` / phone `:603-619`, later
  `emailcheck` uses `:501-502`, `:1378`; same-file `remoteUpdateName` edit trigger `:752`.
- UI-1/2/3 confirmed confined to the `:686-722` block (fold-in eligible per lock §6).

### 5c. P1-delta candidates carried

`include/contact_view.cfm` (`:124` emailcheck; `:244` pane include) — same class; verify usage
during P2 (it may be dead or share-side). `share/` surfaces post-WO-5 read columns via views —
no Class-B blocks there.

---

## 6. P1d EDIT-LOGGING STATUS (feeds P2e ruling — no hand-wave)

- Mechanism: `services/UpdateLogService.cfc` — `INSupdatelog` (`:2-28`) INSERTs into `updatelog`
  (a VIEW over `updatelog_tbl`); `RESupdatelog` (`:29-64`) is the per-user history read.
- The ONLY invokers of `INSupdatelog` are `include/qry/INSERT_266_3.cfm:3`, included by the generic
  RPG update engines: `include/UpdateFormUpdate.cfm:123` and `include/remoteUpdateFormUpdate.cfm:125`
  (each logs only when `oldvalue neq newvalue`, `UpdateFormUpdate.cfm:116`). The literal
  `INSERT INTO updatelog` text at `UpdateFormUpdate.cfm:126-135` is inside `<cfoutput>` — debug
  echo, not an executed query. No other `INSERT INTO updatelog` / `updatelog_tbl` exists in the repo.
- What is actually captured today: only edits flowing through the RPG form engines (module list
  pages via `include/results.cfm:71`, `share/remoteUpdateForm.cfm:49`).
- What is NOT captured: **contact item edits** (`remoteUpdateCUpdate.cfm` path — no logging call),
  **contact detail edits** (`remoteUpdateNameUpdate.cfm` → `update()` — no logging call), master
  link/unlink column writes (by design: master_audit_tbl covers lifecycle), imports, merge.
- **Plain statement for P2e: primary-COLUMN edits would NOT be captured today.** There is no
  primary-edit surface at all yet, and the writer it would use (`ContactService.update()` or a new
  WO-6 method) has no logging hook. Extension cost is small and known: an explicit
  `INSupdatelog(...)` call in the new write path (service exists, signature at
  `UpdateLogService.cfc:2-11`; needs oldvalue read inside the same guarded write, plus a
  compid/recordname convention decision). Alternative (ii) accept-unlogged is equally clean
  mechanically. Decision is the operator's at P2e per amendment A-6.

---

## 7. P1e MERGE TRACE (read-only; live code `services/ContactDuplicateService.cfc`)

Entry: `/app/contact-duplicates/index.cfm:24-49` (app layer: login gate, CSRF via
`/app/Application.cfc`, PRG redirect `:48`; userid = session `:14`).

`mergeContacts` (`:439-1102`), single `<cftransaction>` `:545-1083`:

- Guards: self-merge `:471-474`; discard-is-user-record block `:479-487`; both-exist + owned +
  active guard `:491-501` (userid + isdeleted predicates — conforming ownership).
- Items: colliding discard items (same valueCategory + valuetext, case/trim-insensitive)
  soft-deleted `:577-589`; remainder **repointed to keep** `:600-605` — both against
  `contactitems_tbl`. Note: Company items compare on `valuetext` — company values living in
  `valueCompany` never collide, so discard company items always repoint (duplicate company panes
  possible post-merge; PD-1/PC-1 material for Q1c).
- contactdetails writes: `applyMergedFields` `:1106-1159` — UPDATE **`contactdetails_tbl`**
  (`:1139`), whitelist `:1111-1123` = name/title/nickname/pronoun/meeting/newsletter flags/
  birthday/refer only. **Excludes p/e/c, `_src`, and every master pointer.** Referral repoints
  `:933-939`, `:1048-1053`; avatar carry `:999-1004`; discard soft-delete `:1066-1071`
  (`SET isdeleted = 1`, userid-scoped).
- **The merge never reads or writes `master_co_contact_id` / `master_coid` /
  `company_location_id` / `_src` — zero occurrences in the file. It is link-blind.**

### Risk statement for Q1 (spec silent, §1f)

- **Q1a (discard is linked):** the link is silently buried — `master_co_contact_id` stays set on
  the soft-deleted discard row; nothing transfers to keep; no master_audit_tbl row; the only trace
  is `contact_merge_map` action `softdeleted` (`:1057-1065`). Master-sourced Company items created
  by `MDS` on the discard repoint onto keep as ordinary items (spec §2 rule 4 tension: master
  values persisting in contactitems on a contact that is NOT linked). Backfill/WO-12 counts keyed
  on `master_co_contact_id IS NOT NULL` without an isdeleted predicate would count buried links.
- **Q1b (both linked, different masters):** merge proceeds blind — keep retains its own link;
  discard's differing master link + snapshot buried as above; keep additionally inherits the
  discard's master-shaped Company item. No block exists today. Architect lean (lock §6): BLOCK —
  implementable as one guard in the `:489-501` pre-flight region reading both
  `master_co_contact_id` values, zero writes on reject (matches Section 2c reject shape).
- **Q1c/PD-1 context:** value-union today = item repoint with valuetext-collision dedupe only;
  primaries are untouched by merge in either direction (consistent with keep-linked "untouchable"
  lean, but only by accident of the whitelist, not by guard).

---

## 8. INPUTS TO P2 (register, no rulings here)

1. Enforcement matrix rows come from §3b-3i; the Section 2c conditional-UPDATE shape exists nowhere
   today — every user path needs it added; `/include/remote*` rows also fail auth/CSRF
   preconditions (P2 must state whether WO-6 hardens the touched endpoints or routes primaries to
   a new conforming `/ajax/` endpoint and leaves item-editor hardening to its own WO).
2. Create-path design (P2b): add-form writes contact to _tbl already (`_24048`); wizard/import
   creators use the view via `create()`. Fixing vs routing-around for the p/e/c columns: `create()`
   whitelist extension (+ p/e/c + `_src`) vs a separate primary-write method — size in P2.
3. Import/merge primary adoption counts (P2d): both importers are items-only writers today (§3f);
   merge untouched-by-design (§7).
4. P2e logging choice per §6; Q1 rulings per §7 + §1f (spec silences confirmed).
5. Oversize widths for P5d negative tests confirmed: 100/150/255 (§2).

---

**P1 COMPLETE — read-only throughout (code + SELECT/SHOW probes). STOP for architect review.**
