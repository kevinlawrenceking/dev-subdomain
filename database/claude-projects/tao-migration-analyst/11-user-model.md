# User Management Module - Design Plan

## Discovery Summary

### User Table: `taousers`
Columns (from existing SELtaousers_24306 and getUserById):
- **Identity**: userid (PK, auto-inc), recordname, userFirstName, userLastName, userEmail, userRole, avatarName
- **Status/Auth**: userstatus (Active/Cancelled/Cancelling/Pending), passwordHash, passwordSalt, userPassword, recover, IsDeleted, isSetup
- **Preferences**: calStartTime, calEndTime, calSlotDuration, defRows, defCountry, defState, viewtypeid, tzid, dateFormatID, datePrefID
- **Address**: add1, add2, city, zip, region_id, countryid, def_regionid, regionid
- **Billing**: customerid (FK to thrivecart.id)
- **Feature flags**: IsBetaTester, isAudition, isAuditionModule
- **Newsletter**: nletter_yn, nletter_link
- **OAuth**: access_token, refresh_token
- **Other**: contactid, imdbid, shareid, isDemo

### Password Model
- SHA-512 hashing: `hash(password & passwordSalt, "SHA-512")`
- Salt generated: `hash(generateSecretKey("AES"), "SHA-512")`
- Password reset: UUID stored in `recover` column, email sent with link to `/recover/`

### Authorization Model
- `session.userid` - login gate (Application.cfc onRequestStart)
- `userrole` - set by fetchUsers.cfm on every request (populated from `taousers.userRole`)
- Admin check pattern (from admin-import-v3): `session.userrole EQ "Admin" OR session.userrole EQ "Administrator"`
- Alternative admin check: `session.isAdmin EQ true` (used in admin-relationship)

### Existing UserService.cfc Methods
- `getUserById(userId)` - full user struct with joins to thrivecart, regions, countries, timezones, dateformats
- `GetUserDetails(userid)` - user details with address/prefs
- `DETtaousers(userid)` - SELECT * from taousers
- `SELtaousers_24759(userEmail)` - find by email
- `users_sel()` / `getUsers()` - list all users (grouped by recordname)
- `UPDtaousers_23945(...)` - update profile fields
- `update_cal(...)` - update calendar preferences
- Various update methods for tokens, contacts, newsletter prefs

### Email Infrastructure
- Direct `<cfmail>` usage, no centralized utility
- From address: `support@theactorsoffice.com`
- Welcome email: inline HTML in `sched/thrivecart_process.cfm` with setup link
- Password recovery: inline HTML in `auth-recoverpw.cfm` with recover link

### Existing Admin Pages
- `app/admin-users/` - index.cfm (bare, includes core.cfm), setup-verification.cfm
- `app/admin-import-v3/` - full admin dashboard with Bootstrap 5 + DataTables
- `app/admin-relationship/` - relationship admin

### UI Patterns (from Import V3)
- Bootstrap 5 framework
- DataTables for server-side table rendering
- Card-based layouts with `.import-step` pattern
- Toast messaging via `.toast` Bootstrap component
- AJAX endpoints return JSON `{success, message, data}`

---

## Implementation Plan

### Pages and Endpoints

| Route | Type | Purpose |
|-------|------|---------|
| `/app/admin-users/index.cfm` | Page | User list with search, filter, pagination |
| `/app/admin-users/detail.cfm` | Page | User detail view with tabs and actions |
| `/app/admin-users/ajax/list.cfm` | AJAX | Search/filter/paginate users (JSON) |
| `/app/admin-users/ajax/get.cfm` | AJAX | Get single user details (JSON) |
| `/app/admin-users/ajax/save.cfm` | AJAX | Create or update user (JSON) |
| `/app/admin-users/ajax/toggle-status.cfm` | AJAX | Activate/deactivate user (JSON) |
| `/app/admin-users/ajax/send-email.cfm` | AJAX | Send templated email to user (JSON) |
| `/app/admin-users/ajax/preview-email.cfm` | AJAX | Preview email template rendered (JSON) |

### UserService.cfc Extensions (new methods)

- `listUsers(search, status, role, page, pageSize, sortCol, sortDir)` - paginated search
- `countUsers(search, status, role)` - total count for pagination
- `createUser(struct userData)` - insert new user with password hashing
- `updateUser(userid, struct userData)` - update editable fields
- `toggleUserStatus(userid, newStatus)` - activate/deactivate
- `getUserStatuses()` - list available statuses
- `getUserRoles()` - list distinct roles

### Email Template Approach

File-based templates in `/app/admin-users/email-templates/`:
- `welcome.cfm` - welcome email with setup link (mirrors thrivecart_process.cfm)
- `password-reset.cfm` - password reset instructions (mirrors auth-recoverpw.cfm)
- `status-change.cfm` - account status notification

Templates use a safe variable struct (`emailData`) passed at render time. Preview renders to string via `<cfsavecontent>`.

### Security

Every page and AJAX endpoint starts with:
```cfml
<cfif NOT structKeyExists(session, "userid")
      OR (NOT isDefined("userrole"))
      OR (userrole NEQ "Admin" AND userrole NEQ "Administrator")>
    <!-- return 403 / redirect -->
</cfif>
```

All SQL uses `cfqueryparam`. All form inputs validated server-side.

### Field Validation Rules

| Field | Rules |
|-------|-------|
| userFirstName | Required, max 255 |
| userLastName | Required, max 255 |
| userEmail | Required, valid email, unique per userid |
| userRole | Required, one of existing roles |
| userstatus | One of: Active, Cancelled, Pending |
| Password (create) | Min 6 chars, hashed with SHA-512 + salt |

### Audit Logging

Use `<cflog file="admin_users">` with format:
```
[action] admin_userid=X target_userid=Y detail=...
```

Actions logged: user_created, user_updated, user_status_changed, email_sent, email_previewed.

---

## Verification Checklist

- [ ] No DB schema changes
- [ ] Full CRUD works (create, read, update, list)
- [ ] Search/filter works (name, email, role, status)
- [ ] User details page shows all fields
- [ ] Welcome email resend works with preview
- [ ] Server-side auth enforced on every endpoint
- [ ] All SQL parameterized
- [ ] UI consistent with existing TAO patterns
