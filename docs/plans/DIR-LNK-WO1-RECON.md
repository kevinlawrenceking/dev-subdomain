# DIR-LNK-WO-1 — Recon & Architecture Delta (FINAL, Conditional Plan Lock)

**Binding:** project TAO-MCD-P1 · series DIR-LNK-WO-1..12 · repo `kevinlawrenceking/dev-subdomain` · root `C:\Users\kevin\TAO\dev-subdomain` · branch `dev`.
**Binding spec:** `docs/plans/TAO_Master_Contact_Linking_Revised_Technical_Specification.md` (MD5 `078d926dfb7c146278180877e32fcbdb`, CONFIRMED). Citations below are `spec §N`.
**Mode:** read-only. No writes except this report (+ its docs-class commit). No DDL/DML/deploy. Prod: information_schema/SHOW/**aggregate-read RATIFIED**.
**Provenance:** audit AUD-1/2/3 closed **benign** (spec CreationTime 4:40:14 PM precedes recon 5:08:26 PM). **Operator rulings applied 2026-07-13** (PC-1/2/3 ruled; supersession finalized).
**Labels:** CONFIRMED (evidence) / INFERRED. No fabricated output.

---

## Rulings applied (this finalization)
- **PC-1 RULED:** master primary **phone/email = office-level** (`co_locations`, via `company_location_id`); linked primary phone/email/company are **master-managed, read-only**; differing pre-link user values preserved as **non-primary items**. → PC-1 no longer a conflict.
- **PC-2 RULED:** decision table approved as written; per-field counts required (delivered §5B).
- **PC-3 RULED:** V3_10 values stay **user-sourced**; reconcile + retire the matched legacy item at the WO-3 dry run (recon: 100% match, §5C).
- **Supersession finalized:** PD-L1..L4, R-1, R-3, fill-blank semantics are **historical to the DIR-WO-2 record and do NOT govern DIR-LNK**. Write-consolidation ruled (not open).
- **WO-7 invariant (verbatim, architect):** "the dead bridge is master-value items. The new preservation step writes DISPLACED USER values as non-primary items (skip if equivalent active item exists). New code never creates an item containing a master value."
- **C-1/C-2:** `5946ea4f` never deploys to prod; **DG-3/DG-4 struck**; DIR-WO-2 closed as dev acceptance + foundation record; dev fixtures **128621 and 102009 are NOT WO-11 targets (R-A2: bridge predicate returns 0 for both; they remain linked and migrate via WO-3/4/7)**; audition commits deploy later via cherry-pick branch under separate authorization.

**Surviving product conflicts after rulings: NONE.** (PC-4 SQL-SECURITY choice and PC-5 STATUS-doc re-head are WO-5 design / doc actions, not product conflicts. One residual data-check, not a conflict: office phone/email availability in `co_locations` — quantify at WO-3 for §7.5 blank-master exposure.)

---

## 0. Binding Verification (Gate 0)
repo / branch / root / spec-MD5 all **CONFIRMED** match (§0 of binding header). Working tree: `M .vscode/settings.json` (KNOWN-UNRELATED); `?? …Revised_Technical_Specification.md` + `?? DIR-LNK-WO1-RECON.md` + `?? master-contact-directory-STATUS.md` = DOCS/EVIDENCE (this commit). Local `dev` ahead of `origin/dev` `c7ccad22` by 2 docs commits (L-4, no divergence). L-1..L-5 resolved (spec absent×2 → placed as `…(1).md` → renamed → MD5 PASS). rule-4: canonical role doc (`database/claude-projects/tao-coldfusion-expert/00-PROJECT-INSTRUCTIONS.md`, amended `57c261b5`) vs spec = **NO conflict**. rule-5: superseded-behavior findings logged §9, not edited.
**Deploy state re `5946ea4f` (P-B):** ancestor of `origin/dev` (CONFIRMED); **prod bridge footprint DB-CONFIRMED ZERO** (prod 46,270 active contacts, 0 linked, all master cols 0).

---

## 1. Schema Recon (CONFIRMED — live information_schema, dev)

### 1.1 `contactdetails_tbl` — spec §5 metadata (OQ-1 PROVEN, all 3 primaries exist)
`contactPhone` varchar(100) (33), `contactEmail` varchar(150) (34), `contactCompany` varchar(255) (35); `contactPhone_src`/`contactEmail_src`/`contactCompany_src`/`contactPhoto_src` enum('user','master') NOT NULL DEFAULT 'user' (36–39); `company_location_id` int (40) — **the office pointer that sources master phone/email per PC-1**; `master_co_contact_id` (41), `master_coid` (42), `master_linked_date` datetime (43), `master_last_sync` datetime (44). `recordname` (31) VIRTUAL GENERATED=`contactFullName` (never write). **GAPs:** no dedicated link-status flag (use `master_co_contact_id IS NOT NULL`); no master-version stamp (spec §5 optional). **No single-active-link uniqueness constraint** (WO-2).

### 1.2 Indexes / FKs (CONFIRMED)
Master idx: `idx_cd_master_person`, `idx_cd_master_co`, `idx_cd_company_loc`, `idx_cd_user_fullname`. **D-15: pointers FK-enforced** — `fk_cd_master_co_contact→co_contacts.id`, `fk_cd_master_coid→companies.coid`, `fk_cd_company_location→co_locations.colocid`, all UPD=RESTRICT/DEL=SET NULL; `FK_contactdetails_taousers` RESTRICT/RESTRICT.

### 1.3 `contactitems_tbl` (CONFIRMED)
21 cols; Phone/Email primary value in `valuetext` (text), Company in `valueCompany` (varchar255); `primary_YN` char(1) DEFAULT 'N' (**no single-primary constraint**); `IsDeleted` bit soft-delete; `itemStatus` ∈ {Active, Pending}. Category IDs (`itemcategory`): **Phone=1, Company=9, Email=10**.

### 1.4 Master tables (CONFIRMED)
- `co_contacts` (person): PK `id`; `fullname`(idx), `coid` int DEFAULT 0 (idx), `imdbid`, legacy `contactid`. **No phone/email on the person** — CONFIRMED. **D-14: 81 rows coid=0** (dev=prod).
- `companies`: PK `coid`; **`coName` UNIQUE**; `coPhone`,`coEmail` (company level).
- `co_locations`: PK `colocid`; `coid`(idx); **`phone`,`email`**,`address1`,`city`,`state` — **the PC-1 master phone/email source (per selected office)**; reserved col `current_time` (backtick).

---

## 2. View DDL Recon (CONFIRMED — verbatim SHOW CREATE dev+prod; byte-capture `dirlnk_view_ddl.txt`)
Views exposing p/e/c: dev `contacts_ss`, `_target/_followup/_maint`, `sharez`, `sharez_optimized`, `sharezz`, `v_contacts_optimized`; prod same (−`sharez_optimized`, +`_zzq_*_old`).

**`contacts_ss` — spec §12.1 crux. CONFIRMED reads `contactitems`, not the columns — dev AND prod.** `SQL SECURITY DEFINER`, `FROM contactdetails d WHERE d.contactStatus='Active'`:
```
col3(Phone)  = (select valueText from contactitems where valueCategory='Phone'   and contactID=d.contactID and itemStatus='Active' order by primary_YN desc limit 1)
col4(Email)  = (select valueText from contactitems where valueCategory='Email'   and contactID=d.contactID and itemStatus='Active' order by primary_YN desc limit 1)
col5(Company)= (select valueCompany from contactitems where contactID=d.contactID and valueCategory='Company' and itemStatus='active' order by primary_YN desc limit 1)
```
New primary columns **NOT referenced**. `col5` uses `itemStatus='active'` (lowercase; matches via collation, cosmetic hazard).

**Drift (D-11, spec §12.2 "must be captured before DDL"):** `contacts_ss_target/_followup/_maint` — **dev = rebuilt `SELECT DISTINCT cs.* FROM contacts_ss JOIN fusystemusers su … JOIN fusystems s WHERE SystemType=… AND su.suStatus='Active'`** vs **prod = old inline `contactitems` subqueries + `contactID IN (SELECT … systemID IN (5,6))`, no userid join / no suStatus** — MATERIAL. All `contacts_ss*` = `SQL SECURITY DEFINER` (`contactdetails` view = INVOKER) → WO-5 must choose (PC-4). No hardcoded schema qualifier in dev SS this pass (re-verify on rebuild, role-doc §12).

---

## 3. Full Consumer Inventory (CONFIRMED — file:line; readers AND writers, Import V2/V3 + merge + sched included)

**A. Primary-column WRITERS (contactdetails p/e/c + pointers):** SOLE writer `ContactService.update()` `services/ContactService.cfc:223-256`, driven by `MasterDirectoryService` `upd` (`:188,218` link; `:293,304` unlink). `contactPhone/contactEmail` + `_src` **never written today** (only reader `ContactService.read():100`).

**B. Primary-column READERS:** `ContactService.read():96-100`; `include/contact_info.cfm:691-700` (badge only); `MasterDirectoryService.cfc:99,245`. **`contacts_ss*` do NOT read them.**

**C. contactitems Phone/Email/Company WRITERS (must never carry master values post-WO-7):**
- Bridge: `ContactItemService.createCompanyItem:847`→`contactitems_tbl:852`; rename `MasterDirectoryService.cfc:162`; soft-delete `:175,280`. (sole `createCompanyItem` caller = `MasterDirectoryService:156`.)
- Form add/update: `INScontactitems_24043:774`, `UPDcontactitems_24046:802`, `_24178:1007`; company `INScontactitems_23771:262`,`_24052:916`,`_24057:933`,`_24058:950`; email `_24050:882`; phone `_24051:899`. Entry: `remoteAddCAdd.cfm`→`qry/add_199_3.cfm:3`; `remoteUpdateCUpdate.cfm:58`→`qry/update_262_5.cfm`.
- **Import V2:** `services/ContactImportV2Service.cfc:1380` (INSERT columns incl valueCompany), `:1455` (company dedup). **Import V3:** `services/ContactImportV3Service.cfc:1871 (Email)`, `:1889 (Phone)`, `:1906 (Company)` — `INSERT INTO contactitems` (view). These create **user** items (fine; not master).
- **Merge:** `include/merge_contacts_interface.cfm:39-46,99-105` groups + repoints Company(`valueCompany`)/Phone/Email(`valuetext`) items across contacts.
- **sched/:** grep for primary/master writers = **no matches** (confirms no scheduled writer of primaries/pointers; consistent with §4.6).

**D. contactitems READERS for primary DISPLAY (migrate to columns @ WO-5, spec §12.2):** list SS views (`contacts_ss.cfm:145-147,199`); details company `contact_info.cfm:686-688`←`SELcontactitems_24663:1457`; email/phone `:589,603`←`SELcontactitems_24657:1442`/`_24714:1589`; panes `contact_pane.cfm:69,105,117`; pickers `remoteaddC.cfm:200`,`remoteUpdateC.cfm:190`; audition `auditions.cfm:471`,`auditions_new.cfm:192`; merge display; import grid `ContactItemService:520,557`.

**E. Link/unlink:** `ajax/master/{link,unlink,search,locations}.cfm`; UI `contact_info.cfm:1214,1251,1278,1316`. **Sync:** none.

---

## 4. Behavior Traces (CONFIRMED)
1. **Create:** live add → `contactdetails_tbl` (base, correct). **DEFECT:** `ContactService.create():57` writes the VIEW + lists generated `recordname`; callers `ajax/setup-wizard/save-step4.cfm:195` (WO-6 fix, spec §13).
2. **Edit primary today:** all go to `contactitems` (EAV), not columns (§3D) → WO-6 repoints to columns + server-side read-only when linked (spec §8.1/§13).
3. **Link (bridge):** `linkContactToMaster:91`; bridge `createCompanyItem` when no active Company item (`:154-158`); `_src` provenance `:199-211`; snapshot via `update:218`. Bridge = master-value item = **dead per WO-7 invariant**.
4. **Unlink:** `unlinkMaster:240`; R-1 match-guard soft-delete `:280-288`; clears pointers/snapshot `:293-304`. **Historical (R-1); reusable only in WO-10/11.**
5. **Display source:** list + details company/phone/email all from `contactitems`; **zero live reader of the primary columns for display** (spec §12.1 unmet).
6. **Master→contact propagation: NONE** — repo-wide no INSERT/UPDATE/DELETE on `co_contacts`/`companies`/`co_locations`; sync must be built (WO-8, spec §9).

---

## 5. Data-State Counts

### 5A. Totals (dev CONFIRMED; prod aggregate)
dev `contactdetails_tbl` IsDeleted=0: **1571**, linked **3**, columns pre-populated by V3_10 → company **436**/phone **276**/email **292**; `_src` 1570 user, 1 company='master' (residue). Active items Company **712**/Email **647**/Phone **952**. **prod:** **46,270** contacts, **0 linked**; active items Phone **52,326**/Email **44,810**/Company **27,945**.

### 5B. Decision-table counts per field (spec §6.3; PC-2 — CONFIRMED)
| | one (auto) | multi,1 primary (auto) | multi,0 primary (EXCEPTION) | multi,many primary (EXCEPTION) | dup-norm groups |
|---|---|---|---|---|---|
| **dev Phone** | 152 | 0 | 125 | 0 | 24 |
| **dev Email** | 127 | 0 | 165 | 1 | 42 |
| **dev Company** | 452 | 0 | 20 | 0 | 10 |
| **prod Phone** | 15,594 | 333 | 462 | **7,644** | — |
| **prod Email** | 24,499 | 125 | 484 | 262 | — |
| **prod Company** | 25,194 | 2 | 263 | 423 | — |
**Note:** dev `primary_YN` is barely used (artifact); **prod uses it, but has a large multi-many-primary set (Phone 7,644)** → the dominant exception class in prod. Auto-migratable ("one"+"multi,1") = prod Phone 15,927 / Email 24,624 / Company 25,196.

### 5C. V3_10 reconciliation dry-run (dev; PC-3 — CONFIRMED)
Of the pre-populated columns: **Phone 276 / Email 292 / Company 436 → 100% match an active item; 0 differ; 0 no-item.** ⇒ retire path = soft-delete the matched legacy item for every populated value; **zero conflicts**; `_src` stays 'user' per ruling.

### 5D. D-14 / D-18 (CONFIRMED; dev=prod)
**D-14:** `co_contacts` coid=0 = **81** (of 25,200) → no-company persons; treat as no company (never a company link target). **D-18:** duplicate master persons = **1,291 fullname groups / 2,786 rows**; e.g. "Sam Byrd" `id 4020` & `4032` (both `coid 8097`) → surface in link search, correctable via WO-9/WO-10 (test 45).

### 5E. Prod master-created Company items (OQ-4): **0** (0 linked). Bridge never ran in prod.

---

## 6. DIR-WO-2 Foundation Inventory (P-C — present, preserved, unaltered)
Migrations `V3_7*/V3_8*/V3_9*/V3_10*` + rollbacks (paired); code `MasterDirectoryService.cfc`, `ajax/master/*`, `createCompanyItem:847`, `contact_info.cfm:704` badge, `ContactService.cfc:223-256`; logs `MasterDirectoryService.cfc:221/307`; docs (phase1, STATUS, gate0 bundles, acceptance runbook `768d00ac`+bundle `f5bd4641`, prod-promotion runbook, six-file verbatim, WO0-PROOF-BUNDLE). Closes as dev acceptance / foundation (C-2). **Nothing altered.** ~~WO-11 cleanup targets registered: dev contacts 128621, 102009~~ **CORRECTED (R-A2): NO acceptance fixtures are WO-11 cleanup targets.** The canonical bridge-item predicate returns **0** for both 128621 and 102009 (128621's Company items are user-authored 'Acme Company'/'custom', `_src=user`, ≠ master coName; 102009 is a no-company link with 0 items). **Both fixtures remain linked (live pointers) and migrate under the standard WO-3/4/7 path, not WO-11.** The WO-11 register is populated at WO-11 by the proven-bridge rule, not from these fixtures.

---

## R-A1 / R-A2 Amendments (2026-07-14, DIR-LNK-WO-2 relay)

### R-A1 — production "auto-migratable" counts: exact SQL + DG-1 reconciliation
The prod auto-migratable figures (Phone 15,927 / Email 24,624 / Company 25,196) = **count of ACTIVE prod contacts whose active items in a category fall in decision-table buckets `one` + `multi, exactly-one-primary`** (spec §6.3 auto-migratable), i.e. eligible to populate the currently-empty primary column. Exact SQL (aggregate-only; prod):
```sql
SELECT bucket, COUNT(*) AS contacts FROM (
  SELECT ci.contactID,
    CASE WHEN COUNT(*)=1 THEN 'one'
         WHEN COUNT(*)>1 AND SUM(ci.primary_YN='Y')=1 THEN 'multi_one_primary'
         WHEN COUNT(*)>1 AND SUM(ci.primary_YN='Y')=0 THEN 'multi_zero_primary'
         WHEN COUNT(*)>1 AND SUM(ci.primary_YN='Y')>1 THEN 'multi_multi_primary' END AS bucket
  FROM actorsbusinessoffice.contactitems_tbl ci
  JOIN actorsbusinessoffice.contactdetails_tbl d ON d.contactID=ci.contactID AND d.IsDeleted=0
  WHERE ci.valueCategory = <'Phone'|'Email'|'Company'> AND ci.IsDeleted=0 AND ci.itemStatus='Active'
  GROUP BY ci.contactID
) t GROUP BY bucket;   -- auto-migratable = contacts in ('one' + 'multi_one_primary')
```
**Reconciliation with DG-1:** DG-1 counted 72,062 prod `contactdetails_tbl` rows (all, incl deleted) with **0 populated primary phone/email/company and `_src`=100% 'user'** — the primary COLUMNS are empty (nothing migrated to prod). The auto-migratable counts are ACTIVE contacts (subset of the 46,270 active) holding contactitems ELIGIBLE to populate those empty columns at WO-4. Fully compatible: DG-1 measures the empty destination columns; the auto-migratable counts measure the populated source items. **Interpretation CONFIRMED. Production evidence was aggregate-only (bucket counts; no row-level data).**

### R-A2 — dev company count 435 vs 436 (count core, canonical predicate)
**Canonical predicate governing ALL DIR-LNK counts hereafter:** a primary field is "populated" iff `IsDeleted=0 AND <col> IS NOT NULL AND TRIM(<col>) <> ''` (covers NULL, empty string, whitespace-only). Under it, dev `contactCompany` populated = **436** (raw NOT NULL = 436; TRIM<>'' = 436; empty/whitespace-only = 0 → **no query-semantics difference**). By source: **`_src='user'` = 435, `_src='master'` = 1.** The +1 over the 435 gate0 figure is **exactly one record: contactID 132419, `contactCompany='Morman Boling Casting'`, `contactCompany_src='master'`, linked master_co_contact_id 3518 / master_coid 6115.** **Cause: snapshot residue** — a master-managed `contactCompany` snapshot column written by a DIR-WO-2 link during dev testing (a snapshot COLUMN, not a `contactitems` bridge row). 435 = the V3_10 Part A user-sourced backfill (pre-linking). **WO-11 registration: NO** (no bridge `contactitems` evidence).

### R-A2 predicate reclassification (item 2)
The previously delivered bridge-item detection query is a **HIGH-CONFIDENCE CANDIDATE SOURCE for currently-linked records only — NOT the canonical WO-11 deletion predicate.** Known **misses:** post-link unlink; `_src` reset to 'user'; master rename; orphaned pointers (FK SET NULL); dev/prod historical drift. Known **false-positives:** user manually added an identical Company item after linking; a matching user-authored item exists while the snapshot is master-managed. **Binding WO-11 rule:** WO-11 may soft-delete only rows **PROVEN** bridge-created — the candidate query PLUS corroborating evidence (link/application logs, audit/history, creation timing relative to the link operation, test-fixture provenance, exact bridge preconditions, absence of an equivalent pre-link user item). If provenance cannot be proven: leave the item untouched and report it unresolved.

---

## 7. Gap Analysis (Requirement → Current → Gap → Change → Test; spec-anchored)
| spec | current | gap | change (WO) | test |
|---|---|---|---|---|
| §12.1 `contacts_ss` reads columns | reads contactitems both schemas | not migrated | rebuild SS/sharezz→columns (WO-5) | 34,35 |
| §15/rule 4/20 no master value in items | live bridge writes Company item | violates | disable WO-7, remove WO-11 | 36,47-51 |
| §6 backfill+soft-delete | V3_10 copied w/o soft-delete; primary_YN partial | non-compliant | WO-3 dry-run + WO-4 (decision table) | 1-7,33 |
| §8 linked read-only / unlinked editable | edits→contactitems; no read-only | UI+endpoint | WO-6 columns editable + server-side lock | 8-14 |
| §7 link replace+preserve; §7.4 snapshot | bridge fills company only; no p/e; no preserve | partial | WO-7 preserve displaced USER value + snapshot company(coName)+phone/email(**co_locations**) | 8-13,36 |
| §9 auto master sync | none (§4.6) | missing | WO-8 event+reconcile (office p/e + company) | 18-24,46 |
| §10 correction workflow | no table | missing | WO-2 table + WO-9 | 25-28 |
| §11 unlink=bad-match, preserve history | routine unlink+clear (R-1) | wrong framing; no restore | WO-10 guarded + audit restore | 29-32,44 |
| §16 audit | 2 cflog lines only | missing | WO-2 audit table (13 reasons) | all |
| §5 metadata | 3 primaries+pointers+2ts | no link-flag/version | WO-2 (if ruled) | — |
| §13.3 no dual-source | details show item company vs snapshot | dual-source | WO-5/6 single-source | 14,35 |
| §18 normalization | ad-hoc | missing | WO-2/3 shared normalizer | 5,11,12,26 |

---

## 8. Architecture Delta Register
Preserve unchanged: V3_7-10 schema/FK/idx. Preserve+revise: primary columns + `_src` (marker only, spec §5.1). Superseded@WO-5: `contacts_ss*`/`sharezz` item-ranking (S-7). Superseded→disable WO-7/remove WO-11: bridge `createCompanyItem`+rename/soft-delete (S-1). **Historical (do not govern DIR-LNK): PD-L1..L4, R-1, R-3, fill-blank.** Not built: per-field ownership engine (S-4). Prohibited: user-edit of linked primaries (S-5, §23), approval of routine updates (S-6). Held: DIR-WO-3 bulk linkage (S-8). Requires WO-6 fix: `ContactService.create()` view-write. Doc action: STATUS.md re-head (PD-L2 "governs" now historical).

---

## 9. Findings Log (P-A — recon CONTINUED through each; CONFIRMED)
F-1 primaries exist. F-2 no link-flag/version. **F-3 phone/email never written — RESOLVED by PC-1 (office source).** F-4 no single-primary constraint; `primary_YN` partial (dev unused / prod multi-many). F-5 dev/prod view drift. F-6 `contacts_ss` ranks from items both schemas. F-7 live bridge. F-8 routine unlink affordance (`masterUnlinkBtn`). F-9 unlink clears, no restore. F-10 no correction table. F-11 no sync. F-12 no audit table. F-13 create() view-write. **F-14 co_contacts no p/e — RESOLVED PC-1 (co_locations).** **F-15 V3_10 pre-populated, 100% item-match — RESOLVED PC-3 (retire on match).** F-16 backfill exception classes (§5B). F-17 SS=DEFINER. F-18 **D-18 = 1291 dup-person groups/2786 rows.** F-19 STATUS/2026-07-08 WO carry historical PD/R (don't edit in WO-1). F-20 prod 0 linked/0 bridge. **F-21 D-14 = 81 coid=0.** **F-22 Import V2/V3 create user Phone/Email/Company items (survive; not master).**

---

## 10. Risk Register
RK-1 `5946ea4f` bridge in origin/dev + entangled auditions → C-1 hold, cherry-pick separation, WO-12 bridge-free set. RK-2 backfill over-migrates ambiguous → decision-table EXCEPTION, dry-run first (**prod Phone multi-many 7,644 is the big exception class**). RK-3 view rebuild breaks display / drops INVOKER / schema qualifier → SQL-client only, drift reconcile, tests 34,35,41,42. RK-4 office p/e often blank → §7.5 blank-master mirror; quantify co_locations p/e at WO-3. RK-5 sync stale-write/lost concurrent item → guard+reconcile (23,24). RK-6 cleanup deletes genuine user items → match-guard+audit (37,51). RK-7 `primary_YN` unreliable → designated-primary only, else exception. RK-8 N-1 1s datetime → version/stale-guard (46). RK-9 create() view-write → fix _tbl (40).

---

## 11. Open Questions (resolved/answered)
OQ-1 primaries exist=**YES**. OQ-2 correction table=**NO**→WO-2/9. OQ-3 ts granularity=`datetime` 1s (N-1)→version guard. OQ-4 prod master Company items=**0**. **OQ-5 master p/e source=RULED co_locations (office).** OQ-6 item writers enumerated (§3C incl Import V2/V3). OQ-7 `master_link.log` = cflog `MasterDirectoryService.cfc:221/307` (dir operator-owned). OQ-8 dup-norm groups (§5B). OQ-9 propagation=**NONE**. **OQ-10 unlink/correction permission = WO-10 default guarded user + admin (spec §11.2); §7.5 blank-master = mirror.**

---

## 12. Product Conflicts Surviving Rulings
**NONE.** PC-1/PC-2/PC-3 ruled (above). Non-conflict items: PC-4 (SS `SQL SECURITY` DEFINER→INVOKER choice = WO-5 design), PC-5 (STATUS.md re-head = doc action), and one **data check** (not a conflict): office `co_locations.phone/email` population → quantify at WO-3 to size §7.5 blank-master exposure.

---

## 13. Proposed DIR-LNK-WO-2..WO-12 (spec phases 0→10; gates + tests)
| WO | phase | scope | dep | tests |
|---|---|---|---|---|
| **WO-2** schema/audit | §Ph1,§16 | audit table (13 reasons); correction table (§8.3/§10); single-active-link uniqueness guard; link-status/version if ruled; idempotent guarded migrations+rollback; dev | WO-1 | — |
| **WO-3** backfill dry-run (0 writes) | §Ph2,§6 | classify per §5B (dev+prod); exception exports (prod Phone multi-many 7,644 etc.); dup rule; **V3_10 reconcile (100% match → retire plan, §5C)**; quantify co_locations p/e | WO-2 | 1-7,33 |
| **WO-4** backfill dev | §Ph3 | migrate one+designated-primary; audit `BACKFILL_FROM_CONTACTITEM`; soft-delete matched item only; idempotent+rollback+reconcile | WO-3 | 1-7,33 |
| **WO-5** views/consumers | §Ph4,§12 | rebuild `contacts_ss`+`_target/_followup/_maint`+`sharezz`→columns; remove item-ranking; reconcile D-11; SQL-client, INVOKER choice; migrate CFM/import-grid readers | WO-4 | 34,35,41,42 |
| **WO-6** contact-details UI | §Ph(13),§8 | unlinked editable columns; linked read-only + "Managed by Master Directory" + last-sync; **server-side reject writes to linked primaries**; fix create() view-write | WO-5 | 8,14-17,40 |
| **WO-7** linking rewrite + bridge disable | §Ph5,§7,§15.2 | preview (§7.2); **preserve DISPLACED USER value as non-primary item, skip if equivalent active exists (invariant)**; snapshot company(coName)+phone/email(**co_locations by company_location_id**); disable bridge every link/relink; **new code never writes a master value to contactitems**; audit LINK_CREATED/PRELINK_VALUE_PRESERVED/MASTER_SNAPSHOT_POPULATED | WO-5,6 | 8-13,36,47,48,50 |
| **WO-8** master sync | §Ph6,§9 | event + scheduled reconcile; scope company+office p/e; material→`MASTER_AUTO_UPDATE`; idempotent/stale-guard; sched `createObject().init()`; N-1 guard; never write items | WO-2,7 | 18-24,39,46 |
| **WO-9** correction workflow | §Ph7,§10 | submit(§8.3); statuses(§10.2); approve→master via audited path→WO-8 fan-out; reject(§10.4); dup-prevent(§10.5) | WO-2,8 | 25-28 |
| **WO-10** bad-match correction | §Ph8,§11 | guarded correct-match (user+admin); preserve contactID/fusystemusers/funotifications/notes/history/items; restore pre-link via audit else clear; atomic relink; audit prev+new | WO-7,8 | 29-32,44 |
| **WO-11** bridge removal + cleanup | §Ph9,§15.1 | 15.1 seven-gate; remove bridge+fallbacks; prove unreachable; **soft-delete proven historical master-Company items incl fixtures 128621/102009** (match-guard+_src+link history); idempotent+counts+rollback; prove user items survive | WO-5,7 | 37,49,51 |
| **WO-12** prod rollout | §Ph10,§22 | schema→prod dry-run→exceptions→backfill→views(SQL client,INVOKER)→app deploy(D-17)→link enable→sync→cleanup→monitor; **5946ea4f held; deploy set bridge-free (P-B); no DG-3/DG-4; auditions via cherry-pick under separate auth**; per-stage rollback+auth | all | full |

**Process proofs:** P-A=§9 (recon continued). P-B=§0 (5946ea4f held; bridge-free deploy). P-C=§6 (DIR-WO-2 preserved).

---

## STOP — Conditional Plan Lock satisfied
Recon finalized read-only under the rulings. Decision-table counts (dev+prod), V3_10 reconciliation (100% match), full reader/writer inventory (Import V2/V3, merge, sched-none), D-14 (81) / D-18 (1291 groups/2786 rows), spec §-anchors delivered. **Surviving product conflicts: NONE.** WO-2..WO-12 remain HELD pending architect review of counts + exception process. This report + spec + STATUS committed docs-class, local, unpushed. STOP.
