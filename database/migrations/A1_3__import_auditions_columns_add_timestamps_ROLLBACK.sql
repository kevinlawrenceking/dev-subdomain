-- Rollback A1_3: Remove timestamps from import_auditions_columns

ALTER TABLE import_auditions_columns
  DROP COLUMN created_at,
  DROP COLUMN updated_at;
