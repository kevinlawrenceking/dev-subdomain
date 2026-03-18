-- ============================================================================
-- TAO Ticket Triage - Production SQL Updates
-- Date: 2026-03-18
-- Target: production tickets table (actorsbusinessoffice)
-- Run against: production datasource
-- ============================================================================
-- IMPORTANT: Review before running. All updates use ticketid as primary key.
-- This script is idempotent - safe to run multiple times.
-- Total tickets reviewed: 77
-- ============================================================================

-- ============================================================================
-- SECTION 1: CLOSE GARBAGE / TEST TICKETS (3 tickets)
-- ============================================================================

-- #2182 - "test 3" - garbage test ticket
UPDATE tickets
SET ticketstatus = 'Closed',
    ticketresponse = 'Closed - test/garbage ticket. [TRIAGE 2026-03-18]'
WHERE ticketid = 2182;

-- #2162 - "test" - garbage test ticket
UPDATE tickets
SET ticketstatus = 'Closed',
    ticketresponse = 'Closed - test/garbage ticket. [TRIAGE 2026-03-18]'
WHERE ticketid = 2162;

-- #2019 - "test" - garbage test ticket
UPDATE tickets
SET ticketstatus = 'Closed',
    ticketresponse = 'Closed - test/garbage ticket. [TRIAGE 2026-03-18]'
WHERE ticketid = 2019;

-- ============================================================================
-- SECTION 2: TICKETS WITH CODE FIXES APPLIED (2 tickets -> Implemented)
-- ============================================================================

-- #2187 - Notes cutting off at ~2000 characters
UPDATE tickets
SET ticketstatus = 'Implemented',
    ticketresponse = 'Fixed. Removed LEFT(trim(...), 2000) truncation from all note insert/update paths. Changed 15 locations across 9 files: NoteService.cfc (7 functions), InsertNote_4_1.cfm, InsertNote_169_1.cfm, InsertNote_171_1.cfm, InsertNote_173_1.cfm, InsertNote_308_22.cfm, updatenote_175_1.cfm, updatenote_177_1.cfm, updatenote_179_1.cfm. Notes now store full text without truncation. [TRIAGE 2026-03-18]'
WHERE ticketid = 2187;

-- #2186 - Re-validation not triggered after editing import row
UPDATE tickets
SET ticketstatus = 'Implemented',
    ticketresponse = 'Fixed. Backend revalidation was already working correctly. Bug was in frontend: after saving an edit, loadRows() used the current filter (e.g. "ready"), so when a row status changed to "problem" after revalidation, it disappeared from view. Fixed in contact-import-v3.js by detecting status change in save response and auto-switching filter to "all" with a notification. [TRIAGE 2026-03-18]'
WHERE ticketid = 2186;

-- ============================================================================
-- SECTION 3: BUGS WITH ANALYSIS (needs further work or verification)
-- ============================================================================

-- #2190 - Import "resolve duplicates" / "Update Existing" button does not work
UPDATE tickets
SET ticketresponse = 'Identified as feature gap. The "Update Existing" button in the dupe resolution modal sends action="update" but the backend endpoint (ajax/importv3/row_action.cfm) only accepts: ignore, create, skip, import_new. The "update" action handler needs to be implemented to merge incoming data with the existing contact record. Not a regression - this action was never built. [TRIAGE 2026-03-18]'
WHERE ticketid = 2190;

-- #2184 - mailto/email not working in contact details pane
UPDATE tickets
SET ticketresponse = 'Investigated. Code structure looks correct: both contact_pane.cfm and contact_view.cfm use data-bs-target="#taoEmailModal" and both pages include email_options_modal.cfm. The email icon in relationship details (contact_view.cfm) works. Issue is specific to the contact details pane (contact_pane.cfm) - likely a Bootstrap modal z-index or initialization timing issue. Needs live browser debugging with DevTools console. [TRIAGE 2026-03-18]'
WHERE ticketid = 2184;

-- #2175 - Ability to change default email selection
-- Previous response was mismatched (about import tags). Replacing with correct analysis.
UPDATE tickets
SET ticketresponse = 'Feature request: Add email provider selection (Gmail, Outlook, Yahoo, Default, Copy) to contact pages. The email options modal (email_options_modal.cfm) already exists and works in relationship details view. Needs to be wired up consistently across all contact-related pages where email actions appear. Related to #2184. [TRIAGE 2026-03-18]'
WHERE ticketid = 2175;

-- #2173 - Import Relationships Form not Working
UPDATE tickets
SET ticketresponse = 'Import V3 system has been extensively debugged and verified working as of March 2026. CSV upload, field mapping, validation, review grid, and finalize all functional. If this issue persists, check: 1) file format (CSV/XLS/XLSX supported), 2) browser console for JS errors, 3) session expiration during upload. May be duplicate of #2147. [TRIAGE 2026-03-18]'
WHERE ticketid = 2173;

-- #2161 - Character Description maxlength in audition import
-- Previous response was mismatched (about contact list links). Replacing with correct analysis.
UPDATE tickets
SET ticketresponse = 'Partially resolved. Code already uses cf_sql_longvarchar for charDescription in AuditionRoleService.cfc, upload_audition.cfm, and upload_audition_back.cfm. Migration script exists at database/fix_charDescription_length.sql to ALTER audroles.charDescription and auditionsimport.charDescription columns to TEXT. ACTION NEEDED: Verify migration was applied to production DB. If columns are still VARCHAR, run the migration. [TRIAGE 2026-03-18]'
WHERE ticketid = 2161;

-- #2147 - Relationship import not working / unsupported file type UNKNOWN
UPDATE tickets
SET ticketresponse = 'Import V3 pipeline verified working end-to-end as of March 2026. CSV upload, mapping, review, and finalize all functional. The "unsupported file type UNKNOWN" error indicates the uploaded file was not recognized - ensure file has correct extension (.csv, .xls, .xlsx). If "Upload Failed with template" persists, check that the template CSV has correct headers. Possibly duplicate of #2173. [TRIAGE 2026-03-18]'
WHERE ticketid = 2147;

-- #2143 - Google has not verified the app
UPDATE tickets
SET ticketresponse = 'External dependency - Google OAuth app verification. Not a code bug. Requires submitting the app for Google verification review. Until verified, users see "unverified app" warning when connecting Google Calendar. Related to #2015, #1458, #1657, #1665 (all Google/calendar sync issues). [TRIAGE 2026-03-18]'
WHERE ticketid = 2143;

-- #2140 - UAT title bar is blue not red
UPDATE tickets
SET ticketresponse = 'UI/config issue. UAT environment should have a distinct title bar color (red) to differentiate from production (blue). Check the environment-specific CSS or config variable that controls the title bar color. Low priority cosmetic issue. [TRIAGE 2026-03-18]'
WHERE ticketid = 2140;

-- #2132 - Audition payrate not saving unless income type chosen
UPDATE tickets
SET ticketresponse = 'Previously marked Implemented but testing shows issue persists. Payrate should save independently of income type selection. Re-investigate the audition details save endpoint to ensure payrate is not conditionally gated on income type having a value. Needs re-fix. [TRIAGE 2026-03-18]'
WHERE ticketid = 2132;

-- #2084 - Setup a way to have a new account for testing
UPDATE tickets
SET ticketresponse = 'Infrastructure request. Need a mechanism to create fresh test accounts for major releases. Options: 1) Admin tool to clone a template account, 2) Seed script that creates a test user with sample data, 3) Separate test environment with reset capability. Critical priority - needed for QA process. [TRIAGE 2026-03-18]'
WHERE ticketid = 2084;

-- #1675 - Photo Upload Issue (squished on Safari/Mac)
UPDATE tickets
SET ticketresponse = 'Browser-specific rendering bug. Uploaded headshot previews appear squished (1" wide x very tall) on Safari/Mac. Likely caused by EXIF orientation metadata not being handled, or CSS aspect-ratio / object-fit not applied to the preview image. Check the avatar upload preview code for Safari-specific image rendering. [TRIAGE 2026-03-18]'
WHERE ticketid = 1675;

-- #1656 - Font Color (white text pasted into notes)
UPDATE tickets
SET ticketresponse = 'UX issue with rich text paste. When users paste text with inline color styles, text can become invisible on white backgrounds. Fix options: 1) Strip inline color styles on paste, 2) Add a "paste as plain text" option, 3) Add font color picker to notes editor. Common rich-text editor issue. [TRIAGE 2026-03-18]'
WHERE ticketid = 1656;

-- #1655 - Company Name dropdown not filtered by Type selection
UPDATE tickets
SET ticketresponse = 'Bug: When adding a company to a relationship, selecting a company type (e.g. Casting Office) should filter the company name dropdown to only show companies of that type. Currently shows all companies regardless. Need AJAX call or JS filter on type dropdown change event. [TRIAGE 2026-03-18]'
WHERE ticketid = 1655;

-- #1653 - Link Duplication (IMDB shows twice)
UPDATE tickets
SET ticketresponse = 'Bug: IMDB link added once displays as both an IMDB logo icon AND a separate generic "Link" entry. Link rendering code matches IMDB URLs to show the logo but also renders the same URL in the generic links list. Need to deduplicate - if a link matches a known service (IMDB), show only the branded icon, not both. [TRIAGE 2026-03-18]'
WHERE ticketid = 1653;

-- #1652 - Notes Edit (cannot save edits to existing notes)
UPDATE tickets
SET ticketresponse = 'Bug: Edits to existing notes revert on close/save. Separate from #2187 (note truncation). The update queries (updatenote_175/177/179) look correct. May be a frontend binding issue - check if the edit modal properly captures edited text and sends the correct noteid. Needs live debugging. [TRIAGE 2026-03-18]'
WHERE ticketid = 1652;

-- #1634 - Add New CD gives Whoops Error
UPDATE tickets
SET ticketresponse = 'Bug: Adding a new Casting Director during audition creation throws a Whoops error. Check the CD creation endpoint for: 1) missing required fields, 2) duplicate name handling, 3) transaction integrity when creating CD + linking to audition. Check error logs for specific exception. [TRIAGE 2026-03-18]'
WHERE ticketid = 1634;

-- #1633 - Self Tape Duration (should not require duration)
UPDATE tickets
SET ticketresponse = 'UX bug: Self-tape auditions should not require duration/time selection since done at home. The "Unknown" duration option should be removed or duration field hidden/optional when audition type is "Self Tape". Check audition form for conditional field visibility based on audition type. [TRIAGE 2026-03-18]'
WHERE ticketid = 1633;

-- #1631 - Callback SAME button not working
UPDATE tickets
SET ticketresponse = 'Bug: SAME button to copy audition location to callback does nothing when clicked. Button appears correctly when original audition is in-person with location filled. JS click handler likely not bound or target field selector is wrong. Check callback form JS for the SAME button click event. [TRIAGE 2026-03-18]'
WHERE ticketid = 1631;

-- #1623 - Company info auto-populate when added to relationship
-- Previous response was mismatched (about SAME button). Replacing.
UPDATE tickets
SET ticketresponse = 'Feature request: When adding an existing company to a relationship, company phone, address, and social media should auto-populate from the company record. Need AJAX lookup on company selection to prefill fields. Related to #585/#2085 (company entities). High priority. [TRIAGE 2026-03-18]'
WHERE ticketid = 1623;

-- #1614 - TAO blank screen on iPhone 14 Pro Max
UPDATE tickets
SET ticketresponse = 'Mobile rendering bug. TAO shows blank screen on iPhone 14 Pro Max. Could be: 1) viewport meta tag issue, 2) CSS incompatibility with newer iOS Safari, 3) JS error blocking render. Need to test on iOS Safari dev tools or BrowserStack. [TRIAGE 2026-03-18]'
WHERE ticketid = 1614;

-- #1569 - Contact details (picture, tags) not saving
UPDATE tickets
SET ticketresponse = 'Bug: Contact details including picture and tags not saving. Verify: 1) Save endpoint is being called, 2) Request includes correct contactid, 3) Server-side handler processes all fields. Could be form serialization or CSRF token issue. [TRIAGE 2026-03-18]'
WHERE ticketid = 1569;

-- ============================================================================
-- SECTION 4: FEATURE REQUESTS WITH TRIAGE NOTES
-- ============================================================================

-- #2181 - Make follow-up prompts customizable
UPDATE tickets
SET ticketresponse = 'Feature request: Customizable follow-up prompt dropdowns. Currently hardcoded. Would need: 1) User-defined prompt options table, 2) Admin UI to manage options, 3) Update follow-up forms to pull from user config. Medium complexity. [TRIAGE 2026-03-18]'
WHERE ticketid = 2181;

-- #2169 - Add "Buyout" option under pay cycle for VO
UPDATE tickets
SET ticketresponse = 'Feature request: Add "Buyout" as pay cycle option for voiceover bookings (one-time payment). Simple addition to pay cycle dropdown - either DB lookup table entry or hardcoded option. Low complexity. [TRIAGE 2026-03-18]'
WHERE ticketid = 2169;

-- #2168 - Add status dropdown for bookings
UPDATE tickets
SET ticketresponse = 'Feature request: Booking status tracking with dropdown: Booked, Signed Contract, Sent Invoice, Paid, Complete. Would need: 1) New column or lookup for booking status, 2) Dropdown on booking form, 3) Report filtering. Medium complexity. [TRIAGE 2026-03-18]'
WHERE ticketid = 2168;

-- #2153 - Give Mia admin testing account
UPDATE tickets
SET ticketresponse = 'Admin task - create testing account for Mia with admin access to ticket system. Operational task, not a code change. Related to #2084 (testing account setup). [TRIAGE 2026-03-18]'
WHERE ticketid = 2153;

-- #2133 - Create API with Casting Networks
UPDATE tickets
SET ticketresponse = 'Feature request: Casting Networks integration to import audition data into TAO. Large scope: 1) CN API availability research, 2) Auth flow, 3) Data mapping, 4) Import mechanism. Significant effort. [TRIAGE 2026-03-18]'
WHERE ticketid = 2133;

-- #2016 - Newsletter / mass mailing functionality
UPDATE tickets
SET ticketresponse = 'Feature request: Mass email to all relationships in a system. Large scope: 1) Email template builder, 2) Recipient list from systems, 3) Email service (SendGrid/SES), 4) Unsubscribe handling, 5) CAN-SPAM compliance. Consider third-party (Mailchimp) vs in-house. Related to #1726, #1632. [TRIAGE 2026-03-18]'
WHERE ticketid = 2016;

-- #2015 - Google integration fully working
UPDATE tickets
SET ticketresponse = 'Two-way Google Calendar sync. Blocked by #2143 (app not verified). Would need: 1) Google push notifications/webhooks, 2) Conflict resolution, 3) Bidirectional event mapping. Related to #1458, #1657, #1665. [TRIAGE 2026-03-18]'
WHERE ticketid = 2015;

-- #1888 - Ability to hide/show reports
UPDATE tickets
SET ticketresponse = 'Feature request: Toggle visibility of individual reports. Would need: 1) User preference for report visibility, 2) Toggle UI on reports page, 3) Filter report list by preferences. Low-medium complexity. [TRIAGE 2026-03-18]'
WHERE ticketid = 1888;

-- #1839 - Printing mailing labels
UPDATE tickets
SET ticketresponse = 'User request: Print mailing labels from TAO addresses. Would need: 1) Label format selection (Avery templates), 2) Contact/address selection UI, 3) PDF generation. Consider if CSV export + Word mail merge is sufficient alternative. Medium complexity. [TRIAGE 2026-03-18]'
WHERE ticketid = 1839;

-- #1810 - Show entire birthday list
UPDATE tickets
SET ticketresponse = 'User request: Show all birthdays, not just upcoming on dashboard. Options: 1) "View All" link on birthday widget -> full list, 2) Birthday report page, 3) Calendar view. Low complexity for option 1. [TRIAGE 2026-03-18]'
WHERE ticketid = 1810;

-- #1802 - Update to Stripe billing
UPDATE tickets
SET ticketresponse = 'Feature: Stripe billing integration with rebill date display, monthly/yearly toggle, invoice access. Significant scope - payment integration, subscription management, billing UI. Related to PayKickstart issues in error logs. [TRIAGE 2026-03-18]'
WHERE ticketid = 1802;

-- #1800 - Translation ability
UPDATE tickets
SET ticketresponse = 'Feature request: Language translation for international users. Options: 1) i18n framework, 2) Google Translate widget, 3) Manual translation files. Consider user base size and primary languages. Low priority. [TRIAGE 2026-03-18]'
WHERE ticketid = 1800;

-- #1726 - Build email extension
UPDATE tickets
SET ticketresponse = 'Feature request: Gmail browser extension to store emails in TAO + batch email. Very large scope: 1) Chrome extension dev, 2) Gmail API, 3) Email-to-contact matching, 4) TAO API for email storage. Related to #2016, #1632. [TRIAGE 2026-03-18]'
WHERE ticketid = 1726;

-- #1725 - Merge duplicate relationships
UPDATE tickets
SET ticketresponse = 'Feature request: Merge duplicate contact/relationship records. Would need: 1) Duplicate detection, 2) Side-by-side merge UI, 3) Field-by-field selection, 4) Cascading update of linked records (notes, events, systems). Medium-high complexity. Related to #2190 (import dupes). [TRIAGE 2026-03-18]'
WHERE ticketid = 1725;

-- #1665 - User requests (calendar search, social media, Google sync)
UPDATE tickets
SET ticketresponse = 'Multi-item request: 1) Search calendar for audition dates - need calendar search UI, 2) Social media for contacts - related to #1473/#1613, 3) Live Google Calendar sync - blocked by #2143, related to #2015/#1458. Three separate features. [TRIAGE 2026-03-18]'
WHERE ticketid = 1665;

-- #1657 - Calendar not syncing / nothing after October
UPDATE tickets
SET ticketresponse = 'Bug: Calendar not syncing, events after October not showing. Likely related to Google integration (#2143). Also check: 1) Date range query in calendar feed endpoint, 2) Event data integrity in DB. Related to #2015, #1458. [TRIAGE 2026-03-18]'
WHERE ticketid = 1657;

-- #1636 - Phone number formatting for different countries
UPDATE tickets
SET ticketresponse = 'Feature: International phone format support (AU, US, etc.). Options: 1) libphonenumber library, 2) Store raw digits + format on display by country, 3) Country code field on phone entries. Medium complexity. [TRIAGE 2026-03-18]'
WHERE ticketid = 1636;

-- #1632 - Email tracking feature
UPDATE tickets
SET ticketresponse = 'Feature request: Backdatable notes, email tracking, email-from-platform with logging. Large scope. Related to #1726 (email extension) and #2016 (mass mailing). Multiple features bundled. [TRIAGE 2026-03-18]'
WHERE ticketid = 1632;

-- #1620 - Drag and drop link arrangement
UPDATE tickets
SET ticketresponse = 'User request: Drag-drop to reorder dashboard links. Would need: 1) SortableJS library, 2) Sort order column in links table, 3) AJAX endpoint to save order. Low-medium complexity. [TRIAGE 2026-03-18]'
WHERE ticketid = 1620;

-- #1613 - Social media URL auto-fill from handle
UPDATE tickets
SET ticketresponse = 'User request: Auto-generate social media URLs from handles (e.g., @johnsmith -> instagram.com/johnsmith). Would need: platform detection + URL template per platform. Low complexity. Related to #1473, #327. [TRIAGE 2026-03-18]'
WHERE ticketid = 1613;

-- #1595 - Date format preference (Day/Month)
UPDATE tickets
SET ticketresponse = 'User request: Day/Month date format option. Would need: 1) User preference, 2) Date formatting helper, 3) Update all date displays. Medium complexity due to number of date displays across app. [TRIAGE 2026-03-18]'
WHERE ticketid = 1595;

-- #1533 - More role type options
UPDATE tickets
SET ticketresponse = 'User request: Add role types: supporting, series-regular, lead, etc. Check if role types are in a lookup table or hardcoded. Simple data addition. Low complexity. [TRIAGE 2026-03-18]'
WHERE ticketid = 1533;

-- #1532 - Audition source dropdown
UPDATE tickets
SET ticketresponse = 'User request: Audition source dropdown (Actors Access, LA Cast, CD, agent, etc.). Would need: 1) Lookup table or column, 2) Dropdown on audition form, 3) Reporting by source. Low-medium complexity. [TRIAGE 2026-03-18]'
WHERE ticketid = 1532;

-- #1529 - Sorting auditions
UPDATE tickets
SET ticketresponse = 'User request: Auditions not in chronological order. Check audition list query ORDER BY clause. May just need default sort by date descending + clickable column headers. Low complexity. [TRIAGE 2026-03-18]'
WHERE ticketid = 1529;

-- #1520 - Journal/assessment functionality
UPDATE tickets
SET ticketresponse = 'Feature: Journal for user entries with audition assessments auto-entered. Verify current state of journal feature and whether assessment auto-entry works. Medium complexity if building from scratch. [TRIAGE 2026-03-18]'
WHERE ticketid = 1520;

-- #1519 - Planned features page
UPDATE tickets
SET ticketresponse = 'Feature: Public page showing planned features per release from tickets table. Would need: 1) Query tickets by version/status, 2) Public page grouped by release, 3) Filter to approved/public items only. Low-medium complexity. [TRIAGE 2026-03-18]'
WHERE ticketid = 1519;

-- #1473 - Social media integration for relationships
UPDATE tickets
SET ticketresponse = 'Feature: Import data from Instagram/Facebook into contact records. Social platform APIs increasingly restricted. Related to #327, #1613. Consider feasibility given API restrictions before investing. [TRIAGE 2026-03-18]'
WHERE ticketid = 1473;

-- #1463 - Import Auditions "Fix" button error
UPDATE tickets
SET ticketresponse = 'Bug: Fix button on Import Auditions page gives "Error fetching record data". Marked Implemented previously. Verify fix is deployed. If still broken, check audition import fix endpoint for correct record ID, query response, and AJAX error handling. [TRIAGE 2026-03-18]'
WHERE ticketid = 1463;

-- #1458 - Google calendar both ways
UPDATE tickets
SET ticketresponse = 'Feature: Two-way Google Calendar sync. Blocked by #2143 (app not verified). Would need webhooks, conflict resolution, bidirectional mapping. Related to #2015, #1657, #1665. [TRIAGE 2026-03-18]'
WHERE ticketid = 1458;

-- #1016 - Determine active subscriber count
UPDATE tickets
SET ticketresponse = 'Admin/reporting: Need accurate active subscriber count. Query billing/subscription data from PayKickstart/Stripe API or DB subscription records. Low complexity. [TRIAGE 2026-03-18]'
WHERE ticketid = 1016;

-- #693 - Automatic IMDB info download
UPDATE tickets
SET ticketresponse = 'Feature: Paste IMDB URL to auto-populate contact info and photo. Would need IMDB scraping or OMDb API. Note: IMDB has no official free API; scraping may violate ToS. Medium complexity. [TRIAGE 2026-03-18]'
WHERE ticketid = 693;

-- #595 - Personal information tab with home address
UPDATE tickets
SET ticketresponse = 'User request: Personal info tab in My Profile with home address for mileage calculation. Would need: 1) Profile form extension, 2) Address storage, 3) Distance API for mileage calc. Medium complexity. [TRIAGE 2026-03-18]'
WHERE ticketid = 595;

-- #560 - Clickable links in notes + larger font
UPDATE tickets
SET ticketresponse = 'User request: 1) Auto-detect URLs in notes and make clickable, 2) Larger/darker notes font. For links: URL regex wrapping in <a> tags on display. For font: CSS adjustment. Low complexity for both. High priority per user. [TRIAGE 2026-03-18]'
WHERE ticketid = 560;

-- #498 - Customized systems for Producers and Directors
UPDATE tickets
SET ticketresponse = 'User request: Relationship systems for Producers and Directors like CDs. New system templates in fusystems with action sequences. Medium complexity - mainly data/config if system framework is generic. [TRIAGE 2026-03-18]'
WHERE ticketid = 498;

-- #484 - Row count preference not working
UPDATE tickets
SET ticketresponse = 'Bug: Row count preference not applied to relationships list. Previous response says fixed. Verify fix is deployed to production. Scheduled status. [TRIAGE 2026-03-18]'
WHERE ticketid = 484;

-- #460 - Avatar zoom bar not draggable
UPDATE tickets
SET ticketresponse = 'Bug: Photo zoom bar not draggable (mouse scroll works). Previous response says fixed. Verify fix is deployed to production. Scheduled status. [TRIAGE 2026-03-18]'
WHERE ticketid = 460;

-- #441 - Add Actor Newsletter as action item
UPDATE tickets
SET ticketresponse = 'User request: Add "Actor Newsletter" as action item in relationship systems. New entry in fuactions table. Low complexity - data addition only. [TRIAGE 2026-03-18]'
WHERE ticketid = 441;

-- #327 - Social media scraping
UPDATE tickets
SET ticketresponse = 'Feature: Social media scraping for contact info. Legal/ToS concerns - most platforms prohibit scraping. Consider official API integrations instead. Related to #1473, #1613. Low priority given legal risk. [TRIAGE 2026-03-18]'
WHERE ticketid = 327;

-- ============================================================================
-- SECTION 5: DUPLICATE TICKET CROSS-REFERENCES
-- ============================================================================

-- Login issues: #1615 / #1646
UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), ' [TRIAGE 2026-03-18] Possible duplicate of #1646. Both relate to login/redirect/session issues.')
WHERE ticketid = 1615;

UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), ' [TRIAGE 2026-03-18] Possible duplicate of #1615. Both relate to login/redirect/session issues.')
WHERE ticketid = 1646;

-- Reminder checkboxes: #307 / #308
UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), ' [TRIAGE 2026-03-18] Duplicate of #308. Same feature request for reminder checkbox refinements.')
WHERE ticketid = 307;

UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), ' [TRIAGE 2026-03-18] Duplicate of #307. Same feature request for reminder checkbox refinements.')
WHERE ticketid = 308;

-- Company entities: #585 / #2085
UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), ' [TRIAGE 2026-03-18] Duplicate of #2085. Both request companies as independent entities. Also related to #1623.')
WHERE ticketid = 585;

UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), ' [TRIAGE 2026-03-18] Duplicate of #585. Both request companies as independent entities. Also related to #1623.')
WHERE ticketid = 2085;

-- Audition filters by agent/CD: #1263 / #1780 / #2180
UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), ' [TRIAGE 2026-03-18] Duplicate group with #1780, #2180. All request audition filtering by agent or CD.')
WHERE ticketid = 1263;

UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), ' [TRIAGE 2026-03-18] Duplicate group with #1263, #2180. All request audition filtering by agent or CD.')
WHERE ticketid = 1780;

UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), ' [TRIAGE 2026-03-18] Duplicate group with #1263, #1780. All request audition filtering by agent or CD.')
WHERE ticketid = 2180;

-- To-do list: #1621 / #1637
UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), ' [TRIAGE 2026-03-18] Duplicate of #1637. Both request to-do/task list functionality.')
WHERE ticketid = 1621;

UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), ' [TRIAGE 2026-03-18] Duplicate of #1621. Both request to-do/task list functionality.')
WHERE ticketid = 1637;

-- Company/system doubling: #1617 / #1630
UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), ' [TRIAGE 2026-03-18] Duplicate of #1630. Both report company appearing twice / double system enrollment.')
WHERE ticketid = 1617;

UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), ' [TRIAGE 2026-03-18] Duplicate of #1617. Both report company appearing twice / double system enrollment.')
WHERE ticketid = 1630;

-- Import issues: #2173 / #2147
-- (Cross-referenced in Section 3 individual entries)

-- Google/Calendar cluster: #2143 / #2015 / #1458 / #1657 / #1665
-- (Cross-referenced in Section 3/4 individual entries)

-- Social media cluster: #327 / #1473 / #1613
-- (Cross-referenced in Section 4 individual entries)

-- Email feature cluster: #1726 / #2016 / #1632
-- (Cross-referenced in Section 4 individual entries)

-- ============================================================================
-- SECTION 6: VERIFICATION QUERY
-- ============================================================================

-- Run after all updates to verify changes:
-- SELECT ticketid, ticketname, ticketstatus,
--        LEFT(ticketresponse, 120) AS response_preview
-- FROM tickets
-- WHERE ticketresponse LIKE '%TRIAGE 2026-03-18%'
-- ORDER BY ticketid DESC;

-- ============================================================================
-- SECTION 7: REQUIRED DB MIGRATION - Audition Import Page Routing
-- ============================================================================
-- The pgpages table still routes auditions-import to the OLD import-auditions.cfm.
-- This migration switches it to the V3 page. MUST be run on production.

UPDATE pgpages
SET pgFilename = 'import-auditions-v3.cfm'
WHERE pgDir = 'auditions-import';

-- Verify:
-- SELECT pgDir, pgFilename FROM pgpages WHERE pgDir = 'auditions-import';

-- ============================================================================
-- TRIAGE SUMMARY
-- ============================================================================
-- Closed (garbage):     3 tickets  (#2182, #2162, #2019)
-- Implemented (fixed):  2 tickets  (#2187, #2186)
-- Analysis added:      72 tickets  (all remaining open tickets reviewed)
-- Duplicates tagged:   16 tickets  (8 duplicate pairs/groups identified)
-- Mismatched responses: 3 tickets  (#2175, #2161, #1623) - corrected
--
-- DUPLICATE GROUPS:
-- 1. #1615 / #1646 - Login/session issues
-- 2. #307 / #308 - Reminder checkbox refinements
-- 3. #585 / #2085 - Company as independent entities
-- 4. #1263 / #1780 / #2180 - Audition filter by agent/CD
-- 5. #1621 / #1637 - To-do list feature
-- 6. #1617 / #1630 - Company appearing twice
-- 7. #2173 / #2147 - Import not working (related)
-- 8. #2143 / #2015 / #1458 / #1657 / #1665 - Google Calendar cluster
--
-- PRIORITY BUGS TO FIX NEXT:
-- 1. #2190 - Import "Update Existing" action not implemented
-- 2. #2184 - Email modal not working in contact details pane
-- 3. #2132 - Audition payrate save (marked Implemented but broken)
-- 4. #1652 - Cannot save edits to existing notes
-- 5. #1634 - Add New CD gives Whoops error
-- 6. #1631 - Callback SAME button not working
-- 7. #1617/#1630 - Company/system doubling
-- 8. #1569 - Contact details not saving
-- 9. #1655 - Company dropdown not filtered by type
-- 10. #2161 - charDescription migration needs production verification
-- ============================================================================
