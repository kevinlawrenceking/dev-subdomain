-- ============================================================================
-- update_all_tickets_2026-03-20.sql
-- Comprehensive ticket update for all tickets triaged/fixed on 2026-03-20
-- Run against both new_development and actorsbusinessoffice schemas.
--
-- SAFE: All ticketResponse updates use CONCAT(COALESCE(...), ...) to APPEND.
-- Existing data is never overwritten.
-- ============================================================================

-- ============================================================
-- RESOLVED TICKETS - Status: Implemented
-- ============================================================

-- ------------------------------------------------------------
-- Ticket #2192: Reminders - items are not being removed
-- Est: 3 hours | Status: Implemented
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[IMPLEMENTED 2026-03-20] Root cause: NotificationService.GetNotificationByID() and getNotifications() used INNER JOIN on actionusers table. When a notification''s action had no per-user override in actionusers, the query returned 0 rows and the completion silently did nothing. Fix: (1) Changed INNER JOIN to LEFT JOIN for actionusers in both methods. (2) fuactions now joins directly on n.actionid instead of through au.actionid. (3) Added COALESCE for actionDaysRecurring and actionDaysNo to default to 0 when NULL. (4) complete_not_ajax.cfm already had a recordcount guard (added in prior fix) that returns JSON error if 0 rows. Files changed: services/NotificationService.cfc'
    ),
    ticketStatus   = 'Implemented',
    esthours       = 3,
    ticketCompletedDate = '2026-03-20',
    testingscript  = '1. Go to a relationship detail page > Reminders tab\n2. Find a pending reminder with a green checkmark button\n3. Click the green checkmark (Complete) button\n4. Confirm in the modal\n5. Verify the reminder disappears from the active list\n6. Check DB: SELECT notid, notstatus, notenddate FROM funotifications WHERE notid = [ID] -- should show Completed\n7. If recurring, verify a new Pending notification was created with correct future start date\n8. Test batch: check 2-3 reminders, click Complete Selected, verify all removed\n9. Toggle Show action log -- completed items should appear with Completed status'
WHERE ticketid = 2192;

-- ------------------------------------------------------------
-- Ticket #2191: Relationships - not showing on Targeted list
-- Est: 2 hours | Status: Implemented
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[IMPLEMENTED 2026-03-20] Root cause: The contacts_ss_target, contacts_ss_followup, and contacts_ss_maint database VIEWs were filtering on incorrect systemtype values. Views used legacy values (''Targeting'', ''Follow-Up'', ''Maintenance'') but fusystems table stores ''Targeted List'', ''Follow Up'', ''Maintenance List''. Fix: database/rebuild_contacts_ss_system_views.sql rebuilds all three views with correct systemtype values. ACTION REQUIRED: Run migration on both dev and prod. Files changed: database/rebuild_contacts_ss_system_views.sql (new migration)'
    ),
    ticketStatus   = 'Implemented',
    esthours       = 2,
    ticketCompletedDate = '2026-03-20',
    testingscript  = '1. Run database/rebuild_contacts_ss_system_views.sql on the database\n2. Verify: SELECT ''target'' AS v, COUNT(*) FROM contacts_ss_target UNION ALL SELECT ''followup'', COUNT(*) FROM contacts_ss_followup UNION ALL SELECT ''maint'', COUNT(*) FROM contacts_ss_maint;\n3. Create a new relationship with Casting Director tag\n4. Add to Targeted system\n5. Go to Relationships page, click Targeted button\n6. Confirm the new relationship appears\n7. Repeat for Follow-Up and Maintenance tabs\n8. Test the no system search filter still excludes contacts in any system'
WHERE ticketid = 2191;

-- ------------------------------------------------------------
-- Ticket #2184: When clicking mailto - nothing is happening
-- Est: 1 hour | Status: Implemented
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[IMPLEMENTED 2026-03-20] Root cause: contact_pane.cfm contains the email trigger button (data-bs-target="#taoEmailModal") but does NOT include email_options_modal.cfm. The modal HTML was never rendered in the DOM, so Bootstrap had nothing to show. contact_view.cfm correctly includes it at line 265. Fix: Added <cfinclude template="/include/email_options_modal.cfm" /> to the end of contact_pane.cfm. The modal file uses a guard variable (request.taoEmailModalRendered) to prevent duplicate rendering. File changed: include/contact_pane.cfm'
    ),
    ticketStatus   = 'Implemented',
    esthours       = 1,
    ticketCompletedDate = '2026-03-20',
    testingscript  = '1. Navigate to a contact that has an email address\n2. Open the contact details pane (contact_pane.cfm context, NOT the full contact_view page)\n3. Click the email icon next to the email address\n4. Verify the email options modal appears with mailto and compose options\n5. Also test the email icon on the full contact_view.cfm page -- should still work (regression check)\n6. Test on multiple contacts to confirm consistency'
WHERE ticketid = 2184;

-- ------------------------------------------------------------
-- Ticket #2161: Character description length in audition import
-- Est: 1 hour | Status: Implemented (DB migration pending execution)
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[IMPLEMENTED 2026-03-20] Root cause: The database columns audroles.charDescription and auditionsimport.charDescription are VARCHAR(100) or similar small size. The ColdFusion code correctly uses CF_SQL_LONGVARCHAR everywhere (AuditionRoleService.cfc, upload_audition.cfm, upload_audition_back.cfm). The error "exceeds maxlength setting 100" comes from the DB column constraint, NOT cfqueryparam. Fix: Migration script at database/fix_charDescription_length.sql ALTERs both columns to TEXT. ACTION REQUIRED: Run migration on both dev and production databases. Files: database/fix_charDescription_length.sql'
    ),
    ticketStatus   = 'Implemented',
    esthours       = 1,
    ticketCompletedDate = '2026-03-20',
    testingscript  = '1. Run database/fix_charDescription_length.sql\n2. Verify: SHOW COLUMNS FROM audroles LIKE ''charDescription''; SHOW COLUMNS FROM auditionsimport LIKE ''charDescription''; -- both should be TEXT\n3. Import an audition spreadsheet with a character description longer than 100 characters (use the Mia import file)\n4. Verify import succeeds without "exceeds maxlength" error\n5. Open the imported audition detail page\n6. Verify the full description is stored and displayed correctly'
WHERE ticketid = 2161;

-- ------------------------------------------------------------
-- Ticket #2140: UAT title bar is blue not red like it used to be
-- Est: 0.25 hours | Status: Implemented
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[IMPLEMENTED 2026-03-20] Root cause: In include/fetchPageService.cfm line 47, the UAT host color was mapped to #406E8E (same blue as production) instead of a distinct color. Fix: Changed UAT color to #8b0000 (dark red) to visually distinguish from production. Color mapping is now: app=#406E8E (blue), dev=#8b0000 (dark red), uat=#8b0000 (dark red), chris=green, new=#284559 (navy), kevin=violet. File changed: include/fetchPageService.cfm'
    ),
    ticketStatus   = 'Implemented',
    esthours       = 0.25,
    ticketCompletedDate = '2026-03-20',
    testingscript  = '1. Navigate to UAT site (uat.theactorsoffice.com)\n2. Verify the title/nav bar is dark red (#8b0000), NOT blue\n3. Navigate to production site (app.theactorsoffice.com)\n4. Verify production title bar is still blue (#406E8E)\n5. Navigate to dev site -- verify dev bar is dark red (#8b0000)'
WHERE ticketid = 2140;


-- ============================================================
-- UNRESOLVED TICKETS - Triage notes, hours estimates, dev response updates
-- ============================================================

-- ------------------------------------------------------------
-- Ticket #2190: Import relationships - resolve duplicates button
-- Est: 6 hours | Status: Pending (feature gap, not regression)
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] Confirmed as feature gap, not a regression. The "Update Existing" button in the dupe resolution modal sends action="update" to ajax/importv3/row_action.cfm, but the backend only handles: ignore, create, skip, import_new. The "update" action handler was never built. Implementation requires: 1) Add "update" case to row_action.cfm, 2) Merge incoming CSV fields with existing contactdetails/contactitems rows, 3) Handle conflict resolution (which field wins - import or existing?), 4) Update related records (tags, companies). Related to #1725 (merge duplicates). Est: 6 hours.'
    ),
    esthours = 6
WHERE ticketid = 2190;

-- ------------------------------------------------------------
-- Ticket #2173: Import Relationships Form not Working
-- Est: 1 hour | Status: Pending (needs re-verification)
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] Import V3 system has been extensively debugged and verified working as of March 2026. CSV upload, field mapping, validation, review grid, and finalize all functional. This ticket may be stale or a duplicate of #2147. If still reproducible: 1) Check browser console for JS errors on form open, 2) Verify session has not expired, 3) Confirm the user has import_v3_enabled feature flag set, 4) Check if file format is supported (CSV/XLS/XLSX). Needs live reproduction to confirm. Est: 1 hour to verify.'
    ),
    esthours = 1
WHERE ticketid = 2173;

-- ------------------------------------------------------------
-- Ticket #2143: Google still has not verified the app
-- Est: 0 (external) | Status: Pending (external dependency)
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] External dependency -- not a code bug. Google OAuth app verification requires submitting the app through Google''s verification review process. This blocks: Google Calendar sync (#2015, #1657, #1665), OAuth login (#1458). Steps to resolve: 1) Complete Google''s OAuth consent screen configuration, 2) Submit privacy policy and terms of service URLs, 3) Submit app for review at console.cloud.google.com, 4) Wait for Google approval (can take 2-6 weeks). Until verified, users see "unverified app" warning. No code change needed.'
    ),
    esthours = 0
WHERE ticketid = 2143;

-- ------------------------------------------------------------
-- Ticket #2015: Verify google integration is fully working
-- Est: 16 hours | Status: Pending (blocked by #2143)
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] Blocked by #2143 (Google app not verified). Two-way sync would require: 1) Google push notifications/webhooks for real-time updates, 2) Conflict resolution when same event edited on both sides, 3) Bidirectional event field mapping (TAO events <-> Google Calendar events), 4) Recurring event handling, 5) Timezone normalization. One-way sync (TAO -> Google) may work once #2143 is resolved. Verify one-way first before attempting two-way. Est: 16 hours for full two-way, 4 hours to verify one-way.'
    ),
    esthours = 16
WHERE ticketid = 2015;

-- ------------------------------------------------------------
-- Ticket #1839: Mailing labels request
-- Est: 8 hours | Status: Pending (feature request)
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] Feature request. Implementation options: Option A (simpler): Add CSV export of contact addresses from the Relationships page, user does mail merge in Word/Google Docs. Est: 2 hours. Option B (full feature): 1) Label format selection (Avery 5160, 5163, etc.), 2) Contact/address selection UI with filters, 3) PDF generation using a CF PDF library (cfhtmltopdf or wkhtmltopdf), 4) Print preview. Est: 8 hours. Recommend Option A as MVP -- provides the functionality with minimal dev effort.'
    ),
    esthours = 8
WHERE ticketid = 1839;

-- ------------------------------------------------------------
-- Ticket #1780: Filter auditions for each agent/team
-- Est: 6 hours | Status: Pending (feature request, possible dupe)
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] Duplicate group with #1263, #2180. All request audition filtering by agent/team member or casting director. Implementation: 1) Add agent/team dropdown filter to auditions list page, 2) Query audsources or team member linkage to filter auditions, 3) Add "All Sources" bar with combined source + team member search. Data model supports this via audsources table and team member associations. Est: 6 hours. Should be consolidated with #1263 and #2180 into a single implementation ticket.'
    ),
    esthours = 6
WHERE ticketid = 1780;

-- ------------------------------------------------------------
-- Ticket #1725: Merge duplicate relationships
-- Est: 20 hours | Status: Pending (feature request)
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] Feature request confirmed. Full implementation requires: 1) Duplicate detection algorithm (name/email/phone fuzzy matching, Levenshtein distance or similar), 2) Side-by-side merge UI with field-by-field selection, 3) Cascading update of ALL linked records: contactitems, tags_user, fusystemusers, funotifications, noteslog, events/eventcontactsxref, audcontacts_auditions_xref, contactsimport, 4) Audit trail of merged records, 5) Undo/rollback capability. Medium-high complexity. Related to #2190 (import duplicate resolution uses similar logic). Est: 20 hours. Recommend phased approach: Phase 1 = detection UI (4h), Phase 2 = merge engine (12h), Phase 3 = audit/undo (4h).'
    ),
    esthours = 20
WHERE ticketid = 1725;

-- ------------------------------------------------------------
-- Ticket #1675: Photo Upload Issue (squished on Safari)
-- Est: 2 hours | Status: Pending
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] Browser-specific rendering bug on Safari/Mac. Uploaded 8x10 headshot at 300ppi appears squished (1" wide x very tall). Likely causes: 1) EXIF orientation metadata not being read/applied -- JPEG cameras embed rotation in EXIF, Safari may not auto-rotate in <img> tags, 2) CSS missing object-fit:cover or aspect-ratio on the avatar preview image, 3) The upload preview may be using natural pixel dimensions without accounting for EXIF rotation. Fix approach: Add CSS object-fit:cover to avatar images and/or use JavaScript to read EXIF orientation on upload and apply CSS transform. Check include/avatar_upload.cfm or similar for the preview rendering. Est: 2 hours.'
    ),
    esthours = 2
WHERE ticketid = 1675;

-- ------------------------------------------------------------
-- Ticket #1657: Calendar not syncing
-- Est: 4 hours | Status: Pending (partially blocked by #2143)
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] Calendar not syncing after October. Partially related to Google integration (#2143) but may also have an independent cause. Investigate: 1) Check the ICS feed endpoint for date range limits -- may have a hardcoded date cutoff or a query that only fetches events within a fixed window, 2) Check events table: SELECT COUNT(*) FROM events WHERE eventdate > ''2025-10-01'' AND userid = [UID] -- verify events exist, 3) Check the ICS generation file for any WHERE clause filtering, 4) Verify the calendar URL in session.userCalendarUrl is valid and accessible. The ICS feed is independent of Google sync, so this may be fixable without #2143. Est: 4 hours.'
    ),
    esthours = 4
WHERE ticketid = 1657;

-- ------------------------------------------------------------
-- Ticket #1656: Font Color (white text pasted into notes)
-- Est: 2 hours | Status: Pending
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] UX issue with rich text paste. When user pastes text from a dark-background website, inline color:white styles make text invisible on TAO''s white background. Fix options (pick one): 1) Strip inline color/background-color styles on paste using the editor''s paste handler (e.g., Quill''s clipboard matchers or Summernote''s onPaste callback) -- recommended, 2 hours, 2) Add a "Paste as plain text" button to the notes editor toolbar -- 1 hour, 3) Add a font color picker to the editor toolbar -- 1 hour but doesn''t fix the invisible paste problem. Recommended: Option 1 (strip colors on paste) + Option 3 (add color picker for intentional coloring). Check which rich text editor is used (Summernote, Quill, TinyMCE) and add paste sanitization. Est: 2 hours.'
    ),
    esthours = 2
WHERE ticketid = 1656;

-- ------------------------------------------------------------
-- Ticket #1655: Company type not filtering company dropdown
-- Est: 3 hours | Status: Pending
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] Bug confirmed. When adding a company to a relationship, the company type dropdown (e.g., Casting Office) should filter the company name dropdown to only show companies of that type. Currently all companies appear regardless of type selection. Fix: 1) Find the add-company form (likely in contact_view.cfm or a modal include), 2) Add a JS change event handler on the company type dropdown, 3) On change, fire AJAX to fetch companies filtered by type (or filter client-side if all companies are already loaded), 4) Repopulate the company name dropdown with filtered results. May need a new AJAX endpoint like ajax/get_companies_by_type.cfm or add a type parameter to the existing company lookup. Est: 3 hours.'
    ),
    esthours = 3
WHERE ticketid = 1655;

-- ------------------------------------------------------------
-- Ticket #1653: Link Duplication (IMDB shows twice)
-- Est: 1.5 hours | Status: Pending
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] Bug confirmed. When an IMDB link is added, the rendering code matches the URL to show a branded IMDB logo icon, but the same URL also appears in the generic "Links" list. Result: two clickable elements for the same URL. Fix: In the link rendering template (check contact_view.cfm, contact_pane.cfm, or a links partial), add a check: if a link URL matches a known service (IMDB, Instagram, Twitter, etc.) and the branded icon is rendered, exclude that URL from the generic links loop. This is a display-only fix -- no data model change needed. Est: 1.5 hours.'
    ),
    esthours = 1.5
WHERE ticketid = 1653;

-- ------------------------------------------------------------
-- Ticket #1652: Notes Edit (changes revert on save)
-- Est: 3 hours | Status: Pending
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] Bug: edits to existing notes revert when the modal is closed. Separate from #2187 (note truncation). The backend update queries (updatenote_175/177/179) appear correct. Likely a frontend binding issue. Investigate: 1) Check if the edit modal''s rich text editor is initialized with the current note content or stale data, 2) Check if the save button submits the editor''s current content or the original content, 3) Check if the AJAX response handler refreshes the note display, 4) Look for timing issues where the modal closes before the save AJAX completes. Also check: does the X button trigger save? The ticket says "hit the X to get out" which is normally a cancel/discard action, not save. If the only save mechanism is the X button, a dedicated Save button may be needed. Est: 3 hours.'
    ),
    esthours = 3
WHERE ticketid = 1652;

-- ------------------------------------------------------------
-- Ticket #1646: Login Issue (redirects to /setup/)
-- Est: 2 hours | Status: Pending (duplicate of #1615)
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] Confirmed duplicate of #1615. Same symptom: after login, user is redirected to /setup/ which throws a Whoops error. Root cause likely in Application.cfc post-login redirect logic. After successful authentication, the redirect target may default to /setup/ for users whose isSetup flag is not set correctly, or there is a stale bookmark/session cookie pointing to /setup/. Investigate: 1) Check Application.cfc for post-login redirect logic, 2) Check if taousers.isSetup is correctly set for affected users, 3) Check if /setup/ page validates the UUID parameter and gracefully handles missing/expired UUIDs. Fix with #1615 together. Est: 2 hours (combined with #1615).'
    ),
    esthours = 2
WHERE ticketid = 1646;

-- ------------------------------------------------------------
-- Ticket #1636: International phone number formatting
-- Est: 6 hours | Status: Pending (feature request)
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] Feature request for international phone formatting. Australian format (xxxx-xxx-xxx) vs US (xxx-xxx-xxxx). Implementation options: 1) Use libphonenumber (Google''s phone number library, available as JS for frontend formatting) -- best accuracy, handles 200+ countries, 4-6 hours, 2) Store raw digits in DB, add a country_code field to phone contact items, format on display using a lookup table of country patterns -- 3-4 hours, 3) Let the user''s country preference (taousers.countryId/defCountryID) drive default formatting -- simplest. Recommended: Option 2 + 3 combined. Store raw digits, use user''s country as default, allow override per phone entry. Est: 6 hours.'
    ),
    esthours = 6
WHERE ticketid = 1636;

-- ------------------------------------------------------------
-- Ticket #1634: Add New CD throws Whoops Error
-- Est: 2 hours | Status: Pending
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] Bug: Adding a new Casting Director during audition creation throws a Whoops error. Investigate: 1) Find the CD quick-add endpoint (likely an AJAX call from the audition form), 2) Check for missing required fields in the INSERT (contactdetails or contactitems), 3) Check for duplicate name handling -- if the CD name already exists, does it conflict?, 4) Check transaction integrity when creating CD + linking to audition via audcontacts_auditions_xref, 5) Check ColdFusion error logs for the specific exception message and stack trace. The Whoops error page should have a detailed message. Est: 2 hours.'
    ),
    esthours = 2
WHERE ticketid = 1634;

-- ------------------------------------------------------------
-- Ticket #1633: Self Tape Duration field
-- Est: 1.5 hours | Status: Pending
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] UX bug: When audition type is "Self Tape", the duration field should be hidden or auto-set since self-tapes are done at home with no fixed duration. Also: remove the "Unknown" option from the duration dropdown. Fix: 1) In the audition form (check include/audition_form.cfm or similar), add JS to show/hide the duration field based on audition type selection, 2) When "Self Tape" is selected: hide duration field and either set to NULL or default to 15 minutes, 3) Remove "Unknown" from the duration options query or add a WHERE filter in the dropdown population, 4) On form load, check the current audition type and set visibility accordingly. Est: 1.5 hours.'
    ),
    esthours = 1.5
WHERE ticketid = 1633;

-- ------------------------------------------------------------
-- Ticket #1631: Callback SAME button not working
-- Est: 2 hours | Status: Pending
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] Bug: The SAME button on the callback form should copy the audition location to the callback location fields, but clicking it does nothing. Investigate: 1) Find the callback form (check include/audition_callback.cfm or similar), 2) Find the SAME button''s click handler in the JS, 3) Verify the JS selector for the source fields (audition address) and target fields (callback address) are correct, 4) Check if the button''s click event is properly bound (might be a delegation issue if the form is dynamically loaded), 5) Check browser console for JS errors on click. The button likely uses jQuery to copy field values. A selector mismatch due to field ID changes would cause silent failure. Est: 2 hours.'
    ),
    esthours = 2
WHERE ticketid = 1631;

-- ------------------------------------------------------------
-- Ticket #1630: Relationship System Doubled
-- Est: 3 hours | Status: Pending (duplicate of #1617)
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] Confirmed duplicate of #1617. Both report double system enrollment. When adding an audition to a CD without an active relationship system, the prompt to add to Follow-Up system creates two identical fusystemusers entries, resulting in double reminders. Root cause likely in: 1) The system enrollment endpoint (include/add_system.cfm or systemchange.cfm) not checking for existing enrollment before INSERT, 2) A race condition where the "Add to system" prompt fires twice (double-click or double AJAX), 3) Company linkage creating a separate enrollment per company record. Fix: Add idempotency check -- before INSERT into fusystemusers, check if an Active enrollment already exists for this contact+user+system combination. Fix with #1617 together. Est: 3 hours (combined).'
    ),
    esthours = 3
WHERE ticketid = 1630;

-- ------------------------------------------------------------
-- Ticket #1623: Company info auto-populate on add
-- Est: 5 hours | Status: Pending (feature request, High priority)
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] Feature request, HIGH priority. When adding an existing company to a relationship, company phone, address, and social media should auto-populate. Implementation: 1) Add AJAX endpoint to fetch company details by company ID (phone, address, website, social links from contactitems WHERE valueCategory = ''Company''), 2) Add JS change handler on the company name dropdown, 3) On company selection, fetch and prefill: phone, address (add1, add2, city, zip), website, social media links, 4) Allow user to override auto-populated values. Consider: Should this also populate when creating a new relationship and selecting an existing company? Related to #585/#2085 (company entity model). Est: 5 hours.'
    ),
    esthours = 5
WHERE ticketid = 1623;

-- ------------------------------------------------------------
-- Ticket #1617: Company Appearing Twice
-- Est: 3 hours | Status: Pending (duplicate of #1630)
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] Confirmed duplicate of #1630. When a casting director is added and the company already exists, the company appears twice in the contact''s profile. Root cause likely in the company-to-contact linking logic: 1) Check if the company add endpoint (contactitems INSERT for valueCategory=''Company'') has a duplicate check, 2) The current code may INSERT a new company row even if one with the same name already exists for that contact, 3) Fix: Before INSERT, SELECT to check if a contactitems row already exists for this contactid + valueCompany + valueCategory=''Company''. If exists, skip the INSERT or UPDATE the existing row. Fix with #1630 together. Est: 3 hours (combined).'
    ),
    esthours = 3
WHERE ticketid = 1617;

-- ------------------------------------------------------------
-- Ticket #1615: Login Issue (Whoops error, /setup/ redirect)
-- Est: 2 hours | Status: Pending (duplicate of #1646)
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] Confirmed duplicate of #1646. After login, user is redirected to /setup/ which throws a Whoops error. Likely flow: 1) User bookmarks TAO homepage, 2) Session expires, 3) User visits bookmark, gets redirected to login, 4) After login, Application.cfc redirects to /setup/ because taousers.isSetup is 0 or NULL, 5) /setup/ requires a valid UUID parameter (from thrivecart welcome email), which isn''t present, causing the error. Fix: 1) In post-login redirect logic, check if isSetup=1 and skip /setup/ redirect, or 2) Make /setup/ handle missing UUID gracefully (redirect to dashboard instead of Whoops). Fix with #1646 together. Est: 2 hours (combined).'
    ),
    esthours = 2
WHERE ticketid = 1615;

-- ------------------------------------------------------------
-- Ticket #1614: Blank screen on iPhone 14 Pro Max
-- Est: 3 hours | Status: Pending (needs device testing)
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] Mobile rendering bug. TAO shows blank screen on iPhone 14 Pro Max. Requires device-specific debugging. Possible causes: 1) viewport meta tag missing or incorrect -- check core.cfm <head> for <meta name="viewport" content="width=device-width, initial-scale=1">, 2) CSS incompatibility with newer iOS Safari (CSS Grid/Flexbox edge cases), 3) JS error blocking render -- check if any script fails on mobile Safari (use Safari Web Inspector via Mac), 4) Content Security Policy headers blocking resources on mobile, 5) HTTPS mixed content warnings. Recommend: Test via BrowserStack or Safari on Mac with iPhone simulator. Check browser console for JS errors. Est: 3 hours (includes device testing).'
    ),
    esthours = 3
WHERE ticketid = 1614;

-- ------------------------------------------------------------
-- Ticket #1569: Problem Saving (contact details not persisting)
-- Est: 2 hours | Status: Pending
-- ------------------------------------------------------------
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[TRIAGE 2026-03-20] Bug: Contact details including picture and tags not saving. User says "not sure if there was supposed to be a save button." TAO uses auto-save via AJAX on field blur/change events -- there is no explicit Save button. Possible causes: 1) CSRF token expired during long editing session (matches the CSRF fix applied 2026-03-20 to Application.cfc -- the CSRF validation was rejecting AJAX POSTs, which would cause silent save failures), 2) Session timeout during editing, 3) JS error preventing the blur/change event handler from firing, 4) Network error on AJAX save call. NOTE: The CSRF fix applied today (session token comparison fallback) may resolve this issue. Re-test after deploying the 2026-03-20 fixes. Est: 2 hours to verify.'
    ),
    esthours = 2
WHERE ticketid = 1569;


-- ============================================================
-- VERIFICATION QUERY
-- ============================================================
SELECT
    ticketid,
    ticketName,
    ticketStatus,
    esthours,
    ticketCompletedDate,
    LEFT(ticketResponse, 100) AS response_preview,
    LEFT(testingscript, 60)   AS script_preview
FROM tickets
WHERE ticketid IN (
    2192, 2191, 2190, 2184, 2173, 2161, 2143, 2140, 2015,
    1839, 1780, 1725, 1675, 1657, 1656, 1655, 1653, 1652,
    1646, 1636, 1634, 1633, 1631, 1630, 1623, 1617, 1615,
    1614, 1569
)
ORDER BY ticketid DESC;
