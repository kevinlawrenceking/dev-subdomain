# Contact Import V3 - Next Steps

**Created:** 2026-02-15
**Based on:** Full codebase review of Phases 1-9

---

## Current State Summary

Nine phases of engineering are complete. The full import flow is built:
upload -> parse -> map columns -> recompute/validate -> review rows -> finalize.

All endpoints have auth, CSRF, status gates, debug breadcrumbs, JSON responses, and proper HTTP status codes. The in-memory dupe index reduces duplicate detection to ~3 queries per job. Finalize uses per-row transactions with idempotency via `import_v3_row_results`.

**The critical gap: none of this has been tested end-to-end through the actual UI.** The dogfood run log (`DOGFOOD_RUN_LOG.md`) is entirely empty -- every field shows `_pending_`. All 9 phases were built and documented but never validated with real user interaction.

### What's Solid (No Rework Needed)

- Database schema (EAV pattern, all tables, indexes designed)
- Security (auth, CSRF belt+suspenders, status gates, access control)
- Concurrency (job locking, double-click prevention, idempotent finalize)
- Performance architecture (in-memory dupe index, batch fact loading, O(1) lookups)
- Debug/observability (breadcrumbs, elapsed_ms, metrics on every endpoint)
- jQuery noConflict safety and bounded init timing
- Feature flag gating system

---

## Sprint A: Validate What Exists

**Goal:** Prove the current code actually works before building anything new.
**Priority:** BLOCKING -- nothing else matters until this passes.

### A1. Apply V3_2 Migration to Dev

Run the dupe detection index migration on the dev database.

**Files:**
- `database/migrations/V3_2__contact_import_v3_dupe_indexes.sql`

**Steps:**
1. Run migration against `new_development`
2. Verify indexes created:
   ```sql
   SHOW INDEX FROM contactdetails_tbl WHERE Key_name LIKE '%dupe_v3%';
   SHOW INDEX FROM contactitems_tbl WHERE Key_name LIKE '%dupe_v3%' OR Key_name LIKE '%category_status%';
   ```
3. Run EXPLAIN queries from `PHASE8_RELEASE_CHECKLIST.md` Section C
4. Confirm no `type = ALL` or `key = NULL`

**Done when:** Three indexes exist, EXPLAIN plans show `ref` or `range` type.

---

### A2. Run Happy-Path Dogfood (Scenario 1)

Walk through the full import flow in the dev UI with a 10-row CSV.

**Test file:** `docs/contact-import-v3/test_data/test_basic_10contacts.csv`

**Steps:**
1. Log in as allowlisted user on dev
2. Navigate to V3 import UI
3. Upload CSV
4. Verify parse detects columns and rows
5. Review column mappings, confirm
6. Verify recompute returns stats (watch for the hang that was documented in Phase 1)
7. Review rows in grid -- check tabs (All/Ready/Problems/Duplicates)
8. Click Finalize
9. Verify contacts created in `contactdetails_tbl`

**Record results in:** `DOGFOOD_RUN_LOG.md` Scenario 1

**Done when:** 10 contacts exist in the database with correct names/emails/phones.

**If recompute hangs:** Check ColdFusion logs. The Phase 1 documented failure (no response from recompute) was suspected to be missing tables or query timeouts. The Phase 4 in-memory index should have resolved this, but it's never been verified.

---

### A3. Run Validation Error Dogfood (Scenario 2)

**Test file:** `docs/contact-import-v3/test_data/test_validation_errors.csv`

**Steps:**
1. Upload and parse
2. Recompute -- expect some rows flagged as `problem`
3. Navigate to Problems tab
4. Use inline editing to fix a bad email/phone
5. Verify row transitions from `problem` to `ready`
6. Finalize remaining rows

**Done when:** Problem rows show clear error messages, inline editing works, fixed rows import successfully.

---

### A4. Run Duplicate Detection Dogfood (Scenario 4)

**Test file:** `docs/contact-import-v3/test_data/test_duplicates.csv`

**Prerequisite:** Create 2-3 contacts manually in TAO with matching emails.

**Steps:**
1. Upload CSV with rows that match existing contacts
2. Recompute -- expect some rows flagged as `dupe`
3. Navigate to Duplicates tab
4. Verify duplicate modal shows matched contact and match reasons
5. Set action to `ignore` on dupes
6. Finalize non-dupe rows only

**Done when:** Dupes detected correctly, user can skip them, non-dupes import fine.

---

### A5. Fix Bugs Found During Dogfood

This is a placeholder. Based on 9 phases of untested code, expect bugs. Common suspects:

- recompute.cfm hanging or timing out
- JS errors in review grid rendering
- Column mapping auto-detection not matching expected fields
- Finalize not writing all contact item types correctly
- Stats counts drifting from actual row counts

**Done when:** All Scenario 1/2/4 bugs are fixed and re-tested.

---

## Sprint B: Fill Feature Gaps

**Goal:** Reach feature parity with V1/V2 on the requirements that CLAUDE.md specifies.
**Priority:** Required before production release.
**Depends on:** Sprint A passing.

### B1. Wire VCF Support into V3

The `FileParserService.parseVCF()` method exists and works. The V3 `parse.cfm` endpoint explicitly blocks VCF with `UNSUPPORTED_FILE_TYPE`. Remove the block and integrate.

**Files to change:**
- `ajax/importv3/parse.cfm` -- Remove VCF block (~line 172-175), route to `FileParserService.parseVCF()`
- May need to normalize VCF parsed output to match the row/fact structure V3 expects

**Test with:** `docs/contact-import-v3/test_data/sample_vcard.vcf` and `tests/fixtures/test_apple.vcf`

**Acceptance:**
- Upload a `.vcf` file -> parses without error
- Multiple phones/emails map to separate columns
- Addresses parsed into components
- Photo data ignored without crashing
- Finalize creates contacts with correct data

**Done when:** VCF import works end-to-end in the dev UI.

---

### B2. Wire Relationship System Enrollment into Finalize

V1's `sched/import-contacts.cfm` enrolls contacts into Target/Maintenance systems after import. V3 has the `relationship_system_default` column on `import_v3_jobs` but finalize doesn't use it.

**Files to change:**
- `services/ContactImportV3Service.cfc` -- `processRowForImport()` method. After creating the contact, check `job.relationship_system_default` and enroll via the relationship system tables (`fusystemusers`, `funotifications`, etc.)

**Research first:**
- Trace how V1 (`sched/import-contacts.cfm`) does enrollment
- Trace how the relationship system enrollment works in the existing TAO codebase (look at how contacts are enrolled manually through the UI)
- Understand the `fusystems`, `fusystemusers`, `fuactions`, `actionusers`, `funotifications` tables

**Acceptance:**
- Import a CSV with relationship_system field set
- After finalize, contacts appear in the specified system
- Notifications are created per the system's action schedule

**Done when:** Imported contacts show up in relationship system views.

---

### B3. Import History UI

The `ajax/importv3/history.cfm` endpoint exists. Add a link/tab in the import UI so users can see past imports.

**Files to change:**
- `include/import-contacts-v3.cfm` -- Add "Import History" tab or link
- `app/assets/js/contact-import-v3.js` -- Add AJAX call to load history, render table

**Acceptance:**
- User can see list of past import jobs with status, row counts, date
- User can click a completed job to see summary (imported/skipped/failed counts)

---

## Sprint C: Update-Existing Mode

**Goal:** Allow users to update existing contacts from import files, not just create new ones.
**Priority:** Important but can ship V3 without it initially.
**Depends on:** Sprint B.

### C1. Enable Update Action in row_action.cfm

Currently returns `UPDATE_NOT_SUPPORTED`. Remove the block and wire the `update_existing` action.

**Files:**
- `ajax/importv3/row_action.cfm` -- Remove UPDATE_NOT_SUPPORTED guard
- `services/ContactImportV3Service.cfc` -- `setRowAction()` and `bulkRowAction()` to accept `update_existing`

### C2. Wire preview_update.cfm

The endpoint file exists. Verify it shows field-level diffs between import data and existing contact data.

**Files:**
- `ajax/importv3/preview_update.cfm`
- `app/assets/js/contact-import-v3.js` -- Wire the dupe modal to show update preview

### C3. Wire finalize_update.cfm

The endpoint file exists. Verify it applies updates to existing contacts with safe overwrite rules (respecting `allow_blank_overwrite` setting on the job).

**Files:**
- `ajax/importv3/finalize_update.cfm`
- `services/ContactImportV3Service.cfc` -- Finalize logic for update_existing rows

### C4. Test Full Update Flow

1. Import contacts via V3 (Sprint A)
2. Create a new CSV with updated data for those contacts
3. Upload, parse, recompute -- expect rows marked as `dupe`
4. Set action to `update_existing` on dupe rows
5. Preview the field diffs
6. Finalize updates
7. Verify existing contacts now have updated fields

---

## Sprint D: Production Deployment

**Goal:** Ship V3 to production behind feature flags, then gradual rollout.
**Priority:** After Sprints A and B are validated.

### D1. Apply V3_2 Migration to Production

Follow `PHASE8_RELEASE_CHECKLIST.md` Section A (Production Environment).

- Run during low-traffic window
- Check table sizes first
- Monitor for lock issues during index creation
- Verify indexes created

### D2. Enable Feature Flag for Beta Users

- Verify `feature_flags` table has `import_v3_enabled` row with `is_enabled = 0` (global off)
- Add 1-2 beta users to `feature_flag_users` allowlist
- Confirm beta users see V3 UI, others see V2

### D3. Run Production Smoke Tests

Follow `PHASE8_RELEASE_CHECKLIST.md` Section G (Smoke Tests).

- Upload small CSV (5 rows)
- Parse, map, recompute, review, finalize
- Verify contacts created
- Check CF logs for errors

### D4. Run Production E2E Evidence

Fill in `PHASE9_PROD_PROOF.md` with actual production results:
- Schema verification (views vs base tables)
- EXPLAIN query results
- E2E smoke test evidence
- Concurrency test evidence

### D5. Monitor and Expand

- Monitor for 24-48 hours (health check queries in `PHASE9_PROD_PROOF.md` Section F)
- Check for stuck jobs, orphan rows, count mismatches
- If clean, enable feature flag globally
- Retire V2 import UI (keep code for rollback)

---

## Sprint E: Polish and Cleanup

**Goal:** Quality-of-life improvements and tech debt.
**Priority:** After production is stable.

### E1. Fix V1 Legacy SQL Injection

`sched/import-contacts.cfm` uses string interpolation in SQL queries. Replace with `cfqueryparam`. This is a security issue even if V1 is being deprecated.

### E2. Custom Fields Support

The schema exists (`contact_custom_fields` table, `import_v3_columns.is_custom_field`). Build UI for users to define custom fields and map import columns to them.

### E3. Undo Capability

`import_v3_row_results` has `undo_available`, `undo_json`, `undone_at` columns. Build an undo endpoint that deletes created contacts and reverses the import for a given job.

### E4. Progress Streaming

For large imports (500+ rows), the recompute and finalize steps can take 15-90 seconds. Add progress reporting (polling or SSE) so the UI shows a progress bar.

### E5. Large File Performance Validation

Run `test_large_500contacts.csv` through the full flow. Capture timing metrics and compare against Phase 8 thresholds:

| Operation | Target | Max |
|-----------|--------|-----|
| recompute (500 rows) | < 15s | 30s |
| rows.cfm (page of 50) | < 1s | 3s |
| finalize (500 rows) | < 45s | 90s |

### E6. Retire V1 and V2

Once V3 is stable in production:
- Remove `include/import-contacts_old.cfm` (V1 UI)
- Remove `sched/import-contacts.cfm` (V1 scheduler)
- Archive `services/ContactImportService.cfc` (V1 service)
- Keep V2 code but remove UI links (safety net for rollback)

---

## File Reference

| Category | Key Files |
|----------|-----------|
| V3 Service | `services/ContactImportV3Service.cfc` |
| V3 Dupe Service | `services/DuplicateMatcherService.cfc` |
| V3 File Parser | `services/FileParserService.cfc` |
| V3 UI Template | `include/import-contacts-v3.cfm` |
| V3 JavaScript | `app/assets/js/contact-import-v3.js` |
| V3 Endpoints | `ajax/importv3/*.cfm` |
| V3 Schema | `database/migrations/V3_0__contact_import_v3_tables.sql` |
| V3 Indexes | `database/migrations/V3_2__contact_import_v3_dupe_indexes.sql` |
| Dogfood Log | `docs/contact-import-v3/DOGFOOD_RUN_LOG.md` |
| Release Checklist | `docs/contact-import-v3/PHASE8_RELEASE_CHECKLIST.md` |
| Prod Proof | `docs/contact-import-v3/PHASE9_PROD_PROOF.md` |
| Project History | `docs/contact-import-v3/PROJECT_STATUS.md` |
| Test Data | `docs/contact-import-v3/test_data/` |

---

## Summary

| Sprint | Items | Effort Estimate | Blocks |
|--------|-------|-----------------|--------|
| A: Validate | 5 items | Testing + bug fixes | Nothing |
| B: Feature Gaps | 3 items | VCF wiring, relationship enrollment, history UI | Sprint A |
| C: Update Mode | 4 items | Wire existing endpoints, test | Sprint B |
| D: Production | 5 items | Migration, flags, monitoring | Sprints A+B |
| E: Polish | 6 items | Security fix, custom fields, undo, perf | Sprint D |

**The single most important thing to do next is Sprint A2: run the happy-path dogfood through the dev UI.** Everything else follows from knowing whether the current code actually works.
