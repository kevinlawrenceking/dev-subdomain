-- 2026-04-17: Deactivate auto-generated Error tickets written by ErrorService.
--
-- Context: Between 2026-04-04 and 2026-04-17, ErrorService.createSupportTicket
-- dual-wrote every caught exception into the `tickets` table with pgid=0 and
-- verid=0. Those rows render in /app/admin-support/ (LEFT JOINs) but blow up
-- /app/admin-support-details/ (INNER JOINs on pgpages / taousers_tbl) --
-- producing the ERR-xxxxxxxx the admin sees. Canonical home for these records
-- is error_tickets + /app/admin-error-tickets/.
--
-- Strategy: soft-delete (ticketActive='N') so the rows stay auditable and the
-- change is reversible. Signature `ticketdetails LIKE 'Error Ticket: ERR-%'`
-- uniquely identifies rows written by ErrorService.createSupportTicket.

-- Preview (run first, confirm count roughly matches error_tickets row count
-- for the same window):
SELECT COUNT(*) AS to_deactivate
FROM tickets
WHERE tickettype = 'Error'
  AND ticketActive = 'Y'
  AND ticketdetails LIKE 'Error Ticket: ERR-%';

-- Apply:
UPDATE tickets
SET ticketActive = 'N'
WHERE tickettype = 'Error'
  AND ticketActive = 'Y'
  AND ticketdetails LIKE 'Error Ticket: ERR-%';

-- Rollback (if needed):
-- UPDATE tickets
-- SET ticketActive = 'Y'
-- WHERE tickettype = 'Error'
--   AND ticketActive = 'N'
--   AND ticketdetails LIKE 'Error Ticket: ERR-%';
