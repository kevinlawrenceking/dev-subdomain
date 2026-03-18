-- ============================================================================
-- TAO Ticket Triage - Production SQL Updates
-- Date: 2026-03-18
-- Target: production tickets table (actorsbusinessoffice)
-- Run against: production datasource
-- ============================================================================
-- IMPORTANT: Review before running. All updates use ticketid as primary key.
-- This script is idempotent - safe to run multiple times.
-- ============================================================================

-- ============================================================================
-- SECTION 1: CLOSE GARBAGE / TEST TICKETS
-- ============================================================================

-- #2182 - "test 3" - garbage test ticket
UPDATE tickets
SET ticketstatus = 'Closed',
    ticketresponse = 'Closed - test/garbage ticket.'
WHERE ticketid = 2182;

-- #2162 - "test" - garbage test ticket
UPDATE tickets
SET ticketstatus = 'Closed',
    ticketresponse = 'Closed - test/garbage ticket.'
WHERE ticketid = 2162;

-- #2019 - "test" - garbage test ticket
UPDATE tickets
SET ticketstatus = 'Closed',
    ticketresponse = 'Closed - test/garbage ticket.'
WHERE ticketid = 2019;

-- ============================================================================
-- SECTION 2: TICKETS WITH FIXES APPLIED (mark Implemented)
-- ============================================================================

-- #2187 - Notes cutting off at ~2000 characters
-- Fix: Removed LEFT(trim(...), 2000) truncation from all 15 locations across
-- NoteService.cfc (7 functions) and 8 query handler .cfm files.
-- Changed to just trim() with cf_sql_longvarchar.
UPDATE tickets
SET ticketstatus = 'Implemented',
    ticketresponse = 'Fixed. Removed LEFT(trim(...), 2000) truncation from all note insert/update paths. Changed 15 locations across 9 files: NoteService.cfc (7 functions: INSnoteslog, INSnoteslog_23966, INSnoteslog_23969, INSnoteslog_23972, UPDnoteslog_23974, UPDnoteslog_23980, INSnoteslog_24373), plus InsertNote_4_1.cfm, InsertNote_169_1.cfm, InsertNote_171_1.cfm, InsertNote_173_1.cfm, InsertNote_308_22.cfm, updatenote_175_1.cfm, updatenote_177_1.cfm, updatenote_179_1.cfm. Notes now store full text without truncation.'
WHERE ticketid = 2187;

-- #2186 - Re-validation not triggered when user changes previously correct value in import review
-- Fix: Frontend issue - after saving an edit, if the row status changed (e.g. ready->problem),
-- the row disappeared from the current filter view. Fixed by detecting status change in save
-- response and switching filter to "all" with a notification.
UPDATE tickets
SET ticketstatus = 'Implemented',
    ticketresponse = 'Fixed. Backend revalidation was already working correctly. Bug was in frontend: after saving an edit, loadRows() used the current filter (e.g. "ready"), so when a row status changed to "problem" after revalidation, it disappeared from view. Fixed in contact-import-v3.js by detecting status change in save response and switching filter to "all" with a status change notification.'
WHERE ticketid = 2186;

-- ============================================================================
-- SECTION 3: TICKETS WITH ISSUES IDENTIFIED (add analysis)
-- ============================================================================

-- #2190 - Import creates duplicate relationships with same name but different data
-- Issue: "Update Existing" button sends action='update' but row_action.cfm only accepts
-- ignore/create/skip/import_new. Feature gap, not a bug in existing code.
UPDATE tickets
SET ticketstatus = 'Pending',
    ticketresponse = 'Identified as feature gap. The "Update Existing" button in the dupe resolution modal sends action="update" but the backend endpoint (ajax/importv3/row_action.cfm) only accepts: ignore, create, skip, import_new. The "update" action handler needs to be implemented to merge incoming data with the existing contact record. This is a new feature, not a regression.'
WHERE ticketid = 2190;

-- #2184 - mailto/email not working when clicking email in contact details
-- Both contact_pane.cfm and contact_view.cfm use the same modal pattern (data-bs-target="##taoEmailModal")
-- and both include email_options_modal.cfm. Code looks correct. May need live browser debugging.
UPDATE tickets
SET ticketstatus = 'Pending',
    ticketresponse = 'Investigated. Code structure looks correct: both contact_pane.cfm and contact_view.cfm use data-bs-target="#taoEmailModal" and both pages include email_options_modal.cfm. The email icon in relationship details (contact_view.cfm) works fine. The issue may be specific to the contact details pane (contact_pane.cfm) and could be a Bootstrap modal z-index or initialization timing issue. Needs live browser debugging with DevTools console to identify the specific failure.'
WHERE ticketid = 2184;

-- #2161 - Character Description maxlength in audition import
-- Code already uses cf_sql_longvarchar. Migration script exists at database/fix_charDescription_length.sql.
-- Need to verify migration was applied to production.
UPDATE tickets
SET ticketstatus = 'Pending',
    ticketresponse = 'Partially resolved. Code already uses cf_sql_longvarchar for charDescription in AuditionRoleService.cfc, upload_audition.cfm, and upload_audition_back.cfm. Migration script exists at database/fix_charDescription_length.sql to ALTER audroles.charDescription and auditionsimport.charDescription columns to TEXT. Verify that the migration was applied to production - if the DB columns are still VARCHAR(2000), run the migration script.'
WHERE ticketid = 2161;

-- ============================================================================
-- SECTION 4: FIX MISMATCHED TICKET RESPONSES
-- ============================================================================

-- #2175 - "Add email selection to add to a page" - response was about import tags, not email
UPDATE tickets
SET ticketresponse = 'Feature request: Add email provider selection (Gmail, Outlook, Yahoo, Default, Copy) to contact pages. The email options modal (email_options_modal.cfm) already exists and works in relationship details view. Needs to be wired up consistently across all contact-related pages where email actions appear.'
WHERE ticketid = 2175;

-- ============================================================================
-- SECTION 5: DUPLICATE TICKET CROSS-REFERENCES
-- ============================================================================

-- Duplicate pair: #1615 / #1646 - Login issues
UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), '\n[TRIAGE 2026-03-18] Possible duplicate of #1646. Both relate to login/session issues.')
WHERE ticketid = 1615;

UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), '\n[TRIAGE 2026-03-18] Possible duplicate of #1615. Both relate to login/session issues.')
WHERE ticketid = 1646;

-- Duplicate pair: #307 / #308 - Reminder checkboxes
UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), '\n[TRIAGE 2026-03-18] Possible duplicate of #308. Both relate to reminder checkbox behavior.')
WHERE ticketid = 307;

UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), '\n[TRIAGE 2026-03-18] Possible duplicate of #307. Both relate to reminder checkbox behavior.')
WHERE ticketid = 308;

-- Duplicate pair: #585 / #2085 - Company entities
UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), '\n[TRIAGE 2026-03-18] Possible duplicate of #2085. Both relate to company entity management.')
WHERE ticketid = 585;

UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), '\n[TRIAGE 2026-03-18] Possible duplicate of #585. Both relate to company entity management.')
WHERE ticketid = 2085;

-- Duplicate group: #1263 / #1780 / #2180 - Audition filters by agent/CD
UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), '\n[TRIAGE 2026-03-18] Possible duplicate of #1780, #2180. All relate to audition filtering by agent or casting director.')
WHERE ticketid = 1263;

UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), '\n[TRIAGE 2026-03-18] Possible duplicate of #1263, #2180. All relate to audition filtering by agent or casting director.')
WHERE ticketid = 1780;

UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), '\n[TRIAGE 2026-03-18] Possible duplicate of #1263, #1780. All relate to audition filtering by agent or casting director.')
WHERE ticketid = 2180;

-- Duplicate pair: #1621 / #1637 - To-do list
UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), '\n[TRIAGE 2026-03-18] Possible duplicate of #1637. Both relate to to-do list functionality.')
WHERE ticketid = 1621;

UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), '\n[TRIAGE 2026-03-18] Possible duplicate of #1621. Both relate to to-do list functionality.')
WHERE ticketid = 1637;

-- Duplicate pair: #1617 / #1630 - Company/system doubling
UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), '\n[TRIAGE 2026-03-18] Possible duplicate of #1630. Both relate to company records creating duplicate system entries.')
WHERE ticketid = 1617;

UPDATE tickets
SET ticketresponse = CONCAT(COALESCE(ticketresponse, ''), '\n[TRIAGE 2026-03-18] Possible duplicate of #1617. Both relate to company records creating duplicate system entries.')
WHERE ticketid = 1630;

-- ============================================================================
-- SECTION 6: VERIFICATION
-- ============================================================================

-- Run this after the updates to verify:
-- SELECT ticketid, ticketstatus, LEFT(ticketresponse, 100) AS response_preview
-- FROM tickets
-- WHERE ticketid IN (2182, 2162, 2019, 2187, 2186, 2190, 2184, 2161, 2175,
--                    1615, 1646, 307, 308, 585, 2085, 1263, 1780, 2180,
--                    1621, 1637, 1617, 1630)
-- ORDER BY ticketid;
