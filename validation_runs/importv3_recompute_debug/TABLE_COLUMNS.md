# import_v3 Table Columns (from V3_0 migration schema)

These are the columns defined in `database/migrations/V3_0__contact_import_v3_tables.sql`.
At runtime, the recompute endpoint introspects `information_schema.COLUMNS` and includes
the live column list in its debug output.

## import_v3_jobs

| Column                       | Data Type    | Nullable | Default              |
|------------------------------|-------------|----------|----------------------|
| job_id                       | int         | NO       | AUTO_INCREMENT       |
| userid                       | int         | NO       | -                    |
| source_filename              | varchar(255)| NO       | -                    |
| file_type                    | varchar(10) | NO       | -                    |
| file_size                    | bigint      | YES      | NULL                 |
| file_hash                    | varchar(64) | YES      | NULL                 |
| stored_file_path             | varchar(500)| YES      | NULL                 |
| status                       | varchar(20) | NO       | 'pending'            |
| error_message                | text        | YES      | NULL                 |
| created_at                   | datetime    | NO       | CURRENT_TIMESTAMP    |
| updated_at                   | datetime    | NO       | CURRENT_TIMESTAMP    |
| started_at                   | datetime    | YES      | NULL                 |
| finished_at                  | datetime    | YES      | NULL                 |
| total_rows                   | int         | YES      | 0                    |
| parsed_rows                  | int         | YES      | 0                    |
| valid_rows                   | int         | YES      | 0                    |
| problem_rows                 | int         | YES      | 0                    |
| dupe_rows                    | int         | YES      | 0                    |
| imported_rows                | int         | YES      | 0                    |
| updated_rows                 | int         | YES      | 0                    |
| skipped_rows                 | int         | YES      | 0                    |
| options_json                 | text        | YES      | NULL                 |
| import_mode                  | varchar(20) | YES      | 'create_only'        |
| allow_blank_overwrite        | tinyint(1)  | YES      | 0                    |
| relationship_system_default  | varchar(50) | YES      | NULL                 |
| folder_assignment_json       | text        | YES      | NULL                 |

### Columns referenced by recompute.cfm
- `job_id`, `userid`, `status` (read via getJobForUser)
- `valid_rows`, `problem_rows`, `dupe_rows`, `skipped_rows` (UPDATE at step I)
- All present in V3_0 schema. **No mismatch.**

---

## import_v3_columns

| Column               | Data Type    | Nullable | Default           | Source     |
|----------------------|-------------|----------|-------------------|------------|
| column_id            | int         | NO       | AUTO_INCREMENT    | V3_0       |
| job_id               | int         | NO       | -                 | V3_0       |
| source_column_index  | int         | NO       | -                 | V3_0       |
| source_column_name   | varchar(255)| YES      | NULL              | V3_0       |
| mapped_field         | varchar(50) | YES      | NULL              | V3_0       |
| is_custom_field      | tinyint(1)  | YES      | 0                 | V3_0       |
| custom_field_id      | int         | YES      | NULL              | V3_0       |
| confidence           | decimal(3,2)| YES      | NULL              | V3_0       |
| user_confirmed       | tinyint(1)  | YES      | 0                 | V3_0       |
| sample_values        | text        | YES      | NULL              | V3_0       |
| created_at           | datetime    | NO       | CURRENT_TIMESTAMP | V3_0       |
| updated_at           | datetime    | NO       | CURRENT_TIMESTAMP | V3_0       |
| **intent**           | varchar(20) | YES      | NULL              | **V3_3**   |
| **target_key**       | varchar(100)| YES      | NULL              | **V3_3**   |
| **transform_json**   | text        | YES      | NULL              | **V3_3**   |

### Columns referenced by recompute.cfm
- SELECT: `column_id`, `source_column_index`, `source_column_name`, **`intent`**, **`target_key`**, **`transform_json`**
- UPDATE: **`intent`**, **`target_key`**, `user_confirmed`, `updated_at`

### MISMATCH (if V3_3 not applied)
- `intent` -- MISSING from V3_0, added by V3_3
- `target_key` -- MISSING from V3_0, added by V3_3
- `transform_json` -- MISSING from V3_0, added by V3_3

**Fix:** Run `database/migrations/V3_3__import_v3_columns_add_mapping_fields.sql`

---

## import_v3_rows

| Column              | Data Type    | Nullable | Default           |
|---------------------|-------------|----------|-------------------|
| row_id              | int         | NO       | AUTO_INCREMENT    |
| job_id              | int         | NO       | -                 |
| row_num             | int         | NO       | -                 |
| raw_json            | text        | NO       | -                 |
| status              | varchar(20) | NO       | 'pending'         |
| error_count         | int         | YES      | 0                 |
| warning_count       | int         | YES      | 0                 |
| validation_summary  | text        | YES      | NULL              |
| dupe_candidates_json| text        | YES      | NULL              |
| matched_contactid   | int         | YES      | NULL              |
| best_match_score    | int         | YES      | NULL              |
| user_action         | varchar(20) | YES      | NULL              |
| user_action_at      | datetime    | YES      | NULL              |
| created_contactid   | int         | YES      | NULL              |
| updated_contactid   | int         | YES      | NULL              |
| import_error        | text        | YES      | NULL              |
| imported_at         | datetime    | YES      | NULL              |
| created_at          | datetime    | NO       | CURRENT_TIMESTAMP |
| updated_at          | datetime    | NO       | CURRENT_TIMESTAMP |

### Columns referenced by recompute.cfm
- SELECT: `row_id`, `row_num`, `raw_json`, `status`, `user_action`
- UPDATE: `status`, `error_count`, `warning_count`, `validation_summary`, `dupe_candidates_json`, `matched_contactid`, `best_match_score`, `updated_at`
- All present in V3_0 schema. **No mismatch.**

---

## import_v3_facts

| Column             | Data Type    | Nullable | Default           |
|--------------------|-------------|----------|-------------------|
| fact_id            | int         | NO       | AUTO_INCREMENT    |
| row_id             | int         | NO       | -                 |
| column_id          | int         | NO       | -                 |
| field_name         | varchar(50) | NO       | -                 |
| raw_value          | text        | YES      | NULL              |
| normalized_value   | text        | YES      | NULL              |
| is_valid           | tinyint(1)  | YES      | 1                 |
| validation_code    | varchar(30) | YES      | NULL              |
| validation_message | varchar(255)| YES      | NULL              |
| existing_value     | text        | YES      | NULL              |
| has_conflict       | tinyint(1)  | YES      | 0                 |
| user_choice        | varchar(20) | YES      | NULL              |
| created_at         | datetime    | NO       | CURRENT_TIMESTAMP |
| updated_at         | datetime    | NO       | CURRENT_TIMESTAMP |

### Columns referenced by recompute.cfm
- SELECT: `fact_id`, `column_id`, `field_name`, `raw_value`, `normalized_value`
- UPDATE: `is_valid`, `validation_code`, `validation_message`, `normalized_value`, `field_name`, `updated_at`
- All present in V3_0 schema. **No mismatch.**
