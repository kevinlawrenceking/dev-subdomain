-- update_ticket_responses_2192_2191_email.sql
-- Updates developer responses and status for tickets fixed 2026-03-20
-- Run against both new_development and actorsbusinessoffice schemas.

-- ============================================================
-- Ticket #2192: Reminders - items are not being removed
-- Status: Implemented
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[IMPLEMENTED 2026-03-20] Root cause: complete_not_ajax.cfm was missing a recordcount guard after GetNotificationByID. When the query returned 0 rows (due to incomplete JOIN on actionusers missing userid condition), all variables became empty strings and the UPDATE silently did nothing. Fix: (1) Added recordcount == 0 guard in complete_not_ajax.cfm that returns a JSON error instead of silently failing. (2) Fixed GetNotificationByID JOIN in NotificationService.cfc to include userid in the actionusers JOIN condition (matching the pattern used by other queries). Files changed: include/complete_not_ajax.cfm, services/NotificationService.cfc'
),
    ticketStatus = 'Implemented',
    testingscript = '1. Go to a relationship that has reminders (Reminders tab)\n2. Select a single pending reminder item\n3. Click Complete/Mark Complete\n4. Verify the item disappears from the list\n5. Refresh the page - confirm the item stays completed\n6. Check funotifications table: SELECT notid, notstatus, notenddate FROM funotifications WHERE notid = [ID] -- should show Completed\n7. If the action is recurring, verify a new Pending notification was created with the correct future start date\n8. Test with a notification that has no actionusers match - should return JSON error instead of silent failure'
WHERE ticketid = 2192;

-- ============================================================
-- Ticket #2191: Relationships - not showing on Targeted list
-- Status: Implemented
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[IMPLEMENTED 2026-03-20] Root cause: The contacts_ss_target database VIEW was filtering on systemtype = ''Targeting'' but the fusystems table stores the value as ''Targeted List''. Same mismatch for contacts_ss_followup (''Follow-Up'' vs ''Follow Up'') and contacts_ss_maint (''Maintenance'' vs ''Maintenance List''). Fix: Created database/rebuild_contacts_ss_system_views.sql that rebuilds all three views with correct systemtype values. Must be run on both dev and prod databases. Files changed: database/rebuild_contacts_ss_system_views.sql (new migration)'
),
    ticketStatus = 'Implemented',
    testingscript = '1. Run database/rebuild_contacts_ss_system_views.sql on the database\n2. Verify views exist: SELECT COUNT(*) FROM contacts_ss_target; SELECT COUNT(*) FROM contacts_ss_followup; SELECT COUNT(*) FROM contacts_ss_maint;\n3. Create a new relationship with Casting Director tag\n4. Add to Targeted system\n5. Go to Relationships page, click Targeted button\n6. Verify the new relationship appears in the list\n7. Repeat for Follow-Up and Maintenance systems\n8. Verify the "no system" search filter still works (should exclude contacts in any system)'
WHERE ticketid = 2191;

-- ============================================================
-- Email Forbidden on Admin User Detail page (not a numbered ticket)
-- Status: Implemented
-- ============================================================
-- No ticket ID provided for this issue. Developer notes:
-- Root cause: admin-guard.cfm checked isDefined("userRole") which only exists
-- after fetchUsers.cfm runs in the page context. AJAX endpoints bypass that flow,
-- so the check always fails with HTTP 403 Forbidden.
-- Fix: admin-guard.cfm now falls back to a direct DB query of taousers.userRole
-- when the userRole variable is not in scope (AJAX context).
-- File changed: app/admin-users/admin-guard.cfm
-- Testing:
-- 1. Go to https://dev.theactorsoffice.com/app/admin-users-detail/?userid=30
-- 2. Click "Resend Welcome Email" button - should show preview modal (not Forbidden)
-- 3. Click "Send Password Reset" button - should show preview modal (not Forbidden)
-- 4. Confirm sending works (check mail spool)
-- 5. Test with a non-admin user session - should still get Forbidden

-- ============================================================
-- Ticket #1725: Merge duplicate relationships (Feature Request)
-- Status: Not implemented - feature request only
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[TRIAGE 2026-03-20] Feature request confirmed. Requires: 1) Duplicate detection algorithm (name/email/phone fuzzy matching), 2) Side-by-side merge UI with field-by-field selection, 3) Cascading update of all linked records (notes, events, fusystemusers, funotifications, tags_user, contactitems, audcontacts_auditions_xref, eventcontactsxref). Medium-high complexity. Related to #2190 (import duplicate resolution). Not implemented in this cycle.'
)
WHERE ticketid = 1725;

-- ============================================================
-- Ticket #2184: When clicking mailto - nothing is happening
-- Status: Implemented
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[IMPLEMENTED 2026-03-20] Root cause: contact_pane.cfm contains the email trigger (data-bs-target="#taoEmailModal") but does NOT include email_options_modal.cfm. The modal HTML was never rendered in the DOM when viewing the contact pane, so Bootstrap had no target element to show. contact_view.cfm correctly includes it at line 265. Fix: Added cfinclude of email_options_modal.cfm to the end of contact_pane.cfm. The modal file has a guard variable (request.taoEmailModalRendered) that prevents duplicate rendering. File changed: include/contact_pane.cfm'
),
    ticketStatus = 'Implemented',
    testingscript = '1. Navigate to a contact with an email address\n2. Open the contact details pane (contact_pane.cfm context)\n3. Click the email icon next to the email address\n4. Verify the email options modal appears with mailto and compose options\n5. Also verify the email icon still works on the full contact view page (regression check)\n6. Test on multiple contacts to confirm consistency'
WHERE ticketid = 2184;

-- ============================================================
-- Ticket #2140: UAT title bar is blue not red
-- Status: Implemented
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[IMPLEMENTED 2026-03-20] Root cause: In include/fetchPageService.cfm line 47, UAT hostcolor was mapped to #406E8E (production blue) instead of a distinct color. Fix: Changed UAT color to #8b0000 (dark red), matching the dev environment for visual distinction from production. File changed: include/fetchPageService.cfm'
),
    ticketStatus = 'Implemented',
    testingscript = '1. Navigate to UAT site (uat.theactorsoffice.com)\n2. Verify the title/nav bar is dark red, not blue\n3. Navigate to production site (app.theactorsoffice.com)\n4. Verify production title bar is still blue (#406E8E)\n5. Navigate to dev site - verify dev bar is also dark red (#8b0000)'
WHERE ticketid = 2140;

-- ============================================================
-- Ticket #2161: Character description length in audition import
-- Status: Implemented (DB migration pending)
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[IMPLEMENTED 2026-03-20] Confirmed: All ColdFusion code correctly uses CF_SQL_LONGVARCHAR for charDescription (AuditionRoleService.cfc, upload_audition.cfm, upload_audition_back.cfm). The "exceeds maxlength setting 100" error comes from the database column constraint, NOT cfqueryparam maxlength. Migration script at database/fix_charDescription_length.sql converts audroles.charDescription and auditionsimport.charDescription to TEXT. ACTION REQUIRED: Run migration on both dev and production databases.'
),
    ticketStatus = 'Implemented',
    testingscript = '1. Run database/fix_charDescription_length.sql on the database\n2. Verify columns: SHOW COLUMNS FROM audroles LIKE ''charDescription''; SHOW COLUMNS FROM auditionsimport LIKE ''charDescription''; -- both should be TEXT\n3. Import an audition spreadsheet with a character description longer than 100 characters\n4. Verify the import succeeds without "exceeds maxlength" error\n5. Verify the full description is stored and displayed correctly on the audition detail page'
WHERE ticketid = 2161;

-- ============================================================
-- Ticket #2192 additional fix note: LEFT JOIN for actionusers
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[UPDATE 2026-03-20] Additional fix: Changed INNER JOIN to LEFT JOIN for actionusers in both GetNotificationByID() and getNotifications() methods in NotificationService.cfc. This ensures notifications without per-user action overrides can still be completed. fuactions now joins directly on n.actionid instead of through au.actionid. COALESCE added for actionDaysRecurring and actionDaysNo to default to 0 when NULL.'
)
WHERE ticketid = 2192;

-- ============================================================
-- Ticket #1615: Login Issue (session scope mismatch)
-- Status: Implemented
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[IMPLEMENTED 2026-03-20] Root cause: /setup/Application.cfc used this.name=''Setup_''&envLabel which created a separate session scope from the main app (''TAO_''&envLabel). When a user''s bookmark or redirect hit /setup/, their session.userid did not exist in the Setup scope, causing a 403/Whoops error. Fix: Changed this.name to ''TAO_''&envLabel to share the main app session. Also changed samesite cookie from Strict to Lax (matching main app) so email links work cross-site. Removed the overly aggressive onRequestStart auth gate that blocked new users from reaching setup pages. See also #1646 (duplicate). Files changed: setup/Application.cfc'
),
    ticketStatus = 'Implemented',
    testingscript = '1. Navigate directly to /setup/ while logged in -- should redirect to dashboard (index.cfm checks UUID)\n2. Log out, then navigate to /setup/?uuid=<valid_uuid> -- should show setup form\n3. Log in normally via /app/ -- should reach dashboard without error\n4. Verify session persists when navigating between /app/ and /setup/ pages\n5. Check that new user setup via email link still works'
WHERE ticketid = 1615;

-- ============================================================
-- Ticket #1646: Login Issue (duplicate of #1615)
-- Status: Implemented
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[IMPLEMENTED 2026-03-20] Same root cause as #1615. /setup/Application.cfc session scope mismatch. Fixed by changing this.name from ''Setup_''&envLabel to ''TAO_''&envLabel in setup/Application.cfc. See #1615 for full details. Files changed: setup/Application.cfc'
),
    ticketStatus = 'Implemented',
    testingscript = '1. Same testing steps as #1615\n2. Navigate directly to /setup/ while logged in -- should redirect to dashboard\n3. Verify no Whoops error when hitting /setup/ URLs'
WHERE ticketid = 1646;

-- ============================================================
-- Ticket #1617: Company Appearing Twice
-- Status: Implemented
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[IMPLEMENTED 2026-03-20] Root cause: ContactItemService.INScontactitems_23771() had no SELECT-before-INSERT uniqueness check. When the audition creation flow or tag addition flow called this function, it would always INSERT a new company contactitem even if one already existed for the same contact. Fix: Added a uniqueness check that queries contactitems_tbl for an existing active company record before inserting. If found, returns the existing itemid. See also #1630. Files changed: services/ContactItemService.cfc (INScontactitems_23771 function)'
),
    ticketStatus = 'Implemented',
    testingscript = '1. Find a contact with an existing company link\n2. Add an audition for that contact with the same company\n3. Verify the company does NOT appear twice on the contact profile\n4. Check contactitems_tbl: SELECT * FROM contactitems_tbl WHERE contactid = [ID] AND valuecategory = ''Company'' -- should have only one active row per company\n5. Add a NEW company to the contact -- should still work correctly'
WHERE ticketid = 1617;

-- ============================================================
-- Ticket #1630: Relationship System Doubled
-- Status: Implemented
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[IMPLEMENTED 2026-03-20] Root cause: When adding an audition for a CD, the follow-up system could be enrolled twice through overlapping code paths (modalansweryes.cfm during form processing AND the post-save follow-up modal via systemchange.cfm/add_system.cfm). The SystemUserService.addfuSystemUsers() had a FOR UPDATE uniqueness check, but add_system.cfm still created duplicate notifications if the enrollment already existed. Fix: (1) Added guard in audition_check.cfm to skip the follow-up modal if the contact already has an active system enrollment. (2) Added guard in add_system.cfm to skip notification creation if pending notifications already exist for the suid. See also #1617. Files changed: include/audition_check.cfm, include/add_system.cfm'
),
    ticketStatus = 'Implemented',
    testingscript = '1. Find a CD contact WITHOUT a relationship system\n2. Create an audition for that CD\n3. If the follow-up prompt appears, click Add\n4. Go to the CD''s profile -- verify the system appears ONCE (not twice)\n5. Check fusystemusers_tbl: SELECT * FROM fusystemusers_tbl WHERE contactid = [ID] AND sustatus = ''Active'' AND isdeleted = 0 -- should have only one row\n6. Check funotifications: SELECT * FROM funotifications WHERE suid = [SUID] AND notstatus = ''Pending'' -- should not have duplicates'
WHERE ticketid = 1630;

-- ============================================================
-- Ticket #1655: Company Type dropdown not filtering
-- Status: Implemented (previously)
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[IMPLEMENTED 2026-03-20] Fix was already applied in a prior session. The company name dropdown now filters by selected company type using client-side JavaScript that reads the data-company-types attribute on each option. The type data comes from ContactItemService.SELcontactitems_24040() which uses GROUP_CONCAT to aggregate company types. Applied to both remoteaddC.cfm (add) and remoteUpdateC.cfm (edit). Files changed: include/remoteaddC.cfm, include/remoteUpdateC.cfm'
),
    ticketStatus = 'Implemented',
    testingscript = '1. Navigate to a contact detail page\n2. Click to add a company\n3. Select a company type (e.g., Casting Office)\n4. Verify the company name dropdown only shows companies of that type\n5. Select a different type -- dropdown should update\n6. Select no type or Custom -- all companies should show'
WHERE ticketid = 1655;

-- ============================================================
-- Ticket #1634: Add New CD Whoops Error
-- Status: Implemented (previously)
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[IMPLEMENTED 2026-03-20] Fix was already applied in a prior session. Root cause: include/folder_setup.cfm referenced an undefined variable dir_missing_avatar_filename when copying the default avatar for a newly created contact during audition creation. Replaced with application.defaultAvatarPath which is always defined. Files changed: include/folder_setup.cfm'
),
    ticketStatus = 'Implemented',
    testingscript = '1. Create a new audition\n2. In the CD section, select "***ADD NEW***"\n3. Enter a new casting director name\n4. Submit the audition form\n5. Verify no Whoops error -- audition should be created and CD contact should appear'
WHERE ticketid = 1634;

-- ============================================================
-- Ticket #1653: Link Duplication (IMDB)
-- Status: Implemented (previously)
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[IMPLEMENTED 2026-03-20] Fix was already applied in a prior session. Root cause: contact_pane.cfm rendered social profile links both as branded icons (via getSocialIcons) AND as generic text links. Fix: Added a guard that checks if the URL already has a branded icon rendered before displaying it in the generic links list. If a match is found in the profiles query, the duplicate text link is skipped. Files changed: include/contact_pane.cfm'
),
    ticketStatus = 'Implemented',
    testingscript = '1. Navigate to a contact that has an IMDB link\n2. Verify the IMDB logo icon appears once (not duplicated as both icon and text link)\n3. Add a LinkedIn link -- verify it appears once as a branded icon\n4. Add a generic URL -- verify it appears as a text link (not as a branded icon)'
WHERE ticketid = 1653;

-- ============================================================
-- Ticket #1652: Notes Edit - can''t save changes
-- Status: Implemented
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[IMPLEMENTED 2026-03-20] Root cause (Bug A): The form submit handler used $(\"#snow-editor\").html() which captured the entire Quill container including .ql-clipboard and .ql-tooltip wrapper divs, causing progressive corruption on each save. Root cause (Bug B): A partial fix had added $(\"#noteDetails\").val($(\"#snow-editor .ql-editor\").text()) which overwrote the independent Note Title textarea, causing Parsley validation to block submission when the Quill editor was empty. Fix: Changed to $(\"#snow-editor .ql-editor\").html(), removed the erroneous noteDetails sync, added if($editor.length) guard. Files changed: include/note-update-event.cfm, include/note-update-aud.cfm, include/note-add-event.cfm'
),
    ticketStatus = 'Implemented',
    testingscript = '1. Navigate to a contact with an existing note\n2. Click edit on the note\n3. Make changes in the rich text editor\n4. Click Update\n5. Verify the note reflects the changes\n6. Edit the note again -- verify content is clean (no nested div wrappers)\n7. Test adding a new note with formatting -- verify it saves correctly'
WHERE ticketid = 1652;

-- ============================================================
-- Ticket #1633: Self Tape Duration
-- Status: Implemented (previously)
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[IMPLEMENTED 2026-03-20] Fix was already applied in a prior session. The audition add form (include/audition-add.cfm) now: (1) Hides the duration field when Self Tape is selected (type value 2), (2) Sets default duration to 15 minutes (durid=4) when hidden, (3) Removes the ''Unknown'' option from the duration dropdown. The handleSelectChange() JS function at line 112-123 handles the show/hide logic. Files changed: include/audition-add.cfm'
),
    ticketStatus = 'Implemented',
    testingscript = '1. Navigate to add a new audition\n2. Select "Self Tape" as audition type\n3. Verify the Duration field is hidden\n4. Select "In Person" -- Duration field should reappear\n5. Verify "Unknown" is NOT in the duration dropdown options\n6. Submit a self-tape audition -- verify it saves with 15-minute default duration'
WHERE ticketid = 1633;

-- ============================================================
-- Ticket #1631: Callback SAME button not working
-- Status: Implemented
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[IMPLEMENTED 2026-03-20] Root cause: The SAME button click handler referenced getElementById(''eventLocation'') but the actual HTML element ID is eventLocation + the event ID (e.g. eventLocation12345). getElementById returned null and the subsequent .value assignment threw an uncaught TypeError that halted the entire handler. Secondary bug: region dropdown was set BEFORE country dropdown and filterRegions() was never called. Fix: (1) Changed to getElementById(''eventLocation'' + event_id) using cfoutput. (2) Reordered so country is set first, filterRegions() is called, then region is set. Files changed: include/remoteaudupdateform.cfm'
),
    ticketStatus = 'Implemented',
    testingscript = '1. Create an audition with an in-person location (including special characters like quotes in the address)\n2. Click to add a callback\n3. Click the "Same" button\n4. Verify all location fields are populated from the original audition\n5. Verify country and region/state dropdowns are set correctly\n6. Test with an audition that has no location -- Same button should not appear'
WHERE ticketid = 1631;

-- ============================================================
-- Ticket #1675: Photo Upload Squished Preview
-- Status: Implemented (previously)
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[IMPLEMENTED 2026-03-20] Root cause: Safari does not auto-correct EXIF Orientation tags. Portrait images at 300 PPI with EXIF Orientation metadata appeared squished. Secondary issue: .tao-card-avatar img used height:auto with object-fit:contain, allowing portrait images to expand vertically. Fix: (1) Added image-orientation:from-image to .tao-avatar in tao-components.css, (2) New rule block in tao-components.css for .current-avatar, .birthday-avatar, .team-avatar, .tao-sidebar__avatar, .tao-card-avatar img, .tao-card-photo-body img, (3) Changed .tao-card-avatar img to height:60px and object-fit:cover in app.min.css, (4) Added image-orientation:from-image to inline styles in image-upload.cfm and image-upload-contact.cfm. Files changed: app/assets/css/tao-components.css, app/assets/css/app.min.css, include/image-upload.cfm, include/image-upload-contact.cfm'
),
    ticketStatus = 'Implemented',
    testingscript = '1. Upload a portrait 8x10 JPG headshot (300 PPI) on Safari/Mac\n2. Verify the preview is not squished -- should display as a circle with correct proportions\n3. Verify the saved avatar displays correctly on the contact detail page\n4. Test on Chrome for regression'
WHERE ticketid = 1675;

-- ============================================================
-- Ticket #1656: Font Color Paste Issue
-- Status: Implemented (previously)
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[IMPLEMENTED 2026-03-20] Root cause: Quill v1.3.6 preserves inline color and background-color styles from pasted HTML by default. Text from dark-themed websites retains white font color, invisible against the white editor background. Fix: Added a clipboard matcher in form-quill.js (lines 38-49) that strips color and background attributes from all pasted Delta operations via quill.clipboard.addMatcher(Node.ELEMENT_NODE, ...). Users can still set colors manually via the toolbar color picker. Files changed: app/assets/js/form-quill.js, share/assets/form-quill.js'
),
    ticketStatus = 'Implemented',
    testingscript = '1. Copy text with white font from a dark-background website\n2. Paste into a TAO note editor\n3. Verify the pasted text is visible (black on white) -- color should be stripped\n4. Verify bold/italic/underline formatting is preserved after paste\n5. Verify the toolbar color picker still works for intentional coloring'
WHERE ticketid = 1656;

-- ============================================================
-- TIER 1C: Tickets requiring live debugging (document only)
-- ============================================================

-- Ticket #1569: Problem Saving
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[TRIAGE 2026-03-20] Investigated save endpoints for contacts: ContactService.INScontactdetails() and contactitems INSERT operations all use cfqueryparam and have proper error handling. The photo upload uses Croppie with AJAX save to the server. Tags are saved via AJAX to /ajax/ endpoints. Without knowing which exact page (contact detail? quick-add modal? import flow?), browser, or whether this was a one-time occurrence, we cannot identify the root cause. Request from user: (1) exact page URL where this happened, (2) browser and OS, (3) whether the issue is reproducible, (4) whether the picture upload showed a preview before losing it. No code fix attempted.'
)
WHERE ticketid = 1569;

-- Ticket #1614: Blank screen on iPhone
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[TRIAGE 2026-03-20] Code inspection: (1) Verified <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"> exists in core.cfm layout template. (2) No CSS position:fixed issues found that would break iOS Safari. (3) The main layout uses Bootstrap 5 which is iOS-compatible. (4) No JS APIs used that are unavailable in mobile Safari. This likely requires device-specific debugging (BrowserStack or iOS Safari dev tools) to identify. Could be a network/CDN issue, a service worker caching problem, or a specific iOS Safari rendering bug. Recommend testing on BrowserStack with iPhone 14 Pro Max Safari to reproduce.'
)
WHERE ticketid = 1614;

-- Ticket #2173: Import Relationships Form not Working
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[TRIAGE 2026-03-20] The Import V3 system was verified working as of March 2026 (CSV upload, field mapping, validation, review grid, finalize all functional). If the "relationships form" refers to the relationship import specifically, the import flow is shared with the contact import and should work. If the issue persists, need: (1) exact URL and steps to reproduce, (2) browser console errors, (3) whether the user''s session timed out during upload. This is likely resolved or a session/browser issue.'
)
WHERE ticketid = 2173;

-- ============================================================
-- TIER 2: Feature requests (document only)
-- ============================================================

-- Ticket #2190: Import resolve duplicates button
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[TRIAGE 2026-03-20] Confirmed as feature gap, not a bug. The ''Update Existing'' button sends action=''update'' but the backend (ajax/importv3/row_action.cfm) only handles: ignore, create, skip, import_new. Implementation would require: (1) New ''update'' action handler in row_action.cfm, (2) Merge logic to combine incoming CSV fields with existing contact record, (3) Conflict resolution for non-empty fields on both sides, (4) Integration with DuplicateMatcherService.cfc. Medium complexity. Not implemented this cycle.'
)
WHERE ticketid = 2190;

-- Ticket #1623: Company info auto-populate
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[TRIAGE 2026-03-20] Feature request confirmed. Implementation would require: (1) AJAX lookup on company selection in the relationship add form, (2) Query to fetch company phone, address, social media from contactitems where valuecategory=''Company'', (3) JS to populate form fields from AJAX response, (4) Handle cases where company has multiple addresses/phones. Related to #585/#2085 (company entities). Medium complexity.'
)
WHERE ticketid = 1623;

-- Ticket #1839: Mailing Labels
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[TRIAGE 2026-03-20] Feature request. Implementation would require: (1) Label format selection UI (Avery 5160, 5163, etc.), (2) Contact/address selection and filtering, (3) PDF generation using cfhtmltopdf or a library like jsPDF, (4) Proper address formatting for selected label size. Alternative: CSV export of addresses for Word mail merge. Medium complexity.'
)
WHERE ticketid = 1839;

-- Ticket #1780: Filter auditions by agent/team
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[TRIAGE 2026-03-20] Feature request. Duplicate group with #1263, #2180. Would add a filter dropdown to the auditions list to filter by source/team member. Implementation: (1) Add agent/team member dropdown filter to audition list page, (2) AJAX endpoint to query auditions filtered by source, (3) Display stats per agent (audition counts by type, casting directors, etc.). Related to reporting module.'
)
WHERE ticketid = 1780;

-- Ticket #1636: International phone formatting
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[TRIAGE 2026-03-20] Feature request. Options: (1) Use libphonenumber JS library for client-side formatting, (2) Store raw digits + country code, format on display, (3) Add country code field to phone entries in contactitems. Recommended approach: Store phone numbers with country code prefix (e.g. +61 for AU, +1 for US) and use libphonenumber for display formatting. Medium complexity.'
)
WHERE ticketid = 1636;

-- ============================================================
-- TIER 3: External / blocked (document only)
-- ============================================================

-- Ticket #2143: Google app verification
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[TRIAGE 2026-03-20] External dependency. Google OAuth app verification is a manual process through Google Cloud Console. Not a code bug. Requires submitting the app for Google verification review with privacy policy, terms of service, and scope justification. Until verified, users see ''unverified app'' warning. Blocks #2015, related to #1458, #1657, #1665.'
)
WHERE ticketid = 2143;

-- Ticket #2015: Google integration verification
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[TRIAGE 2026-03-20] Blocked by #2143 (app not verified by Google). Two-way sync would require: (1) Google push notifications/webhooks for changes, (2) Conflict resolution for events modified on both sides, (3) Bidirectional event mapping between TAO events table and Google Calendar events. One-way sync (TAO to Google) should work once app is verified.'
)
WHERE ticketid = 2015;

-- Ticket #1657: Calendar not syncing
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[TRIAGE 2026-03-20] Related to Google integration (#2143). Calendar sync depends on Google OAuth which is blocked by app verification. Additionally checked: the calendar feed endpoint and event queries have no date-range restrictions that would cause events after October to not show. The issue is likely the Google OAuth connection expiring. Once #2143 is resolved, this should be re-tested.'
)
WHERE ticketid = 1657;

-- ============================================================
-- Verification
-- ============================================================
SELECT ticketid, ticketName, ticketStatus,
       LEFT(ticketResponse, 120) AS response_preview,
       LEFT(testingscript, 80) AS script_preview
FROM tickets
WHERE ticketid IN (2192, 2191, 2184, 2161, 2140, 1725,
                   1615, 1646, 1617, 1630, 1655, 1634, 1653, 1652, 1633, 1631, 1675, 1656,
                   1569, 1614, 2173, 2190, 1623, 1839, 1780, 1636, 2143, 2015, 1657);
