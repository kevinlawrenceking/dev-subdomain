# Phase 8 -- Email & External Integrations Audit

**Date:** 2026-03-16
**Scope:** All `<cfmail>` and `<cfhttp>` usage in the TAO codebase (excluding `dev_backup/`).
**Auditor:** Claude Opus 4.6 (automated)

---

## Table of Contents

1. [8A -- cfmail Audit](#8a----cfmail-audit)
   - [Summary of Findings](#cfmail-summary-of-findings)
   - [Detailed File-by-File Analysis](#cfmail-detailed-file-by-file-analysis)
   - [Consolidated cfmail Flags](#consolidated-cfmail-flags)
2. [8B -- cfhttp / External API Audit](#8b----cfhttp--external-api-audit)
   - [Summary of Findings](#cfhttp-summary-of-findings)
   - [Detailed File-by-File Analysis](#cfhttp-detailed-file-by-file-analysis)
   - [Consolidated cfhttp Flags](#consolidated-cfhttp-flags)
3. [Recommendations](#recommendations)

---

## 8A -- cfmail Audit

### cfmail Summary of Findings

| Metric | Count |
|---|---|
| Total files with cfmail (excl. dev_backup) | 14 |
| cfmail in .cfm templates (not service CFCs) | 14 |
| cfmail in service CFCs | 0 |
| No emailService.cfc exists | YES |
| Hardcoded SMTP credentials | 1 (standalone_email_test.cfm) |
| Email sends with no logging | 9 |
| Email sends with error handling (cftry/cfcatch) | 6 |
| Inline HTML email bodies in business logic | 14 |
| Hardcoded personal email addresses as BCC | 13 |

**There is no centralized email service.** Every email send is a bare `<cfmail>` tag inside a `.cfm` template with inline HTML. No email templates or layout system exists. No `emailService.cfc` or equivalent was found anywhere in the codebase.

---

### cfmail Detailed File-by-File Analysis

---

#### 1. `include/remoteSupportFormAdd.cfm`

- **Type:** .cfm template (support ticket creation)
- **cfmail count:** 3 separate cfmail tags
- **SMTP config:** Uses CF server default (no `server=` attribute)
- **Error handling:** NONE -- no cftry/cfcatch around any of the 3 cfmail calls
- **Email send logged:** NO
- **Email body:** Inline HTML including a full email signature with base64-encoded image URLs, duplicated across all ticket emails
- **From:** `support@theactorsoffice.com` (hardcoded)
- **To:** First two go to `add.task.swxn8hp4jz4m0x79@todoist.net` (Todoist task integration); third goes to user email
- **BCC:** `kevinking7135@gmail.com` (hardcoded personal email on all 3)
- **Notes:** The second cfmail has an empty body. Todoist integration email address is hardcoded. Massive inline HTML signature (~170 lines) is embedded directly in the template.

**Flags:**
- `TECH-DEBT: cfmail in template -- should be in emailService.cfc` -- include/remoteSupportFormAdd.cfm
- `TECH-DEBT: email send not logged` -- include/remoteSupportFormAdd.cfm (all 3 sends)
- `TECH-DEBT: no error handling around cfmail` -- include/remoteSupportFormAdd.cfm
- `TECH-DEBT: hardcoded Todoist integration email` -- include/remoteSupportFormAdd.cfm
- `TECH-DEBT: empty cfmail body` -- include/remoteSupportFormAdd.cfm (line 126-128)

---

#### 2. `sched/thrivecart_process.cfm`

- **Type:** .cfm template (scheduled task -- ThriveCart order processing)
- **cfmail count:** 1
- **SMTP config:** Uses CF server default
- **Error handling:** YES -- inner cftry/cfcatch around cfmail with cflog on failure and cfcontinue to skip status update
- **Email send logged:** YES (via cflog to `TAO_thrivecart_mail_errors` on failure; status updated to "Emailed" on success)
- **Email body:** Inline HTML welcome email with setup link
- **From:** `support@theactorsoffice.com`
- **BCC:** `kevinking7135@gmail.com`
- **Notes:** This is one of the better-handled email sends. The host for the setup URL is dynamically determined but defaults to "app" if localhost.

**Flags:**
- `TECH-DEBT: cfmail in template -- should be in emailService.cfc` -- sched/thrivecart_process.cfm

---

#### 3. `auth-recoverpw.cfm`

- **Type:** .cfm template (password recovery page)
- **cfmail count:** 1
- **SMTP config:** Uses CF server default
- **Error handling:** NONE -- no cftry/cfcatch around cfmail
- **Email send logged:** NO
- **Email body:** Inline HTML with password recovery link containing `cid`, `email`, and `recover` UUID in the URL
- **From:** `support@theactorsoffice.com`
- **BCC:** `kevinking7135@gmail.com`
- **Notes:** The recover link exposes `contactid` and `email` in the URL. No rate limiting on password recovery requests. No expiration on the recover UUID. Uses `cgi.server_name` in the URL which could be manipulated via Host header injection.

**Flags:**
- `TECH-DEBT: cfmail in template -- should be in emailService.cfc` -- auth-recoverpw.cfm
- `TECH-DEBT: email send not logged` -- auth-recoverpw.cfm
- `TECH-DEBT: no error handling around cfmail` -- auth-recoverpw.cfm
- `SECURITY: password recovery link exposes contactid and email in URL` -- auth-recoverpw.cfm
- `SECURITY: no rate limiting on password recovery` -- auth-recoverpw.cfm
- `SECURITY: Host header used in recovery URL (potential injection)` -- auth-recoverpw.cfm

---

#### 4. `app/admin-users/ajax/send-email.cfm`

- **Type:** .cfm AJAX endpoint (admin user email send)
- **cfmail count:** 2 (welcome email + password reset email)
- **SMTP config:** Uses CF server default
- **Error handling:** YES -- cftry/cfcatch around each cfmail with detailed debug logging and cflog
- **Email send logged:** YES -- cflog to `admin_users` log file on both success and failure
- **Email body:** Inline HTML, but uses `encodeForHTML()` and `encodeForURL()` for output encoding
- **From:** `support@theactorsoffice.com`
- **BCC:** `kevinking7135@gmail.com`
- **Notes:** This is the best-implemented email sender in the codebase. Has proper validation, admin guard, debug logging, error handling, and output encoding. However, the email template HTML is still inline rather than in a shared template.

**Flags:**
- `TECH-DEBT: cfmail in template -- should be in emailService.cfc` -- app/admin-users/ajax/send-email.cfm

---

#### 5. `sched/email_test.cfm`

- **Type:** .cfm template (diagnostic/test page)
- **cfmail count:** 1
- **SMTP config:** Uses CF server default (no `from=` attribute -- likely uses CF admin default)
- **Error handling:** YES -- cftry/cfcatch with cflog to `email_test_errors`
- **Email send logged:** YES (on failure only)
- **Email body:** Plain text test message
- **From:** Missing `from` attribute (will use CF admin default or fail)
- **To:** `kevinking7135@gmail.com` (hardcoded)
- **Notes:** Test utility. Missing `from=` attribute is a bug. Should be restricted from production access.

**Flags:**
- `TECH-DEBT: cfmail in template -- should be in emailService.cfc` -- sched/email_test.cfm
- `SECURITY: test email page accessible in production` -- sched/email_test.cfm
- `BUG: missing from= attribute on cfmail tag` -- sched/email_test.cfm

---

#### 6. `sched/error.cfm`

- **Type:** .cfm template (global error handler)
- **cfmail count:** 1
- **SMTP config:** Uses CF server default
- **Error handling:** YES -- outer cftry/cfcatch wraps everything; cflog to `TAO_errors` on both paths
- **Email send logged:** YES (via cflog)
- **Email body:** Inline HTML built via cfsavecontent, includes error details, stack trace, session info
- **From:** `support@theactorsoffice.com`
- **To:** `devEmail` defaulting to `kevinking7135@gmail.com`
- **Notes:** Solid error handler. Uses `encodeForHtml()` for error output. The `sign="false" encrypt="false"` attributes are set explicitly.

**Flags:**
- `TECH-DEBT: cfmail in template -- should be in emailService.cfc` -- sched/error.cfm

---

#### 7. `sched/standalone_email_test.cfm`

- **Type:** .cfm template (standalone SMTP test page)
- **cfmail count:** 1
- **SMTP config:** HARDCODED -- `server="127.0.0.1"` port="25" with empty username/password, no SSL/TLS
- **Error handling:** YES -- cftry/cfcatch
- **Email send logged:** NO
- **Email body:** Plain text test message
- **From:** `test@theactorsoffice.com`
- **To:** `kevinking7135@gmail.com`
- **Notes:** Test utility with hardcoded SMTP settings. Should not exist in production.

**Flags:**
- `TECH-DEBT: cfmail in template -- should be in emailService.cfc` -- sched/standalone_email_test.cfm
- `SECURITY: hardcoded SMTP credentials` -- sched/standalone_email_test.cfm (server=127.0.0.1, port=25, empty user/pass)
- `SECURITY: test email page accessible in production` -- sched/standalone_email_test.cfm

---

#### 8. `sched/thrivecart_email.cfm`

- **Type:** .cfm template (hardcoded test email)
- **cfmail count:** 1
- **SMTP config:** Uses CF server default
- **Error handling:** NONE
- **Email send logged:** NO
- **Email body:** Inline HTML welcome email with hardcoded test data (name="Test", uuid="1")
- **From:** `support@theactorsoffice.com`
- **To:** `jodie@jodiebentley.com` (hardcoded)
- **BCC:** `kevinking7135@gmail.com`
- **Notes:** This is a one-off test file that sends a hardcoded welcome email. Should be removed from production.

**Flags:**
- `TECH-DEBT: cfmail in template -- should be in emailService.cfc` -- sched/thrivecart_email.cfm
- `TECH-DEBT: email send not logged` -- sched/thrivecart_email.cfm
- `TECH-DEBT: hardcoded test data in production file` -- sched/thrivecart_email.cfm

---

#### 9. `sched/thrivecart_process_audition.cfm`

- **Type:** .cfm template (scheduled task -- audition module activation)
- **cfmail count:** 1
- **SMTP config:** Uses CF server default
- **Error handling:** NONE
- **Email send logged:** NO
- **Email body:** Inline HTML confirmation of audition module activation
- **From:** `support@theactorsoffice.com`
- **To:** `support@theactorsoffice.com`
- **BCC:** `kevinking7135@gmail.com`
- **SQL injection:** YES -- `where id = #new_id#` and `where userid = #new_userid#` without cfqueryparam
- **Notes:** Has unparameterized SQL queries alongside the cfmail. Internal notification only.

**Flags:**
- `TECH-DEBT: cfmail in template -- should be in emailService.cfc` -- sched/thrivecart_process_audition.cfm
- `TECH-DEBT: email send not logged` -- sched/thrivecart_process_audition.cfm
- `TECH-DEBT: no error handling around cfmail` -- sched/thrivecart_process_audition.cfm
- `SECURITY: unparameterized SQL in same file` -- sched/thrivecart_process_audition.cfm

---

#### 10. `ipn-cancelled.cfm`

- **Type:** .cfm template (IPN webhook handler)
- **cfmail count:** 2 (debug notification + error notification)
- **SMTP config:** Uses CF server default
- **Error handling:** YES -- outer cftry/cfcatch with cflog; inner cftry for fallback email on error
- **Email send logged:** YES -- cflog to `ipn_cancelled_debug` and `ipn_errors`
- **Email body:** Inline HTML built via string concatenation, includes raw POST data and headers
- **From:** `noreply@theactorsoffice.com`
- **To:** `kevin@theactorsoffice.com` (hardcoded as `debugEmail`)
- **Notes:** This sends raw POST data in email, which could include sensitive payment information. The `debugEmail` variable is defined but commented as "CHANGE THIS TO YOUR EMAIL." Well-structured error handling.

**Flags:**
- `TECH-DEBT: cfmail in template -- should be in emailService.cfc` -- ipn-cancelled.cfm
- `SECURITY: raw POST data (potentially sensitive payment info) emailed` -- ipn-cancelled.cfm

---

#### 11. `include/user_setup.cfm`

- **Type:** .cfm template (user account setup/provisioning)
- **cfmail count:** 1
- **SMTP config:** Uses CF server default
- **Error handling:** NONE
- **Email send logged:** NO
- **Email body:** Dynamic HTML built via cfsavecontent variable `user_output`, contains diagnostic info about what was fixed
- **From:** `support@theactorsoffice.com`
- **To:** `kevinking7135@gmail.com`
- **Notes:** Only sends email when `userstatus` is "Fixed" -- internal dev notification. The email body is accumulated throughout the entire file as a debug log.

**Flags:**
- `TECH-DEBT: cfmail in template -- should be in emailService.cfc` -- include/user_setup.cfm
- `TECH-DEBT: email send not logged` -- include/user_setup.cfm
- `TECH-DEBT: no error handling around cfmail` -- include/user_setup.cfm

---

#### 12. `include/ticketemail.cfm`

- **Type:** .cfm include template (ticket email notification)
- **cfmail count:** 1
- **SMTP config:** Uses CF server default
- **Error handling:** NONE
- **Email send logged:** NO
- **Email body:** Inline HTML with ticket details, relies on caller-scoped variables (`emailto`, `emailsubject`, `emailmessage`, `emaillinkname`, `emaillink`)
- **From:** `support@theactorsoffice.com`
- **BCC:** `kevinking7135@gmail.com`
- **CC:** `#emailcc#` (from caller)
- **Notes:** This is a reusable include, which is slightly better than full inline, but none of the caller-scoped variables are validated. No output encoding on any of the variables.

**Flags:**
- `TECH-DEBT: cfmail in template -- should be in emailService.cfc` -- include/ticketemail.cfm
- `TECH-DEBT: email send not logged` -- include/ticketemail.cfm
- `TECH-DEBT: no error handling around cfmail` -- include/ticketemail.cfm
- `TECH-DEBT: no output encoding on email body variables` -- include/ticketemail.cfm

---

#### 13. `include/ticketcomplete.cfm`

- **Type:** .cfm template (ticket completion notification)
- **cfmail count:** 1
- **SMTP config:** Uses CF server default; `usessl="true" usetls="true"` set
- **Error handling:** NONE (comment says "Removed cftry and cfcatch blocks entirely")
- **Email send logged:** NO
- **Email body:** Inline HTML with ticket details; no output encoding
- **From:** `support@theactorsoffice.com`
- **To:** User's email from DB
- **BCC:** `kking@theactorsoffice.com`
- **Notes:** The `usessl` and `usetls` attributes are set here but not on most other cfmail calls, suggesting inconsistent SMTP configuration. Comments indicate error handling was intentionally removed.

**Flags:**
- `TECH-DEBT: cfmail in template -- should be in emailService.cfc` -- include/ticketcomplete.cfm
- `TECH-DEBT: email send not logged` -- include/ticketcomplete.cfm
- `TECH-DEBT: no error handling around cfmail (intentionally removed)` -- include/ticketcomplete.cfm

---

#### 14. `include/ticket_email_client.cfm`

- **Type:** .cfm template (ticket status update email to client/tester)
- **cfmail count:** 1
- **SMTP config:** Uses CF server default; `usessl="true" usetls="true"` set
- **Error handling:** NONE
- **Email send logged:** NO
- **Email body:** Inline HTML with ticket details and full email signature (~100 lines); no output encoding
- **From:** `support@theactorsoffice.com`
- **To:** `cansoff@gmail.com` (hardcoded)
- **BCC:** `kevinking7135@gmail.com`
- **CC:** `jodie@jodiebentley.com`
- **Notes:** Sends when ticket status changes to "Implemented." Contains full duplicated email signature HTML.

**Flags:**
- `TECH-DEBT: cfmail in template -- should be in emailService.cfc` -- include/ticket_email_client.cfm
- `TECH-DEBT: email send not logged` -- include/ticket_email_client.cfm
- `TECH-DEBT: no error handling around cfmail` -- include/ticket_email_client.cfm

---

#### 15. `include/image_upload2.cfm`

- **Type:** .cfm template (image upload handler)
- **cfmail count:** 1
- **SMTP config:** Uses CF server default
- **Error handling:** NONE
- **Email send logged:** NO
- **Email body:** Diagnostic information (cookie values, pgid, userid, paths)
- **From:** `support@theactorsoffice.com`
- **To:** `kevinking7135@gmail.com`
- **Subject:** Uses `cookie.uploaddir` as subject line (exposes internal paths)
- **Notes:** Dev diagnostic email sent on every image upload. Exposes internal file paths and cookie values. Should be removed from production.

**Flags:**
- `TECH-DEBT: cfmail in template -- should be in emailService.cfc` -- include/image_upload2.cfm
- `TECH-DEBT: email send not logged` -- include/image_upload2.cfm
- `TECH-DEBT: no error handling around cfmail` -- include/image_upload2.cfm
- `SECURITY: internal file paths and cookie values sent via email` -- include/image_upload2.cfm
- `TECH-DEBT: debug email fires on every upload -- should be removed` -- include/image_upload2.cfm

---

#### 16. `include/image_upload-contact2.cfm`

- **Type:** .cfm template (contact image upload handler)
- **cfmail count:** 1
- **SMTP config:** Uses CF server default
- **Error handling:** NONE
- **Email send logged:** NO
- **Email body:** Diagnostic information (cookie values, pgid, userid, paths)
- **From:** `support@theactorsoffice.com`
- **To:** `kevinking7135@gmail.com`
- **Subject:** Uses `cookie.uploadDir_Contact` as subject line
- **Notes:** Same pattern as image_upload2.cfm. Dev diagnostic email on every contact image upload.

**Flags:**
- `TECH-DEBT: cfmail in template -- should be in emailService.cfc` -- include/image_upload-contact2.cfm
- `TECH-DEBT: email send not logged` -- include/image_upload-contact2.cfm
- `TECH-DEBT: no error handling around cfmail` -- include/image_upload-contact2.cfm
- `SECURITY: internal file paths and cookie values sent via email` -- include/image_upload-contact2.cfm
- `TECH-DEBT: debug email fires on every upload -- should be removed` -- include/image_upload-contact2.cfm

---

#### 17. `recover/404.cfm`

- **Type:** .cfm template (legacy 404 error page from TMZ codebase)
- **cfmail count:** 1
- **SMTP config:** Uses CF server default
- **Error handling:** Empty cfcatch (swallows errors silently)
- **Email send logged:** NO
- **Email body:** Inline HTML with full error dump, form dump, URL dump
- **From:** `it@tmz.com`
- **To:** Dynamic based on GetAuthUser() (TMZ-specific usernames)
- **Notes:** This is a leftover from a completely different application ("TMZTools"). References `[dbo].[errors]` (SQL Server syntax), `it@tmz.com`, and TMZ-specific users. This file should be removed entirely. It also contains a large block of commented-out SQL Server INSERT code.

**Flags:**
- `TECH-DEBT: cfmail in template -- should be in emailService.cfc` -- recover/404.cfm
- `TECH-DEBT: legacy file from different application (TMZ) -- should be removed` -- recover/404.cfm
- `SECURITY: error dumps (cfdump of error, form, url scopes) exposed to users` -- recover/404.cfm
- `SECURITY: email addresses from different organization (TMZ)` -- recover/404.cfm

---

### Consolidated cfmail Flags

#### SECURITY Flags

| Flag | File | Severity |
|---|---|---|
| `SECURITY: hardcoded SMTP credentials` | sched/standalone_email_test.cfm | HIGH |
| `SECURITY: password recovery link exposes contactid and email in URL` | auth-recoverpw.cfm | MEDIUM |
| `SECURITY: no rate limiting on password recovery` | auth-recoverpw.cfm | MEDIUM |
| `SECURITY: Host header used in recovery URL (potential injection)` | auth-recoverpw.cfm | MEDIUM |
| `SECURITY: raw POST data (potentially sensitive payment info) emailed` | ipn-cancelled.cfm | MEDIUM |
| `SECURITY: internal file paths and cookie values sent via email` | include/image_upload2.cfm | LOW |
| `SECURITY: internal file paths and cookie values sent via email` | include/image_upload-contact2.cfm | LOW |
| `SECURITY: test email page accessible in production` | sched/email_test.cfm | LOW |
| `SECURITY: test email page accessible in production` | sched/standalone_email_test.cfm | LOW |
| `SECURITY: error dumps exposed to users` | recover/404.cfm | MEDIUM |
| `SECURITY: unparameterized SQL in same file` | sched/thrivecart_process_audition.cfm | HIGH |

#### TECH-DEBT Flags

| Flag | Files Affected |
|---|---|
| `TECH-DEBT: cfmail in template -- should be in emailService.cfc` | ALL 17 occurrences across 14 files |
| `TECH-DEBT: email send not logged` | 9 files: remoteSupportFormAdd.cfm, auth-recoverpw.cfm, standalone_email_test.cfm, thrivecart_email.cfm, thrivecart_process_audition.cfm, user_setup.cfm, ticketemail.cfm, ticketcomplete.cfm, ticket_email_client.cfm, image_upload2.cfm, image_upload-contact2.cfm, recover/404.cfm |
| `TECH-DEBT: no error handling around cfmail` | 9 files: remoteSupportFormAdd.cfm, auth-recoverpw.cfm, thrivecart_email.cfm, thrivecart_process_audition.cfm, user_setup.cfm, ticketemail.cfm, ticketcomplete.cfm, ticket_email_client.cfm, image_upload2.cfm, image_upload-contact2.cfm |
| `TECH-DEBT: debug email fires on every upload -- should be removed` | image_upload2.cfm, image_upload-contact2.cfm |
| `TECH-DEBT: legacy file from different application (TMZ)` | recover/404.cfm |
| `TECH-DEBT: hardcoded Todoist integration email` | remoteSupportFormAdd.cfm |
| `TECH-DEBT: no output encoding on email body variables` | ticketemail.cfm |

#### Cross-cutting Observations

- **Hardcoded BCC:** `kevinking7135@gmail.com` appears as BCC in 13 of 14 files. This personal email address should be moved to application config.
- **No email templates:** Every email body is inline HTML. The same email signature block is duplicated in at least 3 files (remoteSupportFormAdd.cfm, ticket_email_client.cfm, remoteverticketupdate2.cfm).
- **Inconsistent SSL/TLS:** Only 2 files set `usessl="true" usetls="true"` (ticketcomplete.cfm, ticket_email_client.cfm). All others rely on CF server defaults.
- **No `from=` consistency:** Most use `support@theactorsoffice.com`, but one uses `test@theactorsoffice.com`, one uses `noreply@theactorsoffice.com`, and one uses `it@tmz.com`.

---

## 8B -- cfhttp / External API Audit

### cfhttp Summary of Findings

| Metric | Count |
|---|---|
| Total files with cfhttp (excl. dev_backup) | 12 |
| cfhttp in .cfm templates | 12 |
| cfhttp in service CFCs | 0 |
| Hardcoded API keys | 2 (icon.horse, Google OAuth) |
| No timeout set | 8 |
| No error handling on non-200 | 5 |
| Hardcoded URLs/endpoints | 12 |

---

### cfhttp Detailed File-by-File Analysis

---

#### 1. `sched/customicon3.cfm`

- **Type:** .cfm template (scheduled task -- favicon fetcher)
- **External service:** Arbitrary websites (fetches HTML to find .ico links)
- **cfhttp count:** 2 (one GET for HTML page, one GET for .ico file)
- **URL hardcoded:** Dynamic based on DB data (user-supplied siteurl)
- **Timeout set:** NO
- **Error handling on non-200:** Partial -- checks `statusCode EQ "200 OK"` for ico download but not for initial HTML fetch
- **API key hardcoded:** N/A
- **In service CFC:** NO
- **SQL injection:** YES -- `where id = #id#` without cfqueryparam
- **Notes:** Fetches arbitrary HTML from user-provided URLs with no timeout. Uses `cfexecute` with ImageMagick for conversion. No cftry/cfcatch wrapper.

**Flags:**
- `TECH-DEBT: cfhttp with no timeout` -- sched/customicon3.cfm
- `TECH-DEBT: cfhttp with no error handling` -- sched/customicon3.cfm (initial HTML fetch)
- `SECURITY: cfhttp to user-supplied URL with no validation (SSRF risk)` -- sched/customicon3.cfm
- `SECURITY: unparameterized SQL` -- sched/customicon3.cfm

---

#### 2. `sched/customicon.cfm`

- **Type:** .cfm template (scheduled task -- favicon fetcher variant)
- **External service:** Arbitrary websites (`siteurl/favicon.ico`)
- **cfhttp count:** 1
- **URL hardcoded:** Dynamic (user-supplied URL + `/favicon.ico`)
- **Timeout set:** NO
- **Error handling on non-200:** YES -- checks `statusCode EQ "200 OK"` and Content-Type; cftry/cfcatch with cflog
- **API key hardcoded:** N/A
- **In service CFC:** NO
- **SQL injection:** YES -- `where id = #id#`
- **Notes:** Contains `<cfdump var="#result#"><cfabort>` debug code left in production. Hard-coded to process a single record (id=29125).

**Flags:**
- `TECH-DEBT: cfhttp with no timeout` -- sched/customicon.cfm
- `TECH-DEBT: debug code left in production (cfdump/cfabort)` -- sched/customicon.cfm
- `SECURITY: cfhttp to user-supplied URL with no validation (SSRF risk)` -- sched/customicon.cfm

---

#### 3. `sched/avatar_loop.cfm`

- **Type:** .cfm template (scheduled task -- Gravatar fetcher)
- **External service:** Gravatar API (`https://www.gravatar.com/avatar/`)
- **cfhttp count:** 2 (one HEAD-style check, one download)
- **URL hardcoded:** Gravatar base URL is hardcoded; email hash is dynamic
- **Timeout set:** NO
- **Error handling on non-200:** Partial -- checks `StatusCode eq "200 OK"` to decide whether avatar exists
- **API key hardcoded:** N/A
- **In service CFC:** NO
- **SQL injection:** YES -- `where itemid = #x.itemid#` (3 occurrences)
- **Notes:** Hardcoded `default_avatar_filename` path. Hardcoded user IDs in WHERE clause (`u.userid in (1,12,17,99)`). No cftry/cfcatch. The second cfhttp downloads directly to filesystem using `path` and `file` attributes.

**Flags:**
- `TECH-DEBT: cfhttp with no timeout` -- sched/avatar_loop.cfm
- `TECH-DEBT: cfhttp with no error handling` -- sched/avatar_loop.cfm (no cftry)
- `SECURITY: unparameterized SQL` -- sched/avatar_loop.cfm

---

#### 4. `sched/avatar_loop2.cfm`

- **Type:** .cfm template (scheduled task -- AvatarAPI.com fetcher)
- **External service:** AvatarAPI.com (via variable `#apiEndpoint#`)
- **cfhttp count:** 2 (one POST to API, one GET to download image)
- **URL hardcoded:** API endpoint is in a variable (likely set elsewhere); image URL is dynamic from API response
- **Timeout set:** NO
- **Error handling on non-200:** Partial -- checks `apiResponse.success eq true`
- **API key hardcoded:** YES -- `#username#` and `#password#` variables are used in the request body (defined elsewhere, likely hardcoded)
- **In service CFC:** NO
- **SQL injection:** YES -- `where itemid = #x.itemid#`
- **Notes:** Uses a third-party avatar lookup API. Sends username/password credentials in the POST body. Contains `<cfdump>` debug output. No cftry/cfcatch.

**Flags:**
- `TECH-DEBT: cfhttp with no timeout` -- sched/avatar_loop2.cfm
- `TECH-DEBT: cfhttp with no error handling` -- sched/avatar_loop2.cfm (no cftry)
- `SECURITY: API credentials (username/password) sent in cfhttp POST body` -- sched/avatar_loop2.cfm
- `TECH-DEBT: debug code left in production (cfdump)` -- sched/avatar_loop2.cfm
- `SECURITY: unparameterized SQL` -- sched/avatar_loop2.cfm

---

#### 5. `sched/customicon7.cfm`

- **Type:** .cfm template (scheduled task -- icon.horse favicon fetcher)
- **External service:** icon.horse API (`https://icon.horse/icon/`)
- **cfhttp count:** 1
- **URL hardcoded:** icon.horse base URL hardcoded with query params
- **Timeout set:** NO
- **Error handling on non-200:** YES -- checks `statusCode EQ "200 OK"` ; cftry/cfcatch wraps the entire loop body
- **API key hardcoded:** YES -- `apikey=996ca328-b4b1-47a7-8d41-e5255525ab6b` in URL
- **In service CFC:** NO
- **SQL injection:** YES -- `where id = #id#`, `where siteurl = '#siteurl#'`
- **Notes:** API key exposed in URL. Contains hardcoded filesystem paths for dev, UAT, and app environments. Uses `cfexecute` with ImageMagick. Cross-datasource updates (writes to both `abo` and `abod`). Contains `<cfdump>` debug output.

**Flags:**
- `TECH-DEBT: cfhttp with no timeout` -- sched/customicon7.cfm
- `SECURITY: hardcoded API key in cfhttp call` -- sched/customicon7.cfm (icon.horse apikey=996ca328-b4b1-47a7-8d41-e5255525ab6b)
- `SECURITY: unparameterized SQL` -- sched/customicon7.cfm
- `TECH-DEBT: hardcoded filesystem paths for multiple environments` -- sched/customicon7.cfm
- `TECH-DEBT: debug code left in production (cfdump)` -- sched/customicon7.cfm

---

#### 6. `include/customicon_single.cfm`

- **Type:** .cfm include template (single favicon fetch via icon.horse)
- **External service:** icon.horse API (`https://icon.horse/icon/`)
- **cfhttp count:** 1
- **URL hardcoded:** icon.horse base URL hardcoded with query params
- **Timeout set:** NO
- **Error handling on non-200:** YES -- checks `statusCode EQ "200 OK"`
- **API key hardcoded:** YES -- `apikey=996ca328-b4b1-47a7-8d41-e5255525ab6b` in URL
- **In service CFC:** NO (but uses `services.SiteLinksService` for data retrieval)
- **Notes:** Uses a service CFC for data access but not for the HTTP call itself. Uses `cfexecute` with ImageMagick. The same icon.horse API key as customicon7.cfm.

**Flags:**
- `TECH-DEBT: cfhttp with no timeout` -- include/customicon_single.cfm
- `SECURITY: hardcoded API key in cfhttp call` -- include/customicon_single.cfm (icon.horse apikey=996ca328-b4b1-47a7-8d41-e5255525ab6b)

---

#### 7. `oauth/oauth_callback.cfm`

- **Type:** .cfm template (Google OAuth callback handler)
- **External service:** Google OAuth2 (`https://oauth2.googleapis.com/token`)
- **cfhttp count:** 1
- **URL hardcoded:** YES -- tokenUrl, clientId, clientSecret, redirectUri all hardcoded
- **Timeout set:** NO
- **Error handling on non-200:** YES -- checks `Left(tokenResponse.statusCode, 3) EQ "200"`; cftry/cfcatch for JSON parsing
- **API key hardcoded:** YES -- Google OAuth client ID and client SECRET are hardcoded in plaintext
- **In service CFC:** NO
- **Notes:** Google `clientSecret = "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"` is hardcoded in the template. Access tokens and refresh tokens are displayed in HTML output (visible in browser). Tokens stored in `taousers` table. The callback page displays raw token values before redirecting.

**Flags:**
- `SECURITY: hardcoded API key in cfhttp call` -- oauth/oauth_callback.cfm (Google clientId and clientSecret in plaintext)
- `SECURITY: access_token and refresh_token displayed in HTML before redirect` -- oauth/oauth_callback.cfm
- `TECH-DEBT: cfhttp with no timeout` -- oauth/oauth_callback.cfm
- `TECH-DEBT: cfhttp in template -- should be in an OAuthService.cfc` -- oauth/oauth_callback.cfm

---

#### 8. `include/mybilling_pane.cfm`

- **Type:** .cfm template (billing portal integration)
- **External service:** PayKickstart API (`https://app.paykickstart.com/api/billing-customer`)
- **cfhttp count:** 1
- **URL hardcoded:** YES -- base URL hardcoded; auth_token and email in query string
- **Timeout set:** NO
- **Error handling on non-200:** NO -- directly deserializes response with no status check
- **API key hardcoded:** YES -- `authToken = "4OWaGHPXFibE"` hardcoded
- **In service CFC:** NO
- **Notes:** PayKickstart auth token is hardcoded. Also contains a hardcoded Laravel session cookie placeholder (`YOUR_SESSION_COOKIE`). Has a syntax error: `cfset userEmail eq userEmail` (should be `=`). No cftry/cfcatch. No status code validation before DeserializeJSON.

**Flags:**
- `SECURITY: hardcoded API key in cfhttp call` -- include/mybilling_pane.cfm (PayKickstart authToken="4OWaGHPXFibE")
- `TECH-DEBT: cfhttp with no timeout` -- include/mybilling_pane.cfm
- `TECH-DEBT: cfhttp with no error handling` -- include/mybilling_pane.cfm
- `BUG: syntax error -- cfset userEmail eq userEmail (should be =)` -- include/mybilling_pane.cfm line 3
- `SECURITY: hardcoded session cookie header` -- include/mybilling_pane.cfm

---

#### 9. `include/get_google_calendars.cfm`

- **Type:** .cfm template (Google Calendar API integration)
- **External service:** Google Calendar API (`https://www.googleapis.com/calendar/v3/users/me/calendarList`)
- **cfhttp count:** 1
- **URL hardcoded:** YES -- Google Calendar API URL hardcoded
- **Timeout set:** NO
- **Error handling on non-200:** NO -- directly deserializes response with no status check
- **API key hardcoded:** NO -- uses `#accessToken#` variable (presumably from session/DB)
- **In service CFC:** NO
- **Notes:** No validation of response before DeserializeJSON. No cftry/cfcatch. Will crash if API returns an error response or non-JSON content.

**Flags:**
- `TECH-DEBT: cfhttp with no timeout` -- include/get_google_calendars.cfm
- `TECH-DEBT: cfhttp with no error handling` -- include/get_google_calendars.cfm

---

#### 10. `include/download_media.cfm`

- **Type:** .cfm template (media file download proxy)
- **External service:** Self-referential (`https://#host#.theactorsoffice.com/...`)
- **cfhttp count:** 1
- **URL hardcoded:** Dynamic -- constructs URL from host and session variables
- **Timeout set:** NO
- **Error handling on non-200:** NO -- uses `throwOnError="yes"` but no cftry/cfcatch
- **API key hardcoded:** N/A
- **In service CFC:** NO
- **Notes:** Downloads a file via HTTP and serves it to the user. The `throwOnError="yes"` without cftry will produce an ugly CF error page on failure. The URL construction uses session-scoped path variables.

**Flags:**
- `TECH-DEBT: cfhttp with no timeout` -- include/download_media.cfm
- `TECH-DEBT: cfhttp with no error handling` -- include/download_media.cfm (throwOnError without cftry)

---

#### 11. `include/customicon.cfm`

- **Type:** .cfm include template (favicon fetcher)
- **External service:** Arbitrary websites (`siteurl/favicon.ico`)
- **cfhttp count:** 1
- **URL hardcoded:** Dynamic (user-supplied URL + `/favicon.ico`)
- **Timeout set:** NO
- **Error handling on non-200:** YES -- checks `statusCode EQ "200 OK"` and Content-Type; cftry/cfcatch with cflog
- **API key hardcoded:** N/A
- **In service CFC:** NO
- **Notes:** Contains `<cfabort>` on line 14 which prevents the cfhttp from ever executing. Dead code.

**Flags:**
- `TECH-DEBT: cfhttp with no timeout` -- include/customicon.cfm
- `TECH-DEBT: dead code -- cfabort prevents cfhttp from executing` -- include/customicon.cfm

---

#### 12. `test-ipn-cancelled.cfm`

- **Type:** .cfm template (IPN test utility)
- **External service:** Self-referential (POSTs to own `ipn-cancelled.cfm`)
- **cfhttp count:** 1
- **URL hardcoded:** Dynamic -- constructs URL from `cgi.server_name`
- **Timeout set:** YES -- `timeout="30"`
- **Error handling on non-200:** Partial -- displays status code but no conditional logic
- **API key hardcoded:** N/A
- **In service CFC:** NO
- **Notes:** Test utility. Only file with an explicit timeout.

**Flags:**
- `SECURITY: test utility accessible in production` -- test-ipn-cancelled.cfm

---

#### 13. `test-ipn-cli.cfm`

- **Type:** .cfm template (IPN CLI-style test utility)
- **External service:** Self-referential (POSTs to own `ipn-cancelled.cfm`)
- **cfhttp count:** 1
- **URL hardcoded:** Dynamic -- constructs URL from `cgi.server_name`
- **Timeout set:** YES -- `timeout="30"`
- **Error handling on non-200:** Partial -- displays status code
- **API key hardcoded:** N/A
- **In service CFC:** NO
- **Notes:** Test utility. References `variables.startTime` after it is used (set at bottom of file, used at top). Bug: will throw undefined variable error.

**Flags:**
- `SECURITY: test utility accessible in production` -- test-ipn-cli.cfm
- `BUG: variables.startTime used before defined` -- test-ipn-cli.cfm

---

### Consolidated cfhttp Flags

#### SECURITY Flags

| Flag | File | Detail | Severity |
|---|---|---|---|
| `SECURITY: hardcoded API key in cfhttp call` | oauth/oauth_callback.cfm | Google OAuth clientId + clientSecret in plaintext | **CRITICAL** |
| `SECURITY: hardcoded API key in cfhttp call` | include/mybilling_pane.cfm | PayKickstart authToken="4OWaGHPXFibE" | **HIGH** |
| `SECURITY: hardcoded API key in cfhttp call` | sched/customicon7.cfm | icon.horse apikey in URL | **MEDIUM** |
| `SECURITY: hardcoded API key in cfhttp call` | include/customicon_single.cfm | icon.horse apikey in URL (same key) | **MEDIUM** |
| `SECURITY: API credentials in cfhttp POST body` | sched/avatar_loop2.cfm | AvatarAPI username/password | **HIGH** |
| `SECURITY: access_token and refresh_token displayed in HTML` | oauth/oauth_callback.cfm | Tokens visible before redirect | **HIGH** |
| `SECURITY: cfhttp to user-supplied URL (SSRF risk)` | sched/customicon3.cfm | Fetches arbitrary URLs from DB | **MEDIUM** |
| `SECURITY: cfhttp to user-supplied URL (SSRF risk)` | sched/customicon.cfm | Fetches arbitrary URLs from DB | **MEDIUM** |
| `SECURITY: hardcoded session cookie header` | include/mybilling_pane.cfm | Laravel session cookie in header | **LOW** |
| `SECURITY: test utility accessible in production` | test-ipn-cancelled.cfm | IPN test page | **LOW** |
| `SECURITY: test utility accessible in production` | test-ipn-cli.cfm | IPN CLI test page | **LOW** |

#### TECH-DEBT Flags

| Flag | Files Affected |
|---|---|
| `TECH-DEBT: cfhttp with no timeout` | 11 of 13 files (all except test-ipn-cancelled.cfm and test-ipn-cli.cfm) |
| `TECH-DEBT: cfhttp with no error handling` | customicon3.cfm (partial), avatar_loop.cfm, avatar_loop2.cfm, mybilling_pane.cfm, get_google_calendars.cfm, download_media.cfm |
| `TECH-DEBT: debug code left in production` | customicon.cfm (cfdump/cfabort), avatar_loop2.cfm (cfdump), customicon7.cfm (cfdump) |
| `TECH-DEBT: dead code` | include/customicon.cfm (cfabort prevents execution) |
| `TECH-DEBT: hardcoded filesystem paths` | sched/customicon7.cfm, sched/avatar_loop.cfm |

#### BUG Flags

| Flag | File |
|---|---|
| `BUG: syntax error -- cfset userEmail eq userEmail` | include/mybilling_pane.cfm (line 3) |
| `BUG: variables.startTime used before defined` | test-ipn-cli.cfm |

---

## Recommendations

### Priority 1 -- Immediate Security Fixes

1. **Move all API credentials to application config or encrypted secrets storage:**
   - Google OAuth clientId/clientSecret (oauth/oauth_callback.cfm)
   - PayKickstart authToken (include/mybilling_pane.cfm)
   - icon.horse API key (sched/customicon7.cfm, include/customicon_single.cfm)
   - AvatarAPI username/password (sched/avatar_loop2.cfm)

2. **Stop displaying OAuth tokens in HTML output** (oauth/oauth_callback.cfm) -- store tokens and redirect immediately without rendering them.

3. **Remove or restrict test/diagnostic pages from production:**
   - sched/email_test.cfm
   - sched/standalone_email_test.cfm
   - sched/thrivecart_email.cfm
   - test-ipn-cancelled.cfm
   - test-ipn-cli.cfm
   - include/image_upload2.cfm (debug email)
   - include/image_upload-contact2.cfm (debug email)

4. **Remove legacy TMZ file:** recover/404.cfm

5. **Add rate limiting to password recovery** (auth-recoverpw.cfm) and stop using `cgi.server_name` in recovery URLs.

### Priority 2 -- Create Centralized Email Service

1. **Create `services/EmailService.cfc`** with methods:
   - `sendWelcomeEmail(userEmail, firstName, setupUUID, hostName)`
   - `sendPasswordResetEmail(userEmail, firstName, contactId, recoverUUID, hostName)`
   - `sendTicketNotification(ticketId, emailTo, subject, message, link, linkName)`
   - `sendTicketCompletionEmail(ticketId, userEmail, firstName, response)`
   - `sendErrorNotification(errorInfo)`
   - `sendInternalNotification(subject, body)`

2. **Move email templates to shared template files** (e.g., `/include/email-templates/`) to eliminate the ~500 lines of duplicated HTML signature blocks.

3. **Centralize the `from` address and BCC configuration** in `Application.cfc` or a config file.

4. **Add logging to all email sends** (at minimum: timestamp, to, subject, success/failure).

### Priority 3 -- cfhttp Hardening

1. **Add `timeout` attribute to all cfhttp calls.** Recommended: 30 seconds for API calls, 60 seconds for file downloads.

2. **Add proper error handling:**
   - Check `statusCode` before processing response
   - Wrap in cftry/cfcatch
   - Log failures

3. **Create service CFCs for external integrations:**
   - `services/GoogleCalendarService.cfc` (OAuth + Calendar API)
   - `services/PayKickstartService.cfc` (billing)
   - `services/IconService.cfc` (favicon fetching via icon.horse)
   - `services/GravatarService.cfc` (avatar lookups)

4. **Validate URLs before cfhttp** to prevent SSRF: block private/internal IP ranges when fetching user-supplied URLs (customicon*.cfm).

5. **Fix bugs:**
   - mybilling_pane.cfm line 3: `cfset userEmail eq userEmail` -> `cfset userEmail = userEmail`
   - test-ipn-cli.cfm: move `variables.startTime` assignment before its usage

### Priority 4 -- Cleanup

1. Remove all `cfdump`/`cfabort` debug code from production files.
2. Remove dead code in include/customicon.cfm (cfabort on line 14).
3. Parameterize all SQL in sched/ files flagged above.
4. Standardize SSL/TLS settings across all cfmail tags.

---

*End of Phase 8 -- Email & External Integrations Audit*
