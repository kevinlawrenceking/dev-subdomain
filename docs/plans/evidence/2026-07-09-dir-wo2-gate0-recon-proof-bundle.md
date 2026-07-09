# DIR-WO-2 — GATE 0 Recon / Pre-Flight Proof Bundle

**Binding (verified this session):** project TAO-MCD-P1 · repo `kevinlawrenceking/dev-subdomain`
(`git remote -v` → `origin https://github.com/kevinlawrenceking/dev-subdomain.git`) ·
root `C:/Users/kevin/TAO/dev-subdomain` (`git rev-parse --show-toplevel`) · branch `dev`
(`git branch --show-current`). All four match the WO BINDING header — PROCEED (NN#10).
**Date:** 2026-07-09 · **Author:** CC · **Mode:** GATE 0 read-only. Zero code changes, zero DDL,
zero DML. Two evidence files created this session (this bundle + the operator SQL packet); nothing
committed.

**Execution channel (revised mid-session):** no `mysql` CLI exists on this workstation and no
MySQL MCP is configured; every prior DB proof was operator-run (HeidiSQL), matching
`2026-07-08-prod-promotion-runbook.md:14` ("CC cannot execute any of this"). Mid-recon, at Kevin's
prompt, a **read-only channel was established**: system Python + `pymysql` 2.2.8, connecting as the
app account `kingk436@%` to `www.theactorsoffice.com:3306` (host/user from Kevin's own HeidiSQL
saved session; credential decoded locally from his registry, used in-memory only, never displayed
or persisted). Probe script: scratchpad `gate0_readonly_probe.py` — statements whitelisted to
SELECT / SHOW / USE only. **Every DB check below is therefore LIVE-VERIFIED 2026-07-09** (raw
output: `docs/plans/evidence/2026-07-09-dir-wo2-gate0-live-probe-output.txt`; connection proof:
`CURRENT_USER()=kingk436@%`, `VERSION()=8.0.41`). The operator packet
(`2026-07-09-dir-wo2-gate0-operator-sql-packet.sql`) is retained for independent re-runs. Prod
constraint honored: on `actorsbusinessoffice` only information_schema + SHOW statements ran — the
one casualty is G0-2c's prod row-count (a plain SELECT COUNT on a prod table), skipped as a
WO-internal conflict (OQ-6). No phpMyAdmin anywhere.

---

## G0-1 — WO number claim

No canonical numbered **DIR WO register file** exists. `docs/plans/master-contact-directory-phase1.md`
§11 lists an unnumbered WO-1…WO-8 breakdown only. Grep for `DIR-WO` across `docs/`:

```
docs\plans\evidence\2026-07-06-wo0b-decision-memo-corrected.md:64:## Plan deviations (registered — DIR-WO-1 revision R2)
docs\plans\evidence\2026-07-07-dir-wo1-six-file-manifest.md:1:# DIR-WO-1 — Six-File Paste Manifest (for the architect verdict)
docs\plans\evidence\2026-07-06-wo1-execution-runbook.md:5:DIR-WO-1 pack **ACCEPTED WITH RULINGS + R1–R3** (2026-07-06).
docs\plans\evidence\2026-07-07-wo0b-addendum-B-drift.md:6:**Status:** EVIDENCE. Resolves the DIR-WO-1 ruling-2 STOP-on-delta gate ...
```

Only **DIR-WO-1** is ever assigned. The master-link UI recon
(`docs/plans/evidence/2026-07-08-master-link-ui-workorder.md:1`) is titled "WO-2, draft" —
informal, same workstream as this WO. **DIR-WO-2 is unassigned → CLAIMED for this workstream
(master-link UI).** Defect D-8 registered: no register file exists; Plan Lock should create one
(read-only mode bars creating it now).

## G0-2 — Migration state audit

### (a)(b)(c) Live checks → operator packet Blocks 1–3. Documentary state:

- **12 columns (11 in-scope + `contactPhoto_src`)** — all added by V3_7 (single 12-col set; see
  file text under G0-3). Dev: `new_cols_present_expect_12` = **12**
  (`2026-07-07-wo1-dev-apply-v3_7-v3_8.md:12`). Prod: **12** (`2026-07-08-wo1-PROD-apply-schema-proof.md:9`).
  `contactPhoto_src` is present in both schemas (out of scope for this WO — reported for the record).
- **View** — dev: `security_type=INVOKER`, `is_updatable=YES`, 44 cols
  (`2026-07-07-wo1-dev-apply-v3_7-v3_8.md:18-19`). Prod: INVOKER, updatable, 44 cols; pre-rebuild
  live view captured at 32 cols DEFINER `kingk436@%` `WHERE IsDeleted=0`
  (`2026-07-08-wo1-PROD-apply-schema-proof.md:15-19`).
- **Backfill counts** — dev `contactCompany` non-null = **435** (phone 276 / email 292, equal to the
  active-eligible ceiling; `2026-07-07-wo1-backfill-partA-dev-proof.md:9-13`). Prod: V3_10 **not
  applied** → expected 0; prod proof confirms "All pointer columns NULL (no linkage backfill yet)"
  (`2026-07-08-wo1-PROD-apply-schema-proof.md:34`).

### (d) Applied-state matrix (documentary; SQL evidence cited per cell; live re-verify = packet Blocks 1–3)

| Migration | abod (`new_development`) | abo (`actorsbusinessoffice`) |
|---|---|---|
| **V3_7** cols/idx/photo | **APPLIED** 2026-07-07 — cols 12/12, idx 3/3, photo varchar(500) (`2026-07-07-wo1-dev-apply-v3_7-v3_8.md:11-14`; commit a40cfb9a) | **APPLIED** 2026-07-08 — cols 12/12, idx 3/3, photo 500 (`2026-07-08-wo1-PROD-apply-schema-proof.md:7-12`) |
| **V3_8** view rebuild | **APPLIED** 2026-07-07 — INVOKER, 44 cols, smoke row 132418 (`…v3_7-v3_8.md:16-21`) | **APPLIED** 2026-07-08 — INVOKER, 44 cols, smoke row 154962; STOP-on-delta cleared (`…PROD…md:14-19`) |
| **V3_9** 3 FKs | **APPLIED** 2026-07-07 — orphan pre-flight all 0; 3 FKs SET NULL/RESTRICT (`2026-07-07-wo1-dev-apply-v3_9-fk.md:8-16`; commit d22b67c4) | **APPLIED** 2026-07-08 — 3 FKs SET NULL/RESTRICT; ERROR-1072 false-start corrected, no partial state (`…PROD…md:21-31`) |
| **V3_10 Part A** hot-field backfill | **APPLIED** 2026-07-07 — 276/292/435 == active-eligible ceiling (`2026-07-07-wo1-backfill-partA-dev-proof.md`; commit f499359c) | **NOT APPLIED** — pending decision D-a (`2026-07-08-prod-promotion-runbook.md:21-25`; `…PROD…md:36`) |
| **Part B** master linkage | **N/A — no migration file exists.** Abandoned on evidence (imdbid key dead, prod 0 nm-format); V3_11 dropped before commit (commits 12c6c4a6, 189700e8; `2026-07-07-wo1-backfill-partB-outcome.md`). Replaced by preview-gated `2026-07-08-wo1-linkage-384-preview.sql` (SELECT-only) + this UI workstream | **N/A** — same; ~380 tier-1 linkage pending preview + D-b |

### (e) Doc-conflict resolution

The WO premise — "the recon doc treats the V3_10 backfill as done while the register says V3_7/8/9
are unapplied on dev" — resolves as **both docs are point-in-time artifacts on one timeline; the
dated apply-proofs supersede**:

- The "unapplied" claims live in pre-execution artifacts: `2026-07-06-wo1-execution-runbook.md:6-7`
  ("Nothing here has been executed… HOLD AT THE GATE") and
  `2026-07-07-dir-wo1-six-file-manifest.md:29-31` (flag 2, "Dev exec is gated"). Both were staged
  **before** the applies.
- Execution then happened, each step with its own dated proof + commit: dev V3_7+V3_8 2026-07-07
  (a40cfb9a) → dev V3_10 Part A (f499359c) → dev V3_9 (d22b67c4, "migration chain COMPLETE on dev")
  → prod V3_7/8/9 2026-07-08 (proof doc, executor Kevin, authorized 2026-07-08).
- The recon doc's "Part A was a one-time backfill" (`2026-07-08-master-link-ui-workorder.md:46`) is
  therefore **correct** (for dev).

**Neither doc is factually wrong for its date; the runbook/manifest are stale-if-read-as-current
and carry no superseded-by pointer → Defect D-3.** Corollary: this GATE-0 WO's own G0-3 HOLD
("applying V3_7/8/9 to abod is blocked") is moot — they were applied to abod 2026-07-07 under the
architect-accepted DIR-WO-1 pack, and to abo 2026-07-08 under named authorization. Fresh live
confirmation = packet Blocks 1–3.

## G0-3 — Six-file pack retrieval (NOT applied; retrieval only)

### (a) `git show a7e1c05e --stat` (raw, trimmed to the migration rows)

```
commit a7e1c05eeed4009185c3925d91b2177147cb25c7
Author: Kevin King <39280670+kevinlawrenceking@users.noreply.github.com>
Date:   Mon Jul 6 10:54:41 2026 -0700

 ...master_directory_wo1_contactdetails_columns.sql | 162 ++++++++++++++++++++
 ...rectory_wo1_contactdetails_columns_ROLLBACK.sql |  98 ++++++++++++
 ...8__master_directory_wo1_contactdetails_view.sql | 149 ++++++++++++++++++
 ..._directory_wo1_contactdetails_view_ROLLBACK.sql |  73 +++++++++
 ...3_9__master_directory_wo1_contactdetails_fk.sql |  86 +++++++++++
 ...er_directory_wo1_contactdetails_fk_ROLLBACK.sql |  38 +++++
 (+ 9 evidence/docs files; 15 files, 1302 insertions)
```

### (b) Verbatim contents

All six retrieved via `git show a7e1c05e:<path>` in this session and reproduced **in full** in the
companion capture `docs/plans/evidence/2026-07-09-dir-wo2-gate0-sixfile-verbatim.txt` (exact bytes,
one `===== <path> =====` header per file). Integrity notes established here:

- **Five of six files are byte-identical** at a7e1c05e, HEAD, and working tree
  (`git diff a7e1c05e HEAD -- <file>` empty; `git diff HEAD` empty).
- **V3_8 forward differs a7e1c05e → HEAD** — one commit, `c8c7e6ad chore(V3_8): lift DRAFT -
  contactdetails view reconcile PASS (32 cols, dev+prod)`. The delta is **comment-block only**: the
  "DRAFT UNTIL RECONCILED — STOP-ON-DELTA" header is replaced by "RECONCILED 2026-07-07 —
  STOP-ON-DELTA CLEARED" (the 33-col note was a miscount; both live views enumerate exactly 32
  cols). **No executable SQL changed.** Working tree == HEAD. The architect line review should read
  the **HEAD** version (`database/migrations/V3_8__master_directory_wo1_contactdetails_view.sql`),
  which is what was actually applied.

### (c) Exact mysql CLI sequences (LISTED ONLY — NOT RUN; HOLD acknowledged)

Forward (abod), per `2026-07-06-wo1-execution-runbook.md` order (V3_7 → reconcile → V3_8 same
window; V3_9 only after orphan pre-flight):

```
mysql -u kingk436 -p -h <db-host> new_development -e "SHOW CREATE TABLE contactdetails_tbl\G"   # archive pre-state
mysql -u kingk436 -p -h <db-host> new_development -e "SHOW CREATE VIEW contactdetails\G"        # STOP-on-delta reconcile
mysql -u kingk436 -p -h <db-host> new_development < database/migrations/V3_7__master_directory_wo1_contactdetails_columns.sql
mysql -u kingk436 -p -h <db-host> new_development < database/migrations/V3_8__master_directory_wo1_contactdetails_view.sql
#   (run the four orphan/sentinel pre-flight SELECTs from the V3_9 header — all must return 0)
mysql -u kingk436 -p -h <db-host> new_development < database/migrations/V3_9__master_directory_wo1_contactdetails_fk.sql
```

Rollback (reverse order — V3_9 FKs pin the columns; V3_8 must precede V3_7 so the live view never
references dropped columns):

```
mysql -u kingk436 -p -h <db-host> new_development < database/migrations/V3_9__master_directory_wo1_contactdetails_fk_ROLLBACK.sql
mysql -u kingk436 -p -h <db-host> new_development < database/migrations/V3_8__master_directory_wo1_contactdetails_view_ROLLBACK.sql
mysql -u kingk436 -p -h <db-host> new_development < database/migrations/V3_7__master_directory_wo1_contactdetails_columns_ROLLBACK.sql
```

**A rollback file exists for every forward file: 3/3.** All six are idempotent (information_schema
guards). Note the V3_7 rollback's contactPhoto-narrow safety trap (refuses while any value >255).
Documentary state: this sequence was already executed on abod (2026-07-07) and abo (2026-07-08) —
see G0-2(d)/(e).

## G0-4 — Seed verification (dev master tables)

Documentary **APPLIED**: commit `3f7f2425 docs: D-B resolved - dev co_contacts/co_locations seeded
from prod (25200/12617)`; `2026-07-07-wo1-dev-apply-v3_7-v3_8.md:5` lists "dev master tables seeded
(D-B closed)" as a met prereq. Per the seed script header
(`2026-07-07-seed-dev-master-tables.sql:2-4`): dev was 0/0 pre-seed; **co_contacts 25,200 ·
co_locations 12,617 · companies 10,740** (already matching, not copied). Live counts + 3-row
samples = operator packet Block 4.

## G0-5 — co_locations key + cardinality

Documentary (prod capture, `2026-07-04-wo0b-prod-Q8-Q15-master.txt:23-42,69,91-92`; dev is a
verbatim row copy of these tables):

- **PK = `colocid`** int auto_increment (NOT `locid` as plan §4.1 assumed — already corrected).
- **Join key to companies = `coid`** int, indexed (MUL). Indexes: `PRIMARY(colocid)`, `coid`.
- **No primary-office flag.** Offices-per-company (companies present in co_locations): min=1
  avg=1.27 max=46. Default-office rule needed; tie-break e.g. MIN(colocid).
- Watch-item: column `current_time` varchar(500) — near-reserved name; must be backtick-quoted.
- Companies with **0** locations were never measured (Q15 aggregated only over companies having
  rows). 0/1/>1 distribution = operator packet Block 5. `SHOW CREATE TABLE` live = same block.

## G0-6 — Reader surfaces + canonical Company item shape (PD-L2 evidence)

### (a) Readers of the snapshot columns: **ZERO live app readers — proven**

Repo-wide greps over `*.cfm`, `*.cfc`, `*.js` for `contactCompany|contactPhone|contactEmail`
(+ `_src` variants, pointers, sync dates) → **no matches**. Every hit is in `database/` DDL
(V3_7/V3_8/V3_9/V3_10 + rollbacks — writers/guards, not readers) or docs/evidence. Nearby caveat:
legacy `cdco` (old company field) still referenced at `include/qry/Insert_159_13.cfm:5` — not a
WO-1 column.

### (b) Company display surfaces

In-repo view DDL:
- `contacts_ss` — **DDL absent from repo entirely** (`17-contact-data-model.md:476`: "Actual SQL
  CREATE VIEW not found"). Live capture required → packet Block 6.
- `contacts_ss_target/_followup/_maint` — `database/rebuild_contacts_ss_system_views.sql:18-55`
  (`SELECT DISTINCT cs.* FROM contacts_ss` joined to fusystemusers/fusystems per systemtype). Full
  live-form target DDL at `database/2026-06-18_fix_view_xschema_contacts_ss_target.sql:30` — Company
  is `col5`: correlated subquery on `contactitems.valueCompany WHERE valueCategory='Company' AND
  itemStatus='active' ORDER BY primary_YN DESC LIMIT 1` (col3=Phone/col4=Email same pattern).
  DEFINER `kingk436@%`, SQL SECURITY DEFINER.
- `sharez` — `database/rebuild_sharez_view.sql:31-93`; Company via `LEFT JOIN contactitems_tbl
  ci_company … valueCategory='Company' AND itemStatus='active' AND IsDeleted<>1`, selected
  `ci_company.valueCompany AS Company` (`:35,70-73`).
- `sharezz` — **distinct view**; created by the misleadingly-named
  `database/rebuild_sharez_simple.sql:14-88`; Company as scalar subquery (`:27-33`).

CFM surfaces: `include/contacts_table.cfm:10,20` (`<th>Company</th>`) + `:181` (`targets: 3, //
Company` — serverSide DataTable fed by SS-view col5); `include/contact_pane.cfm:33,66-69`
(`#valueCompany#` when `catfieldset is "company"`); `include/contact_info.cfm:163` (include
`qry/findcompany_476_1.cfm`) + `:686-688` (`<cfloop query="findcompany"><div
class="text-center">#valueCompany#</div>`). **Every surface reads `valueCompany`/col5 from
contactitems; none reads the `contactCompany` snapshot column** — consistent with (a).

### (c) Canonical Company-item write paths + insert column set

Form handlers `include/remoteaddC.cfm` / `include/remoteUpdateC.cfm` render the modal (catid 9)
and POST to `/include/remoteAddCAdd.cfm` / `/include/remoteUpdateCUpdate.cfm`; qry fragments
marshal into `ContactItemService`.

INSERT paths — identical qry fragments `include/qry/insert_367_6.cfm`, `insert_367_3.cfm`,
`insert_28_6.cfm` (lines 3-19) and service `ContactItemService.INScontactitems_23771` (`:262-293`,
the canonical add-company path with FIX-#1617 dedupe pre-check `:267-274`):

```
INSERT INTO contactitems_tbl (CONTACTID, VALUETYPE, VALUECATEGORY, ValueCompany, ITEMSTATUS)
VALUES (<contactid int>, 'Company', 'Company', <company varchar>, 'Active')
```

Siblings with the same shape: `INScontactitems_24057` (`:911-927`), `_24058` (`:928-944`),
`_24420` (`:1327-1343`). UPDATE paths: `UPDcontactitems_24046` (`:802-842`) and `_24178`
(`:985-1055`) conditionally set `valueCompany`/`valueDepartment`/`valueTitle`; soft delete via
`isdeleted=1`.

**Canonical insert column set (PD-L2 input):**
- Columns: `CONTACTID, VALUETYPE, VALUECATEGORY, ValueCompany, ITEMSTATUS`
- Values: contactid · `valueType='Company'` · `valueCategory='Company'` · name → `ValueCompany`
  (NOT valuetext) · `itemStatus='Active'`
- `primary_yn`: **never set** by any Company insert (DB default; only "My Team" tag inserts set
  `'Y'`). **No primary-collision/demotion handling exists anywhere** (reads assume
  `ORDER BY primary_YN DESC LIMIT 1`) → Defect D-6.
- `userid`: **contactitems has no userid column** — ownership derives via
  contactid → contactdetails.userID.
- `isdeleted`: not set on insert (DB default); deletes are soft updates.
- Dedupe: only `INScontactitems_23771:267-274` (contactid + valuecategory + valuecompany + Active).
- Anomaly: `INScontactitems_24052` (`:894-910`) writes the company name into **VALUETEXT** —
  invisible to every Company reader → Defect D-5.

### (d) Provenance on contactitems: **NONE**

Full documented column list (`17-contact-data-model.md:110-132`, corroborated by the widest code
enumeration `SELcontactitems_24313:1090`): itemid, contactid, valueType, valueCategory, valuetext,
valueCompany, valueDepartment, valueTitle, valueStreetAddress, valueExtendedAddress, valueCity,
valueRegion, valueCountry, valuePostalCode, itemDate, itemNotes, itemStatus, primary_yn,
itemCreationDate, itemLastUpdated, isDeleted. No src/source/origin column; repo-wide grep for
contactitems ∧ provenance-ish names → empty. Live confirm = packet Block 7. **Feeds the Plan Lock
unlink-item question: a PD-L2-upserted Company row cannot be identified as master-sourced by any
column that exists today.**

## G0-7 — Recon conflict resolution

### (a) `include/CompanyLookup.cfc` — **EXISTS on disk**

Two files: `include/CompanyLookup.cfc` (remote CFC) and `include/companylookup.cfm` (standalone
demo page containing the only real `#companySearch`/`#results` elements, lines 14-15). First 20
lines of the CFC (verbatim):

```cfml
<cfcomponent>

        <cffunction name="getCompanies" access="remote" returntype="query" output="false" returnformat="json">
        <cfargument name="searchTerm" type="string" required="true">
        <cfargument name="dsn" type="string" required="true">
<cfargument name="userid" type="integer" required="true">
        <cfquery name="queryCompanies" datasource="#dsn#">
           SELECT DISTINCT i.valuecompany FROM contactitems i
INNER JOIN contactdetails d ON d.contactid = i.contactid
WHERE i.valuecompany IS NOT NULL
AND i.valuecompany <> ''
AND i.valuecategory = 'Company'
AND d.contactstatus = 'Active'
AND i.valuecompany LIKE <cfqueryparam value="#arguments.searchTerm#%" cfsqltype="cf_sql_varchar">
AND d.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer">
ORDER BY i.valuecompany
 LIMIT 10
        </cfquery>

        <cfreturn queryCompanies>
```

All code references: `include/remoteAddName.cfm:185`, `app/assets/js/lookup.cfm:41`,
`share/assets/lookup.cfm:41`, `include/companylookup.cfm:25`. **Reconciliation: whichever prior
recon pass reported the file absent was wrong** (the 2026-07-08 recon doc correctly cites it, but
mislabels the wiring "the model to copy" when the binding is inert — see G0-12/D-2). Registered as
recon defect D-2. Note the CFC passes `dsn`/`userid` as remote args — the pattern the new endpoints
must NOT copy.

### (b) contact_info.cfm anchors + remoteUpdateName chain

- **Company block render:** `include/contact_info.cfm:686-688` — read-only loop
  `<cfloop query="findcompany"><cfoutput><div class="text-center">#valueCompany#</div>` (query
  included at `:163` → `qry/findcompany_476_1.cfm`). This is the natural anchor for the link
  control/badge.
- **JS handler locations:** script blocks at lines 189–196, 215–222, 242–254, 299–306, 329–338,
  355–362, 378–385, 406–413, 430–437, 572–580, and the trailing cluster 1127–1203. Caveat: the
  `$("#valueCompany").on("change", …)` handler at `:1155` targets a select that exists only inside
  the separately-loaded `remoteaddC/remoteUpdateC` modals, not this page's initial DOM (Defect D-7).
- **remoteUpdateName chain — confirmed NO changes needed:** `contact_info.cfm:430-437` loads
  `include/remoteUpdateName.cfm` (form → `/include/remoteUpdateNameUpdate.cfm:24` →
  `include/qry/updatecontact_270_1.cfm:2-13` → `ContactService.UPDcontactdetails_24202`
  (`services/ContactService.cfc:1118-1162`) → `update()` (`:114-211`)). Form fields are exclusively
  name/birthday/meeting/pronoun/refer/custom/deleteitem; the chain never reads or writes company,
  phone, or email (those live in contactitems via the separate C-modals). Anchors verified.

## G0-8 — /ajax framework resolution

`ajax/Application.cfc` dsn resolution (verbatim):

```
4    host = ListFirst(cgi.server_name, ".");
5    if (host == "app") {        envLabel = "PROD"; _dsn = "abo";
7    } else if (host == "uat") { envLabel = "UAT";  _dsn = "abod";
9    } else {                    envLabel = "DEV";  _dsn = "abod"; }
14   this.name = "TAO_" & envLabel;
16   application.dsn = _dsn;
32   this.datasource = application.dsn;
33   application.datasource = this.datasource;
```

Re-forced per-request in `onRequestStart` (`:40-45`), exposed as `request.dsn` (`:66`). The mapping
is **identical** to `app/Application.cfc:6-11` (`app`→`abo`; `uat`/else→`abod`) with the same
`this.name = "TAO_" & envLabel` — **equivalent to application.dsn semantics per hostname.
Confirmed.** (Delta noted: `app/Application.cfc` also derives `application.information_schema`/
`application.suffix`; ajax does not set these — relies on the shared TAO_* application scope.)

`request.svc` in /ajax (`ajax/Application.cfc:68-75`): request-scoped factory,
`createObject("component","services." & name)` cached in `request.services`; `request.userid` at
`:78`. Auth = session gate `:57-63` (401 JSON); CSRF = `:80-128` (POST/PUT/DELETE;
`X-CSRF-Token` header or `form.csrfToken`; importv3/import-auditions skip-list).
Precedent `ajax/contacts/check-duplicate.cfm:43-44`: `request.svc("DuplicateMatcherService")`,
passes `userid=session.userid`, never touches dsn in the endpoint; header `:11-12` confirms
ambient auth+CSRF. **`request.svc` is available and is the pattern for the new endpoints.**

## G0-9 — P1–P6 overlap check

**The labeled items "P1"–"P6" (and P7) do not exist anywhere on disk.** Word-boundary grep
`\bP[1-7]\b` over all of `docs/` matches only: phonebook proof steps
(`2026-07-03-wo-phonebook-plan.md:181,183`), email-dimension SQL probe labels
(`2026-07-06-email-dimension-recon.md` passim), and priority levels in two unrelated tech specs.
No file in `docs/` contains "P6" or "P7" at all. The V3_9 header's "Addendum-B P1 / Q8" cites a
probe whose pane doc uses `F-*` labels, not P-numbers. → **WO-premise defect D-4; open question
OQ-1 for the architect.**

Overlap analysis against the nearest real constructs, so the intent of G0-9 is still answered:
the only things literally called "pre-flight" in the DIR workstream — V3_9's four orphan/sentinel
queries (`V3_9…fk.sql:21-36`) — are **read-only SELECT COUNTs; none writes any of the 11 in-scope
columns or any contactitems Company row.** The backfill write items (Part A A1–A3 = the three hot
fields, dev-complete; Part B B1–B2 = pointers, abandoned) write snapshot columns only and **no
contactitems rows** — and neither is pending work that could collide with this WO. Photo (analogue
of "P7") is decision D-1/A1 — excluded from this WO.

## G0-10 — Dirt check

`git status --porcelain -- services/ include/contact_info.cfm ajax/` → **empty. Zero uncommitted
changes** on `services/ContactService.cfc`, the whole `services/` tree (no
`MasterDirectoryService.cfc` exists yet — clean target), `include/contact_info.cfm`, and the
`ajax/` tree (**no `ajax/master/` directory exists** — clean namespace; full ajax tree enumerated,
80 files, none master-related). Repo-wide untracked files are exactly the four pre-existing
evidence docs from the 2026-07-08 session (`…master-link-ui-workorder.md`,
`…prod-promotion-runbook.md`, `…wo1-PROD-apply-schema-proof.md`, `…wo1-linkage-384-preview.sql`)
plus the two files this GATE-0 session created (this bundle + operator packet + six-file verbatim
capture).

## G0-11 — co_contacts search-field verification

Documentary (`2026-07-04-wo0b-prod-Q8-Q15-master.txt:5-21,68`): full column list = id(PK), title,
page_url, image_url, name_url, **fullname (MUL)**, suffix, starmeter, jobtitle_type, location
(MUL), coid (MUL, 0-sentinel), imdbid, timestamp, coimdbid, tag, contactid (legacy, unindexed).
**No person-level phone or email column — confirmed.** Indexes: PRIMARY(id) + coid + fullname +
location (all single-col, non-unique). **Total rows: 25,200** (prod Q15 capture 2026-07-04; dev
seeded to the same). FULLTEXT decision input: at 25.2K rows a prefix `LIKE 'term%'` on the existing
`fullname` index is index-served; FULLTEXT is optional, not required. Live re-verify = packet
Block 8. Search-quality caveats from Q15: `jobtitle_type` dirty (leading space/newlines/nested
category), `location` contaminated (phones/names mixed in), blank jobtitle_type = 3,740.

## LIVE VERIFICATION ADDENDUM (2026-07-09, pymysql read-only probe — raw output in `2026-07-09-dir-wo2-gate0-live-probe-output.txt`)

- **G0-2a — VERIFIED both schemas:** all 12 columns present with identical definitions on
  `new_development` AND `actorsbusinessoffice`: `contactCompany varchar(255)`, `contactPhone
  varchar(100)`, `contactEmail varchar(150)`, the four `_src enum('user','master') NOT NULL DEFAULT
  'user'` (incl. `contactPhoto_src`, reported for the record), three `int NULL` pointers, two
  `datetime NULL` sync columns. (probe lines 9–22 dev, 145–158 prod)
- **G0-2b — VERIFIED both schemas:** `SHOW CREATE VIEW contactdetails` = `SQL SECURITY INVOKER`,
  44 columns (32 base + 12 WO-1, exact V3_8 order), `WHERE IsDeleted = 0`, `IS_UPDATABLE=YES`,
  DEFINER `kingk436@%`. Byte-consistent with the V3_8 SELECT. (lines 24–34 dev, 160–170 prod)
- **G0-2c/d — VERIFIED:** dev `contactdetails_tbl`: rows_total **1636**, contactCompany non-null
  **435**, phone **276**, email **292**, pointers **0/0/0** — matches the Part A proof exactly
  (line 66–68). FKs live in BOTH schemas: `fk_cd_company_location→co_locations.colocid`,
  `fk_cd_master_coid→companies.coid`, `fk_cd_master_co_contact→co_contacts.id`, all
  `SET NULL`/`RESTRICT` (lines 36–40, 172–176). Prod contactCompany count skipped per prod
  read-constraint (OQ-6); prod pointer-NULL state rests on the 2026-07-08 proof.
- **Applied-state matrix: every documentary cell CONFIRMED LIVE.** V3_7/V3_8/V3_9 = APPLIED on
  both schemas; V3_10 Part A = APPLIED dev (435/276/292) / NOT APPLIED prod (columns present,
  awaiting D-a); Part B nonexistent.
- **G0-4 — VERIFIED:** dev co_contacts **25,200** · co_locations **12,617** · companies **10,740**.
  Samples: co_contacts (1 Charlotte Thorp / 2 Sam Hanson / 3 Yariv Milchan); co_locations
  (1 Montreal,QC coid 9393 / 2 Los Angeles,CA 9393 / 3 Ottawa,ON 9393); companies (1 0X1 sound /
  2 1 & 0 Entertainment / 3 1 Stooge Entertainment). (lines 70–92)
- **G0-5 — VERIFIED:** live `SHOW CREATE TABLE co_locations` (lines 94–117): PK `colocid` (BTREE,
  AUTO_INCREMENT), single secondary `KEY coid (coid)`, `coid int NULL` = join key to companies,
  **no primary-office flag**, InnoDB utf8mb4_unicode_ci; `current_time varchar(500)` column
  confirmed (quote it). Cardinality: companies with 0 locations = **785**, exactly 1 = **8,295**,
  >1 = **1,660** (of 10,740). Default-office rule required for ~15% multi-office companies.
- **G0-6b — LIVE DDL captured for all six views, both schemas** (lines 42–64 dev, 178–200 prod).
  Company is `valueCompany` everywhere (contacts_ss `col5` correlated subquery `ORDER BY primary_YN
  DESC LIMIT 1`; sharez/sharezz scalar/join reads). **NEW DRIFT EVIDENCE (F17 class, now live-proven
  — Defect D-11):** prod `contacts_ss_target/_followup/_maint` are the OLD inline-subquery
  definitions (target: `d.contactID IN (SELECT … systemID IN (5,6))` with **no userid join and no
  suStatus filter**), while dev has the rebuilt `cs.*`-join forms with `su.suStatus='Active'`; prod
  `sharez` is a join-based definition (maxaudition) entirely different from dev's scalar-subquery
  form. Not WO-1 columns — but any read-path work must not assume dev==prod for these views.
- **G0-6d — VERIFIED:** live dev `contactitems_tbl` column list (line 123–125): 21 columns, **no
  provenance/source column** — matches the doc-derived list.
- **G0-11 — VERIFIED:** dev co_contacts total **25,200**; indexes PRIMARY(id) + fullname +
  location + coid (fullname cardinality 20,961); **zero phone/email/mail columns** (0 rows).
  Prod estimates: co_contacts 24,574 / co_locations 12,429 / companies 10,208 (information_schema).
  FULLTEXT input: 25.2K rows, prefix-LIKE on the fullname BTREE suffices for Phase 1.

## G0-12 — Defect register additions (register only; nothing fixed)

| # | Defect | Evidence |
|---|---|---|
| D-1 | **Inert `#companySearch` autocomplete binding** — `include/remoteAddName.cfm:185` calls `setupAutocomplete('#companySearch', '#results', '/include/CompanyLookup.cfc', 'getCompanies')` but no `id="companySearch"` or `id="results"` element exists in the page (inputs are lines 13-73: contactFullName, birthday, meetingdate/loc, refer, pronoun, custom) or its two query-only includes (`qry/pronouns_210_1.cfm`, `qry/refers_210_2.cfm`). Binding attaches to an empty jQuery set — dead code. Twin inert copies: `app/assets/js/lookup.cfm:41`, `share/assets/lookup.cfm:41`. **CONFIRMED** |
| D-2 | **G0-7a recon discrepancy** — a prior recon pass reported `include/CompanyLookup.cfc` absent; it exists on disk (proof in G0-7a). Additionally `2026-07-08-master-link-ui-workorder.md:10` presents the `#companySearch`→CompanyLookup wiring as a live "model to copy" without noting the binding is inert (D-1). |
| D-3 | **G0-2 doc/state staleness** — `2026-07-06-wo1-execution-runbook.md:6-7` and `2026-07-07-dir-wo1-six-file-manifest.md:29-31` still read "nothing executed / dev exec gated" with no superseded-by pointer, while dated proofs show V3_7/8/9 applied on both schemas and V3_10 on dev. Includes this GATE-0 WO's own stale HOLD premise for G0-3. |
| D-4 | **"P1–P6" pre-flight register does not exist on disk** — G0-9 premise defect; no P-labeled DIR checklist anywhere in docs/. |
| D-5 | **`ContactItemService.INScontactitems_24052` (`:894-910`) writes the company name into VALUETEXT** — every Company reader (SS col5, sharez, contact_info) reads `valueCompany`, so rows from this path never surface. |
| D-6 | **No primary-Company maintenance** — all Company reads assume `ORDER BY primary_YN DESC LIMIT 1` but no write path sets or demotes `primary_yn` for Company items; PD-L2's upsert will inherit this ambiguity unless Plan Lock defines primary semantics. |
| D-7 | **`contact_info.cfm:1155` `$("#valueCompany").on("change")`** binds an element absent from the page's initial DOM (exists only inside the later-loaded remoteaddC/remoteUpdateC modals); handler is a no-op at bind time. |
| D-8 | **No canonical DIR WO register file** — DIR-WO numbers exist only as scattered doc titles; Plan Lock should establish the register (this WO claims DIR-WO-2). |
| D-9 | **No mysql CLI / MCP DB channel on the workstation** — prior sessions never had one (all proofs were operator-run). RESOLVED THIS SESSION for read-only work via python+pymysql using the operator's own HeidiSQL-stored credential (declared above); a durable sanctioned channel (mysql client install or MCP server, plus a credential decision) should be ratified at Plan Lock. |
| D-11 | **Dev↔prod view drift LIVE-CONFIRMED (F17 class)** — prod `contacts_ss_target/_followup/_maint` are old inline-subquery definitions (target lacks the userid join and `suStatus='Active'` filter that dev's rebuilt `cs.*`-join forms have); prod `sharez` is a join-based definition entirely different from dev's scalar-subquery form. Full DDL both sides in `2026-07-09-dir-wo2-gate0-live-probe-output.txt`. Read-path work must not assume dev==prod for these views. |
| D-10 | **PD-L2 vs prior recon decision conflict** — this WO's LOCKED PD-L2 (link upserts a contactitems Company row in the same cftransaction) directly contradicts `2026-07-08-master-link-ui-workorder.md:46` ("master-link writes the **snapshot only**, not a `contactitems` row"). PD-L2 governs, but the doc conflict must be registered and the doc superseded at Plan Lock. |

## Open questions for Plan Lock

1. **OQ-1 (G0-9):** what artifact do "P1–P6" refer to? Candidates found: V3_9's four orphan/sentinel
   pre-flight queries, or backfill items A1–A3/B1–B2 + photo decision D-1. None is pending work
   that touches the 11 columns.
2. **OQ-2 (namespace):** LOCKED INTENT mandates `/ajax/master/`; the prior recon doc proposed
   `ajax/contacts/master-*.cfm`. Assuming `/ajax/master/` wins — confirm, and note
   `ajax/Application.cfc` auth/CSRF covers any subfolder automatically.
3. **OQ-3 (PD-L2/PD-L3 interaction, fed by G0-6d):** contactitems has no provenance column, so the
   PD-L2-upserted Company row cannot be identified as master-sourced at unlink time. PD-L3 covers
   snapshot `_src` fields only — define what unlink does with the upserted item row (leave it? soft
   delete only if untouched? add provenance?). Also define `primary_yn` semantics for the upsert
   (D-6) and dedupe behavior vs `INScontactitems_23771`'s existence check.
4. **OQ-4 (G0-5):** no primary-office flag on co_locations — confirm the default-office rule
   (`MIN(colocid)` per coid, or the companies_ss `address1 IS NOT NULL` heuristic) before
   `company_location_id` is ever written by the UI.
5. **OQ-5 (channel):** ratify the read-only pymysql channel used this session (or provision a
   mysql client / MCP server with its own credential) as the sanctioned CC channel going forward;
   define whether CC may ever run gated DDL applies through it or applies stay operator-only.
6. **OQ-6 (WO-internal conflict):** G0-2c demands a `contactCompany` COUNT "per schema" while the
   WO's prod constraint allows information_schema/SHOW only — a plain SELECT COUNT on
   `actorsbusinessoffice.contactdetails_tbl` violates the stricter rule, so the prod count was
   skipped. Architect to relax the constraint or accept the 2026-07-08 proof's pointer-NULL
   statement as sufficient.

## Zero-write confirmation

**Zero writes of any kind were executed against either database.** The live probe ran exclusively
SELECT / SHOW / USE statements (whitelist-enforced in the script; full statement log =
`gate0_readonly_probe.py` in the session scratchpad; raw output in evidence). No DDL, no DML, no
code changes, no fixes applied. No commits, no pushes. Files created (evidence only, declared):
`docs/plans/evidence/2026-07-09-dir-wo2-gate0-recon-proof-bundle.md` (this file),
`docs/plans/evidence/2026-07-09-dir-wo2-gate0-operator-sql-packet.sql`,
`docs/plans/evidence/2026-07-09-dir-wo2-gate0-sixfile-verbatim.txt`,
`docs/plans/evidence/2026-07-09-dir-wo2-gate0-live-probe-output.txt`.

**STOP — awaiting architect Plan Lock.**
