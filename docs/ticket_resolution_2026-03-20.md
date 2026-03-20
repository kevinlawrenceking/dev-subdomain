# Ticket Resolution Details - 2026-03-20

## Tickets Resolved

---

### #1 (Ad-hoc): Admin Email "Send failed: Forbidden"

**Reported:** Both email buttons (Welcome Email, Password Reset) on admin-users-detail page return "Send failed: Forbidden"

**Root Cause:** CSRF validation in `app/Application.cfc` (lines 340-362) rejects POST requests when `CSRFVerifyToken()` fails. The ColdFusion built-in CSRF engine can become inconsistent (token registry drift, session serialization). The validation was returning an HTML error page for all requests, including AJAX, causing jQuery to surface a generic "Forbidden" error with no actionable detail.

**Fix Applied:**
1. **`app/Application.cfc`** - CSRF validation now tries direct session token comparison (`submittedCsrf EQ session.csrfToken`) before falling back to `CSRFVerifyToken()`. This is reliable because the token is stored in session and rendered in the page meta tag.
2. **`app/Application.cfc`** - CSRF rejection now returns JSON (`{"success":false,"message":"...","code":"CSRF_FAILED"}`) for AJAX requests (detected via `X-Requested-With` or `X-CSRF-Token` headers) instead of an HTML error page.

**Files Changed:**
- `app/Application.cfc` (CSRF validation block, ~lines 347-380)

**Pre-existing fix (already committed):**
- `app/admin-users/admin-guard.cfm` - DB fallback for userRole check (commit `71540b06`, 2026-02-20)

**Testing Script:**
1. Log in as an admin user
2. Navigate to `/app/admin-users-detail/?userid=30`
3. Click "Resend Welcome Email" button - preview modal should appear
4. Click "Send Email" in modal - should succeed (check mail spool)
5. Close modal, click "Send Password Reset" button - preview modal should appear
6. Click "Send Email" in modal - should succeed
7. Verify both emails arrive at the target user's email address
8. Check `tao_csrf.log` - no new rejection entries for these endpoints

---

### #2191: Relationships - new relationship not showing on Targeted list

**Reported:** Create a new relationship with "Casting Director" tag, add to Targeted system. Go to Relationships page, click "Targeted" button. New relationship not in list.

**Root Cause:** The database views (`contacts_ss_target`, `contacts_ss_followup`, `contacts_ss_maint`) filter on incorrect `systemtype` values. The views used legacy values (`'Targeting'`, `'Follow-Up'`, `'Maintenance'`) but the `fusystems` table stores `'Targeted List'`, `'Follow Up'`, `'Maintenance List'`.

**Fix Applied:**
- `database/rebuild_contacts_ss_system_views.sql` - Rebuilds all three views with correct `systemtype` values. Includes verification query and rollback script.

**ACTION REQUIRED:** Run the migration SQL against both `new_development` and `actorsbusinessoffice` schemas.

**Files Changed:**
- `database/rebuild_contacts_ss_system_views.sql` (already committed, needs execution)

**Testing Script:**
1. Run `database/rebuild_contacts_ss_system_views.sql` against the database
2. Verify view row counts:
   ```sql
   SELECT 'target' AS v, COUNT(*) FROM contacts_ss_target
   UNION ALL SELECT 'followup', COUNT(*) FROM contacts_ss_followup
   UNION ALL SELECT 'maint', COUNT(*) FROM contacts_ss_maint;
   ```
3. Create a new relationship with "Casting Director" tag
4. Add the relationship to the "Targeted" system
5. Navigate to Relationships page, click "Targeted" button
6. Confirm the new relationship appears in the list
7. Repeat for "Follow Up" and "Maintenance" tabs to verify those views also work

---

### #2192: Reminders - items are not being removed when completed

**Reported:** Relationship Reminders tab - if a single item is selected and completed is selected, nothing happens.

**Root Cause:** `NotificationService.GetNotificationByID()` used INNER JOIN on `actionusers` table. If a notification's action had no corresponding `actionusers` entry for the user, the query returned 0 rows. The completion endpoint (`complete_not_ajax.cfm`) already had a recordcount guard (added in a prior fix), but returned an error instead of completing. The `getNotifications()` method (used to find the next pending notification in a system) had the same INNER JOIN issue, which could cause transaction failures during the completion workflow.

**Fix Applied:**
1. **`services/NotificationService.cfc` - `GetNotificationByID()`** - Changed `actionusers` from INNER JOIN to LEFT JOIN. Changed `fuactions` to join directly on `n.actionid` instead of through `au.actionid`. Added `COALESCE(au.actionDaysRecurring, 0)` for NULL safety.
2. **`services/NotificationService.cfc` - `getNotifications()`** - Same INNER→LEFT JOIN change for `actionusers`. Removed the `AND au.userID = f.userID` from WHERE clause (moved into JOIN ON clause). Added COALESCE for `actionDaysNo` and `actionDaysRecurring`.

**Files Changed:**
- `services/NotificationService.cfc` (GetNotificationByID and getNotifications functions)

**Testing Script:**
1. Navigate to a relationship's detail page (Reminders tab)
2. Find a pending reminder with a green checkmark button
3. Click the green checkmark (Complete) button
4. Confirm in the modal
5. Verify the reminder disappears from the list (or moves to completed if "Show action log" is checked)
6. Check the database:
   ```sql
   SELECT notid, notstatus, notenddate
   FROM funotifications
   WHERE notid = [THE_NOTID]
   ```
   Should show `notStatus = 'Completed'` and `notenddate = today`
7. Test batch completion: check 2-3 reminders, click "Complete Selected"
8. Verify all selected reminders are completed
9. Test with "Show action log" checked - completed items should appear with status "Completed"

---

### #2184: When clicking mailto - nothing is happening

**Reported:** Email icon in the contact details pane does nothing when clicked. The same icon works in contact_view.cfm.

**Root Cause:** `contact_pane.cfm` contains the email trigger (`data-bs-target="#taoEmailModal"`) but does NOT include `email_options_modal.cfm`. The modal HTML is never rendered in the DOM, so Bootstrap has no target to show. `contact_view.cfm` correctly includes it at line 265.

**Fix Applied:**
- `include/contact_pane.cfm` - Added `<cfinclude template="/include/email_options_modal.cfm" />` before the end of the file. The modal file has a guard variable (`request.taoEmailModalRendered`) that prevents duplicate rendering if included by a parent template.

**Files Changed:**
- `include/contact_pane.cfm` (added email modal include near end of file)

**Testing Script:**
1. Navigate to a contact that has an email address
2. Open the contact details pane (not the full contact_view page)
3. Click the email icon next to the email address
4. Verify the email options modal appears with mailto and compose options
5. Also verify the email icon still works on the full contact_view.cfm page (regression check)

---

### #2140: UAT title bar is blue not red

**Reported:** UAT environment title bar is same blue as production. Should be a distinct color.

**Root Cause:** In `include/fetchPageService.cfm` line 47, UAT's hostcolor was mapped to `#406E8E` (the production blue) instead of a distinct color.

**Fix Applied:**
- `include/fetchPageService.cfm` - Changed UAT color from `#406E8E` (blue) to `#8b0000` (dark red), matching the dev environment pattern for visual distinction.

**Files Changed:**
- `include/fetchPageService.cfm` (line 47, UAT color value)

**Testing Script:**
1. Navigate to the UAT site (uat.theactorsoffice.com)
2. Verify the title/nav bar is dark red, not blue
3. Navigate to the production site (app.theactorsoffice.com)
4. Verify production title bar is still blue (#406E8E)
5. Navigate to dev site - verify dev bar is also dark red

---

### #2161: Character description length in audition import (DB Migration Needed)

**Reported:** Character description field throws "exceeds maxlength setting 100" during audition import.

**Root Cause:** The database columns `audroles.charDescription` and `auditionsimport.charDescription` are constrained to a small VARCHAR size. The ColdFusion code correctly uses `CF_SQL_LONGVARCHAR` everywhere, but the DB columns reject long text.

**Status:** Code is correct. Migration script exists at `database/fix_charDescription_length.sql`. **ACTION REQUIRED: Run migration against both dev and production databases.**

**Testing Script (after migration):**
1. Run `database/fix_charDescription_length.sql`
2. Import an audition spreadsheet with a character description longer than 100 characters
3. Verify the import succeeds without "exceeds maxlength" error
4. Verify the full description is stored and displayed correctly

---

### #1615 / #1646: Login Whoops error / Login redirects to /setup/

**Reported:** Login throws a Whoops error or redirects to `/setup/` instead of the main app.

**Root Cause:** `setup/Application.cfc` used a different session scope name (`"Setup_" & envLabel`) than the main app (`"TAO_" & envLabel`). When a user logged in and the browser hit `/setup/` (e.g., via email link), a new isolated session was created with no `session.userid`. The setup code then tried to use session variables that did not exist, causing Whoops errors. Additionally, `samesite` was set to `"Strict"` (vs `"Lax"` in main app), which dropped cookies on email link clicks.

**Fix Applied:**
1. **`setup/Application.cfc`** - Changed `this.name` to `"TAO_" & envLabel` to share session scope with main app.
2. **`setup/Application.cfc`** - Changed `samesite` from `"Strict"` to `"Lax"` (matches main app).
3. **`setup/Application.cfc`** - Wrapped `application.*` writes in `if (NOT structKeyExists(application, "dsn"))` guard to avoid stomping on already-initialized app scope.
4. **`setup/Application.cfc`** - Removed hard 403 abort for unauthenticated users in `onRequestStart`. Setup URLs use UUID-based access for new users who are not yet logged in.

**Files Changed:**
- `setup/Application.cfc`

**Testing Script:**
1. Log out completely. Log in as a normal user - should land on dashboard, not `/setup/`
2. Open an incognito window. Click a welcome email link containing a `/setup/` URL - should load the setup wizard without error
3. Verify session persists when navigating between `/app/` and `/setup/` pages
4. Check that UAT and dev environments also work (env-specific `this.name` via `envLabel`)

---

### #1655: Company type not filtering dropdown

**Reported:** When adding a contact item for category "Company", the company name dropdown shows all companies regardless of the selected type (Agent, Manager, etc.).

**Root Cause:** The company dropdown was populated from a query that returned distinct company names without type information. The type dropdown and company dropdown were completely independent with no filtering relationship.

**Fix Applied:**
1. **`services/ContactItemService.cfc` - `SELcontactitems_24040()`** - Changed query to include `GROUP_CONCAT(DISTINCT i.valuetype ORDER BY i.valuetype SEPARATOR ',') AS company_types` with `GROUP BY i.valueCompany`. Each company now carries its associated types.
2. **`include/remoteaddC.cfm`** - Added `data-company-types` attribute to company `<option>` elements. Added JS IIFE that caches all options and filters the company dropdown when the type dropdown changes (only for catid 9).
3. **`include/remoteUpdateC.cfm`** - Same data-company-types attribute and filtering JS for consistency.

**Files Changed:**
- `services/ContactItemService.cfc` (~line 701)
- `include/remoteaddC.cfm`
- `include/remoteUpdateC.cfm`

**Testing Script:**
1. Navigate to a contact, click "Add" on the Company category
2. Select type "Agent" from the type dropdown
3. Verify company dropdown only shows companies tagged as Agent
4. Switch to "Manager" - verify dropdown updates to show only Manager companies
5. Switch back to a blank type - verify all companies appear
6. Repeat in the Update modal for an existing company item

---

### #1617 / #1630: Company appearing twice / Relationship system doubled

**Reported:** When adding a contact during audition flow, the company is inserted twice. Additionally, the relationship system enrollment can double, creating duplicate reminders.

**Root Cause (Company):** `include/remoteAddContactAddaud.cfm` had two independent `<cfif>` blocks for company insertion. If `company` was "Custom" and `company_new` had a value, the first block inserted the custom company. But the second block also ran because `company` was non-empty and the `<cfif>` was independent (not `<cfelseif>`), inserting a second row. Additionally, `include/remoteAddContactAud.cfm` had the custom company `hidden_div` visible by default, so both fields could have values on submit.

**Root Cause (System):** `include/add_system.cfm` had a stray `<cfdump>` tag and no guard against creating duplicate notifications when enrollment happened through overlapping code paths (e.g., `modalansweryes.cfm` + `add_system.cfm`). Also, `include/audition_check.cfm` did not check if the contact was already enrolled before showing the "Add to Follow-Up" modal.

**Fix Applied:**
1. **`include/remoteAddContactAddaud.cfm`** - Changed company insert from two independent `<cfif>` blocks to `<cfif>/<cfelseif>` so only ONE company is ever inserted.
2. **`include/remoteAddContactAud.cfm`** - Added `style="display:none"` to custom company `hidden_div`.
3. **`include/add_system.cfm`** - Removed stray `<cfdump>`. Added notification existence guard that checks for pending notifications before creating new ones.
4. **`include/audition_check.cfm`** - Added `fusystemusers_tbl` query guard to skip the "Add to Follow-Up" modal if the contact already has an active system enrollment.

**Files Changed:**
- `include/remoteAddContactAddaud.cfm`
- `include/remoteAddContactAud.cfm`
- `include/add_system.cfm`
- `include/audition_check.cfm`

**Testing Script:**
1. Add a new contact during audition flow, selecting an existing company from dropdown
2. Verify only ONE company row appears in `contactitems` for that contact
3. Select "***ADD NEW***" and type a custom company name
4. Verify only the custom company row appears (not both custom and "Custom" literal)
5. Check `fusystemusers_tbl` - should have only ONE active enrollment per contact per system
6. Check `funotifications` - should have no duplicate pending notifications for the same `suid`

---

### #1634: Add new CD throws Whoops error

**Reported:** Adding a new Casting Director during audition flow throws a Whoops error.

**Root Cause:** `include/folder_setup.cfm` referenced `dir_missing_avatar_filename` which was defined in `sched/user_setup_corex.cfm` but never defined in `folder_setup.cfm`. When `folder_setup.cfm` was included from the audition-add flow, the variable was undefined, causing a ColdFusion error.

**Fix Applied:**
- **`include/folder_setup.cfm`** - Replaced undefined `dir_missing_avatar_filename` with `application.defaultAvatarPath` (which is always available from Application.cfc initialization).

**Files Changed:**
- `include/folder_setup.cfm`

**Testing Script:**
1. Start an audition add flow
2. On the casting director step, click "Add New CD"
3. Fill in the form and submit
4. Verify the CD is created without error and the flow continues to the audition page
5. Check that the new contact has an avatar.jpg in their contacts folder

---

### #1653: Link duplication (IMDB/Social Profile)

**Reported:** IMDB and LinkedIn links appear both as a branded icon and a duplicate text link on the contact page.

**Root Cause:** `contact_view.cfm` renders branded icons from the `profiles` query (getSocialIcons). Then `contact_pane.cfm` is included, which re-renders the same Social Profile items as plain text links via the `itemsbycatActive` loop. The same URL appears twice.

**Fix Applied:**
- **`include/contact_pane.cfm`** - Added a check inside the Social Profile/URL rendering block. Before rendering a text link, it loops through the `profiles` query. If the `valuetext` matches an entry already rendered as a branded icon, the text link is skipped.

**Files Changed:**
- `include/contact_pane.cfm`

**Testing Script:**
1. Navigate to a contact that has an IMDB or LinkedIn Social Profile item
2. Verify the branded icon appears in the profiles row
3. Verify NO duplicate text link appears below in the contact pane
4. Add a Social Profile that does NOT have a branded icon (e.g., a personal website)
5. Verify the text link still renders for non-branded profiles

---

### #1633: Self-tape duration required when not applicable

**Reported:** The duration field is required even when the audition type is not "Self Tape", preventing form submission.

**Fix Applied:**
- **`include/audition-add.cfm`** - Added `id="durationWrapper"` to the duration field container. Added JS to hide the duration wrapper and remove its `required` attribute when "Self Tape" is not selected. Excluded "Unknown" from the audition type dropdown options.

**Files Changed:**
- `include/audition-add.cfm`

**Testing Script:**
1. Start adding a new audition
2. Select audition type "In-Person" - verify duration field is hidden
3. Select "Self Tape" - verify duration field appears and is required
4. Switch back to "In-Person" - verify duration field hides
5. Submit the form without duration (non-self-tape type) - should succeed
6. Verify "Unknown" does not appear in the audition type dropdown

---

### #1652: Notes edits not saving

**Reported:** Editing notes on an event/audition and clicking save appears to work but the content reverts.

**Root Cause:** The form submit handler used `$("#snow-editor").html()` which captured the entire Quill container HTML including `.ql-clipboard` and wrapper divs. Each save wrapped the content in extra divs, causing progressive corruption. On reload, the corrupted HTML rendered differently, making edits appear to revert.

**Fix Applied:**
- **`include/note-update-event.cfm`** - Changed selector from `$("#snow-editor").html()` to `$("#snow-editor .ql-editor").html()` to capture only the Quill editor content. Also syncs plain-text field via `.text()`.

**Files Changed:**
- `include/note-update-event.cfm`

**Testing Script:**
1. Navigate to an audition or event with existing notes
2. Edit the notes text in the Quill editor
3. Click Save
4. Refresh the page - verify the edited content persists
5. Edit again, save again, refresh - verify no progressive corruption
6. Check the database: notes HTML should be clean (no nested `.ql-clipboard` divs)

---

### #1631: Callback SAME button not working

**Reported:** On the audition update form, clicking the "SAME" button to copy location details from the original audition does nothing.

**Root Cause:** The JS `getElementById('eventLocation')` used a hardcoded ID, but the form uses dynamic IDs with the event ID appended (e.g., `eventLocation123`). Also, `region_id` was set before calling `filterRegions()`, so the region dropdown was empty when the value was assigned.

**Fix Applied:**
- **`include/remoteaudupdateform.cfm`** - Changed `eventLocation` to use dynamic ID with `<cfoutput>#new_eventid#</cfoutput>`. Moved `filterRegions(countryid)` call before setting `region_id` value so the dropdown is populated first.

**Files Changed:**
- `include/remoteaudupdateform.cfm`

**Testing Script:**
1. Navigate to an audition that has a callback
2. Click to update the callback details
3. Click the "SAME" button
4. Verify all location fields (address, city, region, country, zip) populate from the original audition
5. Verify the region dropdown correctly shows the original region (not blank)

---

### #1675: Photo upload squished on Safari

**Reported:** Uploaded photos appear squished/distorted, particularly on Safari.

**Root Cause:** Safari does not always auto-correct EXIF Orientation tags on uploaded photos. Portrait images appear squished or rotated because the browser ignores the EXIF tag.

**Fix Applied:**
1. **`app/assets/css/tao-components.css`** - Added `image-orientation: from-image` to `.tao-avatar` and other avatar CSS classes (`.current-avatar`, `.birthday-avatar`, `.team-avatar`, `.tao-sidebar__avatar`, `.tao-card-avatar img`, `.tao-card-photo-body img`).
2. **`include/image-upload.cfm`** - Added `image-orientation: from-image` to preview image style.
3. **`include/image-upload-contact.cfm`** - Updated upload interface with EXIF-aware rendering.

**Files Changed:**
- `app/assets/css/tao-components.css`
- `include/image-upload.cfm`
- `include/image-upload-contact.cfm`

**Testing Script:**
1. Upload a portrait photo taken on an iPhone (has EXIF orientation tag)
2. Verify the preview is not squished or rotated
3. Save the photo and verify it displays correctly on the contact page
4. Test on Safari specifically - should no longer appear distorted
5. Test on Chrome/Firefox to verify no regression

---

### #1656: Font color in notes (white text on paste)

**Reported:** Pasting text from websites with dark backgrounds into the notes editor results in invisible white text.

**Root Cause:** Quill.js preserves inline `color` and `background-color` styles from pasted HTML. Text copied from dark-themed websites retains white or light font colors, which become invisible against the white editor background.

**Fix Applied:**
- **`app/assets/js/form-quill.js`** and **`share/assets/form-quill.js`** - Added a Quill clipboard matcher that strips `color` and `background` attributes from all pasted content.

**Files Changed:**
- `app/assets/js/form-quill.js`
- `share/assets/form-quill.js`

**Testing Script:**
1. Copy text from a website with a dark background (e.g., a dark-themed code editor or dark mode page)
2. Paste into the Quill notes editor
3. Verify the pasted text is visible (no white-on-white)
4. Verify manual formatting (bold, italic, lists) still works after pasting
5. Save the note and verify content persists correctly

---

## Tickets Documented (Needs Live Debug / Device Access)

### #1569: Problem saving contact details

**Status:** Bug confirmed - needs handler file creation

**Investigation:** The tag update form in `include/remoteUpdateTag.cfm` submits to `include/tagchange.cfm`, which does not exist in the repository. When a user updates contact tags, the form posts to a non-existent endpoint, resulting in silent failure. The contact name/details update works correctly via `remoteUpdateNameUpdate.cfm`.

**Developer Notes:** Create `include/tagchange.cfm` handler that accepts POST with userid, contactid, and tag array. Must delete old contact-tag associations and insert new ones. Reference `remoteUpdateNameUpdate.cfm` for the pattern.

---

### #1614: Blank screen on iPhone 14 Pro Max

**Status:** Cannot reproduce without device access

**Investigation:** Viewport meta tag is correctly configured. CSS media queries properly handle mobile breakpoints. Sidebar uses transform-based sliding on mobile. Potential causes: iOS Safari CSS transform bug, JavaScript initialization failure (`packeryInit.js` uses `window.matchMedia()`), or session/CSRF issue on mobile. Needs Safari DevTools remote inspection on the actual device.

**Developer Notes:** Requires iPhone 14 Pro Max or Safari remote debug session. Check browser console for JS errors first. Test with recent CSRF/session changes (commit 2f18df6b).

---

### #2173: Import Relationships Form not Working

**Status:** Likely broken JS - needs live verification

**Investigation:** `include/remoteAddName.cfm` (the "Add A Relationship" modal form) contains JavaScript that calls `setupAutocomplete()` on element `#companySearch` which does not exist in the form DOM. Also references `#nameResults` and `#results` elements that are not defined. These missing elements cause JS console errors that may prevent form initialization and Parsley validation setup.

**Developer Notes:** Remove or fix orphaned `setupAutocomplete()` calls in `remoteAddName.cfm` lines 143-151. The autocomplete targets (`#companySearch`, `#nameResults`, `#results`) need to either be added to the form or the JS removed. Verify on live environment after fix.

---

## Feature Requests (Documented Only)

### #2190: Import resolve duplicates button

**Scope:** The "Update" action in the import duplicate resolution UI was never implemented. Currently only "Skip" and "Add as New" work. Implementing "Update" requires: (1) field-by-field merge logic, (2) conflict resolution UI, (3) cascading updates to linked records. Related to #1725 (merge duplicates).

---

### #1623: Company info auto-populate on relationship add

**Scope:** When adding a new relationship and selecting a company, auto-populate company address/phone/email from existing `contactitems` data for that company. Requires AJAX lookup on company selection change that queries `contactitems` for the selected company name and populates form fields.

---

### #1725: Merge duplicate relationships

**Scope:** Feature request confirmed. Requires: (1) Duplicate detection algorithm (name/email/phone fuzzy matching), (2) Side-by-side merge UI with field-by-field selection, (3) Cascading update of all linked records (notes, events, fusystemusers, funotifications, tags_user, contactitems, audcontacts_auditions_xref, eventcontactsxref). Medium-high complexity. Related to #2190.

---

### #1839: Mailing labels from addresses

**Scope:** Feature request to generate printable mailing labels from contact addresses. Requires: (1) Address selection/filter UI, (2) Label format template (Avery standard sizes), (3) PDF generation from selected addresses. Low priority.

---

### #1780: Filter auditions by agent/team

**Scope:** Feature request to add agent/team filter to the auditions list. Requires: (1) Join auditions to contacts via `audcontacts_auditions_xref`, (2) Filter by contact tag (Agent, Manager), (3) UI dropdown or multi-select filter in auditions list page.

---

### #1636: International phone number formatting

**Scope:** Feature request for international phone formatting. Current `formatPhoneNumber.cfm` only handles US format (10-digit). Requires: (1) Country code detection, (2) Format library (libphonenumber or equivalent), (3) Update `formatPhoneNumber.cfm` to handle international formats gracefully.

---

## Blocked / External Dependency Tickets

### #2143: Google app verification

**Status:** External dependency. Google OAuth app review/verification is required before Google integrations can work in production. This is a Google admin process, not a code issue.

---

### #2015: Google integration verification

**Status:** Blocked by #2143. Cannot verify Google integrations until the app passes Google OAuth review.

---

### #1657: Calendar not syncing

**Status:** Blocked by #2143/#2015. Calendar sync depends on Google Calendar API integration, which is blocked until Google app verification completes.
