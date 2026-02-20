-- ============================================================
-- V3_3 ROLLBACK: Remove mapping fields from import_v3_columns
-- ============================================================

ALTER TABLE import_v3_columns
    DROP COLUMN IF EXISTS transform_json,
    DROP COLUMN IF EXISTS target_key,
    DROP COLUMN IF EXISTS intent;
