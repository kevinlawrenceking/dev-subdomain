# TAO Security Audit Report -- Phase 4

**Audit Date:** 2026-03-16
**Branch:** dev (commit ce57de13)
**Auditor:** Claude Opus 4.6 (automated)

---

## Summary

| Check | Issues Found | Severity |
|-------|-------------|----------|
| 4A -- SQL Injection | 46 vectors | CRITICAL |
| 4B -- XSS | 20 vectors | HIGH |
| 4C -- Session Security | 5 gaps | HIGH |
| 4D -- CSRF | 94 unprotected forms, 0 protected | CRITICAL |
| 4E -- File Upload | 8 unvalidated uploads | HIGH |
| 4F -- Hardcoded Credentials | 3 in app code | CRITICAL |

---

## 4A -- SQL Injection Scan

All `<cfquery>` and `queryExecute()` blocks were scanned for variables interpolated
without `cfqueryparam` wrapping. 46 vectors found across application code (excluding
`dev_backup/` and `.venv/`).

### CRITICAL -- Direct User Input in Queries (upload_audition_back.cfm)

These are the highest-risk findings because `#userid#` traces to session/URL scope
and is interpolated directly into INSERT and SELECT statements without cfqueryparam.

```
include\upload_audition_back.cfm:42  -- #userid# in SELECT WHERE clause
include\upload_audition_back.cfm:47  -- #userid# in INSERT VALUES
```

### Service Layer -- Dynamic SQL via arguments (not parameterized)

These are `arguments.*` values used as column names, table names, sort directions,
IN-lists, or LIKE patterns without whitelisting or cfqueryparam. While arguments
come from internal code rather than direct user input, any caller passing user-derived
data creates an injection path.

| File | Line | Variable | Risk |
|------|------|----------|------|
| services\AuditionGenreService_standardized.cfc | 111 | `#arguments.sortBy#` | Column name injection |
| services\AuditionGenreService_standardized.cfc | 111 | `#arguments.sortDir#` | Sort direction injection |
| services\AuditionMediaAudRolesXRefService.cfc | 37 | `#arguments.conditionColumn#` | Column name injection |
| services\AuditionMediaTypeService.cfc | 17 | `#arguments.mediaTypeIds#` | IN-list injection |
| services\AuditionProjectService.cfc | 1416 | `#arguments.colist#` | Column list injection |
| services\AuditionProjectService.cfc | 1457 | `#arguments.materials#` | Dynamic SQL fragment |
| services\AuditionProjectService.cfc | 1463 | `#arguments.audsearch#` (x2) | LIKE/search injection |
| services\AuditionRoleService.cfc | 201 | `#arguments.statusField#` | Column name injection |
| services\AuditionRoleService.cfc | 212 | `#arguments.statusField#` | Column name injection |
| services\BirthdayService.cfc | 9 | `#arguments.maxRows#` | LIMIT injection |
| services\ContactImportService.cfc | 300 | `#arguments.tag_label#` (x2) | Value injection |
| services\ContactService.cfc | 436 | `#arguments.uniquename#` | Dynamic identifier |
| services\ContactService.cfc | 526 | `#arguments.contacts_table#` | Table name injection |
| services\ContactService.cfc | 709 | `#arguments.addDaysNoUniqueName#` | Dynamic identifier |
| services\ContactService.cfc | 814 | `#arguments.uniquename#` | Dynamic identifier |
| services\ContactService.cfc | 946 | `#arguments.addDaysNoUniqueName#` | Dynamic identifier |
| services\ContactService_Consolidated.cfc | 72 | `#arguments.includeFields#` | Column list injection |
| services\ContactService_Consolidated.cfc | 107 | `#arguments.data#` | Dynamic SQL fragment |
| services\ContactService_Consolidated.cfc | 154 | `#arguments.maxRows#` | LIMIT injection |
| services\ContactService_Consolidated.cfc | 155 | `#arguments.includeFields#` | Column list injection |
| services\ContactService_Consolidated.cfc | 158 | `#arguments.sortField#` | Column name injection |
| services\ContactService_Consolidated.cfc | 158 | `#arguments.sortDirection#` | Sort direction injection |
| services\EventContactsXRefService.cfc | 132 | `#arguments.eventIds#` | IN-list injection |
| services\EventService.cfc | 963 | `#arguments.eventStartTime#` | Value injection |
| services\ExportItemService.cfc | 56 | `#arguments.new_ContactMeetingLoc#` | Value injection |
| services\ExportItemService.cfc | 60 | `#arguments.new_contactBirthday#` | Value injection |
| services\ExportItemService.cfc | 63 | `#arguments.new_Website#` | Value injection |
| services\NoteService.cfc | 278 | `#arguments.noteDetailsPrefix#` | LIKE prefix injection |
| services\PanelService.cfc | 13 | `#arguments.newpnids#` | IN-list injection |
| services\PanelUserService.cfc | 43 | `#arguments.new_isvisible#` | Value injection |
| services\SystemService.cfc | 239 | `#arguments.systemIds#` | IN-list injection |
| services\TagService.cfc | 19 | `#arguments.conditions#` | Full WHERE clause injection |
| services\TaoVersionService.cfc | 129 | `#arguments.old_verid#` | Value injection |
| services\TaoVersionService.cfc | 143 | `#arguments.new_verid#` | Value injection |
| services\TaoVersionService.cfc | 160-165 | `#arguments.new_major/minor/patch/version/build#` | Multiple value injections |
| services\TicketService.cfc | 761 | `#arguments.statusList#` | IN-list injection |

### Import Pipeline -- Dynamic SQL

| File | Line | Variable | Risk |
|------|------|----------|------|
| ajax\import-auditions\status.cfm | 240 | `#variables.additionalFields#` | Dynamic column list |
| ajax\importv3\status.cfm | 250 | `#variables.additionalFields#` | Dynamic column list |

### Setup/Sched Files

| File | Line | Variable | Risk |
|------|------|----------|------|
| sched\user_setup_core.cfm | 169 | `#variables.dsn#` | Datasource name injection |
| setup\user_setup_core.cfm | 169 | `#variables.dsn#` | Datasource name injection |

---

## 4B -- XSS (Cross-Site Scripting) Scan

All `<cfoutput>` blocks were scanned for `#url.*#`, `#form.*#`, and `#cgi.*#`
output without `encodeForHTML()`, `HTMLEditFormat()`, or equivalent encoding.
20 vectors found.

### CGI Variables Output Without Encoding

These CGI variables can be manipulated by attackers (query strings, user agents,
referers) and are output directly into HTML.

| Finding | File | Variable |
|---------|------|----------|
| :lock: SECURITY: XSS vector | include\core.cfm:115 | `#cgi.query_string#` output in JS `.load()` URL |
| :lock: SECURITY: XSS vector | include\core_nomenu.cfm:21-22 | `#cgi.script_name#` and `#cgi.query_string#` in variable assignment rendered in HTML |
| :lock: SECURITY: XSS vector | include\coreb.cfm:193 | `#cgi.query_string#` output in JS `.load()` URL |
| :lock: SECURITY: XSS vector | recover\404.cfm:208 | `#cgi.server_name#`, `#cgi.script_name#`, `#cgi.query_string#` |
| :lock: SECURITY: XSS vector | sched\error.cfm:34-38 | `#cgi.script_name#`, `#cgi.query_string#`, `#cgi.remote_addr#`, `#cgi.http_user_agent#`, `#cgi.http_referer#` |
| :lock: SECURITY: XSS vector | sched\email_test.cfm:27 | `#cgi.server_name#` |
| :lock: SECURITY: XSS vector | sched\standalone_email_test.cfm:28 | `#cgi.server_name#` |
| :lock: SECURITY: XSS vector | setup\setup-complete.cfm:55 | `#cgi.server_name#` |
| :lock: SECURITY: XSS vector | share\remote_load.cfm:118 | `#cgi.remote_addr#` |
| :lock: SECURITY: XSS vector | sched\Applicationxx.cfc:155 | `#cgi.script_name#` |

### URL Parameter Output Without Encoding

| Finding | File | Variable |
|---------|------|----------|
| :lock: SECURITY: XSS vector | test-ipn-cli.cfm:56 | `#url.type#` output directly into HTML |

### Encoding Coverage Summary

Only 19 files (out of hundreds of .cfm/.cfc files) use `encodeForHTML()` or
`HTMLEditFormat()`. The vast majority of the codebase outputs variables without
encoding. The findings above are the highest-risk vectors (user-controllable input),
but the systemic lack of output encoding is a broader concern.

---

## 4C -- Application.cfc Session Security

**File:** `app/Application.cfc`

### Session Cookie Settings

| Check | Status | Detail |
|-------|--------|--------|
| `this.sessioncookie.httponly = true` | :lock: MISSING | Not set anywhere in codebase. Session cookies can be read by JavaScript (XSS theft). |
| `this.sessioncookie.secure = true` | :lock: MISSING | Not set anywhere in codebase. Session cookies transmitted over HTTP (MITM theft). |
| `this.sessioncookie.samesite = "strict"` | :lock: MISSING | Not configured. Vulnerable to cross-site request attachment. |

### Session Invalidation at Login

| Check | Status | Detail |
|-------|--------|--------|
| `sessionInvalidate()` called before setting session.userid | :lock: MISSING | Neither `login/login2.cfm` nor `app/login2.cfm` calls `sessionInvalidate()` before establishing a new session. This enables session fixation attacks. |

### Authentication Gate in onRequestStart

| Check | Status | Detail |
|-------|--------|--------|
| Session check before page access | :white_check_mark: PRESENT | `onRequestStart()` at line 300 checks `session.userid` and redirects to `/loginform.cfm` for unauthenticated users. Login pages are exempted. |
| AJAX endpoint auth gate | :white_check_mark: PRESENT | `app/ajax/Application.cfc` returns 401 JSON for unauthenticated AJAX requests. |

### Admin Role-Check Gate

| Check | Status | Detail |
|-------|--------|--------|
| Admin impersonation gate | :white_check_mark: PRESENT | `onRequestStart()` at line 253 verifies `userRole` is "Admin" or "Administrator" before allowing `?u=` impersonation. |
| Admin route protection | :warning: NEEDS REVIEW | Admin routes (e.g., `app/admin-*`, `database/*`, `sched/*`) rely on the general session check but do NOT have explicit role-based gates. Any authenticated user could potentially access admin pages. |

### Error Handler Information Leakage

| Check | Status | Detail |
|-------|--------|--------|
| SQL leak in error response | :lock: SECURITY | `onError()` at line 379 includes `arguments.exception.sql` (truncated to 300 chars) in JSON error responses for AJAX requests. This leaks SQL statements to the client. |
| Full exception dump for non-AJAX | :lock: SECURITY | `onError()` at line 385 outputs `<cfdump>` of the full exception for browser requests, exposing internal paths, stack traces, and SQL. |

---

## 4D -- CSRF (Cross-Site Request Forgery) Audit

### Token Generation

A CSRF token is generated in `onRequestStart()` at line 308:
```
<cfset session.csrfToken = CSRFGenerateToken() />
```

However, this token is **never validated by any form or endpoint**.

### Form Scan Results

**94 POST forms found -- 0 include CSRF token fields or validation.**

Every single POST form in the application is unprotected against CSRF attacks.
An attacker can craft a page that submits forms on behalf of authenticated users.

High-impact unprotected forms include:

| Finding | File | Action |
|---------|------|--------|
| :lock: SECURITY: CSRF unprotected POST | loginform.cfm:117 | Login form |
| :lock: SECURITY: CSRF unprotected POST | include\remoteDeleteForm.cfm:42 | Contact deletion |
| :lock: SECURITY: CSRF unprotected POST | include\remoteDeleteFormAud.cfm:11 | Audition deletion |
| :lock: SECURITY: CSRF unprotected POST | include\remoteDeleteFormAudproject.cfm:5 | Project deletion |
| :lock: SECURITY: CSRF unprotected POST | include\remoteUserUpdate.cfm:27 | User profile update |
| :lock: SECURITY: CSRF unprotected POST | include\admin-support-update.cfm:12 | Admin ticket update |
| :lock: SECURITY: CSRF unprotected POST | include\audition-add.cfm:47 | Audition creation |
| :lock: SECURITY: CSRF unprotected POST | include\audition-update.cfm:43 | Audition modification |
| :lock: SECURITY: CSRF unprotected POST | include\appoint-update.cfm:55 | Appointment modification |
| :lock: SECURITY: CSRF unprotected POST | include\attachmentadd.cfm:17 | File upload |
| :lock: SECURITY: CSRF unprotected POST | include\merge_contacts_interface.cfm:41 | Contact merge |
| :lock: SECURITY: CSRF unprotected POST | include\version-add.cfm:26 | Version creation |
| :lock: SECURITY: CSRF unprotected POST | setup\index.cfm:106 | Account setup |
| :lock: SECURITY: CSRF unprotected POST | recover\index.cfm:90 | Password recovery |
| :lock: SECURITY: CSRF unprotected POST | include\import-auditions.cfm:168 | Audition import |
| :lock: SECURITY: CSRF unprotected POST | include\topbar.cfm:15 | Search form |

**Note:** The importv3 pipeline (`ajax/importv3/status.cfm`) implements its own
CSRF token mechanism using `session.csrf_token = createUUID()`, but this is limited
to that module only and does not protect any of the 94 forms listed above.

---

## 4E -- File Upload Security

8 `<cffile action="upload">` endpoints were found in active application code.
**None** perform server-side MIME type validation, file extension whitelisting,
or file size enforcement.

### Findings

| Finding | File | Issues |
|---------|------|--------|
| :lock: SECURITY: Unvalidated upload | include\attachmentadd2.cfm:40 | No MIME check, no extension whitelist, no size limit. Accepts ANY file type. Stored in user-accessible directory under `session.userMediaPath`. |
| :lock: SECURITY: Unvalidated upload | include\attachmentadd2aud.cfm:29 | Same as above -- no validation. Stored in `session.userMediaPath`. |
| :lock: SECURITY: Unvalidated upload | include\remoteaddHeadshot2.cfm:17 | Intended for headshot images but accepts any file. No MIME check. |
| :lock: SECURITY: Unvalidated upload | include\remoteaddMaterial2.cfm:14 | No MIME check, no extension whitelist. |
| :lock: SECURITY: Unvalidated upload | include\remoteaudmatadd2.cfm:14 | No MIME check, no extension whitelist. |
| :lock: SECURITY: Unvalidated upload | include\upload.cfm:17 | Spreadsheet import -- expects .xlsx but accepts any file type. |
| :lock: SECURITY: Unvalidated upload | include\upload_audition.cfm:67 | Spreadsheet import -- expects .xlsx but accepts any file type. |
| :lock: SECURITY: Unvalidated upload | include\upload_audition_back.cfm:62 | Spreadsheet import -- same issues. |

### Common Issues Across All Upload Endpoints

1. **No `accept` attribute on `<cffile>`** -- The `accept` attribute on `<cffile>` restricts MIME types server-side. None of the endpoints use it.
2. **No file extension whitelist** -- No code checks the uploaded file extension against an allowed list.
3. **No file size limit** -- No `maxfilesize` or equivalent check.
4. **No filename sanitization** -- Files are stored with `nameconflict="MAKEUNIQUE"` (good for deduplication), but original filenames are not sanitized for path traversal or special characters.
5. **Client-side `accept` attribute** is present on some HTML `<input type="file">` elements (e.g., import-contacts-v3.cfm, import-auditions.cfm), but client-side validation is trivially bypassed.
6. **Storage in web-accessible directories** -- Uploaded files are stored under `session.userMediaPath` which maps to `/media-{dsn}/users/{userid}/` -- publicly accessible via URL.

---

## 4F -- Hardcoded Credentials

### CRITICAL Findings

| Finding | File | Detail |
|---------|------|--------|
| :lock: SECURITY: hardcoded credential | oauth\oauth_callback.cfm:36 | Google OAuth client secret hardcoded: `clientSecret = "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"`. Also exposes client ID. **This credential should be rotated immediately and moved to environment variables or a secrets manager.** |
| :lock: SECURITY: hardcoded credential | include\mybilling_pane.cfm:2 | PayKickStart API auth token hardcoded: `authToken = "4OWaGHPXFibE"`. Should be moved to environment configuration. |
| :lock: SECURITY: hardcoded credential | include\mybilling_pane.cfm:8 | Placeholder session cookie value: `laravel_session=YOUR_SESSION_COOKIE`. While currently a placeholder, this pattern encourages hardcoded credentials. |

### Lower-Risk Findings

| Finding | File | Detail |
|---------|------|--------|
| :warning: Needs review | sched\standalone_email_test.cfm:49 | `password=""` in SMTP cfmail tag. Empty password is low risk but should use config. |
| :warning: Needs review | sched\email_test.cfm | Test email with hardcoded recipient address `kevinking7135@gmail.com`. Not a credential but exposes developer PII. |

---

## Additional Security Concerns

### A. Information Leakage in Error Handler

:lock: SECURITY: `app/Application.cfc` onError (line 378-382) includes partial SQL in JSON error
responses sent to the client:
```cfml
<cfif structKeyExists(arguments.exception, "sql")>
    <cfset errorResponse.sql = left(arguments.exception.sql, 300)>
</cfif>
```
This leaks table names, column names, and query structure to any authenticated user
who triggers an error.

For non-AJAX requests, line 385 dumps the full exception:
```cfml
<cfdump var="#arguments.exception#" label="CF Error" top="2" />
```

### B. Session Fixation via Login Flow

Neither `login/login2.cfm` nor `app/login2.cfm` calls `sessionInvalidate()` before
setting `session.userid`. An attacker who pre-sets a session ID (e.g., via XSS or
URL token) can hijack the authenticated session after the user logs in.

### C. Admin Impersonation Audit Trail

`onRequestStart()` sets `session.impersonating = true` when an admin impersonates
another user (line 269), but there is no logging of who impersonated whom, or when.
This creates an accountability gap.

### D. Password Hashing Uses SHA-512

Login uses `Hash(password & salt, "SHA-512")` which is a fast hash. Modern best
practice recommends a slow/adaptive hash like bcrypt, scrypt, or Argon2 to resist
brute-force attacks. Not an immediate vulnerability but a long-term concern.

### E. Debug Login Page Still in Codebase

`login/login2.cfm` contains a `debugLogin` flag (currently set to `false`) that,
when enabled, displays full password hashes, salts, and hash comparison results
in the browser. While disabled, this code should be removed entirely from production.

### F. Broad Session Timeout

`this.sessionTimeout = createTimeSpan(0,9,20,0)` sets sessions to 9 hours 20 minutes.
This is unusually long and increases the window for session hijacking.

---

## Remediation Priority

### Immediate (P0 -- do now)

1. **Rotate the Google OAuth client secret** exposed in `oauth/oauth_callback.cfm`
2. **Move all hardcoded credentials** to environment variables or CF admin DSN config
3. **Remove SQL from error responses** in `onError()` handler
4. **Add `this.sessioncookie.httponly = true`** and `this.sessioncookie.secure = true`

### High (P1 -- this sprint)

5. **Add CSRF token validation** to all POST forms (start with destructive actions: delete, update, merge)
6. **Add server-side file upload validation** -- MIME type check, extension whitelist, size limit
7. **Call `sessionInvalidate()`** before setting session on login
8. **Add `encodeForHTML()` wrapping** for all user-controllable output in cfoutput blocks

### Medium (P2 -- next sprint)

9. **Parameterize all service-layer SQL** -- replace dynamic column/table interpolation with whitelisted identifiers
10. **Add admin role gates** to all admin routes (`app/admin-*`, `database/*`, `sched/*`)
11. **Remove debug login page code** from `login/login2.cfm`
12. **Reduce session timeout** to 2-4 hours

### Long-term (P3)

13. **Migrate password hashing** from SHA-512 to bcrypt/Argon2
14. **Implement Content-Security-Policy headers**
15. **Add audit logging** for admin impersonation events

---

*Report generated by automated security audit. Manual verification recommended for
all findings before remediation.*
