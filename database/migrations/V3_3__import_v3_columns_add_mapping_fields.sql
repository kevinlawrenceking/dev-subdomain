-- V3_3: Add mapping fields to import_v3_columns

ALTER TABLE import_v3_columns ADD COLUMN intent VARCHAR(20) DEFAULT NULL AFTER sample_values;
ALTER TABLE import_v3_columns ADD COLUMN target_key VARCHAR(100) DEFAULT NULL AFTER intent;
ALTER TABLE import_v3_columns ADD COLUMN transform_json TEXT DEFAULT NULL AFTER target_key;
