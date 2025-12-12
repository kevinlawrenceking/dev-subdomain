# Fix: charDescription Length Limit Issue

**Date:** 2025-11-30
**Issue:** Users getting errors when entering long character descriptions
**Status:** ✅ READY TO DEPLOY

---

## Problem

Users are experiencing errors when trying to save audition roles with long character descriptions. The issue occurs in two places:

1. **Database Schema:** The `charDescription` column is likely defined as `VARCHAR(500)` or similar, limiting text to 500 characters
2. **Import Code:** The audition import code has hardcoded `maxlength="500"` limits on the character description field

---

## Solution

This fix involves **both database changes and code changes**:

### 1. Database Changes (SQL)

Run the SQL script to increase column capacity:

**File:** `database/fix_charDescription_length.sql`

**For MySQL/MariaDB:**
```sql
ALTER TABLE audroles
MODIFY COLUMN charDescription TEXT NULL;

ALTER TABLE auditionsimport
MODIFY COLUMN charDescription TEXT NULL;
```

**For MSSQL Server:**
```sql
ALTER TABLE audroles
ALTER COLUMN charDescription VARCHAR(MAX) NULL;

ALTER TABLE auditionsimport
ALTER COLUMN charDescription VARCHAR(MAX) NULL;
```

### 2. Code Changes (ColdFusion)

Two files have been updated to remove the 500-character limit:

**File 1:** `include/upload_audition.cfm`
- **Lines 188-193:** Changed from `cf_sql_varchar maxlength="500"` to `cf_sql_longvarchar`
- Affects: projDescription, charDescription, note fields

**File 2:** `include/upload_audition_back.cfm`
- **Lines 186-191:** Changed from `cf_sql_varchar maxlength="500"` to `cf_sql_longvarchar`
- Affects: projDescription, charDescription, note fields

---

## Deployment Steps

### Step 1: Backup
```bash
# Backup the affected tables before making changes
mysqldump -u username -p database_name audroles auditionsimport > backup_$(date +%Y%m%d).sql
```

### Step 2: Run SQL Migration

**Development (new_development):**
```bash
mysql -u username -p new_development < database/fix_charDescription_length.sql
```

**Production (actorsbusinessoffice):**
```bash
mysql -u username -p actorsbusinessoffice < database/fix_charDescription_length.sql
```

### Step 3: Verify Database Changes
```sql
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME = 'charDescription'
AND TABLE_NAME IN ('audroles', 'auditionsimport');
```

Expected result:
- `audroles.charDescription`: `TEXT` (MySQL) or `VARCHAR(MAX)` (MSSQL)
- `auditionsimport.charDescription`: `TEXT` (MySQL) or `VARCHAR(MAX)` (MSSQL)

### Step 4: Deploy Code Changes

The code changes are already committed to the repository. Deploy via your normal deployment process:

```bash
# Pull latest code
git pull origin cleanup/t1-contacts-qry

# Restart ColdFusion application (if needed)
# Method varies by server setup
```

### Step 5: Test

1. **Create a test audition role** with a very long character description (1000+ characters)
2. **Save and verify** it saves without error
3. **Import auditions** via CSV with long character descriptions
4. **Verify** the import completes successfully

---

## Technical Details

### New Capacity

| Database | Data Type | Max Length |
|----------|-----------|------------|
| MySQL/MariaDB | TEXT | 65,535 characters (~65KB) |
| MSSQL Server | VARCHAR(MAX) | 2GB |

### Code Using CF_SQL_LONGVARCHAR

These files already correctly use `CF_SQL_LONGVARCHAR` (no changes needed):

✅ `services/AuditionRoleService.cfc` (lines 88, 464, 519, 608, 652)
✅ `include/transfer_audition.cfm` (line 426)

These files were **fixed** by this deployment:

✅ `include/upload_audition.cfm` (lines 188-193)
✅ `include/upload_audition_back.cfm` (lines 186-191)

---

## Rollback Plan

If issues occur after deployment:

### Rollback Database:
```sql
-- MySQL
ALTER TABLE audroles MODIFY COLUMN charDescription VARCHAR(500) NULL;
ALTER TABLE auditionsimport MODIFY COLUMN charDescription VARCHAR(500) NULL;

-- MSSQL
ALTER TABLE audroles ALTER COLUMN charDescription VARCHAR(500) NULL;
ALTER TABLE auditionsimport ALTER COLUMN charDescription VARCHAR(500) NULL;
```

### Rollback Code:
```bash
git revert <commit-hash>
# Or restore from backup
```

---

## Files Changed

### Database Schema
- ✅ `audroles.charDescription` - VARCHAR → TEXT/VARCHAR(MAX)
- ✅ `auditionsimport.charDescription` - VARCHAR → TEXT/VARCHAR(MAX)

### Code Files
- ✅ `include/upload_audition.cfm` - Lines 188-193
- ✅ `include/upload_audition_back.cfm` - Lines 186-191

### Documentation
- ✅ `database/fix_charDescription_length.sql` - SQL migration script
- ✅ `database/FIX_charDescription_README.md` - This file

---

## Related Fields

Note: This fix also updates `projDescription` and `note` fields in the import process to use `CF_SQL_LONGVARCHAR`, removing their 500-character limits as well.

---

## Testing Checklist

- [ ] Backup databases completed
- [ ] SQL migration run on dev database
- [ ] SQL migration verified (check INFORMATION_SCHEMA)
- [ ] Code deployed to dev
- [ ] Dev testing: Create role with 1000+ char description
- [ ] Dev testing: Import CSV with long descriptions
- [ ] SQL migration run on prod database
- [ ] Code deployed to prod
- [ ] Prod testing: Create role with long description
- [ ] Prod testing: Import with long descriptions
- [ ] Monitor for errors in first 24 hours
- [ ] Confirm with user who reported issue

---

## Questions?

Contact: Development Team
Issue: charDescription length limit
Fix Date: 2025-11-30
