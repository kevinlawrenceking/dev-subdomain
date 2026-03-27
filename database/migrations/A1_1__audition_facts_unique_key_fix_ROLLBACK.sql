-- ROLLBACK A1_1: Revert unique key change on import_auditions_facts

ALTER TABLE import_auditions_facts
  DROP INDEX idx_iaf_row_field;

ALTER TABLE import_auditions_facts
  ADD UNIQUE INDEX idx_iaf_row_col (row_id, column_id);
