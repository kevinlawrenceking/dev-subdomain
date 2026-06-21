# Import fix verification plan

Covers the fixes in commit `f60b0fb6` (audition category mapping, audition note
routing, dupe-matcher column bug, contact-import error surfacing) plus the
`V3_4` schema migration.

Test fixtures (this folder):
- `test_auditions_create.csv` - audition import (create new)
- `test_relationships_create.csv` - contact import with relationship enrollment (create new)

---

## 0. Prerequisites (must be done before testing)

1. Deploy commit `f60b0fb6` to the target environment (dev/UAT use `new_development`).
2. Run the one outstanding migration on that database (contactitems note width):
   ```sql
   -- pre-check: confirm no index needs a prefix length (expect 0 rows)
   SELECT INDEX_NAME, SUB_PART FROM information_schema.statistics
   WHERE table_schema = DATABASE() AND table_name='contactitems_tbl' AND column_name='valuetext';

   ALTER TABLE contactitems_tbl MODIFY COLUMN valuetext TEXT DEFAULT NULL;
   ```
3. Confirm column widths (all three should be `text` / 65535):
   ```sql
   SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
   FROM information_schema.columns
   WHERE table_schema = DATABASE()
     AND ( (table_name='noteslog_tbl'     AND column_name='noteDetails')
        OR (table_name='audprojects'      AND column_name='projDescription')
        OR (table_name='contactitems_tbl' AND column_name='valuetext') );
   ```
   `noteslog_tbl.noteDetails` and `audprojects.projDescription` are already TEXT
   (their migrations are no-ops); the one that changes is `contactitems_tbl.valuetext`.

Note your test `userid` for the verification queries below.

---

## TEST A - Auditions: category 'film' + note routing + no truncation

Upload `test_auditions_create.csv` through the audition importer.

### A1. Category 'film' (lowercase) is recognized  (was: shown as "no value")
- On the column-mapping step, the **Category** source column should map to the
  **Category** field (not "Medium / Format").
- On Review & Fix, row 1 ("Midnight Harbor") should be **ready** (not "problem"),
  with the category selector showing the resolved Film category. No
  "Audition category is required" error.

### A2. Note lands in the Notes tab, not the logline  (was: in Project Description/Logline)
- Finalize the import.
- Open the created audition. The long breakdown text appears under the
  **Notes** tab. The **Project Description / Logline** field is empty.

### A3. Long note is not truncated  (row 1 note is ~720 chars, > old 500 limit)
- The note shows in full, end to end ("...without loss." / "...stage combat...").

### A4. (Bonus) Duplicate detection works  (was: silently failing every run)
- Re-import the same CSV. Row 1 should now be flagged as a **dupe** against the
  audition created on the first pass (previously the dupe index aborted with
  "Error Executing Database Query" and nothing was ever flagged).

### Verification SQL (replace :uid)
```sql
-- projDescription should be empty/NULL; audSubCatID should be set (category resolved)
SELECT audprojectid, projName, audSubCatID, projDescription
FROM audprojects WHERE userid = :uid ORDER BY audprojectid DESC LIMIT 3;

-- note stored in full in the notes log, keyed by audprojectid
SELECT audprojectid, LENGTH(noteDetails) AS note_len, LEFT(noteDetails,40) AS note_start
FROM noteslog WHERE audprojectid IN (
  SELECT audprojectid FROM audprojects WHERE userid = :uid ORDER BY audprojectid DESC LIMIT 3
);
-- Expect note_len ~720 for the Midnight Harbor row (full length).
```

---

## TEST B - Relationships/contacts: long note + enrollment + real errors

Upload `test_relationships_create.csv` through the contact importer.

### B1. Long note imports without failure  (was: "Import failed: Error executing Database Query.")
- Row 1 ("Alex Morgan", ~900-char note) imports successfully. With V3_4 applied,
  no "Data too long" / generic DB error.

### B2. Long note is not truncated
- The full ~900-char note is stored (see SQL below).

### B3. Relationship enrollment
- "Alex Morgan" enrolled in **Target**, "Jordan Lee" in **Maintenance",
  "Casey Kim" not enrolled.

### B4. Errors are now actionable (regression guard)
- If any row does fail, the error text now includes the real cause
  (`cfcatch.detail`, e.g. the offending column) instead of only
  "Error executing Database Query."

### Verification SQL (replace :uid)
```sql
-- contact note length. V3 importer stores notes as a contactitems 'Note';
-- V2 importer stores them in noteslog. Check both.
SELECT contactid, LENGTH(valuetext) AS note_len, LEFT(valuetext,40) AS note_start
FROM contactitems
WHERE valueCategory = 'Note'
  AND contactid IN (SELECT contactid FROM contactdetails WHERE userid = :uid
                    ORDER BY contactid DESC LIMIT 5);

SELECT contactid, LENGTH(noteDetails) AS note_len, LEFT(noteDetails,40) AS note_start
FROM noteslog
WHERE contactid IN (SELECT contactid FROM contactdetails WHERE userid = :uid
                    ORDER BY contactid DESC LIMIT 5);
-- Expect note_len ~900 for Alex Morgan in whichever table the importer used. No 800 cap.

-- enrollment check
SELECT su.contactid, cd.contactFullName, su.systemid, su.sustatus
FROM fusystemusers su
JOIN contactdetails cd ON cd.contactid = su.contactid
WHERE su.userid = :uid
ORDER BY su.contactid DESC LIMIT 5;
```

---

## Cleanup
These create real records. After verifying, delete the test auditions/contacts
through the UI (or use the importer's per-row Undo for the audition rows), and
remove any test enrollments from `fusystemusers` / `funotifications` if needed.

## Pass criteria
- A1 ready (not problem) + category resolved; A2 note in Notes tab, logline empty;
  A3 note full length; A4 second import flags dupes.
- B1 no failure; B2 note full length (no 800 cap); B3 enrollments correct;
  B4 any failure message names the real column.
