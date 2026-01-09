# TAO Contacts Import V2 - Discovery Summary

**Date:** 2026-01-07  
**Purpose:** Gap analysis for completing Import V2 implementation

## 1. Current V2 State (What Exists)

### 1.1 Services Layer

| Service | File | Status |
|---------|------|--------|
| ContactImportV2Service | /services/ContactImportV2Service.cfc | Complete - Job mgmt, row processing, import |
| FileParserService | /services/FileParserService.cfc | Partial - CSV/Excel done, needs VCF |
| ValidationService | /services/ValidationService.cfc | Complete - All field types |
| DuplicateMatcherService | /services/DuplicateMatcherService.cfc | Complete - Scoring algorithm |

### 1.2 AJAX Endpoints (All Complete)

- /ajax/import/upload.cfm - File upload, job creation
- /ajax/import/parse.cfm - Parse file, detect columns
- /ajax/import/columns.cfm - Column mapping management
- /ajax/import/rows.cfm - Paginated row retrieval
- /ajax/import/update-row.cfm - Single row edit
- /ajax/import/row-action.cfm - Set row action (skip/import/update)
- /ajax/import/bulk-action.cfm - Bulk row actions
- /ajax/import/finalize.cfm - Execute import
- /ajax/import/status.cfm - Job status/counts

### 1.3 Database Schema (Complete)

- import_jobs - Job metadata, counts, status
- import_job_rows - Row data, validation, dupe info
- import_job_columns - Column mapping config
- import_job_events - Audit trail
- import_field_mappings - Canonical field definitions
- import_field_aliases - Auto-map patterns for common headers

### 1.4 UI (Complete)

- /include/import-contacts.cfm - Main wizard page
- /assets/js/contact-import-v2.js - JS controller (~1000 lines)
- Review grid with tabs (All/Ready/Problems/Duplicates/Imported)
- Edit modal for row editing
- Duplicate resolution modal

## 2. Gaps to Fill

### 2.1 Critical Gaps

| Gap | Priority | Effort |
|-----|----------|--------|
| VCF (vCard) Parsing | High | 2-3 days |
| File Hash Idempotency | High | 0.5 days |
| Dry-Run Summary | High | 1 day |
| Relationship Enrollment | Critical | 1-2 days |
| Folder Creation | Medium | 0.5 days |
| Google Contacts Preset | Medium | 0.5 days |

### 2.2 Schema Additions Needed

Add to import_jobs table:
- file_hash VARCHAR(64) - SHA-256 for duplicate detection
- count_new INT - Newly created contacts
- count_updated INT - Updated existing contacts

Add index: IX_import_jobs_file_hash (userid, file_hash)

## 3. V1 Logic to Port

### 3.1 Relationship Enrollment

From /sched/import-contacts.cfm:222-284:

1. If maintenance_or_target = "Target":
   - systemtype = "Targeted List"
   - Check if contact has "Casting Director" tag
   - If yes: systemscope = "Casting Director"
   - If no: systemscope = "Industry"
   - Find fusystems by (systemtype, systemscope)
   - Include add_system.cfm to enroll

2. If maintenance_or_target = "Maintenance":
   - systemtype = "Maintenance List"
   - Same scope logic as above
   - Enroll in system

### 3.2 Folder Creation

From /sched/folder_setup.cfm:
- Creates default folder structure for new contact
- Required variables: select_userid, select_contactid

## 4. VCF Parsing Requirements

vCard fields to parse:
- FN -> contactFullName
- N -> firstName, lastName (parse semicolon-separated)
- EMAIL;type=WORK -> email_business
- EMAIL;type=HOME -> email_personal
- TEL;type=WORK -> phone_work
- TEL;type=CELL -> phone_mobile
- TEL;type=HOME -> phone_home
- ORG -> company
- TITLE -> jobTitle
- ADR -> address components
- BDAY -> birthday
- NOTE -> notes
- URL -> website

Recommendation: Pure CFML parser (no Python dependency needed).

## 5. Files to Modify

### Services
- /services/ContactImportV2Service.cfc - Add enrollment, folders, file hash
- /services/FileParserService.cfc - Add VCF parsing

### Endpoints
- /ajax/import/upload.cfm - Add file hash
- /ajax/import/dry-run.cfm (new) - Dry-run summary

### UI
- /include/import-contacts.cfm - Add dry-run step
- /assets/js/contact-import-v2.js - Dry-run display

### Database
- /database/migrations/V2_1__import_v2_enhancements.sql (new)

## 6. Test Requirements

1. VCF import (single, multi-contact, versions 2.1/3.0/4.0)
2. Idempotency (same file warning, modified file OK)
3. Dry-run counts (new/updated/skipped)
4. Relationship enrollment (Target CD, Target Industry, Maintenance)
5. Folder creation for new contacts

## Document History

| Version | Date | Author |
|---------|------|--------|
| 1.0 | 2026-01-07 | tao-manager |
