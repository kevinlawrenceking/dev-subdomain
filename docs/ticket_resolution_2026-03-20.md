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

## Tickets Still Being Resolved

| Ticket ID | Name | Status |
|-----------|------|--------|
| 2190 | Import relationships - resolve duplicates button does not work | Backend `update` action handler needs implementation |
| 2173 | Import Relationships Form not Working | Needs verification if still occurring |
| 2143 | Google app verification | External dependency - Google OAuth review |
| 2015 | Google integration verification | Blocked by #2143 |
| 1839 | Mailing labels from addresses | Feature request |
| 1780 | Filter auditions by agent/team | Feature request |
| 1725 | Merge duplicate relationships | Feature request - medium-high complexity |
| 1675 | Photo upload squished on Safari | EXIF/CSS issue |
| 1657 | Calendar not syncing | Related to Google integration #2143 |
| 1656 | Font color in notes (white text) | Rich text paste issue |
| 1655 | Company type not filtering dropdown | AJAX filter needed on type change |
| 1653 | Link duplication (IMDB) | Dedup rendering logic |
| 1652 | Notes edits not saving | Frontend binding issue |
| 1646 | Login redirects to /setup/ | Duplicate of #1615 |
| 1636 | International phone formatting | Feature request |
| 1634 | Add new CD throws Whoops error | CD creation endpoint issue |
| 1633 | Self-tape duration required | Conditional field visibility |
| 1631 | Callback SAME button not working | JS click handler issue |
| 1630 | Relationship system doubled | Duplicate of #1617 |
| 1623 | Company info auto-populate | Feature request - high priority |
| 1617 | Company appearing twice | Duplicate enrollment issue |
| 1615 | Login Whoops error | Session/redirect issue |
| 1614 | Blank screen on iPhone | Mobile rendering bug |
| 1569 | Contact details not saving | Form serialization issue |
