# Tech Spec: Admin Enum Dashboard

**Date:** 2026-04-02
**Status:** Draft
**Author:** Kevin King / Claude

---

## 1. Problem Statement

Admin lookup-table management (the "Setup" and "Audition Setup" sidebar sections) currently relies on a heavily indirected dynamic page system:

1. Each enum table gets **two directories** (`aud-genres-Results/`, `aud-genres-Details/`) each containing a one-line `index.cfm` that just includes `core.cfm`.
2. `core.cfm` loads `pgload.cfm` which queries `pgpages` to find the `pgFilename`, then includes a generic `results.cfm`.
3. `results.cfm` queries `pgfields` to build columns, generates per-row `<script>` blocks for every modal, and dynamically loads `RemoteNewForm.cfm` / `RemoteUpdateForm.cfm` / `RemoteDeleteForm.cfm` via separate HTTP requests.
4. The form renderers (`RemoteNewForm`, `RemoteUpdateForm`) query `pgfields` again to determine field types and labels.

**Result:** 21 audition enum directories, 30+ query files, hundreds of `pgpages`/`pgfields`/`pgcomps` rows -- all to manage simple name/value lists. Adding a new dropdown option requires navigating to a separate page, waiting for a modal HTTP round-trip, submitting, and getting redirected back.

### What we want instead

A **single admin dashboard page** (one for Relationship tables, one for Audition tables) styled like the existing user dashboard (`dashboard_new.cfm`) where:

- Each **panel/card** represents one lookup table (e.g., "Genres", "Platforms", "Unions").
- The panel heading is the table's display name.
- The panel body lists the current active values as rows.
- Inline add/edit/delete -- no page navigation, no remote modal loads.

---

## 2. Scope

### In scope

| Area | Tables |
|------|--------|
| **Relationship Setup** | `fusystemtypes` (system types), `fusystems` (system definitions), `fuactions` (action templates) |
| **Audition Setup** | `audcategories`, `audsubcategories`, `audtypes`, `audroletypes`, `audplatforms`, `audnetworks`, `audunions`, `audgenres`, `audvocaltypes`, `auddialects`, `audmediatypes`, `audtones`, `audageranges`, `audsources`, `audsteps`, `audcontracttypes`, `audcallbacktypes`, `audpaycycles`, `audqtypes`, `audbooktypes` |

### Out of scope

- User-specific `_user` tables (e.g., `audgenres_user`) -- those are per-user copies, not admin enums.
- Cross-reference/junction tables (`audgenres_audition_xref`, etc.) -- managed at the audition/role level.
- `audprojects`, `audroles` -- transactional data, not enums.
- The existing `admin-relationship/` health dashboard -- that page stays as-is; the new Relationship Setup dashboard is a sibling for managing the lookup tables that feed the relationship engine.

---

## 3. Architecture

### 3.1 New files

```
app/
  admin-enum-relationship/
    index.cfm                  <-- entry point (includes core.cfm)
  admin-enum-audition/
    index.cfm                  <-- entry point (includes core.cfm)

include/
  admin-enum-dashboard.cfm     <-- shared dashboard renderer (both pages use this)

ajax/
  admin-enum-list.cfm          <-- GET: returns JSON rows for one table
  admin-enum-add.cfm           <-- POST: insert a new row
  admin-enum-update.cfm        <-- POST: update an existing row
  admin-enum-delete.cfm        <-- POST: soft-delete (set isDeleted=1)

services/
  AdminEnumService.cfc         <-- single service for all enum CRUD

app/assets/
  css/admin-enum.css           <-- panel + inline-edit styles
  js/admin-enum.js             <-- all client-side behavior
```

### 3.2 Database: `admin_enums` registry table

Instead of `pgpages`/`pgfields`/`pgcomps`, a single flat table tells the dashboard what to render.

See `sql/admin_enums_create.sql` for the authoritative CREATE TABLE and seed data.

Key schema additions (post-review):

- **`pk_type`** (`VARCHAR(10)`, default `'integer'`): Tells the service which `cf_sql_type` to use for PK params. Values: `'integer'` or `'varchar'`. Required because `fusystemtypes` uses a VARCHAR PK (`systemtype`), while all other tables use integer auto-increment PKs.
- **`fk_type`** (`VARCHAR(10)`, nullable): Same for FK values. Required because `fusystems.systemtype` is a VARCHAR FK pointing to `fusystemtypes.systemtype`.
- **`is_read_only`** (`TINYINT(1)`, default `0`): When `1`, the panel is displayed but add/edit/delete buttons are hidden. Used for:
  - `fusystemtypes` -- PK is the display name; editing would break all FK references in fusystems.
  - `fuactions` -- has many required columns beyond name (actionno, actiondaysno, actiondaysrecurring, isunique, etc.); generic add/edit would create corrupt rows.
- **`parent_label`** (`VARCHAR(50)`, nullable): The UI label shown on the parent/FK dropdown. If NULL, the JS falls back to "Parent". Data-driven so the template has no special cases. Seed values:
  - `'Category'` for the 10 audition tables with `audcatid` FK (these are category classifiers, not hierarchical parents)
  - `'System Type'` for `fusystems` (FK to `fusystemtypes`)
  - `'System'` for `fuactions` (FK to `fusystems`, read-only reference)
  - `NULL` for all tables with no parent FK
### 3.3 Service layer: `AdminEnumService.cfc`

One CFC replaces the 20+ individual `Audition*Service.cfc` files for simple CRUD. It validates table/column names against the `admin_enums` registry (whitelist), so no SQL injection is possible even though column names are dynamic.

```
AdminEnumService.cfc
  getEnumsByGroup(group)        -> query of admin_enums rows for the dashboard
  getEnumRows(enum_id)          -> query of active rows from the target table
  getParentOptions(enum_id)     -> query of parent table rows (for FK dropdowns)
  addEnumRow(enum_id, name, parent_id?)   -> INSERT, returns new PK (rejected if is_read_only=1)
  updateEnumRow(enum_id, pk_value, name, parent_id?)  -> UPDATE (rejected if is_read_only=1)
  deleteEnumRow(enum_id, pk_value)        -> SET isDeleted=1 or hard DELETE (rejected if is_read_only=1)
```

**Security invariant:** Every method starts by loading the `admin_enums` row for the given `enum_id` and using its `table_name`, `pk_column`, `name_column` as the source of truth for the dynamic SQL. User-supplied values go through `cfqueryparam`. Column/table names are validated against the registry, never taken from the request.

**Type-aware parameterization:** The service reads `pk_type` and `fk_type` from the registry to select the correct `cf_sql_type` for `cfqueryparam`:
- `pk_type = 'integer'` -> `CF_SQL_INTEGER`
- `pk_type = 'varchar'` -> `CF_SQL_VARCHAR`
- Same logic for `fk_type` when parameterizing parent_id values.

**Read-only enforcement:** `addEnumRow`, `updateEnumRow`, and `deleteEnumRow` must check `is_read_only` before executing and return an error struct if the table is read-only. The UI hides the buttons, but the service is the authoritative guard.

### 3.4 AJAX endpoints

All four endpoints live under `/ajax/` and return `{ success: true/false, message: "...", data: {...} }`.

| Endpoint | Method | Params | Returns |
|----------|--------|--------|---------|
| `admin-enum-list.cfm` | GET | `enum_id` | `{ rows: [{id, name, parent_name?}], enum: {display_name, has_parent} }` |
| `admin-enum-add.cfm` | POST | `enum_id`, `name`, `parent_id?` | `{ id: newPK }` |
| `admin-enum-update.cfm` | POST | `enum_id`, `pk_value`, `name`, `parent_id?` | `{}` |
| `admin-enum-delete.cfm` | POST | `enum_id`, `pk_value` | `{}` |

All endpoints check `session.userrole IS "Administrator"` before executing.

---

## 4. UI Design

### 4.1 Page layout

Same Packery grid as `dashboard_new.cfm` -- 4-column responsive layout. Each panel = one enum table.

```
+---------------------------+---------------------------+---------------------------+---------------------------+
|  Categories               |  Subcategories            |  Types                    |  Role Types               |
|  [+ Add]                  |  [+ Add]                  |  [+ Add]                  |  [+ Add]                  |
|---------------------------|---------------------------|---------------------------|---------------------------|
|  Commercial               |  Commercial > TV          |  TV Commercial   [ed][x]  |  Lead           [ed][x]   |
|  Film/TV                  |  Commercial > Web         |  Film Feature    [ed][x]  |  Supporting     [ed][x]   |
|  Theatre                  |  Film/TV > Feature        |  Theatre Musical [ed][x]  |  Featured Extra [ed][x]   |
|  Voice Over               |  Film/TV > Pilot          |  ...                      |  ...                      |
|  ...                      |  ...                      |                           |                           |
+---------------------------+---------------------------+---------------------------+---------------------------+
|  Platforms                |  Networks                 |  Unions                   |  Genres                   |
|  ...                      |  ...                      |  ...                      |  ...                      |
+---------------------------+---------------------------+---------------------------+---------------------------+
```

### 4.2 Panel HTML structure

Mirrors the existing dashboard card pattern exactly:

```html
<div class="card grid-item admin-enum-panel" data-enum-id="8">
    <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="m-0">Genres</h5>
        <span class="badge bg-secondary" data-role="count">24</span>
    </div>
    <div class="card-body p-0">
        <div class="admin-enum-list" style="max-height: 300px; overflow-y: auto;">
            <!-- rows injected by JS -->
        </div>
    </div>
    <div class="card-footer p-2">
        <button class="btn btn-sm btn-outline-primary w-100" data-action="add">
            <i class="mdi mdi-plus"></i> Add
        </button>
    </div>
</div>
```

### 4.3 Row HTML (inside `.admin-enum-list`)

```html
<div class="admin-enum-row d-flex align-items-center px-3 py-2" data-pk="12">
    <span class="admin-enum-name flex-grow-1">Horror</span>
    <span class="admin-enum-parent text-muted small me-2">Film/TV</span>
    <button class="btn btn-sm btn-link p-0 me-1" data-action="edit" title="Edit">
        <i class="mdi mdi-square-edit-outline"></i>
    </button>
    <button class="btn btn-sm btn-link p-0 text-danger" data-action="delete" title="Delete">
        <i class="mdi mdi-trash-can-outline"></i>
    </button>
</div>
```

### 4.4 Inline editing (no modals, no page navigation)

**Read-only panels** (`is_read_only = 1`): No Add button in footer, no edit/delete icons on rows. Panel displays data only. A subtle visual indicator (e.g., muted card-header or a lock icon) signals that this panel is view-only.

**Read-write panels** (`is_read_only = 0`):

**Add:** Clicking "+ Add" inserts a text input row at the top of the list with a save/cancel button pair. If the table has a category FK, a `<select>` dropdown labeled "Category" appears next to the text input, pre-populated from the parent table.

**Edit:** Clicking the edit icon swaps the name `<span>` for a text `<input>` pre-filled with the current value. Save/cancel buttons appear. Category dropdown appears if applicable.

**Delete:** Clicking the trash icon shows a small inline confirmation ("Delete 'Horror'? [Yes] [No]") replacing the row content. On confirm, AJAX soft-deletes and removes the row with a fade-out.

All operations are AJAX -- the panel updates in place without affecting other panels or reloading the page.

### 4.5 Responsive behavior

- Desktop: 4-column Packery grid (matches existing dashboard).
- Tablet: 2-column.
- Mobile: 1-column, full width.
- Panel body max-height `300px` with `overflow-y: auto` scroll for tables with many values. Panels with fewer than ~8 rows display without scroll.

---

## 5. Data Flow

### 5.1 Page load

```
Browser -> GET /app/admin-enum-audition/
  -> index.cfm includes core.cfm
  -> core.cfm loads page metadata, includes admin-enum-dashboard.cfm
  -> admin-enum-dashboard.cfm:
       1. AdminEnumService.getEnumsByGroup("audition")
       2. Loop: render card shells (header + empty body + footer)
       3. For each enum, AdminEnumService.getEnumRows(enum_id)
       4. Render rows server-side inside card bodies
  -> Include admin-enum.css + admin-enum.js
```

Server-side rendering on initial load (no loading spinners needed for small datasets). JS takes over for all subsequent CRUD.

### 5.2 Add flow

```
User clicks [+ Add]
  -> JS injects input row at top of panel body
  -> User types name, selects parent (if applicable), clicks Save
  -> JS POST /ajax/admin-enum-add.cfm { enum_id, name, parent_id? }
  -> Server validates, inserts, returns { success: true, id: 99 }
  -> JS replaces input row with rendered data row, updates count badge
```

### 5.3 Edit flow

```
User clicks [edit icon]
  -> JS swaps <span> for <input>, shows save/cancel
  -> User edits, clicks Save
  -> JS POST /ajax/admin-enum-update.cfm { enum_id, pk_value, name, parent_id? }
  -> Server validates, updates, returns { success: true }
  -> JS swaps <input> back to <span> with new value
```

### 5.4 Delete flow

```
User clicks [trash icon]
  -> JS shows inline "Delete 'X'? [Yes] [No]" in the row
  -> User clicks Yes
  -> JS POST /ajax/admin-enum-delete.cfm { enum_id, pk_value }
  -> Server sets isDeleted = 1, returns { success: true }
  -> JS fades out and removes row, decrements count badge
```

---

## 6. Security

| Concern | Mitigation |
|---------|------------|
| SQL injection via dynamic table/column names | All table/column names come from `admin_enums` registry (server-side whitelist), never from request params. Only `enum_id`, `name`, `pk_value`, `parent_id` come from the user, all through `cfqueryparam`. |
| Unauthorized access | All AJAX endpoints and the page itself check `session.userrole IS "Administrator"`. |
| CSRF | Include CSRF token in AJAX headers per existing TAO pattern (see recent CSRF enhancement commit). |
| Double-submit on add | `addEnumRow` checks for duplicate name (case-insensitive) in the same table before inserting. Returns error message if duplicate. |

---

## 7. Sidebar Navigation Changes

Replace the current long sub-item lists under "Setup" and "Audition Setup" with single links:

**Before (Setup section):**
```
Setup
  Action User Durations
  Notification Status
  Systems
  ... (N items from menuItemsA)
```

**After (Setup section):**
```
Setup
  Relationship Admin     -> /app/admin-enum-relationship/
  Relationship Health    -> /app/admin-relationship/   (existing)
  ... (any non-enum items that remain)
```

**Before (Audition Setup section):**
```
Audition Setup
  Age Ranges
  Callback Types
  Categories
  Contract Types
  Dialects
  Genres
  ... (21 items from menuItemsAud)
```

**After (Audition Setup section):**
```
Audition Setup
  Audition Admin         -> /app/admin-enum-audition/
  ... (any non-enum items that remain, e.g., Projects, Roles)
```

This collapses 20+ sidebar entries into 1 per group.

---

## 8. Migration Path

### Phase 1: Build new (no disruption)
1. Create `admin_enums` table and seed data.
2. Build `AdminEnumService.cfc`.
3. Build AJAX endpoints.
4. Build `admin-enum-dashboard.cfm`, CSS, JS.
5. Create `admin-enum-relationship/` and `admin-enum-audition/` page directories.
6. Register both pages in `pgpages`/`pgcomps` so they appear in the sidebar.
7. Test end-to-end.

### Phase 2: Cut over sidebar
1. Update `pgcomps` to hide old individual enum pages from menu (`menuYN = 'N'`).
2. Add new dashboard entries to `pgcomps`.
3. The old pages continue to work at their URLs (no 404s) but aren't navigable from the sidebar.

### Phase 3: Cleanup (optional, later)
1. Remove old `aud-*-Results/` and `aud-*-Details/` directories (21+ pairs).
2. Remove orphaned query files in `include/qry/` (30+ files).
3. Remove orphaned `pgpages`/`pgfields` rows.
4. Keep the individual `Audition*Service.cfc` files -- they're still used by non-admin code paths (audition forms, user-facing dropdowns).

---

## 9. Relationship Admin: Special Considerations

The relationship lookup tables are smaller in count but more complex:

| Table | `is_read_only` | Notes |
|-------|----------------|-------|
| `fusystemtypes` | **1 (read-only)** | Only 3 values ("Follow Up", "Maintenance List", "Targeted List"). PK = display name (VARCHAR). Editing would break all FK references in `fusystems`. Dashboard shows values for reference only. |
| `fusystems` | **0 (read-write)** | 6 rows. Integer PK, VARCHAR FK to `fusystemtypes.systemtype`. The generic panel shows `systemname` with a "System Type" dropdown. Adding/editing system name + type is safe through the generic pattern. Additional columns (`systemscope`, `systemdescript`, `systemtriggernote`) are not exposed — if needed later, handle as a special-case panel. |
| `fuactions` | **1 (read-only)** | Many required columns beyond name (`actionno`, `actiondaysno`, `actiondaysrecurring`, `isunique`, `uniquename`, `actiondetails`, etc.). Generic INSERT would create broken rows missing scheduling data that the relationship engine depends on. Dashboard shows `actiontitle` grouped by parent system for reference. Full editing requires a dedicated sub-page (future scope). |

---

## 10. File-by-File Implementation Summary

| File | Purpose | Est. Lines |
|------|---------|------------|
| `sql/admin_enums_create.sql` | CREATE TABLE + seed INSERT | ~80 |
| `sql/admin_enums_rollback.sql` | DROP TABLE | ~5 |
| `services/AdminEnumService.cfc` | All CRUD + validation | ~200 |
| `ajax/admin-enum-list.cfm` | GET rows JSON | ~30 |
| `ajax/admin-enum-add.cfm` | POST insert JSON | ~40 |
| `ajax/admin-enum-update.cfm` | POST update JSON | ~40 |
| `ajax/admin-enum-delete.cfm` | POST soft-delete JSON | ~30 |
| `include/admin-enum-dashboard.cfm` | Dashboard template (shared) | ~120 |
| `app/admin-enum-relationship/index.cfm` | Entry point | ~3 |
| `app/admin-enum-audition/index.cfm` | Entry point | ~3 |
| `app/assets/css/admin-enum.css` | Panel + inline-edit styles | ~100 |
| `app/assets/js/admin-enum.js` | AJAX CRUD + inline editing | ~250 |
| `pgpages`/`pgcomps` INSERT scripts | Register new pages in nav | ~20 |

**Total new code:** ~920 lines across 13 files.
**Code removed (Phase 3):** 42+ directories, 60+ query files, hundreds of `pgpages`/`pgfields` rows.

---

## 11. Verification Checklist

### Functional
- [ ] Audition admin dashboard loads with all 20 panels
- [ ] Relationship admin dashboard loads with 3 panels (2 read-only, 1 read-write)
- [ ] Each panel shows correct row count badge
- [ ] Inline add works on read-write panels -- new row appears, count increments
- [ ] Inline edit works on read-write panels -- value updates in place
- [ ] Inline delete works on read-write panels -- row fades, count decrements
- [ ] Read-only panels (fusystemtypes, fuactions) show no add/edit/delete controls
- [ ] Read-only enforcement at service level: AJAX add/edit/delete rejected with error for read-only tables
- [ ] Category dropdown populates correctly (genres show audcategories options, labeled "Category")
- [ ] VARCHAR PK handling: fusystemtypes panel loads correctly with string PKs
- [ ] VARCHAR FK handling: fusystems panel shows systemtype dropdown with string values
- [ ] Duplicate name detection prevents double-add
- [ ] Only Administrators see the pages / can hit the AJAX endpoints
- [ ] CSRF token validated on all POST endpoints

### Edge cases
- [ ] Empty panel (table with 0 active rows) shows "No items" message + Add button
- [ ] Very long name (100+ chars) truncates in display, full value in edit
- [ ] Concurrent edits: second save returns error if row was deleted between load and save
- [ ] Panel scroll works for tables with 50+ rows
- [ ] Rapid double-click on Add doesn't create two input rows

### Regression
- [ ] Audition forms still load their dropdowns correctly (they query the tables directly, not through this system)
- [ ] User `_user` tables unaffected
- [ ] Existing `admin-relationship/` health dashboard unaffected
- [ ] Old enum page URLs still resolve (until Phase 3 cleanup)

---

## 12. Open Questions

1. **Panel ordering:** Should admins be able to drag-reorder panels (like the user dashboard), or is a fixed `sort_order` column sufficient?
2. **Soft delete visibility:** Should there be a "Show deleted" toggle per panel so admins can re-activate soft-deleted values?
3. **Audit trail:** Should changes be logged (who changed what, when)? Could be a simple `admin_enum_log` table.

### Resolved

- ~~**fuactions complexity:** Is the inline multi-field editor sufficient for actions?~~ **Decision:** Marked `is_read_only = 1`. Dashboard shows action titles for reference only. Full editing deferred to a future dedicated sub-page.
- ~~**fusystemtypes VARCHAR PK:** How to handle non-integer PKs?~~ **Decision:** Added `pk_type` and `fk_type` columns to `admin_enums`. Service reads these to select the correct `cf_sql_type` for `cfqueryparam`. `fusystemtypes` is also `is_read_only = 1` since editing its PK would break FK references.
- ~~**Parent FK labeling:** Are the audcatid FKs real parent relationships?~~ **Decision:** Verified all 10 tables do have `audcatid`. It's a category classifier, not hierarchical. UI labels the dropdown "Category".
