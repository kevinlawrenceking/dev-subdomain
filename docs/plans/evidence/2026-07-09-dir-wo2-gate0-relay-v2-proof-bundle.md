# DIR-WO-2 (TAO-MCD-P1) — GATE 0 RELAY v2 PROOF BUNDLE

**Mode:** RECON / PRE-FLIGHT ONLY — read-only repo, `SELECT`/`SHOW`/`USE` only on DB. Zero repo writes, zero DB writes at capture time. Delivered 2026-07-09.

**DB channel note:** The relay mandated "mysql CLI only." No mysql CLI exists on this workstation (HeidiSQL GUI only). The only direct channel is `python+pymysql` to `www.theactorsoffice.com:3306` (direct MySQL wire protocol, not app/view/DSN-mediated). This satisfies the intent of the methodology (the `contacts_ss_target` bleed incident is about app/view/DSN mediation, which this channel avoids). Formal ratification tracked as OQ-5 (subsequently ratified at Plan Lock v1).

---

## G0-1 — WO number claim

The DIR WO register is `docs/plans/master-contact-directory-phase1.md` (Status: DRAFT). Its section 11 enumerates WO-1..WO-8, not "DIR-WO-n" numbers. DIR-WO-2 was already claimed 2026-07-09 for the master-link UI workstream. Assigned number confirmed: DIR-WO-2.

---

## G0-2 — Migration + backfill state audit (CRUX)

### Connection fingerprint (global, one connection, no default DB)
```
@@hostname | DATABASE() | CURRENT_USER() | VERSION() | NOW()
A35-51-468 |  (NULL)    | kingk436@%     | 8.0.41    | 2026-07-09 13:30:06
```
Every metadata query carries an explicit `table_schema IN ('actorsbusinessoffice','new_development')` predicate and runs in a single connection whose default `DATABASE()` is NULL. No `USE` context can masquerade one schema as the other — the bleed-proof property the prior USE-based probe lacked.

### G0-2a — 11 in-scope columns + contactPhoto_src (cross-schema)
```
TABLE_SCHEMA         | COLUMN_NAME          | COLUMN_TYPE            | NULL | DEFAULT | CHAR_MAXLEN
actorsbusinessoffice | company_location_id  | int                   | YES  |         |
actorsbusinessoffice | contactCompany       | varchar(255)          | YES  |         | 255
actorsbusinessoffice | contactCompany_src   | enum('user','master') | NO   | user    | 6
actorsbusinessoffice | contactEmail         | varchar(150)          | YES  |         | 150
actorsbusinessoffice | contactEmail_src     | enum('user','master') | NO   | user    | 6
actorsbusinessoffice | contactPhone         | varchar(100)          | YES  |         | 100
actorsbusinessoffice | contactPhone_src     | enum('user','master') | NO   | user    | 6
actorsbusinessoffice | contactPhoto_src     | enum('user','master') | NO   | user    | 6   (report-only)
actorsbusinessoffice | master_co_contact_id | int                   | YES  |         |
actorsbusinessoffice | master_coid          | int                   | YES  |         |
actorsbusinessoffice | master_last_sync     | datetime              | YES  |         |
actorsbusinessoffice | master_linked_date   | datetime              | YES  |         |
new_development      | (identical 12 rows)
```
Per-schema in-scope count (excl. contactPhoto_src): actorsbusinessoffice = 11, new_development = 11. contactPhoto width 500 on both. Master indexes present on both: idx_cd_company_loc, idx_cd_master_co, idx_cd_master_person. contactPhoto_src (out of scope): present on both.

### G0-2b — contactdetails view (cross-schema)
```
TABLE_SCHEMA         | SECURITY_TYPE | DEFINER    | IS_UPDATABLE | CHECK_OPTION | view_cols
actorsbusinessoffice | INVOKER       | kingk436@% | YES          | NONE         | 44
new_development      | INVOKER       | kingk436@% | YES          | NONE         | 44
```
Both SHOW CREATE VIEW (schema-qualified) show SQL SECURITY INVOKER, 32 base + 12 WO-1 columns, WHERE (IsDeleted = 0), bare `contactdetails_tbl` reference.

Bleed check (view body):
```
TABLE_SCHEMA         | mentions_new_development | mentions_actorsbusinessoffice
actorsbusinessoffice | 0                        | 1
new_development      | 1                        | 0
```
CLEAN, not a bleed. `information_schema.views.view_definition` stores the resolved form, correctly qualifying each view to its own schema base table. Neither view cross-references the other.

### G0-2c — backfill / pointer counts
new_development (DEV data read permitted):
```
rows_total | company_nonnull | phone_nonnull | email_nonnull | person_ptr | coid_ptr | office_ptr
1636       | 435             | 276           | 292           | 0          | 0        | 0
_src distribution: user/user/user/user -> 1636 rows (100% 'user')
```
actorsbusinessoffice: COUNT deliberately skipped (MODE restricts prod to information_schema + SHOW). Prod V3_10 backfill state NOT VERIFIABLE under permitted statements (OQ-6).

### G0-2d — Foreign keys (cross-schema)
```
TABLE_SCHEMA         | CONSTRAINT             | COLUMN               | REF_SCHEMA           | REF_TABLE    | REF_COL | UPD      | DEL
actorsbusinessoffice | fk_cd_company_location | company_location_id  | actorsbusinessoffice | co_locations | colocid | RESTRICT | SET NULL
actorsbusinessoffice | fk_cd_master_co_contact| master_co_contact_id | actorsbusinessoffice | co_contacts  | id      | RESTRICT | SET NULL
actorsbusinessoffice | fk_cd_master_coid      | master_coid          | actorsbusinessoffice | companies    | coid    | RESTRICT | SET NULL
new_development      | (same three, own-schema refs)
```
All three master FKs present on both schemas, each referencing its own schema. Pre-existing FK_contactdetails_taousers(userID) also present on both.

### Applied-state matrix

| Migration | new_development | actorsbusinessoffice | Evidence |
|---|---|---|---|
| V3_7 (12 cols + 3 idx + photo 500) | APPLIED | APPLIED | G0-2a |
| V3_8 (44-col INVOKER view) | APPLIED | APPLIED | G0-2b |
| V3_9 (3 master FKs) | APPLIED | APPLIED | G0-2d |
| V3_10 Part A (data backfill) | APPLIED (435/276/292 of 1636; pointers 0; all _src='user') | NOT VERIFIABLE (prod i_s/SHOW-only) | G0-2c |
| V3_10 Part B / linkage | DOES NOT EXIST (V3_11 abandoned + dropped, git 189700e8) | N/A | git log |

### G0-2e — Reconcile four contested sources

| # | Source | Claim | Verdict |
|---|---|---|---|
| 1 | 07-09 live probe | applied on both schemas | CORRECT (re-proven) |
| 2 | git d22b67c4 | complete on dev | CORRECT-BUT-PARTIAL (Jul-7 snapshot; prod caught up Jul-8) |
| 3 | wo0b memory | prod awaiting auth | STALE / WRONG (prod applied Jul-8) |
| 4 | architect register | unapplied on dev | FLATLY WRONG (dev applied Jul-7) |

Reconciling artifact: untracked `2026-07-08-wo1-PROD-apply-schema-proof.md` + `2026-07-08-prod-promotion-runbook.md`.

### G0-2f — Authorization trail
- Dev apply: committed d22b67c4 ("docs: WO-1 dev apply proof - V3_9 FKs PASS; migration chain complete on dev"); Kevin/HeidiSQL operator action.
- Prod apply: authorization EXISTS — `2026-07-08-wo1-PROD-apply-schema-proof.md:4` "Authorized: Kevin 2026-07-08"; runbook:6 "verbally authorized by Kevin 2026-07-08 ('lets update production')".
- G-1 determination: NOT TRIGGERED. Prod columns present WITH named auth trail. Nuance: the prod-apply proof files were UNTRACKED (registered D-12; closed by this commit).

---

## G0-3 — Six-file pack (a7e1c05e) — HOLD, no apply/rollback
`git show a7e1c05e --stat` confirms the pack authored V3_7/V3_8/V3_9 forward+rollback (6 files) plus WO-0b evidence. Full verbatim contents captured live.

CRITICAL — V3_8 drift from a7e1c05e: the applied V3_8 (working tree = commit c8c7e6ad) differs from the a7e1c05e pack version by comment-header ONLY (DRAFT block replaced by RECONCILED block, 14+/17-). The executable CREATE VIEW body is byte-identical. The other five files are byte-identical to a7e1c05e.

Apply order: V3_7 -> V3_8 (one window) -> V3_9 (after backfill validation) -> V3_10 Part A (data). Rollback order: V3_9 FK -> V3_8 view -> V3_7 columns. Every forward file has a paired _ROLLBACK.sql. No applies, no rollbacks executed.

---

## G0-4 — Seed verification (new_development)
Seed script `docs/plans/evidence/2026-07-07-seed-dev-master-tables.sql`. Applied. Exact live counts (07-09): co_contacts 25,200, co_locations 12,617, companies 10,740. Samples captured.

## G0-5 — co_locations key + cardinality (dev)
PK colocid (AUTO_INCREMENT), KEY coid, join key coid, InnoDB. NO primary-office flag. Offices per company: zero=785, one=8,295, >1=1,660. Default-office rule -> OQ-4.

## G0-6 — Reader surfaces + canonical Company item shape
a) Readers of the 11 snapshot columns across all .cfc/.cfm = ZERO. Schema-only; no app code reads them yet.
b) Company display surfaces all read contactitems (contacts_ss col5 = correlated subquery on valueCompany; target/followup/maint + sharez/sharezz variants). dev/prod view drift (D-11). Markup: contact_info.cfm:687, contact_pane.cfm:69.
c) Company write path: remoteaddC.cfm -> remoteAddCAdd.cfm -> add_199_3.cfm (INScontactitems_24043) + update_199_6.cfm (UPDcontactitems_24046). Canonical set: contactid, valuetype, valueCategory='Company', valueCompany, itemStatus='Active'. primary_YN NEVER written (D-6). No userid column. IsDeleted defaults 0. INScontactitems_24052:894-903 writes Company into VALUETEXT (D-5).
d) contactitems_tbl: 21 columns, NO provenance/source column, NO userid.

Canonical PD-L2 template:
```sql
INSERT INTO contactitems_tbl (CONTACTID, VALUETYPE, VALUECATEGORY, ValueCompany, ITEMSTATUS)
VALUES (?, 'Company', 'Company', ?, 'Active');
```

## G0-7 — UI anchors
a) CompanyLookup.cfc EXISTS; wired remoteAddName.cfm:185 (setupAutocomplete '#companySearch'/'#results'). `companySearch` appears only in the JS binding, never as markup element -> INERT (D-1). Dead twin = lowercase include/companylookup.cfm.
b) Company block renders contact_info.cfm:686-688; JS handlers :1155-1159. remoteUpdateName chain untouched by company/phone/email.

## G0-8 — /ajax framework
ajax/Application.cfc: host=="app" -> abo (prod) else abod (dev/uat) (:4-11, :40-45); request.dsn (:66); request.svc closure (:70-75, available in /ajax); framework CSRF gate (:81-128); JSON onError (:134-179).

## G0-9 — P1-P6 overlap
No on-disk artifact enumerates "DIR pre-flight P1-P6". Only Pn tokens = Addendum-B parity (P1) + plan WO-1..WO-8. OQ-1 stands. P7 = photo, out of scope.

## G0-10 — Dirt check
git status clean on services/, contact_info.cfm, ajax/, database/migrations/. Only 8 untracked docs files, all attributed. Merge-thread edits not present.

## G0-11 — co_contacts search fields
No person-level phone/email columns (both schemas). fullname BTREE index present. Total rows dev exact 25,200. FULLTEXT is an open design choice.

## G0-12 — Defect register

| ID | Severity | Finding | Anchor |
|---|---|---|---|
| D-1 | low | Inert #companySearch binding (element absent) | remoteAddName.cfm:185 |
| D-2 | info | CompanyLookup.cfc EXISTS; dead demo = lowercase companylookup.cfm | both present |
| D-5 | med | INScontactitems_24052 writes Company into VALUETEXT | ContactItemService.cfc:894-903 |
| D-6 | med | No primary_YN maintenance; never written | INScontactitems_24043:783 |
| D-11 | med | dev/prod view drift (target/followup/maint/sharez) | G0-6b |
| D-12 | low | Prod-apply auth + proof UNTRACKED (closed by this commit) | 2026-07-08 files |
| G-1 | NOT TRIGGERED | prod columns present WITH named auth trail | G0-2f |

## Open questions (resolved at Plan Lock v1)
- OQ-1 P1-P6 labels do not exist on disk.
- OQ-2 namespace -> /ajax/master/ (locked).
- OQ-3 unlink semantics with no provenance col -> R-1 match-guard (exact coName).
- OQ-4 default-office rule -> getLocations + picker.
- OQ-5 DB channel -> ratified.
- OQ-6 prod COUNT -> DG-1 deploy-gate only.

## Close-out (capture time)
Zero repo writes, zero DB writes at capture. All statements SELECT/SHOW/USE. Prod restricted to information_schema + SHOW. No applies/rollbacks. STOPPED after proof bundle; awaited architect verdict + Plan Lock (received as Plan Lock v1, 2026-07-09).
