# Email to Chris Ansoff - Ticket Resolution Update

**To:** Chris Ansoff
**From:** Development Team
**Date:** March 20, 2026
**Subject:** TAO Ticket Resolution Update - 6 Bugs Fixed

---

Hi Chris,

Here is a summary of the tickets we resolved today:

## Tickets Resolved

- **#1 (Ad-hoc) - Admin Email "Send failed: Forbidden"** - Fixed CSRF token validation in Application.cfc. The CSRF engine was rejecting valid AJAX POST requests from the admin user detail page. Now uses direct session token comparison as primary check and returns proper JSON errors for AJAX callers. Both Welcome Email and Password Reset buttons should now work.

- **#2191 - Relationships not showing on Targeted list** - Fixed database view filter mismatch. The `contacts_ss_target`, `contacts_ss_followup`, and `contacts_ss_maint` views were filtering on legacy systemtype values that no longer match the fusystems table. Migration SQL ready at `database/rebuild_contacts_ss_system_views.sql` -- needs to be run against both dev and production databases.

- **#2192 - Reminders not being removed on completion** - Fixed a query join issue in NotificationService.cfc. The `GetNotificationByID` and `getNotifications` functions used INNER JOIN on the `actionusers` table, which caused queries to return zero rows when a notification's action had no per-user override. Changed to LEFT JOIN with COALESCE defaults so completions work reliably.

- **#2184 - Mailto icon not working in contact pane** - Fixed missing modal include. The email trigger in `contact_pane.cfm` referenced `#taoEmailModal` but the modal HTML was never rendered in that context. Added the `email_options_modal.cfm` include (with duplicate-render guard) to `contact_pane.cfm`.

- **#2140 - UAT title bar same color as production** - Fixed environment color mapping. In `fetchPageService.cfm`, UAT was mapped to the production blue color (`#406E8E`). Changed to dark red (`#8b0000`) to visually distinguish UAT from production.

- **#2161 - Character description length in audition import** - Confirmed code is correct (uses `CF_SQL_LONGVARCHAR` everywhere). The issue is the database column is still VARCHAR(100). Migration script exists at `database/fix_charDescription_length.sql` -- needs to be run against both dev and production databases to convert columns to TEXT.

## Tickets Still In Progress

The following tickets are still being worked on or triaged:

- #2190 - Import duplicates resolve button (backend action handler needed)
- #2173 - Import relationships form (needs re-verification)
- #2143 - Google app verification (external dependency - not a code bug)
- #1725 - Merge duplicate relationships (feature request)
- #1675 - Photo upload squished on Safari
- #1655 - Company type not filtering dropdown
- #1653 - Link duplication (IMDB)
- #1652 - Notes edits not saving
- #1646/#1615 - Login redirect issues
- #1634 - Add new CD throws error
- #1633 - Self-tape duration field
- #1631 - Callback SAME button
- #1630/#1617 - Company/system doubling
- #1623 - Company info auto-populate
- #1614 - Blank screen on iPhone
- #1569 - Contact details not saving

Plus several feature requests (#1839, #1780, #1636, #2015) that are lower priority or blocked by external dependencies.

## Database Migrations Required

Two SQL scripts need to be run against both `new_development` and `actorsbusinessoffice`:
1. `database/rebuild_contacts_ss_system_views.sql` (fixes #2191)
2. `database/fix_charDescription_length.sql` (fixes #2161)

Let me know if you have any questions or need clarification on any of these items.

Best,
Development Team
