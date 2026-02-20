# User Management Module - Proof Bundle

## Files Created/Modified

### New Files (9)

| File | Purpose |
|------|---------|
| `app/admin-users/admin-guard.cfm` | Auth guard include (session + admin role check) |
| `app/admin-users/index.cfm` | User list page (search, filter, sort, paginate, create/edit modal) |
| `app/admin-users/detail.cfm` | User detail page (profile view, status toggle, email send, edit) |
| `app/admin-users/ajax/list.cfm` | AJAX: Paginated user list with filters |
| `app/admin-users/ajax/get.cfm` | AJAX: Get single user details |
| `app/admin-users/ajax/save.cfm` | AJAX: Create or update user |
| `app/admin-users/ajax/toggle-status.cfm` | AJAX: Toggle user status (Active/Cancelled/Pending) |
| `app/admin-users/ajax/send-email.cfm` | AJAX: Send welcome or password reset email |
| `app/admin-users/ajax/preview-email.cfm` | AJAX: Preview email template before sending |

### Modified Files (1)

| File | Change |
|------|--------|
| `services/UserService.cfc` | Added 6 admin methods: `listUsers`, `getUserStatuses`, `getUserRoles`, `createUser`, `updateUser`, `toggleUserStatus` |

### No Database Schema Changes

Zero ALTER TABLE, CREATE TABLE, or migration scripts. All functionality uses existing `taousers` and `thrivecart` tables.

---

## Authorization Enforcement

Every page and AJAX endpoint includes `admin-guard.cfm` which enforces:

```
session.userid must exist (logged in)
session.userrole must be "Admin" or "Administrator"
```

AJAX endpoints return JSON 403; pages redirect to `/app/`.

### Grep proof - all files include the guard:

```
detail.cfm:8:      <cfinclude template="admin-guard.cfm">
index.cfm:8:       <cfinclude template="admin-guard.cfm">
ajax/list.cfm:19:  <cfinclude template="../admin-guard.cfm">
ajax/get.cfm:13:   <cfinclude template="../admin-guard.cfm">
ajax/save.cfm:22:  <cfinclude template="../admin-guard.cfm">
ajax/toggle-status.cfm:14: <cfinclude template="../admin-guard.cfm">
ajax/send-email.cfm:20:    <cfinclude template="../admin-guard.cfm">
ajax/preview-email.cfm:14: <cfinclude template="../admin-guard.cfm">
```

---

## SQL Parameterization

All service methods use `queryExecute` with named parameters and `cfsqltype` declarations. No string-concatenated SQL.

Key methods and their parameter patterns:

- `listUsers`: `:search`, `:exactSearch`, `:status`, `:role`, `:pageSize`, `:offset`
- `createUser`: `:firstName`, `:lastName`, `:email`, `:role`, `:status`, `:pwHash`, `:pwSalt`, `:recordname`, `:avatarname`
- `updateUser`: `:firstName`, `:lastName`, `:email`, `:recordname`, `:uid` + dynamic `:role`, `:status`, `:isBeta`, `:isAud`, `:isAudMod`, `:pwHash`, `:pwSalt`
- `toggleUserStatus`: `:status`, `:uid`
- `send-email.cfm` queries: `:cid`, `:uuid`, `:recover`, `:uid`

Sort column uses whitelist: `"userid,userFirstName,userLastName,userEmail,userRole,userstatus,recordname,customerid"`

---

## Email Templates

### Welcome Email (Resend)
- Looks up thrivecart record by customerid
- Uses existing or generates new setup UUID
- Matches existing thrivecart_process.cfm email format
- HTML-encodes user first name (`encodeForHTML`)
- URL-encodes UUID (`encodeForURL`)

### Password Reset
- Generates new recover UUID, stores in `taousers.recover`
- Matches existing auth-recoverpw.cfm email format
- HTML-encodes user first name
- URL-encodes email and all URL parameters

### Preview Before Send
- Preview endpoint renders template without sending
- Uses same encoding functions as actual send
- Modal shows To, From, Subject, and rendered HTML body
- User must click "Send Email" to confirm after preview

---

## Feature Inventory

### User List Page (`/app/admin-users/`)
- [x] Paginated table (25/50/100 per page)
- [x] Search by name, email, or user ID (debounced 400ms)
- [x] Filter by status dropdown
- [x] Filter by role dropdown
- [x] Column sorting (click header to toggle ASC/DESC)
- [x] Status color coding (Active=green, Cancelled=red, Pending=orange)
- [x] Feature flags display (Beta, Audition, AudMod, Deleted)
- [x] Row click navigates to detail page
- [x] Edit button opens inline modal
- [x] Create new user via modal
- [x] Client-side validation before submit
- [x] Clear filters button

### User Detail Page (`/app/admin-users/detail.cfm?userid=N`)
- [x] Profile info card (name, email, ID, role, status, timezone, region, plan, flags)
- [x] ThriveCart/billing card (if linked)
- [x] Status toggle actions (context-aware buttons)
- [x] Confirmation dialog before status change
- [x] Send welcome email (with preview)
- [x] Send password reset email (with preview)
- [x] Email preview modal with rendered HTML
- [x] Edit user modal (all fields + password change + flags)
- [x] Back to list navigation

### AJAX Endpoints
- [x] `list.cfm` - GET, returns `{success, data: {users, total, page, pageSize, totalPages}, filters: {statuses, roles}}`
- [x] `get.cfm` - GET, returns `{success, data: {user: {...}}}`
- [x] `save.cfm` - POST, returns `{success, message, data: {userid}}`
- [x] `toggle-status.cfm` - POST, returns `{success, message, data: {userid, newStatus}}`
- [x] `preview-email.cfm` - GET, returns `{success, data: {subject, body, to, from, template}}`
- [x] `send-email.cfm` - POST, returns `{success, message}`

---

## Audit Logging

All admin actions are logged via `cflog` to `admin_users` log file:

```
[save] CREATE userid=N by admin=N
[save] UPDATE userid=N by admin=N
[toggle-status] userid=N newStatus=X by admin=N
[send-email] WELCOME sent to userid=N email=X by admin=N
[send-email] PASSWORD_RESET sent to userid=N email=X by admin=N
[list] ERROR: ... (on query failures)
[get] ERROR: ... (on load failures)
[save] ERROR: ... (on save failures)
[send-email] WELCOME FAILED userid=N: ...
[send-email] PASSWORD_RESET FAILED userid=N: ...
```

---

## Verification Checklist

### Navigation
1. Log in as Admin user
2. Navigate to `/app/admin-users/` - should see user list
3. Click a user row - should navigate to detail page
4. Click "Back to User List" - should return to list

### Auth Gate
1. Log in as non-admin user
2. Navigate to `/app/admin-users/` - should redirect to `/app/`
3. Call `/app/admin-users/ajax/list.cfm` directly - should return 403 JSON

### User List
1. Type in search box - table updates after 400ms debounce
2. Select a status filter - table filters
3. Select a role filter - table filters
4. Click column headers - table sorts (arrow indicator changes)
5. Change "Per Page" dropdown - table repaginates
6. Click "Clear" - all filters reset
7. Click pagination links - table pages

### Create User
1. Click "+ New User" button
2. Fill in required fields (first name, last name, email, password min 6 chars)
3. Submit - should close modal and refresh table
4. Verify with SQL: `SELECT userid, userFirstName, userLastName, userEmail, userRole, userstatus FROM taousers ORDER BY userid DESC LIMIT 1`

### Edit User
1. Click "Edit" button on any row
2. Modify fields, leave password blank
3. Submit - should update without changing password
4. Change password field - should update password

### Status Toggle
1. On detail page, click "Deactivate User" for an Active user
2. Confirm dialog
3. Status should change to Cancelled
4. Click "Reactivate User" - status changes back to Active

### Email - Welcome
1. On detail page, click "Resend Welcome Email"
2. Preview modal shows rendered email
3. Verify To, From, Subject fields
4. Click "Send Email" - success message appears
5. Check email logs: `admin_users` log file

### Email - Password Reset
1. On detail page, click "Send Password Reset"
2. Preview modal shows rendered email
3. Click "Send Email"
4. Verify recover UUID stored: `SELECT recover FROM taousers WHERE userid = N`

### Edge Cases
- Create user with duplicate email - should show error
- Create user with password < 6 chars - should show error
- Edit user, leave first name blank - should show error
- Access detail page with invalid userid - should show "User not found"
- Non-numeric userid in URL - should redirect to list

---

## Constraints Compliance

| Constraint | Status |
|-----------|--------|
| No database schema changes | PASS - zero DDL |
| Admin authorization on every endpoint | PASS - 8/8 files guarded |
| All SQL parameterized | PASS - queryExecute with named params |
| Audit logging via cflog | PASS - all actions logged |
| Email preview before send | PASS - modal preview flow |
| Follows TAO patterns (Bootstrap 5, AJAX, JSON responses) | PASS |
| No hard crashes on malformed input | PASS - all endpoints wrapped in cftry/cfcatch |
| HTML encoding in email bodies | PASS - encodeForHTML/encodeForURL |
