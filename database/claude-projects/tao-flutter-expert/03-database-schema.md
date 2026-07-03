# Phase 9 -- Database Schema Audit

**Audited:** 2026-03-16
**Database:** MySQL (`new_development` dev / `actorsbusinessoffice` prod)
**ColdFusion datasource:** `reach`
**Method:** Static analysis of all `.cfm`, `.cfc`, and `.sql` files in the codebase (no live DB access)

---

## 9A -- Tables Referenced in Code

Tables were extracted from every `FROM`, `JOIN`, `INSERT INTO`, `UPDATE`, and `DELETE FROM` clause across all CFML and SQL files.

### Core Business Tables (actively queried in application code)

| # | Table Name | Usage Context | Has _tbl Base Table |
|---|-----------|--------------|---------------------|
| 1 | `contactdetails` | Central contact record; queried everywhere | Yes (`contactdetails_tbl`) -- VIEW with `IsDeleted <> 1` filter |
| 2 | `contactitems` | EAV-style contact attributes (email, phone, tags, company) | Yes (`contactitems_tbl`) -- VIEW with `IsDeleted <> 1` filter |
| 3 | `taousers` | User accounts | Yes (`taousers_tbl`) -- VIEW with `IsDeleted = 0` filter |
| 4 | `funotifications` | Actionable reminders/notifications | Implied (`funotifications_tbl` referenced in dev_backup) |
| 5 | `fusystemusers` | Per-contact per-user system enrollment | Yes (`fusystemusers_tbl`) -- VIEW |
| 6 | `fusystems` | System definitions (Target, Follow-up, Maintenance) | No |
| 7 | `fusystemtypes` | System type reference | No |
| 8 | `fuactions` | Master action templates | No |
| 9 | `actionusers` | Per-user action copies and scheduling overrides | Yes (`actionusers_tbl`) |
| 10 | `fuActionLinks` | Action link reference | No |
| 11 | `events` | Auditions, appointments, meetings | Yes (`events_tbl`) -- VIEW |
| 12 | `eventcontactsxref` | Event-to-contact cross-reference | Yes (`eventcontactsxref_tbl`) -- VIEW |
| 13 | `eventtypes` | Event type definitions | No |
| 14 | `eventtypes_user` | Per-user event type customization | No |
| 15 | `noteslog` | Contact and event notes | Yes (`noteslog_tbl`) -- VIEW |
| 16 | `auditions` | Audition records | No |
| 17 | `audprojects` | Audition project records | No |
| 18 | `audroles` | Audition role definitions | No |
| 19 | `audroletypes` | Role type reference | No |
| 20 | `audsteps` | Audition workflow steps | No |
| 21 | `audcategories` | Audition category reference | No |
| 22 | `audsubcategories` | Audition subcategory reference | No |
| 23 | `audtypes` | Audition type reference | No |
| 24 | `audtones` | Audition tone reference | No |
| 25 | `audcontacts_auditions_xref` | Contact-to-audition cross-reference | No |
| 26 | `audmedia` | Audition media files | No |
| 27 | `audmediatypes` | Media type reference | No |
| 28 | `audmedia_auditions_xref` | Media-to-audition cross-reference | No |
| 29 | `audmedia_audroles_xref` | Media-to-role cross-reference | No |
| 30 | `audgenres` | Genre reference | No |
| 31 | `audgenres_audition_xref` | Genre-to-audition cross-reference | No |
| 32 | `audgenres_user` | Per-user genre preferences | No |
| 33 | `auddialects` | Dialect reference | No |
| 34 | `auddialects_user` | Per-user dialect preferences | Yes (`auddialects_user_tbl`) |
| 35 | `audessences_audtion_xref` | Essence-to-audition cross-reference (note: typo in table name "audtion") | No |
| 36 | `audvocaltypes` | Vocal type reference | No |
| 37 | `audvocaltypes_audition_xref` | Vocal type-to-audition cross-reference | No |
| 38 | `audageranges` | Age range reference | No |
| 39 | `audageranges_audtion_xref` | Age range-to-audition cross-reference (note: typo "audtion") | No |
| 40 | `audnetworks` | Network reference | No |
| 41 | `audnetworks_user` | Per-user network preferences | Yes (`audnetworks_user_tbl`) |
| 42 | `audplatforms` | Platform reference | No |
| 43 | `audplatforms_user` | Per-user platform preferences | Yes (`audPlatforms_user_tbl`) |
| 44 | `audopencalloptions_user` | Per-user open call options | No |
| 45 | `audpaycycles` | Pay cycle reference | No |
| 46 | `audsubmitsites_user` | Per-user submit site preferences | Yes (`audsubmitsites_user_tbl`) |
| 47 | `audtones_user` | Per-user tone preferences | No |
| 48 | `audsources` | Audition source reference | No |
| 49 | `audbooktypes` | Booking type reference | No |
| 50 | `audcallbacktypes` | Callback type reference | No |
| 51 | `audcontracttypes` | Contract type reference | No |
| 52 | `audlinks` | Audition links | Yes (`audlinks_tbl`) |
| 53 | `audlocations` | Audition locations | No |
| 54 | `audanswers` | Audition question answers | No |
| 55 | `audquestions_default` | Default question templates | No |
| 56 | `audquestions_user` | Per-user question templates | No |
| 57 | `audqtypes` | Question type reference | No |
| 58 | `audunions` | Union reference | No |
| 59 | `auditionprojectdetails` | Audition project detail view/table | No |
| 60 | `audprojects_castingabout` | Casting About project data | No |
| 61 | `auditionsimport` | Legacy audition import staging | No |
| 62 | `auditionsimport_error` | Legacy audition import errors | No |
| 63 | `audition_notifications` | Audition-specific notifications | No |

### Contact & Relationship Support Tables

| # | Table Name | Usage Context |
|---|-----------|--------------|
| 64 | `contactsimport` | Legacy contact import staging |
| 65 | `contacts_ss` | Contact spreadsheet/search view |
| 66 | `contacts_ss_followup` | Follow-up system contacts view |
| 67 | `contacts_ss_maint` | Maintenance system contacts view |
| 68 | `contacts_ss_target` | Target system contacts view |
| 69 | `notstatuses` | Notification status reference |
| 70 | `tags` | Master tag definitions |
| 71 | `tagsuser` / `tags_user` | Per-user tag assignments | `tags_user_tbl` exists |
| 72 | `essences` | Essence reference |
| 73 | `reldetails` | Relationship detail records |
| 74 | `itemcategory` | Contact item category reference |
| 75 | `itemcatxref` / `itemcatxref_user` | Item category cross-references |
| 76 | `itemtypes` | Item type definitions | `itemtypes_tbl` exists |
| 77 | `itemtypes_user` | Per-user item types |

### Page & Navigation Tables

| # | Table Name | Usage Context |
|---|-----------|--------------|
| 78 | `pgpages` | Page definitions |
| 79 | `pgpagespluginsxref` | Page-to-plugin cross-reference |
| 80 | `pgpanels_master` | Master panel definitions |
| 81 | `pgpanels_user` | Per-user panel config | `pgpanels_user_tbl` exists |
| 82 | `pgpanels_user_xref` | Panel-to-user cross-reference |
| 83 | `pgfields` | Page field definitions |
| 84 | `pgfiles` | Page file registry |
| 85 | `pgcomps` | Page component definitions |
| 86 | `pgapplinks` | Application links |
| 87 | `pgapps` | Application definitions |
| 88 | `pgdirs` / `pgDIRs` | Directory definitions |

### Site & Link Tables

| # | Table Name | Usage Context |
|---|-----------|--------------|
| 89 | `sitelinks_master` | Master site link definitions |
| 90 | `sitelinks_user` | Per-user site links | `sitelinks_user_tbl` exists |
| 91 | `sitetypes_master` | Master site type definitions |
| 92 | `sitetypes_user` | Per-user site types | `sitetypes_user_tbl` exists |

### Report & Export Tables

| # | Table Name | Usage Context |
|---|-----------|--------------|
| 93 | `reportitems` | Report item data |
| 94 | `reportranges` | Report date ranges |
| 95 | `reportcolors` | Report color definitions |
| 96 | `reports_master` | Master report definitions |
| 97 | `reports_user` | Per-user report config |
| 98 | `exportitems` | Export definitions |
| 99 | `exports` | Export records |

### User & Account Tables

| # | Table Name | Usage Context |
|---|-----------|--------------|
| 100 | `userstatuses` | User status reference |
| 101 | `viewtypes` | View type reference |
| 102 | `dateformats` | Date format reference |
| 103 | `timezones` | Timezone reference |
| 104 | `countries` | Country reference |
| 105 | `regions` | Region reference |
| 106 | `genderpronouns` | Gender pronoun reference |
| 107 | `genderpronouns_users` | Per-user pronoun settings | `genderpronouns_users_tbl` exists |
| 108 | `mtgdurations` | Meeting duration reference |
| 109 | `incometypes` | Income type reference |
| 110 | `paymentplans` | Payment plan definitions |

### Billing & Integration Tables

| # | Table Name | Usage Context |
|---|-----------|--------------|
| 111 | `thrivecart` | ThriveCart payment records | `thrivecart_tbl` exists |
| 112 | `thrivecart_cancel` | ThriveCart cancellation records |

### Support & Admin Tables

| # | Table Name | Usage Context |
|---|-----------|--------------|
| 113 | `tickets` | Support ticket records | `tickets_tbl` exists |
| 114 | `ticketstatuses` | Ticket status reference |
| 115 | `ticketpriority` | Ticket priority reference |
| 116 | `tickettypes` | Ticket type reference |
| 117 | `tickettestusers` | Ticket test user assignments |
| 118 | `ticketslog_tbl` | Ticket log records |
| 119 | `bigbrother` | Page access tracking |
| 120 | `AccessedFiles` | File access audit trail |
| 121 | `updatelog` | Update log records |
| 122 | `taoversions` | Version tracking |
| 123 | `tao_files` | Application file registry (dev tooling) |
| 124 | `tao_tables` | Table registry (dev tooling) |

### Sharing Module Tables

| # | Table Name | Usage Context |
|---|-----------|--------------|
| 125 | `shareTokens` | Share token management |
| 126 | `shareViews` | Share view tracking |
| 127 | `shares` | Share records |

### Import V2 Tables

| # | Table Name | Usage Context |
|---|-----------|--------------|
| 128 | `import_jobs` | V2 import job tracking |
| 129 | `import_job_columns` | V2 column mapping |
| 130 | `import_job_rows` | V2 row staging |
| 131 | `import_job_events` | V2 event audit trail |
| 132 | `import_field_mappings` | Canonical field definitions (shared V2/V3) |
| 133 | `import_field_aliases` | Header auto-mapping patterns (shared V2/V3) |

### Import V3 Tables

| # | Table Name | Usage Context |
|---|-----------|--------------|
| 134 | `import_v3_jobs` | V3 import job tracking |
| 135 | `import_v3_columns` | V3 column mapping |
| 136 | `import_v3_rows` | V3 row staging |
| 137 | `import_v3_facts` | V3 EAV field storage |
| 138 | `import_v3_row_results` | V3 finalization results |
| 139 | `import_v3_events` | V3 event audit trail |
| 140 | `contact_custom_fields` | User-defined custom fields |

### Audition Import Tables

| # | Table Name | Usage Context |
|---|-----------|--------------|
| 141 | `import_auditions_jobs` | Audition import job tracking |
| 142 | `import_auditions_columns` | Audition import column mapping |
| 143 | `import_auditions_rows` | Audition import row staging |
| 144 | `import_auditions_facts` | Audition import EAV storage |
| 145 | `import_auditions_row_results` | Audition import finalization results |
| 146 | `import_auditions_events` | Audition import audit trail |

### Feature Flags

| # | Table Name | Usage Context |
|---|-----------|--------------|
| 147 | `feature_flags` | Global feature toggles |
| 148 | `feature_flag_users` | Per-user feature overrides |

### Other / Misc Tables

| # | Table Name | Usage Context |
|---|-----------|--------------|
| 149 | `attachments` | File attachments |
| 150 | `links` / `links_tbl` | General link records |
| 151 | `uploads` | Upload tracking |
| 152 | `ftypexref_tbl` | Follow-up type cross-reference |
| 153 | ~~`phonebook`~~ | **DRIFT — NEVER-FUNCTIONAL; not a live table. See drift note below.** |
| 154 | `exttypes` | Extension type reference |
| 155 | `extensions` | Extension records |
| 156 | `debugLog` | Debug logging |
| 157 | `loggins` | Login tracking |

**Total unique tables/views referenced: ~157**

> **Note:** Some names like `contacts_ss`, `contacts_ss_followup`, `contacts_ss_maint`, `contacts_ss_target`, `sharezz`, `sharez`, and `maxaudition` appear to be MySQL VIEWs, not base tables.

> **Drift note (2026-07-03, WO-PHONEBOOK) — row #153 `phonebook`:** This row is a **documentation artifact, not a live table.** It was **derived from a dead code reference**, not from live schema. The only reference is an `INNER JOIN phonebook` in `services/AuditionImportService.cfc:1621` (introduced 2026-03-12, commit `c9305792`; moved by `4e25a3b2c` on 2026-04-12). No `CREATE TABLE phonebook` / `DROP TABLE phonebook` exists anywhere in repo history, and the table is **ABSENT in every schema** (prod `information_schema` sentinel, `docs/plans/evidence/2026-07-03-merge-repoint-sqlpack.txt` pack `E_phonebook`). **Mechanism of the drift:** this schema map was built partly by grepping code references; a reference to a table that was never created produced a phantom row. Verdict **NEVER-FUNCTIONAL** (not orphaned-by-drop) — the join has never resolved. The code reference is being removed under WO-PHONEBOOK Option B. The identical phantom row #153 also appears in the sibling audit docs `database/claude-projects/tao-coldfusion-expert/09-database-schema.md:235` and `database/claude-projects/tao-migration-analyst/04-database-schema.md:235`.

---

## 9B -- Foreign Key Analysis

### Declared Foreign Keys (from CREATE TABLE statements in migration scripts)

| Parent Table | Child Table | FK Column | Constraint Name |
|-------------|------------|-----------|-----------------|
| `taousers(userid)` | `import_jobs` | `userid` | `FK_import_jobs_userid` |
| `import_jobs(job_id)` | `import_job_columns` | `job_id` | `FK_import_job_columns_job` |
| `import_jobs(job_id)` | `import_job_rows` | `job_id` | `FK_import_job_rows_job` |
| `import_jobs(job_id)` | `import_job_events` | `job_id` | `FK_import_job_events_job` |
| `import_field_mappings(canonical_field)` | `import_field_aliases` | `canonical_field` | `FK_import_field_aliases_field` |
| `feature_flags(flag_key)` | `feature_flag_users` | `flag_key` | `FK_feature_flag_users_flag` |
| `taousers(userID)` | `shareTokens` | `userID` | `FK_ShareTokens_Users` |
| `shareTokens(shareID)` | `shareViews` | `shareID` | `FK_ShareViews_ShareTokens` |

### Implied FK Relationships (from JOIN patterns in code, no declared constraint)

These are columns referenced in JOINs or WHERE clauses that imply FK relationships but have no `CONSTRAINT FOREIGN KEY` declaration in the codebase.

| Parent Table | Child Table | FK Column | Evidence |
|-------------|------------|-----------|----------|
| `taousers` | `contactdetails` | `userid` | `JOIN ... ON d.userid = u.userid` |
| `contactdetails` | `contactitems` | `contactid` | `JOIN contactitems ON contactitems.contactid = d.contactid` |
| `contactdetails` | `noteslog` | `contactid` | `INSERT INTO noteslog (userid, contactid, ...)` |
| `contactdetails` | `eventcontactsxref` | `contactid` | `JOIN eventcontactsxref ON e.contactid = ...` |
| `contactdetails` | `fusystemusers` | `contactid` | `JOIN fusystemusers su ON su.contactid = d.contactid` |
| `contactdetails` | `audcontacts_auditions_xref` | `contactid` | `DELETE from audcontacts_auditions_xref WHERE contactid = ?` |
| `fusystemusers` | `funotifications` | `suid` | `JOIN funotifications n ON n.suid = su.suid` |
| `fusystems` | `fusystemusers` | `systemid` | `JOIN fusystems s ON s.systemid = su.systemid` |
| `fuactions` | `funotifications` | `actionid` | `JOIN fuactions a ON a.actionid = n.actionid` |
| `fuactions` | `actionusers` | `actionid` | `JOIN actionusers au ON au.actionid = a.actionid` |
| `events` | `eventcontactsxref` | `eventid` | `JOIN events ON events.eventid = ecx.eventid` |
| `audprojects` | `audroles` | `audprojectid` | `JOIN audroles ON audroles.audprojectid = ...` |
| `audprojects` | `audcontacts_auditions_xref` | `audprojectid` | `DELETE FROM audcontacts_auditions_xref WHERE audprojectid = ?` |

> **WARNING:** The core business tables (`contactdetails`, `contactitems`, `fusystemusers`, `funotifications`, `events`, `audprojects`, etc.) rely entirely on application-level referential integrity. There are no declared database-level foreign keys on any of these tables.

**Findings:**

- `contactdetails.userid` -> `taousers.userid`: No FK constraint
- `fusystemusers.contactid` -> `contactdetails.contactid`: No FK constraint
- `funotifications.suid` -> `fusystemusers.suid`: No FK constraint
- `funotifications.actionid` -> `fuactions.actionid`: No FK constraint
- `events.contactid` -> `contactdetails.contactid`: No FK constraint
- `contactitems.contactid` -> `contactdetails.contactid`: No FK constraint
- `noteslog.contactid` -> `contactdetails.contactid`: No FK constraint

> `TECH-DEBT`: All core table relationships lack declared FK constraints. Orphan records are possible if application logic fails silently. The only tables with proper FKs are the newer import system tables (V2, V3, audition import) and sharing module.

---

## 9C -- Timestamp Column Usage

### Tables WITH `created_at` / `updated_at` Patterns

All **newer** tables (created 2024+) follow proper timestamp conventions:

| Table | `created_at` | `updated_at` | `started_at` | `finished_at` |
|-------|:-----------:|:------------:|:-----------:|:-------------:|
| `import_jobs` | DEFAULT CURRENT_TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Yes | Yes |
| `import_job_columns` | DEFAULT CURRENT_TIMESTAMP | -- | -- | -- |
| `import_job_rows` | -- | ON UPDATE CURRENT_TIMESTAMP | -- | -- |
| `import_job_events` | DEFAULT CURRENT_TIMESTAMP | -- | -- | -- |
| `import_v3_jobs` | DEFAULT CURRENT_TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Yes | Yes |
| `import_v3_columns` | DEFAULT CURRENT_TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | -- | -- |
| `import_v3_rows` | DEFAULT CURRENT_TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | -- | -- |
| `import_v3_facts` | DEFAULT CURRENT_TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | -- | -- |
| `import_v3_row_results` | DEFAULT CURRENT_TIMESTAMP | -- | -- | -- |
| `import_v3_events` | DEFAULT CURRENT_TIMESTAMP | -- | -- | -- |
| `import_auditions_jobs` | DEFAULT NOW() | ON UPDATE NOW() | Yes | Yes |
| `import_auditions_columns` | -- | -- | -- | -- |
| `import_auditions_rows` | DEFAULT NOW() | ON UPDATE NOW() | -- | -- |
| `import_auditions_facts` | DEFAULT NOW() | ON UPDATE NOW() | -- | -- |
| `import_auditions_row_results` | DEFAULT NOW() | -- | -- | -- |
| `import_auditions_events` | DEFAULT NOW() | -- | -- | -- |
| `contact_custom_fields` | DEFAULT CURRENT_TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | -- | -- |
| `feature_flags` | DEFAULT CURRENT_TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | -- | -- |
| `feature_flag_users` | DEFAULT CURRENT_TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | -- | -- |
| `shareTokens` | `createdDate` (non-standard name) | -- | -- | `expiryDate` |

### Tables WITHOUT Timestamp Columns (core legacy tables)

Based on code analysis, the following core tables have **no evidence of `created_at`/`updated_at` columns**:

- `contactdetails` / `contactdetails_tbl`
- `contactitems` / `contactitems_tbl`
- `funotifications`
- `fusystemusers` / `fusystemusers_tbl`
- `fuactions`
- `actionusers` / `actionusers_tbl`
- `fusystems`
- `events` / `events_tbl`
- `eventcontactsxref`
- `audprojects`
- `audroles`
- `noteslog` / `noteslog_tbl`
- `auditions`
- `tags` / `tags_user`
- All `aud*` reference tables

> `TECH-DEBT`: The entire core business schema (contacts, notifications, systems, events, auditions) lacks `created_at`/`updated_at` timestamps. This makes debugging, auditing, and conflict resolution during migration extremely difficult. Only the import subsystem and feature flags have proper timestamps.

---

## 9D -- Soft Delete Patterns

### View-Based Soft Delete (the TAO pattern)

TAO uses a distinctive pattern where **base tables have a `_tbl` suffix** and **views without the suffix filter out soft-deleted rows**. This is the primary soft-delete mechanism.

| View Name | Base Table | Soft Delete Filter |
|-----------|-----------|-------------------|
| `taousers` | `taousers_tbl` | `WHERE IsDeleted = 0` |
| `contactdetails` | `contactdetails_tbl` | `WHERE IsDeleted <> 1` |
| `contactitems` | `contactitems_tbl` | `WHERE IsDeleted <> 1` (per MEMORY.md) |
| `fusystemusers` | `fusystemusers_tbl` | `WHERE IsDeleted <> 1` |
| `events` | `events_tbl` | `WHERE IsDeleted <> 1` |
| `eventcontactsxref` | `eventcontactsxref_tbl` | `WHERE IsDeleted <> 1` |
| `noteslog` | `noteslog_tbl` | `WHERE IsDeleted <> 1` |
| `actionusers` | `actionusers_tbl` | `WHERE IsDeleted <> 1` (implied) |

**Column name:** `IsDeleted` (sometimes `isdeleted`, `isDeleted` -- case varies)

### Direct `isdeleted` Column Usage in Queries

Tables queried with explicit `isdeleted` filters:

- `funotifications`: `n.isdeleted = 0` (43+ occurrences across codebase)
- `fusystemusers`: `su.isdeleted = 0` (frequent in admin-relationship)
- `events`: `isdeleted = 0` (in admin-calendar-cleanup.cfm)
- `contactdetails`: `isdeleted` column in allowed fields whitelist

### `is_active` / `isActive` / `active` Patterns

- `shareTokens`: `isActive TINYINT(1) DEFAULT 1`
- `contact_custom_fields`: `is_active TINYINT(1) DEFAULT 1`
- `feature_flags`: `is_enabled TINYINT(1)` (not `isActive` but similar purpose)
- `feature_flag_users`: `is_enabled TINYINT(1)`
- `taousers_tbl`: `userstatus` column with value `'Active'` (not a boolean)
- `fusystemusers`: `sustatus = 'Active'` (string-based status)
- `contactitems`: `itemStatus = 'Active'` (string-based status)

> `TECH-DEBT`: Mixed soft-delete patterns: some tables use `IsDeleted` (bit), some use status strings (`'Active'`/`'Completed'`), some use `is_active`/`is_enabled`. The view-based pattern is effective but makes DDL operations confusing -- ALTER TABLE must target `_tbl`, not the view name.

---

## 9F -- Stored Procedures & Views

### Stored Procedures

| Procedure Name | Defined In | Called From | Purpose |
|---------------|-----------|-------------|---------|
| `sp_update_import_job_counts` | `V2_0__contact_import_staging_tables.sql` | `ContactImportV2Service.cfc` (5 call sites) | Recalculates row counts by status for V2 import jobs |
| `UpdateAudProjects` | **Not defined in codebase** -- exists only in DB | `include/qry/audition.cfm` | Updates audition project aggregate data |
| `sp_CreateShareToken` | `setup/share_module_migration.sql` | `share_module_migration.sql` (test calls only) | Generates unique share tokens |
| `AddIndexIfNotExists` | `V3_2__contact_import_v3_dupe_indexes.sql`, `PRODUCTION_DEPLOY.sql` | Migration scripts only | Utility: creates index if not exists |
| `_add_index_if_missing` | `A1_1__import_auditions_indexes.sql` | Migration scripts only | Utility: creates index if not exists |
| `_drop_index_if_exists` | `A1_1__import_auditions_indexes_ROLLBACK.sql` | Rollback scripts only | Utility: drops index if exists |

**Migration flags:**

- `sp_update_import_job_counts`: Called from application code at runtime
  - `TECH-DEBT: stored procedure called from ContactImportV2Service.cfc -- must have Go equivalent or be inlined`
- `UpdateAudProjects`: Called from application code at runtime, **definition not in repo**
  - `TECH-DEBT: stored procedure called from include/qry/audition.cfm -- definition missing from codebase, must be extracted from DB and migrated`
- `sp_CreateShareToken`: Only called from migration test data, not runtime
- `AddIndexIfNotExists`, `_add_index_if_missing`, `_drop_index_if_exists`: Migration utilities only, not runtime

### Views

| View Name | Defined In | Base Table(s) | Purpose |
|-----------|-----------|---------------|---------|
| `taousers` | `2025-10-19_add_shareid_to_taousers.sql` | `taousers_tbl` | User accounts with `IsDeleted = 0` filter; exposes all columns including `shareID` |
| `contactdetails` | Not in repo (legacy) | `contactdetails_tbl` | Contacts with soft-delete filter |
| `contactitems` | Not in repo (legacy) | `contactitems_tbl` | Contact items with soft-delete filter |
| `fusystemusers` | Not in repo (legacy) | `fusystemusers_tbl` | System enrollments with soft-delete filter |
| `events` | Not in repo (legacy) | `events_tbl` | Events with soft-delete filter |
| `eventcontactsxref` | Not in repo (legacy) | `eventcontactsxref_tbl` | Event-contact xref with soft-delete filter |
| `noteslog` | Not in repo (legacy) | `noteslog_tbl` | Notes with soft-delete filter |
| `actionusers` | Not in repo (legacy) | `actionusers_tbl` | Action users with soft-delete filter |
| `sharez` | `rebuild_sharez_view.sql` | Multiple base tables joined | Complex reporting view for shared contacts |
| `sharezz` | `rebuild_sharez_simple.sql` | Multiple base tables joined | Simplified version of `sharez` -- **this is the one actively queried** |
| `sharez_optimized` | `optimize_sharez_view.sql` | Multiple base tables joined | Performance-optimized version (unclear if deployed) |
| `v_import_jobs_summary` | `V2_0__contact_import_staging_tables.sql` | `import_jobs` | Summary view for V2 import job listing |
| `contacts_ss` | Not in repo (legacy) | Unknown | Contact search/spreadsheet view |
| `contacts_ss_followup` | Not in repo (legacy) | Unknown | Follow-up system contacts |
| `contacts_ss_maint` | Not in repo (legacy) | Unknown | Maintenance system contacts |
| `contacts_ss_target` | Not in repo (legacy) | Unknown | Target system contacts |
| `maxaudition` | Not in repo (legacy) | Unknown | Max audition data (referenced in sharez view comments) |

**Migration flags:**

- `taousers` VIEW: Actively used throughout codebase; queries `taousers` hit the VIEW, writes go to `taousers_tbl`
- `contactdetails` VIEW: Same pattern -- reads from VIEW, writes to `contactdetails_tbl`
- `contactitems` VIEW: Same pattern -- reads from VIEW, writes to `contactitems_tbl`
- `sharezz` VIEW: Actively queried from `share/` module (share.cfm, share_contact_details.cfm, index.cfm, export.cfm)
- `v_import_jobs_summary` VIEW: Referenced in test scripts only; not called from runtime code
- `contacts_ss*` VIEWs: Actively used for contact filtering and lookup
- `maxaudition` VIEW: Referenced in sharez view optimization comments; complex joins

> All views with runtime usage must have equivalents in Go migration. VIEW definitions for `contactdetails`, `contactitems`, `fusystemusers`, `events`, `eventcontactsxref`, `noteslog`, `actionusers`, `contacts_ss*`, and `maxaudition` are **not present in the codebase** and must be extracted from the live database.

---

## 9H -- Transaction Gap Audit

### Files WITH cftransaction (properly wrapped)

| File | Context | Scope |
|------|---------|-------|
| `include/complete_not.cfm` | Notification completion workflow | Multi-step: update notification + update contact + create next notification + update system status |
| `include/complete_not_ajax.cfm` | AJAX notification completion | Same multi-step workflow as above |
| `include/upload_audition.cfm` | Audition file upload + staging | Upload record + staging inserts + date fix |
| `include/remotepaneladd2.cfm` | Panel addition | Panel insert + xref insert |
| `services/ActionUserService.cfc` | Action user delete + recreate | Delete old + insert new action user records |
| `services/ContactDuplicateService.cfc` | Contact merge/duplicate resolution | Multi-table update during merge |
| `services/ContactImportV2Service.cfc` | V2 import finalization | Per-row contact creation with item inserts |
| `services/EventService.cfc` | Event creation with contacts | Event insert + contact xref + optional note |
| `services/SystemUserService.cfc` | System enrollment (3 methods) | Enrollment insert + notification creation |
| `services/RelationshipService.cfc` | Relationship operations (2 methods) | System enrollment + notification scheduling |
| `sched/events_completed.cfm` | Scheduled event completion | Multi-step event + notification processing |
| `sched/appoint-update2.cfm` | Appointment update | Event update + related updates |
| `sched/devtoapp.cfm` | Dev-to-app data sync | Multi-table sync with rollback |
| `sched/extracts*.cfm` | Data extraction jobs | Multi-step extraction |

### Files WITHOUT cftransaction -- Multi-Write Gaps

**HIGH RISK -- Services with multiple write queries and NO transaction wrapping:**

| File | Query Count | Write Operations | Risk |
|------|:----------:|-----------------|------|
| `services/ContactService.cfc` | 235 | INSERT contactdetails + INSERT contactitems + UPDATE contactdetails (in `addContactWithItems`, `createContactFromImport`) | `TECH-DEBT: multi-step write without cftransaction` -- Contact creation writes to contactdetails + contactitems in separate queries |
| `services/ContactItemService.cfc` | 463 | DELETE + INSERT pairs for bulk contact item updates, tag operations | `TECH-DEBT: multi-step write without cftransaction` -- Delete-then-insert patterns for item updates can leave orphan states |
| `services/UserService.cfc` | 143 | UPDATE taousers + SELECT + session refresh in `dateformatpref`, account updates | `TECH-DEBT: multi-step write without cftransaction` -- Update + re-read without atomicity |
| `services/AuditionRoleService.cfc` | 131 | INSERT audroles + UPDATE audprojects + INSERT xref tables | `TECH-DEBT: multi-step write without cftransaction` -- Role creation touches multiple tables |
| `services/AuditionProjectService.cfc` | 234 | INSERT audprojects + INSERT audroles + INSERT xref tables | `TECH-DEBT: multi-step write without cftransaction` -- Project creation is multi-table |
| `services/NoteService.cfc` | 106 | INSERT noteslog in multiple methods (single-query each, lower risk) | Lower risk -- mostly single INSERT per method |
| `services/TicketService.cfc` | 140 | INSERT tickets + UPDATE tickets + INSERT ticketslog | `TECH-DEBT: multi-step write without cftransaction` -- Ticket state changes with log entries |
| `services/NotificationService.cfc` | 155 | INSERT/UPDATE funotifications without wrapping | `TECH-DEBT: multi-step write without cftransaction` -- Notification operations that modify multiple records |
| `services/ReportsRefreshService.cfc` | 253 | Multiple report table writes | `TECH-DEBT: multi-step write without cftransaction` -- Report refresh touches multiple tables |
| `services/ContactImportV3Service.cfc` | 76 | Import finalization writes (rows + facts + results) | `TECH-DEBT: multi-step write without cftransaction` -- V3 finalize should wrap per-row writes |
| `services/TagsUserService.cfc` | 60 | Tag operations across tags_user + contactitems | `TECH-DEBT: multi-step write without cftransaction` |

**HIGH RISK -- Include/endpoint files with multi-write gaps:**

| File | Issue |
|------|-------|
| `include/qry/audition.cfm` | Calls `CALL UpdateAudProjects()` + multiple includes that do DELETE + INSERT without transaction |
| `include/audition-add2.cfm` | Event insert + contact xref insert + note insert without transaction |
| `include/appoint-add2.cfm` | Appointment insert + relationship insert + note insert without transaction |
| `include/account_info.cfm` | UPDATE actionusers_tbl without transaction (single write, lower risk) |
| `include/changestatus.cfm` | Includes update queries conditionally -- depends on included files |
| `admin-calendar-cleanup.cfm` | 6 separate UPDATE events queries without transaction |
| `ipn-handler.cfm` | INSERT thrivecart_tbl -- payment webhook handler (single write but high criticality) |

---

## Schema Files Inventory

### Migration Scripts (database/migrations/)

| Script | Version | Purpose | Has Rollback |
|--------|---------|---------|:------------:|
| `V2_0__contact_import_staging_tables.sql` | V2.0 | Import V2 tables + seed data + SP + VIEW | No |
| `V2_1__import_v2_enhancements.sql` | V2.1 | V2 enhancements | No |
| `V3_0__contact_import_v3_tables.sql` | V3.0 | Import V3 tables (EAV pattern) | Yes |
| `V3_1__feature_flags_tables.sql` | V3.1 | Feature flag tables | Yes |
| `V3_2__contact_import_v3_dupe_indexes.sql` | V3.2 | Duplicate detection indexes | Yes |
| `V3_3__import_v3_columns_add_mapping_fields.sql` | V3.3 | V3 column mapping enhancements | Yes |
| `V3_4__contactitems_valuetext_enlarge.sql` | V3.4 | Enlarge contactitems.valuetext | Yes |
| `A1_0__import_auditions_tables.sql` | A1.0 | Audition import tables | Yes |
| `A1_1__import_auditions_indexes.sql` | A1.1 | Audition import indexes | Yes |
| `A1_2__auditions_import_page_registration.sql` | A1.2 | Page registration for audition import | Yes |

### Standalone Migration Scripts (database/)

| Script | Purpose |
|--------|---------|
| `2025-10-19_add_shareid_to_taousers.sql` | Add shareID to taousers_tbl + rebuild VIEW |
| `2026-02-26_admin_users_pgpages.sql` | Admin user page registrations |
| `2026-02-26_admin_users_plugins.sql` | Admin user plugin registrations |
| `fix_charDescription_length.sql` | Fix character description column length |
| `rebuild_sharez_view.sql` | Rebuild sharez VIEW (optimized) |
| `rebuild_sharez_simple.sql` | Rebuild sharezz VIEW (simplified) |
| `optimize_sharez_view.sql` | Optimized sharez VIEW variant |
| `PRODUCTION_DEPLOY.sql` | Master production deployment script |
| `PRODUCTION_DEPLOY_RUN.sql` | Production deployment runner |
| `WO-2.1_clear_legacy_passwords.sql` | Security: clear legacy plaintext passwords |
| `WO-3.1_prevent_duplicate_enrollments.sql` | Data integrity: prevent duplicate system enrollments |
| `WO-3.2_relationship_diagnostics.sql` | Relationship system diagnostics queries |
| `reset_import_v3_data.sql` | Dev utility: reset V3 import data |

### Other SQL Files

| Script | Path | Purpose |
|--------|------|---------|
| `sql_migration_buyout.sql` | Root | Add buyout column to audprojects |
| `setup/share_module_migration.sql` | Setup | Share module tables + SP |
| `scripts/relationship_system/add_indexes.sql` | Scripts | Performance indexes for relationship tables |
| `scripts/relationship_system/audit_relationship_system.sql` | Scripts | Relationship system audit queries |
| `sql/import_v3_query_audit.sql` | SQL | V3 import query audit |
| `sql/import_v3_query_tests.sql` | SQL | V3 import query tests |
| `tests/sql/test_import_v2_schema.sql` | Tests | V2 schema verification tests |
| `dev/cleanup_proof_test.sql` | Dev | Cleanup proof of concept |

---

## Summary of Critical Findings

### Migration Blockers

1. **Missing VIEW definitions**: The CREATE VIEW statements for `contactdetails`, `contactitems`, `fusystemusers`, `events`, `eventcontactsxref`, `noteslog`, `actionusers`, `contacts_ss`, `contacts_ss_followup`, `contacts_ss_maint`, `contacts_ss_target`, and `maxaudition` are NOT in the codebase. They must be extracted from the live database via `SHOW CREATE VIEW`.

2. **Missing stored procedure definition**: `UpdateAudProjects()` is called at runtime but its definition is not in the codebase. Must be extracted from DB.

3. **Runtime stored procedure dependency**: `sp_update_import_job_counts` is called 5 times from `ContactImportV2Service.cfc`. Must be migrated or inlined.

### Technical Debt

4. **No FK constraints on core tables**: ~13+ implied FK relationships between core business tables (contacts, notifications, systems, events, auditions) have zero declared database-level constraints. Orphan records are a risk.

5. **No timestamps on core tables**: The core schema (contactdetails, contactitems, funotifications, fusystemusers, events, audprojects, etc.) lacks `created_at`/`updated_at` columns entirely.

6. **Transaction gaps in 11+ service files**: Major services (`ContactService`, `ContactItemService`, `AuditionRoleService`, `AuditionProjectService`, `TicketService`, `NotificationService`, `ReportsRefreshService`) perform multi-table writes without `cftransaction` wrapping.

7. **Mixed soft-delete patterns**: Three different patterns coexist: `IsDeleted` bit column + VIEW filter, string status columns (`sustatus = 'Active'`), and boolean `is_active`/`is_enabled`. No unified approach.

8. **Table name typo**: `audessences_audtion_xref` and `audageranges_audtion_xref` contain a typo ("audtion" instead of "audition"). These are legacy and cannot be renamed without migration.

9. **View vs table confusion**: The `_tbl` suffix pattern means DDL must target the base table, but application code reads from the view. The `contactitems` name refers to a VIEW, not a table -- DDL must target `contactitems_tbl`.

### Counts

- **~157** unique tables/views referenced in code
- **~18** tables with proper `created_at`/`updated_at` (all import/feature-flag modules)
- **~8** declared VIEW definitions found in codebase
- **~12+** VIEW definitions missing from codebase (must extract from DB)
- **4** stored procedures with definitions in codebase
- **1** stored procedure (`UpdateAudProjects`) called at runtime with missing definition
- **8** declared FK constraints (all in import subsystem)
- **13+** implied FK relationships without constraints (core business tables)
- **14** files with proper `cftransaction` wrapping
- **11+** service files with multi-write operations lacking `cftransaction`
