# Audition Import Module - Review

**Date:** 2026-03-12
**Status:** Feature-complete (code written), not yet deployed/tested end-to-end

---

## Architecture Summary

A 4-phase audition import system ported from Contact Import V3:

1. **Upload** - File validation, SHA-256 dedup, staging
2. **Parse & Map** - Auto-column mapping with confidence scoring, EAV fact storage
3. **Review & Fix** - Validation, duplicate detection, inline editing, row actions
4. **Finalize** - Per-row transactional insert into production `auditions` table

Design patterns: staging-first, EAV facts, in-memory dupe index, per-row transactions, idempotent finalization, status-transition locking, CSRF + ownership enforcement on all writes.

---

## File Inventory

### Pages & Templates
| File | Lines | Status |
|------|-------|--------|
| `app/auditions-import/index.cfm` | ~696 | Complete |
| `include/import-auditions-v3.cfm` | ~700 | Complete |

### Services
| File | Lines | Status |
|------|-------|--------|
| `services/AuditionImportService.cfc` | 1614 | Complete |
| `services/AuditionDuplicateMatcherService.cfc` | 369 | Complete |
| `services/ImportAuditionsLogger.cfc` | 216 | Complete |

### AJAX Endpoints (11 total)
| Endpoint | Method | Purpose | Status |
|----------|--------|---------|--------|
| `ajax/import-auditions/upload.cfm` | POST | File upload + hash dedup | Complete |
| `ajax/import-auditions/parse.cfm` | POST | Parse file, auto-map columns | Complete |
| `ajax/import-auditions/columns.cfm` | GET/POST | Read/update column mappings | Complete |
| `ajax/import-auditions/recompute.cfm` | POST | Validate rows + detect dupes | Complete |
| `ajax/import-auditions/rows.cfm` | GET | Paginated row listing + stats | Complete |
| `ajax/import-auditions/row.cfm` | GET | Single row detail with facts | Complete |
| `ajax/import-auditions/row_action.cfm` | POST | Set row action (ignore/create) | Complete |
| `ajax/import-auditions/fact_update.cfm` | POST | Edit fact values, revalidate | Complete |
| `ajax/import-auditions/finalize.cfm` | POST | Create auditions from approved rows | Complete |
| `ajax/import-auditions/status.cfm` | POST | Manual status transitions (unstick) | Complete |
| `ajax/import-auditions/history.cfm` | GET | User's import job history | Complete |

### JavaScript
| File | Lines | Status |
|------|-------|--------|
| `app/assets/js/audition-import.js` | 1712 | Complete |

### Database Migrations
| File | Purpose | Status |
|------|---------|--------|
| `database/migrations/A1_0__import_auditions_tables.sql` | 6 staging tables | Written, needs execution |
| `database/migrations/A1_0__import_auditions_tables_ROLLBACK.sql` | Drop all 6 tables | Written |
| `database/migrations/A1_1__import_auditions_indexes.sql` | 5 indexes on production `auditions` table | Written, needs execution |
| `database/migrations/A1_1__import_auditions_indexes_ROLLBACK.sql` | Drop those indexes | Written |
| `database/migrations/A1_2__auditions_import_page_registration.sql` | pgpages registration | Written, needs execution |
| `database/migrations/A1_2__auditions_import_page_registration_ROLLBACK.sql` | Revert pgpages | Written |

### Reference Docs
| File | Purpose |
|------|---------|
| `docs/import-contacts-v3-reference.md` | Blueprint this module was ported from |

---

## What Is Complete (Code-Level)

### Upload Phase
- [x] Drag-drop and file input UI
- [x] CSV, XLS, XLSX file type validation
- [x] 50MB file size limit
- [x] SHA-256 hash-based duplicate file detection
- [x] Job record creation in `import_auditions_jobs`
- [x] File stored to user-specific directory
- [x] Auth check, JSON response envelope

### Parse & Map Phase
- [x] CSV parsing (comma-delimited)
- [x] XLS/XLSX parsing (Apache POI)
- [x] Auto-column mapping with confidence scoring
- [x] Column mapping UI with sample values
- [x] User confirm/adjust column mappings
- [x] EAV fact storage in `import_auditions_facts`
- [x] Raw JSON audit trail per row
- [x] Status transitions: uploaded -> parsing -> parsed -> mapping

### Review Phase
- [x] Recompute endpoint: validates all facts + runs dupe detection
- [x] In-memory dupe index with weighted scoring (date+project=80, date+actor=60, project+role=40, cd+date=30)
- [x] Thresholds: HIGH=70, MEDIUM=40, LOW=25
- [x] Memory guardrails: 100K item index cap, 5s build timeout
- [x] Paginated row grid with 6 tabs (All, Ready, Problems, Duplicates, Ignored, Imported)
- [x] Search/filter across contact_name, project_name, role_name, casting_director
- [x] Stats bar with live counts
- [x] Inline fact editing modal with revalidation
- [x] Duplicate resolution modal with candidate details
- [x] Row actions: ignore (skip) and create (import_new)
- [x] Bulk row actions
- [x] Status transition locking (prevents concurrent recompute/finalize)

### Finalize Phase
- [x] Per-row transaction isolation
- [x] Contact resolution: lookup by email -> full name -> allow null
- [x] INSERT INTO `auditions` with all 15 fields
- [x] All SQL parameterized with `cfqueryparam`
- [x] Idempotency via `import_auditions_row_results` UNIQUE(row_id)
- [x] Failed row retry on re-finalize (resets failed rows to ready)
- [x] Row result audit trail
- [x] Job count updates (imported_rows, skipped_rows)
- [x] Status transitions: reviewing -> finalizing -> completed/failed

### Cross-Cutting
- [x] CSRF protection on all write endpoints (header + body + form fallback)
- [x] Ownership enforcement via WHERE clauses (never post-query IF)
- [x] Structured logging with correlation IDs (ImportAuditionsLogger)
- [x] Debug breadcrumb arrays in all responses
- [x] Feature flag system (global toggle + per-user allowlist)
- [x] Stale lock detection (>10 min warning in UI)
- [x] Manual status transitions to unstick jobs
- [x] Import job history with status badges
- [x] 300-second timeout on recompute

### Audition Fields Supported (15)
contact_name, contact_email, project_name, role_name, casting_director, agency, audition_date, audition_time, callback_date, booking_date, location, medium, status, self_tape, notes

---

## What Can Be Tested Now (Pre-Deploy Checklist)

### A. Static / Code Review Verification
- [ ] All SQL uses `cfqueryparam` - no string concatenation (verified in service layer)
- [ ] All endpoints return JSON with `{success, code, message, data}` envelope
- [ ] No `GETDATE()`, `SELECT TOP`, `IDENTITY`, or other SQL Server syntax (MySQL-only)
- [ ] CSRF token validated on: upload, row_action, fact_update, finalize, status
- [ ] Ownership enforced via WHERE on: all getJobForUser, setRowAction, bulkRowAction, getRowDetail, getRows
- [ ] `ON DUPLICATE KEY UPDATE` used for idempotent row results
- [ ] Feature flag checked before showing UI (index.cfm)

### B. Database (After Running Migrations)
- [ ] Run `A1_0__import_auditions_tables.sql` - verify 6 tables created
- [ ] Run `A1_1__import_auditions_indexes.sql` - verify 5 indexes on `auditions` table
- [ ] Run `A1_2__auditions_import_page_registration.sql` - verify pgpages updated
- [ ] Verify `auditions` production table exists with expected columns (audition_id, userid, contactid, project_name, role_name, casting_director, agency, audition_date, audition_time, location, medium, status, callback_date, booking_date, self_tape, notes)
- [ ] Confirm `contactdetails` table has `contactFullName` and `IsDeleted` columns
- [ ] Confirm `phonebook` table has `type` and `phoneNumber` columns for email lookup

### C. UI Flow Testing (Manual, End-to-End)

#### C1. Upload
- [ ] Navigate to auditions-import page
- [ ] Drag-drop a CSV file - job created, redirects to parse step
- [ ] Upload same file again - DUPLICATE_FILE error shown
- [ ] Upload a .txt file - INVALID_FILE_TYPE error
- [ ] Upload a file >50MB - FILE_TOO_LARGE error
- [ ] Upload XLS file - accepted
- [ ] Upload XLSX file - accepted
- [ ] Verify import history shows new job

#### C2. Parse & Column Mapping
- [ ] After upload, auto-parse begins (status transitions: uploaded -> parsing -> parsed)
- [ ] Column mapping UI appears with detected columns and sample values
- [ ] Auto-mapped columns show confidence scores
- [ ] Can change column mapping via dropdown (audition_field targets: all 15 fields)
- [ ] Can set column intent to "ignore" or "note"
- [ ] Confirm mappings button transitions to review

#### C3. Review Grid
- [ ] Stats bar shows correct counts (Total, Ready, Problems, Duplicates)
- [ ] Tab filtering works (All, Ready, Problems, Duplicates, Ignored)
- [ ] Pagination works (default 50 per page)
- [ ] Search filters rows by contact_name, project_name, role_name, casting_director
- [ ] Click row opens detail/edit modal
- [ ] Can edit individual fact values in modal
- [ ] Editing a fact triggers revalidation of that row
- [ ] Row action buttons: Ignore and Create work
- [ ] Bulk select + bulk action works

#### C4. Duplicate Resolution
- [ ] Rows with dupe score >= 70 flagged as "dupe" status
- [ ] Duplicate modal shows candidate matches with scores and reasons
- [ ] Can choose "Import as New" on a dupe row
- [ ] Can choose "Ignore" on a dupe row
- [ ] Refresh validation re-runs dupe detection

#### C5. Finalize
- [ ] Finalize button enabled when ready rows exist
- [ ] Finalize creates audition records in production table
- [ ] Imported rows show in "Imported" tab
- [ ] Contact resolution: rows with matching email find existing contact
- [ ] Contact resolution: rows with matching full name find existing contact
- [ ] Rows without contact info: audition created with NULL contactid
- [ ] Minimum validation: project_name required (rows without fail)
- [ ] Double-finalize is idempotent (no duplicate auditions)
- [ ] Failed rows reset to "ready" on re-finalize
- [ ] Job transitions to "completed" with summary counts
- [ ] Completion summary screen shows imported/skipped/failed counts

#### C6. Edge Cases & Error Handling
- [ ] Upload while another job is active for user
- [ ] Cancel a job mid-parse (status.cfm transition)
- [ ] Cancel a job mid-finalize
- [ ] Stale lock warning appears after 10 minutes stuck
- [ ] Reset a stuck job back to "reviewing" via status controls
- [ ] Empty CSV (headers only, no data rows)
- [ ] CSV with malformed dates in audition_date field
- [ ] Very large file (1000+ rows) - pagination and performance
- [ ] Session timeout during multi-step flow

### D. API-Level Testing (Direct AJAX Calls)
- [ ] All endpoints return 401 without session
- [ ] All write endpoints return 403 without CSRF token
- [ ] All endpoints return 403 when accessing another user's job
- [ ] All endpoints return 404 for non-existent job_id
- [ ] status.cfm rejects invalid transitions
- [ ] row_action.cfm rejects "update_existing" action (create-only mode)

---

## What Is Left To Do

### Pre-Launch (Required)

1. **Run database migrations** on `new_development` schema
   - Execute A1_0, A1_1, A1_2 in order
   - Verify `auditions` production table exists with expected schema
   - If `auditions` table does not exist yet, a CREATE TABLE migration is needed

2. **Set feature flags** in Application.cfm/cfc
   - Set `application.features.auditionImportEnabled = true` (or add test userid to `auditionImportAllowedUsers` array)
   - Feature flag mechanism is coded but flags may not be initialized in Application scope yet

3. **Verify production `auditions` table schema**
   - The finalize INSERT assumes 15 columns: userid, contactid, project_name, role_name, casting_director, agency, audition_date, audition_time, location, medium, status, callback_date, booking_date, self_tape, notes
   - If any columns are missing or named differently, finalize will fail silently per-row

4. **End-to-end smoke test** with a real CSV file
   - Happy path: upload -> parse -> map -> review -> finalize -> verify audition in DB
   - Verify created audition shows up in existing audition views/pages

5. **Verify contact resolution tables**
   - Finalize queries `contactdetails` (contactFullName, IsDeleted) and `phonebook` (type, phoneNumber) for contact matching
   - Confirm these columns exist and contain expected data

### Post-Launch / Enhancements (Not Blocking)

6. **VCF (vCard) file support** - CLAUDE.md contact importer requirements mention VCF but audition import currently only supports CSV/XLS/XLSX. May not be relevant for auditions.

7. **Undo/rollback for finalized imports** - `import_auditions_row_results` has `undo_available`, `undo_json`, `undone_at` columns but no undo logic is implemented in the service layer.

8. **Update-existing mode** - `row_action.cfm` explicitly blocks "update_existing" action. The schema supports it (`import_mode` column, `user_action` enum) but the service only does create-only. Could be a future enhancement.

9. **Relationship system enrollment** - CLAUDE.md mentions `relationship_system` field for enrolling imported contacts into Target/Maintenance systems. Not relevant for audition import but worth noting.

10. **File cleanup/retention** - Uploaded files are stored to disk but there is no cleanup job for old import files. Consider a scheduled task to purge files from completed/cancelled jobs after N days.

11. **Performance testing with large files** - Recompute has a 300-second timeout and the dupe index has a 100K item / 5s build guardrail, but these haven't been validated under real load.

12. **Nav integration** - Verify the auditions-import page is accessible from the app navigation. The pgpages migration (A1_2) updates the registration, but sidebar/menu links may need verification.

13. **Error import service** - An older `AuditionImportErrorService.cfc` exists that writes to `auditionsimport_error`. Determine if this is legacy (from old importer) or if the new module should integrate with it.

---

## Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| `auditions` table schema mismatch | High | Verify columns before first finalize test |
| Feature flags not initialized | Medium | Add to Application.cfm before testing |
| Contact lookup fails silently | Low | Audition created with NULL contactid - acceptable |
| Concurrent finalize race condition | Low | Status-transition locking prevents this |
| Recompute timeout on large files | Medium | 300s limit + dupe index guardrails in place |
| Double-finalize creates duplicates | Low | Idempotent via UNIQUE(row_id) on row_results |

---

## Summary

| Category | Count |
|----------|-------|
| Files written | 20 |
| AJAX endpoints | 11 |
| Service methods | ~30 |
| Database tables (staging) | 6 |
| Performance indexes | 5 |
| Lines of code (approx) | ~5,300 |
| **Code completeness** | **100%** |
| **Deploy readiness** | **~80%** (needs migrations + flags + smoke test) |
