-- PURPOSE: Rebuild the `tickets` view with SQL SECURITY INVOKER so it no
--          longer depends on a specific DEFINER account existing and being
--          granted SELECT on tickets_tbl.
-- AUTHOR:  Kevin King
-- DATE:    2026-04-18
-- REASON:  Earlier migration 2026-04-18_add_ticket_notification_columns.sql
--          rebuilt the view with `DEFINER=kingk436@%` and `SQL SECURITY DEFINER`.
--          When executed from a phpMyAdmin session that lacked SUPER /
--          SET_USER_ID, MySQL silently rewrote the DEFINER clause to the
--          current session identity (root@108.185.100.195). Under
--          SQL SECURITY DEFINER, view execution runs under that stored
--          identity. If root@108.185.100.195 does not have SELECT on
--          tickets_tbl (or the host-scoped account is stale / removed),
--          MySQL returns error 1146 "Table 'actorsbusinessoffice.tickets'
--          doesn't exist" to the caller -- which is what ColdFusion is
--          hitting now on /app/admin-support-details/.
--
--          With SQL SECURITY INVOKER, privilege checks run as the invoking
--          user (the CF DSN account). CF already has the privileges it
--          needs for the base table, so the view just works, regardless of
--          whether any DEFINER user exists.
--
-- TARGET SCHEMA: runs verbatim on BOTH `actorsbusinessoffice` (prod) and
--                `new_development` (dev). Uses DATABASE() so it rebuilds
--                the view in whichever schema is currently selected.
--                Run with USE <schema>; first.
--
-- SAFE TO RE-RUN: DROP VIEW IF EXISTS + CREATE VIEW. Idempotent. Preserves
--                 the current 28-column list (25 original + 3 notification
--                 columns added on 2026-04-18).
--
-- ROLLBACK (restores prior DEFINER-based security, not recommended):
--   DROP VIEW IF EXISTS tickets;
--   CREATE ALGORITHM=UNDEFINED DEFINER=`kingk436`@`%` SQL SECURITY DEFINER
--   VIEW tickets AS <same SELECT as below> ;

-- ============================================================================
-- Step 0: Environment guard -- only rebuild where tickets is actually a view
--         over a base table tickets_tbl that has the 3 notification columns.
-- ============================================================================
SET @tickets_is_view = (
    SELECT COUNT(*) FROM information_schema.tables
    WHERE table_schema = DATABASE()
      AND table_name   = 'tickets'
      AND table_type   = 'VIEW'
);
SET @tbl_exists = (
    SELECT COUNT(*) FROM information_schema.tables
    WHERE table_schema = DATABASE()
      AND table_name   = 'tickets_tbl'
      AND table_type   = 'BASE TABLE'
);
SET @cols_present = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name   = 'tickets_tbl'
      AND column_name IN ('developerResponse','resolvedEmailSentAt','ackEmailSentAt')
);
SET @proceed = (@tickets_is_view = 1 AND @tbl_exists = 1 AND @cols_present = 3);

-- ============================================================================
-- Step 1: DROP the current view (only if preconditions met).
-- ============================================================================
SET @sql = IF(@proceed = 1, 'DROP VIEW IF EXISTS tickets', 'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- Step 2: Recreate with SQL SECURITY INVOKER. No DEFINER clause -- MySQL will
--         default it to the creating user, but it does not affect runtime
--         privilege checks under INVOKER security.
-- ============================================================================
SET @sql = IF(@proceed = 1,
    CONCAT(
        'CREATE ALGORITHM=UNDEFINED SQL SECURITY INVOKER VIEW `tickets` AS ',
        'SELECT ',
            '`tickets_tbl`.`ticketID` AS `ticketID`,',
            '`tickets_tbl`.`pgID` AS `pgID`,',
            '`tickets_tbl`.`ticketName` AS `ticketName`,',
            '`tickets_tbl`.`ticketDetails` AS `ticketDetails`,',
            '`tickets_tbl`.`ticketResponse` AS `ticketResponse`,',
            '`tickets_tbl`.`userid` AS `userid`,',
            '`tickets_tbl`.`ticketCreatedDate` AS `ticketCreatedDate`,',
            '`tickets_tbl`.`ticketCompletedDate` AS `ticketCompletedDate`,',
            '`tickets_tbl`.`ticketStatus` AS `ticketStatus`,',
            '`tickets_tbl`.`ticketActive` AS `ticketActive`,',
            '`tickets_tbl`.`ticketType` AS `ticketType`,',
            '`tickets_tbl`.`recordname` AS `recordname`,',
            '`tickets_tbl`.`IsDeleted` AS `IsDeleted`,',
            '`tickets_tbl`.`initial_email` AS `initial_email`,',
            '`tickets_tbl`.`complete_email` AS `complete_email`,',
            '`tickets_tbl`.`ticketstring` AS `ticketstring`,',
            '`tickets_tbl`.`verid` AS `verid`,',
            '`tickets_tbl`.`patchNote` AS `patchNote`,',
            '`tickets_tbl`.`environ` AS `environ`,',
            '`tickets_tbl`.`ticketPriority` AS `ticketPriority`,',
            '`tickets_tbl`.`estHours` AS `estHours`,',
            '`tickets_tbl`.`testingScript` AS `testingScript`,',
            '`tickets_tbl`.`customTestPageName` AS `customTestPageName`,',
            '`tickets_tbl`.`customTestPageLink` AS `customTestPageLink`,',
            '`tickets_tbl`.`errorid` AS `errorid`,',
            '`tickets_tbl`.`developerResponse` AS `developerResponse`,',
            '`tickets_tbl`.`resolvedEmailSentAt` AS `resolvedEmailSentAt`,',
            '`tickets_tbl`.`ackEmailSentAt` AS `ackEmailSentAt` ',
        'FROM `tickets_tbl` WHERE (`tickets_tbl`.`IsDeleted` = 0)'
    ),
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- POST-CHECK: view should exist, be INVOKER-secured, and return rows.
-- ============================================================================
SELECT table_schema, table_name, security_type, is_updatable
FROM information_schema.views
WHERE table_schema = DATABASE()
  AND table_name = 'tickets';

-- Smoke test -- one row is enough to prove CF can now read through the view.
SELECT ticketID, ticketName, developerResponse, resolvedEmailSentAt, ackEmailSentAt
FROM tickets
ORDER BY ticketID DESC
LIMIT 1;
