-- Migration: customerid INT -> BIGINT
-- Date: 2026-04-10
-- Purpose: Thrivecart now sends customer IDs that exceed 32-bit INT max (~2,147,483,647).
--          Example value: 429583657593005146. Both thrivecart_tbl.customerid and
--          taousers_tbl.customerid must be widened to BIGINT to accept these values.
-- Affects: thrivecart_tbl, taousers_tbl
-- Rollback: See commented-out section at bottom of this file.

ALTER TABLE thrivecart_tbl MODIFY customerid BIGINT;

ALTER TABLE taousers_tbl MODIFY customerid BIGINT;

-- ============================================================================
-- ROLLBACK (uncomment and run to revert)
-- ============================================================================
-- ALTER TABLE thrivecart_tbl MODIFY customerid INT;
-- ALTER TABLE taousers_tbl MODIFY customerid INT;
