-- =============================================================================
-- Least-privilege MySQL user for the MCP server (@marcelo-ochoa/server-mysql)
--
-- Why: .mcp.json currently authenticates as `admin`. The MCP's only job is
--      read-only inspection (mysql-query SELECTs, mysql-explain). A SELECT-only
--      account means even a stray UPDATE/DELETE sent through the MCP is
--      rejected at the database, not just by convention.
--
-- Target: dev schema `new_development` (matches the .mcp.json connection string
--         mysql://localhost:3306/new_development). For prod, replace the schema
--         name with `actorsbusinessoffice` -- but think hard before granting an
--         always-on MCP any standing access to production.
--
-- Run ONCE as an admin account. Then update .mcp.json env to this user and
-- restart the MCP server.
-- Rollback at the bottom.
-- =============================================================================

-- 1. Create the user. CHANGE THE PASSWORD to a fresh strong random value
--    (do NOT reuse the admin password). '%' host is convenient but broad;
--    if the MCP always connects from one host, replace '%' with that host
--    (e.g. 'localhost' or the workstation IP) to tighten the surface.
CREATE USER IF NOT EXISTS 'tao_mcp_ro'@'%'
  IDENTIFIED BY 'CHANGE_ME_to_a_strong_random_password';

-- 2. Read-only on the dev schema. Covers mysql-query (SELECT) and
--    mysql-explain. This is the full grant the MCP needs for the
--    events_completed review work.
GRANT SELECT ON `new_development`.* TO 'tao_mcp_ro'@'%';

-- 3. OPTIONAL -- only if you want the mysql-stats / mysql-awr tools to work.
--    Those read server-wide performance data. Still read-only, but broader
--    than a single schema. Leave commented unless you need them.
-- GRANT PROCESS ON *.* TO 'tao_mcp_ro'@'%';
-- GRANT SELECT ON `performance_schema`.* TO 'tao_mcp_ro'@'%';
-- GRANT SELECT ON `sys`.* TO 'tao_mcp_ro'@'%';

FLUSH PRIVILEGES;

-- Verify after running:
--   SHOW GRANTS FOR 'tao_mcp_ro'@'%';
--   -- expect exactly: GRANT SELECT ON `new_development`.* (+ optional block)

-- =============================================================================
-- ROLLBACK
-- =============================================================================
-- DROP USER IF EXISTS 'tao_mcp_ro'@'%';
