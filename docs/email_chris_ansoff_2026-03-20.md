# Email to Chris Ansoff - Ticket Resolution Update

**To:** Chris Ansoff
**From:** Development Team
**Date:** March 20, 2026
**Subject:** TAO Ticket Resolution Update - 16 Bugs Fixed, 9 Documented

---

Hi Chris,

Here is a summary of the tickets we resolved and documented today:

## Tickets Resolved (16 total)

### Previously Resolved (6)

- **#1 (Ad-hoc) - Admin Email "Send failed: Forbidden"** - Fixed CSRF token validation in Application.cfc. The CSRF engine was rejecting valid AJAX POST requests from the admin user detail page. Now uses direct session token comparison as primary check and returns proper JSON errors for AJAX callers.

- **#2191 - Relationships not showing on Targeted list** - Fixed database view filter mismatch. The `contacts_ss_target`, `contacts_ss_followup`, and `contacts_ss_maint` views were filtering on legacy systemtype values. Migration SQL at `database/rebuild_contacts_ss_system_views.sql`.

- **#2192 - Reminders not being removed on completion** - Fixed query join issue in NotificationService.cfc. Changed `actionusers` from INNER JOIN to LEFT JOIN with COALESCE defaults.

- **#2184 - Mailto icon not working in contact pane** - Fixed missing modal include. Added `email_options_modal.cfm` include to `contact_pane.cfm`.

- **#2140 - UAT title bar same color as production** - Fixed environment color mapping in `fetchPageService.cfm`. UAT changed from blue to dark red.

- **#2161 - Character description length in audition import** - Database column constraint issue. Migration script at `database/fix_charDescription_length.sql`.

### Newly Resolved Today (10)

- **#1615 / #1646 - Login Whoops error / Login redirects to /setup/** - Fixed session scope mismatch between `setup/Application.cfc` and the main app. Setup was using a separate session name, causing Whoops errors when users hit setup URLs. Also fixed `samesite` cookie attribute and removed incorrect 403 block for UUID-based setup access.

- **#1655 - Company type not filtering dropdown** - Added type-aware filtering to the company dropdown. When adding/editing a company contact item, the company dropdown now filters by the selected type (Agent, Manager, etc.). Changed the query to include `GROUP_CONCAT` of types and added JS filtering.

- **#1617 / #1630 - Company appearing twice / Relationship system doubled** - Fixed dual company insertion in audition add flow (changed two independent `<cfif>` blocks to `<cfif>/<cfelseif>`). Fixed hidden_div visibility default. Added notification existence guard in `add_system.cfm` and system enrollment check in `audition_check.cfm` to prevent duplicate reminders.

- **#1634 - Add new CD throws Whoops error** - Fixed undefined `dir_missing_avatar_filename` variable in `folder_setup.cfm`. Replaced with `application.defaultAvatarPath`.

- **#1653 - IMDB/Social Profile link duplication** - Fixed duplicate rendering where Social Profile items appeared both as branded icons and text links. Added check to skip text link rendering when the URL already has a branded icon.

- **#1633 - Self-tape duration required when not applicable** - Fixed conditional field visibility so the duration field only appears and is required when "Self Tape" is selected as the audition type.

- **#1652 - Notes edits not saving** - Fixed Quill editor content capture. Changed from capturing the entire `#snow-editor` container HTML (which included Quill internal divs) to capturing only `.ql-editor` content, preventing progressive corruption.

- **#1631 - Callback SAME button not working** - Fixed dynamic element ID mismatch in the "SAME" button handler and ensured `filterRegions()` is called before setting the region value.

- **#1675 - Photo upload squished on Safari** - Added `image-orientation: from-image` CSS to avatar and photo classes. Safari now correctly renders EXIF-oriented portrait images.

- **#1656 - Font color in notes (white text on paste)** - Added Quill clipboard matcher that strips `color` and `background` attributes from pasted content, preventing invisible white-on-white text.

## Tickets Documented - Needs Live Debug (3)

- **#1569 - Problem saving contact details** - Confirmed bug: `include/tagchange.cfm` handler file is missing. Tag update form submits to a non-existent endpoint. Needs handler creation.
- **#1614 - Blank screen on iPhone 14 Pro Max** - Cannot reproduce without device access. Requires Safari remote debug session. Likely JS initialization failure or CSS transform issue.
- **#2173 - Import Relationships Form not Working** - Found orphaned JavaScript in `remoteAddName.cfm` referencing non-existent DOM elements (`#companySearch`, `#nameResults`). Needs JS cleanup and live verification.

## Feature Requests Documented (6)

- **#2190** - Import resolve duplicates "Update" button (backend action handler never built)
- **#1623** - Company info auto-populate when adding relationships
- **#1725** - Merge duplicate relationships (medium-high complexity)
- **#1839** - Mailing labels from addresses
- **#1780** - Filter auditions by agent/team
- **#1636** - International phone number formatting

## Blocked / External (3)

- **#2143** - Google app verification (external Google OAuth review process)
- **#2015** - Google integration verification (blocked by #2143)
- **#1657** - Calendar not syncing (blocked by #2143/#2015)

## Database Migrations Required

Two SQL scripts need to be run against both `new_development` and `actorsbusinessoffice`:
1. `database/rebuild_contacts_ss_system_views.sql` (fixes #2191)
2. `database/fix_charDescription_length.sql` (fixes #2161)

## Summary

| Category | Count |
|----------|-------|
| Bugs fixed | 16 |
| Documented (needs live debug) | 3 |
| Feature requests documented | 6 |
| Blocked/external | 3 |
| **Total tickets processed** | **28** |

Let me know if you have any questions or need clarification on any of these items.

Best,
Development Team
