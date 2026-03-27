-- A1_1: Fix unique key on import_auditions_facts
-- BUG: UNIQUE(row_id, column_id) causes field collision when multiple
--      unmapped fields share column_id=0 during edit-modal saves.
-- FIX: Change unique key to (row_id, field_name) so each field is
--      correctly identified by name, not source column.

-- Step 1: Remove duplicate (row_id, field_name) rows that may exist
--         from the bug. Keep the most recently updated fact per (row_id, field_name).
DELETE f1
FROM import_auditions_facts f1
INNER JOIN import_auditions_facts f2
  ON f1.row_id = f2.row_id
  AND f1.field_name = f2.field_name
  AND f1.fact_id < f2.fact_id;

-- Step 2: Drop old unique key
ALTER TABLE import_auditions_facts
  DROP INDEX idx_iaf_row_col;

-- Step 3: Add new unique key on (row_id, field_name)
ALTER TABLE import_auditions_facts
  ADD UNIQUE INDEX idx_iaf_row_field (row_id, field_name);
