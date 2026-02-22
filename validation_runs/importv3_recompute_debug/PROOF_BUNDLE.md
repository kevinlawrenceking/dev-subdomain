# Recompute Debug - Proof Bundle

Date: 2026-02-22

## Files Changed

1. `ajax/importv3/recompute.cfm` -- 3 edits (outermost catch, addDebug meta, schema gate)

## Root Cause

The `import_v3_columns` table is created by migration `V3_0__contact_import_v3_tables.sql`
with the original column set (`mapped_field`, `is_custom_field`, etc.). A later migration,
`V3_3__import_v3_columns_add_mapping_fields.sql`, adds three columns required by
`recompute.cfm`:

- `intent VARCHAR(20)`
- `target_key VARCHAR(100)`
- `transform_json TEXT`

If V3_3 has not been applied to the connected database, every SELECT and UPDATE in
recompute that references these columns will fail with:

```
Unknown column 'intent' in 'field list'
```

The error would surface at the first query that touches `import_v3_columns` (step D,
line ~498: `SELECT column_id, source_column_index, source_column_name, intent,
target_key, transform_json FROM import_v3_columns`).

## Fix Applied

### 1. Outermost try/catch (bomb-proof wrapper)

Wraps the entire endpoint body (variable init, function definitions, inner try/catch)
in an outermost `<cftry>/<cfcatch>` that returns a stable JSON envelope on ANY
unhandled exception:

```json
{
  "ok": false,
  "stage": "outermost_catch",
  "dsn": "<resolved>",
  "db_name": "<from SELECT DATABASE()>",
  "message": "<cfcatch.message>",
  "detail": "<cfcatch.detail>",
  "type": "<cfcatch.type>",
  "sql": "<cfcatch.sql if present>",
  "tagcontext": [],
  "debug": []
}
```

This ensures no HTML error page ever leaks from this endpoint.

### 2. Enhanced addDebug(step, metaStruct)

`addDebug()` now accepts an optional `meta` struct argument. When provided,
the struct is serialized and appended to the debug line. Both the inner
`variables.response.debug` and the outer `variables.outerDebugSteps` arrays
are fed, so the outermost catch has access to all breadcrumbs accumulated
before the crash.

### 3. Schema gate (V3_3 column verification)

After the info_schema introspection block, a new gate checks that the three
V3_3 columns exist in the `import_v3_columns` table. If any are missing,
it returns:

```json
{
  "success": false,
  "code": "SCHEMA_MISMATCH",
  "message": "import_v3_columns is missing columns added by V3_3 migration: ...",
  "data": {
    "dsn": "abod",
    "db_name": "new_development",
    "actual_columns": ["column_id", "job_id", ...],
    "missing_columns": ["intent", "target_key", "transform_json"],
    "fix_sql": "ALTER TABLE import_v3_columns ADD COLUMN ...",
    "migration_file": "database/migrations/V3_3__import_v3_columns_add_mapping_fields.sql"
  }
}
```

This is an actionable, deterministic error. The operator knows exactly which
migration to run and against which database.

### 4. Enhanced info_schema introspection

The existing column introspection query now captures `DATA_TYPE`, `IS_NULLABLE`,
and `COLUMN_DEFAULT` alongside `COLUMN_NAME`, stored in `variables.tableColsFull`.
This provides full column metadata in the debug output for runtime diagnostics.

## DSN + Database Evidence

The endpoint already (since prior iteration) captures and reports:
- `application.datasource` (resolved DSN name)
- `SELECT DATABASE() AS db_name` (actual MySQL schema)
- `SELECT VERSION() AS mysql_version`

These appear in both the success response debug array and the error response
data envelope.

## Why the Fix is Safe

1. **No schema changes.** Zero ALTER/CREATE/DROP. The gate reads
   `information_schema` (read-only) and only controls flow.

2. **No behavior change.** If V3_3 columns exist, execution is identical
   to before. The gate passes silently with a debug breadcrumb.

3. **Existing endpoints unaffected.** Only `recompute.cfm` is modified.
   Other importv3 endpoints are not touched.

4. **Outermost catch is additive.** It only fires if the inner try/catch
   does not handle the error. Normal success/failure paths are unchanged.

5. **No new dependencies.** No new CFCs, no new tables, no new libraries.

## Verification Checklist

### Before V3_3 migration is applied
- [ ] POST `/ajax/importv3/recompute.cfm` with valid `job_id`
- [ ] Response is JSON (not HTML error page)
- [ ] Response contains `"code": "SCHEMA_MISMATCH"`
- [ ] Response `data.missing_columns` lists `["intent", "target_key", "transform_json"]`
- [ ] Response `data.fix_sql` contains the exact ALTER statements
- [ ] Save response to `FAILURE_RESPONSE.json`

### After V3_3 migration is applied
- [ ] Run: `database/migrations/V3_3__import_v3_columns_add_mapping_fields.sql`
- [ ] POST `/ajax/importv3/recompute.cfm` with valid `job_id`
- [ ] Response is `"success": true, "message": "Recompute completed"`
- [ ] Debug array contains `schema_gate_v3_3 PASSED`
- [ ] Debug array contains `db_name=<expected_schema>`
- [ ] Job status transitions to `reviewing`
- [ ] Save response to `FAILURE_RESPONSE.json` (success section)

### Edge cases
- [ ] POST with no `job_id` returns `"code": "MISSING_JOB_ID"` (JSON, not crash)
- [ ] POST without session returns `"code": "AUTH_REQUIRED"` (JSON, not crash)
- [ ] If `application.datasource` is undefined, outermost catch fires with `"ok": false`
