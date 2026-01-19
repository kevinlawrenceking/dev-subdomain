# Contact Import V3 - Production Dogfood Run Log

**Run Date**: 2026-01-19
**Tester**: Kev
**Environment**: Production (app.theactorsoffice.com)

---

## Pre-Flight Verification

### Feature Flag State

**Verification Method**: Database queries on production

```sql
-- Global flag status
SELECT flag_key, is_enabled, description, updated_at
FROM feature_flags
WHERE flag_key = 'import_v3_enabled';

-- Allowlist users
SELECT ffu.userid, ffu.is_enabled, ffu.notes, ffu.created_at, u.userfirstname, u.userlastname
FROM feature_flag_users ffu
JOIN users u ON ffu.userid = u.userid
WHERE ffu.flag_key = 'import_v3_enabled';
```

**Expected State**:
| Check | Expected | Actual | Status |
|-------|----------|--------|--------|
| Global flag `import_v3_enabled` | `is_enabled = 0` (OFF) | _pending_ | [ ] |
| Kev in allowlist | `is_enabled = 1` (ON) | _pending_ | [ ] |
| Non-allowlisted user blocked | Cannot access V3 UI/endpoints | _pending_ | [ ] |

### V3 Tables Exist

```sql
SELECT COUNT(*) as job_count FROM import_v3_jobs;
SELECT COUNT(*) as row_count FROM import_v3_rows;
-- Should not error; counts may be 0 or higher
```

**Result**: _pending_

### Admin Dashboard Accessible

**URL**: `/app/admin-import-v3/index.cfm`

**Result**: _pending_

---

## Scenario 1: Basic CSV Import (Happy Path)

### Test File
- **Filename**: `test_basic_10contacts.csv`
- **Type**: CSV
- **Row Count**: 10
- **Description**: Clean data, all fields valid

### Job Information
- **Job ID**: _pending_
- **Created At**: _pending_
- **Diagnostics URL**: `/ajax/importv3/diagnostics.cfm?job_id=XXX`

### Column Mapping
| Source Column | Mapped Field | Auto-Detected | Confidence |
|---------------|--------------|---------------|------------|
| First Name | first_name | _pending_ | _pending_ |
| Last Name | last_name | _pending_ | _pending_ |
| Email | email | _pending_ | _pending_ |
| Phone | phone | _pending_ | _pending_ |

### Recompute Results
| Metric | Count |
|--------|-------|
| Total Rows | _pending_ |
| Ready | _pending_ |
| Problem | _pending_ |
| Duplicate | _pending_ |
| Ignored | _pending_ |

### Finalize Results
| Metric | Count |
|--------|-------|
| Created | _pending_ |
| Updated | _pending_ |
| Skipped | _pending_ |
| Errors | _pending_ |

### Diagnostics Capture
**Saved to**: `docs/contact-import-v3/diagnostics/job_XXX.json`

### Performance Notes
- Upload time: _pending_
- Parse time: _pending_
- Recompute time: _pending_
- Finalize time: _pending_

### Pass/Fail
- [ ] Upload completes in < 5 seconds
- [ ] All columns auto-mapped correctly
- [ ] No validation errors
- [ ] Finalize creates 10 contacts
- [ ] Dashboard shows job as "completed"

### Bugs Filed
_None_ or _See BUG_XXX_slug.md_

---

## Scenario 2: Excel with Validation Errors

### Test File
- **Filename**: `test_validation_errors.xlsx`
- **Type**: XLSX
- **Row Count**: 5
- **Description**: 3 rows with validation errors (bad email, bad phone, missing first name)

### Job Information
- **Job ID**: _pending_
- **Created At**: _pending_
- **Diagnostics URL**: `/ajax/importv3/diagnostics.cfm?job_id=XXX`

### Column Mapping
| Source Column | Mapped Field | Auto-Detected | Confidence |
|---------------|--------------|---------------|------------|
| _pending_ | _pending_ | _pending_ | _pending_ |

### Recompute Results (Before Edits)
| Metric | Count |
|--------|-------|
| Total Rows | 5 |
| Ready | _pending_ (expected: 2) |
| Problem | _pending_ (expected: 3) |
| Duplicate | _pending_ |
| Ignored | _pending_ |

### Validation Errors Found
| Row | Field | Error Code | Message |
|-----|-------|------------|---------|
| 2 | email | _pending_ | _pending_ |
| 3 | phone | _pending_ | _pending_ |
| 4 | first_name | _pending_ | _pending_ |

### Inline Edits Performed
| Row | Field | Original | Corrected |
|-----|-------|----------|-----------|
| 2 | email | _pending_ | _pending_ |
| 3 | phone | _pending_ | _pending_ |
| 4 | first_name | _pending_ | _pending_ |

### Recompute Results (After Edits)
| Metric | Count |
|--------|-------|
| Ready | _pending_ (expected: 5) |
| Problem | _pending_ (expected: 0) |

### Finalize Results
| Metric | Count |
|--------|-------|
| Created | _pending_ |
| Updated | _pending_ |
| Skipped | _pending_ |
| Errors | _pending_ |

### Diagnostics Capture
**Saved to**: `docs/contact-import-v3/diagnostics/job_XXX.json`

### Pass/Fail
- [ ] Parser handles XLSX format correctly
- [ ] 3 rows flagged with validation errors
- [ ] Error messages are human-readable
- [ ] Inline editing works
- [ ] Fixed rows transition to "Ready"
- [ ] Finalize imports all 5 contacts

### Bugs Filed
_None_ or _See BUG_XXX_slug.md_

---

## Scenario 3: VCF (vCard) from iPhone/iCloud

### Test File
- **Filename**: _pending_ (export from iPhone)
- **Type**: VCF
- **Row Count**: _pending_ (5-10 contacts)
- **Description**: Apple vCard export with multiple phones, addresses, notes

### Job Information
- **Job ID**: _pending_
- **Created At**: _pending_
- **Diagnostics URL**: `/ajax/importv3/diagnostics.cfm?job_id=XXX`

### VCF Parsing Details
| Feature | Handled Correctly | Notes |
|---------|-------------------|-------|
| Multi-line addresses | _pending_ | |
| Multiple phones (mobile/work/home) | _pending_ | |
| Multiple emails | _pending_ | |
| Photo data (should skip) | _pending_ | |
| Notes with special chars | _pending_ | |
| Unicode/accents | _pending_ | |

### Column Mapping
| Source Column | Mapped Field | Notes |
|---------------|--------------|-------|
| _pending_ | _pending_ | _pending_ |

### Recompute Results
| Metric | Count |
|--------|-------|
| Total Rows | _pending_ |
| Ready | _pending_ |
| Problem | _pending_ |
| Duplicate | _pending_ |
| Ignored | _pending_ |

### Finalize Results
| Metric | Count |
|--------|-------|
| Created | _pending_ |
| Updated | _pending_ |
| Skipped | _pending_ |
| Errors | _pending_ |

### Diagnostics Capture
**Saved to**: `docs/contact-import-v3/diagnostics/job_XXX.json`

### Pass/Fail
- [ ] VCF parses without error
- [ ] Multiple phones mapped to separate fields
- [ ] Addresses parsed into components
- [ ] Special characters preserved
- [ ] Photo data ignored without crashing
- [ ] All contacts imported correctly

### Bugs Filed
_None_ or _See BUG_XXX_slug.md_

---

## Scenario 4: Duplicate Detection and Update Mode

### Setup: Pre-existing Contacts
Create these contacts in TAO before running:
| First Name | Last Name | Email |
|------------|-----------|-------|
| John | Smith | john@example.com |
| Jane | Doe | jane@example.com |
| Bob | Wilson | bob@example.com |

**Setup Completed**: [ ] Yes / [ ] No

### Test File
- **Filename**: `test_duplicates.csv`
- **Type**: CSV
- **Row Count**: 3
- **Import Mode**: `create_and_update`

```csv
First Name,Last Name,Email,Phone,Company
John,Smith,john@example.com,555-9999,New Company
Jane,Doe,jane@example.com,555-8888,Another Corp
Alice,New,alice@new.com,555-7777,Fresh Start
```

### Job Information
- **Job ID**: _pending_
- **Created At**: _pending_
- **Diagnostics URL**: `/ajax/importv3/diagnostics.cfm?job_id=XXX`

### Recompute Results
| Metric | Count |
|--------|-------|
| Total Rows | 3 |
| Ready (New) | _pending_ (expected: 1 - Alice) |
| Duplicate | _pending_ (expected: 2 - John, Jane) |
| Problem | _pending_ (expected: 0) |

### Duplicate Detection Details
| Import Row | Matched Contact | Match Field | Match Score | Action |
|------------|-----------------|-------------|-------------|--------|
| John Smith | _pending_ | email | _pending_ | Update |
| Jane Doe | _pending_ | email | _pending_ | Update |

### Update Preview (John Smith)
| Field | Existing Value | Import Value | Will Update |
|-------|----------------|--------------|-------------|
| phone | _pending_ | 555-9999 | _pending_ |
| company | _pending_ | New Company | _pending_ |

### Update Preview (Jane Doe)
| Field | Existing Value | Import Value | Will Update |
|-------|----------------|--------------|-------------|
| phone | _pending_ | 555-8888 | _pending_ |
| company | _pending_ | Another Corp | _pending_ |

### Finalize Results
| Metric | Count |
|--------|-------|
| Created | _pending_ (expected: 1 - Alice) |
| Updated | _pending_ (expected: 2 - John, Jane) |
| Skipped | _pending_ |
| Errors | _pending_ |

### Post-Finalize Verification
| Contact | Phone After | Company After | Verified |
|---------|-------------|---------------|----------|
| John Smith | 555-9999 | New Company | [ ] |
| Jane Doe | 555-8888 | Another Corp | [ ] |
| Alice New | 555-7777 | Fresh Start | [ ] |

### Diagnostics Capture
**Saved to**: `docs/contact-import-v3/diagnostics/job_XXX.json`

### Pass/Fail
- [ ] Dupe detection matches on email
- [ ] Match scores displayed
- [ ] Existing contact data shown for comparison
- [ ] Update mode merges new fields correctly
- [ ] New contact (Alice) created
- [ ] Existing contacts updated with new phone/company

### Bugs Filed
_None_ or _See BUG_XXX_slug.md_

---

## Scenario 5: Large File Performance (500+ rows)

### Test File
- **Filename**: `test_large_500contacts.csv`
- **Type**: CSV
- **Row Count**: 500+
- **Description**: Large file for performance testing

### Job Information
- **Job ID**: _pending_
- **Created At**: _pending_
- **Diagnostics URL**: `/ajax/importv3/diagnostics.cfm?job_id=XXX`

### Performance Metrics
| Phase | Time (seconds) | Benchmark | Pass |
|-------|----------------|-----------|------|
| Upload | _pending_ | N/A | [ ] |
| Parsing | _pending_ | < 5s (500 rows) | [ ] |
| Review grid load | _pending_ | < 2s per page | [ ] |
| Finalize | _pending_ | < 250s (0.5s/row) | [ ] |

### Pagination Testing
| Test | Result |
|------|--------|
| Default page size (25 rows) | _pending_ |
| Navigate to page 10 | _pending_ |
| Navigate to last page | _pending_ |
| Page controls responsive | _pending_ |

### Filter Testing
| Filter | Result |
|--------|--------|
| Status = ready | _pending_ |
| Status = problem | _pending_ |
| Clear filters | _pending_ |

### Recompute Results
| Metric | Count |
|--------|-------|
| Total Rows | _pending_ |
| Ready | _pending_ |
| Problem | _pending_ |
| Duplicate | _pending_ |
| Ignored | _pending_ |

### Finalize Results
| Metric | Count |
|--------|-------|
| Created | _pending_ |
| Updated | _pending_ |
| Skipped | _pending_ |
| Errors | _pending_ |

### Progress Indicator
- [ ] Progress indicator visible during finalize
- [ ] Progress updates as rows process
- [ ] No timeout errors

### Diagnostics Capture
**Saved to**: `docs/contact-import-v3/diagnostics/job_XXX.json`

### Pass/Fail
- [ ] Parsing completes in < 30 seconds
- [ ] Review grid loads quickly with pagination
- [ ] Pagination controls work correctly
- [ ] Filters apply correctly
- [ ] Finalize completes without timeout
- [ ] Progress indicator updates during finalize
- [ ] All rows imported (check imported_rows count)

### Bugs Filed
_None_ or _See BUG_XXX_slug.md_

---

## Post-Dogfood Summary

### Overall Results
| Scenario | Pass/Fail | Bugs Filed | Notes |
|----------|-----------|------------|-------|
| 1. Basic CSV | _pending_ | _pending_ | |
| 2. Validation Errors | _pending_ | _pending_ | |
| 3. VCF Import | _pending_ | _pending_ | |
| 4. Duplicate Detection | _pending_ | _pending_ | |
| 5. Large File | _pending_ | _pending_ | |

### Diagnostics Files Created
- [ ] `docs/contact-import-v3/diagnostics/job_XXX.json` (Scenario 1)
- [ ] `docs/contact-import-v3/diagnostics/job_XXX.json` (Scenario 2)
- [ ] `docs/contact-import-v3/diagnostics/job_XXX.json` (Scenario 3)
- [ ] `docs/contact-import-v3/diagnostics/job_XXX.json` (Scenario 4)
- [ ] `docs/contact-import-v3/diagnostics/job_XXX.json` (Scenario 5)

### Bug Summary
| Bug ID | Scenario | Severity | Summary |
|--------|----------|----------|---------|
| _pending_ | _pending_ | _pending_ | _pending_ |

### Rollout Decision
- [ ] **APPROVED** - All scenarios pass, ready for global rollout
- [ ] **NOT APPROVED** - Blocking issues found (see bugs)

**Approver**: ________________
**Date**: ________________

---

## Execution Instructions (Manual Steps Required)

This dogfood run requires manual execution through the production web UI. Claude Code cannot execute browser-based tests programmatically.

### For Each Scenario:

1. **Log into production** as Kev (allowlisted user)
2. **Navigate to Import V3 UI**
3. **Upload the test file** for the scenario
4. **Complete the import workflow**:
   - Wait for parsing
   - Review/confirm column mappings
   - For validation scenarios: navigate to Problems tab and fix issues
   - For duplicate scenarios: review Duplicates tab and confirm updates
   - Click Finalize
5. **Note the job_id** from the URL or UI
6. **Capture diagnostics**:
   ```
   GET /ajax/importv3/diagnostics.cfm?job_id=<job_id>
   ```
7. **Save the JSON response** to `docs/contact-import-v3/diagnostics/job_<job_id>.json`
8. **Update this log** with results
9. **File bugs** if any issues using `docs/contact-import-v3/BUG_TEMPLATE.md`
