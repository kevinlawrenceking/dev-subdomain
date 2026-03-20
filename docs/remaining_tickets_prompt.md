# TAO Remaining Tickets - Fix Prompt

Paste everything below into a new Claude Code conversation:

---

ULTRATHINK THROUGH EACH TICKET STEP BY STEP.

You are working on TAO, a ColdFusion + MySQL web app. Read CLAUDE.md first for full project context and coding standards.

## Previously Completed (DO NOT re-fix)

These tickets were resolved on 2026-03-20. Do NOT touch these files unless a remaining ticket requires it:
- Ad-hoc: Email Forbidden on admin-users-detail (CSRF fix in app/Application.cfc)
- #2192: Reminders not completing (LEFT JOIN fix in services/NotificationService.cfc)
- #2191: Targeted list empty (database/rebuild_contacts_ss_system_views.sql - needs execution)
- #2184: Mailto not working (email modal include added to include/contact_pane.cfm)
- #2140: UAT title bar color (include/fetchPageService.cfm UAT color changed to #8b0000)
- #2161: Char description length (database/fix_charDescription_length.sql - needs execution)

## Your Task

For each remaining ticket below:
1. Investigate the root cause by reading the actual code (do NOT guess)
2. If fixable: implement the fix, mark status as "Implemented", append to the ticketResponse column (do NOT delete existing response text), and add a testingscript
3. If NOT fixable (feature request, external dependency, needs live debugging): append a detailed developer note to ticketResponse explaining why and what would be needed
4. Track progress with TodoWrite

After ALL tickets are processed:
1. Update `docs/ticket_resolution_2026-03-20.md` - append new resolved tickets and update the "Still Being Resolved" table
2. Update `docs/email_chris_ansoff_2026-03-20.md` - move newly resolved tickets into the Resolved section, update counts in subject line
3. Update `database/update_ticket_responses_2192_2191_email.sql` - append new UPDATE statements for each ticket you processed (use CONCAT to append, never overwrite ticketResponse)

## Ticket Processing Priority

### TIER 1 - Bugs to fix (investigate and implement)

```
"ticketID": "1655"
"ticketName": "Adding company to Relationship - Company Name dropdown not affected by selection of Type"
"ticketDetails": "When you add a company to a relationship, the first box asks for the company type. Selecting that does not affect the company dropdown list. So if Casting Office is selected, the dropdown list for Company Name should have only company names that are of type Casting Office."
"ticketResponse": "Bug: When adding a company to a relationship, selecting a company type (e.g. Casting Office) should filter the company name dropdown to only show companies of that type. Currently shows all companies regardless. Need AJAX call or JS filter on type dropdown change event. [TRIAGE 2026-03-18]"
"ticketPriority": "Medium"
```

```
"ticketID": "1653"
"ticketName": "Link Duplication"
"ticketDetails": "IMDB Link added once, but logo displaying as IMDB and a Link separately (both link to IMDB when clicked)"
"ticketResponse": "Bug: IMDB link added once displays as both an IMDB logo icon AND a separate generic 'Link' entry. Link rendering code matches IMDB URLs to show the logo but also renders the same URL in the generic links list. Need to deduplicate - if a link matches a known service (IMDB), show only the branded icon, not both. [TRIAGE 2026-03-18]"
"ticketPriority": "Medium"
```

```
"ticketID": "1652"
"ticketName": "Notes Edit"
"ticketDetails": "When you try to edit an existing note you can't save changes. when you hit the X to get out of the changed box it reverts to previously saved note."
"ticketResponse": "Bug: Edits to existing notes revert on close/save. Separate from #2187 (note truncation). The update queries (updatenote_175/177/179) look correct. May be a frontend binding issue - check if the edit modal properly captures edited text and sends the correct noteid. Needs live debugging. [TRIAGE 2026-03-18]"
"ticketPriority": "Medium"
```

```
"ticketID": "1634"
"ticketName": "Add New CD"
"ticketDetails": "When creating an audition, when i click relationships and go to add a new Casting Director that doesn't have a profile already created, I click add and then it gives me a Whoops Error."
"ticketResponse": "Bug: Adding a new Casting Director during audition creation throws a Whoops error. Check the CD creation endpoint for: 1) missing required fields, 2) duplicate name handling, 3) transaction integrity when creating CD + linking to audition. Check error logs for specific exception. [TRIAGE 2026-03-18]"
"ticketPriority": "Medium"
```

```
"ticketID": "1633"
"ticketName": "Self Tape Duration"
"ticketDetails": "When Putting an audition in and selecting self tape - it still makes you select a duration of the audition as if it was in person. Should be greyed out. 04-30-24 maybe make the default 15 minutes? Also, get rid of the 'Unknown' option in the duration droplist."
"ticketResponse": "UX bug: Self-tape auditions should not require duration/time selection since done at home. The 'Unknown' duration option should be removed or duration field hidden/optional when audition type is 'Self Tape'. Check audition form for conditional field visibility based on audition type. [TRIAGE 2026-03-18]"
"ticketPriority": "Medium"
```

```
"ticketID": "1631"
"ticketName": "Callback Selection of address button not working."
"ticketDetails": "When you get a callback and select in person, it should default to the company address, but it makes you manually add it in. UPDATE 12/1/23 - Look to see if we can provide an option for the user to have the system fill in the company information if they so wish. UPDATE 10/27/25 Clicking on the SAME does nothing. There was an address in the audition part."
"ticketResponse": "Bug: SAME button to copy audition location to callback does nothing when clicked. Button appears correctly when original audition is in-person with location filled. JS click handler likely not bound or target field selector is wrong. Check callback form JS for the SAME button click event. [TRIAGE 2026-03-18]"
"ticketPriority": "Medium"
```

```
"ticketID": "1675"
"ticketName": "Photo Upload Issue"
"ticketDetails": "Each time I've I upload a headshot it previews squished. (one inch wide by a gazillion inches deep). The image I sourced form is 8z10 at 300 ppi. Jpg. I'm working on a macbook pro, Safari browser."
"ticketResponse": "Browser-specific rendering bug. Uploaded headshot previews appear squished (1 inch wide x very tall) on Safari/Mac. Likely caused by EXIF orientation metadata not being handled, or CSS aspect-ratio / object-fit not applied to the preview image. Check the avatar upload preview code for Safari-specific image rendering. [TRIAGE 2026-03-18]"
"ticketPriority": "Medium"
```

```
"ticketID": "1656"
"ticketName": "Font Color"
"ticketDetails": "I just copy pasted a BIO from a website into the notes section. On the website the font was WHITE on a black background and when I put it into the notes it was all white and invisible. There is no way to change to black. I tried to save but the note remains invisible. I Can only change font type not colour."
"ticketResponse": "UX issue with rich text paste. When users paste text with inline color styles, text can become invisible on white backgrounds. Fix options: 1) Strip inline color styles on paste, 2) Add a 'paste as plain text' option, 3) Add font color picker to notes editor. Common rich-text editor issue. [TRIAGE 2026-03-18]"
"ticketPriority": "Medium"
```

```
"ticketID": "1617"
"ticketName": "Company Appearing Twice"
"ticketDetails": "If I have a casting director that I'm adding and the company already exists (ie. i already have another CD added from that company), and I add the tag of 'Casting director' The company adds twice."
"ticketResponse": "[TRIAGE 2026-03-18] Duplicate of #1630. Both report company appearing twice / double system enrollment."
"ticketPriority": "Medium"
```

```
"ticketID": "1630"
"ticketName": "Relationship System Doubled"
"ticketDetails": "When adding an audition, to a Casting director without a relationship system activated it says do you want to add to FOLLOW Up system. I clicked add, and then on her profile it has added the system twice meaning I had double identical reminders."
"ticketResponse": "[TRIAGE 2026-03-18] Duplicate of #1617. Both report company appearing twice / double system enrollment."
"ticketPriority": "Medium"
```

```
"ticketID": "1615"
"ticketName": "Login Issue"
"ticketDetails": "Found a new bug. I've bookmarked TAO as my homepage. It often logs me out and asks me to log in. Once I login it takes me to a Whoops server error. The website is directing me a /setup/ page. I then delete that and it takes me to my dashboard."
"ticketResponse": "[TRIAGE 2026-03-18] Possible duplicate of #1646. Both relate to login/redirect/session issues."
"ticketPriority": "Medium"
```

```
"ticketID": "1646"
"ticketName": "Login Issue"
"ticketDetails": "Every time i go to login, it takes me to the website/Setup and gives me an error. I then need to backspace this wrong direction to take me to the dashboard."
"ticketResponse": "[TRIAGE 2026-03-18] Possible duplicate of #1615. Both relate to login/session issues."
"ticketPriority": "Medium"
```

```
"ticketID": "1569"
"ticketName": "Problem Saving"
"ticketDetails": "I was in the middle of updating a new contact person and then noticed that a lot of the details I put, such as the picture, and tags didn't get saved. Not sure if there was supposed to be a save button? This hasn't happened to me before."
"ticketResponse": "Bug: Contact details including picture and tags not saving. Verify: 1) Save endpoint is being called, 2) Request includes correct contactid, 3) Server-side handler processes all fields. Could be form serialization or CSRF token issue. [TRIAGE 2026-03-18]"
"ticketPriority": "Medium"
```

```
"ticketID": "2190"
"ticketName": "import relationships - resolve duplicates button does not work"
"ticketDetails": "Resolve duplicate button when import review does not work. Nothing happens when clicked"
"ticketResponse": "Identified as feature gap. The 'Update Existing' button in the dupe resolution modal sends action='update' but the backend endpoint (ajax/importv3/row_action.cfm) only accepts: ignore, create, skip, import_new. The 'update' action handler needs to be implemented to merge incoming data with the existing contact record. Not a regression - this action was never built. [TRIAGE 2026-03-18]"
"ticketPriority": "Medium"
```

```
"ticketID": "2173"
"ticketName": "Import Relationships Form not Working"
"ticketDetails": "Cannot open the relationships form"
"ticketResponse": "Import V3 system has been extensively debugged and verified working as of March 2026. CSV upload, field mapping, validation, review grid, and finalize all functional. If this issue persists, check: 1) file format (CSV/XLS/XLSX supported), 2) browser console for JS errors, 3) session expiration during upload. May be duplicate of #2147. [TRIAGE 2026-03-18]"
"ticketPriority": "Medium"
```

```
"ticketID": "1614"
"ticketName": "Integration Issue"
"ticketDetails": "TAO doesn't work at all on iPhone 14 pro max. Webpage isn't loading any data - blank screen"
"ticketResponse": "Mobile rendering bug. TAO shows blank screen on iPhone 14 Pro Max. Could be: 1) viewport meta tag issue, 2) CSS incompatibility with newer iOS Safari, 3) JS error blocking render. Need to test on iOS Safari dev tools or BrowserStack. [TRIAGE 2026-03-18]"
"ticketPriority": "Medium"
```

### TIER 2 - Feature requests (scope and document, do NOT implement)

For these, append a detailed developer note explaining what implementation would require. Do NOT build the feature.

```
"ticketID": "1623"
"ticketName": "Company information auto-populated when company added to relationship"
"ticketDetails": "When a user adds a company to a relationship, if that company is already in the system, all information (phone, address, social media tags) are to be added to the relationship record automatically."
"ticketResponse": "Feature request: When adding an existing company to a relationship, company phone, address, and social media should auto-populate from the company record. Need AJAX lookup on company selection to prefill fields. Related to #585/#2085 (company entities). High priority. [TRIAGE 2026-03-18]"
"ticketPriority": "High"
```

```
"ticketID": "1725"
"ticketName": "Be able to merge duplicates relationships"
"ticketDetails": "be able to merge duplicates relationship. Need to look at merging duplicate companies as well 8/2/24"
"ticketResponse": "Feature request: Merge duplicate contact/relationship records. Would need: 1) Duplicate detection, 2) Side-by-side merge UI, 3) Field-by-field selection, 4) Cascading update of linked records (notes, events, systems). Medium-high complexity. Related to #2190 (import dupes). [TRIAGE 2026-03-18]\n[TRIAGE 2026-03-20] Feature request confirmed. Requires: 1) Duplicate detection algorithm (name/email/phone fuzzy matching), 2) Side-by-side merge UI with field-by-field selection, 3) Cascading update of all linked records (notes, events, fusystemusers, funotifications, tags_user, contactitems, audcontacts_auditions_xref, eventcontactsxref). Medium-high complexity. Related to #2190 (import duplicate resolution). Not implemented in this cycle."
"ticketPriority": "Medium"
```

```
"ticketID": "1839"
"ticketName": "Request via Email - Mailing Labels"
"ticketDetails": "Is there a way to print mailing labels from Actors Office for all the addresses I've entered in to my Relationship contacts?"
"ticketResponse": "User request: Print mailing labels from TAO addresses. Would need: 1) Label format selection (Avery templates), 2) Contact/address selection UI, 3) PDF generation. Consider if CSV export + Word mail merge is sufficient alternative. Medium complexity. [TRIAGE 2026-03-18]"
"ticketPriority": "Medium"
```

```
"ticketID": "1780"
"ticketName": "Reports/Filters - filter auditions for each agent/team"
"ticketDetails": "It would be really helpful to be able to Filter auditions for each agent/team member. This way we can go back and see more detailed aspects of what types of auditions, which casting directors, etc. we are getting with each agent. update: New bar 'All sources': search by source or team member"
"ticketResponse": "[TRIAGE 2026-03-18] Duplicate group with #1263, #2180. All request audition filtering by agent or CD."
"ticketPriority": "Medium"
```

```
"ticketID": "1636"
"ticketName": "Research how phone number formatting can be done to allow for different country formats"
"ticketDetails": "The Australian phone number format is xxxx-xxx-xxx and the american is xxx-xxx-xxxx. Need to figure out a way that the system will format the phone number with some input from user as to the country it is from"
"ticketResponse": "Feature: International phone format support (AU, US, etc.). Options: 1) libphonenumber library, 2) Store raw digits + format on display by country, 3) Country code field on phone entries. Medium complexity. [TRIAGE 2026-03-18]"
"ticketPriority": "Medium"
```

### TIER 3 - External / blocked (document only)

```
"ticketID": "2143"
"ticketName": "Google still has not verified the app"
"ticketDetails": "Google still has not verified the app, can not connect calendars"
"ticketResponse": "External dependency - Google OAuth app verification. Not a code bug. Requires submitting the app for Google verification review. Until verified, users see 'unverified app' warning when connecting Google Calendar. Related to #2015, #1458, #1657, #1665. [TRIAGE 2026-03-18]"
"ticketPriority": "Medium"
```

```
"ticketID": "2015"
"ticketName": "Verify that google integration is fully working"
"ticketDetails": "Need to make sure that google integration one way sync is working without needing special fixes. Look at two way sync as well"
"ticketResponse": "Two-way Google Calendar sync. Blocked by #2143 (app not verified). Would need: 1) Google push notifications/webhooks, 2) Conflict resolution, 3) Bidirectional event mapping. Related to #1458, #1657, #1665. [TRIAGE 2026-03-18]"
"ticketPriority": "Medium"
```

```
"ticketID": "1657"
"ticketName": "Calendar Problem"
"ticketDetails": "It seems that my calendar is still not syncing with the calendar on devices. Nothing after October is showing up."
"ticketResponse": "Bug: Calendar not syncing, events after October not showing. Likely related to Google integration (#2143). Also check: 1) Date range query in calendar feed endpoint, 2) Event data integrity in DB. Related to #2015, #1458. [TRIAGE 2026-03-18]"
"ticketPriority": "Medium"
```

## Output Requirements

For each ticket you fix, provide:
1. Root cause (traced through actual code, not guessed)
2. Exact files changed with line numbers
3. Complete code blocks (not fragments)
4. Testing script (UI steps + SQL verification queries)
5. Rollback instructions for any DB changes

For the SQL updates file, use this pattern (APPEND to existing, never overwrite):
```sql
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n[IMPLEMENTED 2026-03-20] ...'
),
    ticketStatus = 'Implemented',
    testingscript = '...'
WHERE ticketid = XXXX;
```

For feature requests and blocked tickets, use `[TRIAGE 2026-03-20]` prefix instead of `[IMPLEMENTED]` and do NOT change ticketStatus.

Merge duplicate tickets (#1617/#1630, #1615/#1646) - investigate once, apply the fix, and update both ticket responses referencing each other.

Today's date is 2026-03-20. Begin with Tier 1 bugs, working top to bottom. Use parallel agents for investigation where tickets are independent.
