-- Revert tickets #2132 and #1463 from Implemented to Pending
-- Reason: Both were marked Implemented but issues persist per triage review
-- Date: 2026-03-20

-- #2132 - Audition payrate not saving unless income type chosen
-- Triage note: "Previously marked Implemented but testing shows issue persists"
UPDATE tickets
SET ticketStatus = 'Pending',
    ticketCompletedDate = NULL,
    ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[REVERTED TO PENDING 2026-03-20] Testing confirmed payrate save issue persists. Re-opening for re-fix.'
    )
WHERE ticketid = 2132;

-- #1463 - Import Auditions "Fix" button error
-- Triage note: "Fix button gives Error fetching record data. Marked Implemented previously."
UPDATE tickets
SET ticketStatus = 'Pending',
    ticketCompletedDate = NULL,
    ticketResponse = CONCAT(
        COALESCE(ticketResponse, ''),
        '\n[REVERTED TO PENDING 2026-03-20] Fix button error still present. Re-opening for investigation.'
    )
WHERE ticketid = 1463;

-- Rollback (if needed):
-- UPDATE tickets SET ticketStatus = 'Implemented' WHERE ticketid IN (2132, 1463);
