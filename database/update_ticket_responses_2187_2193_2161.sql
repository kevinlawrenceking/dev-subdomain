-- update_ticket_responses_2187_2193_2161.sql
-- Updates developer responses and status for tickets from Chris email 2026-04-15
-- Run against both new_development and actorsbusinessoffice schemas.

-- ============================================================
-- Ticket #2187: Relationship imports failing with very large notes
-- Status: Implemented
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n\n[IMPLEMENTED 2026-04-15] The import was silently truncating notes to 2,000 characters and swallowing any database errors during note insertion. Users saw "import successful" even when notes failed to save. Fix: removed the character limit on notes during import, upgraded the noteslog.noteDetails database column from VARCHAR to TEXT to support large notes, and added proper warning feedback so users are notified if a note could not be saved. Database migration V3_5 must be run on both dev and prod.'
),
    ticketStatus = 'Implemented'
WHERE ticketid = 2187;

-- ============================================================
-- Ticket #2161: Audition import function
-- Status: Implemented (previously completed)
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n\n[CONFIRMED 2026-04-15] The audition import feature is fully implemented and functional. Includes file upload (CSV/XLS/XLSX), column mapping with auto-detection, review grid with inline editing and duplicate detection, and finalization with per-row error isolation. The character description length issue was also previously resolved. Feature is accessible at /app/auditions-import/ and can be enabled via feature flags in Application.cfc.'
),
    ticketStatus = 'Implemented'
WHERE ticketid = 2161;

-- ============================================================
-- Ticket #2193: Not able to delete an audition
-- Status: Implemented
-- ============================================================
UPDATE tickets
SET ticketResponse = CONCAT(
    COALESCE(ticketResponse, ''),
    '\n\n[IMPLEMENTED 2026-04-15] The audition delete was broken due to multiple issues in the delete workflow. The event contact cleanup was being called with an empty list so it never removed anything, a required database query was missing its datasource connection, and the cleanup query had inverted logic that targeted the wrong records. All issues have been corrected. Both single-event deletion and full project deletion now work correctly.'
),
    ticketStatus = 'Implemented'
WHERE ticketid = 2193;
