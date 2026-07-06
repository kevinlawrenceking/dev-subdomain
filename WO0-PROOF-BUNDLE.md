# WO-0 Proof Bundle — Master Contact Directory Phase 1 Gate-0 Recon

Status: recon complete (repo-provable subset). **Uncommitted.**
Prepared: read-only, no DDL/DML/code changes.

> **ENVIRONMENT BLOCKER (read first).** This session has **no database access**: no `mysql` client on PATH (bash or Windows), no common MySQL/MariaDB install dir, no `~/.my.cnf`, no DB env vars, no `.mcp.json`, and no MySQL MCP tool available. Neither `abo` (prod / actorsbusinessoffice) nor `abod` (dev / new_development) is reachable from here. Therefore **every question requiring live SQL — `SELECT`, `SHOW CREATE`, `SHOW INDEX`, `SHOW GRANTS`, `EXPLAIN`, `VERSION()`, `@@time_zone` — is UNPROVEN and tagged as such.** No values were inferred to fill those gaps. Appendix A is a ready-to-run SQL pack (mysql CLI, per the WO's phpMyAdmin prohibition) to close every DB-blocked item in one pass.

---

## 1. Summary table

| Q | One-line finding | Status | DSN(s) |
|---|---|---|---|
| Q1 | Engine/version | **UNPROVEN** — no DB access | needs abo+abod |
| Q2 | `SHOW CREATE VIEW contactdetails` — not in repo; column list/ALGORITHM/SECURITY live-only | **UNPROVEN** — no DB access | needs abo/abod |
| Q3 | View DDL for contactitems/contacts_ss*/sharez — only partial, divergent repo captures exist | **PARTIAL / UNPROVEN** (repo secondary) | needs abo/abod |
| Q4 | `contactdetails_tbl` DDL — **recordname generated-vs-writable conflict unresolved** | **UNPROVEN** — no DB access; conflict registered | needs abo/abod |
| Q5 | `contactitems_tbl` DDL + status/type distributions | **UNPROVEN** — no DB access | needs abo/abod |
| Q6 | Length/junk audit for new-column sizing | **UNPROVEN** — no DB access | needs abo (prod data) |
| Q7 | Primary-integrity (zero / multi primary_yn) | **UNPROVEN** — no DB access | needs abo |
| Q8 | Master tables DDL incl. **co_locations (never captured)** + counts/indexes | **UNPROVEN** — no DB access | needs abod(+abo) |
| Q9 | Deployment reality (same vs cross-schema); **lookup_contacts.cfm imdb-UNION premise is FALSE in repo** | **PARTIAL** (code proven, DB parts UNPROVEN) | needs abo+abod |
| Q10 | create()/update() write the **VIEW `contactdetails`**, not `_tbl`; recordname treated writable in 4 methods | **PROVEN** (repo) | n/a |
| Q11 | Full contactitems Phone/Email/Company writer inventory; **primary_yn set inconsistently** | **PROVEN** (repo) | n/a |
| Q12 | Read-path subquery inventory; `getContactDetails`/`REScontactitems` use non-deterministic `LIMIT 1` | **PROVEN** (repo) | n/a |
| Q13 | Grid = `contacts_table.cfm` (DataTables server-side) → `contacts_ss.cfm` `qPage`; EXPLAIN blocked | **PARTIAL** (code proven, EXPLAIN UNPROVEN) | needs abod |
| Q14 | contactphoto: no repo writer; grid/gallery/share synth avatar by convention; detail page only reader | **PARTIAL** (code proven, samples UNPROVEN) | needs abo |
| Q15 | Master data-quality snapshot | **UNPROVEN** — no DB access | needs abod(+abo) |
| Q16 | **No `<cftransaction>`** in ContactService create()/update(); house pattern uses `application.dsn` | **PROVEN** (repo) | n/a |
| Q17 | CSRF: central guard in `app/Application.cfc`; **two token conventions** (`csrfToken` vs `csrf_token`) | **PROVEN** (repo) | n/a |
| Q18 | Collations / case-sensitivity | **UNPROVEN** — no DB access | needs abo/abod |
| Q19 | Recent audit timestamp columns use **DATETIME** (not TIMESTAMP); TZ blocked | **PARTIAL** (repo proven, TZ UNPROVEN) | needs abo+abod |
| Q20 | V3 finalize inserts to **views** contactdetails/contactitems; wizard step3 create → view, items → `_tbl` | **PROVEN** (repo) | n/a |

Proven (repo): Q10, Q11, Q12, Q16, Q17, Q20. Partial: Q3, Q9, Q13, Q14, Q19. Fully blocked: Q1, Q2, Q4, Q5, Q6, Q7, Q8, Q15, Q18.

---

## 2. Evidence (Q1–Q20)

### Q1 — Engine + version — UNPROVEN (no DB access)
`SELECT VERSION();` cannot be run. MySQL-vs-MariaDB and CTE/`ROW_NUMBER()` availability for the backfill form are **undetermined**. Circumstantial repo signal only: existing views use `group_concat` and window-free SQL; `V3_4` uses plain `ALTER`. Do not assume 8.0. See Appendix A-Q1.

### Q2 — `contactdetails` view DDL — UNPROVEN (no DB access)
No `CREATE VIEW contactdetails` exists anywhere in `database/` or `sql/` (confirmed by full-repo search). Column list, `ALGORITHM`, `SQL SECURITY`, `DEFINER` are **live-DB-only**. This directly gates the WO-1 view-rebuild spec. See Appendix A-Q2.

### Q3 — Affected view DDL — PARTIAL (repo secondary, divergent) / UNPROVEN authoritative
Authoritative DDL is live-only. Repo captures found (label SECONDARY, possibly stale):
- `contacts_ss_target`: **two conflicting** repo definitions —
  - `database/2026-06-18_fix_view_xschema_contacts_ss_target.sql:30` — live-captured: `CREATE OR REPLACE ALGORITHM=UNDEFINED DEFINER=\`kingk436\`@\`%\` SQL SECURITY DEFINER VIEW contacts_ss_target`; columns `contactid, contactcheck, avatar, hlink, col1, col2, col2b, col3, col4, col5, userid`; filter `contactID IN (SELECT contactID FROM fusystemusers WHERE systemID IN (5,6))`; **col3/col4/col5 use `ORDER BY primary_YN DESC LIMIT 1`**.
  - `database/rebuild_contacts_ss_system_views.sql:18` — simpler `SELECT DISTINCT cs.* FROM contacts_ss cs JOIN fusystemusers ... WHERE s.systemtype='Targeted List'` (no ALGORITHM/DEFINER). **Divergent — flag.**
- `contacts_ss_followup` / `contacts_ss_maint`: `database/rebuild_contacts_ss_system_views.sql:32,46` — `SELECT DISTINCT cs.*` filtered by `systemtype='Follow Up'` / `'Maintenance List'`.
- `contacts_ss` (base): **no CREATE VIEW in repo** — UNPROVEN.
- `contactitems` (view): **no CREATE VIEW in repo**; `V3_4__contactitems_valuetext_enlarge.sql:20-21` widens `contactitems_tbl.valuetext TEXT` and header confirms _tbl base / view split.
- `sharez`: `database/rebuild_sharez_view.sql:31` builds it from **base tables** (`contactdetails_tbl`, `taousers_tbl`, `fusystemusers_tbl`), exposes **Company only** (`ci_company.valueCompany AS Company`), **no phone/email columns**; plain `CREATE VIEW` (no ALGORITHM/DEFINER). Multiple competing rebuild scripts (`rebuild_sharez_view.sql`, `rebuild_sharez_simple.sql`, `optimize_sharez_view.sql`). **NOTE: live code queries `sharezz` (double-z), which the repo never builds** — see Defect D7. See Appendix A-Q3.

### Q4 — `contactdetails_tbl` DDL — UNPROVEN (no DB access) + **CONFLICT**
No `CREATE TABLE contactdetails_tbl` in repo (only index ALTERs, e.g. `2026-06-19_admin_analytics_indexes.sql:43`). **The recordname question cannot be settled from the repo and the two sources contradict:**
- MEMORY `project_wo_g` + `docs/plans/master-contact-directory-phase1.md:25,189` assert `contactdetails_tbl.recordname` is **VIRTUAL GENERATED** (never write).
- Code treats it as a **plain writable VARCHAR**: `ContactService.update:140` `SET recordname = <cfqueryparam...>`; `create` allowedFields:25; `update22` allowedFields:221; `updatebad:281`.
- Repo only proves `recordname` GENERATED on **other** tables (`pgpages_tbl`, `pgcomps_tbl` — `2026-04-18_sync_pgpages_prod_to_dev.sql:28`, `2026-06-19_admin_analytics_pgpages.sql:11-12`), **not** contactdetails.
Column-name collision check for the proposed new columns (`contactPhone`, `contactEmail`, `contactCompany`, `company_location_id`, `*_src`, `master_*`) is **UNPROVEN** — needs live DDL. This is the single highest-priority unblock. See Appendix A-Q4.

### Q5 — `contactitems_tbl` DDL + distributions — UNPROVEN (no DB access)
No `CREATE TABLE contactitems_tbl` in repo. Known from code: PK is `itemid` (`ContactItemService` uses `WHERE itemid=`), `primary_yn` is char `'Y'/'N'` (written as `CF_SQL_CHAR`), `valuetext` is now `TEXT` (`V3_4`), soft-delete via `isDeleted`/`itemstatus`. Casing drift observed in code (`primary_yn` vs `primary_YN`, `itemstatus` vs `itemStatus`, `valuecategory` vs `valueCategory`) but the physical column identifiers require live DDL. Status/type `GROUP BY` counts UNPROVEN. See Appendix A-Q5.

### Q6 — Length/junk audit — UNPROVEN (no DB access)
Cannot size `contactPhone`/`contactEmail`/`contactCompany`. Plan v1 proposed VARCHAR(100)/(150)/(200) but **`valuetext` is now `TEXT`** (`V3_4`), so real max lengths may exceed those and, under strict mode, truncate mid-backfill. Must measure before choosing widths. See Appendix A-Q6.

### Q7 — Primary integrity — UNPROVEN (no DB access)
Cannot count contact/category pairs with zero `primary_yn='Y'` or with ≥2. **Code makes this materially risky:** most Phone/Email/Company writers do NOT set `primary_yn` (Q11), and `getContactDetails`/`REScontactitems` pick with bare `LIMIT 1` (Q12), so "the primary" is often non-deterministic today. Backfill tie-break and zero-primary display change are unquantified. See Appendix A-Q7.

### Q8 — Master tables DDL + counts/indexes — UNPROVEN (no DB access)
`co_locations` DDL has still **never been captured** (not in repo, not reachable here). `companies`/`co_contacts` DDL known only from the column dumps the user pasted into chat (not authoritative). Row counts and existing indexes UNPROVEN — cannot avoid redundant index adds without `SHOW INDEX`. **This blocks wiring `company_location_id` and the master-side search indexes (WO-3/WO-5).** See Appendix A-Q8.

### Q9 — Deployment reality — PARTIAL
- (a) `information_schema` presence check of companies/co_contacts/co_locations in `actorsbusinessoffice` — **UNPROVEN** (no DB). This is the decisive same-schema-vs-cross-schema fact for real-vs-soft FKs.
- (b) `SHOW GRANTS` on both DSNs — **UNPROVEN**.
- (c) **`include/qry/lookup_contacts.cfm` does NOT contain an imdb UNION or any cross-schema reference.** It is a 7-line delegator:
  ```
  include/qry/lookup_contacts.cfm:4-5
  <cfset lookupService = createObject("component","services.LookupService")>
  <cfset contactResults = lookupService.getContacts(userId=userId, searchTerm=searchTerm)>
  ```
  and `services/LookupService.cfc` has **no** match for `imdb|new_development|co_contacts|companies|UNION`. **The WO's stated cross-schema precedent in this file does not exist in the current tree — registered as Conflict C1.**
- Proven cross-schema evidence that DOES exist: `app/Application.cfc:7-11` sets `_schema = "actorsbusinessoffice"` (prod) vs `"new_development"` (dev/uat); and `database/2026-06-18_fix_view_xschema_contacts_ss_target.sql` exists specifically because the `contacts_ss_target` view had hardcoded `new_development.` refs (see its `_ROLLBACK.sql:12`) — i.e. cross-schema view references have burned this codebase before. See Appendix A-Q9.

### Q10 — ContactService write paths + recordname writers — PROVEN
- **`create()` (services/ContactService.cfc:9-68) targets the VIEW `contactdetails`** — `:57 INSERT INTO contactdetails (...)`. Returns `insertResult.generatedKey`.
- **`update()` (:114-211) targets the VIEW `contactdetails`** — `:127 UPDATE contactdetails`.
- allowedFields (create) `:21-39` includes `"recordname":"CF_SQL_VARCHAR"` (`:25`).
- recordname write sites (all target the VIEW, all treat it writable, none skip it as generated):
  - `ContactService.cfc:25` (create allowedFields → INSERT `:57`)
  - `ContactService.cfc:140` (update: `#comma# recordname = <cfqueryparam ...>`)
  - `ContactService.cfc:221` (update22 allowedFields → UPDATE `:253`)
  - `ContactService.cfc:281` (updatebad → UPDATE `:277`) — MEMORY WO-G says retire.
  - `ContactService.cfc:309` — DEAD CODE (commented-out `updatse()`).
- Checked negatives: `remoteUpdateName*.cfm` only READ recordname; `include/qry/INSERT_266_3.cfm:6` writes recordname into the **`updatelog`** audit table via `UpdateLogService`, not contactdetails; `sql/import_v3_query_*.sql` are non-executing test fixtures.

### Q11 — contactitems Phone/Email/Company writer inventory — PROVEN
Central writer `services/ContactItemService.cfc`: Email `:860, :1241, :1258`; Phone `:877, :1275, :1293, :1310`; Company `:262(+dedupe:268), :894, :911, :928, :1327`; dynamic-category `:685, :774`. Edit UPDATEs by itemid `:802, :985` (mutate Phone/Email/Company rows). Soft-delete `:634, :645, :658, :1195`.
Other writers: `ContactService.cfc:451,481` (My Team tag, primary_yn='Y'); `ContactImportV2Service.cfc:1349(addContactItem, Email/Phone, primary by flag), :1372(addCompanyItem, primary='Y'), :1396(addAddressItem)`; `ContactImportV3Service.insertContactItems` finalize `:1871(Email), :1889(Phone), :1906(Company)` **no primary_yn**; wizard `save-step2.cfm:49(Email Y),:61(Phone Y),:73(Company)`, `save-step3.cfm:51(Email Y),:61(Phone Y),:74(Company)`, `save-step1.cfm:121(Phone Y)`; `sched/import-contacts.cfm:119,138(Email),:157,176,195(Phone),:214(Company)` **no primary_yn**; direct `_tbl` fragments `include/qry/insert_202_3.cfm:6(Email), insert_28_6/367_3/367_6(Company)`; `include/transfer_audition.cfm:253(Tag)`; merge `ContactDuplicateService.cfc:252(soft-delete colliding items),:275(repoint items to primary)`.
**primary_yn is set by only:** ContactItemService `:40,:597`; ContactService `:458,:487`; ImportV2 `:1358,:1380,:1404`; wizard `save-step2:49,61`, `save-step3:51,61`, `save-step1:121`. **All other Phone/Email/Company inserts leave primary_yn NULL/default** → Defect D2.
Cross-check: pgpages/pgFilename registry and `sched/` scan surfaced no additional grep-missed writer; `sched/avatar_loop*.cfm` only touch `avatar_yn`.

### Q12 — Read-path inventory — PROVEN
- `ContactItemService.REScontactitems:538-540` and `getContactDetails:574-582` — the three correlated subqueries (Phone/Email col via `valuetext`, Company via `valuecompany`), **bare `LIMIT 1`, no `ORDER BY primary_YN`** → non-deterministic (Defect D3).
- `contacts_ss*` views embed the same pattern **with** `ORDER BY primary_YN DESC LIMIT 1` (`2026-06-18_fix_view_xschema_contacts_ss_target.sql:30`).
- col3/col4/col5 consumers (phone/email/company): `include/contacts_ss.cfm:47-57,133-146,181-199`; `include/qry/contacts_gallery.cfm:12,35-37`; `include/contacts_gallery.cfm:151,160,172,180`; `include/contacts_table_attendees.cfm:28-30`; `include/contacts_attendees.cfm:5,46-48`; `include/qry/qFiltered_77_1.cfm`, `qFiltered_79_1.cfm`; `ContactService.cfc:567-568(getFilteredContactsByEvent),633-642(getFilteredContacts),1662-1678(GetMyTeam),1709-1725(getContactsByAudProject),1755-1771(getContactForCard)`; `share/share_contact_details.cfm:211-221`.
- `contacts_table` bound to `contacts_ss`/`_target`/`_followup`/`_maint` in `include/contacts.cfm:287-390`, `contacts_all.cfm:149-158`, `contacts_all_tabs.cfm:201-213`.
- sharezz consumers (Company only): `ShareService.cfc:64-76,99-115`; `share/share.cfm:33,41`, `index.cfm:52`, `export.cfm:39,46`, `remoteShareViewC.cfm:7-8`, `share_contact_details.cfm:206,220`.

### Q13 — Contact grid — PARTIAL (EXPLAIN UNPROVEN)
Main grid `include/contacts_table.cfm` — DataTables **server-side** (`:58 serverSide:true`, `:82-90 ajax→/include/contacts_ss.cfm POST`). Data endpoint `include/contacts_ss.cfm`: `qTotal:63-93`, `qFilteredCount:96-142`, `qPage:145-194` (`SELECT contactid, col2b, col3, col4, col5, hlink FROM #contacts_table# WHERE userid=? ... LIMIT start,length`; table name regex-validated `:32`). EXPLAIN baseline for the zero-correlated-subqueries acceptance criterion is **UNPROVEN (no DB)**. See Appendix A-Q13.

### Q14 — contactphoto conventions — PARTIAL (samples UNPROVEN)
- Only the **detail page** reads the column: `include/contact_info.cfm:166-167` overrides `browser_contact_avatar_filename = details.contactphoto` when non-empty; rendered `include/contact_view.cfm:17-18` as `<img src="#browser_contact_avatar_filename#?ver=#rand()#">` **and** passed to `FileExists()`/`isImageFile()` (`:4,:17`) — ambiguous whether the column holds a URL or a filesystem path.
- Default when empty (`include/pgload_setup.cfm:25-26`): `/media-#host#/users/#userid#/contacts/#contactid#/avatar.jpg`.
- Media root init: `app/Application.cfc:78-87` (`application.baseMediaPath`), `:362-381,459-478` (`session.userMediaPath/Url`, `userAvatarUrl`).
- Grid/gallery/share do NOT use `contactphoto`; they **synthesize** the avatar URL by convention from userid+contactid (`contacts_ss` view img concat; `share_contact_details.cfm:215-219 CONCAT('/media/users/',c.userid,'/contacts/',c.contactid,'/avatar.jpg')`).
- `sched/avatar_loop.cfm` / `avatar_loop2.cfm` write the **avatar.jpg file to disk** and toggle `contactitems.avatar_yn`; **neither writes the `contactphoto` column** (no repo writer of contactphoto exists at all).
- Distinct sample values & stored-format resolution: **UNPROVEN (no DB)**. Consequence for master-photo strategy (download-to-disk vs store-URL) is undecided until format is confirmed. See Appendix A-Q14.

### Q15 — Master data-quality snapshot — UNPROVEN (no DB access)
companies-by-`coVerificationStatus`, co_contacts null-`coid` %, imdbid %, `jobtitle_type` distribution, `location` samples, co_locations per-company office min/avg/max — all require the DB. Directly gates search UX, populate mapping, and the default-office rule. See Appendix A-Q15.

### Q16 — Transaction posture — PROVEN
`services/ContactService.cfc` contains **zero `<cftransaction>`**. `create()` (`:9-68`) and `update()` (`:114-211`) each run a single `<cfquery>` with **no `datasource` attribute** (relies on Application default). House pattern (uses `application.dsn` + per-query `datasource`): `EventService.cfc:46-150` (inside retry+`cftry`), `RelationshipService.cfc:74-205`, `SystemUserService.cfc:90-118`, `ContactImportV2Service.cfc:1060-1147` (explicit `action="rollback"`). Inconsistency: `application.dsn` vs `application.datasource` both appear across services. → Defect D4.

### Q17 — CSRF pattern — PROVEN
- Generation: `app/Application.cfc:398 session.csrfToken = CSRFGenerateToken()` (guarded `:397`). (`database/Application.cfc` has no CSRF.)
- Central guard: `app/Application.cfc:401-436` onRequestStart validates POST via `form.csrfToken` (`:405-406`) **or** header `X-CSRF-Token` (`cgi.HTTP_X_CSRF_TOKEN`, `:407-408`); session-compare then `CSRFVerifyToken()` fallback; failure → JSON `{"success":false,"code":"CSRF_FAILED"}`.
- Concrete compliant endpoint doing explicit validation: `ajax/admin-error-tickets/resolve.cfm:30-36` (`<cfparam name="form.csrf_token" default=""> ... <cfif NOT CSRFVerifyToken(form.csrf_token)>`).
- **Two conventions coexist** (Defect D5): central uses `csrfToken` / `session.csrfToken`; several endpoints use `csrf_token` / `session.csrf_token` (`import-auditions/bulk_category.cfm:67`, `bulk_edit.cfm:135`). `/ajax/master/*` must standardize on the central `app/Application.cfc` guard.

### Q18 — Collations — UNPROVEN (no DB access)
`SHOW FULL COLUMNS` / table default collations unobtainable. Case-sensitivity of `valuecategory`/`valuetype`/`itemstatus` matching (affects backfill WHERE and casing-drift handling) is **undetermined**. Code shows mixed casing in string literals ('Company' vs 'company' at `getContactDetails:582` uses lowercase `'active'`). See Appendix A-Q18.

### Q19 — Datetime convention — PARTIAL (TZ UNPROVEN)
Recent audit-timestamp columns are **DATETIME**: `2026-06-22_tickets_add_followup.sql:44 followupEmailSentAt DATETIME NULL`; `2026-04-18_add_ticket_notification_columns.sql:95 resolvedEmailSentAt DATETIME`, `:110 ackEmailSentAt DATETIME`. → **`master_linked_date`/`master_last_sync` should be `DATETIME`, not `TIMESTAMP`** (corrects plan v1). `@@global.time_zone`/`@@session.time_zone` UNPROVEN. See Appendix A-Q19.

### Q20 — Wizard/import insert locations — PROVEN
- V3 finalize: `ajax/importv3/finalize.cfm:250 → ContactImportV3Service.finalizeJob`. Contact insert `ContactImportV3Service.cfc:1557 INSERT INTO contactdetails (userid, contactFullName, contactBirthday, contactmeetingdate, user_yn, IsDeleted)` — **VIEW, not `_tbl`**. Items into VIEW `contactitems` (`:1871/1889/1906...`), `datasource=application.datasource`.
- Wizard Step 3: create is in the AJAX handler `ajax/setup-wizard/save-step3.cfm:32-38 contactService.create({userid, contactFullName:cName, contactStatus:"Active"})` (→ VIEW). Its own item inserts target **`contactitems_tbl` (base)** at `~:50`. `app/setup-wizard/steps/step3.cfm` has no ContactService call.
- **Three different write targets in play** (contactdetails view / contactitems view / contactitems_tbl base) → Conflict C2. Both wizard-step3 and V3-finalize must set the new denormalized columns on day one or the backfill goes stale immediately (WO-4/WO-20 coupling).

---

## 3. Defect register (observed during recon — NOT fixed)

| ID | Defect | Evidence | Blocks |
|---|---|---|---|
| **D1** | `recordname` written as a plain column in 4 live methods, but asserted VIRTUAL GENERATED elsewhere. If it IS generated, every create()/update() that passes recordname errors; if not, WO-G/memory is wrong. Unresolved without live DDL. | `ContactService.cfc:25,140,221,281`; vs MEMORY WO-G / plan `:25`. Repo proves generated only on pgpages/pgcomps. | WO-1, WO-4 (extending allowedFields before this is settled is unsafe) |
| **D2** | `primary_yn` set by only a minority of Phone/Email/Company writers; most leave it default. "Primary" is therefore frequently undefined. | Q11 writer list; unset at ImportV3 `:1871/1889/1906`, `sched/import-contacts.cfm`, most ContactItemService INS methods. | WO-2 backfill tie-break, WO-6 primary semantics |
| **D3** | `getContactDetails`/`REScontactitems` pick primary with bare `LIMIT 1` (no ORDER BY primary_YN) — non-deterministic; differs from the `contacts_ss` views which order by primary_YN. | `ContactItemService.cfc:538-540, 574-582` vs view DDL. | WO-6 correctness / display parity |
| **D4** | No `<cftransaction>` in ContactService.create()/update(); no datasource attr. Multi-row master link+populate would be non-atomic if built on this. | `ContactService.cfc:9-68, 114-211`. | WO-4, WO-5 |
| **D5** | Two CSRF conventions (`csrfToken`/`session.csrfToken` vs `csrf_token`/`session.csrf_token`). | `app/Application.cfc:398-436` vs `admin-error-tickets/resolve.cfm:32`, `import-auditions/bulk_*`. | WO-5 endpoint compliance |
| **D6** | Inconsistent write targets: view `contactdetails` (ContactService, V3) vs base `contactitems_tbl` (wizard) vs view `contactitems` (V3). View-insertability depends on live view DDL (Q2). | Q10, Q20. | WO-1, WO-4 |
| **D7** | Live code queries view **`sharezz`** (double-z) but repo only ever builds **`sharez`**. Real definition of the in-use view is unknown. | `ShareService.cfc:64-76`, `share/*` vs `rebuild_sharez_view.sql:31`. | any WO touching share company/phone/email |
| **D8** | `updatebad()` still live (MEMORY WO-G says retire) and multiple divergent view-rebuild scripts (`contacts_ss_target`, `sharez`) in repo — stale/ambiguous source of truth. | `ContactService.cfc:277-281`; `rebuild_contacts_ss_system_views.sql` vs `2026-06-18_fix_view_xschema...`. | WO-1 hygiene |

---

## 4. Conflicts and surprises (reality vs plan/audit/WO)

- **C1 — WO premise false:** Q9(c) assumes `include/qry/lookup_contacts.cfm` contains an imdb UNION cross-schema reference. It does not — it is a 7-line delegator to `LookupService.getContacts`, and LookupService has no imdb/new_development/co_contacts reference. The documented "existing cross-schema precedent" in that file does not exist in the current tree.
- **C2 — Write target contradicts plan:** plan v1 §4 says "DDL targets `_tbl`" and implies writes go to `_tbl`; in reality `ContactService.create/update` and `ContactImportV3Service` finalize write the **views** `contactdetails`/`contactitems`. So the mandatory post-ALTER **view rebuild** (plan §4.2) is not just for read visibility — it also determines whether INSERT/UPDATE through the view even sees the new columns. Higher-stakes than the plan states.
- **C3 — recordname:** audit docs/MEMORY treat `contactdetails.recordname` as VIRTUAL GENERATED; live code writes it as a normal column and no repo DDL confirms generated status for this table (only for pgpages/pgcomps). One of the two is wrong; unresolved here (D1).
- **C4 — column sizing:** plan v1 proposed VARCHAR(100/150/200) for the denormalized fields, but `contactitems_tbl.valuetext` is already widened to `TEXT` (`V3_4`), so source values may exceed those widths → truncation risk under strict mode (Q6).
- **C5 — timestamp type:** plan v1 used `TIMESTAMP` for link/sync columns; house convention in recent migrations is `DATETIME` (Q19). Adjust.
- **C6 — primary is a fiction today:** the plan assumes a clean "primary phone/email/company" to backfill; in practice primary_yn is often unset (D2) and one hot read path ignores it entirely (D3). Backfill needs an explicit, documented tie-break, and QA must expect display shifts for zero/multi-primary contacts.
- **C7 — sharezz≠sharez** (D7): any Phase-1 claim about share-page company/phone/email rests on a view whose real definition isn't in the repo.

---

## Appendix A — Ready-to-run SQL pack for the DB-blocked questions

Run via **mysql CLI only** (never phpMyAdmin — it rewrites SQL SECURITY/DEFINER and has corrupted view DDL before). Label every result with its DSN. DDL questions: run on `abod` and, where read-only permits, `abo`, then diff. Data questions (Q6/Q7/Q15): prefer `abo` (prod data), else label DEV.

```sql
-- A-Q1  Engine/version (both DSNs)
SELECT VERSION() AS version;

-- A-Q2  contactdetails view DDL (capture DEFINER/SQL SECURITY/ALGORITHM/columns)
SHOW CREATE VIEW contactdetails\G

-- A-Q3  All affected view DDL
SHOW CREATE VIEW contactitems\G
SHOW CREATE VIEW contacts_ss\G
SHOW CREATE VIEW contacts_ss_followup\G
SHOW CREATE VIEW contacts_ss_maint\G
SHOW CREATE VIEW contacts_ss_target\G
SHOW CREATE VIEW sharez\G
SHOW CREATE VIEW sharezz\G          -- the actually-used (double-z) view; confirm it exists

-- A-Q4  contactdetails base table DDL: settle recordname + collision-check new columns
SHOW CREATE TABLE contactdetails_tbl\G
SELECT COLUMN_NAME, DATA_TYPE, EXTRA, GENERATION_EXPRESSION
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'contactdetails_tbl'
  AND (COLUMN_NAME = 'recordname'
    OR COLUMN_NAME IN ('contactPhone','contactEmail','contactCompany','company_location_id',
                       'contactPhone_src','contactEmail_src','contactCompany_src','contactphoto_src',
                       'master_co_contact_id','master_coid','master_link_status',
                       'master_linked_date','master_last_sync'));

-- A-Q5  contactitems base DDL + distributions
SHOW CREATE TABLE contactitems_tbl\G
SELECT itemstatus, COUNT(*) FROM contactitems_tbl GROUP BY itemstatus;
SELECT valuetype, COUNT(*) FROM contactitems_tbl
 WHERE valuecategory IN ('Phone','Email','Company') GROUP BY valuetype;

-- A-Q6  Length/junk audit (repeat per category; example = Phone)
SELECT 'Phone' cat, COUNT(*) n, MAX(CHAR_LENGTH(valuetext)) maxtext
 FROM contactitems_tbl WHERE valuecategory='Phone' AND itemstatus='Active' AND IsDeleted=0;
SELECT valuetext FROM contactitems_tbl
 WHERE valuecategory='Phone' AND itemstatus='Active' AND IsDeleted=0
 ORDER BY CHAR_LENGTH(valuetext) DESC LIMIT 10;      -- Email: valuetext; Company: valuecompany
SELECT 'Company' cat, MAX(CHAR_LENGTH(valuecompany)) maxco
 FROM contactitems_tbl WHERE valuecategory='Company' AND itemstatus='Active' AND IsDeleted=0;

-- A-Q7  Primary integrity (repeat per category)
SELECT cat, COUNT(*) pairs_zero_primary FROM (
  SELECT contactid, COUNT(*) items, SUM(primary_yn='Y') prim, 'Phone' cat
  FROM contactitems_tbl WHERE valuecategory='Phone' AND itemstatus='Active' AND IsDeleted=0
  GROUP BY contactid HAVING items>=1 AND prim=0) t GROUP BY cat;
SELECT contactid FROM contactitems_tbl
 WHERE valuecategory='Phone' AND itemstatus='Active' AND IsDeleted=0
 GROUP BY contactid HAVING SUM(primary_yn='Y')>=2 LIMIT 5;

-- A-Q8  Master tables (run on new_development; also check prod presence in A-Q9)
SHOW CREATE TABLE co_locations\G       -- never captured before
SHOW CREATE TABLE companies\G
SHOW CREATE TABLE co_contacts\G
SELECT (SELECT COUNT(*) FROM companies) companies,
       (SELECT COUNT(*) FROM co_contacts) co_contacts,
       (SELECT COUNT(*) FROM co_locations) co_locations;
SHOW INDEX FROM companies;  SHOW INDEX FROM co_contacts;  SHOW INDEX FROM co_locations;

-- A-Q9  Deployment reality
SELECT TABLE_SCHEMA, TABLE_NAME FROM information_schema.TABLES
 WHERE TABLE_NAME IN ('companies','co_contacts','co_locations');   -- which schema(s)?
SHOW GRANTS FOR CURRENT_USER();                                    -- both DSNs

-- A-Q13 Grid EXPLAIN (abod) — paste the live qPage SQL with a real userid + table
EXPLAIN SELECT contactid, col2b, col3, col4, col5, hlink
 FROM contacts_ss WHERE userid = :uid ORDER BY col1 LIMIT 0,25;

-- A-Q14 contactphoto samples
SELECT DISTINCT contactphoto FROM contactdetails_tbl
 WHERE contactphoto IS NOT NULL AND contactphoto <> '' LIMIT 20;

-- A-Q15 Master data quality
SELECT coVerificationStatus, COUNT(*) FROM companies GROUP BY coVerificationStatus;
SELECT COUNT(*) total, SUM(coid IS NULL)/COUNT(*) pct_null_coid,
       SUM(imdbid IS NOT NULL)/COUNT(*) pct_imdb FROM co_contacts;
SELECT DISTINCT jobtitle_type FROM co_contacts LIMIT 20;
SELECT location FROM co_contacts WHERE location<>'' LIMIT 20;
SELECT MIN(c) mn, AVG(c) av, MAX(c) mx FROM (
  SELECT coid, COUNT(*) c FROM co_locations GROUP BY coid) t;

-- A-Q18 Collations
SHOW FULL COLUMNS FROM contactitems_tbl;    -- inspect valuecategory/valuetype/itemstatus Collation
SELECT TABLE_NAME, TABLE_COLLATION FROM information_schema.TABLES
 WHERE TABLE_NAME IN ('contactitems_tbl','contactdetails_tbl');

-- A-Q19 Time zone
SELECT @@global.time_zone, @@session.time_zone;
```

**STOP — awaiting approval. No WO-1+ work performed.**

---

# WO-0b Addendum — abo (prod) pane landed 2026-07-04

Source: `docs/plans/evidence/2026-07-04-wo0b-pane-abo.txt` (verbatim). Engine confirmed **MySQL 8.0.41 Community Server — GPL**.
**Still pending:** the **abod (new_development) pane**, and the two one-liners **`SHOW GRANTS` (Q9b)** and **`EXPLAIN` (Q13)**. Everything requiring the dev pane (Q8 master DDL/indexes/counts, Q15 master data-quality, and the dev-vs-prod DDL drift diff) remains **UNPROVEN — awaiting abod pane**.

## Section 1 status flips (abo-provable)

| Q | New status | What the prod pane proved |
|---|---|---|
| Q1 | **PROVEN (abo)** | MySQL **8.0.41**. CTE + `ROW_NUMBER()` available — the plan's window-function backfill form is valid (prod already ships `v_contacts_optimized` using CTEs + `ROW_NUMBER`). |
| Q2 | **PROVEN (abo)** | `contactdetails` view is an **enumerated 32-column** list over `contactdetails_tbl` WHERE `IsDeleted=0`, `DEFINER`/`SQL SECURITY DEFINER`, definer `kingk436@%`. It **enumerates columns** → after the WO-1 ALTER the view **must be rebuilt** or new columns are invisible (plan §4.2 confirmed, now proven not assumed). |
| Q3 | **PROVEN (abo)** | Full prod view list captured incl. `contacts_ss`/`_followup`/`_maint`/`_target` (all carry the phone/email/company `ORDER BY primary_YN DESC LIMIT 1` subqueries), **`sharezz` (double-z) is REAL** (resolves D7), `sharez` (single-z) is the older maxaudition variant, and `taousers` is the lone `INVOKER` view. |
| Q4 | **PROVEN (abo) — D1/C3 RESOLVED** | `contactdetails_tbl.recordname` is **`varchar(500)` VIRTUAL GENERATED, `genexpr=contactFullName`**. MEMORY/plan were right; the **code is the bug** (see D1 verdict). **No collision**: none of `contactPhone/contactEmail/contactCompany/company_location_id/*_src/master_*` exist. **Reuse note:** `imdbid varchar(50)` and `refer_contact_id int` already exist; `contactPhoto varchar(255)` and `avatar_yn char(1)` already exist. |
| Q5 | **PROVEN (abo)** | `itemStatus`: Active **257,491** / Pending **7,976** / NULL 2. `primary_YN char(1) NOT NULL default 'N'`. `valuetext` is **`text`** (V3_4 confirmed). `valueCategory` reliable; **`valueType` is free-text and dirty** (trailing apostrophes, blanks, raw phone numbers and company names stored as the type; `Phone/Work Fax` n=7752, `Company/Job` n=20435). |
| Q6 | **PROVEN (abo)** | Active max lengths: **Company 174** (n=27,918), **Email 104** (n=44,797), **Phone 57** (n=52,321). Plan's `VARCHAR(200/150/100)` fit, but Company 174 is tight (see finding F3). |
| Q7 | **PROVEN (abo) — confirms C6/D2** | "Primary" is a fiction. **Phone: 4,337 zero-primary + 7,644 multi-primary; Email: 8,411 + 262; Company: 7,863 + 423.** Backfill needs an explicit deterministic tie-break. |
| Q9(a) | **PROVEN (abo) — DECIDED** | `companies`, `co_contacts`, `co_locations` **all exist in `actorsbusinessoffice` (prod)** — and also in `new_development` and `tao_development`. Prod `companies_ss` view already **JOINs `companies`+`co_locations`**. Prod copies are **populated** (G1: 10,740 / 25,200 / 12,617). With Q9b `REFERENCES` granted → **FK direction FINAL: real, same-schema FKs in prod** (Open Q1 closed; soft-FK fallback dropped). |
| Q14 | **PROVEN (abo) — photo format resolved** | Every sampled `contactPhoto` value is a **full external IMDb URL** (`https://m.media-amazon.com/images/M/...jpg`) — not a filesystem path, not local `avatar.jpg`. contactPhoto holds URLs; the disk `avatar.jpg`+`avatar_yn` is a **separate** mechanism (mixed driver confirmed). |
| Q18 | **PROVEN (abo)** | Both hot tables `utf8mb4_unicode_ci` → **case-insensitive**. Backfill/enum WHERE matching is safe against the views' mixed `'active'`/`'Active'` casing. |
| Q19 | **PROVEN (abo)** | House convention for app-set stamps = **DATETIME** (`tickets.resolvedEmailSentAt/ackEmailSentAt` datetime; `error_tickets.root_cause_*` present). Server TZ `SYSTEM`. → **`master_linked_date`/`master_last_sync` = `DATETIME`** (corrects plan-v1 `TIMESTAMP`, confirms C5). |

**Q9(b) — PROVEN (one-liner A, both DSNs, 2026-07-04):** app user = **`kingk436@%`** with **`ALL PRIVILEGES` on `actorsbusinessoffice`, `new_development`, `tao_development`** (ALL includes `REFERENCES`, `ALTER`, `INDEX`, `CREATE VIEW`). Grants are **identical** on both DSNs — abo/abod is a connection/default-DB distinction, not a privilege boundary. → **FK creation is permitted in prod; not a blocker.** Evidence: `docs/plans/evidence/2026-07-04-wo0b-oneliner-A-grants.txt`.

**Q13 — PROVEN (one-liner B, abod, 2026-07-04):** the `contacts_ss` grid materializes the whole view (`<derived2>`, type=ALL, filesort) over a `contactdetails_tbl` ref scan, plus **10 `DEPENDENT SUBQUERY` nodes, all on `contactitems_tbl`** (each an indexed 1-row `ref`). Three of the ten are the phone/email/company columns (`col3`/`col4`/`col5`) WO-6 eliminates; the other ~7 are Tag-badge subqueries (`col2`/`col2e`/`col2b`) that stay in the EAV bag. Baseline for Acceptance #4. Evidence: `docs/plans/evidence/2026-07-04-wo0b-oneliner-B-explain.txt`.

**Q8 — PROVEN (prod, 2026-07-04):** master-table DDL/indexes captured from `actorsbusinessoffice`. **`co_locations` PK = `colocid`** (plan §4.1's "locid" was wrong); `co_contacts` PK = `id`; `companies` PK = `coid`, `coName` UNIQUE. All three **InnoDB / utf8mb4_unicode_ci** → real FKs legal. Master-side indexes the plan wanted (`coName`, `fullname`, `location`, `coid`) **already exist**. Evidence: `docs/plans/evidence/2026-07-04-wo0b-prod-Q8-Q15-master.txt`.

**Q15 — PROVEN (prod, 2026-07-04):** companies **100% `Unverified`** (10,740); co_contacts **100% have `imdbid`** (25,200), `coid` uses a **0-sentinel** (default 0, 0.00% NULL); `jobtitle_type` is **dirty** (leading space + embedded newlines + nested `(Category)`; 3,740 blank); `co_contacts.location` is **contaminated** (phones/names/companies mixed with real locations); `co_locations` averages **1.27 offices/company (max 46), no primary-office flag**.

Still open: only the **dev-vs-prod hot-table drift diff** (needs the abod pane). **Q9(c)** stays a repo finding (false imdb-UNION premise, carried).

## New findings from the prod pane (registered, not fixed)

- **F1 — D1/C3 settled: `recordname` IS virtual-generated.** `contactFullName` is its expression. Any INSERT/UPDATE that lists `recordname` with a value **errors** in MySQL 8. WO-4 must **not** add `recordname` to `allowedFields` and must **drop** the four existing writers (`ContactService.cfc:25,140,221,281`); this is the same landmine as WO-G and the wizard-P11 silent-create failure. **Gate-0 create()-writes-VIEW defect now doubly confirmed.**
- **F2 — `v_contacts_optimized` already exists in prod.** A CTE/`ROW_NUMBER()` join-free replacement for the `contacts_ss` correlated-subquery pattern is already built (unused by the plan). WO-6 read-path cutover should **evaluate reusing/retargeting it** rather than authoring a new optimized view from scratch.
- **F3 — Company width.** Source `valueCompany` is `varchar(255)` and active Company max is 174. Denormalized `contactCompany` should be **`varchar(255)`** (match source), not 200, to remove any strict-mode truncation risk.
- **F4 — master IMDb id already has a home.** `contactdetails_tbl.imdbid varchar(50)` already exists; do **not** add a separate `master_imdb_id`. Managed-field mapping should target existing `imdbid`.
- **F5 — D7 resolved.** `sharezz` (the in-use double-z view) is real: it reads Company/Title/Audition via correlated subqueries on `contactitems_tbl` (`itemStatus='Active' AND IsDeleted=0 LIMIT 1`). Any Phase-1 share-surface claim can now rest on a captured definition.
- **F6 — three physical copies of the master tables** (`actorsbusinessoffice`, `new_development`, `tao_development`). **Prod copy is populated (G1: 10,740 companies / 25,200 co_contacts / 12,617 co_locations)** and already used by prod's `companies_ss` view → **prod is authoritative** for Phase 1; wire against it. Drift/confusion risk remains if scrapers write a different copy than the app reads — Phase 2 must pin the write target. `tao_development` stays a drift-register item (confirm it is not a rogue copy affecting `_schema` routing).
- **F9 — Q8/Q15 pivot to PROD.** Since the directory is populated and authoritative in `actorsbusinessoffice`, the outstanding **Q8** (co_locations/companies/co_contacts DDL + indexes — needed to wire `company_location_id`) and **Q15** (data quality) should be pulled from **prod**, not new_development. The abod pane's remaining value is narrowed to the **dev-vs-prod drift diff of the hot tables** (`contactdetails_tbl`/`contactitems_tbl`/contact views).
- **F7 — dirty `valueType`.** Backfill and any UI that surfaces "phone type / email type" must tolerate blanks, trailing `'`, and values that are actually phone numbers or company names. Do not key logic on `valueType`.
- **F8 — Acceptance #4 must be scoped.** The `contacts_ss` EXPLAIN baseline shows **10** `DEPENDENT SUBQUERY` nodes, but WO-6 denormalization only removes **3** (phone `col3` / email `col4` / company `col5`). The other ~7 are Tag-badge subqueries (`col2`/`col2e`/`col2b`) that stay in the EAV bag by design. Restate Acceptance #4 as "**zero phone/email/company correlated subqueries**"; the post-WO-6 EXPLAIN should reference `contactitems_tbl` only for Tag columns. Also note the outer `<derived2>` is `type=ALL` + filesort — WO-6/F2 (`v_contacts_optimized` reuse) addresses the materialize-whole-view cost, separate from the 3-subquery removal.
- **F10 — FK wiring corrected: `co_locations` PK is `colocid`, not `locid`.** Plan §4.1 guessed `locid`. Real target keys: `company_location_id INT → co_locations.colocid`; `master_co_contact_id INT → co_contacts.id`; `master_coid INT → companies.coid`. All three referenced cols are PKs; all tables InnoDB → FKs are enforceable. WO-1 adds the INT columns; a follow-up ALTER adds the FKs.
- **F11 — WO-3 master indexes are largely a no-op.** `companies.coName` is already `UNIQUE`; `co_contacts.fullname`, `.location`, `.coid` and `co_locations.coid` are already single-column indexed. The plan's `idx_co_name` is **redundant** (skip); the composite `idx_cc_name_loc` is **optional/low-priority**. No index on `co_contacts.contactid` (irrelevant — that legacy column is not reused).
- **F12 — master data-quality gates for WO-5.** companies are **100% `Unverified`** → verification status is NOT a usable Phase-1 signal (Model C user-override is the safety net; surface it as informational only). `co_contacts` are **100% imdbid-bearing**, but `coid` uses a **0-sentinel** (default 0, 0% NULL) → treat `coid=0` as "no company," not NULL, when deriving `master_coid`.
- **F13 — master free-text is dirty; normalize before use.** `co_contacts.jobtitle_type` has leading spaces, embedded newlines, and nested `(Category)` (3,740 blank) → **normalize** (trim/strip-newline/parse) for WO-5 search+display. `co_contacts.location` is **contaminated** with phones/person-names/company-names → an **unreliable filter** (don't hard-depend on location search). `co_locations` has **no primary-office flag** (avg 1.27, max 46 offices/company) → the "default office" rule must be explicit (e.g. `companies_ss`'s `address1 IS NOT NULL AND <>''`, tie-break `MIN(colocid)`).

## Gaps to close on the next paste

- **G1 — prod master-table row counts: CLOSED 2026-07-04.** `actorsbusinessoffice` = companies **10,740** / co_contacts **25,200** / co_locations **12,617** — populated. → real same-schema FKs confirmed. Evidence: `docs/plans/evidence/2026-07-04-wo0b-prod-master-counts.txt`.
- **G2 — prod half CLOSED 2026-07-04.** ~~Q8 master DDL/indexes + Q15 quality~~ done from PROD (see Q8/Q15 PROVEN above; F10–F13). Evidence: `docs/plans/evidence/2026-07-04-wo0b-prod-Q8-Q15-master.txt`. **Still open:** only the **dev-vs-prod hot-table DDL drift diff** — run the **abod pane** (contactdetails_tbl / contactitems_tbl / contact views) and diff against the abo pane.
- **G3 — one-liners: CLOSED 2026-07-04.** ~~`SHOW GRANTS` (Q9b)~~ done — app user `kingk436@%` has `ALL PRIVILEGES` (incl. `REFERENCES`) on `actorsbusinessoffice` + `new_development`; FK creation permitted. ~~`EXPLAIN` grid baseline (Q13)~~ done — 10 dependent subqueries, 3 removable (see F8).
