# Phase 1: Contact Import Upgrade - Implementation Guide

**Date:** 2025-11-26
**Status:** Completed
**Phase:** 1 of 5

## Overview

Phase 1 enhances the existing TAO contact import system to support CSV files, provide better validation, and show users a preview before importing. This solves the critical issue of Mac users being unable to use Apple Numbers with the Excel template.

---

## Changes Summary

### 1. **CSV Support Added**
- Users can now upload both `.xlsx` (Excel) and `.csv` files
- CSV parser service handles quoted fields, embedded commas, and various CSV formats
- Template downloads available in both formats

### 2. **Validation Before Import**
- Validates required fields (name and contact method)
- Checks email format
- Validates date formats
- Detects duplicates by name and email

### 3. **Preview Screen**
- Shows summary of what will be imported
- Lists new contacts vs. updates to existing contacts
- Displays validation errors clearly
- Allows user to confirm or cancel before processing

### 4. **Better User Experience**
- Clear error messages
- Mac-friendly templates
- Improved upload UI with both format options
- Real-time file name display

---

## Files Created

### Services
1. **`services/CsvParserService.cfc`**
   - Parses CSV files into ColdFusion query objects
   - Handles quoted fields and embedded commas
   - Validates CSV structure

2. **`services/ContactImportValidationService.cfc`**
   - Validates import data rows
   - Checks for duplicates
   - Provides detailed error reporting

### Database
3. **`database/2025-11-26_create_contact_import_log.sql`**
   - Creates `contact_import_log` table for tracking import results
   - Stores action taken for each row (created/updated/skipped/error)
   - Includes indexes for performance

### Pages
4. **`include/upload_confirm.cfm`**
   - Handles user confirmation after preview
   - Validates session state
   - Redirects to processing

---

## Files Modified

### 1. **`include/download_contact_template.cfm`**
**Changes:**
- Added `format` URL parameter (csv or xlsx)
- Generates CSV templates dynamically
- Includes sample data rows
- Falls back to CSV if Excel template not found

**Usage:**
```
/include/download_contact_template.cfm?format=csv   # CSV format
/include/download_contact_template.cfm?format=xlsx  # Excel format
```

### 2. **`include/upload.cfm`**
**Changes:**
- Detects file extension (.csv or .xlsx)
- Uses CsvParserService for CSV files
- Wraps cfspreadsheet with error handling for Excel files
- Validates import data after parsing
- Redirects to preview if errors or duplicates found

**Flow:**
```
Upload File → Detect Type → Parse → Validate → Preview (if needed) → Process
```

### 3. **`include/import-contacts.cfm`**
**Changes:**
- Added preview mode display
- Shows validation results (errors, duplicates, summary)
- Updated upload form UI
  - Two template download buttons (CSV and Excel)
  - Mac user recommendation
  - Custom file input with name display
  - Accept attribute restricts to .xlsx and .csv

**New Parameters:**
- `url.preview` - triggers preview mode
- `session.pendingImport` - stores validation results

---

## Database Schema

### contact_import_log Table

**Important Database Naming:**
- **Datasource names** (in ColdFusion): `abo` (prod), `abod` (dev), `reach` (primary)
- **Actual database names** (in SQL): `actorsbusinessoffice` (prod), `new_development` (dev)
- SQL scripts should use: `new_development.dbo.tablename` or `actorsbusinessoffice.dbo.tablename`

```sql
CREATE TABLE contact_import_log (
    logid INT IDENTITY(1,1) PRIMARY KEY,
    uploadid INT NOT NULL,
    userid INT NOT NULL,
    row_number INT NULL,
    import_action VARCHAR(50) NULL,    -- 'created', 'updated', 'skipped', 'error'
    error_message VARCHAR(MAX) NULL,
    contactid INT NULL,
    row_data VARCHAR(MAX) NULL,         -- For debugging
    created_at DATETIME DEFAULT GETDATE(),

    FOREIGN KEY (uploadid) REFERENCES uploads(uploadid),
    FOREIGN KEY (userid) REFERENCES taousers(userid)
);
```

**Indexes:**
- `IX_contact_import_log_uploadid`
- `IX_contact_import_log_userid`
- `IX_contact_import_log_action`
- `IX_contact_import_log_created`

---

## User Flow

### Happy Path (No Errors)
1. User navigates to `/app/contacts-import/`
2. Downloads CSV or XLSX template
3. Fills in contact data
4. Uploads file
5. System validates data
6. Preview screen shows summary
7. User clicks "Confirm and Import"
8. Contacts are processed
9. Success message displayed

### Error Path
1. User uploads file with validation errors
2. Preview screen displays:
   - Error count and details
   - Which rows will be skipped
   - Valid rows that will be imported
3. User can:
   - Cancel and fix the file
   - Proceed to import only valid rows

### Duplicate Handling
1. System detects duplicates by:
   - Exact name match
   - Business email match
   - Personal email match
2. Preview shows which contacts will be updated
3. User confirms to proceed
4. Existing contacts updated with new data

---

## Validation Rules

### Required Fields
- **Name:** Must have at least First Name OR Last Name
- **Contact Method:** Must have at least one of:
  - Business Email
  - Personal Email
  - Work Phone
  - Mobile Phone
  - Home Phone

### Format Validation
- **Emails:** Must be valid email format
- **Dates:** Must be valid date format (contactMeetingDate, Birthday)

### Duplicate Detection
Matches are found by:
1. Exact `contactFullName` match (case-sensitive)
2. Business email in `contactitems` (Active status only)
3. Personal email in `contactitems` (Active status only)

---

## Template Columns

Both CSV and XLSX templates use identical column structure:

```
FirstName, LastName, Tag1, Tag2, Tag3, BusinessEmail, PersonalEmail,
WorkPhone, MobilePhone, HomePhone, Company, Address, Address2,
City, State, Zip, Country, contactMeetingDate, contactMeetingLoc,
Birthday, website, Notes
```

**Sample Row:**
```csv
John,Doe,Casting Director,,,john@example.com,johndoe@gmail.com,
(555) 123-4567,(555) 123-4568,,ABC Casting,"123 Main St",Suite 100,
Los Angeles,CA,90001,USA,2025-01-15,Starbucks on Sunset,1985-03-20,
https://example.com,"Met at industry workshop"
```

---

## Testing Checklist

### CSV Upload
- [ ] Download CSV template
- [ ] Open in Apple Numbers (Mac)
- [ ] Open in Excel (Windows/Mac)
- [ ] Open in Google Sheets
- [ ] Fill in sample data
- [ ] Upload and verify parsing
- [ ] Verify all fields map correctly

### XLSX Upload
- [ ] Download Excel template
- [ ] Open in Excel
- [ ] Fill in sample data
- [ ] Upload and verify parsing
- [ ] Verify backward compatibility

### Validation
- [ ] Upload file with missing name → Shows error
- [ ] Upload file with no contact method → Shows error
- [ ] Upload file with invalid email → Shows error
- [ ] Upload file with invalid date → Shows error
- [ ] Upload file with all valid data → No errors

### Duplicate Detection
- [ ] Upload contact with existing name → Shows as update
- [ ] Upload contact with existing email → Shows as update
- [ ] Upload contact with new name/email → Shows as new
- [ ] Verify duplicate contacts link to existing records

### Preview Screen
- [ ] Verify summary counts (new/update/error)
- [ ] Verify error table displays correctly
- [ ] Verify duplicate table displays correctly
- [ ] Verify links to existing contacts work
- [ ] Verify confirm button enabled/disabled correctly

### Error Handling
- [ ] Upload non-.csv/.xlsx file → Clear error message
- [ ] Upload corrupted CSV → Clear error message
- [ ] Upload corrupted XLSX → Clear error message
- [ ] Upload empty file → Appropriate handling

---

## Known Limitations

1. **No field mapping** - Must use exact column names from template
2. **No partial imports** - Errors skip entire row, not just invalid fields
3. **Simple duplicate matching** - Only by exact name or email
4. **No undo** - Once confirmed, import cannot be reversed
5. **Session-based preview** - Preview data stored in session (not persistent)

---

## Backward Compatibility

✅ **Fully backward compatible**

- Existing .xlsx imports work unchanged
- Old template file paths still supported
- `contactsimport` table structure unchanged
- Processing logic in `sched/import-contacts.cfm` untouched
- All QRY includes still functional

---

## Deployment Steps

### Development (new_development database, abod datasource)

1. **Run Database Migration:**
   ```sql
   -- Execute: database/2025-11-26_create_contact_import_log.sql
   -- Against: new_development database
   -- Uncomment: USE new_development;
   ```

2. **Verify Files:**
   - Check all new files uploaded to server
   - Verify services directory has new CFCs
   - Confirm include files updated

3. **Test End-to-End:**
   - Download both CSV and XLSX templates
   - Upload sample data
   - Verify preview displays
   - Confirm import completes

### Production (actorsbusinessoffice database, abo datasource)

1. **Update Migration Script:**
   ```sql
   -- Uncomment: USE actorsbusinessoffice;
   ```

2. **Run Migration:**
   ```sql
   -- Execute script against actorsbusinessoffice database
   ```

3. **Deploy Code:**
   - Upload all modified and new files
   - Verify file permissions

4. **Smoke Test:**
   - Download templates
   - Test CSV upload
   - Test XLSX upload
   - Verify preview works
   - Complete one import

---

## Future Enhancements (Phases 2-5)

### Phase 2: Field Mapping
- Upload any CSV format
- Map columns to TAO fields in UI
- Save mapping presets

### Phase 3: vCard Support
- Import from Apple Contacts (.vcf)
- Parse vCard format

### Phase 4: Google Contacts
- Auto-detect Google CSV format
- Pre-fill field mappings

### Phase 5: OAuth Integration
- Direct Google Contacts sync
- Real-time sync option

---

## Support & Troubleshooting

### Common Issues

**Problem:** CSV file won't parse
**Solution:** Ensure file is UTF-8 encoded, has header row, uses comma delimiters

**Problem:** Excel template won't download
**Solution:** System automatically falls back to CSV. Upload CSV template file to correct location.

**Problem:** All rows showing as errors
**Solution:** Verify column names match template exactly (case-sensitive)

**Problem:** Preview doesn't show
**Solution:** Check session is enabled. Clear browser cache.

### Log Files
- Import errors logged to `contact_import_log` table
- Check `uploadid` to trace specific import
- Review `error_message` column for details

---

## Contact

For questions or issues with Phase 1 implementation:
- Review this documentation
- Check validation service error messages
- Query `contact_import_log` table for details

---

**End of Phase 1 Documentation**
