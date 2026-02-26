# Import V3 Field Name camelCase SSOT Fix -- Proof Bundle

Date: 2026-02-25

## Summary

Fixed a naming convention split where `recompute.cfm` was converting
camelCase field names to snake_case before storing them in
`import_v3_facts.field_name`, while every other component (edit modal,
`recomputeFullName`, search, columns UI) expected camelCase.

## Files Changed

### Core fix

| File | Change |
|------|--------|
| `ajax/importv3/recompute.cfm` | fieldNameMap changed to identity (camelCase -> camelCase) for firstName, lastName, contactFullName, contactType. Updated name validation and dupe matcher to prefer camelCase with snake_case fallback. Added invariant warning log for legacy snake_case. Added convention log at job start. |
| `app/assets/js/contact-import-v3.js` | Removed reverseKeyMap in saveEdit() -- sends camelCase as-is. Added client-side contactFullName recomputation from first+last. |
| `services/ContactImportV3Service.cfc` | Fixed search query field names (first_name -> firstName, last_name -> lastName). Changed recomputeFullName UPDATE to INSERT...ON DUPLICATE KEY UPDATE for robustness. |

### Hardening and tooling (this pass)

| File | Change |
|------|--------|
| `ajax/importv3/recompute.cfm` | Added invariant warning log for snake_case field_name detection. Added convention log at recompute start. |
| `ajax/importv3/normalize_fact_fieldnames.cfm` | NEW -- Admin-only endpoint to remediate legacy snake_case field names for a given job. Idempotent. |
| `scripts/dev/importv3_regression_check.cfm` | NEW -- Admin-only regression check. Reports camelCase vs snake_case counts per field for a job. HTML and JSON output. |
| `docs/contact-import-v3/importer_v3_fieldname_convention.md` | NEW -- Documents the camelCase SSOT, key mapping, and remediation tools. |

## No Schema Changes

Zero ALTER TABLE, CREATE TABLE, CREATE INDEX, or migration files.
All changes are application-layer only.

## Verification Queries

### Check a job for legacy snake_case facts

```sql
SELECT f.field_name, COUNT(*) as cnt
FROM import_v3_facts f
INNER JOIN import_v3_rows r ON f.row_id = r.row_id
WHERE r.job_id = <JOB_ID>
  AND f.field_name IN ('first_name','last_name','full_name','contact_type',
                        'firstName','lastName','contactFullName','contactType')
GROUP BY f.field_name
ORDER BY f.field_name;
```

Expected result for a **newly recomputed job** (post-fix):

```
+-----------------+-----+
| field_name      | cnt |
+-----------------+-----+
| contactFullName |  10 |
| firstName       |  10 |
| lastName        |  10 |
+-----------------+-----+
```

Expected result for a **legacy job** (pre-fix, not yet normalized):

```
+---------------+-----+
| field_name    | cnt |
+---------------+-----+
| first_name    |  10 |
| full_name     |  10 |
| last_name     |  10 |
+---------------+-----+
```

### Normalize endpoint response

```
POST /ajax/importv3/normalize_fact_fieldnames.cfm?job_id=123

Response:
{ "ok": true, "job_id": 123, "updated_count": 30, "message": "Normalized 30 fact field names to camelCase" }
```

Re-run (idempotent):

```
{ "ok": true, "job_id": 123, "updated_count": 0, "message": "Normalized 0 fact field names to camelCase" }
```

## Backward Compatibility

- `buildContactDataFromFacts` (finalize pipeline) has dual-case switch statements for all 4 keys. Existing jobs with snake_case facts will finalize correctly without normalization.
- `renderRows` JS uses `getVal()` which tries both key formats.
- `renderEditModal` JS `normalizeKeys` maps snake_case to camelCase for display.
- The normalize endpoint is optional remediation, not required for correctness.

## Invariant Logging

After this fix, any snake_case field_name written during recompute will
produce a warning in `importv3.log`:

```
[INVARIANT_WARN] snake_case field_name detected job_id=123 row_id=456 field=first_name -- expected camelCase
```

This should never fire for new jobs. If it does, it indicates a regression
in the fieldNameMap or a code path writing facts outside of recompute.
