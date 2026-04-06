# Phase 6 -- Performance Audit

Generated: 2026-03-16
Scope: Entire codebase excluding `dev_backup/`

---

## 6A -- N+1 Query Detection

Scanned all `cfloop query=` and `for (row in query)` patterns. For each loop body, checked for nested cfquery, queryExecute, cfinclude to /qry/, or service calls that likely query.

### Critical N+1 Patterns (Production-impacting)

#### 1. ReportsRefreshService.cfc -- ALL 15 report functions

Every report function (report_2 through report_18) follows the same anti-pattern: loop over a data query and run a `SELECT r.ID AS new_id FROM reports_user` lookup + an `INSERT INTO reportitems` **per row**.

Report_4 is the worst: it runs **3 queries per row** (findid SELECT, INSERT, a second SELECT + UPDATE).

Files:
- `services/ReportsRefreshService.cfc` lines 48-90, 137-177, 234-297, 342-392, 453-497, 548-592, 643-690, 737-780, 820-870, 909-955, 994-1040, 1080-1125, 1164-1212, 1296-1340

```
report_2:  loop -> findid SELECT + INSERT (2 queries/row)
report_3:  loop -> findid SELECT + INSERT (2 queries/row)
report_4:  loop -> INSERT + Findit SELECT + UPDATE (3 queries/row)
report_5:  loop -> findid SELECT + INSERT (2 queries/row)
report_6:  loop -> findid SELECT + INSERT (2 queries/row)
report_7:  loop -> findid SELECT + INSERT (2 queries/row)
report_8:  loop -> findid SELECT + INSERT (2 queries/row)
report_9:  loop -> findid SELECT + INSERT (2 queries/row)
report_10: loop -> findIdQuery SELECT + INSERT (2 queries/row)
report_11: loop -> findid SELECT + INSERT (2 queries/row)
report_12: loop -> findid SELECT + INSERT (2 queries/row)
report_13: loop -> findid SELECT + INSERT (2 queries/row)
report_17: loop -> findid SELECT + INSERT (2 queries/row)
report_18: loop -> findid SELECT + INSERT (2 queries/row)
```

The `findid` query returns the same result every iteration (it only depends on userid + reportid, which are constants for the loop). This is a pure waste.

- :triangular_flag_on_post: MIGRATE: N+1 query pattern -- `services/ReportsRefreshService.cfc` -- runs 2-3 queries per row across all 15 report functions. Move the `findid` SELECT out of the loop. Replace per-row INSERTs with batch INSERT.

#### 2. RelationshipService.cfc -- startSystemForContact()

- `services/RelationshipService.cfc` lines 302-339
- Loops `getActions` query. Per row: runs `checkUnique` SELECT (if isunique=1) + `insertNotification` INSERT.

- :triangular_flag_on_post: MIGRATE: N+1 query pattern -- `services/RelationshipService.cfc:302` -- runs 1-2 queries per action row in startSystemForContact()

#### 3. ContactImportV2Service.cfc -- createSystemNotifications()

- `services/ContactImportV2Service.cfc` lines 1568-1612
- Loops `qActions` query. Per row: runs `qCheckUnique` SELECT (if isUnique=1) + INSERT.

- :triangular_flag_on_post: MIGRATE: N+1 query pattern -- `services/ContactImportV2Service.cfc:1568` -- runs 1-2 queries per action row in createSystemNotifications()

#### 4. ContactImportV2Service.cfc -- executeImport()

- `services/ContactImportV2Service.cfc` lines 1029-1078
- Loops `qRows` query. Per row: calls `createContactFromRow()` or `updateExistingContact()` (each runs multiple queries) + UPDATE per row. Inside a transaction, but still N+1.

- :triangular_flag_on_post: MIGRATE: N+1 query pattern -- `services/ContactImportV2Service.cfc:1029` -- runs multiple queries per import row in executeImport()

#### 5. NotificationService.cfc -- removenotdups()

- `services/NotificationService.cfc` lines 182-188
- Loops `findDuplicates` query. Per row: runs UPDATE to mark duplicate as deleted.

- :triangular_flag_on_post: MIGRATE: N+1 query pattern -- `services/NotificationService.cfc:182` -- runs 1 UPDATE per duplicate row. Replace with single UPDATE ... WHERE notid IN (SELECT ...) or batch approach.

#### 6. contact_info.cfm -- nested loop over systems and notifications

- `include/contact_info.cfm` lines 453-457
- Loops `sysactive` query. Per row: cfinclude to `/include/qry/notsactive_510_1.cfm` and `/include/qry/notsInactive_510_2.cfm` (2 queries per system). Then inner loop over `notsactive`.

- :triangular_flag_on_post: MIGRATE: N+1 query pattern -- `include/contact_info.cfm:453` -- runs 2 queries per active system for a contact

#### 7. appointments_pane.cfm -- query per appointment row

- `include/appointments_pane.cfm` line 46
- Loops `eventresults.eventresults` query. Per row: cfinclude to `/include/qry/finall_20_1.cfm` (1 query per appointment).

- :triangular_flag_on_post: MIGRATE: N+1 query pattern -- `include/appointments_pane.cfm:46` -- runs 1 query per appointment row via cfinclude

#### 8. complete_not.cfm / complete_not_ajax.cfm / complete_not_batch.cfm -- notification completion loop

- `include/complete_not.cfm` lines 198-221: loops `notsnext`, runs cfinclude `/include/qry/updateNotificationNext.cfm` per row.
- `include/complete_not_ajax.cfm` lines 246-272: same pattern.
- `include/complete_not_batch.cfm` lines 102-105: loops `notsnext`, runs cfinclude per row. Additionally in the outer batch loop, runs multiple cfinclude queries per notification (getNotificationsBySystem, updateNotificationCompleted, checkformaint, etc.).

- :triangular_flag_on_post: MIGRATE: N+1 query pattern -- `include/complete_not_batch.cfm` (outer loop) -- runs 4-6 queries per notification being completed

#### 9. add_system.cfm / AddSystemToContact.cfm -- action loop

- `include/add_system.cfm` lines 18-46: loops `addDaysNo`. Per row: cfinclude to `checkUnique_157_8.cfm` + `addNotification_326_1.cfm`.
- `include/AddSystemToContact.cfm` lines 19-55: same pattern with `addDaysNo_5_2.cfm`, `checkUnique_5_3.cfm`, `addNotification_5_4.cfm`.

- :triangular_flag_on_post: MIGRATE: N+1 query pattern -- `include/add_system.cfm:18` -- runs 1-2 queries per action in system enrollment loop

#### 10. contactfolder_setup.cfm -- nested user+contact loops

- `include/contactfolder_setup.cfm` lines 21-120: loops users (query U), per user runs `C_73_2.cfm` query, then loops all contacts doing filesystem operations.

- :triangular_flag_on_post: MIGRATE: N+1 query pattern -- `include/contactfolder_setup.cfm:21` -- runs 1 query per user to get contacts, then filesystem ops per contact

#### 11. DuplicateMatcherService.cfc -- getCandidateContacts inner loops

- `services/DuplicateMatcherService.cfc` lines 732-863: `getCandidateContactIds` loops `qCandidates` and `qNameMatch` queries with potential nested lookups.

- :warning: Needs review: complex looping in DuplicateMatcherService -- mitigated by in-memory index approach but still generates per-candidate queries in some code paths.

### Summary: N+1 Query Findings

| Severity | File | Pattern | Est. Queries/Request |
|----------|------|---------|---------------------|
| :x: Critical | ReportsRefreshService.cfc | 15 report functions, 2-3 queries/row | 50-500 |
| :x: Critical | complete_not_batch.cfm | 4-6 queries per notification | 20-100 |
| :x: Critical | contact_info.cfm | 2 queries per active system | 10-50 |
| :warning: High | RelationshipService.cfc | 1-2 queries per action | 5-20 |
| :warning: High | ContactImportV2Service.cfc | Multiple per import row | 10-1000 |
| :warning: High | appointments_pane.cfm | 1 query per appointment | 5-50 |
| :warning: Medium | add_system.cfm | 1-2 per action | 3-10 |
| :warning: Medium | NotificationService.cfc | 1 UPDATE per duplicate | 5-50 |

---

## 6B -- Query Caching Audit

Searched entire codebase for `cachedwithin`. Found **very limited** usage:

### Active Cache Instances

| File | Query Name | Cache Duration | Assessment |
|------|-----------|---------------|------------|
| `share/share_contact_details.cfm:189` | qGetContactNotes | 5 minutes | :white_check_mark: Appropriate for shared view |
| `share/share_contact_details.cfm:202` | qGetContactDetail | 10 minutes | :white_check_mark: Appropriate for shared view |
| `share/share_contact_details.cfm:241` | qGetContactEvents | 10 minutes | :white_check_mark: Appropriate for shared view |
| `share/share.cfm:29` | sharesWithEvents | 15 minutes | :white_check_mark: Appropriate for shared view |
| `include/admin-support_optimized.cfm:9` | all_versions | 30 minutes | :white_check_mark: Lookup table, safe to cache |

### User-Specific Data Risk

- All cached queries in `share/` are filtered by share token, not session.userid. Low risk of cross-user data leakage.
- `all_versions` is a global lookup. No user-specific risk.

### Missing Cache Opportunities

The following lookup queries are called on nearly every page load and never change during a session. They should be cached:

| Query / Include | Location | Recommendation |
|----------------|----------|----------------|
| FindLinksT / FindLinksB | `include/core.cfm` lines 29-30 | :warning: Cache for 30+ minutes -- nav links rarely change |
| eventtypes_user | `include/qry/eventtypes_user_443_2.cfm` | :warning: Cache for 10 minutes -- user event types are stable |
| ranges (report date ranges) | `include/qry/ranges_332_1.cfm` | :warning: Cache for 60 minutes -- reference data |
| audcategories, audsubcategories | Various `/include/qry/` files | :warning: Cache for 60 minutes -- reference data |
| countries, regions, timezones | `include/qry/getAllCountries.cfm` etc. | :warning: Cache for 24 hours -- static reference data |

---

## 6C -- Missing Index Candidates

Scanned WHERE, JOIN ON, and ORDER BY columns across all queries in `/include/qry/`, `/services/`, and `/ajax/` directories.

### High-Priority Index Candidates

These columns appear in WHERE clauses across many queries and are likely to benefit from indexes if not already indexed:

#### funotifications table
```
MYSQL: verify index on funotifications.actionid
MYSQL: verify index on funotifications.userid
MYSQL: verify index on funotifications.suid
MYSQL: verify index on funotifications.notstatus
MYSQL: verify index on funotifications.notstartdate
MYSQL: verify index on funotifications.isdeleted
MYSQL: verify composite index on funotifications (userid, notstatus, isdeleted)
MYSQL: verify composite index on funotifications (suid, notstatus)
MYSQL: verify composite index on funotifications (actionid, userid, suid)
```

#### fusystemusers table
```
MYSQL: verify index on fusystemusers.contactid
MYSQL: verify index on fusystemusers.userid
MYSQL: verify index on fusystemusers.systemid
MYSQL: verify index on fusystemusers.sustatus
MYSQL: verify composite index on fusystemusers (contactid, userid, sustatus)
MYSQL: verify composite index on fusystemusers (systemid, sustatus, isdeleted)
```

#### contactdetails table
```
MYSQL: verify index on contactdetails.userid
MYSQL: verify index on contactdetails.isdeleted
MYSQL: verify index on contactdetails.contactfullname
MYSQL: verify composite index on contactdetails (userid, isdeleted)
```

#### contactitems table (via contactitems VIEW -> contactitems_tbl)
```
MYSQL: verify index on contactitems_tbl.contactid
MYSQL: verify index on contactitems_tbl.valueCategory
MYSQL: verify index on contactitems_tbl.itemstatus
MYSQL: verify composite index on contactitems_tbl (contactid, valueCategory, itemstatus)
```

#### audprojects table
```
MYSQL: verify index on audprojects.userid
MYSQL: verify index on audprojects.projdate
MYSQL: verify index on audprojects.isdeleted
MYSQL: verify composite index on audprojects (userid, projdate, isdeleted)
```

#### events table
```
MYSQL: verify index on events.audroleid
MYSQL: verify index on events.isdeleted
MYSQL: verify index on events.audstepid
MYSQL: verify index on events.eventstatus
```

#### audroles table
```
MYSQL: verify index on audroles.audprojectid
MYSQL: verify index on audroles.isdeleted
MYSQL: verify index on audroles.iscallback
MYSQL: verify index on audroles.isbooked
```

#### reports_user table
```
MYSQL: verify composite index on reports_user (userid, reportid)
```

#### reportitems table
```
MYSQL: verify index on reportitems.userid
MYSQL: verify index on reportitems.ID
MYSQL: verify composite index on reportitems (userid, ID)
```

#### import tables
```
MYSQL: verify index on import_job_rows.job_id
MYSQL: verify composite index on import_job_rows (job_id, status)
MYSQL: verify index on import_v3_rows.job_id
MYSQL: verify composite index on import_v3_rows (job_id, status)
MYSQL: verify index on import_auditions_rows.job_id
MYSQL: verify composite index on import_auditions_rows (job_id, status)
```

### ORDER BY Columns Without Likely Indexes
```
MYSQL: verify index on contactdetails.contactfullname (used in ORDER BY across contact lookups)
MYSQL: verify index on contactdetails.recordname (used in ORDER BY in many select lists)
MYSQL: verify index on audprojects.projdate (used in ORDER BY DESC frequently)
```

---

## 6D -- Scope Variable Hygiene

Scanned for `cfset` at page level without explicit scope prefix (`var`, `local.`, `variables.`, `session.`, `application.`, `request.`, `form.`, `url.`).

### Severity: Widespread

Approximately **556+ cfset occurrences** in `/include/` .cfm files alone use unscoped variables. This is systemic across the codebase.

### Worst Offenders

#### audition-add2.cfm (30+ unscoped sets)
```
<cfset modalAnswer = form.modalAnswer />
<cfset CustomPlatform = form.CustomPlatform />
<cfset new_contactid = form.new_contactid />
<cfset new_audStepID = form.new_audStepID />
... (29 more)
```
All of these leak into the `variables` scope of the including page. If any other cfinclude on the same request uses the same variable names, they collide silently.

#### contact_info.cfm
- `<cfset dbugz = "N" />` (line 7) -- unscoped
- `<cfset currentStartDate = ...>` (lines 21-23) -- unscoped, could collide with other includes

#### complete_not.cfm / complete_not_ajax.cfm / complete_not_batch.cfm
- Multiple unscoped cfsets for `new_notstartdate`, `currentStartDate`, etc.
- These pages run via cfinclude chains that share scope.

#### reports.cfm
- `<cfset pgcol=3>` (line 8) -- unscoped
- Multiple cfparam defaults without scope prefix

### High-Risk Collision Scenarios

| Variable Name | Files That Set It (unscoped) | Risk |
|--------------|----------------------------|------|
| `currentStartDate` | contact_info.cfm, complete_not.cfm, complete_not_ajax.cfm, add_system.cfm | :x: High -- shared in cfinclude chains |
| `contactid` / `currentid` | remoteAddContactAdd.cfm, many /include/ files | :x: High -- central variable set without scope |
| `new_contactid` | audition-add2.cfm, appoint-add2.cfm, appoint-update2.cfm | :warning: Medium -- form processors |
| `userid` | audition-add2.cfm, multiple /include/ files | :x: High -- could mask session.userid |
| `dsn` | get_notifications.cfm, get_reminders.cfm | :warning: Medium -- per-request but unscoped |
| `dbug` / `dbugz` | contact_info.cfm, contactfolder_setup.cfm, complete_not.cfm | :warning: Low -- debug flags |

### Recommendation

- :x: CRITICAL: Audit all cfset statements in form-processing pages (`*2.cfm` pattern) for scope collisions.
- :warning: All cfinclude-chain variables should use `local.` or `variables.` prefix to prevent silent overwrites.
- A codemod pass adding `variables.` prefix to all page-level cfsets would be the safest incremental fix.
