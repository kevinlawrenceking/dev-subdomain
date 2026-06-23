-- ROLLBACK for 2026-06-22_tickets_add_followup.sql
-- Drops tickets_tbl.followupEmailSentAt and rebuilds the `tickets` view back to
-- its 28-column (post-2026-04-18) shape WITHOUT followupEmailSentAt.
-- AUTHOR: Claude Code (TAO-SPEC-2026-005 extension)
-- DATE:   2026-06-22
--
-- SAFE TO RE-RUN: guarded by information_schema. SAFE ON EITHER SCHEMA: no-op
-- where the view/base-table split is absent.

-- Step 0: Environment guard.
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

-- Step 1: Drop the view if present.
SET @sql = IF(@proceed = 1, 'DROP VIEW IF EXISTS tickets', 'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Step 2: Recreate the view WITHOUT followupEmailSentAt (28 columns).
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
            '`tickets_tbl`.`ackEmailSentAt` AS `ackEmailSentAt` ',
        'FROM `tickets_tbl` WHERE (`tickets_tbl`.`IsDeleted` = 0)'
    ),
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Step 3: Drop the column (idempotent).
SET @col_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name   = 'tickets_tbl'
      AND column_name  = 'followupEmailSentAt'
);
SET @sql = IF(@proceed = 1 AND @col_exists = 1,
    'ALTER TABLE tickets_tbl DROP COLUMN followupEmailSentAt',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Post-check: expect 0 rows after rollback.
SELECT table_name, column_name
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND table_name IN ('tickets','tickets_tbl')
  AND column_name = 'followupEmailSentAt';
