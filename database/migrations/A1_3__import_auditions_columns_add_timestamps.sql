-- A1_3: Add created_at and updated_at to import_auditions_columns
-- The other staging tables (jobs, rows, facts) already have these columns.
-- recompute.cfm references updated_at in column-mapping UPDATE queries.

ALTER TABLE import_auditions_columns
  ADD COLUMN created_at DATETIME DEFAULT NOW(),
  ADD COLUMN updated_at DATETIME DEFAULT NOW() ON UPDATE NOW();
