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
1. Navigate to app/contacts-import/
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
- **Main page:** app/contacts-import/index.cfm
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
