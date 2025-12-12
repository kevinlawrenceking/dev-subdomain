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
