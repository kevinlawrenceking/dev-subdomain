# Contact Import V3 - Bug Report Template

Use this template when reporting issues with Contact Import V3. Complete all sections to help with faster diagnosis and resolution.

---

## Bug Report

### Summary
<!-- One-line description of the issue -->


### Environment
- **Date/Time**:
- **User ID**:
- **Browser**: (e.g., Chrome 120, Safari 17)
- **File Type**: (csv / xlsx / xls / vcf)
- **File Size**:
- **Row Count**:
- **Import Mode**: (create_only / update_existing / create_and_update)

### Job Information
- **Job ID**:
- **Job Status**:
- **Diagnostics URL**: `/ajax/importv3/diagnostics.cfm?job_id=XXX`

### Steps to Reproduce
1.
2.
3.

### Expected Behavior
<!-- What should have happened -->


### Actual Behavior
<!-- What actually happened -->


### Error Messages
<!-- Copy any error messages shown in UI or console -->
```

```

### Screenshots
<!-- Attach screenshots if applicable -->


---

## Diagnostics Output

<!-- Run diagnostics endpoint and paste JSON output here -->
```json

```

### Key Diagnostics to Check

| Field | Value | Expected | OK? |
|-------|-------|----------|-----|
| job.status | | | |
| counts.rows | | | |
| counts.facts | | | |
| row_status_distribution | | | |
| recent_events (last) | | | |

---

## Additional Context

### File Sample
<!-- If safe to share, attach a sample file or paste first 5 rows (redact PII) -->
```csv

```

### Console Errors
<!-- Open browser DevTools (F12) > Console, paste any red errors -->
```

```

### Network Errors
<!-- Open browser DevTools > Network, filter by "importv3", note any failed requests -->
```

```

---

## Classification

### Severity
- [ ] **Critical**: Import completely broken, data loss risk
- [ ] **High**: Major feature broken, no workaround
- [ ] **Medium**: Feature partially broken, workaround exists
- [ ] **Low**: Minor issue, cosmetic, or edge case

### Category
- [ ] Parsing (file read/parse issues)
- [ ] Validation (field validation incorrect)
- [ ] Mapping (column mapping issues)
- [ ] Duplicate Detection (false positives/negatives)
- [ ] Finalize (import/update failures)
- [ ] UI/UX (display, interaction issues)
- [ ] Performance (slow, timeout)
- [ ] Security (access control, data exposure)

### Reproducibility
- [ ] Always reproducible
- [ ] Intermittent (happens sometimes)
- [ ] One-time (happened once)

---

## For Developers

### Quick Diagnosis SQL

```sql
-- Job overview
SELECT job_id, status, total_rows, parsed_rows, valid_rows,
       problem_rows, dupe_rows, imported_rows, error_message
FROM import_v3_jobs WHERE job_id = XXX;

-- Row status distribution
SELECT status, COUNT(*) as cnt
FROM import_v3_rows WHERE job_id = XXX
GROUP BY status;

-- Recent events
SELECT event_type, event_detail, created_at
FROM import_v3_events WHERE job_id = XXX
ORDER BY created_at DESC LIMIT 10;

-- Validation errors
SELECT r.row_num, f.field_name, f.raw_value, f.validation_code, f.validation_message
FROM import_v3_facts f
JOIN import_v3_rows r ON f.row_id = r.row_id
WHERE r.job_id = XXX AND f.is_valid = 0;
```

### Related Files
- Upload: `ajax/importv3/upload.cfm`
- Parse: `ajax/importv3/parse.cfm`
- Columns: `ajax/importv3/columns.cfm`
- Recompute: `ajax/importv3/recompute.cfm`
- Finalize: `ajax/importv3/finalize.cfm`
- Service: `services/ContactImportV3Service.cfc`

---

## Resolution Tracking

| Field | Value |
|-------|-------|
| Reported By | |
| Reported Date | |
| Assigned To | |
| Fix Version | |
| Resolution | |
| Verified By | |
| Verified Date | |
