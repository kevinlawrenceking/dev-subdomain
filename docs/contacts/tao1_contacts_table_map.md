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
