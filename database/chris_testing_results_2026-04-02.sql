-- ============================================================================
-- chris_testing_results_2026-04-02.sql
-- Chris Ansoff testing results from 2026-04-02
-- Appends tester comments to ticketResponse, updates status.
-- Run against actorsbusinessoffice (production / abo datasource) ONLY.
--
-- SAFE: All ticketResponse updates use CONCAT(COALESCE(...), ...) to APPEND.
-- Existing data is never overwritten.
-- ============================================================================

-- ============================================================
-- TESTED - SUCCESS (Chris signed off)
-- ============================================================

-- #2184 - mailto icon in contact pane
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] Testing success'
    ),
    ticketStatus = 'Tested - Success'
WHERE ticketid = 2184;

-- #2140 - UAT distinct title bar color
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] Testing success'
    ),
    ticketStatus = 'Tested - Success'
WHERE ticketid = 2140;

-- #1655 - Company type dropdowns filter correctly
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] This was in a future release but testing success'
    ),
    ticketStatus = 'Tested - Success'
WHERE ticketid = 1655;

-- #1617 - Companies/relationships duplicated when adding auditions
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] Testing success'
    ),
    ticketStatus = 'Tested - Success'
WHERE ticketid = 1617;

-- #1630 - Companies/relationships duplicated when adding auditions (related)
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] Testing success'
    ),
    ticketStatus = 'Tested - Success'
WHERE ticketid = 1630;

-- #1634 - Adding a new CD no longer causes an error
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] Testing success'
    ),
    ticketStatus = 'Tested - Success'
WHERE ticketid = 1634;

-- #1653 - Social profile links no longer show up twice
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] Testing success'
    ),
    ticketStatus = 'Tested - Success'
WHERE ticketid = 1653;

-- #1633 - Self-tape duration field only appears when Self Tape selected
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] Testing success'
    ),
    ticketStatus = 'Tested - Success'
WHERE ticketid = 1633;

-- #1652 - Notes edits save properly
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] Testing success'
    ),
    ticketStatus = 'Tested - Success'
WHERE ticketid = 1652;

-- #1631 - SAME button on callbacks works again
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] This was in a future release but testing success'
    ),
    ticketStatus = 'Tested - Success'
WHERE ticketid = 1631;

-- #1656 - Pasting text into notes no longer causes white-on-white text
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] Testing success'
    ),
    ticketStatus = 'Tested - Success'
WHERE ticketid = 1656;

-- #2173 - Import Relationships form / download template
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] This was a time when one was not able download the import template - fixed.'
    ),
    ticketStatus = 'Tested - Success'
WHERE ticketid = 2173;

-- #2190 - Update button for resolving duplicates during import
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] GPT misunderstood this ticket - it was a bug with import but is working now'
    ),
    ticketStatus = 'Tested - Success'
WHERE ticketid = 2190;

-- #1569 - Saving contact details failing
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] Don''t think this is an issue anymore'
    ),
    ticketStatus = 'Tested - Success'
WHERE ticketid = 1569;

-- ============================================================
-- TESTED - BUG (Chris found issues or could not verify)
-- ============================================================

-- #1615 - Login errors causing blank Whoops screens
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] Well these fall under all the login issues that have happened. Closed them but not sure if the login issues are fixed.'
    ),
    ticketStatus = 'Tested - Bug'
WHERE ticketid = 1615;

-- #1646 - Login errors redirecting to wrong page
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] Well these fall under all the login issues that have happened. Closed them but not sure if the login issues are fixed.'
    ),
    ticketStatus = 'Tested - Bug'
WHERE ticketid = 1646;

-- #2191 - Relationships not showing on Targeted list
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] Well the first issue is fixed but if one changes a relationship system from Targeted to Follow-up, the relationship does not show up when Follow-up list is selected on Relationships: All.'
    ),
    ticketStatus = 'Tested - Bug'
WHERE ticketid = 2191;

-- #2192 - Reminders not being removed when marked complete
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] This worked yesterday but today does not work.'
    ),
    ticketStatus = 'Tested - Bug'
WHERE ticketid = 2192;

-- #2161 - Character description length on audition import
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] Long texts still getting cut off - GPT said partially resolved'
    ),
    ticketStatus = 'Tested - Bug'
WHERE ticketid = 2161;

-- #1675 - Photo uploads squished on Safari
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] Need someone with macbook to test this using Safari'
    ),
    ticketStatus = 'Tested - Bug'
WHERE ticketid = 1675;

-- #1614 - Blank screen on iPhone 14 Pro Max
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] This does not feel critical - moved to later release'
    ),
    ticketStatus = 'Tested - Bug'
WHERE ticketid = 1614;

-- ============================================================
-- FEATURE REQUESTS - Append comment only, no status change
-- ============================================================

-- #1623 - Auto-populating company info when adding relationships
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] Already in a future release'
    )
WHERE ticketid = 1623;

-- #1725 - Ability to merge duplicate relationships
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] Already in a future release'
    )
WHERE ticketid = 1725;

-- #1839 - Mailing label generation from addresses
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] Already in a future release'
    )
WHERE ticketid = 1839;

-- #1780 - Filtering auditions by agent or team
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] Already in a future release'
    )
WHERE ticketid = 1780;

-- #1636 - International phone number formatting
UPDATE tickets
SET ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n\n[TESTED 2026-04-02 Chris Ansoff] Already in a future release'
    )
WHERE ticketid = 1636;
