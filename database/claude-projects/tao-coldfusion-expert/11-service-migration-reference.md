# Function Migration Reference

This document tracks the migration of functions from their original naming conventions to the standardized CRUD approach. Use this as a reference when updating code that calls these services.

## Table of Contents

- [ContactService](#contactservice)
- [AuditionGenreService](#auditiongenreservice)
- [Template for New Services](#template-for-new-services)

## ContactService

| Original Function | Standardized Function | Parameters Changed | Notes |
|-------------------|----------------------|-------------------|-------|
| INScontactdetails_23839 | create() | Yes | Now accepts a struct with key-value pairs instead of individual arguments |
| SELcontactdetails_23843 | list() or read() | Yes | If select_contactid is provided, maps to read(); otherwise maps to list() |
| UPDcontactdetails_23841 | update() | Yes | Now accepts contactid and a struct with fields to update |
| DELcontactdetails_23842 | delete() | No | Maintains same parameter signature |
| SELcontactdetails_by_userid_23844 | list() | Yes | Use list() with filters struct: {userid: value} |
| SELcontacts_by_range_23845 | list() | Yes | Use list() with appropriate filters and sorting |

## AuditionGenreService

| Original Function | Standardized Function | Parameters Changed | Notes |
|-------------------|----------------------|-------------------|-------|
| SELaudgenres_362_1 | list() | Yes | Now accepts filters struct instead of individual parameters |
| INSaudgenres_362_1 | create() | Yes | Now accepts a struct with key-value pairs |
| SELaudgenres_362_2 | read() | No | Maps directly to read() with id parameter |
| UPDaudgenres_364_1 | update() | Yes | Now accepts audgenreid and a struct with fields to update |
| DELaudgenres_366_1 | delete() | No | Maintains same parameter signature |

## Template for New Services

When standardizing additional services, follow this pattern:

1. **Create standard CRUD functions:**
   - `create(data)` - Creates new record, accepts struct of field values
   - `read(id, [includeFields])` - Retrieves a single record by ID
   - `update(id, data)` - Updates record with ID using values in data struct
   - `delete(id, [hardDelete=false])` - Soft or hard deletes a record
   - `list(filters, [sortField], [sortDirection], [includeFields], [maxRows])` - Lists records with filtering and sorting

2. **Add legacy function mappings:**
   ```cfml
   <cffunction name="ORIGINAL_FUNCTION_NAME" access="public" returntype="TYPE" output="false" hint="[DEPRECATED] Use standardFunction() instead">
       <cfargument name="originalArg1" type="type" required="true">
       <cflog file="serviceLog" text="DEPRECATED: ORIGINAL_FUNCTION_NAME called. Use standardFunction() instead.">
       <cfreturn standardFunction({
           "key1": arguments.originalArg1,
           "key2": arguments.originalArg2
       })>
   </cffunction>
   ```

3. **Implement special case functions:**
   - For functions that don't map directly to CRUD operations
   - For specialized business logic

## Implementation Strategy

1. **Phase 1:** Add core standardized functions to each service while maintaining original functions
2. **Phase 2:** Add deprecation warnings to original functions
3. **Phase 3:** Update calling code to use new standardized functions
4. **Phase 4:** Eventually remove original functions when no longer referenced

## Progress Tracking

| Service | Core Functions Added | Legacy Mappings Added | Calling Code Updated | Original Functions Removed |
|---------|---------------------|----------------------|---------------------|---------------------------|
| ContactService | ✅ | ✅ | ❌ | ❌ |
| AuditionGenreService | ✅ | ✅ | ❌ | ❌ |
