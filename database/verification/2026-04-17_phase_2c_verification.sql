-- TAO-SPEC-2026-005 Phase 2c: ErrorService rootCause verification
-- Run against: new_development (dev DSN abod)
-- After: applying 2026-04-17_error_tickets_add_root_cause.sql
--        and triggering /app/admin-error-test/?mode=query,expression,nested
--
-- Expected shape per mode:
--   query      => root_cause_type/message/file/line populated from JDBC cause
--   expression => root_cause_* may be empty/0 (no java-level cause)
--   nested     => cause_chain JSON has >= 1 frame, causeTruncated = 0

-- ==============================================================
-- CHECK 1: Schema — all six new columns + index present.
-- Expected: 6 column rows + 1 index row, all with expected types.
-- ==============================================================
SELECT
    COLUMN_NAME,
    COLUMN_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'new_development'
  AND TABLE_NAME   = 'error_tickets'
  AND COLUMN_NAME IN (
      'root_cause_type',
      'root_cause_message',
      'root_cause_detail',
      'root_cause_file',
      'root_cause_line',
      'cause_chain'
  )
ORDER BY ORDINAL_POSITION;

SELECT
    INDEX_NAME,
    COLUMN_NAME,
    NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'new_development'
  AND TABLE_NAME   = 'error_tickets'
  AND INDEX_NAME   = 'idx_root_cause_type';

-- ==============================================================
-- CHECK 2: Three most recent error_tickets rows — root-cause fields.
-- Expected: 3 rows (one per smoke-test mode). Inspect per-row below.
-- ==============================================================
SELECT
    ticket_id,
    created_at,
    error_type,
    LEFT(error_message, 80)         AS error_message_preview,
    root_cause_type,
    LEFT(root_cause_message, 80)    AS root_cause_message_preview,
    root_cause_file,
    root_cause_line,
    CHAR_LENGTH(IFNULL(cause_chain,'')) AS cause_chain_bytes,
    script_name
FROM error_tickets
ORDER BY id DESC
LIMIT 3;

-- ==============================================================
-- CHECK 3: Paired support ticket in tickets table — confirms the
-- createSupportTicket path wrote the Root Cause block + FK columns.
-- Expected: 3 rows, tickettype='Error', ticketdetails LIKE '%Root Cause%'
-- for query/nested modes. Expression mode may omit the block.
-- ==============================================================
SELECT
    t.ticketid,
    t.tickettype,
    t.pgid,
    t.verid,
    t.userid,
    LEFT(t.ticketName, 120)                                   AS name_preview,
    (t.ticketdetails LIKE '%Root Cause Message:%')            AS has_root_cause_block,
    (t.ticketdetails LIKE '%--- Outer Exception ---%')        AS has_outer_divider,
    SUBSTRING(t.ticketdetails, 1, 40)                         AS details_head
FROM tickets t
WHERE t.tickettype     = 'Error'
  AND t.ticketActive   = 'Y'
  AND t.ticketdetails LIKE 'Error Ticket: ERR-%'
ORDER BY t.ticketid DESC
LIMIT 3;

-- ==============================================================
-- CHECK 4: Nested-mode cause_chain depth — confirms unwrapCauseChain
-- walked at least one frame and recorded depth/type/file/line JSON.
-- Expected: at least one row with chain_depth >= 1 (from mode=nested).
-- ==============================================================
SELECT
    ticket_id,
    created_at,
    root_cause_type,
    -- JSON_LENGTH works on MySQL 5.7+ and counts array elements.
    CASE
        WHEN cause_chain IS NULL OR cause_chain = '' THEN 0
        ELSE JSON_LENGTH(cause_chain)
    END                                         AS chain_depth,
    LEFT(cause_chain, 300)                      AS chain_head
FROM error_tickets
WHERE created_at >= NOW() - INTERVAL 1 HOUR
ORDER BY id DESC
LIMIT 10;

-- ==============================================================
-- CHECK 5: Fallback health — no recent rows should be missing
-- ticket_id or have a NULL error_message. Also confirms the persist
-- path did not silently fall through to cflog-only.
-- Expected: missing_count = 0.
-- ==============================================================
SELECT
    COUNT(*)                                                  AS recent_rows_1h,
    SUM(CASE WHEN ticket_id IS NULL OR ticket_id = '' THEN 1 ELSE 0 END)     AS missing_ticket_id,
    SUM(CASE WHEN error_message IS NULL OR error_message = '' THEN 1 ELSE 0 END) AS missing_error_message,
    SUM(CASE WHEN root_cause_type IS NOT NULL AND root_cause_type <> '' THEN 1 ELSE 0 END) AS with_root_cause_type
FROM error_tickets
WHERE created_at >= NOW() - INTERVAL 1 HOUR;
