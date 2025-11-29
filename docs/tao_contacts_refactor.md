# TAO Contacts Refactor Documentation

## Overview: TAO Tiered Refactor and Cleanup Plan

The TAO Tiered Refactor is a systematic approach to modernizing the codebase while maintaining backward compatibility. **Tier 1 (T1)** focuses on the Contacts module: implementing standardized CRUD methods in ContactService, migrating legacy query-naming-convention methods (INS/UPD/SEL/DET) to thin wrappers that delegate to the new CRUD methods, and eliminating direct QRY object usage in application code by replacing them with direct service calls. This approach improves maintainability, performance, and sets a pattern for refactoring other modules (Events, Auditions, etc.).

---

## T1 Contacts: Current Status

### CRUD Methods Implemented (ContactService.cfc)

The following standardized CRUD methods have been implemented in `services/ContactService.cfc`:

- **`create(dataStruct)`** - Creates new contact record, returns contactid
  - Uses `queryExecute()` with named parameters
  - Validates required fields: `userid`, `contactFullName`
  - Whitelists allowed fields with SQL type mappings

- **`read(contactid)`** - Retrieves single contact record, returns struct
  - Returns empty struct if not found
  - Returns full contact record as struct

- **`update(contactid, dataStruct)`** - Updates existing contact record
  - Dynamic SET clause building
  - Only updates fields present in dataStruct
  - Uses whitelisted allowed fields

- **`delete(contactid)`** - Soft-deletes contact record
  - Sets `isdeleted = 1`
  - Preserves data for audit trail

- **`list(filtersStruct)`** - Lists contacts with optional filters
  - Requires `userid` in filtersStruct
  - Supports filters: `contactStatus`, `isdeleted`, `search`, `orderBy`, `orderDir`
  - Defaults to excluding deleted records
  - Uses `queryExecute()` with named parameters

### Legacy Methods Migrated to Wrappers

The following legacy methods have been converted to thin wrappers that delegate to standardized CRUD methods:

#### INSERT Wrappers (delegate to `create()`)
- `INScontactdetails` (userid, contactFullName)
- `INScontactdetails_23769` (userid, cdfullname)
- `INScontactdetails_23839` (userid, contactfullname)
- `INScontactdetails_24000` (userFirstName, userLastName, userId) - concatenates names, sets user_yn='Y'
- `INScontactdetails_24048` (userid, contactfullname) - trims input
- `INScontactdetails_24070` (complex insert with multiple optional fields)
- `INScontactdetails_24294` (userid, contactfullname)

#### UPDATE Wrappers (delegate to `update()`)
- `UPDcontactdetails` (final_birthday, New_contactid)
- `UPDcontactdetails_24202` (complex update with conditional fields)

#### SELECT Wrappers (delegate to `list()` or `read()`)
- `SELcontactdetails_23722` (userId) - filters for non-empty recordname
- `SELcontactdetails_23727` (userid, relationship) - delegates to read() with security check
- `SELcontactdetails_23806` (contactid) - delegates to read(), filters for non-null birthday
- `SELcontactdetails_23843` (userid, select_contactid) - conditional: read() or list()
- `SELcontactdetails_23913` (contactid) - delegates to read(), returns recordname only
- `SELcontactdetails_24069` (userid) - returns all columns (fallback to direct query)
- `SELcontactdetails_24263` (userid) - filters for non-empty recordname, ordered by recordname
- `SELcontactdetails_24293` (userid, referral) - exact recordname match using list() + filtering
- `SELcontactdetails_24433` (userId, selectContactId) - conditional: read() or list()
- `SELcontactdetails_24483` (userid) - filters for Active contacts only

#### DETAIL Wrappers (delegate to `read()`)
- `DETcontactdetails` (contactid) - converts struct to query for backward compatibility
- `DETcontactdetails_24264` (contactid) - converts struct to query
- `DETcontactdetails_24625` (refer_contact_id) - converts struct to query with specific columns
- `DETcontactdetails_24629` (refer_contact_id) - converts struct to query with aliases

#### RESULTS Wrappers (delegate to `list()`)
- `REScontactdetails` (userId) - filters for Active, returns contactid and col1 (recordname alias)

### Technical Notes

1. **queryExecute Usage**: New CRUD methods use `queryExecute()` with named parameters instead of `<cfquery>` tags for better security and consistency.

2. **Allowed Fields Whitelist**: Both `create()` and `update()` use whitelisted field maps that include SQL type definitions:
   ```cfml
   allowedFields = {
       "userid": "CF_SQL_INTEGER",
       "contactFullName": "CF_SQL_VARCHAR",
       "contactBirthday": "CF_SQL_DATE",
       // ... etc
   }
   ```

3. **Soft Delete Behavior**: The `delete()` method performs soft deletes by setting `isdeleted = 1`. The `list()` method defaults to excluding deleted records unless explicitly requested via `filtersStruct.isdeleted`.

4. **Struct Return Type**: The `read()` method returns a struct (not a query), requiring wrapper methods to convert to query objects for backward compatibility.

5. **Dynamic Query Building**: Both `create()` and `update()` build dynamic SQL with only the fields present in the input struct, preventing unnecessary column updates or null insertions.

6. **Special Case Methods**: Some legacy methods use dynamic column names (e.g., `UPDcontactdetails_23816`) and preserve their original implementation as they can't be safely mapped to the standard CRUD pattern.

---

## Next Steps: T1 Contacts Completion

### Remaining Legacy Methods to Wrap

The following methods in ContactService.cfc still use direct database queries and should be evaluated for wrapper migration:

- [ ] `updateContactUnique` - Dynamic column update (special case)
- [ ] `addMembers` - Complex insert with subquery
- [ ] `getSystemIdBasedOnTag` - Read-only query with complex logic
- [ ] `getContactCount` - Aggregate query (could use list() with count)
- [ ] `getFilteredContactsByEvent` - Complex join query
- [ ] `ru` - Relationship system query (join with fusystemusers/fusystems)
- [ ] `getFilteredContacts` - Complex filtering with dynamic SQL
- [ ] `getContactUpdates` - Aggregate join with updatelog table
- [ ] `SELcontactdetails` - Dynamic column name query (special case)
- [ ] `UPDcontactdetails_23816` - Dynamic column update (currently preserved as special case)
- [ ] `UPDcontactdetails_23861` - Batch soft delete with idList
- [ ] `SELcontactdetails_23888` - Complex select with string parsing
- [ ] `SELcontactdetails_23906` - UNION query across contactdetails and imdb tables
- [ ] `getContactRecordName` - Simple read (can use read() wrapper)
- [ ] `SELcontactdetails_23939` - Dynamic column query (special case)
- [ ] `DETcontactdetails_24340` - Batch read with idList
- [ ] `SELcontactdetails_24364` - Search by fullname and userid (can use list() with filter)
- [ ] `SELcontactdetails_24397` - Search by fname/lname (can use list() with search filter)
- [ ] `INScontactdetails_24399` - Complex upsert with duplicate check
- [ ] `INScontactdetails_24537` - Insert with non-standard column name (cdco)
- [ ] `SELcontactdetails_24617` - Birthday reminder query with date math
- [ ] `DETcontactdetails_24624` - Complex join with taousers and self-referencing contact
- [ ] `DETcontactdetails_24685` - Complex select with joins
- [ ] `SELcontactdetails_24674` - Join with updatelog table
- [ ] `SELcontactdetails_24683` - Join with contactitems for "My Team" tag
- [ ] `GetMyTeam` - Complex query with contacts_ss view
- [ ] `getContactsByAudProject` - Complex query with audcontacts_auditions_xref
- [ ] `getContactForCard` - Complex query with contacts_ss view
- [ ] `SELcontactdetails_24515` - Complex query with NOT IN subquery

**Note**: Many of these involve complex joins, aggregations, or queries against views (contacts_ss) and may not be suitable for simple CRUD wrapper conversion. Consider whether these should remain as specialized query methods.

### T1-Contacts QRY Migration (Next Branch)

After completing the wrapper migration, create a new branch `cleanup/t1-contacts-qry` to eliminate QRY object usage:

- [ ] Search codebase for `application.ContactsQRY` references
- [ ] Replace QRY method calls with direct ContactService calls
- [ ] Update all `.cfm` view files that call QRY methods
- [ ] Update all controller files that instantiate or use ContactsQRY
- [ ] Remove or deprecate ContactsQRY.cfc once all references are migrated
- [ ] Update any AJAX endpoints that use QRY methods

### Manual Regression Testing

Before merging T1 Contacts work to dev branch:

- [ ] **Contact Creation**: Test creating new contacts via UI
- [ ] **Contact Updates**: Test editing contact details (name, birthday, meeting info, pronouns)
- [ ] **Contact List View**: Verify contact listings display correctly with filters
- [ ] **Contact Search**: Test search functionality by name, recordname
- [ ] **Contact Soft Delete**: Test deleting contacts and verify they're excluded from default lists
- [ ] **Contact Details Page**: Verify all contact detail fields display correctly
- [ ] **Contact Birthday Reminders**: Test birthday notification system
- [ ] **Contact Relationships**: Test refer_contact_id relationships and referral display
- [ ] **Contact Tags**: Test "My Team" and other tag associations
- [ ] **Contact Systems**: Test Follow-Up, Targeting, and Maintenance system associations
- [ ] **Audition Project Contacts**: Test contact associations with audition projects
- [ ] **Contact Import**: Test contact import functionality
- [ ] **Performance Testing**: Compare query execution times before/after refactor

---

## How to Rehydrate This Context

When starting a new Claude Code session to continue T1 Contacts work, read files in this order:

1. **Start here**: `docs/tao_contacts_refactor.md` (this file) - Get overview and current status

2. **Core implementation**: `services/ContactService.cfc` - Review CRUD methods and current wrapper implementations (lines 1-241 for CRUD, rest for legacy methods)

3. **TAO context**: `CLAUDE.md` - Understand TAO system architecture, modules, and development priorities

4. **Relationship system**: `mnt/data/TAO Relationship System_ Process & Data Flow Documentation.md` - Deep dive into relationship workflows if working on system-related queries

5. **Recent commits**: Run `git log --oneline -20` to see latest changes and understand the migration pattern

6. **Search for usage**: When wrapping a specific legacy method, search for its usage:
   ```bash
   git grep "methodName" -- "*.cfm" "*.cfc"
   ```

7. **Database schema** (if needed): The contactdetails table schema can be inferred from the allowedFields whitelist in ContactService.cfc lines 21-39

### Quick Start Commands

```bash
# View current branch and status
git status

# See recent T1 Contacts commits
git log --oneline --grep="T1 Contacts" -20

# Find usage of a specific legacy method
git grep "INScontactdetails_24399"

# Check for QRY usage (for QRY migration phase)
git grep "application.ContactsQRY" -- "*.cfm" "*.cfc"
```

---

## Related Documentation

- `CLAUDE.md` - TAO developer context and system overview
- `services/ContactService.cfc` - Main implementation file
- Git commit history on `cleanup/t1-contacts-qry` branch for migration patterns

---

*Last Updated: 2025-11-24*
*Current Branch: cleanup/t1-contacts-qry*
*Status: T1 Contacts CRUD and wrapper migration complete, QRY cleanup in progress*
