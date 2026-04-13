# TAO Setup Wizard v2 -- Comprehensive Tech Spec

**Date:** 2026-04-12
**Author:** Kevin King + Claude Code
**Status:** Draft for CF Expert Review
**Priority:** P1 (Blocks new user onboarding)

---

## 1. Executive Summary

The P11 Setup Wizard (`/app/setup-wizard/`) is a 7-step AJAX-driven onboarding flow for new TAO users. It was scaffolded in July 2024 and is partially functional. This spec documents every bug, missing feature, and visual improvement needed to make it production-ready.

**Current state:** Steps 1-2 save data but have UX bugs. Step 3 manual entry is broken. Step 4 fails to load entirely. Step 5 is untested. Step 6 needs UX reorganization. Step 7 (Finish) fails. The visual design is plain and lacks the polished look of other TAO pages (e.g., the error page).

---

## 2. File Inventory

### Wizard Shell
| File | Lines | Purpose |
|------|-------|---------|
| `/app/setup-wizard/index.cfm` | 162 | Master page: stepper, AJAX loader, footer nav |
| `/app/assets/js/setup-wizard.js` | 279 | Navigation controller: step loading, save, skip, history |
| `/app/assets/css/setup-wizard.css` | 434 | All wizard styling |

### Step Partials (loaded via AJAX into `#wizard-step-content`)
| File | Lines | Step |
|------|-------|------|
| `/app/setup-wizard/steps/step1.cfm` | 238 | Account Info |
| `/app/setup-wizard/steps/step2.cfm` | 177 | Representation |
| `/app/setup-wizard/steps/step3.cfm` | 199 | Contacts |
| `/app/setup-wizard/steps/step4.cfm` | 127 | Auditions |
| `/app/setup-wizard/steps/step5.cfm` | 189 | Reminders |
| `/app/setup-wizard/steps/step6.cfm` | 113 | Links |
| `/app/setup-wizard/steps/step7.cfm` | 166 | Completion |

### AJAX Endpoints
| File | Lines | Purpose |
|------|-------|---------|
| `/ajax/setup-wizard/load-step.cfm` | 64 | GET: loads step HTML fragment |
| `/ajax/setup-wizard/save-step1.cfm` | 117 | POST: save profile/timezone/pronouns |
| `/ajax/setup-wizard/save-step2.cfm` | 121 | POST: create rep contacts |
| `/ajax/setup-wizard/save-step3.cfm` | 110 | POST: create contacts from manual entry |
| `/ajax/setup-wizard/save-step4.cfm` | 76 | POST: create audition projects/roles |
| `/ajax/setup-wizard/save-step5.cfm` | 70 | POST: enroll contacts in reminder systems |
| `/ajax/setup-wizard/save-step6.cfm` | 75 | POST: update/insert site links |
| `/ajax/setup-wizard/save-step7.cfm` | 40 | POST: activate account (userstatus -> Active) |
| `/ajax/setup-wizard/upload-avatar.cfm` | 74 | POST: avatar JPEG/PNG upload |
| `/ajax/setup-wizard/skip-step.cfm` | 58 | POST: advance without saving data |

### Auth
- All AJAX endpoints are protected by `/ajax/Application.cfc` which enforces session auth (401 if no `session.userid`) and CSRF token validation (403 if invalid).

### Database
- **Migration:** `/database/migrations/P11_setup_wizard_columns.sql` -- adds `setup_step` (TINYINT) and `setup_completed_at` (DATETIME) to `taousers_tbl`
- **Rollback:** `/database/migrations/P11_setup_wizard_columns_ROLLBACK.sql`

---

## 3. Visual / Aesthetic Improvements

### 3.1 Colored Header (match error page style)

**Problem:** The wizard header is plain white with just a logo image. The error page (`/templates/error/error-friendly.cfm`) has a polished dark teal header (#406E8E) with brand text that looks professional.

**Current code** (`index.cfm` lines 66-70):
```html
<div class="wizard-header">
    <img src="/media-{dsn}/images/taowhite.png" alt="The Actors Office" class="wizard-logo" />
</div>
```

**Current CSS** (`setup-wizard.css` lines 11-19):
```css
.wizard-header {
    text-align: center;
    padding: 32px 0 16px;
}
.wizard-header .wizard-logo {
    height: 48px;
    margin-bottom: 8px;
}
```

**Fix:** Replace the plain header with a colored header bar matching the error page pattern:
- Background: `#406E8E` (TAO brand teal)
- Text: "The Actors Office" in white, 18px, weight 700
- Sub-text: "Career Management Platform" in `#a8c8de`, 12px
- Padding: 32px 30px 28px
- Card gets `border-radius: 16px` and `overflow: hidden` so the header rounds with the card

**Logo issue:** The current logo file `taowhite.png` has a fixed white background that looks bad against the teal header. Two options:
- **Option A (preferred):** Create a transparent-background PNG version of the logo and use it in the header
- **Option B:** Use text-only branding (like the error page does) with CSS font styling, no image

**Impact:** `index.cfm` (header HTML), `setup-wizard.css` (header styles)

### 3.2 Widen the Panel

**Problem:** `max-width: 820px` feels narrow for step 3 (two-panel layout with import + manual entry) and step 6 (link list).

**Fix:** Increase `.wizard-card` max-width to `920px`.

**Impact:** `setup-wizard.css` line 22

### 3.3 Raised / Rounded Card

**Problem:** Card has minimal shadow (`0 1px 3px rgba(0,0,0,.08)`) and 8px radius. Looks flat.

**Fix:**
- Increase border-radius to `16px` (matches error page)
- Increase shadow to `0 4px 24px rgba(0,0,0,0.08)` (matches error page)
- Add `overflow: hidden` to contain the colored header within rounded corners

**Impact:** `setup-wizard.css` lines 21-28

### 3.4 Body Background

**Fix:** Change from `#f5f7fa` to `#F1F5F9` to match the error page.

**Impact:** `setup-wizard.css` line 7

### 3.5 Shorten Breadcrumb Labels

**Problem:** Multi-word labels like "Account Info", "My Links" cause wrapping and visual clutter in the stepper.

**Current labels** (`index.cfm` line 27):
```coldfusion
<cfset stepLabels = ["Account Info", "Representation", "Contacts", "Auditions", "Reminders", "My Links", "Complete"]>
```

**Fix:** Change to single words:
```coldfusion
<cfset stepLabels = ["Account", "Reps", "Contacts", "Auditions", "Reminders", "Links", "Complete"]>
```

**Impact:** `index.cfm` line 27

### 3.6 Timezone and Date Format Layout Fix

**Problem:** Timezone is a `<select>` in a `col-md-6` but Date Format is a `<select>` placed next to a label on the same line. They are not on the same horizontal level.

**Current code** (`step1.cfm` lines 139-160):
```html
<div class="row g-3 mt-1">
    <div class="col-md-6">
        <label class="form-label">Timezone *</label>
        <select class="form-select" name="timezoneId" required>...</select>
    </div>
    <div class="col-md-6">
        <label class="form-label">Date Format *</label>
        <select class="form-select" name="dateFormatId" required>...</select>
    </div>
</div>
```

**Analysis:** The layout code itself looks correct (both in `col-md-6`). The visual misalignment likely comes from the timezone `<select>` being much wider due to long timezone names (e.g., "Acre Standard Time - Eirunepe") forcing different rendering. The date format select only has short values like "mm/dd/yyyy".

**Fix:**
- Make both selects full-width within their columns (they already are via `.form-select`)
- Ensure the Date Format select also has a `<select>` element with `class="form-select"` (not an inline dropdown) -- verified it does
- The real fix is shortening the timezone display names (see Section 4.1)

---

## 4. Step 1: Account Info -- Bugs and Features

### 4.1 Timezone: Default to Pacific + Organize List

**Problem:** The timezone dropdown starts at "Acre Standard Time - Eirunepe" (alphabetical first). No default is selected. The list is enormous (all world timezones). New users (actors, mostly US-based) have to scroll through hundreds of entries.

**Current code** (`step1.cfm` lines 42-44, 142-149):
```sql
SELECT tzid, tzname FROM timezones ORDER BY tzname
```
```html
<select class="form-select" name="timezoneId" required>
    <cfloop query="qTimezones">
        <option value="#qTimezones.tzid#" #val(qProfile.tzid) EQ qTimezones.tzid ? 'selected' : ''#>
            #encodeForHTML(qTimezones.tzname)#
        </option>
    </cfloop>
</select>
```

The browser auto-detection code (lines 204-218) tries to match `Intl.DateTimeFormat().resolvedOptions().timeZone` (IANA format like "America/Los_Angeles") against `qTimezones.tzname`, but the timezone table uses Windows-style names like "Pacific Standard Time", so the match fails.

**Fix (multi-part):**

**A. Reorganize the dropdown with optgroups:**
```html
<select class="form-select" name="timezoneId" required>
    <option value="">-- Select timezone --</option>
    <optgroup label="United States">
        <!-- Pacific, Mountain, Central, Eastern, Alaska, Hawaii -->
    </optgroup>
    <optgroup label="All Timezones">
        <!-- Everything else alphabetically -->
    </optgroup>
</select>
```

**B. Default to Pacific Standard Time:** Query for the Pacific timezone ID and pre-select it when `qProfile.tzid` is 0 (new user). This requires knowing the `tzid` for Pacific time.

**C. Fix browser auto-detection:** Add a mapping from IANA timezone names to the `timezones` table `tzid` values. The JS detection returns IANA names like "America/Los_Angeles" but the DB stores Windows-style names. Options:
- Add a `tz_iana` column to the timezones table with IANA identifiers
- Or maintain a JS mapping object: `{ "America/Los_Angeles": 15, "America/New_York": 10, ... }`

**D. Identify US timezone tzid values:** Need to query the timezones table to find:
- Pacific Standard Time
- Mountain Standard Time
- Central Standard Time
- Eastern Standard Time
- Alaska Standard Time
- Hawaii-Aleutian Standard Time

**Database change required:** Add `tz_iana VARCHAR(100)` column to `timezones` table, populate with IANA identifiers for at least US timezones.

**Impact:** `step1.cfm` (query + HTML), possibly `timezones` table DDL

### 4.2 "What is this step?" Shows No Additional Info

**Problem:** Clicking the tutorial toggle "What is this step?" on Step 1 collapses/expands but the tutorial content IS there (lines 60-64 of step1.cfm contain text). 

**Analysis:** The tutorial toggle has class `collapsed` and targets `#tutorial1`. The content div has class `collapse` (no `show`). Bootstrap collapse should work. If clicking does nothing visible, it may be because:
1. Bootstrap JS is not loaded in the wizard shell
2. The `data-bs-toggle="collapse"` requires Bootstrap 5 JS

**Current:** `index.cfm` loads `app.min.css` but does NOT explicitly load Bootstrap 5 JS bundle. The only JS loaded is jQuery 3.6.0 + Parsley + setup-wizard.js + tao-toast.js.

**Fix:** Add Bootstrap 5 JS bundle to `index.cfm`:
```html
<script src="/app/assets/js/bootstrap.bundle.min.js"></script>
```
This is needed for collapse, modals, and any other Bootstrap interactive components.

**Impact:** `index.cfm` (add script tag). This will also fix the tutorial toggles on ALL other steps.

### 4.3 Upload Photo: Doesn't Show Uploaded Photo

**Problem:** After uploading, the toast says "Photo uploaded" (success) but the avatar preview image doesn't update visually.

**Current code** (`step1.cfm` lines 191-193):
```javascript
success: function(r) {
    if (r.success) {
        $('##avatar-preview').attr('src', r.avatarUrl + '?t=' + Date.now());
        taoToast('Photo uploaded');
    }
}
```

**Analysis:** The `r.avatarUrl` returned by `upload-avatar.cfm` (line 58) is:
```coldfusion
<cfset avatarUrl = application.baseMediaUrl & "/users/" & userid & "/avatar.jpg">
```

If `application.baseMediaUrl` is not set correctly (or is an absolute filesystem path instead of a web URL), the browser can't display it. The upload itself works (file is saved to disk), but the returned URL might be wrong.

Also, the initial avatar display (line 73-74) uses a different URL pattern:
```html
<img src="/media-{dsn}/users/{userid}/avatar.jpg?t={tick}" ... onerror="this.src='...default-avatar.png'" />
```

The `onerror` fallback to `default-avatar.png` fires if the file doesn't exist, which works. But after upload, if the returned URL path differs from the relative path, the image won't load.

**Fix:**
1. In `upload-avatar.cfm`, construct the URL as a relative web path: `/media-{dsn}/users/{userid}/avatar.jpg`
2. Verify `application.baseMediaUrl` is set to `/media-{dsn}` (not a filesystem path)
3. After successful upload, use the known relative path pattern instead of relying on the server response:
```javascript
$('#avatar-preview').attr('src', '/media-' + window.TAO_WIZARD.dsn + '/users/' + window.TAO_WIZARD.userId + '/avatar.jpg?t=' + Date.now());
```
4. Add `dsn` to the `TAO_WIZARD` config object in `index.cfm`

**Impact:** `upload-avatar.cfm` (URL construction), `index.cfm` (add dsn to config), `step1.cfm` (JS update)

### 4.4 Upload Photo: Add Croppie Crop Modal

**Problem:** The wizard uploads the raw file without cropping. The main app uses Croppie.js (`/include/image-upload-contact.cfm`) for a crop modal with circular viewport, zoom, and rotation.

**Fix:** Integrate Croppie.js into the wizard photo upload flow:

1. Add Croppie CSS/JS to `index.cfm`:
```html
<link href="/app/assets/css/croppie.css" rel="stylesheet" />
<script src="/app/assets/js/croppie.min.js"></script>
```

2. In `step1.cfm`, after file selection:
   - Show a modal with Croppie viewport (200x200 circle, boundary 300x300)
   - Let user crop/zoom
   - On confirm, get cropped blob via `$uploadCrop.result({ type: 'blob', size: { width: 300, height: 300 } })`
   - Upload the cropped blob instead of the raw file

3. Add crop modal HTML to `step1.cfm`:
```html
<div class="modal fade" id="cropModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Crop Photo</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body text-center">
                <div id="crop-viewport"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary btn-sm" id="crop-save">Save Photo</button>
            </div>
        </div>
    </div>
</div>
```

4. JS flow:
```javascript
// On file select -> read as data URL -> bind to Croppie -> show modal
// On "Save Photo" click -> get cropped result -> upload via FormData -> update preview
```

**Dependency:** Requires Bootstrap JS (see 4.2) for the modal.

**Impact:** `index.cfm` (Croppie assets), `step1.cfm` (modal HTML + JS rewrite of upload handler)

### 4.5 Allow Email Change

**Problem:** The email field is `disabled` (line 100 of step1.cfm). Users cannot update their email address during setup.

**Current:**
```html
<input type="email" class="form-control" value="#...userEmail#" disabled />
```

**Fix:**
1. Remove `disabled`, add `name="email"` attribute
2. In `save-step1.cfm`, add email update logic:
   - Validate email format server-side
   - Check uniqueness against other users
   - Update `taousers_tbl.userEmail`
   - Update session email
3. Add a note below the field: "Changing your email will update your login credentials."
4. Consider: require email verification for changes? For MVP, skip verification but add a warning.

**Impact:** `step1.cfm` (enable field + name attr), `save-step1.cfm` (add email update + uniqueness check)

### 4.6 Timezone Reverts on Back Navigation

**Problem:** Navigating Next (step 1 -> step 2) saves the timezone. But clicking Back (step 2 -> step 1) reloads the step from the server. The query `val(qProfile.tzid) EQ qTimezones.tzid ? 'selected' : ''` should pick up the saved value from the DB, since `save-step1.cfm` updates `taousers_tbl.tzid`.

**Root cause analysis:**
1. `save-step1.cfm` updates the DB timezone (confirmed, line 41)
2. `load-step.cfm` calls `fetchUsers.cfm` to refresh session data (line 24)
3. `step1.cfm` queries `taousers` for `u.tzid` (line 10)

If the timezone still reverts, possible causes:
- The `fetchUsers.cfm` include caches user data and `session.bustUserCache` is not being honored
- The `save-step1.cfm` sets `session.bustUserCache = true` (line 105) but `load-step.cfm` also sets it (line 23), so it should be busted

**Fix:** Debug by:
1. Add `cflog` in `step1.cfm` to log `qProfile.tzid` when loading
2. Verify `fetchUsers.cfm` re-queries after cache bust
3. If the issue is timing (load-step runs before DB update is committed), add a small delay or ensure the SELECT reads from the correct isolation level
4. Alternative: Pass saved values back in the save response JSON, store in JS, and pre-populate on back navigation without re-querying

**Recommended approach:** Store form values in `sessionStorage` keyed by step number. When loading a step, check sessionStorage first and pre-fill from there. This also prevents data loss if the user navigates away and returns.

**Impact:** `setup-wizard.js` (add sessionStorage caching), `step1.cfm` (read from sessionStorage on load)

---

## 5. Step 2: Representation -- Issues

### 5.1 "Why add representation?" -- No Info on Click

**Same root cause as 4.2:** Bootstrap JS not loaded, so `data-bs-toggle="collapse"` doesn't work. The tutorial content exists in the HTML (lines 36-40 of step2.cfm) but the collapse toggle is non-functional.

**Fix:** Loading Bootstrap JS in `index.cfm` (Section 4.2) fixes this for all steps.

### 5.2 Functional Status

Step 2 works correctly: rep contacts are created with proper tags (role, My Rep Team, My Team). Verified in save-step2.cfm.

---

## 6. Step 3: Contacts -- Major Issues

### 6.1 "Why add contacts?" -- No Info on Click

**Same root cause as 4.2:** Bootstrap JS not loaded.

### 6.2 Import vs Manual Entry Toggle

**Problem:** The current two-panel layout shows both import and manual entry side by side. User wants a toggle to switch between them (to give manual entry more room).

**Fix:** Replace the two-panel layout with a tab/toggle UI:
```html
<div class="wizard-mode-toggle btn-group btn-group-sm mb-3" role="group">
    <input type="radio" class="btn-check" name="contactMode" id="mode-upload" value="upload" checked>
    <label class="btn btn-outline-primary" for="mode-upload">Import from File</label>
    <input type="radio" class="btn-check" name="contactMode" id="mode-manual" value="manual">
    <label class="btn btn-outline-primary" for="mode-manual">Add Manually</label>
</div>

<div id="panel-upload" class="wizard-panel-content">
    <!-- Full import UI here -->
</div>

<div id="panel-manual" class="wizard-panel-content" style="display:none;">
    <!-- Manual entry rows here -->
</div>
```

JS toggle:
```javascript
$('input[name="contactMode"]').on('change', function() {
    var mode = $(this).val();
    $('#panel-upload').toggle(mode === 'upload');
    $('#panel-manual').toggle(mode === 'manual');
});
```

**Impact:** `step3.cfm` (restructure layout), `setup-wizard.css` (toggle styles)

### 6.3 Dropzone: Full Contact Import Functionality

**Problem:** Currently, clicking the dropzone opens a popup window (`window.open('/app/contacts/?action=import', ...)`). This is a poor UX -- the import wizard opens in a separate window with no visual connection to the setup wizard. The user wants FULL import functionality carried over from the main app.

**Current import system:** The import-contacts-v3 flow is a complex multi-step process:
- Entry: `/include/import-contacts-v3.cfm` with JS at `/app/assets/js/contact-import-v3.js`
- Endpoints: `/ajax/import/upload.cfm`, `parse.cfm`, `columns.cfm`, `dry-run.cfm`, `rows.cfm`, `update-row.cfm`, `finalize.cfm`, `bulk-action.cfm`, `status.cfm`
- Full state machine: Upload -> Parse -> Map Columns -> Review -> Detect Dupes -> Finalize

**Fix (recommended approach -- embed via iframe modal):**

Since the import-contacts-v3 flow is a self-contained state machine with its own JS (25K+ file), the safest approach is to embed it in a modal iframe rather than rewriting it:

1. Add a full-screen modal to `step3.cfm`:
```html
<div class="modal fade" id="importModal" tabindex="-1">
    <div class="modal-dialog modal-xl modal-dialog-scrollable" style="max-width:95vw; height:90vh;">
        <div class="modal-content" style="height:90vh;">
            <div class="modal-header">
                <h5 class="modal-title">Import Contacts</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-0">
                <iframe id="import-iframe" src="" style="width:100%; height:100%; border:none;"></iframe>
            </div>
        </div>
    </div>
</div>
```

2. On dropzone click or file drop:
```javascript
$('#import-dropzone').on('click', function() {
    $('#import-iframe').attr('src', '/app/contacts-import-v3/');
    var modal = new bootstrap.Modal(document.getElementById('importModal'));
    modal.show();
});
```

3. On file drop, pass file to iframe via postMessage or just open the import wizard and let user re-select. Simpler: just open the import wizard URL.

4. When the import completes, detect via:
   - postMessage from iframe
   - Or poll for contact count change
   - Or add a "Done" button that closes the modal

5. After modal closes, refresh the contact count display on step3.

**Alternative approach (not recommended):** Inline the entire import-contacts-v3 state machine into step 3. This is extremely complex -- the import JS alone is 25K+ and has its own AJAX endpoints, polling, and state management. Would require major refactoring.

**Impact:** `step3.cfm` (add modal, modify dropzone handler), `setup-wizard.css` (modal styles), `index.cfm` (ensure Bootstrap JS loaded)

### 6.4 Manual Entry: Does Not Work

**Problem:** The manual quick-add rows have inputs but clicking "Next" with filled data does not create contacts.

**Analysis of the code path:**
1. `step3.cfm` defines `wizardCollectStepData()` (lines 181-195) which collects contact data from `.quick-add-row` elements
2. Data is posted to `save-step3.cfm` which deserializes the JSON and creates contacts

**Possible failure points:**
1. The `wizardCollectStepData` function serializes contacts as JSON string: `{ contacts: JSON.stringify(contacts) }`
2. The `save-step3.cfm` deserializes: `deserializeJSON(form.contacts)`
3. The `ContactService.create()` call might fail silently inside the try/catch
4. The entire cftransaction might roll back on error, with only a generic "Failed to save contacts" message

**Debugging approach:**
1. Check the browser network tab for the POST to `save-step3.cfm` -- is it returning success:false?
2. Check `TAO_setup_wizard.log` for error details
3. Test the `ContactService.create()` method independently
4. Verify the `contactdetails_tbl` INSERT permissions

**Likely fix:** The `ContactService.create()` expects specific parameters. Check if the method signature matches what save-step3.cfm passes:
```coldfusion
contactService.create({
    userid: userid,
    contactFullName: cName,
    contactStatus: "Active"
})
```
If `create()` expects positional args or different struct keys, it will throw inside the transaction.

**Impact:** `save-step3.cfm` (debug and fix ContactService call), possibly `step3.cfm` (JS data collection)

---

## 7. Step 4: Auditions -- Fails to Load

**Problem:** Navigating to Step 4 shows an error. The step fails to load entirely.

**Analysis:** `load-step.cfm` includes `step4.cfm`, which runs:
```sql
SELECT audmediatypeid, audmediatypename
FROM audmediatypes_user
WHERE userid = ? AND isDeleted = 0
```

**Possible failure causes:**
1. The `audmediatypes_user` table or view doesn't exist or the user has no rows bootstrapped
2. New users during setup may not have `audmediatypes_user` rows yet -- these are typically created during the legacy `user_setup_core.cfm` flow
3. If `isAuditionModule = 0`, the step should be skipped entirely, but the error suggests it IS loading

**Fix:**
1. Verify the `audmediatypes_user` table exists and has data for the test user
2. Add defensive handling: if `qMediaTypes.recordCount EQ 0`, show a simplified form with a text input for media type instead of the dropdown
3. Ensure the skip logic works: if `isAuditionModule = 0`, step 4 should never load. Check `index.cfm` line 24: `val(isauditionmodule)` -- where does this variable come from? It's `cfparam default="0"` but should be reading from session/user data. If `fetchUsers.cfm` doesn't set `isauditionmodule` in a scope visible to `index.cfm`, it defaults to 0, meaning step 4 is always skipped visually but the stepper still shows it.

**Additional issue:** `save-step4.cfm` line 20 sets `cookie.userid` because `INSaudprojects()` reads from cookie:
```coldfusion
<cfcookie name="userid" value="#userid#" />
```
This is a security concern (cookie can be tampered with) and a tech debt item.

**Fix for save-step4:** Refactor `AuditionProjectService.INSaudprojects()` to accept `userid` as a parameter instead of reading `cookie.userid`. If that's too risky, at minimum validate that `cookie.userid == session.userid` after setting.

**Impact:** `step4.cfm` (defensive handling), `save-step4.cfm` (cookie issue), `AuditionProjectService.cfc` (refactor INSaudprojects), `index.cfm` (fix isauditionmodule sourcing)

---

## 8. Step 5: Reminders -- Verification Needed

**Problem:** Untested. User asks "does this work?"

**Analysis of code:** The step 5 flow looks architecturally sound:
1. `step5.cfm` loads contacts, checks enrollment status, renders radio buttons
2. `save-step5.cfm` calls `RelationshipService.startSystemForContact()` for each enrollment
3. Each enrollment is self-transactional (line 21 comment: no nested transactions)
4. Ownership check prevents enrolling contacts from other users (line 28-34)

**Potential issues:**
1. `contactItemService.getContactTagStatus()` (line 30 of step5.cfm) -- does this method exist? If not, it throws and the whole step fails to load
2. If no contacts exist (all steps were skipped), the empty state is handled (lines 106-110)
3. The `fusystems` query (line 9-13) must return at least one Target and one Maintenance system

**Fix:** Test with a user who has contacts from steps 2-3. Verify `getContactTagStatus()` method exists in `ContactItemService.cfc`. If the method doesn't exist, remove or replace the call.

**Impact:** `step5.cfm` (verify/fix getContactTagStatus call)

---

## 9. Step 6: Links -- UX Improvements

### 9.1 Organize by Type/Panel

**Problem:** All links are displayed in a flat list sorted by custom flag then alphabetically. User wants them organized by type (Casting Profiles, Social Media, Other).

**Current query** (`step6.cfm` lines 9-17):
```sql
SELECT sl.id, sl.sitename, sl.siteurl, sl.siteicon, sl.iscustom,
       st.sitetypename
FROM sitelinks_user_tbl sl
LEFT JOIN sitetypes_user st ON st.sitetypeid = sl.sitetypeid AND st.userid = sl.userid
WHERE sl.userid = ? AND sl.isdeleted = 0
ORDER BY sl.iscustom ASC, sl.sitename ASC
```

The query already JOINs `sitetypes_user` and has `sitetypename`. This can be used for grouping.

**Fix:** Group links by `sitetypename` using optgroup-style panels:
```html
<cfset lastType = "">
<cfloop query="qLinks">
    <cfif qLinks.sitetypename NEQ lastType>
        <cfif len(lastType)></div></cfif>
        <h6 class="text-muted mt-3 mb-2">#encodeForHTML(qLinks.sitetypename)#</h6>
        <div class="link-type-group">
        <cfset lastType = qLinks.sitetypename>
    </cfif>
    <!-- link row -->
</cfloop>
```

**Impact:** `step6.cfm` (restructure loop with type grouping), `setup-wizard.css` (type group styles)

### 9.2 Easy Way to Uncheck/Skip Links

**Problem:** User wants an easy way to indicate which links they DON'T want (they don't use every casting platform).

**Fix:** Add a checkbox or toggle next to each link row:
```html
<div class="link-row" data-link-id="#qLinks.id#">
    <div class="form-check form-switch me-2">
        <input class="form-check-input" type="checkbox" checked data-field="enabled" />
    </div>
    <div class="link-name">#encodeForHTML(qLinks.sitename)#</div>
    <input type="url" class="form-control form-control-sm" placeholder="https://..." data-field="url" />
</div>
```

When the toggle is off, gray out the URL input and don't submit it. On save, unchecked links get `siteurl = ''` (cleared).

**Impact:** `step6.cfm` (add toggles), `setup-wizard.css` (toggle styles, disabled state), `save-step6.cfm` (handle enabled/disabled)

### 9.3 Additional Instructions

**Problem:** User wants more context about what links are for and how they'll be used.

**Fix:** Expand the tutorial content (currently just 2 sentences) and make it more prominent. Add per-type-group helper text:
- Casting Profiles: "Add your profile URLs for casting platforms you actively use"
- Social Media: "Optional -- these appear on your dashboard for quick access"
- Custom: "Add any other professional links you reference frequently"

**Impact:** `step6.cfm` (tutorial text, per-group subtitles)

---

## 10. Step 7: Completion / Finish -- Fails

**Problem:** Clicking "Finish Setup" (on Step 6) or "Go to My Dashboard" (on Step 7) triggers a POST to the save endpoint which fails.

**Analysis of the flow:**
1. On Step 6, clicking "Finish Setup" calls `save-step6.cfm` (POST)
2. On success, JS calls `loadStep(7)` to show the summary
3. On Step 7, clicking "Go to My Dashboard" calls `save-step7.cfm`
4. `save-step7.cfm` sets `userstatus = 'Active'`, `setup_step = 7`, `setup_completed_at = NOW()`

**The button label is confusing:** On step 6, the button says "Finish Setup" (via `setup-wizard.js` line 113) but it calls `save-step6.cfm`, NOT `save-step7.cfm`. After step 6 saves, it loads step 7 (the summary). The actual finish/activation happens when clicking "Go to My Dashboard" on step 7.

**If step 7 fails to load:** The summary page (`step7.cfm`) runs 6 queries. Any of these could fail:
- `audprojects` table query (line 34-37) -- if table doesn't exist for this user
- `fusystemusers` query (line 39-43)
- `sitelinks_user_tbl` query (line 45-49)
- Subqueries in `qProfile` for `tzname` and `dateformat` (lines 11-12) -- if tzid or dateFormatID is 0 or NULL

**If save-step7 fails:** The activation query is simple (`UPDATE taousers_tbl SET userstatus = 'Active'`). Unlikely to fail unless there's a DB connection issue.

**Debugging approach:**
1. Check `TAO_setup_wizard.log` for the error message
2. Check the browser network tab for the failing request
3. The `load-step.cfm` error handler (lines 51-62) catches exceptions and displays them in the step content area -- check if a red error div appears

**Likely fix:** Defensive handling in step7.cfm queries -- use `IFNULL()` or `LEFT JOIN` patterns to handle missing data:
```sql
SELECT userFirstName, userLastName, userEmail,
       IFNULL((SELECT tzname FROM timezones WHERE tzid = u.tzid), 'Not set') AS tzname,
       IFNULL((SELECT formatexample FROM dateformats WHERE id = u.dateFormatID), 'Not set') AS dateformat
FROM taousers u WHERE userid = ?
```

**Impact:** `step7.cfm` (defensive queries), `save-step7.cfm` (verify activation flow), `load-step.cfm` (better error display)

---

## 11. Cross-Cutting Concerns

### 11.1 Bootstrap JS Missing (Root Cause of Multiple Bugs)

The wizard `index.cfm` does NOT load Bootstrap 5 JavaScript. This breaks:
- All `data-bs-toggle="collapse"` tutorial toggles (Steps 1-6)
- Any modals (needed for crop, import)
- Tooltips, popovers

**Fix:** Add to `index.cfm` after jQuery:
```html
<script src="/app/assets/js/vendor/bootstrap.bundle.min.js"></script>
```

Verify the path -- check what Bootstrap JS file exists in the assets directory.

### 11.2 Step Data Persistence on Back Navigation

**Problem:** Navigating back reloads the step HTML from the server, which re-queries the DB. If the data was saved, it should reload correctly. But form-only changes (typed but not saved) are lost.

**Fix options:**
1. **Save on Back navigation:** Before loading the previous step, auto-save the current step. This changes the behavior -- users might not want to save incomplete data.
2. **SessionStorage cache (recommended):** Cache form data in `sessionStorage` on every input change. When loading a step, check sessionStorage first and pre-fill inputs from cached values.

**Impact:** `setup-wizard.js` (add sessionStorage read/write), each step's `wizardCollectStepData` (already collects data in the right format)

### 11.3 Email Field Validation (Step 1)

If email is made editable (Section 4.5), add:
- Client-side: Parsley email validation (`type="email"` + `required`)
- Server-side: regex validation + uniqueness check against `taousers_tbl.userEmail`
- Return specific error: "This email is already in use by another account"

### 11.4 Form State Indicator

Add visual feedback showing saved vs unsaved state:
- When a step loads from saved data, show a subtle "Saved" indicator
- When the user makes changes, show "Unsaved changes"
- This helps users understand that Back doesn't save

---

## 12. Database Changes

### 12.1 Timezones Table Enhancement

```sql
-- Add IANA timezone identifier column
ALTER TABLE timezones ADD COLUMN tz_iana VARCHAR(100) NULL AFTER tzname;

-- Populate US timezones (update tzid values based on actual data)
UPDATE timezones SET tz_iana = 'America/Los_Angeles' WHERE tzname LIKE '%Pacific%';
UPDATE timezones SET tz_iana = 'America/Denver' WHERE tzname LIKE '%Mountain%' AND tzname NOT LIKE '%Arizona%';
UPDATE timezones SET tz_iana = 'America/Phoenix' WHERE tzname LIKE '%Arizona%';
UPDATE timezones SET tz_iana = 'America/Chicago' WHERE tzname LIKE '%Central%' AND tzname NOT LIKE '%Australia%' AND tzname NOT LIKE '%Africa%';
UPDATE timezones SET tz_iana = 'America/New_York' WHERE tzname LIKE '%Eastern%' AND tzname NOT LIKE '%Australia%';
UPDATE timezones SET tz_iana = 'America/Anchorage' WHERE tzname LIKE '%Alaska%';
UPDATE timezones SET tz_iana = 'Pacific/Honolulu' WHERE tzname LIKE '%Hawaii%';

-- Rollback
ALTER TABLE timezones DROP COLUMN tz_iana;
```

### 12.2 Verify Existing Tables

Before deploying, verify these tables exist and have data for test users:
- `audmediatypes_user` (Step 4 depends on this)
- `sitetypes_user` (Step 6 grouping depends on this)
- `fusystems` with systemtype IN ('Target', 'Maintenance') (Step 5)
- `sitelinks_user_tbl` bootstrapped rows (Step 6)

---

## 13. Implementation Plan (Ordered by Priority)

### Phase 1: Unblock (make all steps loadable)
1. **Add Bootstrap JS** to `index.cfm` -- fixes all tutorial toggles and enables modals
2. **Fix Step 4 loading** -- defensive handling for empty `audmediatypes_user`
3. **Fix Step 7 loading** -- defensive queries with IFNULL
4. **Fix save-step7 (Finish)** -- debug and fix activation flow
5. **Fix manual entry in Step 3** -- debug ContactService.create() call

### Phase 2: Visual Polish
6. **Colored header** -- match error page style
7. **Widen panel** -- 820px -> 920px
8. **Raised/rounded card** -- 16px radius, deeper shadow
9. **Shorten breadcrumb labels** -- single words
10. **Body background** -- match error page
11. **Logo** -- create transparent PNG or use text branding

### Phase 3: Step 1 Improvements
12. **Timezone reorganization** -- US first + optgroups + default Pacific
13. **Fix timezone auto-detection** -- IANA mapping
14. **Fix avatar upload display** -- correct URL path
15. **Add Croppie crop modal** -- reuse from main app
16. **Enable email editing** -- with validation and uniqueness check
17. **Fix timezone revert on Back** -- sessionStorage caching

### Phase 4: Step 3 Contact Import
18. **Add toggle** -- import vs manual entry
19. **Embed import-v3** -- modal iframe with full import functionality
20. **Fix manual entry save** -- debug and fix

### Phase 5: Step 6 Links
21. **Organize by type** -- group links with sitetypename
22. **Add enable/disable toggles** -- easy opt-out
23. **Add instructions** -- per-type-group helper text

### Phase 6: Step 4 Hardening
24. **Fix cookie.userid dependency** -- refactor INSaudprojects()
25. **Verify step 5** -- test with contacts, fix getContactTagStatus

---

## 14. Testing Checklist

### Reset SQL (for repeatable testing)
```sql
-- Reset user 30 to pre-wizard state
UPDATE taousers_tbl SET
    setup_step = 0,
    setup_completed_at = NULL,
    userstatus = 'Setup',
    tzid = 0,
    dateFormatID = 0,
    avatarName = NULL
WHERE userid = 30;

-- Delete contacts created during wizard (preserve self-contact)
DELETE ci FROM contactitems_tbl ci
INNER JOIN contactdetails_tbl cd ON cd.contactid = ci.contactid
WHERE cd.userid = 30 AND cd.user_yn = 'N';

DELETE FROM contactdetails_tbl WHERE userid = 30 AND user_yn = 'N';

-- Delete auditions
DELETE FROM audroles WHERE new_userid = 30;
DELETE FROM audprojects WHERE userid = 30;

-- Delete reminder enrollments
DELETE FROM fusystemusers WHERE userid = 30;

-- Reset links
UPDATE sitelinks_user_tbl SET siteurl = '' WHERE userid = 30;
DELETE FROM sitelinks_user_tbl WHERE userid = 30 AND iscustom = 1;
```

### Per-Step Test Plan

**Step 1 (Account):**
- [ ] Header shows colored bar with branding
- [ ] Card is wider, rounded, raised
- [ ] Breadcrumbs show single words
- [ ] Tutorial toggle expands/collapses
- [ ] Tutorial content is helpful and visible
- [ ] First name, last name pre-filled from registration
- [ ] Email is editable with validation
- [ ] Timezone defaults to Pacific for new users
- [ ] US timezones appear first in dropdown
- [ ] Browser auto-detection selects correct timezone
- [ ] Date format dropdown aligned with timezone
- [ ] Upload photo opens crop modal
- [ ] Cropped photo saves and displays in preview
- [ ] Next saves all fields
- [ ] Back from Step 2 retains Step 1 values

**Step 2 (Reps):**
- [ ] Tutorial toggle works
- [ ] Can add 1-5 rep cards
- [ ] Role toggle (Agent/Manager/Publicist) works
- [ ] Next creates contacts with correct tags
- [ ] Back from Step 3 shows previously entered reps

**Step 3 (Contacts):**
- [ ] Toggle switches between Import and Manual modes
- [ ] **Import mode:** Dropzone opens import modal
- [ ] Import modal shows full import-contacts-v3 wizard
- [ ] After import completes, contact count updates
- [ ] **Manual mode:** Can add up to 10 rows
- [ ] Next creates contacts from manual rows
- [ ] Email vs phone auto-detection works

**Step 4 (Auditions -- if module enabled):**
- [ ] Step loads without error
- [ ] Media type dropdown populated (or fallback text input)
- [ ] Can add 1-5 audition entries
- [ ] Next creates audition projects/roles
- [ ] Step is properly skipped if audition module disabled

**Step 5 (Reminders):**
- [ ] Tutorial expanded by default
- [ ] System explanation cards visible
- [ ] Contact table shows contacts from Steps 2-3
- [ ] Rep contacts default to Maintenance
- [ ] Casting Director contacts default to Target
- [ ] Already enrolled contacts show "Enrolled" (disabled)
- [ ] Next enrolls selected contacts

**Step 6 (Links):**
- [ ] Links grouped by type
- [ ] Enable/disable toggles work
- [ ] Can add custom links
- [ ] Disabled links don't save URLs
- [ ] Finish Setup saves and loads Step 7

**Step 7 (Complete):**
- [ ] Summary shows correct counts for all sections
- [ ] "Go to My Dashboard" activates account
- [ ] Redirects to /app/ with success toast
- [ ] Subsequent login goes to dashboard (not wizard)

---

## 15. Risk Register

| # | Risk | Severity | Mitigation |
|---|------|----------|------------|
| 1 | ContactService.create() API mismatch breaks Steps 2-3 | High | Trace method signature before changing calls |
| 2 | Import-v3 iframe loses session/CSRF | High | Same domain, same session cookie. Test CSRF pass-through |
| 3 | Croppie.js conflicts with existing app assets | Medium | Load conditionally only on wizard pages |
| 4 | Timezone table schema change breaks other pages | Medium | tz_iana is additive (nullable column). No existing code references it |
| 5 | Step 4 cookie.userid refactor breaks main audition flow | High | Test INSaudprojects() from both wizard and main app after change |
| 6 | save-step7 activation fails silently, user stuck in Setup | Critical | Add retry UI + manual activation path for support |
| 7 | Email change without verification enables account takeover | Medium | For MVP, log email changes and notify old address |

---

## 16. Architecture Notes for CF Expert Review

### Session Flow
```
ThriveCart Purchase -> /setup/index.cfm (account creation with UUID)
                   -> /setup/setup2.cfm (legacy bootstrap: creates self-contact, bootstraps audmediatypes_user, sitelinks, etc.)
                   -> Redirect to /app/setup-wizard/ (P11 wizard)
                   -> Steps 1-7
                   -> save-step7: userstatus = 'Active', setup_completed_at = NOW()
                   -> Redirect to /app/ (dashboard)
```

### Key Questions for Review
1. Does `setup2.cfm` / `user_setup_core.cfm` reliably bootstrap all required data (audmediatypes_user, sitelinks_user_tbl, self-contact, fusystems)? If not, the wizard will fail on steps that query this data.
2. Is `ContactService.create()` the correct method? What is its exact signature? Are there newer methods?
3. What is the correct path to Bootstrap 5 JS in the assets directory?
4. Should email changes during setup require verification, or is post-verification acceptable?
5. Is there a cleaner way to handle the step 4 `cookie.userid` dependency than the current workaround?
6. The `contactItemService.getContactTagStatus()` in step5.cfm -- does this method exist? What does it return?
