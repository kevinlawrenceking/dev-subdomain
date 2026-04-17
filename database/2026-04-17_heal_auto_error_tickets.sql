-- 2026-04-17: Heal auto-generated Error tickets so /app/admin-support-details/
-- stops throwing ERR-xxxxxxxx when an admin opens them.
--
-- Context: Between 2026-04-04 and 2026-04-17 ErrorService.createSupportTicket
-- inserted Error-type tickets with pgid=0 / verid=0 / userid=0. Those zeros
-- miss the INNER JOINs in services.TicketService.DETtickets_24767, so the
-- details page crashes. The ErrorService INSERT has since been patched to
-- resolve real FK values at insert time; this script backfills the rows
-- already in prod.
--
-- Signature `ticketdetails LIKE 'Error Ticket: ERR-%'` uniquely identifies
-- rows written by createSupportTicket — manually filed Error-type tickets
-- (if any) are untouched.

-- 1) Preview — how many rows need each kind of fix?
SELECT
    COUNT(*)                                                                 AS candidate_rows,
    SUM(CASE WHEN pgid = 0 THEN 1 ELSE 0 END)                                AS bad_pgid,
    SUM(CASE WHEN verid = 0 THEN 1 ELSE 0 END)                               AS bad_verid,
    SUM(CASE WHEN userid NOT IN (SELECT userid FROM taousers_tbl)
             THEN 1 ELSE 0 END)                                              AS bad_userid
FROM tickets
WHERE tickettype = 'Error'
  AND ticketActive = 'Y'
  AND ticketdetails LIKE 'Error Ticket: ERR-%';

-- 2) Heal pgid — point to the admin-error-tickets page (fallback: any page).
UPDATE tickets
SET pgid = COALESCE(
    (SELECT pgid FROM pgpages WHERE pgDir = 'admin-error-tickets' ORDER BY pgid LIMIT 1),
    (SELECT pgid FROM pgpages ORDER BY pgid LIMIT 1)
)
WHERE tickettype = 'Error'
  AND ticketActive = 'Y'
  AND ticketdetails LIKE 'Error Ticket: ERR-%'
  AND pgid = 0;

-- 3) Heal verid — point to the current active release.
UPDATE tickets
SET verid = (SELECT verid FROM taoversions ORDER BY isactive DESC, verid DESC LIMIT 1)
WHERE tickettype = 'Error'
  AND ticketActive = 'Y'
  AND ticketdetails LIKE 'Error Ticket: ERR-%'
  AND verid = 0;

-- 4) Heal userid — point orphan references to the lowest userid in taousers_tbl.
UPDATE tickets
SET userid = (SELECT userid FROM taousers_tbl ORDER BY userid LIMIT 1)
WHERE tickettype = 'Error'
  AND ticketActive = 'Y'
  AND ticketdetails LIKE 'Error Ticket: ERR-%'
  AND userid NOT IN (SELECT userid FROM taousers_tbl);

-- 5) Post-check — candidate_rows should now be 0.
SELECT COUNT(*) AS still_broken
FROM tickets
WHERE tickettype = 'Error'
  AND ticketActive = 'Y'
  AND ticketdetails LIKE 'Error Ticket: ERR-%'
  AND (pgid = 0
       OR verid = 0
       OR userid NOT IN (SELECT userid FROM taousers_tbl));
