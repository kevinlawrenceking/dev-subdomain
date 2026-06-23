-- PURPOSE: Add tickets_tbl.followupEmailSentAt and expose it through the
--          `tickets` view. Stores 3-day follow-up state for the user-facing
--          ticket-notification flow. The follow-up window is measured from
--          tickets_tbl.resolvedEmailSentAt (NOT ticketCompletedDate).
-- AUTHOR:  Claude Code (TAO-SPEC-2026-005 extension: user-facing error mgmt flow)
-- DATE:    2026-06-22
-- EXTENDS: 2026-04-18_add_ticket_notification_columns.sql (same view-rebuild dance).
--
-- SAFE TO RE-RUN: every step is guarded by information_schema checks. A replayed
--                 ADD COLUMN would throw 1060; the IF() guard makes it a no-op.
-- SAFE ON EITHER SCHEMA: if `tickets` is not a view or `tickets_tbl` is absent
--                 (dev schema drift), every step becomes a no-op.
--
-- Captured view definition (from 2026-04-18 migration, 28 columns: original 25
-- + developerResponse + resolvedEmailSentAt + ackEmailSentAt). This migration
-- adds followupEmailSentAt as the 29th column, immediately AFTER resolvedEmailSentAt
-- in the base table and at the end of the view column list.
--
-- Rollback: database/migrations/2026-06-22_tickets_add_followup_ROLLBACK.sql

-- Step 0: Environment guard -- only proceed on schemas with the view/base-table split.
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
SET @proceed = (@tickets_is_view = 1 AND @tbl_exists = 1);

-- Step 1: Add followupEmailSentAt to tickets_tbl (idempotent; guards 1060).
SET @col_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name   = 'tickets_tbl'
      AND column_name  = 'followupEmailSentAt'
);
SET @sql = IF(@proceed = 1 AND @col_exists = 0,
    'ALTER TABLE tickets_tbl ADD COLUMN followupEmailSentAt DATETIME NULL AFTER resolvedEmailSentAt',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Step 2: Drop the view (only if it is currently a view).
SET @sql = IF(@proceed = 1, 'DROP VIEW IF EXISTS tickets', 'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Step 3: Recreate the view = original 25 + 3 notification columns + followupEmailSentAt.
--         Preserves ALGORITHM=UNDEFINED, DEFINER=kingk436@%, SQL SECURITY DEFINER,
--         and the WHERE IsDeleted = 0 filter from the 2026-04-18 captured definition.
SET @sql = IF(@proceed = 1,
    CONCAT(
        'CREATE ALGORITHM=UNDEFINED DEFINER=`kingk436`@`%` SQL SECURITY DEFINER VIEW `tickets` AS ',
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
            '`tickets_tbl`.`ackEmailSentAt` AS `ackEmailSentAt`,',
            '`tickets_tbl`.`followupEmailSentAt` AS `followupEmailSentAt` ',
        'FROM `tickets_tbl` WHERE (`tickets_tbl`.`IsDeleted` = 0)'
    ),
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Post-check: followupEmailSentAt should appear in BOTH tickets_tbl and tickets.
-- Expect 2 rows on a schema with the split; 0 rows on a schema that wasn't touched.
SELECT table_name, column_name, ordinal_position
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND table_name IN ('tickets','tickets_tbl')
  AND column_name = 'followupEmailSentAt'
ORDER BY table_name;
