# P11 -- Multi-Step Onboarding Wizard: Authoritative Design Document

**Status:** Phase 1 complete -- design approved, ready for Phase 2 implementation
**Priority:** LOW (largest single feature -- design-first approach)
**Dependencies:** P5 (deleted users -- DONE), P6 (three-status management -- DONE)
**Date:** 2026-04-07
**Author:** Kevin (design decisions), Claude Code (draft generation), Kevin (final authority)

---

## 1. Executive Summary

Replace the current minimal setup flow (`setup/index.cfm` -> `setup2.cfm` -> `setup-complete.cfm`) with a guided 7-step onboarding wizard. Each step collects data, can be skipped, and includes a collapsible tutorial section explaining why the step matters. The wizard runs after account creation and before first dashboard access.

**Current flow:** UUID email link -> create password -> auto-bootstrap lookups/folders -> "Go to Dashboard" button. The user lands on an empty dashboard with no contacts, no reminders, no audition prefs, and no casting profile links.

**Proposed flow:** UUID email link -> create password -> 7-step wizard -> dashboard (populated with contacts, reminders, links from day one).

The account creation step (password, user record INSERT, ThriveCart status flip, lookup/folder bootstrap) remains unchanged. The wizard inserts between the existing `setup2.cfm` processing and the `setup-complete.cfm` redirect.

### The Seven Steps

| Step | Title | Purpose | Can Skip |
|------|-------|---------|----------|
| 1 | Welcome and Account Info | Name, email, timezone, date format, avatar | No (anchor step, but defaults allow click-through) |
| 2 | Add Your Representation | Agent, manager, publicist contacts | Yes |
| 3 | Import or Add Contacts | CSV/VCF import or manual quick-add | Yes |
| 4 | Import or Add Auditions | CSV import or manual audition entry | Yes (auto-skipped if audition module off) |
| 5 | Relationship Reminders | Explain systems, enroll contacts from steps 2-3 | Yes |
| 6 | My Links | Casting profiles, social media, website | Yes |
| 7 | Completion | Summary, status flip Setup -> Active, redirect to dashboard | No (terminal step) |

---

## 2. Critical Architectural Decisions

### 2.1 Wizard location: `/app/setup-wizard/` (NOT `/setup/`)

<!-- REVIEW FIX C1: Updated justification. Finding A19 (session isolation) was resolved in
     issue #1615/#1646 -- setup/Application.cfc now uses the same app name as app/Application.cfc.
     The wizard still lives under /app/ for the reasons listed below. -->

The wizard MUST live under `/app/setup-wizard/` for three reasons:

1. **Auth guard integration.** The existing `onRequestStart()` auth gate in `app/Application.cfc` (line ~368-372) already validates `session.userid`. Placing the wizard under `/app/` means the guard protects all wizard endpoints automatically. Under `/setup/`, we would need to duplicate or extend the auth logic.

2. **Session timeout.** `setup/Application.cfc` has a 30-minute session timeout. `app/Application.cfc` has a 9-hour-20-minute timeout. A user working through a 7-step wizard needs the longer timeout window.

3. **Access to main app includes.** The wizard reuses components from `include/`, `services/`, and `app/assets/`. Living under `/app/` ensures these paths resolve consistently.

**Note:** The `/setup/Application.cfc` session isolation issue (finding A19 in `06-architecture.md`) was **resolved** in issues #1615/#1646. `setup/Application.cfc` now uses `this.name = "TAO_" & envLabel`, sharing the same session scope as the main app. This is no longer a factor in the wizard placement decision.

**File location:** All wizard files go under `/app/setup-wizard/`. AJAX endpoints go under `/ajax/setup-wizard/`. The existing `/setup/` files are not modified -- see section 11 for disposition.

### 2.2 Single-page AJAX shell (not separate pages)

The wizard is a single page (`/app/setup-wizard/index.cfm`) that loads step content via AJAX. This keeps the progress bar, navigation, and tutorial state in the DOM without full page reloads. Consistent with TAO's AJAX-first patterns. Import sub-flows (steps 3-4) open in modal overlays on top of the wizard shell.

### 2.3 DB-persisted wizard progress (not session-only)

The `setup_step` column on `taousers_tbl` tracks progress. This survives browser close, session expiry, and enables dropout visibility for admin. The session mirrors the DB value for fast reads.

### 2.4 Step 4 conditionally shown based on `isAuditionModule`

If `taousers_tbl.isAuditionModule = 0`, Step 4 is auto-skipped entirely. The progress bar renders 6 visual steps (no gap, no "N/A" marker -- renumber visually). The `setup_step` column increments from 3 directly to 5.

### 2.5 Setup guard blocks main app access

Users with `userstatus = 'Setup'` cannot access `/app/` pages. The guard in `app/Application.cfc` `onRequestStart` redirects them to the wizard. The guard whitelists `/app/setup-wizard/`, `/ajax/`, `/login`, and `/logout` paths.

### 2.6 Import sub-flows open in modals

When the user chooses the import path in steps 3-4, the existing import flow opens in a Bootstrap modal overlay. The wizard shell (progress bar, step indicator) remains visible behind it so the user knows they're still in the wizard. When the import completes or is cancelled, the modal closes and the wizard step advances.

### 2.7 Existing setup code left intact

The current `setup/` files are not modified or removed. The wizard is a parallel path. Decommissioning the old flow is a separate future prompt after the wizard is validated in production. See section 11.

---

## 3. Step Specifications

### Step 1: Welcome and Account Info

**Purpose:** Confirm identity, set preferences, upload avatar. This is the anchor step that cannot be skipped, but all fields are pre-filled or have defaults so the user can click "Next" immediately.

**Database tables:**

| Table | Operation | Columns |
|-------|-----------|---------|
| `taousers_tbl` | UPDATE | `userFirstName`, `userLastName`, `tzid`, `dateformatid`, `avatarname` |
| `contactdetails_tbl` | UPDATE | `contactFullName`, `contactNickname`, `contactPronoun` (on self-contact where `user_yn = 'Y'`) |
| `contactitems_tbl` | UPSERT | Primary phone item (valueCategory='Phone', valueType='Mobile', primary_yn='Y') on self-contact |
| `timezones` | READ | Timezone picklist |
| `dateformats` | READ | Date format picklist |

**Fields:**

| Field | Required | Pre-filled From | Widget | Validation |
|-------|----------|-----------------|--------|------------|
| First name | Yes | `taousers_tbl.userFirstName` | Text input | Min 1 char |
| Last name | Yes | `taousers_tbl.userLastName` | Text input | Min 1 char |
| Email | Display-only | `taousers_tbl.userEmail` | Disabled input | N/A (read-only) |
| Nickname | No | `contactdetails.contactNickname` (likely empty) | Text input | Max 100 chars |
| Pronouns | No | `contactdetails.contactPronoun` | Dropdown: He/Him, She/Her, They/Them, Custom | Custom shows text input |
| Primary phone | No | Existing phone item on self-contact if any | Tel input | Parsley phone |
| Timezone | Yes | Browser detection via `Intl.DateTimeFormat().resolvedOptions().timeZone`, fallback `America/Los_Angeles` | Select dropdown | Must match `timezones` table value |
| Date format | Yes | System default (MM/DD/YYYY) | Select dropdown | Must match `dateformats` table ID |
| Profile photo | No | Default avatar | File upload + circular preview | JPEG/PNG, max 5MB |

**Skip behavior:** Cannot skip. But name fields are pre-filled from registration and timezone/date format have sensible defaults, so the user can click "Next" without changing anything. This ensures every user passes through the wizard entry point.

**Tutorial content (collapsible, default collapsed):**
> "Welcome to The Actors Office! TAO helps you manage industry contacts, track auditions, and stay on top of your relationships. This wizard will help you set up the basics -- you can skip any step and come back later."

**Save endpoint:** `POST /ajax/setup-wizard/save-step1.cfm`

**Request body:**
```
firstName, lastName, nickname, pronouns, pronounCustom, phone,
timezoneId, dateFormatId, csrfToken
```

**Response:** `{success: boolean, message: string}`

**Save logic:**
1. Validate CSRF token (see section 4.5 for the custom `session.csrf_token` pattern)
2. Validate `session.userid` exists
3. UPDATE `taousers_tbl` SET `userFirstName`, `userLastName`, `tzid`, `dateformatid` WHERE `userid = session.userid`
4. Find self-contact: SELECT `contactid` FROM `contactdetails_tbl` WHERE `userid = session.userid AND user_yn = 'Y'`
5. UPDATE `contactdetails_tbl` SET `contactFullName = firstName + ' ' + lastName`, `contactNickname`, `contactPronoun` WHERE `contactid = selfContactId`
6. Phone upsert on self-contact:
   - SELECT from `contactitems_tbl` WHERE `contactid = selfContactId AND valueCategory = 'Phone' AND primary_yn = 'Y'`
   - If exists: UPDATE `valuetext = phone`
   - If not: INSERT into `contactitems_tbl` (contactid, userid, valueCategory='Phone', valueType='Mobile', valuetext=phone, primary_yn='Y', itemStatus='Active')
7. UPDATE `taousers_tbl` SET `setup_step = 1` WHERE `userid = session.userid`
8. SET `session.setup_step = 1`
9. Return `{success: true}`

**Avatar upload:** Separate endpoint `POST /ajax/setup-wizard/upload-avatar.cfm`. Accepts JPEG/PNG, max 5MB. Resizes using existing avatar handling pattern. Saves to user media directory. Updates `taousers_tbl.avatarname`. Returns `{success: true, avatarUrl: "..."}`. Avatar upload is independent of the step save -- it fires on file selection, not on "Next".

**Transaction scope:** Wrap items 3-6 in a single `<cftransaction>`.

**Pre-fill on re-entry:** Query current values from `taousers` + `contactdetails` + `contactitems` for self-contact. Pre-populate all fields.

**UI wireframe:**
- Full-width card centered in the wizard layout (no sidebar navigation from main app)
- TAO logo + "Welcome to The Actors Office" heading
- Progress stepper bar across the top (reuse `.import-stepper` CSS pattern from `include/import-contacts-v3.cfm` lines 217-269)
- Form fields single-column, stacked vertically
- Avatar upload: circular preview area (reuse `.tao-avatar--lg` from `app/assets/css/tao-components.css`) with "Upload Photo" button and drag-drop zone
- Collapsible tutorial panel below the heading (Bootstrap `.collapse` with chevron toggle, Lucide `chevron-down` / `chevron-up`)
- Footer: "Next" button right-aligned. No "Back" on step 1. No "Skip" on step 1.

---

### Step 2: Add Your Representation

**Purpose:** Quick-add agent, manager, or publicist contacts. These are the people actors interact with most frequently. Getting them in early means reminders (Step 5) can reference them immediately.

**Database tables:**

| Table | Operation | Columns |
|-------|-----------|---------|
| `contactdetails_tbl` | INSERT | `userid`, `contactFullName`, `contactTitle`, `contactStatus='Active'`, `contactCreationDate=NOW()` |
| `contactitems_tbl` | INSERT | Email (valueCategory='Email', valueType='Business', primary_yn='Y'), Phone (valueCategory='Phone', valueType='Work', primary_yn='Y'), Company (valueCategory='Company', valueType='Company', valueCompany=company), Tag: role (valueCategory='Tag', valueType='Tags', valuetext='Agent'/'Manager'/'Publicist'), Tag: 'My Rep Team', Tag: 'My Team' |

**Note on tags:** Tags are stored in `contactitems_tbl` with `valueCategory = 'Tag'` and `valueType = 'Tags'`. There is no separate `tagscontact_tbl`. The role value (Agent, Manager, Publicist) becomes the `valuetext` of a tag item. `My Rep Team` and `My Team` are additional tag items on the same contact.

**Fields (per rep card, repeatable 1-5):**

| Field | Required | Widget | Validation |
|-------|----------|--------|------------|
| Role | Yes | Button group: Agent / Manager / Publicist / Custom | Custom shows text input, max 40 chars |
| Full name | Yes | Text input | Min 2 chars |
| Company/Agency | No | Text input | Max 255 chars |
| Phone | No | Tel input | Parsley phone |
| Email | No | Email input | Parsley email |

**Skip behavior:** "I'll add this later" link below the cards. Skipping writes nothing. The user can add representation contacts anytime from the main Contacts module.

**Tutorial content (collapsible, default collapsed):**
> "Your agent, manager, and publicist are key contacts you'll interact with regularly. Adding them now means TAO can help you track communications and set up relationship reminders for them."

**Save endpoint:** `POST /ajax/setup-wizard/save-step2.cfm`

**Request body:** JSON array of rep objects: `[{role, name, company, phone, email}, ...]`

**Response:** `{success: boolean, message: string, data: {contactsCreated: N}}`

**Save logic:**
1. Validate CSRF token and `session.userid`
2. For each rep with a non-empty name:
   a. INSERT into `contactdetails_tbl` (`userid`, `contactFullName`, `contactTitle = role`, `contactStatus = 'Active'`, `contactCreationDate = NOW()`)
   b. Get new `contactid` from insert result
   c. INSERT contact items into `contactitems_tbl`:
      - Email item (if provided): `valueCategory='Email', valueType='Business', valuetext=email, primary_yn='Y', itemStatus='Active'`
      - Phone item (if provided): `valueCategory='Phone', valueType='Work', valuetext=phone, primary_yn='Y', itemStatus='Active'`
      - Company item (if provided): `valueCategory='Company', valueType='Company', valueCompany=company, itemStatus='Active'`
      - Tag: `valueCategory='Tag', valueType='Tags', valuetext=role` (e.g., 'Agent')
      - Tag: `valueCategory='Tag', valueType='Tags', valuetext='My Rep Team'`
      - Tag: `valueCategory='Tag', valueType='Tags', valuetext='My Team'`
   d. All inserts use `cfqueryparam` with correct `cfsqltype`
3. UPDATE `taousers_tbl` SET `setup_step = 2`
4. SET `session.setup_step = 2`
5. Return `{success: true, data: {contactsCreated: N}}`

**Transaction scope:** All rep inserts in a single `<cftransaction>`. If any insert fails, roll back all reps.

**Idempotency on re-entry:** If user navigates back to Step 2 and submits again, match submitted rep names against existing `My Rep Team` tagged contacts for this user. Update existing matches. Create new ones. Do NOT delete previously created reps that the user didn't include this time -- deletion is destructive and out of wizard scope.

**Representation tags -- system tags:** The tags "Agent", "Manager", "Publicist" should be treated as system tags. CC must verify during Phase 2 recon whether these already exist in `tags_user` for the user (seeded by `user_setup_core.cfm` bootstrap). If not, the wizard creates them as tag items on the contact. They do not need to be in `tags_user` to function as `contactitems` tags -- they just need to be `contactitems_tbl` rows with `valueCategory='Tag'`.

**Empty submission (0 reps):** Valid. Step advances with `contactsCreated: 0`.

**UI wireframe:**
- Heading: "Who represents you?"
- Three card slots side by side (responsive: stack on mobile)
- Each card: role pill selector at top (Agent / Manager / Publicist / Custom), then name/company/phone/email fields stacked
- "Add another" link if user wants additional cards (max 5 total)
- Cards use a clean Bootstrap card layout
- Remove card button (Lucide `x-circle`) on each card, hidden if only 1 card
- Footer: "Back" (left), "Skip -- I'll add this later" (center), "Next" (right)

---

### Step 3: Import or Add Contacts

**Purpose:** Seed the contact list with industry contacts. This is the foundation -- contacts feed the reminder system in Step 5.

**Database tables:**

| Table | Operation | Columns |
|-------|-----------|---------|
| `contactdetails_tbl` | INSERT | Manual quick-add path |
| `contactitems_tbl` | INSERT | Email, phone, company, tags for manual contacts |
| `import_v3_jobs` | INSERT | Import path (handled by existing import V3 flow) |
| `import_v3_rows`, `import_v3_facts` | INSERT | Import path (handled by existing import V3 flow) |

**Two paths:**

**Path A -- Import from file:**
- Drag-and-drop zone accepting CSV, XLS, XLSX, VCF
- Clicking "Import" opens the existing import-contacts-v3 flow in a Bootstrap modal overlay
- The import flow runs its full lifecycle (upload -> parse -> map -> review -> finalize) inside the modal
- When import completes or is cancelled, the modal closes and the user is back on the wizard Step 3
- The wizard does NOT re-implement import -- it opens the existing `include/import-contacts-v3.cfm` in a modal context
- After modal close, the wizard reads the contact count to update the step summary

**Path B -- Manual quick-add:**

| Field | Required | Widget | Validation |
|-------|----------|--------|------------|
| Full name | Yes | Text input | Min 2 chars |
| Tag | No | Dropdown: Casting Director, Producer, Director, Writer, Showrunner, Other | Maps to contactitems tag |
| Email or Phone | No | Text input, auto-detect: contains `@` = email, else = phone | Parsley email or phone based on detection |
| Company | No | Text input | Max 255 chars |

Repeatable rows -- "Add another contact" appends a new row. Start with 3 empty rows, max 10.

**Skip behavior:** "I'll add contacts later" link. Skipping writes nothing.

**Tutorial content (collapsible, default collapsed):**
> "Contacts are the foundation of your network in TAO. You can import a spreadsheet of existing contacts or add a few key people manually. Don't worry about getting everyone in now -- you can always import more later."

**Save endpoint (manual path):** `POST /ajax/setup-wizard/save-step3.cfm`

**Request body:** JSON array: `[{name, tag, emailOrPhone, company}, ...]`

**Response:** `{success: boolean, message: string, data: {contactsCreated: N}}`

**Save logic (manual path):**
1. Validate CSRF token and `session.userid`
2. For each row with a non-empty name:
   a. INSERT into `contactdetails_tbl` (`userid`, `contactFullName`, `contactStatus='Active'`, `contactCreationDate=NOW()`)
   b. Get new `contactid`
   c. INSERT contact items:
      - If email detected (contains @): `valueCategory='Email', valueType='Business', valuetext=value, primary_yn='Y', itemStatus='Active'`
      - If phone detected: `valueCategory='Phone', valueType='Work', valuetext=value, primary_yn='Y', itemStatus='Active'`
      - If company provided: `valueCategory='Company', valueType='Company', valueCompany=company, itemStatus='Active'`
      - If tag selected: `valueCategory='Tag', valueType='Tags', valuetext=tag`
   d. **CD tag detection:** If tag is "Casting Director", this contact's `systemscope` will be 'Casting Director' in Step 5. The scope is determined at Step 5 read time by checking `ContactItemService.getContactTagStatus()` -- no special column needed at insert time.
3. UPDATE `taousers_tbl` SET `setup_step = 3`
4. Return `{success: true, data: {contactsCreated: N}}`

**Import path save:** When the import modal completes, the import V3 flow has already written contacts to `contactdetails_tbl` and `contactitems_tbl`. The wizard only needs to increment `setup_step` to 3. A separate AJAX call (`POST /ajax/setup-wizard/complete-import-step.cfm`) handles this.

**Transaction scope (manual path):** All contacts in a single `<cftransaction>`.

**Idempotency on re-entry:** Same as Step 2 -- match by name, update existing, create new, never delete.

**Empty submission:** Valid. Step advances.

**UI wireframe:**
- Heading: "Add a few industry contacts"
- Two-panel layout: left panel "Import from file" with drag-drop zone and file type badges (CSV, XLS, XLSX, VCF); right panel "Or add manually" with quick-add rows
- Import panel reuses the file upload visual from `include/import-contacts-v3.cfm`
- Manual panel: stacked rows, each row has name / tag dropdown / email-or-phone / company, plus a remove (Lucide `x`) icon
- "Add another contact" link at bottom of manual panel
- Alternative text between panels: "or"
- Footer: "Back" / "Skip" / "Next"

---

### Step 4: Import or Add Auditions

**Purpose:** Seed the audition history so the audition tracker has data from day one. Only shown if `taousers_tbl.isAuditionModule = 1`.

**Conditional display:** If `isAuditionModule = 0`, this step is auto-skipped. The progress bar renders 6 visual steps (steps 1-3, then 5-7, renumbered visually as 1-6). The `setup_step` column increments from 3 directly to 5.

**Database tables:**

| Table | Operation | Columns |
|-------|-----------|---------|
| `audprojects` | INSERT | Manual path: project name, type, category |
| `audroles` | INSERT | Manual path: role name, audition date |
| Audition xref tables | INSERT | As required by audition service create pattern |
| `import_auditions_jobs` | INSERT | Import path (if audition import flow exists) |

**Note:** Auditions are stored in `audprojects` (project level) and `audroles` (role level), NOT in `events_tbl` or `auditions_tbl`. CC must use the audition service methods for creation (see section 4.7 for method name verification requirements).

<!-- REVIEW FIX C4: AuditionProjectService.INSaudprojects() uses cookie.userid internally
     instead of accepting a userid parameter. Phase 2 must either refactor the method to
     accept userid as a parameter, or set cookie.userid = session.userid before calling.
     Document as // TECH-DEBT. -->

**Phase 2 recon requirement (audition services):** CC must read `AuditionProjectService.cfc` and `AuditionRoleService.cfc` to get exact method signatures. **Known issue:** `INSaudprojects()` uses `cookie.userid` internally instead of accepting a `userid` parameter. Phase 2 must either refactor the method to accept `userid` as a parameter, or ensure `cookie.userid` matches `session.userid` before calling. Mark as `// TECH-DEBT`.

**Two paths:**

**Path A -- Import:** Same modal pattern as Step 3. If an audition import flow exists, open it in a modal. If no audition import flow exists, this button is disabled with label "Coming soon -- import auditions from the Auditions page after setup."

**Path B -- Manual quick-add:**

| Field | Required | Widget | Validation |
|-------|----------|--------|------------|
| Project name | Yes | Text input | Min 2 chars |
| Audition type | No | Select dropdown (from `audmediatypes`) | Must match lookup value |
| Category | No | Select dropdown (from `audcategories` or similar lookup) | Must match lookup value |
| Casting director | No | Text input or dropdown of contacts from Step 3 | Free text OK |
| Date | No | Date picker | Valid date |
| Notes | No | Textarea | Max 500 chars |

Repeatable -- "Add another audition" appends a new form block.

**Audition preferences sub-section:** Below the add/import area, include a "Set your defaults" collapsible section with:

| Preference | Widget | Source Table | Purpose |
|------------|--------|-------------|---------|
| Union status | Checkboxes | `audunions` | SAG-AFTRA, AEA, Non-Union |
| Primary submission sites | Checkboxes | Seed from `audsubmitsites_user` defaults | Actors Access, Casting Networks, Backstage |
| Media types I audition for | Checkboxes | `audmediatypes` | Film, TV, Commercial, Theater, Voiceover, New Media |
| Playing age range | Two dropdowns (min, max) | `audageranges` | e.g., 25-35 |

These preferences become default filters and pre-fills when logging future auditions. CC must verify during Phase 2 recon which per-user preference tables store these and their exact column structure. Known tables: `audsubmitsites_user`, `audmediatypes_user`, `audnetworks_user`, `audplatforms_user`.

**Skip behavior:** "I'll add auditions later" link. Skipping writes nothing.

**Tutorial content (collapsible, default collapsed):**
> "Tracking auditions helps you see patterns in your career -- which casting directors call you back, what types of roles you book, and how your audition frequency changes over time."

**Save endpoint:** `POST /ajax/setup-wizard/save-step4.cfm`

**Request body:**
```
auditions: [{projectName, type, category, castingDirector, date, notes}, ...],
preferences: {unions: [...], submissionSites: [...], mediaTypes: [...], ageMin, ageMax}
```

**Response:** `{success: boolean, message: string, data: {auditionsCreated: N, prefsSet: boolean}}`

**Save logic:**
1. Validate CSRF and session
2. For each audition with a non-empty project name:
   a. Use audition service create methods (CC must read the service during Phase 2 recon to get exact method signatures and required fields -- see section 4.7)
   b. Create `audprojects` record + `audroles` record + required xref entries
3. Save preferences to per-user preference tables (INSERT or UPSERT pattern -- CC must verify table structure)
4. UPDATE `taousers_tbl` SET `setup_step = 4` (or 5 if this step was auto-skipped)
5. Return response

**Transaction scope:** All auditions in a single `<cftransaction>`. Preferences in a separate transaction (they're independent -- a pref save failure shouldn't roll back auditions).

**Empty submission:** Valid. Step advances.

**UI wireframe:**
- Same two-panel layout as Step 3 (import left, manual right)
- Manual side: single-column form for one audition at a time, "Add another" appends below
- Preferences sub-section below both panels: collapsible accordion "Set your defaults" with checkbox groups
- Conditional render: entire step hidden when `isAuditionModule = 0`
- Footer: "Back" / "Skip" / "Next"

---

### Step 5: Relationship Reminders

**Purpose:** Explain the relationship system (most users won't know what Target vs. Maintenance means) and optionally enroll contacts from Steps 2-3 into starter workflows. This is where TAO's core value proposition clicks.

**THIS IS THE HIGHEST-RISK STEP.** The relationship enrollment chain is complex: `fusystems` -> `fuactions` (templates) -> `actionusers` (per-user copies) -> `fusystemusers` (enrollments) -> `funotifications` (reminders). Incorrect enrollment creates orphaned notifications or missed reminders.

**Database tables:**

| Table | Operation | Columns |
|-------|-----------|---------|
| `fusystems` | READ | System definitions (Target, Follow-up, Maintenance types) |
| `fusystemtypes` | READ | System type categories |
| `fuactions` | READ | Action templates per system (ordered by `actionOrder`) |
| `actionusers` | READ | Per-user action timing overrides |
| `contactdetails` | READ | User's contacts from Steps 2-3 |
| `contactitems` | READ | Tags on those contacts (for CD scope detection) |
| `fusystemusers_tbl` | INSERT | Enrollment records |
| `funotifications_tbl` | INSERT | First reminder notification per enrollment |

**Fields:**

| Field | Required | Widget |
|-------|----------|--------|
| System explanation | N/A | Read-only explanation cards (Target vs. Maintenance) |
| Contact checklist | No | Multi-select table: contact name, role/company, radio per row (Target / Maintenance / None) |

**Contact grouping logic:**

The checklist shows contacts created in Steps 2-3, grouped by scope:

| Group | Source | Suggested Default | How Scope Is Determined |
|-------|--------|-------------------|------------------------|
| Rep Team | Contacts tagged `My Rep Team` (Step 2) | Maintenance (pre-selected) | Tag match |
| Casting Directors | Contacts with CD tags | Target (pre-selected) | `ContactItemService.getContactTagStatus()` returns `systemscope = 'Casting Director'` when contact has a tag matching `tags_user WHERE tagtype = 'C'` |
| Other Industry | Remaining contacts from Step 3 | None (not pre-selected) | Default scope |

Cards with 0 contacts are hidden. If no contacts exist from Steps 2-3, show message: "You haven't added any contacts yet. You can set up reminders later from the Contacts page." with a "Back to Add Contacts" link.

**Skip behavior:** "I'll set these up later" link. Skipping enrolls nobody.

**Tutorial content (collapsible, DEFAULT EXPANDED -- this is the one step where the concept needs explanation):**
> "Relationship reminders are TAO's secret weapon. There are two systems:
>
> **Target** -- For people you want to work with but haven't built a relationship with yet. TAO will remind you to reach out on a structured schedule.
>
> **Maintenance** -- For people you've already connected with. TAO helps you stay in touch so relationships don't go cold.
>
> Select a few contacts below and choose a system. TAO will start generating reminders for you."

**Save endpoint:** `POST /ajax/setup-wizard/save-step5.cfm`

**Request body:** JSON array: `[{contactId, systemId}, ...]` (only contacts with a system selected, not "None")

**Response:** `{success: boolean, message: string, data: {contactsEnrolled: N}}`

**Save logic -- CRITICAL SECTION:**

The wizard MUST use the canonical enrollment function. It must NOT create a parallel enrollment path (there are already 6 INSERT paths for `fusystemusers` per WO-3.1 in `02-modernization-plan.md`).

**Phase 2 recon requirement:** CC must read `services/RelationshipService.cfc` and locate `startSystemForContact()`. **Confirmed to exist** (validated against codebase 2026-04-07). Method signature:

```cfml
<cffunction name="startSystemForContact" access="public" returntype="struct" output="false">
    <cfargument name="systemid" type="numeric" required="true" />
    <cfargument name="contactid" type="numeric" required="true" />
    <cfargument name="userid" type="numeric" required="true" />
    <cfargument name="startDate" type="date" required="false" default="#Now()#" />
    <cfargument name="notes" type="string" required="false" default="" />
```

Returns: `{ success: boolean, message: string, data: { suid: numeric, notificationsCreated: numeric } }`

This function:
1. Checks for existing active enrollment (FOR UPDATE lock -- duplicate prevention)
2. INSERTs into `fusystemusers_tbl` (systemid, contactid, userid, sustartdate=NOW(), sustatus='Active')
3. Retrieves system actions with user-specific overrides from `actionusers`
4. Creates first `funotifications_tbl` record with calculated `notstartdate`
5. Has a known N+1 pattern (1-2 queries per action row) -- acceptable for wizard use since enrollment count is small (3-10 contacts)
6. Handles its own transaction internally
7. Returns structured success/failure response

**The wizard calls `startSystemForContact()` directly.** No wrapper needed. Each call is self-contained and transaction-safe.

Save logic:
1. Validate CSRF and session
2. For each `{contactId, systemId}` pair:
   a. Verify `contactId` belongs to `session.userid` (security: prevent enrolling other users' contacts)
   b. Call `RelationshipService.startSystemForContact(contactid=contactId, systemid=systemId, userid=session.userid)`
   c. Check return value -- if duplicate enrollment detected, skip silently (not an error)
3. UPDATE `taousers_tbl` SET `setup_step = 5`
4. Return `{success: true, data: {contactsEnrolled: N}}`

**Transaction scope:** Each enrollment is self-transactional (the function handles its own `<cftransaction>`). The wizard does NOT wrap all enrollments in an outer transaction -- this avoids nested transaction issues.

**Empty submission (all set to None):** Valid. Step advances with `contactsEnrolled: 0`.

**UI wireframe:**
- Top section: two side-by-side explanation cards (Target and Maintenance) with Lucide icons (`target` and `refresh-cw`) and brief 2-sentence descriptions
- Below: contact table/checklist. Columns: avatar (small), name, role/company, radio group (Target / Maintenance / None). Default selections per the grouping logic above.
- If no contacts: centered message with "Back to Add Contacts" link
- Footer: "Back" / "Skip" / "Next"

---

### Step 6: My Links

**Purpose:** Add external profile links (casting sites, social media, personal website). Actors live on these sites -- having them one click away from the dashboard is a daily convenience.

**Database tables:**

| Table | Operation | Columns |
|-------|-----------|---------|
| `sitelinks_user_tbl` | UPDATE | `siteurl` for pre-populated link rows |
| `sitelinks_user_tbl` | INSERT | New custom link rows |
| `sitetypes_user` | READ | Link type picklist (pre-populated during account bootstrap) |

<!-- REVIEW FIX M3: "mylinks" is a query variable name in mylinks_pane.cfm, not a separate table.
     include/qry/mylinks_159_1.cfm calls SiteLinkUserService.SELsitelinks_user_23943().
     The underlying table is sitelinks_user_tbl. -->

**Note:** TAO has TWO link systems: (1) `sitelinks_user_tbl` for user-level "My Links" (dashboard quick-links), and (2) `contactitems_tbl` with `valueCategory = 'Acting Links'` / `'Social Profile'` on the self-contact. Step 6 writes to `sitelinks_user_tbl` because these are user-level dashboard links, not contact-level items. The `mylinks_pane.cfm` UI queries this same table via `SiteLinkUserService.SELsitelinks_user_23943()` -- `mylinks` is a query variable name, not a separate table. CC must verify this during Phase 2 recon by reading `include/mylinks_pane.cfm` and `include/qry/mylinks_159_1.cfm`.

**Fields:**

| Field | Required | Widget | Validation |
|-------|----------|--------|------------|
| Pre-populated link rows (one per bootstrap site type) | No | URL text input per row | Parsley URL |
| Custom link name | No | Text input | Max 100 chars |
| Custom link URL | No | URL text input | Parsley URL |

**Pre-populated rows** (seeded in `sitelinks_user_tbl` during account bootstrap via `user_setup_core.cfm`):
- Actors Access
- Casting Networks
- IMDb
- Backstage
- Instagram
- Website / Portfolio

Each row shows: site icon (from `sitetypes_user.typeIcon`), site name label (read-only), URL text input (user fills in their profile URL). The rows already exist in `sitelinks_user_tbl` from the bootstrap -- they just have empty URLs.

"Add custom link" button at bottom appends a new row with editable name + URL fields.

**Skip behavior:** "I'll add links later" link. Skipping leaves all URLs empty -- the link type records still exist in `sitelinks_user_tbl`, just without URLs.

**Tutorial content (collapsible, default collapsed):**
> "My Links gives you quick access to your casting profiles and social media. Fill in the URLs now so they're always one click away from your dashboard."

**Save endpoint:** `POST /ajax/setup-wizard/save-step6.cfm`

**Request body:** JSON array: `[{sitelinkId, siteurl}, ...]` for existing rows, plus `[{sitename, siteurl}]` for new custom links

**Response:** `{success: boolean, message: string}`

**Save logic:**
1. Validate CSRF and session
2. For each existing link (has `sitelinkId`):
   a. UPDATE `sitelinks_user_tbl` SET `siteurl = url` WHERE `id = sitelinkId AND userid = session.userid`
3. For each new custom link (no `sitelinkId`):
   a. INSERT into `sitelinks_user_tbl` (`userid`, `sitename`, `siteurl`, `sitetypeid` = default/custom type)
4. UPDATE `taousers_tbl` SET `setup_step = 6`
5. Return `{success: true}`

**Transaction scope:** All link updates/inserts in a single `<cftransaction>`.

**Pre-fill on re-entry:** Query `sitelinks_user_tbl` for this user. Show existing URLs in their fields.

**Empty submission:** Valid. Step advances.

**UI wireframe:**
- Heading: "Your casting profiles and links"
- Vertical list of link rows, each with: site icon, site name label, URL text input
- Simplified flat list (not the accordion from `mylinks_pane.cfm` -- wizard needs to be fast)
- "Add custom link" button at bottom (Lucide `plus-circle`)
- Footer: "Back" / "Skip" / "Finish Setup" (this is the last data-entry step)

---

### Step 7: Completion

**Purpose:** Show a summary of everything set up, flip user status from Setup to Active, and redirect to the dashboard.

**Database tables:**

| Table | Operation | Columns |
|-------|-----------|---------|
| `taousers_tbl` | UPDATE | `userstatus = 'Active'`, `setup_step = 7`, `setup_completed_at = NOW()` |

**Fields:** None -- read-only summary page.

**Summary display:**

| Section | Content | "Edit" Link Target |
|---------|---------|-------------------|
| Account | Name, email, timezone, date format | `/app/settings/` |
| Representation | Count of reps added, or "None added yet" | `/app/contacts/?filter=repteam` |
| Contacts | Count imported/added, or "None added yet" | `/app/contacts/` |
| Auditions | Count logged, or "Skipped" / "Module not enabled" | `/app/auditions/` |
| Reminders | Count of contacts enrolled, or "None set up yet" | `/app/reminders/` |
| Links | Count of links with URLs filled in | `/app/mylinks/` |

Each section has an "Edit" link pointing to the relevant app page for post-setup changes.

**Skip behavior:** Cannot skip -- terminal step.

**Tutorial content:** None needed on this step.

**Actions on "Go to My Dashboard" click:**
1. `POST /ajax/setup-wizard/save-step7.cfm`
2. UPDATE `taousers_tbl` SET `userstatus = 'Active'`, `setup_step = 7`, `setup_completed_at = NOW()` WHERE `userid = session.userid`
3. SET `session.userstatus = 'Active'` (clears the setup guard)
4. SET `session.setup_step = 7`
5. Return `{success: true, redirect: '/app/'}`
6. JS follows the redirect
7. On dashboard load, check `sessionStorage.taoWizardComplete` flag. If present, show welcome toast: "You're all set! Your first reminders will appear here." Clear the flag after showing.

The `sessionStorage.taoWizardComplete = true` flag is set by the wizard JS immediately before the redirect. This ensures the toast fires exactly once and survives the page navigation but not a new browser session.

**UI wireframe:**
- Lucide `check-circle` icon + "You're all set!" heading
- Summary cards in a 2x3 responsive grid (Bootstrap `col-md-4`)
- Each card: section icon, section name, count/status line, "Edit" link
- Large "Go to My Dashboard" primary button, centered below the grid
- No "Back" button -- once the user clicks "Go to Dashboard", the status flips to Active

---

## 4. Technical Architecture

### 4.1 File Inventory

**New files to create:**

```
app/setup-wizard/
  index.cfm                          -- Wizard shell (progress bar, nav, step container)

ajax/setup-wizard/
  load-step.cfm                      -- Returns step HTML fragment (GET, param: step)
  save-step1.cfm                     -- Step 1 save
  save-step2.cfm                     -- Step 2 save
  save-step3.cfm                     -- Step 3 save (manual path)
  save-step4.cfm                     -- Step 4 save
  save-step5.cfm                     -- Step 5 save
  save-step6.cfm                     -- Step 6 save
  save-step7.cfm                     -- Step 7 save (status flip)
  skip-step.cfm                      -- Skip endpoint (advances step without saving)
  upload-avatar.cfm                  -- Avatar upload (Step 1)
  complete-import-step.cfm           -- Marks step complete after import modal closes

app/assets/js/
  setup-wizard.js                    -- Wizard navigation, AJAX, history management

app/assets/css/
  setup-wizard.css                   -- Wizard-specific styles (minimal -- mostly Bootstrap)

database/migrations/
  P11_setup_wizard_columns.sql       -- Schema migration
  P11_setup_wizard_columns_ROLLBACK.sql -- Rollback
```

**Step content partials** (loaded by `load-step.cfm` based on step param):

```
app/setup-wizard/steps/
  step1.cfm                          -- Welcome and Account Info HTML
  step2.cfm                          -- Add Representation HTML
  step3.cfm                          -- Import or Add Contacts HTML
  step4.cfm                          -- Import or Add Auditions HTML
  step5.cfm                          -- Relationship Reminders HTML
  step6.cfm                          -- My Links HTML
  step7.cfm                          -- Completion Summary HTML
```

**Existing files to modify:**

| File | Change |
|------|--------|
| `app/Application.cfc` | Add setup guard in `onRequestStart()` (see section 4.3). Add `session.setup_step` and `session.userstatus` population in the post-login session setup block. |
| `setup/setup2.cfm` | Change redirect target from `setup-complete.cfm` to `/app/setup-wizard/` for new users. Keep existing redirect for the fallback path (see section 11). |
| `include/qry/fetchUsers.cfm` | Add `session.userstatus = userData.userStatus` and `session.setup_step = userData.setup_step` after the existing session variable population block (currently these values are fetched but not cached to session). |

<!-- REVIEW FIX C5: fetchUsers.cfm added to the files-to-modify table.
     Currently fetchUsers.cfm fetches userData.userStatus and userData.setup_step
     but does NOT cache them to session variables. The setup guard needs
     session.userstatus and session.setup_step to function. -->

**Existing files reused (no changes):**

| File | Reuse |
|------|-------|
| `include/import-contacts-v3.cfm` | Import stepper CSS/HTML pattern, opened in modal for Step 3 |
| `include/mylinks_pane.cfm` | Links UI pattern reference for Step 6 |
| `include/modal.cfm` | Modal wrapper for import sub-flows |
| `app/assets/css/tao-components.css` | `.tao-avatar--lg` for Step 1 avatar |
| Parsley.js | Form validation on all steps |
| Bootstrap 5 `.collapse` | Tutorial panels |

### 4.2 Progress Tracking

**Database column:** `taousers_tbl.setup_step TINYINT NOT NULL DEFAULT 0`

| Value | Meaning |
|-------|---------|
| 0 | Account created, wizard not started |
| 1-6 | Last completed step (user is on step N+1) |
| 7 | Wizard completed (userstatus = 'Active') |

**Session mirror:**
```
session.setup_step = userData.setup_step
```

Populated during login via `fetchUsers.cfm` (see files-to-modify table above). Updated by each save endpoint.

### 4.3 Setup Guard

Add to `onRequestStart()` in `app/Application.cfc`, after the existing auth check (line ~372):

```
IF session.userid exists
  AND session.userstatus = 'Setup'
  AND cgi.SCRIPT_NAME does NOT contain '/setup-wizard/'
  AND cgi.SCRIPT_NAME does NOT contain '/ajax/'
  AND cgi.SCRIPT_NAME does NOT contain '/login'
  AND cgi.SCRIPT_NAME does NOT contain '/logout'
  AND cgi.SCRIPT_NAME does NOT end with '.css' or '.js' or '.png' or '.jpg' or '.gif' or '.svg' or '.woff'
THEN
  cflocation to '/app/setup-wizard/' addtoken='false'
```

This prevents Setup-status users from reaching the main app. They must complete or skip through the wizard first.

**Edge case:** Users created by admin (manual ThriveCart record) who never clicked the email link have `userstatus = 'Setup'` but no password. The email link flow handles password creation first. The guard only activates for authenticated sessions (those that pass the existing `session.userid` check).

### 4.4 Navigation Rules

| Action | Behavior |
|--------|----------|
| Next | AJAX POST to save endpoint, increment `setup_step`, load next step content |
| Back | Load previous step content via AJAX GET. Does NOT decrement `setup_step` in DB (data already saved). |
| Skip | AJAX POST to `skip-step.cfm`, increment `setup_step` +1 (skip 4->5 if audition module off), load next step |
| Browser back button | Intercepted via `history.pushState` -- navigates wizard steps, not browser history |
| Direct URL to /app/ | Blocked by setup guard, redirected to wizard |
| Close browser | User resumes at `setup_step + 1` on next login |

### 4.5 CSRF Protection

<!-- REVIEW FIX C2: TAO uses a custom UUID-based CSRF pattern, NOT ColdFusion's built-in
     CSRFGenerateToken()/CSRFVerifyToken() functions. The token is stored in session.csrf_token
     and embedded via a meta tag in include/core.cfm (line 58). -->

TAO uses a **custom UUID-based CSRF pattern** (not ColdFusion's built-in `CSRFGenerateToken()`/`CSRFVerifyToken()`).

The wizard embeds the existing token as a meta tag:

```html
<meta name="csrf-token" content="#session.csrf_token#">
```

All AJAX POSTs include `csrfToken` as a parameter. Every save endpoint validates:

```cfml
<cfif NOT structKeyExists(form, "csrfToken") OR form.csrfToken NEQ session.csrf_token>
    <cfoutput>#serializeJSON({success: false, message: "Invalid CSRF token"})#</cfoutput>
    <cfabort>
</cfif>
```

The token is generated during session setup: `session.csrf_token = createUUID()`. The wizard relies on the existing token from `include/core.cfm` -- it does not generate its own.

### 4.6 Data Flow

```
app/setup-wizard/index.cfm (shell)
  |
  |-- AJAX GET /ajax/setup-wizard/load-step.cfm?step=N
  |     |-- Auth check (session.userid)
  |     |-- Reads current data for that step (for pre-fill)
  |     |-- Returns HTML fragment (step partial)
  |
  |-- AJAX POST /ajax/setup-wizard/save-stepN.cfm
  |     |-- Validates CSRF token (session.csrf_token pattern)
  |     |-- Validates session.userid
  |     |-- Step-specific save logic (see step specs above)
  |     |-- Updates taousers_tbl.setup_step
  |     |-- Returns JSON {success, message, data}
  |
  |-- AJAX POST /ajax/setup-wizard/skip-step.cfm
  |     |-- Validates CSRF
  |     |-- Increments setup_step (handles step 4 auto-skip)
  |     |-- Returns JSON {success, nextStep}
  |
  |-- AJAX POST /ajax/setup-wizard/upload-avatar.cfm
  |     |-- Validates file type (JPEG/PNG) + size (max 5MB)
  |     |-- Saves to user media directory
  |     |-- Updates taousers_tbl.avatarname
  |     |-- Returns JSON {success, avatarUrl}
```

### 4.7 Service CFCs Involved

<!-- REVIEW FIX C3: Service method names are tentative. The codebase uses legacy INS*/UPD*/DEL*
     naming conventions, not standardized create()/update()/delete(). CC must verify exact
     method names during Phase 2 recon. Confirmed methods are noted; unconfirmed are flagged. -->

| Service | Methods Used | Steps | Verification Status |
|---------|-------------|-------|---------------------|
| `UserService.cfc` | `UPDtaousers_23945()` (profile update) or equivalent | 1, 7 | **Tentative** -- CC must verify exact method for profile fields and status flip |
| `ContactService.cfc` | `create(dataStruct)` | 2, 3 | **Confirmed** -- accepts struct with `userid`, `contactFullName` required, returns contactid |
| `ContactItemService.cfc` | `INScontactitems()` (tags), `INScontactitems_23771()` (company) | 2, 3 | **Confirmed** -- multiple insert methods available |
| `ContactImportV3Service.cfc` | Existing full flow | 3 (import path) | Opened in modal, not called directly by wizard |
| `AuditionProjectService.cfc` | `INSaudprojects()` (NOT `create()`) | 4 | **Tentative** -- known issue: uses `cookie.userid` internally (see Step 4 note) |
| `AuditionRoleService.cfc` | `INSaudroles()` (NOT `create()`) | 4 | **Tentative** -- CC must verify required fields |
| `RelationshipService.cfc` | `startSystemForContact(systemid, contactid, userid)` | 5 | **Confirmed** -- validated 2026-04-07, cleanly callable, self-transactional |
| `SiteLinkUserService.cfc` | `INSsitelinks_user_24449()`, `UPDsitelinks_user()` | 6 | **Confirmed** -- insert and update methods available |

**New methods needed (estimated):**
- `UserService.activateAccount(userid)` -- sets `userstatus = 'Active'`, `setup_step = 7`, `setup_completed_at = NOW()`
- `UserService.updateWizardStep(userid, step)` -- updates `setup_step` column

CC should evaluate during Phase 2 recon whether these belong on `UserService.cfc` or in a new lightweight `SetupWizardService.cfc`. Preference: keep on `UserService.cfc` to avoid adding a new CFC unless the method count warrants it.

### 4.8 Existing Code Reuse

| Component | Source File | Reuse |
|-----------|------------|-------|
| Progress stepper CSS/HTML | `include/import-contacts-v3.cfm` (lines 217-269) | Direct reuse for wizard progress bar |
| Status badges | `include/import-contacts-v3.cfm` (lines 120-140) | Completion summary cards |
| Modal wrapper | `include/modal.cfm` | Import sub-flows in steps 3-4 |
| Avatar CSS | `app/assets/css/tao-components.css` (`.tao-avatar--lg`) | Step 1 photo preview |
| File upload drag-drop | `include/import-contacts-v3.cfm` | Steps 3-4 import path |
| Reminder explanation cards | `include/remoteUpdateSUID.cfm` | Step 5 system explanation |
| MyLinks list pattern | `include/mylinks_pane.cfm` | Step 6 (simplified, flat list) |
| Parsley.js | Project-wide | Form validation |
| Bootstrap 5 collapse | Project-wide | Tutorial panels |
| taoToast | `app/assets/js/tao-toast.js` | Error/success feedback |

---

## 5. Schema Changes

### 5.1 New Columns

<!-- REVIEW FIX M1: ALTER + backfill run as a single migration script to prevent
     a race condition where Active users briefly have setup_step=0 and get
     trapped by the setup guard. -->

```sql
-- FILE: database/migrations/P11_setup_wizard_columns.sql
-- IMPORTANT: Run ALTER and backfill as a single migration.
-- If backfill runs separately and fails, Active users would have setup_step=0
-- and the setup guard would trap them in the wizard.

ALTER TABLE taousers_tbl
  ADD COLUMN setup_step TINYINT NOT NULL DEFAULT 0
    COMMENT 'Wizard progress: 0=not started, 1-6=last completed step, 7=wizard done',
  ADD COLUMN setup_completed_at DATETIME NULL DEFAULT NULL
    COMMENT 'Timestamp when wizard completed and user activated';

-- Backfill IMMEDIATELY after ALTER (same script, same connection)

-- All existing Active users: mark as wizard-complete so they never see it
UPDATE taousers_tbl
SET setup_step = 7,
    setup_completed_at = NOW()
WHERE userstatus = 'Active';

-- Users in Setup status who have already been bootstrapped (isSetup = 1):
-- These are users who completed the old setup flow before the wizard existed.
-- Promote them to Active so they don't get stuck in the wizard.
UPDATE taousers_tbl
SET setup_step = 7,
    userstatus = 'Active',
    setup_completed_at = NOW()
WHERE userstatus = 'Setup'
  AND isSetup = 1;
```

**Note:** The `isSetup` column reference must be verified during Phase 2 recon. If P6 uses a different mechanism, adjust the backfill WHERE clause accordingly.

### 5.2 Login Redirect Update

<!-- REVIEW FIX C6: The login flow (login/login2.cfm) uses userstatuses.status_url to
     redirect after login. For 'Setup' status users, this must route through /app/ so the
     Application.cfc guard can redirect to /app/setup-wizard/. -->

The login flow (`login/login2.cfm` line 39) redirects authenticated users to `userstatuses.status_url`. For Setup-status users to reach the wizard, their redirect must go through the Application.cfc guard:

```sql
-- Update the Setup status redirect to go through the main app guard
UPDATE userstatuses SET status_url = '/app/' WHERE userstatus = 'Setup';
```

This way: login -> `/app/` -> guard detects `userstatus = 'Setup'` -> redirect to `/app/setup-wizard/`.

**Phase 2 recon requirement:** CC must run `SELECT userstatus, status_url FROM userstatuses ORDER BY userstatus` to see current values before making this change.

### 5.3 View Update

The `taousers` view (which filters `IsDeleted = 0`) must include the new columns:

```sql
-- Extract current view definition first:
SHOW CREATE VIEW taousers;

-- Then rebuild with setup_step and setup_completed_at added to the SELECT list.
-- CRITICAL: Preserve ALL existing ~45 columns. Do not drop any columns during rebuild.
-- (Exact DDL depends on current view -- CC must read it during Phase 2.)
```

### 5.4 Rollback

```sql
-- FILE: database/migrations/P11_setup_wizard_columns_ROLLBACK.sql

ALTER TABLE taousers_tbl
  DROP COLUMN setup_step,
  DROP COLUMN setup_completed_at;

-- Restore the Setup status redirect
-- UPDATE userstatuses SET status_url = '/setup/' WHERE userstatus = 'Setup';
-- (Verify original value before applying)

-- Rebuild taousers view without new columns
-- (Restore from current view definition before migration)
```

### 5.5 No New Tables

All wizard steps write to existing tables. The import sub-flows use existing `import_v3_*` and `import_auditions_*` tables. No new staging or wizard-specific tables are needed.

---

## 6. Migration Plan for Existing Users

| User State | Action | Result |
|------------|--------|--------|
| `userstatus = 'Active'` | Backfill `setup_step = 7`, `setup_completed_at = NOW()` | Never sees wizard |
| `userstatus = 'Setup'` AND `isSetup = 1` | Backfill to Active (see 5.1) | Never sees wizard |
| `userstatus = 'Setup'` AND `isSetup = 0` | No backfill -- these are incomplete registrations | Will see wizard on next login (correct behavior) |
| New users created after deploy | `setup_step = 0` by default | Enters wizard on first authenticated request |

<!-- REVIEW FIX M2: Verify during Phase 2 recon that setup2.cfm or user_setup_core.cfm
     sets userstatus = 'Setup' during account creation. The INSERT in setup2.cfm (line 83)
     does NOT include userstatus. If the column has no DEFAULT constraint and remains NULL,
     login will fail because login2.cfm does INNER JOIN userstatuses ON userstatus. -->

**Phase 2 recon requirement:** Verify that `userstatus` is set to `'Setup'` during account creation. The INSERT in `setup/setup2.cfm` (line 83) does NOT include `userstatus` in the column list. If the column has no DEFAULT constraint and remains NULL, login will fail silently because `login/login2.cfm` does `INNER JOIN userstatuses ON us.userstatus = u.userstatus` -- a NULL userstatus returns zero rows. Check whether `user_setup_core.cfm` or a table DEFAULT handles this.

---

## 7. Security Checklist

| Requirement | Implementation |
|-------------|---------------|
| Auth guard on all wizard pages | `session.userid` check in every AJAX endpoint and in `index.cfm` |
| Auth guard on all AJAX endpoints | First line of every save/load/skip endpoint checks `session.userid` |
| CSRF on all state-changing POSTs | Token from `session.csrf_token` (custom UUID pattern), validated by every save endpoint |
| `cfqueryparam` on ALL queries | No exceptions. Every user-supplied value parameterized with correct `cfsqltype`. |
| XSS prevention | `encodeForHTML()` on all user-supplied values rendered in step HTML |
| No user input in `cfinclude` paths | Step loading uses a numeric step parameter validated against a whitelist (1-7), never passed to cfinclude directly |
| Avatar upload validation | File type whitelist (JPEG, PNG only), 5MB max size, store outside webroot or with randomized filename |
| Contact ownership verification | Step 5 enrollment verifies each `contactId` belongs to `session.userid` before enrolling |
| No open redirect | Setup guard redirect URL is hardcoded (`/app/setup-wizard/`), not user-supplied |

---

## 8. Existing Setup Flow Disposition

### Current files and their roles:

| File | Role |
|------|------|
| `setup/index.cfm` | Landing page after UUID email link click. Shows password creation form. |
| `setup/setup2.cfm` | Processes password creation. Runs bootstrap (lookups, folders, site links). Redirects to `setup-complete.cfm`. |
| `setup/setup-complete.cfm` | Static "Setup Complete" page with link to login. Does NOT set any flags or session variables. |
| `setup/user_setup_core.cfm` | Core bootstrap logic: creates self-contact (`user_yn='Y'`), seeds `sitelinks_user_tbl`, creates folder structure, seeds lookup preferences. |
| `setup/contact_info.cfm` | Basic contact info collection (may be part of old flow or unused). |
| `setup/Application.cfc` | `this.name = "TAO_" & envLabel` -- shares session scope with main app (fixed in #1615/#1646). |

### What changes:

- `setup/setup2.cfm`: After bootstrap processing, redirect to `/app/setup-wizard/` instead of `setup-complete.cfm`. The bootstrap (password save, lookup seeding, folder creation, site link seeding) still runs in `setup2.cfm` / `user_setup_core.cfm` as before. Only the redirect target changes.
- `setup/setup-complete.cfm`: Kept as fallback. If a user somehow reaches it directly, it still works.
- `setup/Application.cfc`: NOT modified. Session scope sharing is already fixed.

### Why not remove the old flow:

- The old flow handles password creation and bootstrap -- those steps remain.
- Only the post-bootstrap redirect changes.
- The old `setup-complete.cfm` serves as a fallback.
- Full decommission is a separate future prompt after wizard validation.

### Interaction with `sched/user_setup.cfm`:

The scheduled task `user_setup.cfm` / `user_setup_core.cfm` creates the self-contact record (`user_yn = 'Y'`), seeds lookup tables, and creates folder structures. This runs during the `setup2.cfm` processing step, BEFORE the wizard. By the time the user enters Step 1 of the wizard, their self-contact already exists and `sitelinks_user_tbl` is already seeded. The wizard reads and updates these records -- it does not create them from scratch.

---

## 9. Effort Estimates

| Component | Effort | Notes |
|-----------|--------|-------|
| Wizard shell + stepper + navigation JS + browser history | 4-6 hrs | Single-page AJAX shell, progress bar, nav logic |
| Step 1: Welcome and Account Info | 2-3 hrs | Simple form, timezone/dateformat dropdowns, avatar upload |
| Step 2: Add Representation | 3-4 hrs | Repeatable contact cards, role selector, tag assignment |
| Step 3: Import or Add Contacts | 3-4 hrs | Two-path UI, quick-add form, import modal integration |
| Step 4: Import or Add Auditions | 2-3 hrs | Similar to step 3, conditional on audition module flag, preference sub-section |
| Step 5: Relationship Reminders | 3-4 hrs | System explanation UI, contact checklist, enrollment call |
| Step 6: My Links | 2-3 hrs | Pre-populated link list, URL inputs, custom link add |
| Step 7: Completion | 2-3 hrs | Summary cards, status transition, redirect, welcome toast |
| Application.cfc setup guard | 1-2 hrs | Guard logic + whitelist + edge cases |
| fetchUsers.cfm session wiring | 0.5 hrs | Add session.userstatus and session.setup_step |
| DB migration + view rebuild + backfill | 1 hr | ALTER TABLE + view rebuild + backfill + userstatuses update |
| Testing + edge cases | 3-4 hrs | Skip combinations, resume after browser close, double-submit, import modal flow |
| **Total** | **~27-37 hrs** | |

---

## 10. Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| Step 5 enrollment creates orphaned notifications | High | MUST use existing `RelationshipService.startSystemForContact()`. No parallel path. Confirmed callable 2026-04-07. |
| Existing users hit setup guard after migration | High | Backfill script runs in SAME migration as ALTER TABLE. Sets `setup_step = 7` for all Active users. Test before deploy. |
| User drops off mid-wizard | Medium | DB-persisted `setup_step` means they resume on next login |
| Import modal breaks wizard state | Medium | Import runs in modal overlay; wizard state is independent. Step advances on modal close. |
| `setup2.cfm` redirect change breaks existing flow | Medium | Only the redirect target changes. Old `setup-complete.cfm` kept as fallback. |
| Login fails for new users if userstatus is NULL | Medium | Phase 2 recon must verify userstatus is set during account creation (see section 6). |
| Session expiry during wizard | Low | Setup guard redirects to login; step resumes after re-auth |
| Double-submit on save-step | Low | Idempotent saves + disable button on click + duplicate check in Step 5 enrollment |
| Avatar upload fails | Low | Non-required field; default avatar remains; error toast shown |
| Step 4 audition creation uses wrong tables | Medium | CC must use audition service methods (not direct INSERT into `events_tbl`). Phase 2 recon requirement. |
| AuditionProjectService uses cookie.userid | Medium | Phase 2 must refactor or work around. See Step 4 note. Mark as `// TECH-DEBT`. |

---

## 11. Open Questions (Resolved)

| # | Question | Decision |
|---|----------|----------|
| 1 | Step 4 visibility when audition module is off? | **Hidden entirely.** Progress bar renumbers to 6 steps. No locked/upgrade teaser. |
| 2 | Resume behavior after browser close? | **Land on exact step they left off** (setup_step + 1). Don't restart from step 1. |
| 3 | Tutorial default state? | **Collapsed on all steps except Step 5.** Step 5 defaults to expanded because the Target/Maintenance concept needs explanation. |
| 4 | Import sub-flow presentation? | **Modal overlay.** Wizard shell stays visible behind it. Modal close returns to wizard. |
| 5 | Representation tags (Agent, Manager, Publicist)? | **System-level tags, non-deletable.** Verify during Phase 2 recon if bootstrap seeds them. If not, wizard creates them. |
| 6 | Analytics on wizard dropout? | **Minimal.** `SELECT setup_step, COUNT(*) FROM taousers_tbl WHERE userstatus='Setup' GROUP BY setup_step` is sufficient. No separate tracking table. |
| 7 | Mobile layout? | **Desktop-first.** Bootstrap responsive stacking handles mobile adequately. No mobile-specific layouts in Phase 2. |

---

## 12. Phase 2 Implementation Prompt Structure

When Phase 2 begins, the CC prompt should follow this phased structure:

| Phase | Content | Gate |
|-------|---------|------|
| Phase 2A | DB migration: add columns, backfill, rebuild view, update userstatuses | Verify columns exist, backfill correct, view works, login redirects correctly |
| Phase 2B | Wizard shell: `index.cfm`, `setup-wizard.js`, `setup-wizard.css`, progress stepper, nav logic, Application.cfc guard, fetchUsers.cfm session wiring | Shell renders, steps load, nav works, guard blocks non-wizard pages |
| Phase 2C | Steps 1-2: Account info + Representation | Forms render, saves work, re-entry pre-fills, avatar uploads |
| Phase 2D | Steps 3-4: Contacts + Auditions | Manual path works, import modal opens/closes, Step 4 conditional skip |
| Phase 2E | Step 5: Relationship Reminders | Enrollment calls `startSystemForContact()`, contacts grouped correctly, duplicate check works |
| Phase 2F | Steps 6-7: My Links + Completion | Links save, status flips to Active, redirect works, welcome toast fires |
| Phase 2G | Proof bundle | File inventory, edge case verification, security checklist, all commits listed |

Each phase has explicit acceptance criteria and a STOP gate before proceeding.

---

## 13. Annotations for Phase 2

CC must include these annotations throughout the implementation:

- `// MIGRATE: [description]` on any pattern that should change in the Go/Flutter rewrite
- `// TECH-DEBT: [description]` on any known shortcuts or deferred items (e.g., N+1 in enrollment loop, hardcoded tag names, cookie.userid in audition service)

---

## 14. Files CC Must Read Before Phase 2 Implementation

| File | Why |
|------|-----|
| `app/Application.cfc` | Auth gate, session setup, redirect insertion point |
| `setup/setup2.cfm` | Current post-bootstrap redirect (change target) |
| `setup/user_setup_core.cfm` | Bootstrap logic: what gets seeded before wizard runs |
| `services/ContactService.cfc` | `create()` method signature for Steps 2-3 -- **confirmed** |
| `services/ContactItemService.cfc` | Item insertion, tag handling, `getContactTagStatus()` -- **confirmed** |
| `services/RelationshipService.cfc` | `startSystemForContact()` -- **confirmed callable** |
| `services/AuditionProjectService.cfc` | `INSaudprojects()` method for Step 4 -- **known cookie.userid issue** |
| `services/AuditionRoleService.cfc` | `INSaudroles()` method for Step 4 |
| `services/UserService.cfc` | Profile update (`UPDtaousers_23945()`), status flip patterns |
| `services/SiteLinkUserService.cfc` | Link insert/update methods for Step 6 -- **confirmed** |
| `include/qry/fetchUsers.cfm` | Verify it selects from `taousers` view (new columns available after rebuild). Add session.userstatus and session.setup_step. |
| `include/qry/mylinks_159_1.cfm` | Confirms mylinks_pane uses SiteLinkUserService, not a separate mylinks table |
| `include/import-contacts-v3.cfm` | Import stepper UI pattern, modal integration |
| `include/mylinks_pane.cfm` | Links UI pattern for Step 6 |
| `login/login2.cfm` | Login redirect flow via userstatuses.status_url |
| `03-relationship-system-architecture.md` | Full enrollment chain: fusystems -> fuactions -> actionusers -> fusystemusers -> funotifications |
| `06-architecture.md` | Finding A19 (now resolved), Application.cfc structure |
| `02-modernization-plan.md` | WO-3.1 (duplicate enrollment prevention) |

---

## 15. Review Changelog

Changes applied from codebase validation review (2026-04-07):

| ID | Severity | Change |
|----|----------|--------|
| C1 | Critical | Section 2.1: Updated wizard location justification. Finding A19 (session isolation) was resolved in #1615/#1646. New justification cites auth guard integration, session timeout, and include path access. |
| C2 | Critical | Section 4.5: Replaced references to ColdFusion's built-in `CSRFGenerateToken()`/`CSRFVerifyToken()` with the actual custom `session.csrf_token = createUUID()` pattern used in the codebase. |
| C3 | Critical | Section 4.7: Added verification status column. Flagged `AuditionProjectService` and `AuditionRoleService` method names as tentative (actual names are `INSaudprojects()` and `INSaudroles()`, not `create()`). Confirmed `ContactService.create()`, `RelationshipService.startSystemForContact()`, and `SiteLinkUserService` methods. |
| C4 | Critical | Step 4: Added Phase 2 recon note about `AuditionProjectService.INSaudprojects()` using `cookie.userid` internally instead of accepting a userid parameter. |
| C5 | Critical | Section 4.1 files-to-modify table: Added `include/qry/fetchUsers.cfm` -- must add `session.userstatus` and `session.setup_step` population (currently fetched but not cached to session). |
| C6 | Critical | Section 5.2 (new): Added `userstatuses.status_url` update for 'Setup' status so login redirects through the Application.cfc guard to the wizard. |
| M1 | Medium | Section 5.1: Added explicit note that ALTER TABLE and backfill must run as a single migration script to prevent Active users from being temporarily trapped by the setup guard. |
| M2 | Medium | Section 6: Added Phase 2 recon note to verify `userstatus` is set during account creation in `setup2.cfm`. The INSERT does not include `userstatus`, which may cause login failure if NULL. |
| M3 | Medium | Step 6: Clarified that `mylinks` is a query variable name in `mylinks_pane.cfm`, not a separate table. The underlying table is `sitelinks_user_tbl` (via `SiteLinkUserService.SELsitelinks_user_23943()`). |
| M4 | Medium | Step 6: Matched column casing to codebase (`siteurl`, `sitename` lowercase as used in `user_setup_core.cfm` INSERTs). |
| M5 | Medium | Section 5.3: Added note to preserve all existing ~45 view columns during rebuild. |

---

**END OF DESIGN DOCUMENT.**

This document is the authoritative reference for Phase 2 implementation. No implementation code should be written that contradicts the decisions, table mappings, or architectural constraints documented here.
