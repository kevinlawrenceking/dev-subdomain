# Phase 7 -- Code Quality Audit

Generated: 2026-03-16
Scope: Entire codebase excluding `dev_backup/`

---

## 7A -- Magic Numbers and Strings

Searched for numeric/string literals in cfif conditions and WHERE clauses: `EQ [0-9]+`, `== [0-9]+`, `is "[0-9]+"`, `NEQ [0-9]+`.

### Audit Step IDs (audstepid)

Hardcoded across at least 6 files. The mapping `1=Audition, 2=Callback, 3=Redirect, 4=Pin/Avail, 5=Booking, 999=Direct Booking` appears as raw numbers:

| File | Line(s) | Magic Value | Meaning |
|------|---------|-------------|---------|
| `include/audition.cfm` | 203 | `audstepid is "2"` | Callback |
| `include/audition.cfm` | 210 | `audstepid is "5"` | Booking |
| `include/auditions.cfm` | 386-391 | `is "1"` through `is "999"` | All step types |
| `include/auditions_new.cfm` | 116-121 | `is "1"` through `is "999"` | All step types (duplicate) |
| `services/ReportsRefreshService.cfc` | 269 | `a.audstepid = #report_4_loop.audstepid#` | Unparameterized |

- TECH-DEBT: magic value `audstepid 1-5, 999` in `include/auditions.cfm`, `include/auditions_new.cfm`, `include/audition.cfm`
- :recycle: MERGE CANDIDATE: auditions.cfm and auditions_new.cfm share identical step ID option lists

### Action Link IDs (actionLinkID)

| File | Line(s) | Magic Value | Meaning |
|------|---------|-------------|---------|
| `include/contact_info.cfm` | 471 | `actionLinkID is "2"` | Email link |
| `include/contact_info.cfm` | 477 | `actionLinkID is "6"` | Search link |

- TECH-DEBT: magic value `actionLinkID 2, 6` in `include/contact_info.cfm`

### Page IDs (pgid)

| File | Line(s) | Magic Value | Meaning |
|------|---------|-------------|---------|
| `include/account_info_mobile_code.cfm` | 22-38 | `pgid is "121"`, `"122"`, `"124"`, `"125"` | Page routing |
| `include/contacts_all.cfm` | 148-157 | `pgid is "113"`, `"114"`, `"115"`, `"116"` | Contact page variants |
| `services/PageTitleService.cfc` | 26+ | `case "89"`, `case "113"`, etc. | Page configuration |

- TECH-DEBT: magic value `pgid 89, 113-116, 121-125` across 3+ files. Should be named constants or database-driven.

### Audition Category IDs (audcatid)

| File | Line(s) | Magic Value | Meaning |
|------|---------|-------------|---------|
| `include/audition-add.cfm` | 182 | `new_audcatid IS "5"` | Specific category check |
| `include/aud_role_pane.cfm` | 125 | `audcatid is "5"` and `new_audsubcatid is "34"` | Category + subcategory |
| `include/aud_role_pane.cfm` | 142 | `audcatid is "5" or audcatid is "6"` | Two categories |

- TECH-DEBT: magic value `audcatid 5, 6` and `audsubcatid 34` in `include/audition-add.cfm`, `include/aud_role_pane.cfm`

### Duration IDs (durid)

| File | Line(s) | Magic Value | Meaning |
|------|---------|-------------|---------|
| `include/appoint-add.cfm` | 225 | `durid is "4"` | Default duration selection |
| `include/audition-add.cfm` | 325 | `durid is "4"` | Default duration selection |
| `include/audition-update.cfm` | 172 | `durid is "4"` | Default duration selection |

- TECH-DEBT: magic value `durid 4` in 3 form files. Should be a configurable default.

### Boolean Flag Comparisons

Pervasive pattern of comparing boolean flags as strings: `is "1"`, `is "0"`, `is "Y"`, `is "N"`.

| File | Lines | Pattern |
|------|-------|---------|
| `include/audition.cfm` | 219, 225, 423-488, 507, 522, 529, 562, 974 | `isdirect is "0"`, `isbooked is "1"`, `iscallback is "1"`, etc. |
| `include/auditions.cfm` | 871-877 | `isbooked is "1"`, `ispin is "1"`, etc. |
| `include/add_system.cfm` | 22-28 | `isunique is "1"`, `recordcount is "1"` |

- TECH-DEBT: String-comparison of boolean fields across 20+ files. Use `isBooked` (truthy) instead of `isBooked is "1"`.

### Unparameterized Values in SQL

| File | Line | Issue |
|------|------|-------|
| `services/ReportsRefreshService.cfc` | 269-270 | `a.audstepid = #report_4_loop.audstepid#` and `t.audtypeid = #report_4_loop.new_audtypeid#` -- not using cfqueryparam |
| `include/qry/FIND_222_1.cfm` | 7 | `where userid = #userid#` -- not using cfqueryparam |
| `include/qry/updateContact_72_2.cfm` | 7 | `Where contactid = #contactid#` -- not using cfqueryparam |
| `include/qry/uu_274_2.cfm` | 7 | `where userid = #userid#` -- not using cfqueryparam |
| `include/details.cfm` | 72 | `cfset filter = " and t.#FindKey.fname# = #recid#"` -- dynamic column and value |

- :x: CRITICAL: These unparameterized SQL values remain despite Phase 4+5 security hardening. They were likely missed.

---

## 7B -- Tag vs CFScript Consistency

Audited all 100+ CFC files in `/services/`.

### Overall Finding

The codebase is overwhelmingly **tag-based**. This is consistent and not a problem per se, but there are a few outliers.

### Purely CFScript CFCs (3 files)

| File | Lines | Notes |
|------|-------|-------|
| `AuditionImportService.cfc` | 1,628 | Modern style, queryExecute, response envelopes |
| `ContactImportV3Service.cfc` | 2,995 | Modern style, queryExecute, response envelopes |
| `ImportAuditionsLogger.cfc` | (small) | Logger utility |
| `ImportV3Logger.cfc` | (small) | Logger utility |

These are the newest services, written with modern patterns. They use `queryExecute()` with struct params instead of `<cfquery>` with `<cfqueryparam>`.

### Mixed Tag/CFScript CFCs (2 files)

| File | Tag Elements | CFScript Blocks | Assessment |
|------|-------------|----------------|------------|
| `PageTitleService.cfc` | 4 cffunction tags | 4 cfscript blocks | :x: TECH-DEBT: mixed tag/CFScript in single function -- cffunction wrapper with cfscript body |
| `PaginationService.cfc` | 6 cffunction tags | 4 cfscript blocks | :x: TECH-DEBT: mixed tag/CFScript in single function -- cffunction wrapper with cfscript body |

Both use the pattern of `<cffunction>` wrapper tags with `<cfscript>` blocks inside for logic. This works but creates inconsistency.

### Purely Tag-Based CFCs (95+ files)

All remaining CFCs are purely tag-based using `<cffunction>`, `<cfquery>`, `<cfqueryparam>`, `<cfset>`, `<cfreturn>`.

### Style Divergence Concern

There are now **two distinct coding conventions** in the services layer:
1. **Legacy tag style** (95+ files): `<cffunction>` + `<cfquery>` + `<cfqueryparam>`
2. **Modern script style** (4 files): `component { function() { queryExecute(...) } }`

- :warning: TECH-DEBT: New services (V3 importers) use a completely different coding convention than existing services. A decision should be made on whether new code should follow the legacy convention for consistency or whether to incrementally migrate. Currently the split is 95:4 in favor of tags.

---

## 7C -- Form Validation Location Audit

### Client-Side Validation Framework

TAO uses **Parsley.js** for client-side validation. Found in **80+ form files** under `/include/`.

#### Forms Using Parsley

| File | Form ID | Parsley Config |
|------|---------|---------------|
| `include/audition-add.cfm` | `form-event` | `data-parsley-validate` with per-field `data-parsley-required`, `data-parsley-error-message` |
| `include/appoint-add.cfm` | (unnamed) | `data-parsley-validate` with per-field validation |
| `include/remoteAddContact.cfm` | `profile-form` | `needs-validation` (Bootstrap) + HTML5 `required` |
| Various `remote*.cfm` | multiple | Mix of Parsley + HTML5 required |

#### Forms Using HTML5 `required` Only (no Parsley)

| File | Form | Issue |
|------|------|-------|
| `include/remoteAddContact.cfm` | `profile-form` | Uses `needs-validation` class + `required` attribute, minimal JS validator |
| `include/attachmentadd.cfm` | file upload | HTML5 `required` only |

### Server-Side Validation

#### audition-add2.cfm (form processor)
- Uses `cfparam` for defaults (30+ params).
- **No server-side validation** of required fields. If Parsley is bypassed, empty strings are inserted into the database.
- Sets unscoped page variables from form scope without validation.

#### remoteAddContactAdd.cfm (form processor)
- Uses `cfparam` for defaults.
- **No server-side validation** before `cfinclude template="/include/qry/add_201_1.cfm"`. The insert proceeds with whatever values are in the form scope.

#### appoint-add2.cfm (form processor)
- Has minimal server-side checks: `len(trim(eventStart)) EQ 0` and `len(trim(eventEnd)) EQ 0`.
- Most other fields are not validated server-side.

### Assessment

| Validation Layer | Coverage | Assessment |
|-----------------|----------|------------|
| Client-side (Parsley) | ~80 forms | :warning: Good coverage but bypassable |
| Client-side (HTML5 required) | ~15 forms | :warning: Minimal, easily bypassed |
| Server-side (cfparam + len checks) | ~7 form processors | :x: CRITICAL: Most form processors have NO server-side validation |
| Server-side (service-layer) | Import services only | :white_check_mark: V2/V3 import services validate thoroughly |
| Database constraints | Unknown | :warning: Need to verify NOT NULL constraints on critical columns |

### Specific Findings

- :x: CRITICAL: `include/audition-add2.cfm` -- 0 server-side field validation, 30+ fields go straight to SQL
- :x: CRITICAL: `include/remoteAddContactAdd.cfm` -- 0 server-side validation before INSERT
- :x: CRITICAL: `include/appoint-add2.cfm` -- minimal checks (date only), most fields unchecked
- :warning: Needs review: All `remote*Add*.cfm` and `*-add2.cfm` files should have server-side validation mirroring client-side rules
- :white_check_mark: Clean: `services/ContactImportV2Service.cfc` and `services/ContactImportV3Service.cfc` have thorough validation with per-field error capture

### Duplicated Validation

No cases of validation logic duplicated across multiple server-side files were found -- because server-side validation is nearly absent. The risk is the opposite: validation exists only client-side.

### Inconsistent Error Structures

- Import services return `{success: false, message: "...", errors: []}` -- consistent.
- Legacy form processors use `cflocation` redirects on success with no error handling pattern.
- No consistent error structure for form submission failures.

---

## 7D -- cfinclude Audit (Non-/qry/)

Searched for all cfinclude calls NOT pointing to `/qry/` directories. Categorized by type.

### Dynamic Includes (Security-Sensitive)

| File | Line | Pattern | Risk |
|------|------|---------|------|
| `include/core.cfm` | 41 | `<cfinclude template="#findlinkst.linkurl#">` | :x: CRITICAL -- database-sourced path. Has traversal guard (`find("..")`) but allows any path from DB. |
| `include/core.cfm` | 193 | `<cfinclude template="#findlinksb.linkurl#">` | :x: CRITICAL -- same pattern for bottom links |
| `include/coreb.cfm` | 31, 228 | Same as core.cfm | :x: CRITICAL -- duplicate of core.cfm pattern |
| `include/audition.cfm` | 871 | `<cfinclude template="#includeTemplates[secid]#">` | :warning: Struct-lookup controlled. Keys are hardcoded in a struct (lines 855-868). Lower risk but still dynamic. |
| `include/account_info.cfm` | 173 | `<cfinclude template="#modalData.include#">` | :warning: Variable-sourced path |

### Layout Includes (Scope-Affecting)

These includes inject UI panes and likely set/modify variables scope:

| Category | Files | Count | Assessment |
|----------|-------|-------|------------|
| Pane includes | `*_pane.cfm` files (myteam_pane, mylinks_pane, prefs_pane, etc.) | 25+ | :warning: Each runs queries and sets variables in shared scope |
| Tab includes | `contacts_table.cfm`, `contacts_table_attendees.cfm` | 5+ | :warning: Scope pollution risk |
| Modal includes | `modal.cfm` | 10+ references | :white_check_mark: Likely HTML-only |
| Card includes | `card.cfm`, `card_photo.cfm` | 5+ references | :warning: May set variables |
| BigBrother tracking | `bigbrotherinclude.cfm` | 8+ references | :white_check_mark: Analytics/tracking, low risk |

### Scope-Affecting Includes (High Impact)

| File | Include Target | Concern |
|------|---------------|---------|
| `include/details.cfm` | `rpg_load.cfm` (lines 68, 122) | Sets `rpg_compTable`, `rpg_pgid`, `rpg_compid`, `rpg_compname`, `rpg_pgDir`, `rpg_pgHeading` into calling scope |
| `include/remoteDeleteForm.cfm` | `rpg_load.cfm` | Same scope pollution |
| `include/remoteNewForm.cfm` | `rpg_load.cfm` | Same |
| `include/remoteUpdateForm.cfm` | `rpg_load.cfm` | Same |
| `include/remoteUpdateFormUpdate.cfm` | `rpg_load.cfm` | Same |
| `include/UpdateFormUpdate.cfm` | `rpg_load.cfm` | Same |
| `include/icsmaker.cfm` | `remote_load.cfm` | Similar scope injection |
| `include/remoteheadingupdate.cfm` | `remote_load.cfm` | Similar |

- :warning: `rpg_load.cfm` is included from 7+ files and injects 6+ unscoped variables. Any naming collision would cause silent bugs.

### System/Workflow Includes

| File | Include Target | Purpose | Concern |
|------|---------------|---------|---------|
| `include/complete_not.cfm:288` | `add_system.cfm` | Start maintenance system | Runs queries + sets `add_count`, `systemID`, `suStartDate`, `currentStartDate` in shared scope |
| `include/complete_not_ajax.cfm:312` | `add_system.cfm` | Same | Same scope risk |
| `include/complete_not_batch.cfm:120` | `add_system.cfm` | Same | Same scope risk, now in a loop |
| `include/complete_not_skip.cfm:79` | `add_system.cfm` | Same | Same |

- :x: CRITICAL: `add_system.cfm` is included inside loops in batch processors. It sets unscoped variables (`add_count`, `systemID`, `suStartDate`) that could collide with the calling loop's own variables.

### Relative Path Includes (Non-absolute)

| File | Line | Include | Concern |
|------|------|---------|---------|
| `include/admin-support-update2.cfm` | 35 | `ticketemail.cfm` | Relative path, depends on ColdFusion current directory |
| `include/audition-add2.cfm` | 94 | `modalansweryes.cfm` | Relative path |
| `include/aud_notes_pane.cfm` | 3 | `notes_aud_pane.cfm` | Relative path |
| `include/calendar-appoint.cfm` | 10-19 | 4x relative includes | Relative paths |
| `include/details.cfm` | 68, 77, 122 | `rpg_load.cfm`, `qry/results.cfm` | Relative paths |
| `include/upload_audition.cfm` | 203 | `transfer_audition.cfm` | Relative path |

- :warning: 15+ relative-path includes. These work because files are co-located in `/include/`, but refactoring file locations would break them silently.

### Include Count Summary

| Category | Count | Risk Level |
|----------|-------|------------|
| /include/qry/ (query includes) | 300+ | :warning: Scope pollution (each sets query variables) |
| Layout/pane includes | 25+ | :warning: Scope-affecting |
| Dynamic includes (DB or variable-sourced) | 5 | :x: Security-sensitive |
| rpg_load.cfm (scope injection) | 7+ | :warning: Variable collision risk |
| add_system.cfm (workflow include in loops) | 5 | :x: Scope collision in batch contexts |
| bigbrotherinclude.cfm (tracking) | 8+ | :white_check_mark: Low risk |
| Relative path includes | 15+ | :warning: Fragile on file moves |

---

## Cross-Phase Summary

### Critical Items (Fix Priority)

1. :x: **N+1 in ReportsRefreshService.cfc** -- 15 functions each running 2-3 queries per row. Hoist `findid` out of loops, use batch INSERT. (6A)
2. :x: **No server-side validation** on core form processors: `audition-add2.cfm`, `remoteAddContactAdd.cfm`, `appoint-add2.cfm`. (7C)
3. :x: **Unparameterized SQL** still present in 4+ query files despite Phase 4+5 hardening. (7A)
4. :x: **Dynamic cfinclude from database** in `core.cfm`/`coreb.cfm` -- path traversal guard is minimal. (7D)
5. :x: **Scope collision risk** -- `add_system.cfm` included inside batch loops, sets unscoped variables. (7D + 6D)

### High-Priority Items

6. :warning: **N+1 in contact_info.cfm** -- 2 queries per active system per contact view. (6A)
7. :warning: **Missing query cache** on nav links, event types, reference data. (6B)
8. :warning: **Magic numbers** -- audstepid, pgid, actionLinkID, durid hardcoded in 15+ files. (7A)
9. :warning: **Scope variable hygiene** -- 556+ unscoped cfsets in /include/ alone. (6D)
10. :warning: **Two coding conventions** in services layer (tag vs script). (7B)

### Clean Areas

- :white_check_mark: Query caching where used (share/ pages) is appropriate and safe.
- :white_check_mark: Import V2/V3 services have thorough server-side validation.
- :white_check_mark: DuplicateMatcherService has guardrails (timeouts, ceiling checks) for large datasets.
- :white_check_mark: Tag-based convention is consistent across 95+ of 100+ CFCs.
