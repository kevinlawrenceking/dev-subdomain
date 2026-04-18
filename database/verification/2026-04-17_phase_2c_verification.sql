-- TAO-SPEC-2026-005 Phase 2c: ErrorService rootCause verification
-- Run against: new_development (dev DSN abod)
-- After: applying 2026-04-17_error_tickets_add_root_cause.sql
--        and triggering /app/admin-error-test/?mode=query,expression,nested
--
-- Expected shape per mode:
--   query      => root_cause_type/message/file/line populated from JDBC cause
--   expression => root_cause_* may be empty/0 (no java-level cause)
--   nested     => cause_chain JSON has >= 1 frame, causeTruncated = 0
--
-- All five checks are unioned into ONE result set. Each section starts with
-- a header row whose c1..c10 cells name the columns, followed by its data
-- rows. Columns a section does not use are blank. Rows are ordered by a
-- hidden (_ord, _sort2) sort key so sections stay grouped and data rows
-- within a section appear newest-first.
--
-- Section map:
--   1a  schema columns        (6 rows expected)
--   1b  schema index          (1 row expected)
--   2   recent error_tickets  (3 rows expected — one per smoke-test mode)
--   3   paired tickets        (3 rows expected — createSupportTicket output)
--   4   nested chain          (up to 10 rows from last 1h — nested >= 1)
--   5   fallback health       (1 aggregate row)

SELECT
    check_id,
    section,
    c1, c2, c3, c4, c5, c6, c7, c8, c9, c10
FROM (

    -- ================= CHECK 1a: schema columns =================
    -- Expected: 6 rows, IS_NULLABLE='YES', COLUMN_DEFAULT=NULL.
    SELECT
        CAST(10 AS SIGNED) AS _ord,
        CAST(0  AS SIGNED) AS _sort2,
        CAST('1a'             AS CHAR(4))   AS check_id,
        CAST('schema columns' AS CHAR(30))  AS section,
        CAST('COLUMN_NAME'    AS CHAR(500)) AS c1,
        CAST('COLUMN_TYPE'    AS CHAR(500)) AS c2,
        CAST('IS_NULLABLE'    AS CHAR(500)) AS c3,
        CAST('COLUMN_DEFAULT' AS CHAR(500)) AS c4,
        CAST('' AS CHAR(500)) AS c5,
        CAST('' AS CHAR(500)) AS c6,
        CAST('' AS CHAR(500)) AS c7,
        CAST('' AS CHAR(500)) AS c8,
        CAST('' AS CHAR(500)) AS c9,
        CAST('' AS CHAR(500)) AS c10

    UNION ALL

    SELECT
        10,
        CAST(ORDINAL_POSITION AS SIGNED),
        '1a',
        'schema columns',
        CAST(COLUMN_NAME AS CHAR(255)),
        CAST(COLUMN_TYPE AS CHAR(255)),
        CAST(IS_NULLABLE AS CHAR(3)),
        CAST(IFNULL(COLUMN_DEFAULT, 'NULL') AS CHAR(255)),
        '', '', '', '', '', ''
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

    UNION ALL

    -- ================= CHECK 1b: schema index ===================
    -- Expected: 1 row with INDEX_NAME='idx_root_cause_type'.
    SELECT 20, 0,
           '1b', 'schema index',
           'INDEX_NAME', 'COLUMN_NAME', 'NON_UNIQUE',
           '', '', '', '', '', '', ''

    UNION ALL

    SELECT 20, 1,
           '1b', 'schema index',
           CAST(INDEX_NAME  AS CHAR(255)),
           CAST(COLUMN_NAME AS CHAR(255)),
           CAST(NON_UNIQUE  AS CHAR(3)),
           '', '', '', '', '', '', ''
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = 'new_development'
      AND TABLE_NAME   = 'error_tickets'
      AND INDEX_NAME   = 'idx_root_cause_type'

    UNION ALL

    -- ================= CHECK 2: recent error_tickets ============
    -- Expected: 3 rows (one per smoke-test mode).
    --   query      => root_cause_type populated, root_cause_line > 0
    --   expression => root_cause_type empty
    --   nested     => cause_chain_bytes > 0
    SELECT 30, 0,
           '2', 'recent error_tickets',
           'ticket_id', 'created_at', 'error_type',
           'error_message_80', 'root_cause_type',
           'root_cause_msg_80', 'root_cause_file',
           'root_cause_line', 'cause_chain_bytes', 'script_name'

    UNION ALL

    SELECT 30, -CAST(t2.id AS SIGNED),
           '2', 'recent error_tickets',
           t2.ticket_id, t2.created_at, t2.error_type,
           t2.error_message_80, t2.root_cause_type,
           t2.root_cause_msg_80, t2.root_cause_file,
           t2.root_cause_line, t2.cause_chain_bytes, t2.script_name
    FROM (
        SELECT
            et.id,
            CAST(et.ticket_id                                AS CHAR(255)) AS ticket_id,
            CAST(et.created_at                               AS CHAR(30))  AS created_at,
            CAST(IFNULL(et.error_type, '')                   AS CHAR(255)) AS error_type,
            CAST(LEFT(IFNULL(et.error_message, ''), 80)      AS CHAR(80))  AS error_message_80,
            CAST(IFNULL(et.root_cause_type, '')              AS CHAR(255)) AS root_cause_type,
            CAST(LEFT(IFNULL(et.root_cause_message, ''), 80) AS CHAR(80))  AS root_cause_msg_80,
            CAST(IFNULL(et.root_cause_file, '')              AS CHAR(500)) AS root_cause_file,
            CAST(IFNULL(et.root_cause_line, 0)               AS CHAR(20))  AS root_cause_line,
            CAST(CHAR_LENGTH(IFNULL(et.cause_chain, ''))     AS CHAR(20))  AS cause_chain_bytes,
            CAST(IFNULL(et.script_name, '')                  AS CHAR(500)) AS script_name
        FROM error_tickets et
        ORDER BY et.id DESC
        LIMIT 3
    ) t2

    UNION ALL

    -- ================= CHECK 3: paired tickets ==================
    -- Expected: 3 rows, tickettype='Error', pgid>0, verid>0, userid>0.
    -- query and nested rows should have has_root_cause_block = 1.
    SELECT 40, 0,
           '3', 'paired tickets',
           'ticketid', 'tickettype', 'pgid',
           'verid', 'userid', 'name_preview',
           'has_root_cause_block', 'has_outer_divider', 'details_head', ''

    UNION ALL

    SELECT 40, -CAST(t3.ticketid_num AS SIGNED),
           '3', 'paired tickets',
           t3.ticketid, t3.tickettype, t3.pgid,
           t3.verid, t3.userid, t3.name_preview,
           t3.has_root_cause_block, t3.has_outer_divider, t3.details_head, ''
    FROM (
        SELECT
            t.ticketid                                                       AS ticketid_num,
            CAST(t.ticketid                                      AS CHAR(20))  AS ticketid,
            CAST(t.tickettype                                    AS CHAR(40))  AS tickettype,
            CAST(t.pgid                                          AS CHAR(20))  AS pgid,
            CAST(t.verid                                         AS CHAR(20))  AS verid,
            CAST(t.userid                                        AS CHAR(20))  AS userid,
            CAST(LEFT(IFNULL(t.ticketName, ''), 120)             AS CHAR(120)) AS name_preview,
            CAST((t.ticketdetails LIKE '%Root Cause Message:%')  AS CHAR(3))   AS has_root_cause_block,
            CAST((t.ticketdetails LIKE '%--- Outer Exception ---%') AS CHAR(3)) AS has_outer_divider,
            CAST(SUBSTRING(IFNULL(t.ticketdetails, ''), 1, 40)   AS CHAR(40))  AS details_head
        FROM tickets t
        WHERE t.tickettype     = 'Error'
          AND t.ticketActive   = 'Y'
          AND t.ticketdetails LIKE 'Error Ticket: ERR-%'
        ORDER BY t.ticketid DESC
        LIMIT 3
    ) t3

    UNION ALL

    -- ================= CHECK 4: nested chain depth ==============
    -- Expected: at least one row in the last 1h with chain_depth >= 1
    -- (from mode=nested). JSON_LENGTH works on MySQL 5.7+.
    SELECT 50, 0,
           '4', 'nested chain',
           'ticket_id', 'created_at', 'root_cause_type',
           'chain_depth', 'chain_head_300',
           '', '', '', '', ''

    UNION ALL

    SELECT 50, -CAST(t4.id AS SIGNED),
           '4', 'nested chain',
           t4.ticket_id, t4.created_at, t4.root_cause_type,
           t4.chain_depth, t4.chain_head_300,
           '', '', '', '', ''
    FROM (
        SELECT
            et.id,
            CAST(et.ticket_id                    AS CHAR(255)) AS ticket_id,
            CAST(et.created_at                   AS CHAR(30))  AS created_at,
            CAST(IFNULL(et.root_cause_type, '')  AS CHAR(255)) AS root_cause_type,
            CAST(
                CASE
                    WHEN et.cause_chain IS NULL OR et.cause_chain = '' THEN 0
                    ELSE JSON_LENGTH(et.cause_chain)
                END
                AS CHAR(20)
            ) AS chain_depth,
            CAST(LEFT(IFNULL(et.cause_chain, ''), 300) AS CHAR(300)) AS chain_head_300
        FROM error_tickets et
        WHERE et.created_at >= NOW() - INTERVAL 1 HOUR
        ORDER BY et.id DESC
        LIMIT 10
    ) t4

    UNION ALL

    -- ================= CHECK 5: fallback health =================
    -- Expected: missing_ticket_id=0, missing_error_message=0,
    -- with_root_cause_type >= 1. Single aggregate row.
    SELECT 60, 0,
           '5', 'fallback health',
           'recent_rows_1h', 'missing_ticket_id',
           'missing_error_message', 'with_root_cause_type',
           '', '', '', '', '', ''

    UNION ALL

    SELECT 60, 1,
           '5', 'fallback health',
           CAST(COUNT(*) AS CHAR(20)),
           CAST(SUM(CASE WHEN ticket_id IS NULL OR ticket_id = '' THEN 1 ELSE 0 END) AS CHAR(20)),
           CAST(SUM(CASE WHEN error_message IS NULL OR error_message = '' THEN 1 ELSE 0 END) AS CHAR(20)),
           CAST(SUM(CASE WHEN root_cause_type IS NOT NULL AND root_cause_type <> '' THEN 1 ELSE 0 END) AS CHAR(20)),
           '', '', '', '', '', ''
    FROM error_tickets
    WHERE created_at >= NOW() - INTERVAL 1 HOUR

) combined
ORDER BY _ord ASC, _sort2 ASC;
