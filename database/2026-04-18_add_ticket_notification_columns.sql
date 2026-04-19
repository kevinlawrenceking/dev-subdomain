-- PURPOSE: Add the three ticket-notification columns that feat f1b11f9f
--          (admin-support developer response / resolution email) depends on.
-- AUTHOR:  Kevin King
-- DATE:    2026-04-18
-- REASON:  sql/P1_ticket_notifications.sql was committed outside the dated
--          database/ migration stream and was never applied to prod, so
--          /app/admin-support-details/ throws "Unknown column 'developerResponse'"
--          from include/qry/admin-support-details.cfm at the SELECT on line 10.
--
-- Idempotent: each ALTER is guarded by an information_schema check so re-runs
-- are safe. Mirrors the PREPARE/EXECUTE pattern from
-- 2026-03-19_rebuild_taousers_view_recover.sql.
--
-- Rollback:
--   ALTER TABLE tickets
--     DROP COLUMN ackEmailSentAt,
--     DROP COLUMN resolvedEmailSentAt,
--     DROP COLUMN developerResponse;

-- developerResponse
SET @col_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name   = 'tickets'
      AND column_name  = 'developerResponse'
);
SET @alter_sql = IF(@col_exists = 0,
    'ALTER TABLE tickets ADD COLUMN developerResponse TEXT NULL AFTER ticketdetails',
    'SELECT 1'
);
PREPARE stmt FROM @alter_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- resolvedEmailSentAt
SET @col_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name   = 'tickets'
      AND column_name  = 'resolvedEmailSentAt'
);
SET @alter_sql = IF(@col_exists = 0,
    'ALTER TABLE tickets ADD COLUMN resolvedEmailSentAt DATETIME NULL AFTER developerResponse',
    'SELECT 1'
);
PREPARE stmt FROM @alter_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ackEmailSentAt
SET @col_exists = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name   = 'tickets'
      AND column_name  = 'ackEmailSentAt'
);
SET @alter_sql = IF(@col_exists = 0,
    'ALTER TABLE tickets ADD COLUMN ackEmailSentAt DATETIME NULL AFTER resolvedEmailSentAt',
    'SELECT 1'
);
PREPARE stmt FROM @alter_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Post-check: all three should be present.
SELECT column_name, column_type, is_nullable
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND table_name   = 'tickets'
  AND column_name IN ('developerResponse','resolvedEmailSentAt','ackEmailSentAt')
ORDER BY ordinal_position;
