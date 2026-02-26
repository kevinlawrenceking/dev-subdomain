# Import V3 Field Name Convention

## SSOT: camelCase

The single source of truth for `import_v3_facts.field_name` and
`import_v3_columns.target_key` is **camelCase**.

Legacy snake_case values are tolerated on **read paths only** (e.g.,
`buildContactDataFromFacts` dual-case switch, `renderRows` JS fallback).
New writes must always use the camelCase key.

## Canonical Key Mapping

| snake_case (legacy) | camelCase (canonical) |
|----------------------|-----------------------|
| `first_name`         | `firstName`           |
| `last_name`          | `lastName`            |
| `full_name`          | `contactFullName`     |
| `contact_type`       | `contactType`         |

All other field names (`email_business`, `phone_work`, `company`, `city`,
`birthday`, etc.) are already identical in both conventions and are
unchanged.

## Where this applies

| Location | Convention | Notes |
|----------|-----------|-------|
| `columns.cfm` available_fields | camelCase | UI dropdown values |
| `recompute.cfm` fieldNameMap | camelCase (identity) | target_key stored in DB |
| `import_v3_facts.field_name` | camelCase | Written by recompute and fact_update |
| `import_v3_columns.target_key` | camelCase | Written by recompute mapping phase |
| `buildContactDataFromFacts` | Both (dual case switch) | Read path -- accepts either |
| `renderRows` JS | Both (getVal fallback) | Read path -- tries both |
| `recomputeFullName` service | camelCase | Queries `firstName`, `lastName` |
| `saveEdit` JS | camelCase | Sends form field names as-is |

## Remediation for existing jobs

Jobs parsed before this fix may have snake_case `field_name` values.
To normalize a single job:

```
POST /ajax/importv3/normalize_fact_fieldnames.cfm?job_id=123
```

Requires `session.isAdmin = true`. Idempotent.

## Regression check

```
GET /scripts/dev/importv3_regression_check.cfm?job_id=123
GET /scripts/dev/importv3_regression_check.cfm?job_id=123&format=json
```

Reports per-field counts of snake_case vs camelCase. Requires admin session.
