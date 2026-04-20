-- PURPOSE: Expose the three ticket-notification columns through the `tickets`
--          view so include/qry/admin-support-details.cfm stops throwing
--          "Unknown column 't.developerResponse' in 'field list'".
-- AUTHOR:  Kevin King
-- DATE:    2026-04-18
-- REASON:  Prod schema has `tickets` as a VIEW over base table `tickets_tbl`
--          (WHERE IsDeleted = 0). The P1 migration added the columns to the
--          base table but the view's column list is frozen at CREATE VIEW
--          time, so the view still doesn't expose them.
--
-- SAFE TO RE-RUN: every step is guarded by information_schema checks.
-- SAFE TO RUN ON EITHER SCHEMA: if `tickets` is not a view or `tickets_tbl`
-- doesn't exist (dev schema drift), every step becomes a no-op.
--
-- Current (pre-migration) view definition captured from
--   SHOW CREATE VIEW actorsbusinessoffice.tickets
-- on 2026-04-18:
--   CREATE ALGORITHM=UNDEFINED DEFINER=`kingk436`@`%` SQL SECURITY DEFINER
--   VIEW `tickets` AS SELECT <25 columns> FROM `tickets_tbl`
--   WHERE (`tickets_tbl`.`IsDeleted` = 0)
--
-- Rollback:
--   ALTER TABLE tickets_tbl
--     DROP COLUMN ackEmailSentAt,
--     DROP COLUMN resolvedEmailSentAt,
--     DROP COLUMN developerResponse;
--   DROP VIEW IF EXISTS tickets;
--   CREATE ALGORITHM=UNDEFINED DEFINER=`kingk436`@`%` SQL SECURITY DEFINER
--   VIEW `tickets` AS
--   SELECT `tickets_tbl`.`ticketID` AS `ticketID`,
--          `tickets_tbl`.`pgID` AS `pgID`,
--          `tickets_tbl`.`ticketName` AS `ticketName`,
--          `tickets_tbl`.`ticketDetails` AS `ticketDetails`,
--          `tickets_tbl`.`ticketResponse` AS `ticketResponse`,
--          `tickets_tbl`.`userid` AS `userid`,
--          `tickets_tbl`.`ticketCreatedDate` AS `ticketCreatedDate`,
--          `tickets_tbl`.`ticketCompletedDate` AS `ticketCompletedDate`,
--          `tickets_tbl`.`ticketStatus` AS `ticketStatus`,
--          `tickets_tbl`.`ticketActive` AS `ticketActive`,
--          `tickets_tbl`.`ticketType` AS `ticketType`,
--          `tickets_tbl`.`recordname` AS `recordname`,
--          `tickets_tbl`.`IsDeleted` AS `IsDeleted`,
--          `tickets_tbl`.`initial_email` AS `initial_email`,
--          `tickets_tbl`.`complete_email` AS `complete_email`,
--          `tickets_tbl`.`ticketstring` AS `ticketstring`,
--          `tickets_tbl`.`verid` AS `verid`,
--          `tickets_tbl`.`patchNote` AS `patchNote`,
--          `tickets_tbl`.`environ` AS `environ`,
--          `tickets_tbl`.`ticketPriority` AS `ticketPriority`,
--          `tickets_tbl`.`estHours` AS `estHours`,
--          `tickets_tbl`.`testingScript` AS `testingScript`,
--          `tickets_tbl`.`customTestPageName` AS `customTestPageName`,
--          `tickets_tbl`.`customTestPageLink` AS `customTestPageLink`,
--          `tickets_tbl`.`errorid` AS `errorid`
--   FROM `tickets_tbl` WHERE (`tickets_tbl`.`IsDeleted` = 0);

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

-- Step 1a: Add developerResponse to tickets_tbl (idempotent).
SET @col_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name   = 'tickets_tbl'
      AND column_name  = 'developerResponse'
);
SET @sql = IF(@proceed = 1 AND @col_exists = 0,
    'ALTER TABLE tickets_tbl ADD COLUMN developerResponse TEXT NULL AFTER ticketDetails',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Step 1b: Add resolvedEmailSentAt to tickets_tbl (idempotent).
SET @col_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name   = 'tickets_tbl'
      AND column_name  = 'resolvedEmailSentAt'
);
SET @sql = IF(@proceed = 1 AND @col_exists = 0,
    'ALTER TABLE tickets_tbl ADD COLUMN resolvedEmailSentAt DATETIME NULL AFTER developerResponse',
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Step 1c: Add ackEmailSentAt to tickets_tbl (idempotent).
SET @col_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name   = 'tickets_tbl'
      AND column_name  = 'ackEmailSentAt'
);
SET @sql = IF(@proceed = 1 AND @col_exists = 0,
    'ALTER TABLE tickets_tbl ADD COLUMN ackEmailSentAt DATETIME NULL AFTER resolvedEmailSentAt',
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

-- Step 3: Recreate the view with the original 25 columns plus the 3 new ones.
--         Preserves ALGORITHM=UNDEFINED, DEFINER=kingk436@%, SQL SECURITY DEFINER,
--         and the WHERE IsDeleted = 0 filter from the captured definition.
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

-- Post-check: each of the three columns should appear in BOTH tickets_tbl (the base)
-- and tickets (the view). Expect 6 rows on prod; 0 rows on a schema that wasn't touched.
SELECT table_name, column_name, ordinal_position
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND table_name IN ('tickets','tickets_tbl')
  AND column_name IN ('developerResponse','resolvedEmailSentAt','ackEmailSentAt')
ORDER BY table_name, ordinal_position;
