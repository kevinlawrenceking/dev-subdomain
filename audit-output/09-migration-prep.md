# Phase 14 -- Migration Prep Assessment

**Audit date:** 2026-03-16
**Scope:** Session inventory, API surface map, file storage, REST-ification candidates
**Files excluded:** `dev_backup/` (legacy copies)

---

## 14A -- Session Variable Inventory

All session variables are initialized in `app/Application.cfc` (onRequestStart), with initial login set in `app/login2.cfm`. Additional variables are set in `include/qry/fetchUsers.cfm` (included from Application.cfc on every request).

### Complete Session Variable Table

| Session Variable | Set In | Read In | Purpose | JWT Field Name |
|---|---|---|---|---|
| `session.userid` | `app/login2.cfm` (login), `app/Application.cfc` (impersonation) | **Everywhere** -- 100+ templates, all AJAX endpoints via `ajax/Application.cfc` | Primary user identity; integer PK from `taousers` | `sub` (subject) |
| `session.impersonating` | `app/Application.cfc` (admin bypass) | Not explicitly read (informational flag) | Marks admin impersonation sessions | `impersonating` (boolean) |
| `session.isAdmin` | Not found set in active code (likely set via older flow or DB check at runtime) | `admin-relationship/index.cfm`, `importv3/diag.cfm`, `importv3/check_tables.cfm`, `importv3/normalize_fact_fieldnames.cfm`, `importv3/admin_cleanup.cfm` | Admin authorization gate | `role` (claim, value "admin") |
| `session.userrole` | `sched/setup-verification.cfm` (indirect via fetchUsers variables) | `admin-import-v3/index.cfm`, `admin-users/setup-verification.cfm`, `importv3/admin_dashboard.cfm`, `importv3/diagnostics.cfm` | Role-based access control string ("Admin", "Administrator", etc.) | `role` |
| `session.csrfToken` | `app/Application.cfc` (auto-generated via `CSRFGenerateToken()`) | `ajax/Application.cfc` (CSRF validation) | CSRF protection for state-changing requests | N/A -- not needed in JWT/API model |
| `session.csrf_token` | `include/import-contacts-v3.cfm`, `include/import-auditions-v3.cfm` | Same files (hidden form fields) | Secondary CSRF token (UUID-based, for import UIs) | N/A |
| `session.dateformatExample` | `include/qry/fetchUsers.cfm` (every request) | `app/Application.cfc` (formatDate helper), `include/prefs_pane.cfm` | User's preferred date display format string (e.g., "mm/dd/yyyy") | `preferences.dateFormat` |
| `session.dateformatID` | `include/qry/fetchUsers.cfm` | Indirectly via preference update flows | Numeric FK to `dateformats` table | `preferences.dateFormatId` |
| `session.user.dateformatid` | `services/UserService.cfc` (dateformatpref method) | Same service | Nested struct variant of dateformat preference | `preferences.dateFormatId` |
| `session.user.dateformatExample` | `services/UserService.cfc` | Same service | Nested struct variant | `preferences.dateFormat` |
| `session.userMediaPath` | `app/Application.cfc` (every authed request) | `include/upload.cfm`, `include/attachmentadd2.cfm`, `include/attachmentadd2aud.cfm`, `include/remoteaddHeadshot2.cfm`, `include/remoteaddMaterial2.cfm`, `include/remoteaudmatadd2.cfm`, `include/attachmentdel*.cfm`, `include/download*.cfm`, `include/export_auditions.cfm`, `include/exportContacts.cfm`, `include/user_setup.cfm`, `include/folder_setup.cfm`, `include/contactfolder_setup.cfm`, `include/icsmaker.cfm` | Absolute filesystem path to user's media root | N/A -- server-side only; Go must compute from `userId` |
| `session.userMediaUrl` | `app/Application.cfc` | `include/aud_head_pane.cfm`, `include/load_headshot*.cfm`, `include/myheadshots_pane.cfm`, `include/download_media.cfm`, `include/remoteselectheadshot.cfm` | Browser-relative URL to user's media root | N/A -- Go serves via `/api/media/{userId}/...` |
| `session.userContactsPath` | `app/Application.cfc` | `include/contact_info.cfm`, `include/birthdays.cfm`, `include/dash_repteam.cfm`, `include/aud_rel_pane.cfm`, `include/myteam_pane*.cfm`, `include/folder_setup.cfm` | Filesystem path to user's contacts avatar directory | N/A -- server-side |
| `session.userContactsUrl` | `app/Application.cfc` | `include/contact_info.cfm`, `include/birthdays.cfm`, `include/dash_repteam.cfm`, `include/image-upload-contact.cfm`, `include/folder_setup.cfm` | Browser URL to contacts avatar directory | N/A -- Go media route |
| `session.userImportsPath` | `app/Application.cfc` | `ajax/import/upload.cfm` | Filesystem path for import file staging | N/A -- server-side |
| `session.userImportsUrl` | `app/Application.cfc` | Not directly read in templates | Browser URL for imports directory | N/A |
| `session.userExportsPath` | `app/Application.cfc` | Not directly read in active templates | Filesystem path for export files | N/A |
| `session.userExportsUrl` | `app/Application.cfc` | Not directly read in active templates | Browser URL for exports | N/A |
| `session.userSharePath` | `app/Application.cfc`, `include/icsmaker.cfm` (fallback) | `include/icsmaker.cfm` | Filesystem path for shared calendar files | N/A |
| `session.userShareUrl` | `app/Application.cfc` | Not directly read in active templates | Browser URL for shares | N/A |
| `session.userCalendarPath` | `app/Application.cfc` | `include/pgload.cfm` | Filesystem path to user's ICS calendar file | N/A |
| `session.userCalendarUrl` | `app/Application.cfc` | `include/calendarModalSubscription.cfm`, `include/pgload.cfm` | Full HTTPS URL to user's ICS calendar feed | `calendarUrl` |
| `session.userAvatarPath` | `app/Application.cfc` | `include/user_setup.cfm`, `include/contactfolder_setup.cfm`, `include/folder_setup.cfm` | Filesystem path to user's avatar | N/A |
| `session.userAvatarUrl` | `app/Application.cfc` | `include/myinfo_pane.cfm`, `include/leftbar.cfm`, `include/image-upload.cfm` | Browser URL to user's avatar | `avatarUrl` |
| `session.contactAvatarUrl` | `include/user_setup.cfm`, `include/contactfolder_setup.cfm`, `include/pgload_setup.cfm` | Same files (display/debug) | Browser URL for contact avatar (temporary) | N/A |
| `session.dir_contact_avatar_filename` | `include/image-upload-contact.cfm` | Same file | Contact avatar full URL for image upload crop tool | N/A |
| `session.pgaction` | `include/contacts.cfm`, `include/contacts_all.cfm`, `include/contacts_all_tabs.cfm`, `include/share.cfm`, `include/tmpcontactgroups.cfm`, `include/tmpcontacttags.cfm` | Same files | UI state: "view" or "bulk" mode for contact list | N/A -- client-side state |
| `session.pg_action` | `include/deletesystemfromrel.cfm` | Not read explicitly | Variant of pgaction (inconsistent naming) | N/A |
| `session.pgrtn` | `include/account_info.cfm`, `include/coreb.cfm`, `include/core_title.cfm` | `include/coreb.cfm` | Page return/navigation breadcrumb code | N/A -- client-side routing |
| `session.ftom` | `include/complete_not.cfm`, `include/complete_not_skip.cfm`, `include/complete_not_ajax.cfm`, `include/complete_not_batch*.cfm` | `include/coreb.cfm` | "Follow-up to maintenance" flag -- triggers UI refresh after system transition | N/A -- websocket/event |
| `session.mocktoday` | Never set in active code (debug-only) | `include/complete_not*.cfm`, `include/contact_info.cfm`, `include/qry/systemNotificationsActive.cfm` | Override current date for testing notification scheduling | N/A -- test-only |
| `session.new_eventid` | `include/appoint.cfm`, `include/appoint-info.cfm` | Same files (link construction) | Stores last-viewed event ID for UI navigation | N/A -- query parameter |
| `session.projectlist` | `include/auditions.cfm`, `include/auditions_new.cfm` | `include/export_auditions.cfm` | Comma-delimited list of audition project IDs for export | N/A -- request parameter |
| `session.currentpage` | `include/contact_info.cfm` | Not explicitly read | Stores current page URL for breadcrumb/return | N/A |
| `session.user_id` | `app/ajax/load_reminders.cfm` (reads; likely set elsewhere or is alternate naming) | `include/reminder_pane_old.cfm` | Alternate naming for userid (inconsistency) | `sub` |

### Migration Notes

- **18 path-based session variables** (`userMediaPath`, `userContactsPath`, etc.) are server-computed filesystem paths. These do NOT migrate to JWT. The Go backend must compute them from `userId` and config.
- **3 UI state variables** (`pgaction`, `pgrtn`, `ftom`) should move to client-side state (React state / URL params).
- **2 CSRF variables** (`csrfToken`, `csrf_token`) are replaced by Go's own CSRF middleware or dropped if using JWT bearer tokens.
- **session.userid** is the critical identity claim -- maps to JWT `sub`.
- **session.userrole / session.isAdmin** map to JWT `role` claim. Currently these are checked inconsistently (sometimes DB lookup, sometimes session).

> :triangular_flag_on_post: **MIGRATION BLOCKER**: `session.userrole` and `session.isAdmin` are set through different paths and checked inconsistently. Go auth middleware must normalize to a single `role` claim with consistent admin check.

> :warning: **NEEDS REVIEW**: `session.user_id` vs `session.userid` -- two different naming conventions exist. `load_reminders.cfm` uses `session.user_id` while everything else uses `session.userid`. Must unify before migration.

---

## 14B -- API Surface Map

### Write Endpoints (Form POST Handlers)

| Template | Method | Parameters Accepted | What It Does | Go API Endpoint |
|---|---|---|---|---|
| `/app/login2.cfm` | POST | `j_username`, `j_password` | Authenticates user, sets `session.userid`, redirects | `POST /api/auth/login` |
| `/app/logout.cfm` | GET | (none) | Destroys session | `POST /api/auth/logout` |
| `/include/remoteAddContactAdd.cfm` | POST | contact fields (name, email, phone, etc.) | Creates new contact record | `POST /api/contacts` |
| `/include/remoteAddCAdd.cfm` | POST | `contactid`, detail field values | Adds/updates contact detail (generic) | `PUT /api/contacts/{id}/details` |
| `/include/remoteUpdateCUpdate.cfm` | POST | `itemid`, `valueText`, field values | Updates a contact detail field | `PUT /api/contacts/{id}/items/{itemId}` |
| `/include/remoteDelete2.cfm` | POST | `recid`, entity identifiers | Deletes a record (generic) | `DELETE /api/{entity}/{id}` |
| `/include/remoteDeleteFormDelete.cfm` | POST | `recid` | Deletes a form record | `DELETE /api/records/{id}` |
| `/include/remoteAddNameAdd.cfm` | POST | `contactid`, `firstName`, `lastName` | Adds/updates contact name | `PUT /api/contacts/{id}/name` |
| `/include/tmpcontactgroups.cfm` | POST | `contactids[]`, `groupid` | Bulk assigns contacts to group | `POST /api/contacts/bulk/groups` |
| `/include/tmpcontacttags.cfm` | POST | `contactids[]`, `tagid` | Bulk assigns tags to contacts | `POST /api/contacts/bulk/tags` |
| `/include/audition-add2.cfm` | POST | audition fields (project, date, casting, etc.) | Creates new audition record | `POST /api/auditions` |
| `/include/audition-update2.cfm` | POST | `audprojectid`, audition fields | Updates existing audition | `PUT /api/auditions/{id}` |
| `/include/changestatus.cfm` | GET (form action) | `audprojectid`, `status` | Changes audition status | `PUT /api/auditions/{id}/status` |
| `/include/rolecheck.cfm` | GET (form action) | `audprojectid`, role params | Checks/updates audition role | `PUT /api/auditions/{id}/role` |
| `/include/appoint-add2.cfm` | POST | event fields (title, date, time, contacts) | Creates new appointment/event | `POST /api/events` |
| `/include/appoint-update2.cfm` | POST | `eventid`, event fields | Updates existing event | `PUT /api/events/{id}` |
| `/include/complete_not_ajax.cfm` | POST | `notid`, `notstatus` | Completes/skips a notification; triggers next action scheduling | `POST /api/notifications/{id}/complete` |
| `/include/complete_not_batch.cfm` | POST | `notid`, `notstatus` | Batch notification completion with system lifecycle | `POST /api/notifications/batch` |
| `/include/update_reminder_status.cfm` | POST | `notid`, `status` | Updates reminder status | `PUT /api/reminders/{id}/status` |
| `/app/ajax/update_notification_status.cfm` | POST | `notificationID`, `status` | Updates `funotifications.notstatus` | `PUT /api/notifications/{id}/status` |
| `/include/systemchange.cfm` | GET (form action) | `suid`, system params | Changes relationship system for contact | `PUT /api/systems/{suId}` |
| `/include/deletesystemfromrel.cfm` | POST/GET | `suid` | Removes contact from relationship system | `DELETE /api/systems/{suId}` |
| `/include/attachmentadd2.cfm` | POST (multipart) | `file`, `contactid`, `userid` | Uploads contact attachment | `POST /api/contacts/{id}/attachments` |
| `/include/attachmentadd2aud.cfm` | POST (multipart) | `file`, audition params | Uploads audition attachment | `POST /api/auditions/{id}/attachments` |
| `/include/attachmentdel.cfm` | POST | `attachfilename` | Deletes contact attachment | `DELETE /api/attachments/{filename}` |
| `/include/attachmentdelaud.cfm` | POST | `attachfilename` | Deletes audition attachment | `DELETE /api/attachments/audition/{filename}` |
| `/include/remoteaddHeadshot2.cfm` | POST (multipart) | `file` | Uploads user headshot | `POST /api/users/{id}/headshots` |
| `/include/remoteaddMaterial2.cfm` | POST (multipart) | `file` | Uploads user material | `POST /api/users/{id}/materials` |
| `/include/upload.cfm` | POST (multipart) | `file` | Generic file upload (contact import) | `POST /api/imports/upload` |
| `/include/upload_audition.cfm` | POST (multipart) | `file` | Audition import file upload | `POST /api/imports/auditions/upload` |
| `/include/update_cal.cfm` | POST | calendar prefs | Updates calendar preferences | `PUT /api/users/{id}/preferences/calendar` |
| `/include/bookupdateform2.cfm` | POST | booking fields | Updates booking details | `PUT /api/auditions/{id}/booking` |
| `/include/catupdateform2.cfm` | POST | category fields | Updates category | `PUT /api/categories/{id}` |
| `/include/linkadd2.cfm` | POST | link fields | Adds a link to contact | `POST /api/contacts/{id}/links` |
| `/include/linkmedia.cfm` | GET (form action) | media link params | Links media to audition | `POST /api/auditions/{id}/media` |
| `/include/dashboardupdate2.cfm` | POST | dashboard prefs | Updates dashboard config | `PUT /api/users/{id}/preferences/dashboard` |
| `/include/merge_contacts_interface.cfm` | POST | `primary_contactid`, `secondary_contactid` | Merges two contacts | `POST /api/contacts/merge` |
| `/include/admin-support-update2.cfm` | POST | ticket fields | Updates support ticket | `PUT /api/admin/tickets/{id}` |
| `/include/UpdateFormUpdate.cfm` | POST | generic detail fields | Updates a detail record | `PUT /api/records/{id}` |
| `/include/testing3.cfm` | POST | `recid`, approval params | Approves implementation record | `PUT /api/admin/testing/{id}/approve` |
| `/app/admin-users/ajax/save.cfm` | POST | user fields | Admin: saves user record | `PUT /api/admin/users/{id}` |
| `/app/admin-users/ajax/toggle-status.cfm` | POST | `userid`, `newStatus` | Admin: toggles user status | `PUT /api/admin/users/{id}/status` |
| `/app/admin-users/ajax/send-email.cfm` | POST | `userid`, `template` | Admin: sends email to user | `POST /api/admin/users/{id}/email` |
| `/ajax/importv3/upload.cfm` | POST (multipart) | `file` | V3 contact import upload | `POST /api/imports/v3/upload` |
| `/ajax/importv3/parse.cfm` | POST | `job_id`, mapping config | Parses uploaded import file | `POST /api/imports/v3/{jobId}/parse` |
| `/ajax/importv3/finalize.cfm` | POST | `job_id` | Finalizes approved import rows | `POST /api/imports/v3/{jobId}/finalize` |
| `/ajax/importv3/row_action.cfm` | POST | `row_id`, `action` | Sets per-row import action | `PUT /api/imports/v3/rows/{rowId}/action` |
| `/ajax/importv3/fact_update.cfm` | POST | `row_id`, field data | Updates import row field value | `PUT /api/imports/v3/rows/{rowId}/fields` |
| `/ajax/importv3/finalize_update.cfm` | POST | `job_id` | Finalizes update-type imports | `POST /api/imports/v3/{jobId}/finalize-updates` |
| `/ajax/importv3/admin_dashboard.cfm` | POST | `action`, various | Admin feature flag management | `POST /api/admin/feature-flags` |
| `/ajax/import-auditions/upload.cfm` | POST (multipart) | `file` | Audition import upload | `POST /api/imports/auditions/upload` |
| `/ajax/import-auditions/parse.cfm` | POST | `job_id` | Parses audition import | `POST /api/imports/auditions/{jobId}/parse` |
| `/ajax/import-auditions/finalize.cfm` | POST | `job_id` | Finalizes audition import | `POST /api/imports/auditions/{jobId}/finalize` |

### Read Endpoints (Data Display / AJAX GET)

| Template | Method | Parameters Accepted | What It Does | Go API Endpoint |
|---|---|---|---|---|
| `/app/contacts/index.cfm` | GET | URL params (filters, page) | Contacts list page (HTML) | `GET /api/contacts` |
| `/app/contact/index.cfm` | GET | `contactid` | Single contact detail page | `GET /api/contacts/{id}` |
| `/app/auditions/index.cfm` | GET | filter params | Auditions list page | `GET /api/auditions` |
| `/app/audition/index.cfm` | GET | `audprojectid` | Single audition detail | `GET /api/auditions/{id}` |
| `/app/dashboard/index.cfm` | GET | (none) | Dashboard page | `GET /api/dashboard` |
| `/app/reminders/index.cfm` | GET | (none) | Reminders list page | `GET /api/reminders` |
| `/app/notifications/index.cfm` | GET | (none) | Notifications page | `GET /api/notifications` |
| `/include/get_reminders.cfm` | GET (AJAX) | `currentid`, `showInactive`, `userid` | JSON: reminders for contact | `GET /api/contacts/{id}/reminders` |
| `/include/get_dashboard_reminders.cfm` | GET (AJAX) | `currentid`, `showInactive`, `limit` | JSON: dashboard reminder summary (7 contacts) | `GET /api/dashboard/reminders` |
| `/include/get_notifications.cfm` | GET (AJAX) | `currentid`, `showInactive`, `limit` | JSON: audition notifications | `GET /api/auditions/notifications` |
| `/app/ajax/load_reminders.cfm` | GET (AJAX) | `contactid`, `showInactive`, `HIDE_COMPLETED` | HTML: reminder rows for contact pane | `GET /api/contacts/{id}/reminders` |
| `/include/get_record_data.cfm` | GET (AJAX) | `tablename`, `id` | JSON: generic record data fetch | `GET /api/records/{table}/{id}` |
| `/include/fetch.cfm` | GET (AJAX) | params | JSON: generic lookup | `GET /api/lookup/{type}` |
| `/include/fetch_panelname.cfm` | GET (AJAX) | params | JSON: panel name lookup | `GET /api/lookup/panels` |
| `/include/fetch_sitename.cfm` | GET (AJAX) | params | JSON: submit site name | `GET /api/lookup/sites` |
| `/app/autolookup.cfm` | GET (AJAX) | `q`, search term | Typeahead contact search | `GET /api/contacts/search?q=` |
| `/include/companylookup.cfm` | GET (AJAX) | `q` | Company name typeahead | `GET /api/companies/search?q=` |
| `/ajax/importv3/status.cfm` | GET (AJAX) | `job_id` | JSON: import job status | `GET /api/imports/v3/{jobId}/status` |
| `/ajax/importv3/rows.cfm` | GET (AJAX) | `job_id`, filters | JSON: import rows grid data | `GET /api/imports/v3/{jobId}/rows` |
| `/ajax/importv3/columns.cfm` | GET (AJAX) | `job_id` | JSON: import column mappings | `GET /api/imports/v3/{jobId}/columns` |
| `/ajax/importv3/history.cfm` | GET (AJAX) | (none) | JSON: user's import history | `GET /api/imports/v3/history` |
| `/app/admin-users/ajax/list.cfm` | GET (AJAX) | `search`, `status`, `page` | JSON: admin user list | `GET /api/admin/users` |
| `/app/admin-users/ajax/get.cfm` | GET (AJAX) | `userid` | JSON: admin user detail | `GET /api/admin/users/{id}` |
| `/app/admin-users/ajax/preview-email.cfm` | GET (AJAX) | `userid`, `template` | HTML: email preview | `GET /api/admin/users/{id}/email-preview` |
| `/include/exportContacts.cfm` | GET | `idlist` | Generates XLS export file | `GET /api/contacts/export` |
| `/include/export_auditions.cfm` | GET | (via session.projectlist) | Generates audition XLS export | `GET /api/auditions/export` |
| `/include/icsmaker.cfm` | GET (scheduled) | userid | Generates ICS calendar file | `GET /api/users/{id}/calendar.ics` |

> :triangular_flag_on_post: **MIGRATION BLOCKER**: Many "write" endpoints are plain `.cfm` files under `/include/` with no consistent REST structure. The Go migration must create a proper REST router. All 50+ write endpoints currently share the same session auth -- Go middleware must replicate.

> :warning: **NEEDS REVIEW**: Several endpoints return HTML fragments (not JSON) for AJAX pane loading (`load_reminders.cfm`, `getModalContent.cfm`, `remoteselectheadshot.cfm`). These must become JSON APIs with React/frontend rendering.

---

## 14C -- File Storage Inventory

### Active `cffile` Usage (excluding dev_backup/ and sched/ tooling scripts)

| File | Action | What Gets Stored | Storage Location | File Types | How Served |
|---|---|---|---|---|---|
| `ajax/import/upload.cfm` | upload, delete | Contact import files (CSV, XLS, XLSX, VCF) | `session.userImportsPath` = `{mediaRoot}/users/{userId}/imports/` | `.csv`, `.xls`, `.xlsx`, `.vcf` | Not directly served; parsed then deleted |
| `ajax/importv3/upload.cfm` | upload, delete | Contact import V3 files | `session.userImportsPath` | `.csv`, `.xls`, `.xlsx`, `.vcf` | Parsed then deleted |
| `ajax/import-auditions/upload.cfm` | upload, delete | Audition import files | `session.userImportsPath` | `.csv`, `.xls`, `.xlsx` | Parsed then deleted |
| `include/attachmentadd2.cfm` | upload | Contact attachments (docs, images) | `session.userMediaPath/{contactId}/` | Any (unrestricted) | Via `include/download.cfm` using `cfcontent` |
| `include/attachmentadd2aud.cfm` | upload | Audition attachments | `session.userMediaPath/` | Any | Via `include/download_aud.cfm` |
| `include/attachmentdel.cfm` | delete | Contact attachment removal | `session.userMediaPath/{filename}` | -- | -- |
| `include/attachmentdelaud.cfm` | delete | Audition attachment removal | `session.userMediaPath/{filename}` | -- | -- |
| `include/remoteaddHeadshot2.cfm` | upload | User headshots | `session.userMediaPath/` | Image files | Via media URL path |
| `include/remoteaddMaterial2.cfm` | upload | User marketing materials | `session.userMediaPath/` | Any | Via media URL path |
| `include/remoteaudmatadd2.cfm` | upload | Audition materials | `session.userMediaPath/` | Any | Via media URL path |
| `include/upload.cfm` | upload | Legacy contact import (XLS) | `session.userMediaPath/` | `.xls`, `.xlsx` | Parsed via cfspreadsheet |
| `include/upload_audition.cfm` | upload | Legacy audition import | `{mediaRoot}/users/{userId}/` | `.xls`, `.xlsx` | Parsed via cfspreadsheet |
| `include/icsmaker.cfm` | write | ICS calendar feed file | `C:\home\theactorsoffice.com\media-{dsn}\calendar\{calendarname}.ics` | `.ics` | Direct URL access |
| `include/contact_info.cfm` | copy (avatar) | Contact avatar placeholder | `session.userContactsPath/{contactId}/` | `.jpg` | Via contacts URL |
| `include/birthdays.cfm` | copy (avatar) | Contact avatar placeholder | `session.userContactsPath/{contactId}/` | `.jpg` | Via contacts URL |
| `include/dash_repteam.cfm` | copy (avatar) | Contact avatar placeholder | `session.userContactsPath/{contactId}/` | `.jpg` | Via contacts URL |
| `include/folder_setup.cfm` | copy (avatar) | Default avatar to user dir | `session.userMediaPath/` | `.jpg` | Via media URL |
| `include/user_setup.cfm` | copy (avatar) | Default avatar on user setup | `session.userMediaPath/`, contact dirs | `.jpg` | Via media URL |
| `include/contactfolder_setup.cfm` | copy (avatar) | Default avatar on contact folder setup | `session.userMediaPath/`, contact dirs | `.jpg` | Via media URL |
| `include/customicon_single.cfm` | write | Downloaded favicon as custom icon | Temp directory then copied | `.ico`, `.png` | Via image URL |
| `include/customicon.cfm` | write | Custom icon files | Image directories | `.ico`, `.png` | Via image URL |
| `include/sql.cfm` | write | Dynamic page content | Page-specific directory | `.cfm` | Direct include |
| `services/FileParserService.cfc` | read, readbinary | Import file parsing | Reads from imports path | Various | Internal processing |
| `services/ContactImportV2Service.cfc` | readbinary, copy | Import processing + avatar copy | Import path, contact folders | Various + `.jpg` | Internal + media URL |

### Storage Path Architecture

```
C:\home\theactorsoffice.com\
  media-{dsn}\
    users\{userId}\                    # session.userMediaPath
      avatar.jpg                       # session.userAvatarPath
      contacts\{contactId}\            # session.userContactsPath/{id}
        avatar.jpg                     # Contact avatars
      imports\                         # session.userImportsPath
      exports\                         # session.userExportsPath
      share\                           # session.userSharePath
      calendar\{calendarname}.ics      # session.userCalendarPath
      {attachments at root}            # Headshots, materials, audition files
    images\                            # application.imagesPath
      defaults\avatar.jpg             # application.defaultAvatarPath
      retina-circular-icons\           # Custom icons
      email\                           # Email template images
      filetypes\                       # File type icons
      dates\                           # Date-related images
    calendar\{calendarname}.ics        # ICS feeds (icsmaker.cfm)
    auditionimporttemplates.xlsx       # Template file
```

> :triangular_flag_on_post: **MIGRATE: local file storage -- must move to S3**. All user media is stored on local disk under `C:\home\theactorsoffice.com\media-{dsn}\`. This includes:
> - **User avatars** (~1 file per user)
> - **Contact avatars** (~1 file per contact per user)
> - **Headshots and materials** (variable count per user)
> - **Contact/audition attachments** (variable count)
> - **Import staging files** (temporary; can remain local/ephemeral)
> - **ICS calendar feeds** (regenerated periodically)
> - **Export files** (temporary)

> :triangular_flag_on_post: **MIGRATE: hardcoded Windows paths**. Multiple files contain `C:\home\theactorsoffice.com\...` hardcoded paths. These must be replaced with config-driven paths for Go deployment:
> - `include/icsmaker.cfm` (line 256)
> - `include/upload.cfm` (line 10)
> - `include/pgload_setup.cfm` (line 18)
> - `include/core_nomenu.cfm` (line 19)
> - `include/Applicationx.cfm` (line 19)
> - `sched/user_setup_core.cfm` (line 83)
> - `setup/user_setup_core.cfm` (line 83)

> :warning: **NEEDS REVIEW**: Attachment uploads in `attachmentadd2.cfm` and `remoteaddHeadshot2.cfm` have no file type restrictions beyond what the browser sends. Go API must enforce allowlists.

---

## 14D -- REST-ification Candidates

These are the top 5 highest-value service functions to wrap as CF REST endpoints NOW, based on:
- Frequency of use across the app
- Clean JSON output (no HTML mixing)
- Minimal session dependency beyond `userid`
- Direct applicability to the Go migration

### 1. Contact Lookup / Search -- `LookupService.getContacts()`

**Current path:** `app/autolookup.cfm` / `services/LookupService.cfc`
**Why:** Called on every page with a contact search box (typeahead). Pure query, returns `{id, name}` pairs. Zero HTML.
**Proposed CF REST:** `GET /api/cf/contacts/search?q={term}&userid={id}`
**Parameters:** `userid` (integer), `q` (string)
**Return:** `{ "success": true, "data": [{ "id": 123, "col1": "Jane Smith" }] }`

### 2. Dashboard Reminders -- `include/get_dashboard_reminders.cfm`

**Current path:** `include/get_dashboard_reminders.cfm`
**Why:** Called on every dashboard load. Already returns clean JSON. Most-called data endpoint for logged-in users.
**Proposed CF REST:** `GET /api/cf/dashboard/reminders?userid={id}&limit={n}`
**Parameters:** `userid` (integer), `limit` (integer, default 7)
**Return:** Already structured JSON with reminder objects.

### 3. Contact Reminders -- `include/get_reminders.cfm`

**Current path:** `include/get_reminders.cfm`
**Why:** Called every time a contact detail page loads. Already returns clean JSON array. Second-most-called data endpoint.
**Proposed CF REST:** `GET /api/cf/contacts/{contactId}/reminders?userid={id}&showInactive={0|1}`
**Parameters:** `contactId` (integer), `userid` (integer), `showInactive` (0/1)
**Return:** Already structured JSON array of reminder objects.

### 4. Notification Completion -- `include/complete_not_ajax.cfm`

**Current path:** `include/complete_not_ajax.cfm`
**Why:** Most critical write operation -- triggers the entire relationship system lifecycle (next action scheduling, system transitions, maintenance enrollment). Already returns JSON. Wrapping it as REST makes the action engine accessible to mobile/Go.
**Proposed CF REST:** `POST /api/cf/notifications/{notId}/complete`
**Parameters:** `notId` (integer), `notstatus` (string: "Completed"|"Skipped")
**Return:** `{ "success": true, "debugCounters": { ... } }`

### 5. User Profile / Preferences -- `services/UserService.cfc` + `include/qry/fetchUsers.cfm`

**Current path:** `services/UserService.cfc` (getUserById, getUserByHash, update_cal, dateformatpref)
**Why:** UserService already has clean CFC methods. User data is needed by every client. Wrapping provides the foundation for JWT token generation (user identity + preferences in one call).
**Proposed CF REST:** `GET /api/cf/users/{id}/profile`
**Parameters:** `userId` (integer)
**Return:** `{ "success": true, "data": { "userid": 1, "userFirstName": "...", "userEmail": "...", "userRole": "...", "dateformatExample": "...", "calendarUrl": "...", ... } }`

### Priority Order for Implementation

| Priority | Endpoint | Effort | Impact |
|---|---|---|---|
| 1 | Contact Search | Low (already a CFC) | High -- enables decoupled frontend |
| 2 | Dashboard Reminders | Low (already JSON) | High -- most-visited page |
| 3 | Contact Reminders | Low (already JSON) | High -- contact detail page |
| 4 | Notification Completion | Medium (complex lifecycle) | Critical -- core workflow engine |
| 5 | User Profile | Medium (consolidate fetchUsers) | High -- enables JWT bootstrap |

> :triangular_flag_on_post: **MIGRATION BLOCKER**: The notification completion endpoint (`complete_not_ajax.cfm`) contains the entire relationship system state machine (follow-up to maintenance transitions, recurring action scheduling, duplicate enrollment prevention). This is the single most complex piece of business logic to port to Go. It should be the LAST thing migrated and the FIRST thing wrapped as a CF REST endpoint for dual-stack operation.

> :warning: **NEEDS REVIEW**: 60+ service CFCs exist in `/services/` but most are only used by include files, not exposed as endpoints. A service-layer audit should identify which ones already have clean `returntype="query"` signatures suitable for direct REST wrapping.

---

## Summary of Migration Blockers

| # | Blocker | Severity | Description |
|---|---|---|---|
| 1 | Local file storage | :triangular_flag_on_post: BLOCKER | All user media on local Windows disk -- must move to S3 or equivalent |
| 2 | Hardcoded Windows paths | :triangular_flag_on_post: BLOCKER | 7+ files with `C:\home\theactorsoffice.com\...` literals |
| 3 | Session-based auth | :triangular_flag_on_post: BLOCKER | 30+ session variables, 100+ files reading `session.userid` -- must migrate to JWT |
| 4 | Inconsistent admin checks | :triangular_flag_on_post: BLOCKER | `session.isAdmin` vs `session.userrole` checked differently in different files |
| 5 | Notification state machine | :triangular_flag_on_post: BLOCKER | `complete_not_ajax.cfm` contains all relationship lifecycle logic -- most complex port |
| 6 | HTML-returning AJAX endpoints | :warning: REVIEW | Several endpoints return HTML fragments, not JSON -- must convert for SPA |
| 7 | `session.user_id` vs `session.userid` | :warning: REVIEW | Naming inconsistency will cause bugs during migration |
| 8 | Unrestricted file uploads | :warning: REVIEW | Some upload endpoints lack file type validation |
| 9 | No REST structure | :warning: REVIEW | Write endpoints scattered across `/include/` with no URL convention |
| 10 | 18 path-based session vars | :warning: REVIEW | Must be replaced with computed paths from config + userId in Go |
