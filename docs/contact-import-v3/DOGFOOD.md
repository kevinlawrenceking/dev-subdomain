# Contact Import V3 - Dogfood Checklist

## Purpose

This checklist covers 5 real-world import scenarios for testing Contact Import V3 before wider rollout. Each scenario should be completed successfully before enabling global access.

---

## Pre-Flight Checks

Before running dogfood tests:

1. **Feature flag enabled for tester**: Verify user is in allowlist or global flag is ON
2. **V3 tables exist**: Run `SELECT COUNT(*) FROM import_v3_jobs` - should not error
3. **Admin dashboard accessible**: `/app/admin-import-v3/index.cfm` loads
4. **Test data prepared**: Have sample files ready for each scenario

---

## Scenario 1: Basic CSV Import (Happy Path)

**Goal**: Verify end-to-end flow with clean data

**Test File**: `test_basic_10contacts.csv`
```csv
First Name,Last Name,Email,Phone
John,Smith,john.smith@example.com,555-0101
Jane,Doe,jane.doe@example.com,555-0102
...
```

**Steps**:
1. Navigate to Import V3 upload page
2. Upload CSV file
3. Verify parsing completes (status: parsed)
4. Confirm auto-mapped columns (first_name, last_name, email, phone)
5. Review rows - all should show "Ready"
6. Click Finalize
7. Verify contacts created in TAO

**Expected Results**:
- [ ] Upload completes in < 5 seconds
- [ ] All 10 columns auto-mapped correctly
- [ ] No validation errors
- [ ] Finalize creates 10 contacts
- [ ] Dashboard shows job as "completed"

**Diagnostics Query**:
```
/ajax/importv3/diagnostics.cfm?job_id=XXX
```

---

## Scenario 2: Excel with Validation Errors

**Goal**: Verify validation catches bad data and allows row-level fixes

**Test File**: `test_validation_errors.xlsx`
- Row 1: Valid contact
- Row 2: Invalid email format (missing @)
- Row 3: Invalid phone (letters)
- Row 4: Missing required first name
- Row 5: Valid contact

**Steps**:
1. Upload XLSX file
2. Complete column mapping
3. Navigate to Problems tab
4. Verify 3 rows show validation errors with correct messages
5. Edit row 2 - fix email
6. Edit row 3 - fix phone
7. Edit row 4 - add first name
8. Verify all rows now show "Ready"
9. Finalize

**Expected Results**:
- [ ] Parser handles XLSX format correctly
- [ ] 3 rows flagged with validation errors
- [ ] Error messages are human-readable
- [ ] Inline editing works
- [ ] Fixed rows transition to "Ready"
- [ ] Finalize imports all 5 contacts

---

## Scenario 3: VCF (vCard) from iPhone/iCloud

**Goal**: Verify VCF parsing with Apple-specific quirks

**Test File**: Export 5-10 contacts from iPhone Contacts app as VCF

**Steps**:
1. Export contacts from iPhone to VCF
2. Upload VCF file to Import V3
3. Verify parsing handles:
   - Multi-line addresses
   - Multiple phone numbers (labeled: mobile, work, home)
   - Multiple emails
   - Photo data (should be skipped gracefully)
   - Notes with special characters
4. Map columns appropriately
5. Review and finalize

**Expected Results**:
- [ ] VCF parses without error
- [ ] Multiple phones mapped to separate fields (phone_mobile, phone_work, etc.)
- [ ] Addresses parsed into components
- [ ] Special characters preserved (accents, unicode)
- [ ] Photo data ignored without crashing
- [ ] All contacts imported correctly

---

## Scenario 4: Duplicate Detection and Update Mode

**Goal**: Verify dupe detection and update flow

**Setup**: Create 3 contacts in TAO manually:
1. John Smith - john@example.com
2. Jane Doe - jane@example.com
3. Bob Wilson - bob@example.com

**Test File**: `test_duplicates.csv`
```csv
First Name,Last Name,Email,Phone,Company
John,Smith,john@example.com,555-9999,New Company
Jane,Doe,jane@example.com,555-8888,Another Corp
Alice,New,alice@new.com,555-7777,Fresh Start
```

**Steps**:
1. Upload CSV with import mode "Create and Update"
2. Verify:
   - John and Jane flagged as duplicates (matched by email)
   - Alice shows as new contact
3. Navigate to Duplicates tab
4. For John: Confirm update (phone and company will be added)
5. For Jane: Confirm update
6. Review merged data preview
7. Finalize

**Expected Results**:
- [ ] Dupe detection matches on email
- [ ] Match scores displayed (should be high for exact email match)
- [ ] Existing contact data shown for comparison
- [ ] Update mode merges new fields without overwriting existing
- [ ] New contact (Alice) created
- [ ] Existing contacts updated with new phone/company

---

## Scenario 5: Large File Performance (500+ rows)

**Goal**: Verify performance and pagination at scale

**Test File**: `test_large_500contacts.csv` (500+ valid rows)

**Steps**:
1. Upload large CSV
2. Time the parsing phase
3. Verify pagination in review grid (25 rows per page)
4. Navigate to page 10+
5. Apply filter (e.g., status = ready)
6. Finalize (this may take 30-60 seconds)
7. Monitor progress indicator

**Expected Results**:
- [ ] Parsing completes in < 30 seconds
- [ ] Review grid loads quickly with pagination
- [ ] Pagination controls work correctly
- [ ] Filters apply correctly
- [ ] Finalize completes without timeout
- [ ] Progress indicator updates during finalize
- [ ] All rows imported (check imported_rows count)

**Performance Benchmarks**:
- Parsing: < 1 second per 100 rows
- Review grid load: < 2 seconds per page
- Finalize: < 0.5 seconds per row

---

## Post-Dogfood Checklist

After completing all scenarios:

1. **Review admin dashboard**:
   - [ ] All jobs show correct status
   - [ ] Row counts match expected
   - [ ] No failed jobs (unless expected)

2. **Verify created contacts**:
   - [ ] Spot-check 5 random contacts in TAO
   - [ ] All fields populated correctly
   - [ ] Relationship system enrolled (if configured)

3. **Run diagnostics on each job**:
   - [ ] No orphaned rows (rows without job)
   - [ ] No orphaned facts (facts without row)
   - [ ] Event log shows complete lifecycle

4. **Document any issues**:
   - Use BUG_TEMPLATE.md for each issue found
   - Include job_id and diagnostics output

---

## Known Limitations (Expected Behaviors)

1. **VCF photos**: Skipped by design - photos should not error
2. **Excel formulas**: Evaluated values imported, not formulas
3. **Merged cells**: May cause column misalignment - document in user guide
4. **Very long text**: Truncated to field max lengths with warning

---

## Rollout Decision

| Scenario | Tester | Pass/Fail | Notes |
|----------|--------|-----------|-------|
| 1. Basic CSV | | | |
| 2. Validation Errors | | | |
| 3. VCF Import | | | |
| 4. Duplicate Detection | | | |
| 5. Large File | | | |

**Rollout Approved**: [ ] Yes / [ ] No

**Approver**: ________________  **Date**: ________________
