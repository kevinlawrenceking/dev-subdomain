# TAO Contact Data Model Reference
Consolidated from: docs/contacts/

---

# TAO 1.0 Contacts Module - Complete Table Map

**Generated:** 2025-11-30
**Purpose:** Migration documentation for TAO 2.0
**Scope:** All database tables used by the contacts module

---

## CRITICAL DISCOVERY: Views vs Base Tables

**TAO 1.0 uses a dual-table architecture:**

- **Base tables:** Suffix `_tbl` (e.g., `contactdetails_tbl`, `contactitems_tbl`)
- **Views:** No suffix (e.g., `contactdetails`, `contactitems`)
- **View filter:** All views add `WHERE IsDeleted <> 1` automatically

**Implication for migration:**
- ColdFusion code references VIEWS (no suffix) via datasource
- SQL scripts reference BASE TABLES (with `_tbl` suffix)
- Indexes must be created on BASE TABLES, not views
- IsDeleted casing varies: `isdeleted` (ColdFusion) vs `IsDeleted` (SQL)

---

## TABLE OF CONTENTS

1. [Core Contact Tables](#1-core-contact-tables)
2. [Junction/Link Tables](#2-junctionlink-tables)
3. [Import/Staging Tables](#3-importstaging-tables)
4. [Lookup/Metadata Tables](#4-lookupmetadata-tables)
5. [Contact Views (Summary/Performance)](#5-contact-views-summaryperformance)
6. [Related Module Tables](#6-related-module-tables)

---

## 1. CORE CONTACT TABLES

### contactdetails / contactdetails_tbl

**Purpose:**
Master record for each contact. Stores contact identity, profile, meeting history, and feature flags.

**Columns used in code:**

| Column | Type | Usage | Files Referencing |
|--------|------|-------|-------------------|
| `contactid` | int (PK) | Primary key, referenced everywhere | All 145+ contact files |
| `userid` | int (FK) | Owner of contact, ALWAYS filtered | All queries (required) |
| `contactFullName` | varchar | Primary display name, search target | ContactService.cfc:84, 198; contacts_ss view; include/contacts.cfm; 100+ files |
| `recordname` | varchar | Alternative/professional name | ContactService.cfc:85; contacts_ss view (col1); include/contact_info.cfm |
| `contacttitle` | varchar | Professional title | ContactService.cfc:84; include/contact_info.cfm:127 |
| `contactNickname` | varchar | Informal name | ContactService.cfc:86; include/contact_info.cfm:142 |
| `contactBirthday` | date | Birthday for reminders | BirthdayService.cfc; ContactService.cfc:87; sched/birthday_fix.cfm |
| `contactMeetingDate` | date | First meeting date | ContactService.cfc:88; sharez view:39; include/contact_info.cfm:189 |
| `contactMeetingLoc` | varchar | Where first met | ContactService.cfc:89; sharez view:38; include/contact_info.cfm:201 |
| `contactPronoun` | varchar | He/She/They/Custom | ContactService.cfc:90; include/contact_info.cfm:156 |
| `refer_contact_id` | int (FK) | Self-referencing FK - who referred | ContactService.cfc:91; include/qry/contact_info.cfm:8 (self-join) |
| `contactStatus` | varchar | Active/Inactive | ContactService.cfc:92, 203; include/contacts.cfm (filter) |
| `contactCreationDate` | datetime | Audit trail | ContactService.cfc:94; reports |
| `contactLastUpdated` | datetime | Audit trail | ContactService.cfc:95; reports |
| `contactphoto` | varchar | Avatar file path | ContactService.cfc:96; include/image-upload-contact.cfm; sched/avatar_loop.cfm |
| `user_yn` | char(1) | Y/N - Is this the user's own contact? | ContactService.cfc:97; sched/user_setup.cfm |
| `newsletter_yn` | char(1) | Y/N - Subscribe to newsletters | ContactService.cfc:98; include/contact_info.cfm:233 |
| `googlealert_yn` | char(1) | Y/N - Set up Google alerts | ContactService.cfc:99; include/contact_info.cfm:245 |
| `socialmedia_yn` | char(1) | Y/N - Track social media | ContactService.cfc:100; include/contact_info.cfm:257 |
| `isdeleted` | bit | Soft delete flag | ContactService.cfc:101, 184; all views; all queries (WHERE isdeleted = 0) |

**Columns NOT used anywhere:**

| Column | Notes |
|--------|-------|
| `cdco` | LEGACY company field (replaced by contactitems valueCategory='Company') - Still has ONE reference in deprecated code: include/qry/Insert_159_13.cfm:5 |

**Tables it joins with:**

| Table | Join Type | Purpose | Files |
|-------|-----------|---------|-------|
| contactitems | 1:Many | Contact metadata (emails, phones, etc.) | contacts_ss view; ContactService.cfc; 98+ files |
| fusystemusers | 1:Many | Relationship systems for contact | sharez view; ContactService.cfc:ru(); include/contacts.cfm |
| eventcontactsxref | 1:Many | Events contact attended | EventService.cfc; sharez view |
| audcontacts_auditions_xref | 1:Many | Auditions linked to contact | AuditionProjectService.cfc; sharez view |
| noteslog | 1:Many | Notes about contact | NoteService.cfc; include/notes_event_pane.cfm |
| taousers | Many:1 | Contact owner | sharez view:48; all queries filter by userid |
| contactdetails (self) | Self-join | Referral tracking (refer_contact_id) | include/qry/contact_info.cfm:8 |

**Notes / oddities:**

- **Dual naming:** `contactdetails_tbl` (base table) vs `contactdetails` (view with IsDeleted filter)
- **IsDeleted casing inconsistency:** ColdFusion uses lowercase `isdeleted`, SQL uses `IsDeleted`
- **cdco column:** Should be fully migrated to contactitems and removed
- **user_yn flag:** Creates circular reference - user IS a contact in their own system
- **No hard delete:** All deletes are soft (isdeleted = 1)
- **contactStatus values:** Not enforced by DB constraint - application logic only
- **contactPronoun:** Supports "Custom" - actual value stored in separate field (not visible in service code)

---

### contactitems / contactitems_tbl

**Purpose:**
Entity-Attribute-Value (EAV) table storing ALL flexible contact metadata: emails, phones, addresses, companies, tags, social profiles, URLs, etc. Allows unlimited items per contact.

**Columns used in code:**

| Column | Type | Usage | Files Referencing |
|--------|------|-------|-------------------|
| `itemid` | int (PK) | Primary key | ContactItemService.cfc:81; all item queries; include/contact_info.cfm |
| `contactid` | int (FK) | Links to contactdetails | All 98+ files; ContactItemService.cfc:104 |
| `valueType` | varchar | Specific type within category | ContactItemService.cfc:82; include/remoteaddC.cfm:51; 50+ files |
| `valueCategory` | varchar | High-level category | ContactItemService.cfc:83; include/remoteaddC.cfm:37; 50+ files |
| `valuetext` | varchar | Primary text value (emails, phones, tags, URLs) | ContactItemService.cfc:84; contacts_ss view; 80+ files |
| `valueCompany` | varchar | Company name (ONLY for valueCategory='Company') | ContactItemService.cfc:85; sharez view:35; include/contact_info.cfm |
| `valueDepartment` | varchar | Department (ONLY for valueCategory='Company') | ContactItemService.cfc:86; include/remoteaddC.cfm |
| `valueTitle` | varchar | Job title (ONLY for valueCategory='Company') | ContactItemService.cfc:87; include/remoteaddC.cfm |
| `valueStreetAddress` | varchar | Street (ONLY for valueCategory='Address') | ContactItemService.cfc:88; include/remoteaddC.cfm |
| `valueExtendedAddress` | varchar | Apt/Suite (ONLY for valueCategory='Address') | ContactItemService.cfc:89; include/remoteaddC.cfm |
| `valueCity` | varchar | City (ONLY for valueCategory='Address') | ContactItemService.cfc:90; include/remoteaddC.cfm |
| `valueRegion` | varchar | State/Province (ONLY for valueCategory='Address') | ContactItemService.cfc:91; include/remoteaddC.cfm |
| `valueCountry` | varchar | Country (ONLY for valueCategory='Address') | ContactItemService.cfc:97; include/remoteaddC.cfm |
| `valuePostalCode` | varchar | Zip/Postal (ONLY for valueCategory='Address') | ContactItemService.cfc:100; include/remoteaddC.cfm |
| `itemDate` | date | Date associated with item (rarely used) | ContactItemService.cfc:92; defined but seldom populated |
| `itemNotes` | text | Notes about item (rarely used) | ContactItemService.cfc:93; defined but seldom populated |
| `itemStatus` | varchar | Active/Pending/Inactive | ContactItemService.cfc:94, 106; all queries filter Active |
| `primary_yn` | char(1) | Y/N - Is this primary in category? | ContactItemService.cfc:101; contacts_ss view (uses for first email/phone) |
| `itemCreationDate` | datetime | Audit trail | ContactItemService.cfc:95 |
| `itemLastUpdated` | datetime | Audit trail | ContactItemService.cfc:96 |
| `isDeleted` | bit | Soft delete flag | All queries; ContactItemService.deleteTeam:67 |

**Columns NOT used anywhere:**

_None identified - all columns have active usage_

**Tables it joins with:**

| Table | Join Type | Purpose | Files |
|-------|-----------|---------|-------|
| contactdetails | Many:1 | Parent contact | All 98+ files |
| itemcategory | Many:1 | Category metadata (icon, fieldset) | ContactItemService.cfc:103; include/qry/itemsbycatActive.cfm |
| itemtypes_user | Many:1 (optional) | User-customized types (social media) | ContactItemService.getSocialIcons(); include/remoteaddC.cfm |
| tags_user | Filter join | Determine if tag is Casting Director | ContactItemService.cfc:9-21 (getContactTagStatus) |

**Notes / oddities:**

- **EAV flexibility:** valueCategory determines which value* fields are used
  - `Email/Phone/URL/Tag` → use `valuetext` only
  - `Company` → uses `valueCompany`, `valueDepartment`, `valueTitle` (NOT valuetext)
  - `Address` → uses 6 address fields (`valueStreetAddress`, `valueExtendedAddress`, `valueCity`, `valueRegion`, `valueCountry`, `valuePostalCode`)
- **Primary enforcement:** No database constraint - app enforces one `primary_yn='Y'` per category per contact
- **itemStatus values:** 'Active', 'Pending', 'Inactive' - no DB constraint
- **valueType casing:** Inconsistent ('Mobile' vs 'mobile') - needs standardization
- **Tag length:** Application truncates to 40 chars: `LEFT(tagname, 40)` in queries
- **Performance:** Requires many JOINs to assemble full contact view - hence contacts_ss view optimization
- **IsDeleted vs isDeleted:** Same casing issue as contactdetails

---

## 2. JUNCTION/LINK TABLES

### audcontacts_auditions_xref

**Purpose:**
Links contacts (typically casting directors) to audition projects. Tracks which contacts are associated with specific auditions.

**Columns used in code:**

| Column | Type | Usage | Files Referencing |
|--------|------|-------|-------------------|
| `contactid` | int (FK) | Links to contactdetails | ContactItemService.cfc:59; ContactAuditionService.cfc; 20+ files |
| `audprojectid` | int (FK) | Links to audprojects | ContactItemService.cfc:60; AuditionProjectService.cfc; AuditionRoleService.cfc |
| `xrefnotes` | text | Notes about contact's involvement | AuditionProjectService.cfc; include/qry/add_aud_contact.cfm |

**Columns NOT used anywhere:**

_Unable to determine - no full schema available in code. Likely has PK/audit columns not visible in queries._

**Tables it joins with:**

| Table | Join Type | Purpose | Files |
|-------|-----------|---------|-------|
| contactdetails | Many:1 | Contact being linked | AuditionProjectService.cfc; sharez view |
| audprojects | Many:1 | Audition project | AuditionProjectService.cfc |
| events | Many:1 (via audRoleID) | Audition events | sharez view:59-68 (maxaudition subquery) |
| audsteps | Many:1 (via events) | Audition step tracking | sharez view:60 |

**Notes / oddities:**

- **No soft delete visible:** Queries do not filter by IsDeleted on this table
- **Service:** ContactAuditionService.cfc handles CRUD
- **Delete operation:** ContactItemService.deleteAudContact() does HARD delete (not soft)
- **Usage pattern:** Primarily for casting director tracking on projects

---

### eventcontactsxref / eventcontactsxref_tbl

**Purpose:**
Links contacts to events/appointments. Tracks which contacts attended or participated in meetings.

**Columns used in code:**

| Column | Type | Usage | Files Referencing |
|--------|------|-------|-------------------|
| `contactid` | int (FK) | Links to contactdetails | EventContactsXRefService.cfc; sharez view:81, 89 |
| `eventid` | int (FK) | Links to events | EventContactsXRefService.cfc; sharez view:90 |
| `IsDeleted` | bit | Soft delete flag | sharez view:82, 91 (filtered in aggregations) |

**Columns NOT used anywhere:**

_Unable to determine - likely has PK/audit columns not visible in queries._

**Tables it joins with:**

| Table | Join Type | Purpose | Files |
|-------|-----------|---------|-------|
| contactdetails | Many:1 | Contact who attended | EventService.cfc; ContactService.cfc |
| events | Many:1 | Event attended | EventService.cfc; sharez view |

**Notes / oddities:**

- **Dual naming:** `eventcontactsxref_tbl` (base) vs `eventcontactsxref` (view)
- **Used in aggregations:** sharez view counts meetings: `COUNT(*)` grouped by contactid
- **Last event tracking:** sharez view uses window function (ROW_NUMBER) to find most recent event per contact
- **Service:** EventContactsXRefService.cfc handles CRUD
- **Soft delete:** Uses `IsDeleted <> 1` filter in sharez view

---

## 3. IMPORT/STAGING TABLES

### contactsimport / CONTACTSIMPORT

**Purpose:**
Staging table for contact imports. Holds CSV data during validation, duplicate detection, and user review before committing to contactdetails.

**Columns used in code:**

| Column | Type | Usage | Files Referencing |
|--------|------|-------|-------------------|
| `id` | int (PK) | Primary key for import row | ContactImportService.cfc |
| `contactid` | int (FK) | Populated after match/create | ContactImportService.cfc; include/import-contacts.cfm |
| `uploadid` | varchar/int | Groups rows by upload session | ContactImportService.cfc; include/import-contacts.cfm |
| `status` | varchar | 'Added', 'Duplicate', 'Error', 'Pending' | ContactImportService.cfc; include/import-contacts.cfm |
| _(CSV columns)_ | various | First Name, Last Name, Email, Phone, Company, Address fields, Birthday, Meeting Date, Tags | ContactImportService.cfc; ContactImportValidationService.cfc |

**Columns NOT used anywhere:**

_Dynamic based on CSV upload - columns created to match import template_

**Tables it joins with:**

| Table | Join Type | Purpose | Files |
|-------|-----------|---------|-------|
| contactdetails | 1:1 (after import) | Links to created/matched contact | ContactImportService.cfc |
| contactitems | 1:Many (after import) | Email used for duplicate detection | ContactImportValidationService.cfc |

**Notes / oddities:**

- **Temporary table:** Should be archived/purged after successful import
- **Duplicate detection:** Matches on (First Name + Last Name) OR (Email address)
- **Status flow:** Pending → Validation → User Review → Added/Duplicate/Error
- **No standard schema:** Columns depend on import template
- **Archive recommendation:** Move completed imports to contact_import_log

---

### contact_import_log

**Purpose:**
Audit trail for contact imports. Tracks when imports occurred, who performed them, and results.

**Created:** 2025-11-26 (database/2025-11-26_create_contact_import_log.sql)

**Columns defined in schema:**

| Column | Type | Purpose |
|--------|------|---------|
| _(Unknown - file not read)_ | - | Audit fields for import tracking |

**Tables it joins with:**

_Not yet integrated - new table_

**Notes / oddities:**

- **New addition:** Created specifically for TAO 2.0 migration planning
- **Purpose:** Replace indefinite growth of contactsimport table
- **Recommendation:** Archive contactsimport rows here after X days

---

## 4. LOOKUP/METADATA TABLES

### itemcategory

**Purpose:**
Defines available contact item categories (Email, Phone, Address, Company, Tag, Social Profile, etc.). Provides metadata like icons, fieldset types, and display order.

**Columns used in code:**

| Column | Type | Usage | Files Referencing |
|--------|------|-------|-------------------|
| `catid` | int (PK) | Primary key | ContactItemService.cfc:129; include/contact_info.cfm |
| `valueCategory` | varchar | Category name (Email, Phone, etc.) | ContactItemService.cfc:126, 130; itemcategory JOIN in all item queries |
| `recordname` | varchar | Display name | ContactItemService.cfc (implied in UNION queries) |
| `caticon` | varchar | Icon CSS class (fe-phone, fe-mail, etc.) | ContactItemService.cfc:127, 99; include/contact_pane.cfm |
| `catfieldset` | varchar | 'text', 'address', 'company' - determines which fields to show | ContactItemService.cfc:98, 128; include/remoteaddC.cfm (form logic) |
| `catOrder` | int | Display order | ContactItemService.cfc:130; ORDER BY finalorder |
| `catArea_UCB` | char(1) | 'B' (both), 'U' (user), 'C' (contact) - applicability | ContactItemService.cfc:108; include/qry/itemsbycatActive.cfm:7 |
| `catSelectList` | varchar | (Usage unclear from code) | Defined but not referenced in scanned files |

**Columns NOT used anywhere:**

| Column | Notes |
|--------|-------|
| `catSelectList` | Defined but no references found |

**Tables it joins with:**

| Table | Join Type | Purpose | Files |
|-------|-----------|---------|-------|
| contactitems | 1:Many | Provides metadata for each item | ContactItemService.cfc:103; all itemsbycatActive queries |

**Notes / oddities:**

- **UNION with 'Relationship':** ContactItemService adds synthetic 'Relationship' category in queries (line 123)
- **catfieldset determines UI:** 'text' → single field, 'address' → 6 fields, 'company' → 3 fields
- **Tag exclusion:** Many queries exclude `valuecategory <> 'Tag'` (tags handled separately)
- **catArea_UCB filter:** Ensures items meant for Users don't show on Contacts and vice versa

---

### itemtypes / itemtypes_tbl

**Purpose:**
Master list of item types. Defines available valueType values and their icons (deprecated in favor of itemtypes_user).

**Columns used in code:**

| Column | Type | Usage | Files Referencing |
|--------|------|-------|-------------------|
| `valueType` | varchar (PK?) | Type name | include/qry/remoteUpdateC.cfm:46 |
| `typeIcon` | varchar | Icon CSS class | include/qry/remoteUpdateC.cfm (implied) |

**Columns NOT used anywhere:**

_Unable to determine - limited references in code_

**Tables it joins with:**

| Table | Join Type | Purpose | Files |
|-------|-----------|---------|-------|
| contactitems | 1:Many | Defines available types | include/remoteUpdateC.cfm (dropdown) |

**Notes / oddities:**

- **Deprecated usage:** Most type handling moved to itemtypes_user for customization
- **Limited references:** Only appears in legacy query files

---

### itemtypes_user

**Purpose:**
User-specific customization of item types. Allows users to define which social media profiles, acting links, etc. they want to track, with custom icons.

**Columns used in code:**

| Column | Type | Usage | Files Referencing |
|--------|------|-------|-------------------|
| `userid` | int (FK) | Links to taousers | ItemTypesUserService.cfc |
| `valueType` | varchar | Custom type name (Facebook, Twitter, IMDb, etc.) | include/remoteaddC.cfm:53; ContactItemService.getSocialIcons() |
| `typeIcon` | varchar | Icon CSS class | ContactItemService.getSocialIcons(); include/contact_pane.cfm |
| `typeid` | int (PK?) | Primary key | ItemTypesUserService.cfc |

**Columns NOT used anywhere:**

_Unable to determine - service file not fully scanned_

**Tables it joins with:**

| Table | Join Type | Purpose | Files |
|-------|-----------|---------|-------|
| contactitems | 1:Many | Provides custom types for Social Profile, Acting Links | include/remoteaddC.cfm (dropdown population) |
| taousers | Many:1 | User ownership | ItemTypesUserService.cfc |

**Notes / oddities:**

- **User customization:** Each user can define their own social media types to track
- **Icon support:** Allows custom icon CSS classes (fe-facebook, fe-twitter, etc.)
- **Used for:** Social Profile, Acting Links, Profile categories

---

### tags / tags_user

**Purpose:**
Define tags and their behavior. Determines which tags trigger "Casting Director" vs "Industry" relationship workflows.

**Columns used in code (tags_user):**

| Column | Type | Usage | Files Referencing |
|--------|------|-------|-------------------|
| `userid` | int (FK) | Links to taousers | ContactItemService.cfc:18; TagsUserService.cfc |
| `tagname` | varchar | Tag name | ContactItemService.cfc:16; include/qry/contacts.cfm |
| `tagtype` | char(1) | 'C' = Casting Director tag | ContactItemService.cfc:19 (WHERE tagtype = 'C') |
| `IsCasting` | bit | Is this a casting director tag? | TagsUserService.cfc (implied) |

**Columns NOT used anywhere:**

_Unable to determine - service file not fully scanned_

**Tables it joins with:**

| Table | Join Type | Purpose | Files |
|-------|-----------|---------|-------|
| contactitems | Filter join | Determine if contact has CD tag | ContactItemService.getContactTagStatus():15-20 |
| taousers | Many:1 | User ownership | TagsUserService.cfc |

**Notes / oddities:**

- **Critical business logic:** tagtype='C' determines relationship system workflow
- **Tag truncation:** Queries use `LEFT(tagname, 40)` - enforces 40-char limit
- **Special tags:**
  - 'My Team' - adds to team view
  - Casting Director tags - trigger different system actions
- **IsCasting vs tagtype:** Appears to be redundant - needs clarification

---

## 5. CONTACT VIEWS (SUMMARY/PERFORMANCE)

### contacts_ss

**Purpose:**
Performance optimization view. Pre-joins contactdetails + contactitems to provide fast contact list rendering. Used extensively throughout the application.

**Structure (inferred from usage):**

| Column | Source | Usage | Files Referencing |
|--------|--------|-------|-------------------|
| `contactid` | contactdetails.contactid | Primary key | All list views; ContactSSService.cfc |
| `userid` | contactdetails.userid | Filter | All queries |
| `col1` | contactFullName OR recordname | Display name | include/contacts.cfm; contacts_table.cfm; 14+ files |
| `col2` | (tags - aggregated?) | Tags display | include/contacts.cfm |
| `col2b` | (unknown) | Unknown | Defined but usage unclear |
| `col3` | First active phone (valuetext) | Phone display | include/contacts_table.cfm |
| `col4` | First active email (valuetext) | Email display | include/contacts_table.cfm |
| `col5` | First active company (valueCompany) | Company display | include/contacts_table.cfm |
| `hlink` | Computed link to contact detail | Click-through | include/contacts_table.cfm |
| `avatar` | contactphoto | Photo path | include/contacts_table.cfm |

**Tables it joins:**

- contactdetails (main)
- contactitems (for col3, col4, col5 - first email/phone/company)

**Files referencing (14+ total):**

- ContactSSService.cfc (service layer)
- include/contacts.cfm, contacts_all.cfm, contacts_all_tabs.cfm (main lists)
- include/contacts_table.cfm, contacts_grid.cfm (layouts)
- include/contacts_ss.cfm (dedicated view page)
- ContactItemService.addTeam():48 (uses col1 for team lookup)
- Multiple AJAX/lookup files

**Notes / oddities:**

- **Performance critical:** Avoids repeated JOINs on contactitems for every list row
- **col naming:** Cryptic column names (col1, col2, col3...) - should be aliased in TAO 2.0
- **First item logic:** Uses subqueries or window functions to get "first" email/phone/company where primary_yn='Y'
- **View definition not in code:** Actual SQL CREATE VIEW not found in scanned files - likely in database directly

---

### contacts_ss_target

**Purpose:**
Filtered view of contacts currently in the "Targeting" relationship system.

**Structure:**
Joins `contacts_ss` + `fusystemusers` WHERE `systemtype = 'Targeting'` AND `suStatus = 'Active'`

**Files referencing:**

- include/contacts.cfm (tab filter)
- include/contacts_all_tabs.cfm

**Notes / oddities:**

- **Filter view:** Same columns as contacts_ss, just filtered by system
- **Performance:** Reduces app-level filtering by pre-filtering at DB level

---

### contacts_ss_followup

**Purpose:**
Filtered view of contacts currently in the "Follow-Up" relationship system.

**Structure:**
Joins `contacts_ss` + `fusystemusers` WHERE `systemtype = 'Follow-Up'` AND `suStatus = 'Active'`

**Files referencing:**

- include/contacts.cfm (tab filter)
- include/contacts_all_tabs.cfm

**Notes / oddities:**

- Same as contacts_ss_target, different system filter

---

### contacts_ss_maint

**Purpose:**
Filtered view of contacts currently in the "Maintenance" relationship system.

**Structure:**
Joins `contacts_ss` + `fusystemusers` WHERE `systemtype = 'Maintenance'` AND `suStatus = 'Active'`

**Files referencing:**

- include/contacts.cfm (tab filter)
- include/contacts_all_tabs.cfm

**Notes / oddities:**

- Same as contacts_ss_target, different system filter

---

### sharez

**Purpose:**
Complex view joining contacts with relationship systems, events, auditions, and notes. Used for sharing contact info and advanced reporting.

**Structure (from database/rebuild_sharez_view.sql):**

| Column | Source | Purpose |
|--------|--------|---------|
| `contactid` | contactdetails_tbl.contactID | Primary key |
| `NAME` | contactdetails_tbl.recordname | Contact name |
| `Company` | contactitems_tbl.valueCompany (WHERE valueCategory='Company') | Company |
| `Title` | contactitems_tbl.valueText (WHERE valueCategory='Tag') | Title from tags |
| `Audition` | audsteps.audstep (via complex subquery) | Last audition step |
| `WhereMet` | contactdetails_tbl.contactMeetingLoc | Meeting location |
| `WhenMet` | contactdetails_tbl.contactMeetingDate | Meeting date |
| `NotesLog` | NULL (removed GROUP_CONCAT for performance) | Notes - retrieve separately |
| `userid` | taousers_tbl.userID | User owner |
| `userHash` | LEFT(taousers_tbl.passwordHash, 10) | User identifier |
| `last_met` | events_tbl.eventStart (via ROW_NUMBER window) | Last event date |
| `no_mtgs` | COUNT from eventcontactsxref_tbl | Meeting count |
| `lasteventtype` | events_tbl.eventTypeName | Last event type |

**Tables it joins:**

- contactdetails_tbl (main)
- taousers_tbl (user)
- fusystemusers_tbl (filter - only contacts IN systems)
- contactitems_tbl (company, tags)
- audcontacts_auditions_xref (auditions)
- events_tbl (last audition step, last event)
- audsteps (audition progression)
- eventcontactsxref_tbl (meeting counts, last event)

**Files referencing:**

- ShareService.cfc
- share/contact.cfm
- share/remoteShareViewC.cfm
- database/optimize_sharez_view.sql (performance optimization script)

**Notes / oddities:**

- **3-level view nesting:** sharez → views (contactdetails, events, etc.) → base tables (_tbl)
  - **Critical performance issue** - must optimize by querying base tables directly
- **GROUP_CONCAT removed:** Originally aggregated notes, now returns NULL (performance killer)
- **Window function:** Uses ROW_NUMBER for last event (MySQL 8.0+ required)
- **Complex maxaudition:** Nested subqueries to find highest audition step per contact
- **Filter enforced:** Only contacts with `fusystemusers.suStatus = 'Active'` AND `systemID IN (1,2,3,4)`
- **Optimization script:** database/rebuild_sharez_view.sql rewrites to query base tables directly
- **Materialized table option:** Script includes commented-out sharez_cache table for best performance

---

## 6. RELATED MODULE TABLES

### noteslog / noteslog_tbl

**Purpose:**
Stores notes for contacts, events, and auditions. Rich text support (HTML + plain text).

**Columns used in code:**

| Column | Type | Usage | Files Referencing |
|--------|------|-------|-------------------|
| `noteid` | int (PK) | Primary key | NoteService.cfc |
| `userid` | int (FK) | Note author | NoteService.cfc |
| `contactid` | int (FK) | 0 if not contact-specific | NoteService.cfc; include/notes_event_pane.cfm |
| `eventid` | int (FK) | If note tied to event | NoteService.cfc |
| `audprojectid` | int (FK) | If note tied to audition | NoteService.cfc |
| `noteDetails` | text | Plain text version (max 2000 chars) | NoteService.cfc; include/notes_event_pane.cfm |
| `notedetailshtml` | text | Rich text HTML version | NoteService.cfc |
| `isPublic` | bit | Share with team? | NoteService.cfc |
| `notetimestamp` | datetime | When created | NoteService.cfc |
| `isdeleted` | bit | Soft delete | NoteService.cfc |

**Columns NOT used anywhere:**

_Unable to determine - service not fully scanned_

**Tables it joins with:**

| Table | Join Type | Purpose | Files |
|-------|-----------|---------|-------|
| contactdetails | Many:1 (optional) | Contact note is about | NoteService.cfc |
| events | Many:1 (optional) | Event note is about | NoteService.cfc |
| audprojects | Many:1 (optional) | Audition note is about | NoteService.cfc |
| taousers | Many:1 | Note author | NoteService.cfc |

**Notes / oddities:**

- **Multi-purpose:** Notes can be for contacts, events, auditions, or standalone
- **contactid = 0:** Indicates note not tied to specific contact
- **HTML + plain text:** Stores both formats for display flexibility
- **2000 char limit:** noteDetails truncated (notedetailshtml has no limit)
- **sharez view originally included:** GROUP_CONCAT of notes removed for performance

---

### fusystemusers / fusystemusers_tbl

**Purpose:**
Relationship system instances. Links contacts to Targeting/Follow-Up/Maintenance systems with per-contact state.

**Columns referenced in contact module:**

| Column | Type | Usage | Files Referencing |
|--------|------|-------|-------------------|
| `contactid` | int (FK) | Links to contactdetails | sharez view:49; ContactService.ru(); include/contacts.cfm |
| `userid` | int (FK) | System owner | sharez view:50 |
| `suStatus` | varchar | 'Active', 'Completed', 'Skipped' | sharez view:51 (WHERE suStatus='Active') |
| `systemID` | int (FK) | Links to fusystems | sharez view:52 (WHERE systemID IN (1,2,3,4)) |
| `systemtype` | varchar | 'Targeting', 'Follow-Up', 'Maintenance' | contacts_ss_target/followup/maint views (filter) |
| `IsDeleted` | bit | Soft delete | sharez view:53 |

**Columns NOT used in contact context:**

_Many - fusystemusers has 20+ columns for system state, most not relevant to contact display_

**Tables it joins with:**

| Table | Join Type | Purpose | Files |
|-------|-----------|---------|-------|
| contactdetails | Many:1 | Contact in system | sharez view; ContactService.cfc |
| fusystems | Many:1 | System definition | SystemUserService.cfc |
| funotifications | 1:Many | Actions for this system instance | NotificationService.cfc |

**Notes / oddities:**

- **Not primarily a contact table:** Lives in relationship module, but heavily referenced by contacts
- **System filter in sharez:** Only shows contacts actively IN a system (systemID 1-4)
- **contacts_ss system views:** Pre-filter by systemtype for performance

---

### events / events_tbl

**Purpose:**
Events, appointments, and auditions. Linked to contacts via eventcontactsxref.

**Columns referenced in contact module:**

| Column | Type | Usage | Files Referencing |
|--------|------|-------|-------------------|
| `eventID` | int (PK) | Primary key | EventContactsXRefService.cfc; sharez view:90 |
| `eventStart` | datetime | Event date/time | sharez view:43, 88 (last_met calculation) |
| `eventTypeName` | varchar | Type of event | sharez view:45 (lasteventtype) |
| `audRoleID` | int (FK) | If audition event | sharez view:59 (maxaudition filter) |
| `audStepID` | int (FK) | Audition step | sharez view:60 |
| `IsDeleted` | bit | Soft delete | sharez view:59, 90 |

**Columns NOT used in contact context:**

_Many - events has 30+ columns, most not relevant to contact display_

**Tables it joins with:**

| Table | Join Type | Purpose | Files |
|-------|-----------|---------|-------|
| eventcontactsxref | 1:Many | Which contacts attended | sharez view:86-92 |
| contactdetails | Many:Many (via xref) | Contacts at event | EventService.cfc |
| audsteps | Many:1 (if audition) | Audition progression | sharez view:60 |

**Notes / oddities:**

- **Dual purpose:** Regular events AND audition events (if audRoleID IS NOT NULL)
- **last_met calculation:** ROW_NUMBER window function in sharez view
- **no_mtgs aggregation:** COUNT of eventcontactsxref per contact

---

### audprojects, audsteps, audcontacts_auditions_xref

**Purpose:**
Audition tracking. Linked to contacts via audcontacts_auditions_xref.

**Usage in contact module:**

- **audprojects:** Not directly joined in contact queries
- **audsteps:** Joined in sharez view maxaudition subquery to show "last audition step" (Callback, Avail, Booked, etc.)
- **audcontacts_auditions_xref:** Covered in Junction Tables section above

**Notes / oddities:**

- **maxaudition complexity:** Nested subqueries in sharez view to find MAX(audstepid) per contact
- **Performance issue:** Major contributor to sharez view slowness

---

### taousers / taousers_tbl

**Purpose:**
User accounts. Every contact is owned by a user (userid FK).

**Columns referenced in contact module:**

| Column | Type | Usage | Files Referencing |
|--------|------|-------|-------------------|
| `userID` | int (PK) | User identifier | All contact queries (WHERE userid = :userid) |
| `passwordHash` | varchar | User identifier hash | sharez view:42 (LEFT 10 chars as userHash) |
| `IsDeleted` | bit | Soft delete | sharez view:48 |

**Columns NOT used in contact context:**

_Many - taousers has 50+ columns, most not relevant to contacts_

**Tables it joins with:**

| Table | Join Type | Purpose | Files |
|-------|-----------|---------|-------|
| contactdetails | 1:Many | User owns contacts | All contact queries |
| fusystemusers | 1:Many | User's systems | sharez view |

**Notes / oddities:**

- **Required join:** Every contact query filters `WHERE userid = :userid` for multi-tenancy
- **userHash in sharez:** Uses LEFT(passwordHash, 10) as identifier (security concern?)

---

## SUMMARY STATISTICS

### Tables Discovered: 16

**Core Contact Tables:** 2
- contactdetails / contactdetails_tbl
- contactitems / contactitems_tbl

**Junction Tables:** 2
- audcontacts_auditions_xref
- eventcontactsxref / eventcontactsxref_tbl

**Import Tables:** 2
- contactsimport
- contact_import_log

**Lookup Tables:** 4
- itemcategory
- itemtypes / itemtypes_tbl
- itemtypes_user
- tags / tags_user

**Views:** 5
- contacts_ss
- contacts_ss_target
- contacts_ss_followup
- contacts_ss_maint
- sharez

**Related Module Tables:** 5
- noteslog / noteslog_tbl
- fusystemusers / fusystemusers_tbl
- events / events_tbl
- audprojects (minimal usage)
- audsteps (via sharez)
- taousers / taousers_tbl

---

## MIGRATION PRIORITIES

### High Priority

1. **Standardize IsDeleted casing** - Fix isdeleted vs IsDeleted inconsistency
2. **Remove cdco column** - Migrate remaining reference to contactitems
3. **Optimize contacts_ss view** - Critical performance bottleneck
4. **Rebuild sharez view** - Query base tables directly (use rebuild_sharez_view.sql)
5. **Add primary_yn constraint** - Enforce one primary per category per contact
6. **Standardize valueType casing** - Fix 'Mobile' vs 'mobile', etc.

### Medium Priority

7. **Archive contactsimport** - Implement cleanup via contact_import_log
8. **Index base tables** - Follow recommendations in rebuild_sharez_view.sql
9. **Normalize EAV** - Consider dedicated tables for Email, Phone, Address
10. **Document view definitions** - Extract CREATE VIEW statements from database

### Low Priority

11. **Rename contacts_ss columns** - col1/col2/col3 → meaningful names
12. **Add CHECK constraints** - Enforce contactStatus, itemStatus, valueType values
13. **Add audit columns** - deleted_at, deleted_by timestamps

---

## END OF TABLE MAP

**Next Documentation Files:**
1. ✅ tao1_contacts_table_map.md (this file)
2. ⏭️ tao1_contacts_column_usage.md
3. ⏭️ tao1_contactitems_type_category_map.md
4. ⏭️ tao1_contacts_feature_map.md


---

<!-- END: tao1_contacts_table_map.md -->

---

# TAO 1.0 Contacts Module - Column-by-Column Usage Analysis

**Generated:** 2025-11-30
**Purpose:** Detailed usage tracking for migration to TAO 2.0
**Scope:** Every column in every contact-related table

---

## TABLE OF CONTENTS

1. [contactdetails Columns](#contactdetails-columns)
2. [contactitems Columns](#contactitems-columns)
3. [Junction Table Columns](#junction-table-columns)
4. [Import Table Columns](#import-table-columns)
5. [Lookup Table Columns](#lookup-table-columns)
6. [View Columns](#view-columns)

---

## CONTACTDETAILS COLUMNS

### contactdetails.contactid

**Type:** int (PRIMARY KEY, AUTO_INCREMENT)

**Used in:**
- **SELECT:** Every query - primary key
  - services/ContactService.cfc:82 - `SELECT contactid...`
  - services/ContactService.cfc:198 - `SELECT contactid, userid, contactFullName...`
  - include/qry/contact_info.cfm - contact detail query
  - include/qry/contacts.cfm - contact list query
  - 145+ files total

- **WHERE (filtering):**
  - services/ContactService.cfc:103 - `WHERE contactid = :contactid`
  - services/ContactService.cfc:165 - `WHERE contactid = :contactid` (UPDATE)
  - services/ContactService.cfc:185 - `WHERE contactid = :contactid` (DELETE)
  - All contact detail/edit pages

- **INSERT:** Never (auto-increment)

- **UPDATE:** Never (primary key)

**Role:**
- Primary key for all contact operations
- Foreign key target for contactitems, eventcontactsxref, audcontacts_auditions_xref, fusystemusers, noteslog

**Business logic:**
- Required for all contact operations
- Auto-generated on INSERT
- Never changes after creation

**Unused anywhere?:** No - critical column

---

### contactdetails.userid

**Type:** int (FOREIGN KEY → taousers.userID)

**Used in:**
- **SELECT:** Every query - required for multi-tenancy
  - services/ContactService.cfc:83, 199 - Always selected
  - All contact queries

- **WHERE (filtering):** **ALWAYS** - multi-tenancy enforcement
  - services/ContactService.cfc:199 - `WHERE userid = :userid`
  - services/ContactService.cfc:227 - `WHERE userid = :userid`
  - ContactItemService.cfc:10, 18, 49 - All tag/item queries
  - **Every single query filters by userid**

- **INSERT:** Required field
  - services/ContactService.cfc:13-15 - Validation: userid required
  - services/ContactService.cfc:22 - Field definition in allowedFields
  - All contact creation flows

- **UPDATE:** Never (immutable - contacts can't change owners)

**Role:**
- Multi-tenancy - isolates data by user
- Controls which user owns this contact
- Joins to taousers for user info in sharez view

**Business logic:**
- REQUIRED on INSERT
- Immutable after creation
- ALWAYS filtered in WHERE clauses
- Security critical - prevents cross-user data access

**Unused anywhere?:** No - most critical column for security

---

### contactdetails.contactFullName

**Type:** varchar(255)

**Used in:**
- **SELECT:** Primary display name
  - services/ContactService.cfc:84, 198 - Core field
  - include/contact_info.cfm:78 - Display on detail page
  - include/contacts_table.cfm - List display
  - contacts_ss view (contributes to col1)
  - sharez view:34 - Used as NAME
  - 100+ files

- **WHERE (filtering/searching):**
  - services/ContactService.cfc:207-210 - `WHERE (contactFullName LIKE :search OR recordname LIKE :search)`
  - services/ContactImportService.cfc - Duplicate detection by name
  - include/qry/lookup_contacts.cfm - Autocomplete search
  - ContactSSService.cfc:SELcontacts_ss_23946() - Find by name

- **INSERT:** Required field
  - services/ContactService.cfc:16-18 - Validation: contactFullName required
  - services/ContactService.cfc:23 - Field definition
  - include/contact_add.cfm - Creates with "Unknown" if not provided

- **UPDATE:** Frequently updated
  - services/ContactService.cfc:126 - Allowed in updates
  - include/remoteUpdateName.cfm - AJAX name update
  - include/remoteUpdateNameUpdate.cfm - Name update handler

**Role:**
- Primary contact identifier
- Search target for contact lookup
- Display in lists, cards, detail views
- Duplicate detection key

**Business logic:**
- REQUIRED on INSERT (or defaults to "Unknown")
- Full-text search target
- Combined with recordname for comprehensive search
- Truncated to 255 chars if longer

**Unused anywhere?:** No - core identifier

---

### contactdetails.recordname

**Type:** varchar(255)

**Used in:**
- **SELECT:** Alternative/professional name
  - services/ContactService.cfc:85 - Selected with contactFullName
  - contacts_ss view - Used in col1 (contactFullName OR recordname)
  - sharez view:34 - `d.recordname AS NAME` (primary in sharez)
  - include/contact_info.cfm:95 - Display if different from contactFullName

- **WHERE (filtering/searching):**
  - services/ContactService.cfc:207-210 - `WHERE (contactFullName LIKE :search OR recordname LIKE :search)`
  - include/qry/lookup_contacts.cfm - Autocomplete searches both names
  - ContactDuplicateService - Duplicate detection uses both

- **INSERT:** Optional
  - services/ContactService.cfc:25 - Allowed field
  - Often left NULL or empty

- **UPDATE:** Occasionally updated
  - services/ContactService.cfc:127 - Allowed in updates
  - include/remoteUpdateName.cfm - Can update professional name

**Role:**
- Professional name (e.g., "John Smith" vs "Johnny S.")
- Alternative search term
- Used in formal communications/sharing

**Business logic:**
- Optional - can be NULL
- Search includes both contactFullName AND recordname
- contacts_ss view prefers recordname if present, else contactFullName
- sharez view ALWAYS uses recordname (may be NULL)

**Unused anywhere?:** No - actively used in search and display

**Migration note:** Clarify which name is "primary" - inconsistent between views

---

### contactdetails.contacttitle

**Type:** varchar(255)

**Used in:**
- **SELECT:** Professional title
  - services/ContactService.cfc:84 - Selected in read()
  - include/contact_info.cfm - Display on detail page

- **WHERE:** Not used for filtering

- **INSERT:** Optional
  - services/ContactService.cfc:24 - Allowed field
  - Rarely populated

- **UPDATE:** Rarely updated
  - services/ContactService.cfc:127 - Allowed in updates

**Role:**
- Professional title (e.g., "Casting Director", "Producer")
- Display-only field

**Business logic:**
- Optional - often NULL
- No validation or constraints
- Rarely used in practice (tags used more for categorization)

**Unused anywhere?:** Rarely used - candidate for deprecation

**Migration note:** Consider removing or merging with contactitems tag system

---

### contactdetails.contactNickname

**Type:** varchar(100)

**Used in:**
- **SELECT:** Informal name
  - services/ContactService.cfc:86 - Selected in read()
  - include/contact_info.cfm:142 - Displayed in "Nickname" section with edit icon

- **WHERE:** Not used for filtering

- **INSERT:** Optional
  - services/ContactService.cfc:26 - Allowed field
  - User-entered during contact creation

- **UPDATE:** Occasionally updated
  - services/ContactService.cfc:128 - Allowed in updates
  - include/contact_info.cfm - Editable via modal

**Role:**
- Personal touch - how user knows contact informally
- Display alongside formal names

**Business logic:**
- Optional
- Not searchable (not in ContactService.list() search)
- Display-only

**Unused anywhere?:** Used but minor - consider keeping for personal touch

---

### contactdetails.contactBirthday

**Type:** date

**Used in:**
- **SELECT:** Birthday tracking
  - services/ContactService.cfc:87 - Selected in read()
  - services/BirthdayService.cfc - Birthday reminders query
  - include/contact_info.cfm:177 - Display with age calculation

- **WHERE (filtering):**
  - services/BirthdayService.cfc - `WHERE contactBirthday IS NOT NULL AND contactBirthday BETWEEN...`
  - sched/birthday_fix.cfm - Birthday data cleanup script
  - Reports/dashboard widgets - upcoming birthdays

- **INSERT:** Optional
  - services/ContactService.cfc:27 - Allowed field (CF_SQL_DATE)
  - User-entered or imported from CSV

- **UPDATE:** Occasionally updated
  - services/ContactService.cfc:130 - Allowed in updates
  - include/contact_info.cfm - Editable date picker

**Role:**
- Birthday reminder system
- Dashboard "upcoming birthdays" widget
- Personal relationship management

**Business logic:**
- Optional - can be NULL
- Triggers reminder system (15-day advance notifications)
- Used with DATEDIFF for "days until birthday" calculations
- sched/birthday_fix.cfm suggests data quality issues (cleanup script exists)

**Unused anywhere?:** No - active feature

**Migration note:** Add index on contactBirthday WHERE contactBirthday IS NOT NULL for performance

---

### contactdetails.contactMeetingDate

**Type:** date

**Used in:**
- **SELECT:** First meeting tracking
  - services/ContactService.cfc:88 - Selected in read()
  - sharez view:39 - `d.contactMeetingDate AS WhenMet`
  - include/contact_info.cfm:189 - Display "When We Met" section

- **WHERE:** Not used for filtering

- **INSERT:** Optional
  - services/ContactService.cfc:28 - Allowed field
  - Often entered during contact creation

- **UPDATE:** Occasionally updated
  - services/ContactService.cfc:131 - Allowed in updates
  - include/contact_info.cfm - Editable date picker

**Role:**
- Context about relationship start
- Historical record keeping
- Shared in sharez view (public contact info)

**Business logic:**
- Optional - can be NULL
- Not validated against contactCreationDate (could be before account creation)
- No automated reminders or calculations
- Display-only for reference

**Unused anywhere?:** Used but passive - no automation tied to it

---

### contactdetails.contactMeetingLoc

**Type:** varchar(255)

**Used in:**
- **SELECT:** First meeting location
  - services/ContactService.cfc:89 - Selected in read()
  - sharez view:38 - `d.contactMeetingLoc AS WhereMet`
  - include/contact_info.cfm:201 - Display "Where We Met" section

- **WHERE:** Not used for filtering

- **INSERT:** Optional
  - services/ContactService.cfc:29 - Allowed field
  - Often entered with contactMeetingDate

- **UPDATE:** Occasionally updated
  - services/ContactService.cfc:132 - Allowed in updates
  - include/contact_info.cfm - Editable text field

**Role:**
- Context about relationship start
- Location memory (e.g., "CBS Studios Lot 32", "Backstage Expo")
- Shared in sharez view

**Business logic:**
- Optional - can be NULL
- Free-text entry (no validation)
- Display-only

**Unused anywhere?:** Used but passive - no automation

---

### contactdetails.contactPronoun

**Type:** varchar(50)

**Used in:**
- **SELECT:** Pronoun preference
  - services/ContactService.cfc:90 - Selected in read()
  - include/contact_info.cfm:156 - Display with dropdown editor

- **WHERE:** Not used for filtering

- **INSERT:** Optional
  - services/ContactService.cfc:30 - Allowed field
  - Defaults to NULL if not specified

- **UPDATE:** Occasionally updated
  - services/ContactService.cfc:133 - Allowed in updates
  - include/contact_info.cfm - Dropdown with He/She/They/Custom options

**Role:**
- Respectful communication
- Pronoun reference for notes, emails, scripts
- Custom option for non-binary pronouns

**Business logic:**
- Optional - can be NULL
- Supports "Custom" value (actual custom text stored elsewhere? Not visible in code)
- No validation - free-text allowed
- Display-only for reference

**Unused anywhere?:** Used but not in automation - good to keep for inclusive language

**Migration note:** Clarify where "Custom" pronoun text is stored

---

### contactdetails.refer_contact_id

**Type:** int (FOREIGN KEY → contactdetails.contactid, self-referencing)

**Used in:**
- **SELECT:** Referral tracking
  - services/ContactService.cfc:91 - Selected in read()
  - include/qry/contact_info.cfm:8 - Self-join to get referrer name:
    ```sql
    LEFT JOIN contactdetails cd2 ON cd2.contactid = d.refer_contact_id
    SELECT cd2.contactFullName AS referDetailsFullname
    ```
  - include/contact_info.cfm - Display "Referred By" with link to referrer

- **WHERE:** Not used for filtering (could be used for "find all contacts referred by X")

- **INSERT:** Optional
  - services/ContactService.cfc:31 - Allowed field (CF_SQL_INTEGER)
  - User selects from contact dropdown during creation

- **UPDATE:** Occasionally updated
  - services/ContactService.cfc:134 - Allowed in updates
  - include/contact_info.cfm - Editable contact lookup

**Role:**
- Track referral source
- Network mapping (who introduced you)
- Relationship context

**Business logic:**
- Optional - can be NULL
- Self-referencing FK (must point to valid contactid)
- No cascade deletes visible (orphaned if referrer deleted?)
- Display shows referrer's contactFullName

**Unused anywhere?:** Used but not for reporting - could enable "referral network" reports

**Migration note:** Add ON DELETE SET NULL for referral integrity

---

### contactdetails.contactStatus

**Type:** varchar(50)

**Used in:**
- **SELECT:** Contact active state
  - services/ContactService.cfc:92, 198 - Selected in read() and list()
  - include/contacts.cfm - Used for filtering Active/Inactive

- **WHERE (filtering):**
  - services/ContactService.cfc:203-206 - `WHERE contactStatus = :contactStatus` (optional filter)
  - include/contacts.cfm - Filter dropdown for Active/Inactive
  - Most list queries assume Active only

- **INSERT:** Optional (likely defaults to 'Active')
  - services/ContactService.cfc:32 - Allowed field

- **UPDATE:** Occasionally updated
  - services/ContactService.cfc:135 - Allowed in updates
  - Status change from Active to Inactive (soft archival, not delete)

**Role:**
- Lifecycle management
- Distinguish active relationships from archived
- Filter option in contact lists

**Business logic:**
- Values: 'Active', 'Inactive' (no other values observed in code)
- No DB constraint - application-level only
- Default likely 'Active' (not enforced in DB)
- Different from isdeleted (status = state, isdeleted = deleted)

**Unused anywhere?:** No - actively used for filtering

**Migration note:** Add CHECK constraint for valid statuses, add default 'Active'

---

### contactdetails.contactCreationDate

**Type:** datetime

**Used in:**
- **SELECT:** Audit trail
  - services/ContactService.cfc:94, 198 - Selected in read() and list()
  - include/qry/contacts.cfm - Used in ORDER BY (recent first)
  - Reports - contact growth over time

- **WHERE (filtering):**
  - Reports/analytics - date range filters (not visible in core code)

- **INSERT:** Auto-populated
  - Not in ContactService.cfc allowedFields - suggests DB default (CURRENT_TIMESTAMP)

- **UPDATE:** Never (immutable)

**Role:**
- Audit trail - when contact was created
- Sorting (newest first)
- Reports (contacts added this month, etc.)

**Business logic:**
- Auto-populated by DB (CURRENT_TIMESTAMP default)
- Immutable
- Used for sorting and reporting

**Unused anywhere?:** No - essential audit field

---

### contactdetails.contactLastUpdated

**Type:** datetime

**Used in:**
- **SELECT:** Audit trail
  - services/ContactService.cfc:95, 198 - Selected in read() and list()
  - Reports - recently updated contacts

- **WHERE (filtering):**
  - Reports/analytics - find recently modified contacts

- **INSERT:** Auto-populated (likely DB default CURRENT_TIMESTAMP)

- **UPDATE:** Auto-updated
  - Not in ContactService.cfc update logic - suggests DB trigger or ON UPDATE CURRENT_TIMESTAMP

**Role:**
- Audit trail - when contact was last modified
- Find recently changed contacts
- Sync/integration tracking

**Business logic:**
- Auto-populated/updated by DB
- Not manually set by application
- Used for change tracking

**Unused anywhere?:** No - essential audit field

**Migration note:** Ensure ON UPDATE CURRENT_TIMESTAMP is set in schema

---

### contactdetails.contactphoto

**Type:** varchar(255)

**Used in:**
- **SELECT:** Avatar display
  - services/ContactService.cfc:96 - Selected in read()
  - contacts_ss view - Column: avatar
  - include/contact_info.cfm - Display contact avatar
  - include/contacts_table.cfm - Avatar in list view

- **WHERE:** Not used for filtering

- **INSERT:** Optional
  - services/ContactService.cfc:33 - Allowed field
  - Default NULL (no avatar)

- **UPDATE:** Updated via upload
  - services/ContactService.cfc:136 - Allowed in updates
  - include/image-upload-contact.cfm - Avatar upload flow
  - sched/avatar_loop.cfm, avatar_loop2.cfm - Batch avatar processing

**Role:**
- Visual identification
- Avatar display in lists, cards, detail views
- File path to uploaded image

**Business logic:**
- Optional - can be NULL (shows default avatar)
- Stores file path, not binary data
- Upload handled separately from contact CRUD
- Batch processing scripts suggest bulk operations

**Unused anywhere?:** No - active visual feature

**Migration note:** Validate file paths on read, handle missing files gracefully

---

### contactdetails.user_yn

**Type:** char(1) - 'Y' or 'N'

**Used in:**
- **SELECT:** User's own contact record
  - services/ContactService.cfc:97 - Selected in read()
  - sched/user_setup.cfm - User initialization creates user_yn='Y' contact

- **WHERE (filtering):**
  - sched/user_setup.cfm - `WHERE userid = :userid AND user_yn = 'Y'` (find user's self-contact)
  - Possibly used to exclude self from lists (not visible in scanned code)

- **INSERT:** Specific use case
  - services/ContactService.cfc:34 - Allowed field
  - sched/user_setup.cfm - Creates contact for user with user_yn='Y'

- **UPDATE:** Never (immutable once set)

**Role:**
- Flag user's own contact record (user IS a contact in their own system)
- Self-referential feature
- Prevents duplication of user entity

**Business logic:**
- Values: 'Y' or 'N' (char 1)
- Only ONE contact per user should have user_yn='Y'
- Created during user onboarding
- Used for self-referential features (user as contact)

**Unused anywhere?:** Used but rare - special case

**Migration note:** Add unique constraint (userid, user_yn='Y') to enforce one per user

---

### contactdetails.newsletter_yn

**Type:** char(1) - 'Y' or 'N'

**Used in:**
- **SELECT:** Newsletter subscription flag
  - services/ContactService.cfc:98 - Selected in read()
  - include/contact_info.cfm:233 - Display checkbox

- **WHERE (filtering):**
  - Newsletter send logic (not visible in scanned contact files - likely in separate newsletter module)

- **INSERT:** Optional
  - services/ContactService.cfc:35 - Allowed field
  - Default likely 'N'

- **UPDATE:** User-toggled
  - services/ContactService.cfc:138 - Allowed in updates
  - include/contact_info.cfm - Checkbox toggle

**Role:**
- Opt-in for newsletters to this contact
- Integration with newsletter/email module
- GDPR compliance (explicit opt-in)

**Business logic:**
- Values: 'Y' or 'N'
- User-controlled flag
- Default 'N' (assume opt-out)
- Used by newsletter module for recipient lists

**Unused anywhere?:** Used - integrates with newsletter feature

---

### contactdetails.googlealert_yn

**Type:** char(1) - 'Y' or 'N'

**Used in:**
- **SELECT:** Google alert setup flag
  - services/ContactService.cfc:99 - Selected in read()
  - include/contact_info.cfm:245 - Display checkbox

- **WHERE (filtering):**
  - Batch script to set up Google alerts (not visible in scanned files)

- **INSERT:** Optional
  - services/ContactService.cfc:36 - Allowed field
  - Default likely 'N'

- **UPDATE:** User-toggled
  - services/ContactService.cfc:139 - Allowed in updates
  - include/contact_info.cfm - Checkbox toggle

**Role:**
- Flag to set up Google alerts for this contact
- Automation trigger (create alert for contact name)
  - Monitor news/mentions of contact

**Business logic:**
- Values: 'Y' or 'N'
- User-controlled flag
- Likely triggers external automation (Google Alerts API or manual setup)

**Unused anywhere?:** Used - feature flag

**Migration note:** Verify if automation exists or if manual reminder only

---

### contactdetails.socialmedia_yn

**Type:** char(1) - 'Y' or 'N'

**Used in:**
- **SELECT:** Social media tracking flag
  - services/ContactService.cfc:100 - Selected in read()
  - include/contact_info.cfm:257 - Display checkbox

- **WHERE (filtering):**
  - Social media monitoring logic (not visible in scanned files)

- **INSERT:** Optional
  - services/ContactService.cfc:37 - Allowed field
  - Default likely 'N'

- **UPDATE:** User-toggled
  - services/ContactService.cfc:140 - Allowed in updates
  - include/contact_info.cfm - Checkbox toggle

**Role:**
- Flag to track social media activity for this contact
- Integration with social media monitoring
- May relate to contactitems with valueCategory='Social Profile'

**Business logic:**
- Values: 'Y' or 'N'
- User-controlled flag
- Likely enables additional features (social media aggregation, monitoring)

**Unused anywhere?:** Used - feature flag

**Migration note:** Clarify relationship with contactitems Social Profile category

---

### contactdetails.isdeleted

**Type:** bit (0 or 1)

**Used in:**
- **SELECT:** Rarely selected directly (filtered in WHERE)
  - services/ContactService.cfc:101 - Selected in read() (for verification)

- **WHERE (filtering):** **ALWAYS** - soft delete filter
  - services/ContactService.cfc - All queries filter `WHERE isdeleted = 0` (implied by view)
  - contactdetails view - WHERE IsDeleted <> 1
  - All list/search queries exclude deleted

- **INSERT:** Default 0
  - services/ContactService.cfc:38 - Allowed field (CF_SQL_BIT)
  - Defaults to 0 (not deleted)

- **UPDATE (soft delete):**
  - services/ContactService.cfc:184 - `SET isdeleted = 1` (delete() method)
  - include/deleteContacts.cfm - Batch soft delete

**Role:**
- Soft delete flag
- Allows "undelete" recovery
- Preserves referential integrity (no cascade deletes)

**Business logic:**
- Values: 0 (active) or 1 (deleted)
- NO HARD DELETES - all deletes are soft
  - ContactService.delete() sets isdeleted = 1
- contactdetails view filters WHERE IsDeleted <> 1 automatically
- Deleted contacts hidden from all lists but data retained

**Unused anywhere?:** No - critical for data integrity

**Migration note:** Standardize casing (isdeleted vs IsDeleted), add deleted_at timestamp

---

### contactdetails.cdco (LEGACY)

**Type:** varchar(100) - LEGACY company field

**Used in:**
- **SELECT:** Minimal
  - Only in deprecated query files

- **WHERE:** Not used

- **INSERT:** One reference found
  - include/qry/Insert_159_13.cfm:5 - `cdco = categories.cdco` (deprecated import logic)

- **UPDATE:** Not used

**Role:**
- LEGACY: Original company field before contactitems system
- Replaced by: contactitems WHERE valueCategory='Company'

**Business logic:**
- Deprecated - should not be used
- Data should be migrated to contactitems
- Remaining reference is in deprecated import code

**Unused anywhere?:** DEPRECATED - migrate and remove

**Migration note:** **HIGH PRIORITY** - Migrate cdco data to contactitems, drop column

---

## CONTACTITEMS COLUMNS

### contactitems.itemid

**Type:** int (PRIMARY KEY, AUTO_INCREMENT)

**Used in:**
- **SELECT:** Primary key
  - ContactItemService.cfc:81 - Selected in itemsbycatActive()
  - include/contact_info.cfm - Used for edit/delete actions (modal IDs)
  - All item queries

- **WHERE (filtering):**
  - UPDATE/DELETE operations by itemid
  - Modal targeting (data-item-id attributes)

- **INSERT:** Never (auto-increment)

- **UPDATE:** Never (primary key)

**Role:**
- Primary key for all contact item operations
- Modal/AJAX target for item edit/delete

**Business logic:**
- Auto-generated on INSERT
- Immutable

**Unused anywhere?:** No - critical primary key

---

### contactitems.contactid

**Type:** int (FOREIGN KEY → contactdetails.contactid)

**Used in:**
- **SELECT:** Often selected (for verification)
  - ContactItemService.cfc:104 - `WHERE i.contactID = :contactid`
  - All item queries

- **WHERE (filtering):** **ALWAYS** - items belong to contact
  - ContactItemService.cfc:104 - Every item query filters by contactid
  - include/qry/*.cfm - All item queries require contactid
  - Prevents cross-contact data leakage

- **INSERT:** Required
  - All INScontactitems queries require contactid
  - include/remoteaddC.cfm - contactid from form/context

- **UPDATE:** Never (immutable - items can't move between contacts)
  - Exception: ContactDuplicateService.mergeContacts() - moves items during merge

**Role:**
- Foreign key to parent contact
- Security - isolates items by contact
- Join target for contact+items queries

**Business logic:**
- REQUIRED on INSERT
- Immutable (except during merge)
- ALWAYS filtered in WHERE
- No orphaned items allowed (FK constraint?)

**Unused anywhere?:** No - critical foreign key

---

### contactitems.valueType

**Type:** varchar(100)

**Used in:**
- **SELECT:** Type identifier
  - ContactItemService.cfc:82 - Selected in all queries
  - include/remoteaddC.cfm:51 - Dropdown for type selection
  - include/contact_pane.cfm - Display type with item

- **WHERE (filtering):**
  - Rarely filtered by valueType directly (filtered by valueCategory instead)
  - itemtypes_user JOIN to get icons

- **INSERT:** Required
  - include/remoteaddC.cfm:51 - User selects from dropdown
  - Values depend on valueCategory:
    - Email: 'Business', 'Personal', 'Work'
    - Phone: 'Work', 'Mobile', 'Home'
    - Company: 'Company'
    - Address: 'Business', 'Work'
    - URL: 'Company Website', etc.
    - Social Profile: Facebook, Twitter, Instagram, LinkedIn, etc. (from itemtypes_user)
    - Tags: 'Tags'

- **UPDATE:** Occasionally updated
  - include/remoteUpdateC.cfm:47 - Type dropdown editable

**Role:**
- Specific type within category
- Determines icon (via itemtypes_user)
- User-visible label

**Business logic:**
- Required - cannot be NULL/empty
- No DB constraint - values defined by itemcategory + itemtypes_user
- Casing inconsistent ('Mobile' vs 'mobile')
- Social Profile types user-customizable via itemtypes_user

**Unused anywhere?:** No - core classification field

**Migration note:** Standardize casing, add FK to itemtypes_user for validation

---

### contactitems.valueCategory

**Type:** varchar(100)

**Used in:**
- **SELECT:** Category identifier
  - ContactItemService.cfc:83, 105 - Selected and filtered in all queries
  - include/remoteaddC.cfm:37 - Hidden field in forms

- **WHERE (filtering):** **VERY FREQUENTLY** - category filtering
  - ContactItemService.cfc:105 - `WHERE c.valuecategory = :valueCategory`
  - ContactItemService.cfc:12 - `WHERE valuecategory = 'Tag'` (tag queries)
  - contacts_ss view - Subqueries for first email/phone/company by category
  - All item retrieval by type

- **INSERT:** Required
  - include/remoteaddC.cfm:37 - Set from itemcategory selection
  - Values: 'Email', 'Phone', 'Address', 'Company', 'Tag', 'Social Profile', 'Acting Links', 'Profile', 'URL'

- **UPDATE:** Never (immutable - changing category changes which fields are used)

**Role:**
- High-level category classification
- Determines which value* fields are used:
  - Email/Phone/URL/Tag → valuetext
  - Company → valueCompany, valueDepartment, valueTitle
  - Address → 6 address fields
- JOIN target to itemcategory for metadata

**Business logic:**
- REQUIRED on INSERT
- Immutable
- Defines field usage pattern (EAV model)
- Must match itemcategory.valueCategory (FK?)

**Unused anywhere?:** No - critical for EAV model

**Migration note:** Add FK to itemcategory.valueCategory for referential integrity

---

### contactitems.valuetext

**Type:** varchar(500)

**Used in:**
- **SELECT:** Primary text value
  - ContactItemService.cfc:84 - Selected in all queries
  - contacts_ss view - col3 (phone), col4 (email) from valuetext
  - sharez view:36 - `ci_tag.valueText AS Title`
  - include/contact_pane.cfm - Display email/phone/URL/tag text

- **WHERE (filtering):**
  - ContactItemService.cfc:66-69 - `WHERE valuetext = 'My Team'` (team tag)
  - services/ContactImportValidationService.cfc - Email duplicate detection by valuetext
  - include/qry/duplicatesByEmail.cfm:20 - `WHERE ic.valueCategory = 'Email' AND ic.valuetext = ...`

- **INSERT:** Required for most categories
  - All Email, Phone, URL, Tag inserts
  - include/qry/insert*.cfm - valuetext populated from form

- **UPDATE:** Frequently updated
  - include/remoteUpdateC.cfm - Edit email, phone, tag, URL

**Role:**
- Primary value storage for:
  - Email addresses
  - Phone numbers
  - URLs
  - Tag names
  - Social profile URLs
  - Acting link URLs
- Search/filter target (duplicate detection)

**Business logic:**
- REQUIRED for Email, Phone, URL, Tag, Social Profile, Acting Links
- NOT USED for Company (uses valueCompany instead) or Address (uses 6 address fields)
- Max 500 chars (varies by category - tags truncated to 40 in queries)
- Duplicate detection on Email valuetext

**Unused anywhere?:** No - critical value field

**Migration note:** Consider separate columns for email/phone/url instead of EAV for performance

---

### contactitems.valueCompany

**Type:** varchar(255)

**Used in:**
- **SELECT:** Company name
  - ContactItemService.cfc:85 - Selected in itemsbycatActive()
  - sharez view:35 - `ci_company.valueCompany AS Company`
  - contacts_ss view - col5 (company) from valueCompany

- **WHERE (filtering):**
  - sharez view:71-72 - `WHERE ci_company.valueCategory = 'Company' AND ci_company.itemStatus = 'active'`

- **INSERT:** Required for valueCategory='Company'
  - include/remoteaddC.cfm - Company name input
  - NOT valuetext - different field!

- **UPDATE:** Updated for company items
  - include/remoteUpdateC.cfm - Company editing

**Role:**
- Company name storage (ONLY for valueCategory='Company')
- Different from valuetext (Company category uses valueCompany, NOT valuetext)

**Business logic:**
- ONLY used when valueCategory='Company'
- NULL/empty for all other categories
- Stored separately from valuetext (design oddity)

**Unused anywhere?:** No - active for Company category

**Migration note:** Inconsistent design - Company uses valueCompany while Email/Phone use valuetext. Consider normalizing.

---

### contactitems.valueDepartment

**Type:** varchar(255)

**Used in:**
- **SELECT:** Department within company
  - ContactItemService.cfc:86 - Selected in itemsbycatActive()
  - include/contact_pane.cfm - Display company department

- **WHERE:** Not used for filtering

- **INSERT:** Optional for valueCategory='Company'
  - include/remoteaddC.cfm - Department input (optional)

- **UPDATE:** Updated for company items
  - include/remoteUpdateC.cfm - Department editing

**Role:**
- Department/division within company (e.g., "Casting", "Development")
- ONLY for valueCategory='Company'

**Business logic:**
- Optional (can be NULL)
- ONLY used when valueCategory='Company'
- NULL for all other categories

**Unused anywhere?:** Used for Company category

---

### contactitems.valueTitle

**Type:** varchar(255)

**Used in:**
- **SELECT:** Job title within company
  - ContactItemService.cfc:87 - Selected in itemsbycatActive()
  - include/contact_pane.cfm - Display job title

- **WHERE:** Not used for filtering

- **INSERT:** Optional for valueCategory='Company'
  - include/remoteaddC.cfm - Title input (e.g., "Casting Director", "VP of Development")

- **UPDATE:** Updated for company items
  - include/remoteUpdateC.cfm - Title editing

**Role:**
- Job title within company
- ONLY for valueCategory='Company'

**Business logic:**
- Optional (can be NULL)
- ONLY used when valueCategory='Company'
- NULL for all other categories

**Unused anywhere?:** Used for Company category

---

### contactitems.valueStreetAddress

**Type:** varchar(255)

**Used in:**
- **SELECT:** Street address
  - ContactItemService.cfc:88 - Selected in itemsbycatActive()
  - include/contact_pane.cfm - Display address line 1

- **WHERE:** Not used for filtering

- **INSERT:** Optional for valueCategory='Address'
  - include/remoteaddC.cfm - Address line 1 input

- **UPDATE:** Updated for address items
  - include/remoteUpdateC.cfm - Address editing

**Role:**
- Street address (line 1)
- ONLY for valueCategory='Address'

**Business logic:**
- Optional (can be NULL)
- ONLY used when valueCategory='Address'
- NULL for all other categories

**Unused anywhere?:** Used for Address category

---

### contactitems.valueExtendedAddress

**Type:** varchar(255)

**Used in:**
- **SELECT:** Apt/Suite/Unit
  - ContactItemService.cfc:89 - Selected in itemsbycatActive()
  - include/contact_pane.cfm - Display address line 2

- **WHERE:** Not used for filtering

- **INSERT:** Optional for valueCategory='Address'
  - include/remoteaddC.cfm - Address line 2 input (Apt, Suite, Unit)

- **UPDATE:** Updated for address items
  - include/remoteUpdateC.cfm - Address editing

**Role:**
- Address line 2 (apartment, suite, unit, building)
- ONLY for valueCategory='Address'

**Business logic:**
- Optional (can be NULL)
- ONLY used when valueCategory='Address'
- NULL for all other categories

**Unused anywhere?:** Used for Address category

---

### contactitems.valueCity

**Type:** varchar(100)

**Used in:**
- **SELECT:** City
  - ContactItemService.cfc:90 - Selected in itemsbycatActive()
  - include/contact_pane.cfm - Display city

- **WHERE:** Not used for filtering (could be used for "contacts in LA" query)

- **INSERT:** Optional for valueCategory='Address'
  - include/remoteaddC.cfm - City input

- **UPDATE:** Updated for address items
  - include/remoteUpdateC.cfm - Address editing

**Role:**
- City name
- ONLY for valueCategory='Address'

**Business logic:**
- Optional (can be NULL)
- ONLY used when valueCategory='Address'
- NULL for all other categories

**Unused anywhere?:** Used for Address category

**Migration note:** Could enable geographic filtering/reporting

---

### contactitems.valueRegion

**Type:** varchar(100)

**Used in:**
- **SELECT:** State/Province/Region
  - ContactItemService.cfc:91 - Selected in itemsbycatActive()
  - include/contact_pane.cfm - Display state/region

- **WHERE:** Not used for filtering (could enable "contacts in CA")

- **INSERT:** Optional for valueCategory='Address'
  - include/remoteaddC.cfm - State/Province dropdown or text input

- **UPDATE:** Updated for address items
  - include/remoteUpdateC.cfm - Address editing

**Role:**
- State/Province/Region
- ONLY for valueCategory='Address'

**Business logic:**
- Optional (can be NULL)
- ONLY used when valueCategory='Address'
- NULL for all other categories

**Unused anywhere?:** Used for Address category

**Migration note:** Could enable regional reporting

---

### contactitems.valueCountry

**Type:** varchar(100)

**Used in:**
- **SELECT:** Country
  - ContactItemService.cfc:97 - Selected in itemsbycatActive()
  - include/contact_pane.cfm - Display country

- **WHERE:** Not used for filtering

- **INSERT:** Optional for valueCategory='Address'
  - include/remoteaddC.cfm - Country dropdown (likely defaults to US)

- **UPDATE:** Updated for address items
  - include/remoteUpdateC.cfm - Address editing

**Role:**
- Country name
- ONLY for valueCategory='Address'

**Business logic:**
- Optional (can be NULL, likely defaults to US)
- ONLY used when valueCategory='Address'
- NULL for all other categories

**Unused anywhere?:** Used for Address category

---

### contactitems.valuePostalCode

**Type:** varchar(20)

**Used in:**
- **SELECT:** Zip/Postal code
  - ContactItemService.cfc:100 - Selected in itemsbycatActive()
  - include/contact_pane.cfm - Display zip code

- **WHERE:** Not used for filtering

- **INSERT:** Optional for valueCategory='Address'
  - include/remoteaddC.cfm - Zip/Postal code input

- **UPDATE:** Updated for address items
  - include/remoteUpdateC.cfm - Address editing

**Role:**
- Postal code / ZIP code
- ONLY for valueCategory='Address'

**Business logic:**
- Optional (can be NULL)
- ONLY used when valueCategory='Address'
- NULL for all other categories
- Max 20 chars (supports international formats)

**Unused anywhere?:** Used for Address category

---

### contactitems.itemDate

**Type:** date

**Used in:**
- **SELECT:** Rarely
  - ContactItemService.cfc:92 - Selected in itemsbycatActive() but rarely populated

- **WHERE:** Not used

- **INSERT:** Rarely populated
  - Defined in schema but seldom used

- **UPDATE:** Rarely updated

**Role:**
- Date associated with item (e.g., date email verified, date phone added)
- Intended use unclear from code

**Business logic:**
- Optional - usually NULL
- No automation or business rules visible

**Unused anywhere?:** **UNDERUTILIZED** - rarely populated or queried

**Migration note:** Consider removing if truly unused, or define clear use case

---

### contactitems.itemNotes

**Type:** text

**Used in:**
- **SELECT:** Rarely
  - ContactItemService.cfc:93 - Selected in itemsbycatActive() but rarely populated

- **WHERE:** Not used

- **INSERT:** Rarely populated
  - Defined in schema but seldom used

- **UPDATE:** Rarely updated

**Role:**
- Notes about specific item (e.g., "Primary work email", "Do not call after 5pm")
- Intended use unclear from code

**Business logic:**
- Optional - usually NULL
- No visible UI for entering item notes

**Unused anywhere?:** **UNDERUTILIZED** - rarely populated or displayed

**Migration note:** Consider removing if truly unused, or add UI to utilize

---

### contactitems.itemStatus

**Type:** varchar(50)

**Used in:**
- **SELECT:** Status indicator
  - ContactItemService.cfc:94 - Selected in all queries

- **WHERE (filtering):** **FREQUENTLY** - active item filter
  - ContactItemService.cfc:106 - `WHERE i.itemstatus = 'Active'`
  - ContactItemService.cfc:14 - `WHERE itemstatus = 'Active'` (tag queries)
  - sharez view:72, 76 - `WHERE itemStatus = 'active'` (case inconsistent!)
  - All item display queries filter Active only

- **INSERT:** Required
  - Defaults to 'Active' on creation
  - Can create as 'Pending' for placeholder items

- **UPDATE:** Occasionally updated
  - Status changed to 'Inactive' instead of deleting
  - Soft archival of items

**Role:**
- Item lifecycle management
- Filter active vs inactive items
- Soft archival (different from soft delete)

**Business logic:**
- Values: 'Active', 'Pending', 'Inactive'
- No DB constraint - application-level only
- Default 'Active'
- Casing inconsistent ('Active' vs 'active')

**Unused anywhere?:** No - actively used for filtering

**Migration note:** Standardize casing, add CHECK constraint, add default 'Active'

---

### contactitems.primary_yn

**Type:** char(1) - 'Y' or 'N'

**Used in:**
- **SELECT:** Primary item indicator
  - ContactItemService.cfc:101 - Selected in itemsbycatActive()
  - contacts_ss view - Uses to select "first" email/phone (WHERE primary_yn='Y')

- **WHERE (filtering):**
  - contacts_ss view - Subqueries filter `WHERE primary_yn = 'Y'` to get first item per category

- **INSERT:** Optional
  - Defaults to 'N'
  - First item of category often set to 'Y'

- **UPDATE:** Occasionally updated
  - User changes which email/phone is primary

**Role:**
- Identify primary/default item per category per contact
- Used by contacts_ss view to show "first" email/phone/company

**Business logic:**
- Values: 'Y' or 'N'
- Only ONE item per category per contact should be 'Y' (not enforced by DB)
- contacts_ss subqueries assume one primary exists
- Risk: Multiple primaries or no primary

**Unused anywhere?:** No - critical for list view performance

**Migration note:** **HIGH PRIORITY** - Add unique constraint (contactid, valueCategory, primary_yn) WHERE primary_yn='Y'

---

### contactitems.itemCreationDate

**Type:** datetime

**Used in:**
- **SELECT:** Audit trail
  - ContactItemService.cfc:95 - Selected in itemsbycatActive()

- **WHERE:** Not used for filtering

- **INSERT:** Auto-populated
  - Likely DB default CURRENT_TIMESTAMP

- **UPDATE:** Never (immutable)

**Role:**
- Audit trail - when item was created
- Historical tracking

**Business logic:**
- Auto-populated by DB
- Immutable

**Unused anywhere?:** No - audit field

---

### contactitems.itemLastUpdated

**Type:** datetime

**Used in:**
- **SELECT:** Audit trail
  - ContactItemService.cfc:96 - Selected in itemsbycatActive()

- **WHERE:** Not used for filtering

- **INSERT:** Auto-populated
  - Likely DB default CURRENT_TIMESTAMP

- **UPDATE:** Auto-updated
  - Likely DB ON UPDATE CURRENT_TIMESTAMP

**Role:**
- Audit trail - when item was last modified
- Change tracking

**Business logic:**
- Auto-updated by DB
- Not manually set

**Unused anywhere?:** No - audit field

**Migration note:** Ensure ON UPDATE CURRENT_TIMESTAMP in schema

---

### contactitems.isDeleted

**Type:** bit (0 or 1)

**Used in:**
- **SELECT:** Rarely (filtered in WHERE)

- **WHERE (filtering):** **ALWAYS** - soft delete filter
  - contactitems view - WHERE IsDeleted <> 1
  - All queries filter out deleted items

- **INSERT:** Default 0

- **UPDATE (soft delete):**
  - ContactItemService.deleteTeam():67 - Hard DELETE (not soft!) - INCONSISTENT
  - Most other deletes likely soft (isDeleted = 1)

**Role:**
- Soft delete flag
- Allows recovery

**Business logic:**
- Values: 0 (active) or 1 (deleted)
- Most deletes are soft (isDeleted = 1)
- Exception: deleteTeam() does HARD DELETE (bug or intentional?)

**Unused anywhere?:** No - critical for data integrity

**Migration note:** Standardize casing (isDeleted vs IsDeleted), fix deleteTeam() to soft delete

---

## JUNCTION TABLE COLUMNS

### audcontacts_auditions_xref.contactid

**Type:** int (FK → contactdetails.contactid)

**Used in:**
- All audition contact queries
- ContactAuditionService.cfc
- sharez view:58, 61, 67 (maxaudition subquery)

**Role:** Links contact to audition project

**Business logic:** Required, many-to-many relationship

---

### audcontacts_auditions_xref.audprojectid

**Type:** int (FK → audprojects.audprojectid)

**Used in:**
- All audition contact queries
- AuditionProjectService.cfc

**Role:** Links audition project to contact

**Business logic:** Required, many-to-many relationship

---

### audcontacts_auditions_xref.xrefnotes

**Type:** text

**Used in:**
- AuditionProjectService - notes about contact's role in audition
- include/qry/add_aud_contact.cfm

**Role:** Context notes (e.g., "Met at callback", "Requested breakdown")

**Business logic:** Optional, free-text

---

### eventcontactsxref.contactid

**Type:** int (FK → contactdetails.contactid)

**Used in:**
- EventService.cfc
- sharez view:81, 89 (meeting counts, last event)

**Role:** Links contact to event

**Business logic:** Required, many-to-many relationship

---

### eventcontactsxref.eventid

**Type:** int (FK → events.eventid)

**Used in:**
- EventService.cfc
- sharez view:90

**Role:** Links event to contact

**Business logic:** Required, many-to-many relationship

---

### eventcontactsxref.IsDeleted

**Type:** bit

**Used in:**
- sharez view:82, 91 - Filtered in aggregations

**Role:** Soft delete flag

**Business logic:** Filtered in all queries (IsDeleted <> 1)

---

## IMPORT TABLE COLUMNS

### contactsimport columns

**Note:** Dynamic schema based on CSV upload. Common columns:

- `id` (PK)
- `contactid` (FK after import)
- `uploadid` (groups import batch)
- `status` ('Added', 'Duplicate', 'Error', 'Pending')
- CSV data columns (firstName, lastName, email, phone, company, etc.)

**Usage:** Staging only - temporary table for import workflow

---

## LOOKUP TABLE COLUMNS

### itemcategory.valueCategory

**Type:** varchar(100) (unique key)

**Used in:**
- All contactitems queries as JOIN target
- ContactItemService.cfc:105, 126, 130

**Role:** Category name (Email, Phone, Tag, etc.)

**Business logic:** Must match contactitems.valueCategory (FK?)

---

### itemcategory.caticon

**Type:** varchar(50)

**Used in:**
- ContactItemService.cfc:99, 127
- include/contact_pane.cfm - Icon display

**Role:** CSS icon class (fe-phone, fe-mail, etc.)

**Business logic:** Displayed alongside items

---

### itemcategory.catfieldset

**Type:** varchar(50)

**Used in:**
- ContactItemService.cfc:98, 128
- include/remoteaddC.cfm - Determines which form fields to show

**Role:** Defines field layout ('text', 'address', 'company')

**Business logic:**
- 'text' → show valuetext only
- 'address' → show 6 address fields
- 'company' → show valueCompany, valueDepartment, valueTitle

---

### tags_user.tagname

**Type:** varchar(100)

**Used in:**
- ContactItemService.cfc:16 - Filter join for CD detection
- TagsUserService.cfc

**Role:** Tag name definition

**Business logic:** Max 40 chars enforced in queries (LEFT(tagname, 40))

---

### tags_user.tagtype

**Type:** char(1)

**Used in:**
- ContactItemService.cfc:19 - `WHERE tagtype = 'C'` (Casting Director detection)

**Role:** 'C' = Casting Director tag, affects relationship system workflow

**Business logic:** Critical for system scope determination

---

## VIEW COLUMNS

### contacts_ss.col1

**Type:** varchar (computed: contactFullName OR recordname)

**Used in:**
- include/contacts.cfm, contacts_table.cfm - Display name in lists
- ContactItemService.addTeam():50 - Lookup by name

**Role:** Primary display name

**Business logic:** Prefers recordname if present, else contactFullName

---

### contacts_ss.col3

**Type:** varchar (computed: first phone where primary_yn='Y')

**Used in:**
- include/contacts_table.cfm - Phone display in lists

**Role:** Primary phone display

**Business logic:** Subquery gets first phone with primary_yn='Y' or itemStatus='Active'

---

### contacts_ss.col4

**Type:** varchar (computed: first email where primary_yn='Y')

**Used in:**
- include/contacts_table.cfm - Email display in lists

**Role:** Primary email display

**Business logic:** Subquery gets first email with primary_yn='Y' or itemStatus='Active'

---

### contacts_ss.col5

**Type:** varchar (computed: first company where primary_yn='Y')

**Used in:**
- include/contacts_table.cfm - Company display in lists

**Role:** Primary company display

**Business logic:** Subquery gets first company with primary_yn='Y' or itemStatus='Active'

---

## SUMMARY: UNUSED OR UNDERUTILIZED COLUMNS

### Completely Unused:
1. **contactdetails.cdco** - LEGACY, migrate and remove

### Underutilized:
1. **contactdetails.contacttitle** - Rarely used, consider deprecating
2. **contactitems.itemDate** - Defined but rarely populated
3. **contactitems.itemNotes** - Defined but rarely populated
4. **itemcategory.catSelectList** - Defined but no references

### Migration Actions Required:
1. **Migrate contactdetails.cdco** to contactitems
2. **Standardize casing:** isdeleted → IsDeleted, itemstatus values
3. **Add constraints:** primary_yn uniqueness, status CHECK constraints
4. **Add indexes:** Performance optimization per rebuild_sharez_view.sql
5. **Clarify/remove:** itemDate, itemNotes (or add UI)

---

## END OF COLUMN USAGE ANALYSIS

**Next Documentation File:** tao1_contactitems_type_category_map.md


---

<!-- END: tao1_contacts_column_usage.md -->

---

# TAO 1.0 Contacts Module - Complete Feature Map

**Generated:** 2025-11-30
**Purpose:** Functional documentation of all contacts features for TAO 2.0 migration
**Scope:** Every user-facing and backend feature in the contacts module

---

## EXECUTIVE SUMMARY

This document provides a complete functional map of the TAO 1.0 Contacts module from a feature perspective. Each feature is documented with:

- User-facing functionality
- Files that implement it
- Tables and columns touched
- Business rules and workflows
- Data flow (page → service → database → UI)
- Migration notes and recommendations

---

## TABLE OF CONTENTS

1. [Contact List & Search Features](#1-contact-list--search-features)
2. [Contact Detail & View Features](#2-contact-detail--view-features)
3. [Contact Creation & Editing](#3-contact-creation--editing)
4. [Contact Items Management](#4-contact-items-management)
5. [Tag Management](#5-tag-management)
6. [Contact Import Features](#6-contact-import-features)
7. [Duplicate Detection & Merge](#7-duplicate-detection--merge)
8. [Avatar & Photo Management](#8-avatar--photo-management)
9. [Contact Relationships & Systems](#9-contact-relationships--systems)
10. [Events & Appointments Integration](#10-events--appointments-integration)
11. [Audition Integration](#11-audition-integration)
12. [Notes & History](#12-notes--history)
13. [Sharing & Collaboration](#13-sharing--collaboration)
14. [Special Features](#14-special-features)
15. [Backend/Automation Features](#15-backendautomation-features)

---

## 1. CONTACT LIST & SEARCH FEATURES

### 1.1 All Contacts List

**Feature:** View all contacts in a paginated, searchable, sortable table

**User flow:**
1. Navigate to app/contacts/
2. See all contacts owned by user
3. Filter by system (All/Target/Follow-Up/Maintenance/No System)
4. Search by name
5. Sort by columns
6. Bulk select for batch operations

**Files:**
- **Main page:** app/contacts/index.cfm
- **Template:** include/contacts.cfm
- **Table layout:** include/contacts_table.cfm
- **Grid layout:** include/contacts_grid.cfm
- **Query:** ContactService.cfc:list(), ContactSSService.cfc:SELcontacts_ss()

**Tables used:**
- contacts_ss (view) - pre-joined contact + items for performance
- contactdetails (filtered by userid, isdeleted=0)
- contactitems (joined for email, phone, company - via contacts_ss view)

**Columns displayed:**
- col1 (contactFullName or recordname) - name
- col2 (tags) - tag badges
- col3 (phone) - first active phone
- col4 (email) - first active email
- col5 (company) - first active company
- avatar (contactphoto) - contact photo
- hlink - link to contact detail page

**Business rules:**
- Only show contacts where userid = current user (multi-tenancy)
- Only show where isdeleted = 0 (soft delete filter)
- Default filter: All contacts (no system filter)
- contacts_ss view uses primary_yn='Y' to show "first" email/phone/company

**Features:**
- **Search:** ContactService.list() with search parameter - searches contactFullName and recordname (LIKE '%search%')
- **Filters:**
  - By Tag: Filter by specific tag (valuetext)
  - By Import: Filter by uploadid (contacts from specific import)
  - By System: Target/Follow-Up/Maintenance/No System tabs
  - By Status: Active/Inactive dropdown
- **Sorting:** DataTables client-side sorting on all columns
- **Pagination:** DataTables pagination (configurable rows per page)
- **Bulk actions:** Checkboxes for batch operations (add to system, delete)

**Data flow:**
```
User → app/contacts/ → include/contacts.cfm
  → ContactSSService.SELcontacts_ss() OR contacts_ss view query
    → SELECT from contacts_ss WHERE userid=:userid
      → Returns: contactid, col1, col2, col3, col4, col5, avatar, hlink
        → DataTables renders paginated table
```

**Migration notes:**
- contacts_ss view is performance-critical (pre-joins items)
- col1/col2/col3/col4/col5 naming is cryptic - rename in TAO 2.0
- Consider materialized view or cached table for large datasets
- Search only covers name fields - consider full-text search across all fields
- Pagination is client-side (DataTables) - consider server-side for 1000+ contacts

---

### 1.2 System-Filtered Contact Lists

**Feature:** View contacts filtered by relationship system (Targeting, Follow-Up, Maintenance, No System)

**User flow:**
1. Navigate to app/contacts/ with system tabs
2. Click tab: All / Target / Follow-Up / Maintenance / No System
3. See contacts filtered by active system

**Files:**
- **Main page:** app/contacts/index.cfm
- **Template:** include/contacts_all_tabs.cfm
- **Views used:**
  - contacts_ss (All)
  - contacts_ss_target (Target tab)
  - contacts_ss_followup (Follow-Up tab)
  - contacts_ss_maint (Maintenance tab)

**Tables used:**
- contacts_ss* views (filtered by fusystemusers)
- fusystemusers (JOIN WHERE systemtype='Targeting'/'Follow-Up'/'Maintenance')

**Business rules:**
- Target tab: JOIN fusystemusers WHERE systemtype='Targeting' AND suStatus='Active'
- Follow-Up tab: JOIN fusystemusers WHERE systemtype='Follow-Up' AND suStatus='Active'
- Maintenance tab: JOIN fusystemusers WHERE systemtype='Maintenance' AND suStatus='Active'
- No System tab: LEFT JOIN fusystemusers WHERE fusystemusers IS NULL (no active systems)
- All tab: No system filter

**Data flow:**
```
User clicks tab → include/contacts_all_tabs.cfm with system filter
  → Query appropriate contacts_ss_* view
    → View filters by fusystemusers.systemtype
      → Returns contacts in that system
        → DataTables renders
```

**Migration notes:**
- contacts_ss_* views are pre-filtered for performance
- Consider dynamic filtering instead of separate views
- No System tab requires LEFT JOIN - ensure performance optimization

---

### 1.3 My Team View

**Feature:** Special view of contacts tagged with "My Team" (agents, managers, core team)

**User flow:**
1. Access My Team view (exact URL not found in scanned files)
2. See contacts with 'My Team' tag
3. Card layout with photo, name, title, email, phone, company

**Files:**
- **Service:** ContactService.cfc:GetMyTeam()
- **Display:** (File not found - likely app/myteam/ or include/myteam_pane.cfm)

**Tables used:**
- contactdetails (filtered by userid, isdeleted=0)
- contactitems WHERE valueCategory='Tag' AND valuetext='My Team'

**Query (ContactService.GetMyTeam - not fully visible):**
```sql
SELECT contacts WHERE EXISTS (
  SELECT 1 FROM contactitems
  WHERE contactid=contacts.contactid
  AND valueCategory='Tag'
  AND valuetext='My Team'
  AND itemStatus='Active'
)
```

**Business rules:**
- Only contacts with 'My Team' tag appear
- Tag added via ContactItemService.addTeam()
- Tag removed via ContactItemService.deleteTeam() (HARD DELETE - bug?)
- Cannot add 'My Team' tag twice to same contact (duplicate check)

**Display:**
- Card layout (not table)
- Shows: name, title (from tags?), email, phone, company
- Likely larger photos/avatars for visual recognition

**Migration notes:**
- 'My Team' is special tag with dedicated UI
- Consider separate team management interface
- Fix deleteTeam() HARD DELETE → soft delete

---

### 1.4 Contact Search/Autocomplete

**Feature:** Quick lookup of contacts by name (used in forms, modals, referral selection)

**User flow:**
1. Type in contact lookup field
2. See autocomplete suggestions
3. Select contact from dropdown

**Files:**
- **AJAX endpoint:** app/assets/js/autolookup.cfm, autolookupbackup.cfm
- **Query:** include/qry/lookup_contacts.cfm
- **Service:** LookupService.cfc

**Tables used:**
- contactdetails (search contactFullName and recordname)
- Possibly IMDb database (UNION in lookup_contacts.cfm per code comment)

**Query pattern:**
```sql
SELECT contactid, contactFullName, recordname
FROM contactdetails
WHERE userid = :userid
  AND isdeleted = 0
  AND (contactFullName LIKE :search OR recordname LIKE :search)
UNION
SELECT ... FROM imdb.recordname WHERE ... (IMDb integration)
ORDER BY contactFullName
LIMIT 20
```

**Business rules:**
- Search both contactFullName and recordname
- Case-insensitive LIKE '%term%'
- Limit 20 results for performance
- IMDb database integration (actors can search IMDb and create contact)

**Returns:** JSON array for autocomplete widget

**Data flow:**
```
User types → AJAX call to autolookup.cfm with term parameter
  → lookup_contacts.cfm query
    → Returns JSON: [{contactid, name}, ...]
      → Autocomplete widget displays suggestions
        → User selects → contactid used in form
```

**Migration notes:**
- IMDb integration is unique feature - preserve if API still available
- Consider full-text search index for better performance
- Limit 20 may be too restrictive - make configurable
- Add fuzzy matching for typos?

---

## 2. CONTACT DETAIL & VIEW FEATURES

### 2.1 Contact Detail Page (Tabbed View)

**Feature:** Comprehensive contact information display with tabs for different data types

**User flow:**
1. Click contact from list → app/contact/?contactid=X&ctaction=view
2. See contact detail with 4 tabs:
   - **Tab 1 (t1=1):** Contact Info (default)
   - **Tab 2 (t2=1):** Appointments/Events
   - **Tab 3 (t3=1):** Notes
   - **Tab 4 (t4=1):** Relationships/Systems

**Files:**
- **Main page:** app/contact/index.cfm
- **Template:** include/contact_info.cfm
- **Tab content:**
  - contact_expand (tab 1 - contact info)
  - appointments_expand (tab 2 - include/appointments_pane.cfm)
  - notes_expand (tab 3 - include/notes_event_pane.cfm)
  - relationship_expand (tab 4 - include/aud_rel_pane.cfm or similar)

**Services:**
- ContactService.cfc:read(contactid) - main contact data
- ContactItemService.cfc:itemsbycatActive() - contact items by category
- EventService.cfc - events for tab 2
- NoteService.cfc - notes for tab 3
- ContactService.cfc:ru() - relationship updates for tab 4

**Tables used:**
- contactdetails (main contact data)
- contactitems (all items grouped by category)
- itemcategory (category metadata - icons, fieldsets)
- eventcontactsxref + events (tab 2)
- noteslog (tab 3)
- fusystemusers (tab 4)

**Tab 1 - Contact Info displays:**
- **Header:**
  - Avatar (contactphoto)
  - Name (contactFullName)
  - Nickname (contactNickname) - editable inline
  - Pronoun (contactPronoun) - dropdown: He/She/They/Custom
- **Contact Details:**
  - Birthday (contactBirthday) - date picker with age calc
  - Meeting Date (contactMeetingDate) - when you met
  - Meeting Location (contactMeetingLoc) - where you met
  - Referred By (refer_contact_id) - link to referrer contact
- **Contact Items (grouped by category):**
  - Emails (valueCategory='Email') - Business/Personal/Work types
  - Phones (valueCategory='Phone') - Work/Mobile/Home types
  - Addresses (valueCategory='Address') - Business/Work/Home types with full address display
  - Companies (valueCategory='Company') - Company name, department, title
  - URLs (valueCategory='URL') - Company Website, custom URLs
  - Social Profiles (valueCategory='Social Profile') - Facebook/Twitter/Instagram/LinkedIn with icons
  - Acting Links (valueCategory='Acting Links') - IMDb/Actors Access/etc with icons
  - Tags (valueCategory='Tag') - Tag badges (blue pills)
- **Feature Flags:**
  - Newsletter subscription (newsletter_yn) - checkbox
  - Google alerts (googlealert_yn) - checkbox
  - Social media tracking (socialmedia_yn) - checkbox
- **Actions:**
  - Edit buttons for each section (modal forms)
  - Add buttons for each category (modal forms)
  - Delete buttons for items

**Tab 2 - Appointments/Events:**
- DataTable of events contact attended (dt_eventscontact.cfm)
- Shows: event date, event type, event name, project (if audition)
- Click event → event detail page

**Tab 3 - Notes:**
- DataTable of notes about contact (dt_notescontact.cfm)
- Shows: note date, note text (truncated), note type (contact/event/audition)
- Add note button → modal with rich text editor (Quill.js)

**Tab 4 - Relationships/Systems:**
- Active relationship systems for contact
- Shows: system name, system status, next action, due date
- Link to system detail → fusystemusers management

**Business rules:**
- contactid and userid required (security - can only view own contacts)
- ctaction=view parameter controls display mode (view vs edit - code suggests edit mode too)
- Default tab is t1=1 (Contact Info)
- Items grouped by valueCategory with icons from itemcategory.caticon
- primary_yn='Y' items highlighted or shown first
- isDeleted=1 items hidden from display

**Data flow:**
```
User clicks contact → app/contact/?contactid=X&ctaction=view
  → include/contact_info.cfm
    → ContactService.read(contactid) - get main contact data
    → For each category in itemcategory.getActiveCategories():
      → ContactItemService.itemsbycatActive(contactid, category)
        → Returns items for that category
          → Display section with category icon, items list, add/edit/delete buttons
    → Tab 2: EventService.getEventsByContact(contactid)
    → Tab 3: NoteService.getNotesByContact(contactid)
    → Tab 4: ContactService.ru(contactid) - relationship updates
      → Render all sections
```

**Migration notes:**
- Comprehensive view - good UX
- Tabbed layout keeps info organized
- Consider lazy-loading tabs (don't query tabs 2-4 until clicked)
- DataTables on tabs 2-3 provide good UX - keep
- Contact items section could be heavy with many items - paginate?
- Avatar upload via modal - consider inline drag-drop

---

### 2.2 Contact Card/Panel Component

**Feature:** Compact contact summary card (used in modals, sidebars, popups)

**User flow:**
1. View contact card in sidebar or modal
2. See compact view: photo, name, primary email/phone, tags
3. Click → full contact detail

**Files:**
- **Template:** include/contact_pane.cfm
- **Service:** ContactService.cfc:read() or contacts_ss view

**Displays:**
- Avatar (small)
- Name
- Primary email (first email with primary_yn='Y')
- Primary phone (first phone with primary_yn='Y')
- Tags (as badges)
- Quick action buttons (edit, delete, view full)

**Migration notes:**
- Reusable component - good pattern
- Ensure consistent with full detail view
- Consider Web Components for reusability

---

### 2.3 Contact View (Alternative Layout)

**Feature:** Alternative contact view layout (purpose unclear - possibly print view?)

**Files:**
- **Template:** include/contact_view.cfm
- **Service:** Same as contact_info.cfm

**Migration note:** Clarify use case vs contact_info.cfm - may be redundant

---

## 3. CONTACT CREATION & EDITING

### 3.1 Quick Add Contact

**Feature:** Create new contact with minimal info (name), then fill in details later

**User flow:**
1. Click "Add Contact" button
2. Modal or page loads
3. Enter name (or skip - defaults to "Unknown")
4. Submit → contact created
5. Redirect to contact detail page for full data entry

**Files:**
- **Form:** include/contact_add.cfm
- **Handler:** ContactService.cfc:create()
- **Redirect:** app/contact/?contactid=X&ctaction=view

**Required fields:**
- userid (auto-filled from session)
- contactFullName (or defaults to "Unknown")

**Optional fields:**
- All other contactdetails fields can be provided but not required

**Default values:**
- contactFullName = "Unknown" if not provided
- contactStatus = 'Active' (likely DB default)
- isdeleted = 0
- contactCreationDate = CURRENT_TIMESTAMP

**Post-creation:**
- Folder structure created (via folder_setup.cfm - see feature 15.5)
- Redirect to contact detail page (ctaction=view)

**Business rules:**
- Minimum data required → fast contact creation
- User can create placeholder "Unknown" contacts during events/meetings and fill in later

**Data flow:**
```
User → Click "Add Contact" → include/contact_add.cfm form
  → Submit → ContactService.create(dataStruct)
    → INSERT INTO contactdetails (userid, contactFullName, ...)
      → Returns contactid (auto-increment)
        → Redirect to app/contact/?contactid=X&ctaction=view
          → User fills in rest of details via inline editing
```

**Migration notes:**
- "Unknown" contact creation is interesting pattern - allows quick capture
- Consider requiring at least name or company (avoid too many "Unknown" contacts)
- Auto-folder creation may not be needed in TAO 2.0 (cloud storage?)

---

### 3.2 Inline Editing (Contact Fields)

**Feature:** Edit contact fields directly on detail page without full form reload

**User flow:**
1. View contact detail page
2. Click edit icon next to field (name, nickname, birthday, etc.)
3. Inline editor appears (text input, date picker, dropdown)
4. Edit value
5. Click save → AJAX update
6. Field updates without page reload

**Files:**
- **AJAX endpoints:**
  - include/remoteUpdateName.cfm - name editing
  - include/remoteUpdateNameUpdate.cfm - name update handler
  - include/remoteUpdateEssenceContact.cfm - other field updates (inferred from filename)
- **Service:** ContactService.cfc:update(contactid, dataStruct)

**Editable fields (via inline editing):**
- contactFullName (name)
- contactNickname (nickname)
- recordname (professional name)
- contactPronoun (pronoun dropdown)
- contactBirthday (date picker)
- contactMeetingDate (date picker)
- contactMeetingLoc (text input)
- refer_contact_id (contact lookup autocomplete)
- newsletter_yn (checkbox)
- googlealert_yn (checkbox)
- socialmedia_yn (checkbox)

**Business rules:**
- Only update field being edited (partial update)
- ContactService.update() uses dynamic UPDATE with only provided fields
- contactLastUpdated auto-updated (DB trigger?)

**Data flow:**
```
User → Click edit icon → Inline editor appears
  → User changes value → Click save
    → AJAX POST to remoteUpdate*.cfm
      → ContactService.update(contactid, {field: newValue})
        → UPDATE contactdetails SET field = :newValue WHERE contactid = :contactid
          → Returns success
            → AJAX callback updates displayed value
```

**Migration notes:**
- Inline editing provides excellent UX - keep in TAO 2.0
- Consider using modern inline editing library (e.g., X-Editable successor)
- Ensure validation on AJAX calls (don't trust client)
- Add optimistic UI updates (update display immediately, rollback if error)

---

### 3.3 Modal Form Editing (Contact Items)

**Feature:** Add/edit contact items (emails, phones, addresses, etc.) via modal forms

**User flow:**
1. View contact detail page
2. Click "Add Email" (or Phone, Address, etc.)
3. Modal form appears with category-specific fields
4. Fill form (type, value, etc.)
5. Submit → AJAX add
6. Modal closes, item appears in contact detail

**Files:**
- **Add forms:** include/remoteaddC.cfm (modal form for each category)
- **Edit forms:** include/remoteUpdateC.cfm (modal form for editing items)
- **Add handler:** include/remoteAddCAdd.cfm (form processor)
- **Update handler:** include/remoteUpdateCUpdate.cfm (update processor)
- **Services:**
  - ContactItemService.cfc:INScontactitems_* (legacy insert methods)
  - ContactItemService.cfc:UPDcontactitems_* (legacy update methods)

**Form fields vary by category (see tao1_contactitems_type_category_map.md):**

**Email form (valueCategory='Email'):**
- valueType dropdown: Business/Personal/Work
- valuetext input: email address (email validation)
- primary_yn checkbox: Is this primary email?

**Phone form (valueCategory='Phone'):**
- valueType dropdown: Work/Mobile/Home
- valuetext input: phone number (phone validation)
- primary_yn checkbox: Is this primary phone?

**Address form (valueCategory='Address'):**
- valueType dropdown: Business/Work/Home
- valueStreetAddress input: street address (required, min 5 chars)
- valueExtendedAddress input: apt/suite
- valueCity input: city
- valueRegion dropdown: state/province (chained to country)
- valueCountry dropdown: country (default US)
- valuePostalCode input: zip/postal code
- primary_yn checkbox: Is this primary address?

**Company form (valueCategory='Company'):**
- valueType: 'Company' (hidden - only one type)
- valueCompany dropdown: select existing or add custom (required)
- valueDepartment input: department (optional)
- valueTitle input: job title (optional)
- primary_yn checkbox: Is this primary company?

**URL form (valueCategory='URL'):**
- valueType dropdown: Company Website / custom types from itemtypes_user
- valuetext input: URL (URL validation, must start with http/https, no @ symbol)
- primary_yn checkbox: Is this primary URL?

**Social Profile form (valueCategory='Social Profile'):**
- valueType dropdown: Facebook/Twitter/Instagram/LinkedIn/custom from itemtypes_user
- valuetext input: profile URL (URL validation)
- Icon displayed based on itemtypes_user.typeIcon
- primary_yn checkbox

**Acting Links form (valueCategory='Acting Links'):**
- valueType dropdown: IMDb/Actors Access/Backstage/custom from itemtypes_user
- valuetext input: profile URL (URL validation)
- Icon displayed based on itemtypes_user.typeIcon
- primary_yn checkbox

**Business rules:**
- Category (valueCategory) passed via hidden field (from catid → itemcategory lookup)
- valueType required (except when only one type available)
- "Custom" option in valueType dropdown → shows custom type input field
- Form validation via Parsley.js (client-side + server-side)
- Address: Country/Region dropdowns use jquery.chained.js for cascading
- Company: Dropdown pre-populated with existing companies, "***ADD NEW***" option for custom

**Primary handling:**
- If user checks primary_yn='Y':
  - (Should) unset primary_yn for other items in same category
  - (Not visible in code - may be bug: multiple primaries possible)
- If no primary set and first item added → auto-set primary_yn='Y'

**Data flow (Add):**
```
User → Click "Add Email" → Modal loads include/remoteaddC.cfm?catid=10
  → include/qry/details_198_1.cfm → ItemCategoryService.DETitemcategory(catid)
    → Returns category details (valueCategory='Email', catfieldset='text', etc.)
  → include/qry/types_198_3.cfm → ItemCategoryService.SELitemcategory_24039(catid, userid)
    → Returns available types (Business, Personal, Work)
      → Form rendered with category-specific fields
        → User fills form → Submit
          → POST to include/remoteAddCAdd.cfm
            → ContactItemService.INScontactitems_* (varies by category)
              → INSERT INTO contactitems (contactid, valueCategory, valueType, valuetext/valueCompany/address fields, primary_yn, itemStatus='Active')
                → Returns itemid
                  → AJAX callback → Modal closes → Item appears on page
```

**Data flow (Edit):**
```
User → Click edit icon on item → Modal loads include/remoteUpdateC.cfm?itemid=X
  → Query existing item: ContactItemService.SELcontactitems_XXXXX(itemid)
    → Returns item data
      → Form pre-filled with current values
        → User edits → Submit
          → POST to include/remoteUpdateCUpdate.cfm
            → ContactItemService.UPDcontactitems_* (varies by category)
              → UPDATE contactitems SET ... WHERE itemid = :itemid
                → AJAX callback → Modal closes → Item updates on page
```

**Migration notes:**
- Modal forms provide good UX - keep pattern
- **HIGH PRIORITY:** Fix primary_yn enforcement (ensure only one primary per category)
- Category-specific forms (remoteaddC.cfm) are complex - consider form builder
- Validation with Parsley.js is good - migrate to modern validation library
- Company dropdown with custom option is good pattern
- Address cascading dropdowns (Country → Region) work well - keep
- Consider adding item notes field to UI (currently hidden)

---

### 3.4 Delete Contact (Soft Delete)

**Feature:** Delete contact (soft delete - sets isdeleted=1)

**User flow:**
1. View contact detail or list
2. Click delete button/icon
3. Confirm deletion (modal confirmation?)
4. Contact soft-deleted (isdeleted=1)
5. Contact hidden from all lists
6. (Optional recovery via database - no UI for undelete visible)

**Files:**
- **Single delete:** (File not found - likely AJAX endpoint)
- **Batch delete:** include/deleteContacts.cfm
- **Service:** ContactService.cfc:delete(contactid)

**Business rules:**
- **SOFT DELETE ONLY** - no hard deletes
- Sets isdeleted = 1 (NOT actual DELETE)
- Contact data retained in database
- Allows recovery if needed (no UI - database admin only)

**Related data handling:**
- contactitems remain (orphaned but intact)
- fusystemusers remain (systems deactivate?)
- eventcontactsxref remain (events still have contact link)
- noteslog remain (notes preserved)

**Data flow:**
```
User → Click delete → Confirm
  → AJAX call to delete endpoint
    → ContactService.delete(contactid)
      → UPDATE contactdetails SET isdeleted = 1 WHERE contactid = :contactid
        → Success
          → Contact hidden from lists (WHERE isdeleted = 0 filter)
```

**Migration notes:**
- Soft delete is correct approach - preserve data
- Add deleted_at timestamp (when deleted)
- Add deleted_by userid (who deleted)
- Add UI for "undelete" (admin feature)
- Consider archival (move old deleted contacts to archive table after X years)
- Handle related data: should systems auto-complete when contact deleted?

---

### 3.5 Batch Delete Contacts

**Feature:** Select multiple contacts and delete in one operation

**User flow:**
1. View contact list
2. Check boxes next to contacts
3. Click "Delete Selected" button
4. Confirm deletion
5. All selected contacts soft-deleted

**Files:**
- **Handler:** include/deleteContacts.cfm
- **Service:** ContactService.cfc:delete(contactid) called in loop

**Business rules:**
- Same soft delete as single contact
- Loop through contactid array
- All-or-nothing transaction? (Not visible in code)

**Data flow:**
```
User → Select contacts (checkboxes) → Click "Delete Selected"
  → Confirm → POST to include/deleteContacts.cfm with contactid array
    → Loop: FOR EACH contactid
      → ContactService.delete(contactid)
        → UPDATE contactdetails SET isdeleted = 1
          → Success → Next contact
            → All deleted → Redirect to contact list
```

**Migration notes:**
- Add transaction wrapper (all succeed or all fail)
- Add progress indicator for large batches
- Consider soft delete with "undo" option (30-second grace period)

---

## 4. CONTACT ITEMS MANAGEMENT

_(Covered in section 3.3 - Modal Form Editing)_

**Additional features:**

### 4.1 Delete Contact Item (Soft Delete)

**Feature:** Remove specific contact item (email, phone, etc.)

**User flow:**
1. View contact detail
2. Click delete icon on item
3. Confirm deletion
4. Item soft-deleted (isDeleted=1)
5. Item hidden from contact detail

**Files:**
- **Service:** ContactItemService.cfc:UPDcontactitems() with isDeleted=1

**Business rules:**
- Soft delete: UPDATE contactitems SET isDeleted = 1
- Exception: deleteTeam() does HARD DELETE (bug? - line 67)

**Migration note:** Fix deleteTeam() to use soft delete

---

### 4.2 Set Primary Item

**Feature:** Designate one email/phone/address/company as "primary"

**User flow:**
1. View contact detail
2. Click "Set Primary" on item
3. Item marked primary_yn='Y'
4. Other items in same category set primary_yn='N'
5. contacts_ss view updates to show new primary item

**Files:**
- **Service:** ContactItemService.cfc:UPDcontactitems() with primary_yn='Y'

**Business rules:**
- Only ONE primary per category per contact
- **BUG:** No enforcement in database (no unique constraint)
- **BUG:** No visible code to unset other primaries (may allow multiple primaries)

**Migration note:** **HIGH PRIORITY** - Add unique constraint, fix update logic to unset other primaries

---

## 5. TAG MANAGEMENT

### 5.1 Add Tag to Contact

**Feature:** Add tag to contact for categorization and filtering

**User flow:**
1. View contact detail
2. Click "Add Tag" button
3. Enter tag name (autocomplete from existing tags) OR select from dropdown
4. Submit → tag added
5. Tag appears as badge on contact

**Files:**
- **Form:** (Likely modal - file not found)
- **Service:** ContactItemService.cfc:addContactItemsTag(), INScontactitems_24049()

**Business rules:**
- Tag name max 40 chars (enforced by LEFT(tagname, 40) in queries)
- Duplicate tag check (can't add same tag twice to same contact)
- Tag creates contactitems record:
  - valueCategory = 'Tag'
  - valueType = 'Tags'
  - valuetext = tag name
  - itemStatus = 'Active'
- If tag exists in tags_user WHERE tagtype='C' → contact becomes Casting Director scope

**Casting Director detection:**
- ContactItemService.getContactTagStatus(contactid, userid)
- Checks if contact has tag in tags_user WHERE tagtype='C'
- If yes → systemscope = 'Casting Director' → enables Targeting/Follow-Up systems
- If no → systemscope = 'Industry' → different system workflows

**Data flow:**
```
User → Click "Add Tag" → Modal with tag input/dropdown
  → User types tag name → Autocomplete shows existing tags
    → User selects or creates new tag
      → Submit
        → ContactItemService.addContactItemsTag(contactid, tagname)
          → INSERT INTO contactitems (contactid, valueCategory='Tag', valueType='Tags', valuetext=tagname, itemStatus='Active')
            → Check if tagname in tags_user WHERE tagtype='C'
              → If yes: Update relationship system scope to 'Casting Director'
                → Tag badge appears on contact detail
```

**Migration notes:**
- Tag-based system scope is CRITICAL business logic - must migrate carefully
- tags_user.tagtype='C' mapping must be preserved
- Consider separate tag table (many-to-many) vs EAV for performance
- Max 40 chars is reasonable - enforce with CHECK constraint
- Autocomplete for tags is good UX - keep

---

### 5.2 Remove Tag from Contact

**Feature:** Remove tag from contact

**User flow:**
1. View contact detail
2. Click X on tag badge
3. Confirm removal
4. Tag removed from contact
5. If Casting Director tag removed → system scope may change to Industry

**Files:**
- **Service:** ContactItemService.cfc:DELcontactitems()

**Business rules:**
- Soft delete? (isDeleted = 1) OR hard delete?
- If Casting Director tag removed → re-evaluate system scope
- Systems may need to be updated/completed if scope changes

**Data flow:**
```
User → Click X on tag badge → Confirm
  → ContactItemService.DELcontactitems(itemid)
    → UPDATE/DELETE contactitems WHERE itemid = :itemid
      → Re-evaluate system scope (getContactTagStatus)
        → If scope changed: Update fusystemusers?
          → Tag badge disappears
```

**Migration note:** Clarify soft vs hard delete for tags

---

### 5.3 Add "My Team" Tag (Special)

**Feature:** Add contact to "My Team" (special tag for core team members)

**User flow:**
1. View contact detail or list
2. Click "Add to My Team" button
3. 'My Team' tag added
4. Contact appears in My Team view

**Files:**
- **Service:** ContactItemService.cfc:addTeam(userid, contactname)

**Business rules:**
- Special tag: valuetext = 'My Team'
- Uses contacts_ss.col1 to find contact by name (line 50)
- Adds tag with primary_yn='Y' (unusual for tags)
- LIMIT 1 (only adds to first matching contact)
- Duplicate check (can't add twice)

**Data flow:**
```
User → Click "Add to My Team"
  → ContactItemService.addTeam(userid, contactname)
    → INSERT INTO contactitems (contactid, valueType='Tags', valueCategory='Tag', valuetext='My Team', itemStatus='Active', primary_yn='Y')
      → (Uses SELECT from contacts_ss WHERE col1=contactname to get contactid)
        → Tag added → Contact appears in My Team view
```

**Migration notes:**
- 'My Team' is special tag with dedicated feature
- primary_yn='Y' for tags is unusual (tags don't typically have primary)
- Lookup by name (col1) is fragile - consider lookup by contactid

---

### 5.4 Remove "My Team" Tag (Special)

**Feature:** Remove contact from "My Team"

**User flow:**
1. View My Team or contact detail
2. Click "Remove from Team" button
3. 'My Team' tag removed
4. Contact disappears from My Team view

**Files:**
- **Service:** ContactItemService.cfc:deleteTeam(contactid)

**Business rules:**
- **BUG:** HARD DELETE (line 67-70) - inconsistent with soft delete pattern
- Deletes from contactitems_tbl (base table) not view

**Code (line 64-70):**
```
DELETE FROM contactitems_tbl
WHERE contactid = :contactid
  AND valuetext = 'My Team'
```

**Migration note:** **BUG FIX** - Change to soft delete (UPDATE SET isDeleted=1)

---

### 5.5 Batch Add Tags (Tag Group Operation)

**Feature:** Add same tag to multiple contacts at once

**User flow:**
1. View contact list
2. Select multiple contacts (checkboxes)
3. Click "Add Tag" button
4. Enter/select tag name
5. Submit → tag added to all selected contacts

**Files:**
- **Handler:** include/tmpcontacttags.cfm (inferred from filename)

**Migration note:** Batch operations improve efficiency - include in TAO 2.0

---

## 6. CONTACT IMPORT FEATURES

### 6.1 CSV Contact Import

**Feature:** Import contacts from CSV file with validation, duplicate detection, and review

**User flow:**
1. Navigate to app/contacts-import-v3/
2. Download CSV template (optional)
3. Upload completed CSV file
4. System stages to contactsimport table
5. Validation runs (email format, required fields)
6. Duplicate detection (name + email matching)
7. Review interface shows:
   - New contacts (will be added)
   - Duplicates (matched to existing contacts)
   - Errors (validation failures)
8. User confirms/adjusts
9. System creates/updates contacts
10. Import results summary

**Files:**
- **Main page:** app/contacts-import-v3/index.cfm
- **Template:** include/import-contacts.cfm
- **Template download:** include/download_contact_template.cfm
- **Services:**
  - ContactImportService.cfc - manages contactsimport table, import workflow
  - ContactImportValidationService.cfc - email validation, duplicate detection
  - ContactService.cfc:INScontactdetails_24399() - creates contacts from import
- **Scheduled batch:** sched/import-contacts.cfm (automated imports?)

**CSV template columns:**
- First Name
- Last Name
- Email
- Phone
- Company
- Department
- Title
- Street Address
- Extended Address (Apt/Suite)
- City
- Region (State)
- Country
- Postal Code
- Birthday
- Meeting Date
- Meeting Location
- Tags (comma-separated?)
- (Possibly more - template file not fully visible)

**contactsimport table workflow:**

**Stage 1 - Upload:**
```sql
INSERT INTO contactsimport (uploadid, firstName, lastName, email, phone, company, ... , status='Pending')
VALUES (...) -- One row per CSV row
```

**Stage 2 - Validation:**
- ContactImportValidationService.cfc validates each row:
  - Email format check
  - Required fields check
  - UPDATE contactsimport SET status='Error', error_message=... WHERE validation fails

**Stage 3 - Duplicate detection:**
- Match by (firstName + lastName) OR (email):
  ```sql
  SELECT contactid FROM contactdetails
  WHERE userid = :userid
    AND isdeleted = 0
    AND (
      (contactFullName = CONCAT(firstName, ' ', lastName))
      OR
      EXISTS (SELECT 1 FROM contactitems
              WHERE contactid=contactdetails.contactid
                AND valueCategory='Email'
                AND valuetext=:email)
    )
  ```
- If match found:
  - UPDATE contactsimport SET contactid=:matchedContactId, status='Duplicate'
- Else:
  - Leave status='Pending' (will be created)

**Stage 4 - User review:**
- Display staged contacts grouped by status:
  - **Pending (New):** Will be added
  - **Duplicate:** Matched to existing contact (show match, allow override)
  - **Error:** Validation failed (show error, allow edit/skip)
- User actions:
  - Confirm add (Pending → Added)
  - Skip (any status → Skipped)
  - Override duplicate (Duplicate → Pending - force create new)
  - Edit and re-validate (Error → Pending)

**Stage 5 - Import execution:**
- ContactService.INScontactdetails_24399() for each Pending row:
  ```
  IF contactsimport.status = 'Pending' THEN
    CREATE contact from contactsimport data
    INSERT contactdetails (...)
    INSERT contactitems for email, phone, address, company, tags
    UPDATE contactsimport SET contactid=:newContactId, status='Added'
  END IF
  ```
- For Duplicates (if user chose to update):
  ```
  UPDATE existing contact with new data
  UPDATE contactsimport SET status='Updated'
  ```

**Stage 6 - Results:**
- Summary page:
  - X contacts added
  - X contacts updated
  - X duplicates skipped
  - X errors
- Link to view new contacts (filter by uploadid)

**Business rules:**
- uploadid groups import batch (GUID or timestamp)
- Duplicate match: Name OR Email (inclusive OR)
- Email validation: basic format check
- Required fields: First Name, Last Name (Email optional but recommended)
- Tags: comma-separated in CSV → split and create multiple contactitems
- Addresses: Only import if Street Address provided
- Companies: Create company contactitem if Company name provided

**Data flow:**
```
User uploads CSV → parse CSV → FOR EACH row:
  → INSERT INTO contactsimport (uploadid, firstName, lastName, ..., status='Pending')
    → END LOOP
      → Validation: FOR EACH contactsimport WHERE uploadid=:uploadid
        → Validate email, required fields
          → If error: UPDATE SET status='Error'
            → END LOOP
              → Duplicate detection: FOR EACH contactsimport WHERE status='Pending'
                → Search contactdetails + contactitems for match
                  → If match: UPDATE SET contactid=:matchId, status='Duplicate'
                    → END LOOP
                      → User reviews → Confirms/adjusts
                        → Import execution: FOR EACH contactsimport WHERE status='Pending'
                          → Create contact + items
                            → UPDATE SET contactid=:newId, status='Added'
                              → END LOOP
                                → Display results summary
```

**Migration notes:**
- Multi-stage import with review is EXCELLENT UX - preserve in TAO 2.0
- Duplicate detection by Name OR Email is reasonable
- Consider fuzzy matching for duplicates (similar names, not just exact)
- Add option to merge duplicate fields (take new phone if exists, keep old email if not provided)
- contactsimport table should be archived/purged (move to contact_import_log)
- Template download is good feature - include customizable templates
- Consider drag-drop CSV upload
- Add progress indicator for large imports (AJAX polling?)
- Support for Excel files (.xlsx) in addition to CSV

---

### 6.2 Download Import Template

**Feature:** Download blank CSV template for contact import

**User flow:**
1. Navigate to import page
2. Click "Download Template" link
3. CSV file downloads with header row
4. User fills template with contact data
5. Upload completed CSV

**Files:**
- **Handler:** include/download_contact_template.cfm

**Template structure:**
- Header row with column names
- Example row (optional - commented out?)
- Blank rows for data entry

**Migration note:** Consider multiple template formats (CSV, Excel, Google Sheets link)

---

### 6.3 Import from IMDb (Inferred)

**Feature:** Search IMDb database and import actor/industry professional as contact

**Evidence:**
- include/qry/lookup_contacts.cfm has UNION with imdb.recordname
- Suggests IMDb database integration

**User flow (inferred):**
1. Search for contact name
2. IMDb results appear in autocomplete
3. Select IMDb result
4. Create contact from IMDb data (name, photo, credits?)

**Migration note:** Unique feature for actors - preserve if IMDb API available

---

## 7. DUPLICATE DETECTION & MERGE

### 7.1 Find Duplicate Contacts

**Feature:** Identify potential duplicate contacts by name or email

**User flow:**
1. Navigate to app/contact-duplicates/
2. See list of potential duplicates:
   - Grouped by matching name (same contactFullName)
   - Grouped by matching email (same email valuetext)
3. Select duplicates to merge

**Files:**
- **Main page:** app/contact-duplicates/contact-duplicates.cfm
- **Service:** ContactDuplicateService.cfc:findDuplicatesByName(), findDuplicatesByEmail()
- **Query files:**
  - include/qry/duplicatesByName.cfm
  - include/qry/duplicatesByEmail.cfm

**Duplicate detection logic:**

**By Name:**
```sql
SELECT contactFullName, COUNT(*) as dupes
FROM contactdetails
WHERE userid = :userid
  AND isdeleted = 0
GROUP BY contactFullName
HAVING COUNT(*) > 1
ORDER BY dupes DESC
```

**By Email:**
```sql
SELECT ic.valuetext AS email, COUNT(DISTINCT d.contactid) as dupes
FROM contactdetails d
JOIN contactitems ic ON ic.contactid = d.contactid
WHERE d.userid = :userid
  AND d.isdeleted = 0
  AND ic.valueCategory = 'Email'
  AND ic.itemStatus = 'Active'
GROUP BY ic.valuetext
HAVING COUNT(DISTINCT d.contactid) > 1
ORDER BY dupes DESC
```

**Display:**
- Grouped by match value (name or email)
- Shows all contacts that match
- For each contact: name, email, phone, company, tags
- Checkboxes to select which to keep (primary) and which to merge (duplicates)

**Migration notes:**
- Duplicate detection is essential feature - preserve
- Consider fuzzy matching (Levenshtein distance for names)
- Add detection by phone number
- Add detection by multiple criteria (name + email + phone)
- Show "confidence score" for matches (exact vs probable)

---

### 7.2 Merge Duplicate Contacts

**Feature:** Combine multiple duplicate contacts into one, preserving all data

**User flow:**
1. From duplicate detection page, select:
   - Primary contact (keepContactId) - this one stays
   - Duplicate contacts (mergeContactId) - these will be merged in
2. Review merge preview:
   - Show all contact items from both contacts
   - User selects which items to keep
3. Confirm merge
4. System executes merge:
   - Move all contactitems from duplicates to primary
   - Move all notes from duplicates to primary
   - Move all events from duplicates to primary
   - Move all systems from duplicates to primary
   - Soft-delete duplicate contacts
5. Redirect to primary contact detail

**Files:**
- **Interface:** include/merge_contacts_interface.cfm
- **Service:** ContactDuplicateService.cfc:mergeContacts(keepContactId, mergeContactId)

**Merge logic (ContactDuplicateService.mergeContacts):**

**Step 1: Transfer contactitems:**
```sql
-- Move items from duplicate to primary (skip duplicates)
UPDATE contactitems
SET contactid = :keepContactId
WHERE contactid = :mergeContactId
  AND itemid NOT IN (
    SELECT itemid FROM contactitems
    WHERE contactid = :keepContactId
      AND valueCategory = contactitems.valueCategory
      -- Avoid duplicate items in same category
  )
```

**Step 2: Transfer notes:**
```sql
UPDATE noteslog
SET contactid = :keepContactId
WHERE contactid = :mergeContactId
```

**Step 3: Transfer events:**
```sql
UPDATE eventcontactsxref
SET contactid = :keepContactId
WHERE contactid = :mergeContactId
  AND eventid NOT IN (
    SELECT eventid FROM eventcontactsxref
    WHERE contactid = :keepContactId
      -- Avoid duplicate event links
  )
```

**Step 4: Transfer systems:**
```sql
UPDATE fusystemusers
SET contactid = :keepContactId
WHERE contactid = :mergeContactId
  AND systemid NOT IN (
    SELECT systemid FROM fusystemusers
    WHERE contactid = :keepContactId
      -- Avoid duplicate systems
  )
```

**Step 5: Soft-delete duplicate:**
```sql
UPDATE contactdetails
SET isdeleted = 1
WHERE contactid = :mergeContactId
```

**Business rules:**
- Primary contact (keepContactId) is never modified (except adding items)
- Duplicate contact (mergeContactId) is soft-deleted (isdeleted=1)
- All contactitems moved UNLESS duplicate category already exists on primary
- All notes moved (no duplicate check - all notes preserved)
- All events moved UNLESS primary already linked to that event
- All systems moved UNLESS primary already in that system
- **NO UNDO** - merge is permanent (unless database recovery)

**Duplicate handling:**
- contactitems: If primary already has Email category, don't add duplicate's emails
- This may LOSE data (duplicate's emails not merged if primary has emails)
- Better logic: Merge ALL items, let user delete unwanted ones after

**Data flow:**
```
User → Duplicate detection page → Select primary and duplicates
  → Review merge preview → Confirm
    → ContactDuplicateService.mergeContacts(keepContactId, mergeContactId)
      → UPDATE contactitems SET contactid = keepContactId (with duplicate check)
      → UPDATE noteslog SET contactid = keepContactId
      → UPDATE eventcontactsxref SET contactid = keepContactId (with duplicate check)
      → UPDATE fusystemusers SET contactid = keepContactId (with duplicate check)
      → UPDATE contactdetails SET isdeleted = 1 WHERE contactid = mergeContactId
        → Commit transaction
          → Redirect to primary contact detail
```

**Migration notes:**
- **CRITICAL FEATURE** - duplicate management is essential
- **DATA LOSS RISK** - Current logic may skip duplicate's items if category exists
  - **Recommendation:** Merge ALL items, mark duplicates, let user clean up manually
- Add undo/rollback capability (transaction log, keep merge history)
- Add merge preview with diff view (show what will change)
- Add selective merge (user chooses which items to merge)
- Consider "master data management" approach (confidence scores, auto-merge rules)
- Add merge audit log (track all merges, who did it, when)

---

## 8. AVATAR & PHOTO MANAGEMENT

### 8.1 Upload Contact Avatar

**Feature:** Upload and crop photo for contact avatar

**User flow:**
1. View contact detail page
2. Click on avatar placeholder or existing avatar
3. Upload modal appears
4. Choose file (drag-drop or file picker)
5. Crop/resize with Croppie.js
6. Save → upload to server
7. Update contactdetails.contactphoto with file path
8. Avatar displays on contact detail and lists

**Files:**
- **Main page:** app/image-upload-contact/
- **Template:** include/image-upload-contact.cfm, include/image_upload-contact2.cfm
- **Cropping tool:** croppie.cfm (Croppie.js integration)
- **Service:** ContactService.cfc:update(contactid, {contactphoto: filePath})

**Business rules:**
- File upload to server file system (not database)
- contactphoto stores file path (e.g., "/uploads/avatars/12345_photo.jpg")
- File naming: likely userid_contactid_timestamp.ext for uniqueness
- Supported formats: JPG, PNG, GIF (inferred)
- Max file size: (not visible in code - likely 5MB?)
- Cropping: Square aspect ratio for consistent avatars

**Data flow:**
```
User → Click avatar → Upload modal appears
  → Choose file → File uploaded to temp location
    → Croppie.js displays image with crop UI
      → User adjusts crop → Saves
        → POST image data to upload handler
          → Save file to /uploads/avatars/userid_contactid_timestamp.jpg
            → ContactService.update(contactid, {contactphoto: filePath})
              → UPDATE contactdetails SET contactphoto = :filePath WHERE contactid = :contactid
                → Modal closes → Avatar displays on page
```

**Migration notes:**
- Croppie.js is good tool - consider modern alternative (Cropper.js, react-image-crop)
- Store files in cloud storage (S3, Azure Blob) instead of file system
- Generate thumbnails (small/medium/large) for performance
- Add default avatars (initials, colored background) for contacts without photos
- Support for webcam capture (take photo directly)
- Compress images on upload (reduce file size)

---

### 8.2 Batch Avatar Processing

**Feature:** Automated avatar processing/optimization (backend task)

**User flow:**
- No direct user interaction
- Scheduled task runs periodically

**Files:**
- **Scheduled tasks:** sched/avatar_loop.cfm, sched/avatar_loop2.cfm

**Purpose (inferred from filenames):**
- Resize/optimize existing avatars
- Generate thumbnails
- Fix broken file paths
- Migrate avatars to new storage

**Migration note:** Ensure avatar file paths are migrated correctly to TAO 2.0

---

## 9. CONTACT RELATIONSHIPS & SYSTEMS

### 9.1 View Contact Relationship Systems

**Feature:** See which relationship systems (Targeting, Follow-Up, Maintenance) contact is enrolled in

**User flow:**
1. View contact detail page
2. Click "Relationships" tab (t4=1)
3. See list of active systems for contact:
   - System name (Targeting, Follow-Up, Maintenance)
   - System status (Active, Completed, Skipped)
   - Next action due
   - Due date
4. Click system → view system detail (fusystemusers management)

**Files:**
- **Template:** include/aud_rel_pane.cfm or similar (exact file not found)
- **Service:** ContactService.cfc:ru() - relationship updates

**Tables used:**
- fusystemusers (WHERE contactid = :contactid AND suStatus = 'Active')
- fusystems (system definitions)
- funotifications (actions/notifications for each system)

**Displays:**
- System name
- Current step/action
- Next action description
- Due date (notstartdate)
- Progress indicator (X of Y actions complete)
- Links to notifications

**Business rules:**
- Only show Active systems (suStatus='Active')
- Completed systems hidden (suStatus='Completed')
- System scope (Casting Director vs Industry) determines which systems available

**Data flow:**
```
User → Click "Relationships" tab
  → ContactService.ru(contactid)
    → SELECT FROM fusystemusers WHERE contactid = :contactid AND suStatus = 'Active'
      → JOIN fusystems for system details
      → JOIN funotifications for next action
        → Returns active systems with next action info
          → Render relationship panel
```

**Migration note:** Relationship systems are CORE TAO feature - preserve fully

---

### 9.2 Add Contact to System (Batch)

**Feature:** Add contact(s) to relationship system (Targeting, Follow-Up, Maintenance)

**User flow:**
1. View contact list
2. Select contact(s) via checkboxes
3. Click "Add to System" dropdown
4. Choose system: Targeting / Follow-Up / Maintenance
5. Confirm → system(s) created
6. Contact enters system workflow (actions scheduled)

**Files:**
- **Handler:** include/tmpcontactgroups.cfm (inferred from filename)
- **Service:** SystemUserService.cfc (system creation)

**Business rules:**
- System scope check:
  - If contact has Casting Director tag → can use Targeting/Follow-Up
  - If contact has NO CD tag → can use Industry systems
- Cannot add to system already enrolled in (duplicate check)
- System creation triggers:
  - Create fusystemusers record (systemtype, contactid, userid, suStatus='Active')
  - Create first funotifications (actions) based on fusystems template

**Migration note:** Batch system enrollment is efficient - preserve

---

## 10. EVENTS & APPOINTMENTS INTEGRATION

### 10.1 View Contact Events

**Feature:** See all events/appointments contact attended

**User flow:**
1. View contact detail page
2. Click "Appointments" tab (t2=1)
3. See DataTable of events:
   - Event date
   - Event type (Meeting, Audition, Call, etc.)
   - Event name
   - Project (if audition)
   - Notes
4. Click event → event detail page

**Files:**
- **DataTable:** app/assets/js/dt_eventscontact.cfm
- **Service:** EventService.cfc:getEventsByContact(contactid)

**Tables used:**
- eventcontactsxref (WHERE contactid = :contactid)
- events (JOIN for event details)

**Query:**
```sql
SELECT e.eventid, e.eventStart, e.eventTypeName, e.eventName, e.audRoleID
FROM eventcontactsxref xref
JOIN events e ON e.eventid = xref.eventid
WHERE xref.contactid = :contactid
  AND xref.IsDeleted = 0
  AND e.IsDeleted = 0
ORDER BY e.eventStart DESC
```

**Business rules:**
- Only show events where contact was attendee (eventcontactsxref record exists)
- Sort by date descending (most recent first)
- DataTables provides pagination, sorting, search

**Migration note:** Events integration is important for context - preserve

---

### 10.2 Link Contact to Event

**Feature:** Add contact as attendee to event/appointment

**User flow:**
1. Create or edit event
2. Add attendees → contact lookup
3. Search/select contact
4. Save event → eventcontactsxref record created
5. Contact appears on event attendees list
6. Event appears on contact's events tab

**Files:**
- **Attendee selection:** include/contacts_attendees.cfm, include/contacts_table_attendees.cfm
- **Service:** EventContactsXRefService.cfc (CRUD for xref)

**Business rules:**
- Many-to-many: One event can have multiple contacts, one contact can attend multiple events
- No duplicate links (same contactid + eventid)
- eventcontactsxref.IsDeleted for soft delete

**Migration note:** Preserve many-to-many event-contact linking

---

### 10.3 Auto-Create Follow-Up System After Event

**Feature:** Automatically create Follow-Up system for contact after event completion

**User flow:**
- No direct user interaction (automated)
- User marks event as completed
- System checks if contact is in system
- If not, creates Follow-Up system automatically

**Files:**
- **Scheduled task:** sched/events_completed.cfm, sched/events_completed_wo_system.cfm

**Business rules (inferred):**
- When event marked completed:
  - FOR EACH contact linked to event (eventcontactsxref)
    - Check if contact in active system (fusystemusers)
    - If NOT in system AND contactStatus='Active':
      - Create Follow-Up system
      - Start first action (send follow-up email or note reminder)

**Migration note:** Automation is powerful feature - preserve with user controls (opt-in/opt-out)

---

## 11. AUDITION INTEGRATION

### 11.1 Link Contact to Audition Project

**Feature:** Associate casting director/industry contact with audition project

**User flow:**
1. View or edit audition project
2. Add casting contacts → contact lookup
3. Search/select contact
4. Optionally add notes about contact's role
5. Save → audcontacts_auditions_xref record created
6. Contact appears on project casting list

**Files:**
- **Service:** ContactAuditionService.cfc
- **Delete:** include/delete_audcontact.cfm

**Tables used:**
- audcontacts_auditions_xref (contactid, audprojectid, xrefnotes)
- audprojects (project details)

**Business rules:**
- Many-to-many: One project can have multiple casting contacts, one contact can be on multiple projects
- xrefnotes: Context about contact's involvement (e.g., "Requested breakdown", "Scheduled callback")

**Migration note:** Audition-contact link is industry-specific feature - preserve

---

### 11.2 View Contact Audition History

**Feature:** See all audition projects associated with contact (via sharez view)

**User flow:**
1. View contact in shared view (share/contact.cfm)
2. See audition history
3. Last audition step displayed (Callback, Avail, Booked, etc.)

**Files:**
- **View:** sharez view (complex query in database/rebuild_sharez_view.sql)

**Tables used:**
- audcontacts_auditions_xref (contact-project links)
- events (audition events WHERE audRoleID IS NOT NULL)
- audsteps (audition progression)

**sharez view audition logic (maxaudition subquery):**
```sql
-- Get highest audition step for contact
SELECT x.contactid, s.audstep
FROM audcontacts_auditions_xref x
JOIN events a ON a.audRoleID IS NOT NULL
JOIN audsteps s ON s.audstepid = a.audStepID
WHERE x.contactid = :contactid
  AND s.audstepid = (
    SELECT MAX(s2.audstepid)
    FROM audcontacts_auditions_xref x2
    JOIN events a2 ON a2.audRoleID IS NOT NULL
    JOIN audsteps s2 ON s2.audstepid = a2.audStepID
    WHERE x2.contactid = x.contactid
  )
```

**Displays:** Last audition step (e.g., "Callback", "Avail", "Booked")

**Migration note:** Audition tracking is valuable for actors - preserve with performance optimization

---

## 12. NOTES & HISTORY

### 12.1 View Contact Notes

**Feature:** See all notes about contact

**User flow:**
1. View contact detail page
2. Click "Notes" tab (t3=1)
3. See DataTable of notes:
   - Note date
   - Note text (truncated)
   - Note type (contact note, event note, audition note)
   - Public/private flag
4. Click note → expand full text or edit

**Files:**
- **DataTable:** app/assets/js/dt_notescontact.cfm
- **Service:** NoteService.cfc:getNotesByContact(contactid)

**Tables used:**
- noteslog (WHERE contactid = :contactid OR eventid IN (SELECT eventid FROM eventcontactsxref WHERE contactid = :contactid))

**Query:**
```sql
SELECT noteid, notetimestamp, noteDetails, notedetailshtml, isPublic, eventid, audprojectid
FROM noteslog
WHERE (contactid = :contactid OR eventid IN (
  SELECT eventid FROM eventcontactsxref WHERE contactid = :contactid
))
  AND isdeleted = 0
ORDER BY notetimestamp DESC
```

**Business rules:**
- Show notes directly about contact (contactid = :contactid)
- Show notes about events contact attended (eventid in eventcontactsxref)
- Show notes about audition projects contact is on (audprojectid in audcontacts_auditions_xref)
- Public notes (isPublic=1) can be shared with team
- Private notes (isPublic=0) only visible to owner

**Migration note:** Notes provide valuable context - preserve with rich text editing

---

### 12.2 Add Note About Contact

**Feature:** Create note about contact (or event, or audition)

**User flow:**
1. View contact detail → Notes tab
2. Click "Add Note" button
3. Modal appears with rich text editor (Quill.js)
4. Type note (max 2000 chars for noteDetails, unlimited for notedetailshtml)
5. Set public/private flag
6. Save → note created
7. Note appears in notes list

**Files:**
- **Note form:** share/assets/note-add-event.cfm, app/assets/js/note-add-event.cfm
- **Service:** NoteService.cfc:create() or INS* method

**Business rules:**
- noteDetails = plain text version (max 2000 chars)
- notedetailshtml = HTML version from Quill.js (unlimited)
- contactid = contact note is about (OR 0 if general note)
- eventid = event note is tied to (optional)
- audprojectid = audition note is tied to (optional)
- isPublic flag controls sharing
- notetimestamp auto-set to CURRENT_TIMESTAMP

**Data flow:**
```
User → Click "Add Note" → Modal with Quill.js editor
  → User types note → Click save
    → POST to note handler
      → NoteService.create({userid, contactid, noteDetails, notedetailshtml, isPublic})
        → INSERT INTO noteslog (userid, contactid, eventid, audprojectid, noteDetails, notedetailshtml, isPublic, notetimestamp, isdeleted=0)
          → Returns noteid
            → Modal closes → Note appears in DataTable
```

**Migration notes:**
- Rich text editing (Quill.js) is good UX - preserve or upgrade to modern editor
- 2000 char limit on noteDetails is restrictive - consider removing or expanding
- Public/private flag is important for sharing - preserve
- Consider tagging notes (categories: follow-up, feedback, general, etc.)
- Add note templates for common scenarios

---

## 13. SHARING & COLLABORATION

### 13.1 Share Contact Information

**Feature:** Share contact info with team or externally via sharez view

**User flow:**
1. Generate share link for contact
2. Share link with team or client
3. Recipient views contact info via share/contact.cfm
4. Limited view (no editing, only info display)

**Files:**
- **Share view:** share/contact.cfm, share/share_contact_details.cfm
- **Share service:** ShareService.cfc
- **Share view (DB):** sharez (complex view)

**Tables used:**
- sharez view (pre-joined contact + systems + events + auditions + notes)

**Displayed fields (from sharez view):**
- contactid
- NAME (recordname)
- Company (from contactitems)
- Title (from tags)
- Audition (last audition step)
- WhereMet (contactMeetingLoc)
- WhenMet (contactMeetingDate)
- NotesLog (NULL in optimized view - retrieve separately)
- last_met (last event date)
- no_mtgs (meeting count)
- lasteventtype (last event type)

**Business rules:**
- Only contacts IN active systems visible in sharez (fusystemusers filter)
- Public notes only (isPublic=1)
- No editing allowed on share view
- Possible authentication required (userHash in sharez view - LEFT(passwordHash, 10))

**Migration notes:**
- Sharing is valuable for collaboration - preserve
- sharez view is performance bottleneck (3-level view nesting) - optimize heavily
- Consider public share links with expiration
- Consider permission levels (view-only, edit, full access)
- Remove NotesLog GROUP_CONCAT (major performance killer - retrieve notes separately)

---

## 14. SPECIAL FEATURES

### 14.1 Birthday Tracking & Reminders

**Feature:** Track contact birthdays and show upcoming birthday reminders

**User flow:**
1. Enter birthday on contact detail (contactBirthday field)
2. Dashboard widget shows upcoming birthdays (next 15 days)
3. User sees reminder to send birthday message

**Files:**
- **Service:** BirthdayService.cfc
- **Query:** ContactService.cfc:SELcontactdetails_24617() (birthday query)
- **Cleanup:** sched/birthday_fix.cfm

**Query (inferred):**
```sql
SELECT contactid, contactFullName, contactBirthday,
       DATEDIFF(contactBirthday, CURDATE()) AS days_until
FROM contactdetails
WHERE userid = :userid
  AND isdeleted = 0
  AND contactBirthday IS NOT NULL
  AND DATEDIFF(contactBirthday, CURDATE()) BETWEEN 0 AND 15
ORDER BY days_until ASC
```

**Business rules:**
- Show birthdays in next 15 days
- Calculate age (current year - birth year)
- Sort by days until birthday (soonest first)

**Migration notes:**
- Birthday reminders are personal touch - preserve
- Add birthday notifications (email, push)
- Add "send birthday message" quick action (email template)
- Consider recurring yearly reminder (auto-create notification each year)
- sched/birthday_fix.cfm suggests data quality issues - add validation

---

### 14.2 Newsletter Subscription Flag

**Feature:** Flag contact for newsletter subscription (integration with newsletter module)

**User flow:**
1. View contact detail
2. Check "Subscribe to Newsletter" checkbox (newsletter_yn)
3. Save → contact added to newsletter recipient list

**Files:**
- **Field:** contactdetails.newsletter_yn
- **Service:** ContactService.cfc:update({newsletter_yn: 'Y'})

**Business rules:**
- newsletter_yn = 'Y' → contact subscribed
- newsletter_yn = 'N' → contact not subscribed
- Default 'N' (opt-out)
- Used by newsletter module to build recipient lists

**Migration note:** Newsletter integration - preserve with GDPR compliance (explicit opt-in, easy unsubscribe)

---

### 14.3 Google Alerts Flag

**Feature:** Flag contact for Google alert setup (monitor news/mentions)

**User flow:**
1. View contact detail
2. Check "Set up Google Alerts" checkbox (googlealert_yn)
3. Save → contact flagged for alert setup
4. (Manual or automated setup of Google alert for contact name)

**Files:**
- **Field:** contactdetails.googlealert_yn
- **Service:** ContactService.cfc:update({googlealert_yn: 'Y'})

**Business rules:**
- googlealert_yn = 'Y' → alert should be set up
- Default 'N'
- Actual alert setup likely manual or via batch script (not visible in code)

**Migration note:** Useful for staying informed about important contacts - preserve with automation

---

### 14.4 Social Media Tracking Flag

**Feature:** Flag contact for social media activity tracking

**User flow:**
1. View contact detail
2. Check "Track Social Media" checkbox (socialmedia_yn)
3. Save → contact flagged for tracking
4. (Integration with social media monitoring tool?)

**Files:**
- **Field:** contactdetails.socialmedia_yn
- **Service:** ContactService.cfc:update({socialmedia_yn: 'Y'})

**Business rules:**
- socialmedia_yn = 'Y' → track social activity
- Default 'N'
- May integrate with Social Profile items (valueCategory='Social Profile')

**Migration note:** Clarify purpose and integration - preserve if actively used

---

### 14.5 Referral Tracking

**Feature:** Track who referred this contact (network mapping)

**User flow:**
1. Create or edit contact
2. Select referring contact (refer_contact_id) via contact lookup
3. Save → referral link created
4. Display "Referred by [contact name]" on contact detail

**Files:**
- **Field:** contactdetails.refer_contact_id (FK to contactdetails.contactid)
- **Query:** include/qry/contact_info.cfm (self-join to get referrer name)

**Query:**
```sql
SELECT d.contactid, d.contactFullName, ...,
       cd2.contactFullName AS referDetailsFullname
FROM contactdetails d
LEFT JOIN contactdetails cd2 ON cd2.contactid = d.refer_contact_id
WHERE d.contactid = :contactid
```

**Business rules:**
- Self-referencing FK (contact refers to another contact in same table)
- Optional - can be NULL
- One contact can refer many others (1:many)
- ON DELETE SET NULL recommended (prevent orphaned references)

**Migration notes:**
- Referral tracking enables network analysis - preserve
- Add reports: "referral network" (graph visualization)
- Add "contacts I referred" view (reverse lookup)
- Add ON DELETE SET NULL constraint
- Consider tracking referral source (how they met: event, mutual friend, etc.)

---

## 15. BACKEND/AUTOMATION FEATURES

### 15.1 User Setup (Create User Contact)

**Feature:** When new user signs up, create contact record for user themselves

**User flow:**
- No direct user interaction (automated during signup)

**Files:**
- **Scheduled task:** sched/user_setup.cfm, sched/user_setup_core.cfm, sched/user_setup_corex.cfm, sched/usercontact.cfm

**Business rules:**
- When user account created:
  - Create contactdetails record:
    - userid = user's userid
    - contactFullName = user's name
    - user_yn = 'Y' (flag as user's own contact)
    - contactStatus = 'Active'
  - Purpose: User can reference themselves in relationships, events, referrals

**Migration note:** Self-referential user contact is unique pattern - preserve if still needed in TAO 2.0

---

### 15.2 Folder Setup (Auto-Create Contact Folders)

**Feature:** Automatically create folder structure for new contact (file storage)

**User flow:**
- No direct user interaction (automated on contact creation)

**Files:**
- **Scheduled task:** sched/folder_setup.cfm
- **Include:** include/contactfolder_setup.cfm, include/scripts/folder_setup.cfm

**Business rules (inferred):**
- When contact created:
  - Create folders:
    - /uploads/contacts/[userid]/[contactid]/
    - /uploads/contacts/[userid]/[contactid]/documents/
    - /uploads/contacts/[userid]/[contactid]/photos/
    - /uploads/contacts/[userid]/[contactid]/notes/
  - Purpose: Organize contact-related files

**Migration note:** File storage patterns may change in TAO 2.0 (cloud storage) - re-evaluate need for folder structure

---

### 15.3 Batch Data Fixes

**Feature:** Scheduled tasks to fix data quality issues

**Files:**
- **Birthday fix:** sched/birthday_fix.cfm
- **Date fix:** sched/dateaddedfix.cfm
- **Password fix:** sched/psw_fix.cfm (not contact-specific but in sched/)

**Purpose:**
- birthday_fix.cfm: Fix invalid birthday dates, format issues
- dateaddedfix.cfm: Fix missing contactCreationDate values
- Suggests historical data quality issues

**Migration note:** Run data cleanup before migration, add validation to prevent issues in TAO 2.0

---

### 15.4 Batch Avatar Processing

_(Covered in section 8.2)_

---

### 15.5 Automated System Creation After Events

_(Covered in section 10.3)_

---

## 16. MISSING/UNCLEAR FEATURES

Based on code analysis, these features are referenced but not fully documented:

### 16.1 Contact Groups (temp feature?)

**Files:**
- include/tmpcontactgroups.cfm
- app/tmpcontactgroups-Results/

**Purpose:** Temporary grouping of contacts for batch operations?

**Status:** Unclear - may be deprecated or specialized use case

---

### 16.2 Contact Check

**Files:**
- include/contacts_check.cfm
- include/qry/contacts_check.cfm

**Purpose:** Validation? Duplicate check? Integrity check?

**Status:** Unclear from filenames alone

---

### 16.3 Essence Contact

**Files:**
- include/remoteUpdateEssenceContact.cfm

**Purpose:** Update "essence" of contact? Core fields only?

**Status:** Unclear - may be subset of full contact update

---

## 17. PERFORMANCE OPTIMIZATIONS

### 17.1 contacts_ss View

**Purpose:** Pre-join contactdetails + contactitems to avoid repeated JOINs

**Performance gain:** Significant - used in every contact list query

**Optimization notes:**
- Uses subqueries to get "first" email/phone/company (WHERE primary_yn='Y')
- Avoids N+1 query problem (one query per contact for items)
- Consider materialized view or cached table for 1000+ contacts

---

### 17.2 sharez View Optimization

**Purpose:** Complex view for sharing contacts - originally had heavy GROUP_CONCAT

**Performance issue:** 3-level view nesting (sharez → views → base tables)

**Fix:** database/rebuild_sharez_view.sql
- Query base tables (_tbl suffix) directly instead of views
- Remove GROUP_CONCAT for notes (major performance killer)
- Use ROW_NUMBER window function for last event (vs correlated subquery)
- Simplify maxaudition logic

**Recommendation:** Use optimized sharez view or materialized table

---

## SUMMARY STATISTICS

**Total Features Documented:** 50+

**Feature Categories:**
- Contact List & Search: 4
- Contact Detail & View: 3
- Contact Creation & Editing: 5
- Contact Items Management: 2
- Tag Management: 5
- Contact Import: 3
- Duplicate Detection & Merge: 2
- Avatar & Photo: 2
- Relationships & Systems: 2
- Events Integration: 3
- Audition Integration: 2
- Notes & History: 2
- Sharing & Collaboration: 1
- Special Features: 5
- Backend/Automation: 5
- Performance: 2

**Critical Migration Features:**
1. Contact CRUD (create, read, update, soft delete)
2. Contact items (EAV model with type/category)
3. Tag-based system scope (Casting Director detection)
4. Import with duplicate detection
5. Duplicate merge
6. contacts_ss view optimization
7. Relationship systems integration
8. Events/auditions integration
9. Notes with rich text
10. Birthday reminders

**Nice-to-Have Features:**
1. IMDb integration
2. Google alerts automation
3. Social media tracking
4. Referral network
5. Avatar cropping
6. Public sharing
7. Batch operations
8. Auto-folder creation

**Deprecated/Unclear Features:**
1. Contact groups (tmpcontactgroups)
2. Essence contact update
3. Contact check
4. Important Date category

---

## END OF FEATURE MAP

**Documentation Complete:**
1. ✅ tao1_contacts_table_map.md
2. ✅ tao1_contacts_column_usage.md
3. ✅ tao1_contactitems_type_category_map.md
4. ✅ tao1_contacts_feature_map.md (this file)

**Ready for TAO 2.0 migration planning.**


---

<!-- END: tao1_contacts_feature_map.md -->

---

# TAO 1.0 Contacts Module - ContactItems Type/Category Map

**Generated:** 2025-11-30
**Purpose:** Complete mapping of valueType and valueCategory combinations for TAO 2.0 migration
**Scope:** All type/category combinations observed in code

---

## EXECUTIVE SUMMARY

TAO 1.0 uses an Entity-Attribute-Value (EAV) model in `contactitems` where:

- **valueCategory** = High-level category (Email, Phone, Address, Company, Tag, etc.)
- **valueType** = Specific type within category (Business, Personal, Work, Mobile, etc.)
- **Category determines field usage** - which value* columns are populated

This document maps all observed combinations, their business rules, and migration recommendations.

---

## TABLE OF CONTENTS

1. [Category-to-CatID Mapping](#1-category-to-catid-mapping)
2. [Category-Specific Field Usage](#2-category-specific-field-usage)
3. [Complete Type/Category Combinations](#3-complete-typecategory-combinations)
4. [Special Categories](#4-special-categories)
5. [Migration Recommendations](#5-migration-recommendations)

---

## 1. CATEGORY-TO-CATID MAPPING

### catid Values (inferred from include/remoteaddC.cfm)

| catid | valueCategory | catFieldSet | Fields Used | Add Form Section |
|-------|---------------|-------------|-------------|------------------|
| 1 | Phone | text | valuetext | Lines 123-130 |
| 2 | Address | address | valueStreetAddress, valueExtendedAddress, valueCity, valueRegion, valueCountry, valuePostalCode | Lines 132-183 |
| 4 | URL | text | valuetext | Lines 84-120 (url validation) |
| 5 | Social Profile | text | valuetext | Lines 84-120 (url validation) |
| 9 | Company | company | valueCompany, valueDepartment, valueTitle | Lines 193-227 |
| 10 | Email | text | valuetext | Lines 84-120 (email type) |
| 12 | Acting Links | text | valuetext | Lines 84-120 (url validation) |
| 13 | Important Date | text | itemDate | Lines 185-191 |
| (unknown) | Tag | text | valuetext | Not in add form (added via separate tag interface) |
| (unknown) | Profile | text | valuetext | Similar to Social Profile |

**Note:** catid values extracted from conditionals in include/remoteaddC.cfm. Some categories may have different catid values.

---

## 2. CATEGORY-SPECIFIC FIELD USAGE

### 2.1 TEXT CATEGORIES (catFieldSet = 'text')

**Categories:** Email, Phone, URL, Tag, Social Profile, Acting Links, Profile

**Fields used:**
- `valuetext` (PRIMARY - stores the actual value)
- `valueType` (type within category)
- `primary_yn` (one primary per category per contact)
- `itemStatus` ('Active', 'Pending', 'Inactive')

**Fields NULL/unused:**
- valueCompany, valueDepartment, valueTitle
- valueStreetAddress, valueExtendedAddress, valueCity, valueRegion, valueCountry, valuePostalCode
- itemDate (except Important Date category)
- itemNotes (rarely used)

**Business rules:**
- valuetext is REQUIRED
- Max length varies by category:
  - Email: 500 chars (valuetext column max)
  - Phone: 500 chars
  - URL: 500 chars (validated as URL format)
  - Tag: 40 chars (enforced by `LEFT(tagname, 40)` in queries)
  - Social Profile/Acting Links: 500 chars (URLs)

---

### 2.2 ADDRESS CATEGORY (catFieldSet = 'address')

**Category:** Address

**Fields used:**
- `valueStreetAddress` (street address line 1) - REQUIRED
- `valueExtendedAddress` (apt, suite, unit)
- `valueCity` (city/town)
- `valueRegion` (state/province/region) - REQUIRED
- `valueCountry` (country name, from lookup) - REQUIRED, defaults to 'US'
- `valuePostalCode` (zip/postal code)
- `valueType` (Business, Work, Home, etc.)
- `primary_yn`
- `itemStatus`

**Fields NULL/unused:**
- `valuetext` - NOT USED for addresses
- valueCompany, valueDepartment, valueTitle
- itemDate, itemNotes

**Business rules:**
- valueStreetAddress is REQUIRED (min 5 chars)
- valueRegion and valueCountry REQUIRED (dropdowns)
- Other address fields optional
- Country defaults to 'US'
- Region dropdown chained to Country selection (include/remoteaddC.cfm:239)

**Form handling:**
- include/remoteaddC.cfm lines 132-183
- include/remoteUpdateC.cfm (similar structure for edit)

---

### 2.3 COMPANY CATEGORY (catFieldSet = 'company')

**Category:** Company

**Fields used:**
- `valueCompany` (company name) - REQUIRED - **NOT valuetext!**
- `valueDepartment` (department/division)
- `valueTitle` (job title within company)
- `valueType` (always 'Company' - single type)
- `primary_yn`
- `itemStatus`

**Fields NULL/unused:**
- `valuetext` - **NOT USED** (company uses valueCompany instead)
- Address fields (valueStreetAddress, etc.)
- itemDate, itemNotes

**Business rules:**
- valueCompany is REQUIRED
- Dropdown pre-populated with existing companies (from include/qry/companies_198_4.cfm)
- User can select existing or add custom (option value="custom")
- valueDepartment and valueTitle are optional
- valueType always 'Company' (no variation)

**Form handling:**
- include/remoteaddC.cfm lines 193-227
- Select existing company OR enter custom
- Custom company via special toggle (toggleCustomField function)

**Migration note:** **CRITICAL INCONSISTENCY** - Company category uses valueCompany field while all other text categories use valuetext. Consider normalizing in TAO 2.0.

---

### 2.4 TAG CATEGORY (special case)

**Category:** Tag

**Fields used:**
- `valuetext` (tag name)
- `valueType` (always 'Tags')
- `valueCategory` (always 'Tag')
- `itemStatus` ('Active' only - no Inactive tags visible)

**Fields NULL/unused:**
- All other value* fields
- primary_yn - not applicable (no "primary tag")
- itemDate, itemNotes

**Business rules:**
- valueType always 'Tags' (singular type)
- valuetext stores tag name (max 40 chars enforced by queries)
- Tag names must match tags_user.tagname for Casting Director detection
- Tags NOT added via remoteaddC.cfm form - separate tag interface
- Special tags:
  - 'My Team' - adds contact to team view
  - Casting Director tags (from tags_user WHERE tagtype='C')

**Casting Director detection (ContactItemService.cfc:9-30):**
```
IF contact has tag in tags_user WHERE tagtype='C'
  THEN systemscope = 'Casting Director'
  ELSE systemscope = 'Industry'
```

**Tag operations:**
- Add: ContactItemService.addContactItemsTag() or addTeam()
- Delete: ContactItemService.DELcontactitems() (soft delete? or hard?)
- List: ContactItemService.SELcontactitems() WHERE valueCategory='Tag'

**Tag length enforcement:**
- Application: `LEFT(tagname, 40)` in queries
- Database: likely varchar(500) but truncated
- **Migration:** Add varchar(40) constraint or validation

---

### 2.5 IMPORTANT DATE CATEGORY (rare)

**Category:** (valueCategory unclear - possibly 'Important Date')

**Fields used:**
- `itemDate` (the actual date)
- `valueType` (type of date?)
- `valueCategory` (unknown - not visible in code)

**Form handling:**
- include/remoteaddC.cfm lines 185-191 (when new_catid eq "13")

**Usage:** Rarely referenced in code - possible feature flag or incomplete feature

**Migration note:** Clarify purpose or deprecate if unused

---

## 3. COMPLETE TYPE/CATEGORY COMBINATIONS

### 3.1 EMAIL (valueCategory = 'Email', catid = 10)

**valueType values observed in code:**

| valueType | Usage | Code References |
|-----------|-------|-----------------|
| Business | Primary business email | Default/common |
| Personal | Personal email | User-selectable |
| Work | Work email (synonym for Business?) | User-selectable |

**Field storage:**
- `valuetext` = email address
- `valueType` = Business/Personal/Work
- `primary_yn` = 'Y' for default email

**Business rules:**
- Email format validation (data-parsley-type="email" in forms)
- Used for duplicate detection (ContactImportValidationService.cfc)
- Used for contact lookup/matching
- contacts_ss view shows "first" email (col4) where primary_yn='Y' or itemStatus='Active'

**Form validation:**
- include/remoteaddC.cfm: valuefieldtype='email' when new_catid eq "10"
- Email format enforced by Parsley.js

**Duplicate detection:**
- include/qry/duplicatesByEmail.cfm:20 - `WHERE valueCategory='Email' AND valuetext=...`
- ContactDuplicateService.findDuplicatesByEmail() - matches by email valuetext

**Migration notes:**
- Standard email types - keep all three
- Consider adding validation for email format at DB level
- Clarify difference between Business and Work (synonyms?)

---

### 3.2 PHONE (valueCategory = 'Phone', catid = 1)

**valueType values observed in code:**

| valueType | Usage | Code References |
|-----------|-------|-----------------|
| Work | Work phone number | Common |
| Mobile | Mobile/cell phone | Common |
| mobile | Mobile (lowercase - INCONSISTENT) | Found in some queries |
| Home | Home phone | Less common |

**Field storage:**
- `valuetext` = phone number
- `valueType` = Work/Mobile/mobile/Home
- `primary_yn` = 'Y' for default phone

**Business rules:**
- Phone format validation (data-parsley-phone in forms)
- contacts_ss view shows "first" phone (col3) where primary_yn='Y'
- No standardized format (US vs international)

**Form validation:**
- include/remoteaddC.cfm lines 123-130
- data-parsley-phone validation (custom validator)
- Min/max length constraints

**Casing inconsistency:**
- **CRITICAL:** 'Mobile' vs 'mobile' found in code
- ContactItemService likely has both
- **Migration:** Standardize to 'Mobile' (title case)

**Migration notes:**
- Standardize casing: 'Mobile' not 'mobile'
- Keep Work, Mobile, Home
- Consider phone number formatting/normalization
- International phone number support?

---

### 3.3 ADDRESS (valueCategory = 'Address', catid = 2)

**valueType values observed in code:**

| valueType | Usage | Code References |
|-----------|-------|-----------------|
| Business | Business address | Common |
| Work | Work address (synonym for Business?) | Common |
| Home | Home address | Less common |

**Field storage (6 fields):**
- `valueStreetAddress` = street address line 1 (REQUIRED)
- `valueExtendedAddress` = apt, suite, unit
- `valueCity` = city/town
- `valueRegion` = state/province (REQUIRED)
- `valueCountry` = country name (REQUIRED, defaults 'US')
- `valuePostalCode` = zip/postal code
- `valueType` = Business/Work/Home
- `primary_yn` = 'Y' for default address

**Business rules:**
- valueStreetAddress REQUIRED (min 5 chars)
- valueRegion and valueCountry REQUIRED
- Country defaults to 'US'
- Region dropdown chained to Country (jquery.chained.js)
- Other fields optional

**Form handling:**
- include/remoteaddC.cfm lines 132-183
- Multi-field address form
- Country → Region cascading dropdowns
- include/qry/fetchLocationService.cfm - loads countries/regions

**Migration notes:**
- Consider separate address table (normalize out of EAV)
- Clarify Business vs Work (synonyms?)
- Validate international addresses
- Consider address verification/autocomplete in TAO 2.0

---

### 3.4 COMPANY (valueCategory = 'Company', catid = 9)

**valueType values observed in code:**

| valueType | Usage | Code References |
|-----------|-------|-----------------|
| Company | Only type for Company category | Default/only option |

**Field storage (3 fields):**
- `valueCompany` = company name (REQUIRED) - **NOT valuetext!**
- `valueDepartment` = department/division
- `valueTitle` = job title within company
- `valueType` = 'Company' (always)
- `primary_yn` = 'Y' for primary company

**Business rules:**
- valueCompany REQUIRED
- Pre-populated dropdown from existing companies (include/qry/companies_198_4.cfm)
- Option to add custom company
- valueDepartment and valueTitle optional
- No type variation (always 'Company')

**Form handling:**
- include/remoteaddC.cfm lines 193-227
- Dropdown with existing companies + "***ADD NEW***" option
- Custom company entry via special field (toggleCustomField)

**Display:**
- contacts_ss view - col5 shows first company (from valueCompany, not valuetext)
- sharez view:35 - `ci_company.valueCompany AS Company`

**Migration notes:**
- **CRITICAL DESIGN ISSUE:** Company uses valueCompany while Email/Phone use valuetext - inconsistent EAV model
- Consider normalizing: either all use valuetext, or create dedicated company table
- Single valueType ('Company') suggests this could be a separate table, not EAV

---

### 3.5 URL (valueCategory = 'URL', catid = 4)

**valueType values observed in code:**

| valueType | Usage | Code References |
|-----------|-------|-----------------|
| Company Website | Company/casting office website | Common |
| (others) | User-defined via itemtypes_user | Custom |

**Field storage:**
- `valuetext` = URL (REQUIRED)
- `valueType` = Company Website / custom types
- `primary_yn` = 'Y' for primary URL

**Business rules:**
- URL format validation (data-parsley-type="url")
- Must start with http:// or https://
- Pattern validation: no @ symbol (distinguish from email)
- Placeholder: "https://www.yourwebsite.com"

**Form validation:**
- include/remoteaddC.cfm lines 84-120
- data-parsley-type="url"
- data-parsley-pattern="^(?!.*@).*$" (no @ symbol)

**Migration notes:**
- Standard URL validation
- Consider storing protocol separately (http vs https)
- Link click tracking?

---

### 3.6 SOCIAL PROFILE (valueCategory = 'Social Profile', catid = 5)

**valueType values observed in code (from itemtypes_user):**

| valueType | Usage | Icon | Code References |
|-----------|-------|------|-----------------|
| Facebook | Facebook profile URL | fe-facebook | User-customizable |
| Twitter | Twitter profile URL | fe-twitter | User-customizable |
| Instagram | Instagram profile URL | fe-instagram | User-customizable |
| LinkedIn | LinkedIn profile URL | fe-linkedin | User-customizable |
| (custom) | Any social media user adds | Custom icon | Via itemtypes_user |

**Field storage:**
- `valuetext` = profile URL (REQUIRED)
- `valueType` = Facebook/Twitter/Instagram/LinkedIn/custom (from itemtypes_user)
- `primary_yn` = 'Y' for primary profile?

**Business rules:**
- valueType defined in itemtypes_user table (user-customizable)
- Each user can define which social media types they track
- Icons from itemtypes_user.typeIcon
- URL format validation (https://)

**Form handling:**
- include/remoteaddC.cfm lines 84-120
- Dropdown populated from itemtypes_user WHERE userid=:userid
- Icon display via ContactItemService.getSocialIcons()

**Display:**
- include/contact_pane.cfm - Icons displayed alongside profile links
- Clickable links to social profiles

**Migration notes:**
- User-customizable social media types = good flexibility
- Consider pre-seeding common types (Facebook, Twitter, Instagram, LinkedIn, TikTok, YouTube)
- Icon handling via itemtypes_user works well - keep pattern

---

### 3.7 ACTING LINKS (valueCategory = 'Acting Links', catid = 12)

**valueType values observed in code (from itemtypes_user):**

| valueType | Usage | Icon | Code References |
|-----------|-------|------|-----------------|
| IMDb | IMDb profile URL | Custom | User-customizable |
| Actors Access | Actors Access profile | Custom | User-customizable |
| Backstage | Backstage profile | Custom | User-customizable |
| Casting Networks | Casting Networks profile | Custom | User-customizable |
| (custom) | Other casting platforms | Custom icon | Via itemtypes_user |

**Field storage:**
- `valuetext` = profile URL (REQUIRED)
- `valueType` = IMDb/Actors Access/custom (from itemtypes_user)
- `primary_yn` = 'Y' for primary acting profile?

**Business rules:**
- Similar to Social Profile but for acting/casting platforms
- valueType defined in itemtypes_user (user-customizable)
- URL format validation

**Form handling:**
- include/remoteaddC.cfm lines 84-120
- Same pattern as Social Profile

**Migration notes:**
- Industry-specific category - important for actors
- Consider pre-seeding common types
- IMDb integration possibilities?

---

### 3.8 PROFILE (valueCategory = 'Profile')

**valueType values:** (Similar to Acting Links - user-defined)

**Purpose:** Unclear distinction from Social Profile and Acting Links

**Field storage:**
- `valuetext` = profile URL
- `valueType` = from itemtypes_user

**Business rules:**
- User-customizable via itemtypes_user

**Migration note:** **CLARIFICATION NEEDED** - What's the difference between Profile, Social Profile, and Acting Links? Consider consolidating.

---

### 3.9 TAG (valueCategory = 'Tag')

**valueType values observed in code:**

| valueType | Usage | Code References |
|-----------|-------|-----------------|
| Tags | Only type for Tag category | ContactItemService.cfc:42 (INSERT) |

**Field storage:**
- `valuetext` = tag name (max 40 chars)
- `valueType` = 'Tags' (always)
- `valueCategory` = 'Tag'

**Business rules:**
- valueType always 'Tags' (no variation)
- Tag names must be unique per contact (no duplicate tags)
- Tag names in tags_user define special behavior:
  - tagtype='C' → Casting Director tag → affects relationship system scope
  - 'My Team' → adds to team view
  - 'My Rep Team' → agent/representative designation

**Special tag handling:**

**'My Team' tag:**
- ContactItemService.addTeam() - adds 'My Team' tag
- ContactItemService.deleteTeam() - removes 'My Team' tag (HARD DELETE - line 67)
- Used to filter ContactService.GetMyTeam() - team view
- Can only be added once per contact (duplicate check)

**Casting Director tags:**
- Defined in tags_user WHERE tagtype='C'
- ContactItemService.getContactTagStatus() - determines scope
- If contact has CD tag → systemscope='Casting Director' → Targeting/Follow-Up systems
- Else → systemscope='Industry' → different system workflows

**Tag length:**
- Enforced by `LEFT(tagname, 40)` in queries
- Database likely varchar(500) but truncated in application

**Tag add/delete:**
- Add: ContactItemService.addContactItemsTag(), addTeam()
- Delete: ContactItemService.DELcontactitems(), deleteTeam()
- List: ContactItemService.SELcontactitems() WHERE valueCategory='Tag'

**Migration notes:**
- **CRITICAL:** Tag business logic is core to relationship system workflows
- Ensure tags_user.tagtype='C' mapping migrates correctly
- Fix HARD DELETE in deleteTeam() - should soft delete
- Add varchar(40) constraint
- Consider separate tag table (many-to-many) vs EAV

---

## 4. SPECIAL CATEGORIES

### 4.1 Relationship (Synthetic Category)

**Not a real contactitems category** - added by ContactItemService in queries

**Purpose:** Display relationship systems in contact item lists

**Code reference:**
- ContactItemService.cfc:123 - `SELECT 'Relationship' AS valueCategory, 'fe-users' AS caticon, 'text' AS catFieldSet`
- UNION with actual categories

**Migration note:** Synthetic category for UI purposes only - not stored in contactitems

---

## 5. MIGRATION RECOMMENDATIONS

### 5.1 Standardization Required

**1. Casing inconsistencies:**
- valueType: 'Mobile' vs 'mobile' → standardize to 'Mobile'
- itemStatus: 'Active' vs 'active' → standardize to 'Active'
- IsDeleted vs isdeleted → standardize to 'IsDeleted'

**2. Synonym clarification:**
- Email: 'Business' vs 'Work' - are these the same?
- Address: 'Business' vs 'Work' - are these the same?
- Company: only 'Company' type - why have valueType at all?

**3. Add constraints:**
- valueType FK to itemtypes OR itemtypes_user
- valueCategory FK to itemcategory.valueCategory
- CHECK constraints for itemStatus ('Active', 'Pending', 'Inactive')
- Tag max length 40 chars

---

### 5.2 Schema Normalization Options

**Option A: Keep EAV, fix inconsistencies**
- Pros: Flexible, user-customizable
- Cons: Complex queries, hard to enforce constraints
- Changes:
  - Company uses valuetext (not valueCompany)
  - Add FK constraints
  - Add indexed views for performance

**Option B: Normalize core categories**
- Separate tables for:
  - contact_emails (id, contactid, email, type, is_primary)
  - contact_phones (id, contactid, phone, type, is_primary)
  - contact_addresses (id, contactid, street1, street2, city, region, country, postal, type, is_primary)
  - contact_companies (id, contactid, company, department, title, is_primary)
  - contact_tags (many-to-many: contact_id, tag_id)
- Keep EAV for custom/rare categories (URL, Social Profile, Acting Links)
- Pros: Better performance, constraints, indexing
- Cons: More tables, less flexible

**Option C: Hybrid approach**
- Core categories (Email, Phone, Company) → dedicated tables
- Flexible categories (Social Profile, Acting Links, URL) → EAV
- Tags → many-to-many table
- Address → separate table with full address model
- Pros: Best of both worlds
- Cons: More complex migration

**Recommendation:** **Option C - Hybrid approach** for optimal performance and flexibility

---

### 5.3 Type/Category Matrix Validation

**Create reference data for valid combinations:**

```sql
CREATE TABLE contactitem_valid_types (
  valuecategory VARCHAR(100),
  valuetype VARCHAR(100),
  is_deprecated BIT DEFAULT 0,
  notes TEXT,
  PRIMARY KEY (valuecategory, valuetype)
);

-- Seed valid combinations
INSERT INTO contactitem_valid_types VALUES
  ('Email', 'Business', 0, 'Business email'),
  ('Email', 'Personal', 0, 'Personal email'),
  ('Email', 'Work', 0, 'Work email - synonym for Business?'),
  ('Phone', 'Work', 0, 'Work phone'),
  ('Phone', 'Mobile', 0, 'Mobile phone'),
  ('Phone', 'mobile', 1, 'DEPRECATED - use Mobile'),
  ('Phone', 'Home', 0, 'Home phone'),
  ('Address', 'Business', 0, 'Business address'),
  ('Address', 'Work', 0, 'Work address'),
  ('Address', 'Home', 0, 'Home address'),
  ('Company', 'Company', 0, 'Only valid type'),
  ('URL', 'Company Website', 0, 'Company website URL'),
  ('Tag', 'Tags', 0, 'Only valid type'),
  ... (Social Profile, Acting Links from itemtypes_user)
;
```

**Enforce via FK:**
```sql
ALTER TABLE contactitems
ADD CONSTRAINT fk_contactitems_valid_type
FOREIGN KEY (valuecategory, valuetype)
REFERENCES contactitem_valid_types(valuecategory, valuetype);
```

---

### 5.4 Migration Script Priorities

**Phase 1: Data cleanup**
1. Standardize casing (Mobile, Active, etc.)
2. Merge synonyms (Business vs Work - user choice or auto-merge?)
3. Fix Company category (migrate valueCompany → valuetext OR keep as-is with documentation)
4. Truncate tags to 40 chars (or expand limit)

**Phase 2: Schema updates**
5. Add FK constraints (valueCategory → itemcategory)
6. Add CHECK constraints (itemStatus)
7. Add unique constraint on primary_yn
8. Add indexes per rebuild_sharez_view.sql recommendations

**Phase 3: Normalization (if Option B or C chosen)**
9. Create dedicated tables (contact_emails, contact_phones, etc.)
10. Migrate data from contactitems to new tables
11. Update application code to use new tables
12. Drop old contactitems EAV data (or keep for legacy)

**Phase 4: Testing**
13. Test all type/category combinations
14. Test primary_yn enforcement
15. Test tag-based system scope detection
16. Test contacts_ss view performance

---

## 6. COMPLETE TYPE/CATEGORY REFERENCE TABLE

| valueCategory | valueType | Fields Used | Required | Primary | Status | Notes |
|---------------|-----------|-------------|----------|---------|--------|-------|
| Email | Business | valuetext | Yes | Supported | Active | Primary business email |
| Email | Personal | valuetext | Yes | Supported | Active | Personal email |
| Email | Work | valuetext | Yes | Supported | Active | Work email (synonym for Business?) |
| Phone | Work | valuetext | Yes | Supported | Active | Work phone |
| Phone | Mobile | valuetext | Yes | Supported | Active | Mobile/cell phone |
| Phone | mobile | valuetext | Yes | Supported | **DEPRECATED** | Casing inconsistency - standardize to Mobile |
| Phone | Home | valuetext | Yes | Supported | Active | Home phone |
| Address | Business | 6 address fields | valueStreetAddress req | Supported | Active | Business address |
| Address | Work | 6 address fields | valueStreetAddress req | Supported | Active | Work address |
| Address | Home | 6 address fields | valueStreetAddress req | Supported | Active | Home address |
| Company | Company | valueCompany, valueDepartment, valueTitle | valueCompany req | Supported | Active | Only type - uses valueCompany NOT valuetext |
| URL | Company Website | valuetext | Yes | Supported | Active | Company/office website |
| URL | (custom) | valuetext | Yes | Supported | Active | User-defined via itemtypes_user |
| Social Profile | Facebook | valuetext | Yes | Supported | Active | Facebook profile URL |
| Social Profile | Twitter | valuetext | Yes | Supported | Active | Twitter profile URL |
| Social Profile | Instagram | valuetext | Yes | Supported | Active | Instagram profile URL |
| Social Profile | LinkedIn | valuetext | Yes | Supported | Active | LinkedIn profile URL |
| Social Profile | (custom) | valuetext | Yes | Supported | Active | User-defined via itemtypes_user |
| Acting Links | IMDb | valuetext | Yes | Supported | Active | IMDb profile URL |
| Acting Links | Actors Access | valuetext | Yes | Supported | Active | Actors Access profile |
| Acting Links | Backstage | valuetext | Yes | Supported | Active | Backstage profile |
| Acting Links | Casting Networks | valuetext | Yes | Supported | Active | Casting Networks profile |
| Acting Links | (custom) | valuetext | Yes | Supported | Active | User-defined via itemtypes_user |
| Profile | (custom) | valuetext | Yes | Supported | **UNCLEAR** | Purpose unclear - consolidate with Social Profile? |
| Tag | Tags | valuetext | Yes | **N/A** | Active | Only type - max 40 chars |
| Tag | 'My Team' | valuetext='My Team' | Yes | N/A | Active | Special tag - team view filter |
| Tag | (CD tags) | valuetext=tagname from tags_user | Yes | N/A | Active | Casting Director tags - affects system scope |

---

## 7. TAG NAMES WITH SPECIAL BEHAVIOR

| Tag Name | Source | Special Behavior | Code References |
|----------|--------|------------------|-----------------|
| 'My Team' | User-added | Adds contact to team view | ContactItemService.addTeam(), deleteTeam() |
| 'My Rep Team' | User-added | Agent/representative designation | ContactService.GetMyTeam() (implied) |
| _(Any CD tag)_ | tags_user WHERE tagtype='C' | Sets systemscope='Casting Director' → enables Targeting/Follow-Up systems | ContactItemService.getContactTagStatus() |
| _(Other tags)_ | User-added | Sets systemscope='Industry' → different system workflows | ContactItemService.getContactTagStatus() |

**Casting Director Tag Examples (likely in tags_user):**
- 'Casting Director'
- 'CD'
- 'Casting Associate'
- (User-defined tags with tagtype='C')

---

## 8. CATID REFERENCE (for form handling)

| catid | valueCategory | Form Section | Validation |
|-------|---------------|--------------|------------|
| 1 | Phone | remoteaddC.cfm:123-130 | data-parsley-phone |
| 2 | Address | remoteaddC.cfm:132-183 | Street required (min 5), Region required, Country required |
| 4 | URL | remoteaddC.cfm:84-120 | data-parsley-type="url", no @ symbol |
| 5 | Social Profile | remoteaddC.cfm:84-120 | data-parsley-type="url" |
| 9 | Company | remoteaddC.cfm:193-227 | Company name required |
| 10 | Email | remoteaddC.cfm:84-120 | data-parsley-type="email" |
| 12 | Acting Links | remoteaddC.cfm:84-120 | data-parsley-type="url" |
| 13 | Important Date | remoteaddC.cfm:185-191 | data-parsley-type="date" |
| _(unknown)_ | Tag | Separate tag interface | Max 40 chars |

---

## 9. UNUSED OR AMBIGUOUS CATEGORIES

**Profile category:**
- Purpose unclear
- Distinct from Social Profile and Acting Links?
- **Recommendation:** Clarify use case or consolidate with Social Profile

**Important Date category (catid 13):**
- Rarely referenced
- Uses itemDate field (uncommon)
- **Recommendation:** Verify usage or deprecate

---

## END OF TYPE/CATEGORY MAP

**Summary Statistics:**
- **Core Categories:** 9 (Email, Phone, Address, Company, URL, Social Profile, Acting Links, Profile, Tag)
- **Email Types:** 3 (Business, Personal, Work)
- **Phone Types:** 4 (Work, Mobile, mobile-deprecated, Home)
- **Address Types:** 3 (Business, Work, Home)
- **Company Types:** 1 (Company)
- **URL Types:** 1+ (Company Website + custom)
- **Social Profile Types:** 4+ (Facebook, Twitter, Instagram, LinkedIn + custom)
- **Acting Links Types:** 4+ (IMDb, Actors Access, Backstage, Casting Networks + custom)
- **Tag Types:** 1 (Tags)
- **User-customizable:** Social Profile, Acting Links, Profile (via itemtypes_user)

**Migration Priorities:**
1. **HIGH:** Standardize casing (Mobile, Active)
2. **HIGH:** Fix Company category field inconsistency (valueCompany vs valuetext)
3. **HIGH:** Add FK constraints (valueCategory, valueType)
4. **MEDIUM:** Clarify synonyms (Business vs Work)
5. **MEDIUM:** Normalize schema (Option C recommended)
6. **LOW:** Deprecate unused categories (Profile?, Important Date?)

**Next Documentation File:** tao1_contacts_feature_map.md


---

<!-- END: tao1_contactitems_type_category_map.md -->
