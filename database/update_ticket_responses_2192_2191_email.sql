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
-- Verification
-- ============================================================
SELECT ticketid, ticketName, ticketStatus,
       LEFT(ticketResponse, 120) AS response_preview,
       LEFT(testingscript, 80) AS script_preview
FROM tickets
WHERE ticketid IN (2192, 2191, 2184, 2161, 2140, 1725);
