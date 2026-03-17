# Phase 5 -- Architecture Audit

Audited: 2026-03-16
Branch: `dev` @ `ce57de13`
Scope: Application.cfc lifecycle, service instantiation, scope leaks, error handling, environment config

---

## 5A -- Application.cfc Deep Read

### Main: `/app/Application.cfc`

#### `this.*` settings

| Setting | Value | Assessment |
|---------|-------|------------|
| `this.name` | `"TAO"` | Shared across all sub-apps that need session sharing |
| `this.datasource` | `application.dsn` (derived from hostname) | No hardcoded credentials -- DSN name resolved from CF admin |
| `this.sessionManagement` | `true` | Correct |
| `this.applicationTimeout` | `createTimeSpan(11,1,0,0)` = **11 days 1 hour** | Extremely long -- see finding below |
| `this.sessionTimeout` | `createTimeSpan(0,9,20,0)` = **9 hours 20 min** | Very long for a web app -- see finding below |
| `this.loginStorage` | `"session"` | Correct |
| `this.strictVariables` | `false` | Enables implicit scope resolution; hinders bug detection |
| `this.searchImplicitScopes` | `true` | Allows unscoped variable reads across all scopes |
| `this.enableNullSupport` | `false` | Reasonable for legacy compat |

#### `onApplicationStart`
- Rebuilds `application.datasource` and `application.services` registry
- Calls `loadFeatureFlags()` which queries `feature_flags` and `feature_flag_users` tables
- Service registry contains only 1 service: `AuditionSubmitSiteUserService`; the other 136 services are not registered (all per-request)

#### `onSessionStart`
- **NOT IMPLEMENTED** -- no session initialization, no audit logging, no default values

#### `onSessionEnd`
- **NOT IMPLEMENTED** -- no cleanup, no session-end auditing

#### `onRequestStart`
- Normalizes URL/FORM params into `request.p` merged map (good pattern)
- Admin impersonation gate via `?u=` with role check (proper auth check)
- Login gate redirects unauthenticated users to `/loginform.cfm`
- CSRF token generation for authenticated sessions
- **On every request**: includes `/include/qry/fetchUsers.cfm` which instantiates `UserService` via `createObject`, runs a DB query, and dumps 60+ bare variables into the caller's `variables` scope (e.g. `userFirstName`, `accessToken`, `refreshToken`)
- Session media paths rebuilt on every request (duplicated in impersonation block and post-login block)

#### `onRequest`
- Simple include wrapper: `<cfinclude template="#arguments.targetPage#" />`

#### `onRequestEnd`
- **NOT IMPLEMENTED**

#### `onError`
- Implemented with AJAX detection (checks `X-Requested-With`, `Accept` header, and `/ajax/` in path)
- AJAX errors: returns JSON with `success`, `message`, `detail`, `type`, and partial `sql` (capped at 300 chars)
- Browser errors: **`<cfdump>` of full exception** -- exposes stack traces, SQL, file paths to end users
- No logging to file or alerting system

#### Utility function
- `formatDate()` -- user-facing date formatter. Reads `session.dateformatExample` but properly `var`-scoped.

### Findings

| ID | Level | Finding |
|----|-------|---------|
| A01 | :warning: | **Session timeout 9h20m is very long.** Standard web apps use 20-30 minutes. Increases window for session hijacking. |
| A02 | :warning: | **Application timeout 11d1h.** Prevents `onApplicationStart` from re-running. Feature flag cache partially compensates but service registry and media paths stay stale for 11 days. |
| A03 | :x: | **`onError` dumps raw exception to browser in non-AJAX mode.** `<cfdump var="#arguments.exception#">` exposes file paths, SQL statements, CF internals to end users. |
| A04 | :x: | **`onError` leaks partial SQL in AJAX JSON.** `left(arguments.exception.sql, 300)` sends database query fragments to the client. |
| A05 | :x: | **No `onSessionStart` / `onSessionEnd`.** No audit trail of login sessions, no cleanup of temp resources. |
| A06 | :x: | **`fetchUsers.cfm` runs on every request.** Creates `UserService` per-request and runs a DB query. Dumps OAuth tokens (`refreshToken`, `accessToken`) and billing data into the variables scope on every page load. |
| A07 | :warning: | **`fetchUsers.cfm` dumps 60+ bare unscoped variables.** `<cfset userFirstName = userData.userFirstName>` etc. These leak into the `variables` scope of the calling template. With `strictVariables=false` and `searchImplicitScopes=true`, any template can accidentally read/shadow them. |
| A08 | :warning: | **`application.dbug = "Y"` is hardcoded at component body level** (line 7). This runs on every Application.cfc load, not gated by environment. Debug flag in application scope is readable by all requests. |
| A09 | :warning: | **Session media path code is duplicated** in the impersonation block (lines 272-292) and the post-login block (lines 316-337). Divergence risk. |
| A10 | :recycle: | **Service registry is vestigial.** Only `AuditionSubmitSiteUserService` is registered. `application.services` is never referenced outside `Application.cfc`. All 136 other services are instantiated per-request. |

---

### Sub-Application.cfc Files

#### `/ajax/Application.cfc`
- `this.name = "TAO"` -- shares session with main app (correct)
- `this.serialization.preserveCaseForStructKey = true` -- good for JSON APIs
- **Duplicates DSN detection logic** instead of extending `/app/Application`
- Auth check: returns 401 JSON for unauthenticated requests (good)
- CSRF validation for POST/PUT/DELETE with header or form field (good)
- CSRF is only validated **if token is provided** -- not enforced. `<cfif len(csrfHeader)>` means requests without a token pass through.

| ID | Level | Finding |
|----|-------|---------|
| A11 | :x: | **CSRF validation is opt-in, not enforced.** If no `X-CSRF-Token` header or `csrfToken` form field is sent, the request proceeds without validation. Attackers simply omit the token. |
| A12 | :recycle: | **DSN config duplicated** from main Application.cfc. Should extend parent or share config. |

#### `/app/ajax/Application.cfc`
- `this.name = "TAO"` (correct)
- Auth check returns 401 JSON (good)
- **Does not set `this.datasource`** -- relies on inherited CF admin default
- **No CSRF validation** -- unlike `/ajax/Application.cfc`
- Has `onRequest` include wrapper

| ID | Level | Finding |
|----|-------|---------|
| A13 | :warning: | **No datasource explicitly set.** Missing `this.datasource` means it relies on CF server default. |
| A14 | :warning: | **No CSRF validation** for this AJAX path, unlike `/ajax/`. Inconsistent security posture. |

#### `/include/Application.cfc`
- `extends="/app/Application"` -- inherits from main (good)
- `onRequestStart` only sets `application.datasourceName = application.dsn` (redundant)
- **Returns `void` instead of `boolean`** for `onRequestStart` -- technically incorrect signature

| ID | Level | Finding |
|----|-------|---------|
| A15 | :warning: | **`onRequestStart` return type is `void` not `boolean`.** May cause issues with some CF engines. Parent's auth checks are bypassed since this overrides without calling `super.onRequestStart()`. |

#### `/sched/Application.cfc`
- `extends="/app/Application"` (good)
- Allows localhost (`127.0.0.1`, `::1`) without auth -- correct for CF scheduler
- External requests require authenticated session (good)
- Returns `boolean` (correct)

| ID | Level | Finding |
|----|-------|---------|
| A16 | :warning: | **Scheduler auth only checks `session.userid` exists for external requests**, does not verify admin role. Any authenticated user could hit scheduler endpoints directly. |

#### `/database/Application.cfc`
- Standalone (does not extend parent)
- `this.name = "TAO"` -- shares session
- `this.sessionTimeout = createTimeSpan(0, 0, 30, 0)` = 30 min (appropriate for admin tool)
- Auth check: 403 + abort for unauthenticated (good)
- **No admin role check** -- any authenticated user can access database admin pages

| ID | Level | Finding |
|----|-------|---------|
| A17 | :x: | **Database admin pages have no role check.** Any authenticated user can access `/database/` endpoints. Must verify `userRole = "Admin"`. |
| A18 | :recycle: | **Duplicates DSN config logic.** Should extend parent or share centralized config. |

#### `/setup/Application.cfc`
- Standalone with `this.name = "Setup"` -- **separate application scope** (does not share sessions with main app!)
- `this.applicationTimeout = createTimeSpan(1,0,0,0)` = 1 day (reasonable)
- `this.sessionTimeout = createTimeSpan(0,0,30,0)` = 30 min (good)
- `application.dbug = "N"` (overrides main app's "Y")
- **Hardcoded production path**: `application.baseMediaPath = "C:\home\theactorsoffice.com\media-"` -- no dev path fallback
- Auth check: 403 + abort (good)
- No admin role check

| ID | Level | Finding |
|----|-------|---------|
| A19 | :x: | **`this.name = "Setup"` means setup pages do NOT share sessions with main app.** User authenticates in TAO app but setup has a separate session scope. Auth check on `session.userid` will always fail unless user also logged in within the setup app context. |
| A20 | :warning: | **Hardcoded production media path** without dev environment fallback. |
| A21 | :warning: | **No admin role verification** -- any authenticated user can access setup pages. |

#### `/share/Applicationx.cfc` (inactive -- note the "x" suffix)
- `this.name = "TAO_Share"` -- separate app scope (correct for public sharing)
- Has `onApplicationStart`, `onRequestStart`, `onMissingTemplate`
- **Bug**: Dev environment sets `application.information_schema = "actorsbusinessoffice"` (should be `"new_development"`)
- Hardcoded production media path only
- Minimal token validation stub (not implemented)

| ID | Level | Finding |
|----|-------|---------|
| A22 | :warning: | **Dev schema bug in `Applicationx.cfc`**: both branches set `information_schema = "actorsbusinessoffice"`. Dev branch should use `"new_development"`. |

---

## 5B -- Service Instantiation Audit

### Summary
- **137 service CFC files** exist in `/services/`
- **1 service** is registered in `application.services` (in `onApplicationStart`)
- **965 `createObject("component", ...)` calls** found across 953 unique files outside Application.cfc and services/
- Every page request that touches a service creates a new CFC instance, runs its constructor, and discards it at request end

### Top 10 Most Frequently Per-Request Instantiated Services

| Service | Per-request `createObject` count |
|---------|----------------------------------|
| `ContactItemService` | 81 |
| `ContactService` | 57 |
| `EventService` | 52 |
| `AuditionProjectService` | 47 |
| `NotificationService` | 43 |
| `TicketService` | 34 |
| `UserService` | 31 |
| `PageService` | 26 |
| `SystemUserService` | 23 |
| `NoteService` | 23 |

### Findings

| ID | Level | Finding |
|----|-------|---------|
| B01 | :x: | **965 per-request `createObject` calls across the codebase.** Each constructs a CFC, allocates memory, and is GC'd at request end. Major performance and memory pressure issue at scale. |
| B02 | :warning: | **`application.services` registry exists but is unused.** Only `AuditionSubmitSiteUserService` is registered. No code references `application.services.*` to retrieve cached instances. |
| B03 | :recycle: | **`fetchUsers.cfm` creates `UserService` on every request** (called from `onRequestStart`). This alone means 31+ service instantiations could be eliminated by caching in application scope. |

---

## 5C -- Scope Leak Audit

### `fetchUsers.cfm` -- The Primary Scope Leak Vector

`/include/qry/fetchUsers.cfm` is included on every authenticated request from `onRequestStart`. It sets **60+ bare unscoped variables** including:

**Security-sensitive variables leaked to `variables` scope every request:**
- `accessToken` -- OAuth access token
- `refreshToken` -- OAuth refresh token
- `customerId`, `customerEmail` -- billing identity
- `invoiceId`, `purchaseAmountCents` -- payment data
- `billingAddress`, `billingCity`, `billingZip`, `billingCountry`, `billingState`

**User identity variables:**
- `userId`, `uid`, `uuid`, `userFirstName`, `userLastName`, `userEmail`, `userRole`, `userStatus`
- `calendarName`, `shareid`, etc.

Because `this.strictVariables = false` and `this.searchImplicitScopes = true`, any template included after `fetchUsers.cfm` can read these variables without scope qualification. This is by design for legacy compat but creates:
1. Risk of accidental shadowing (a local `userId` clobbers the request-level one)
2. OAuth tokens available in every template's variable scope

### `variables.*` Scope Writes Inside Service CFCs

The following services write to `variables.*` scope (constructor-level or init-level). This is **correct** for per-request instances but would become a **thread-safety bug** if these services are ever cached in `application` scope:

- `services/ImportV3Logger.cfc` -- 8 `variables.*` writes (correlationId, endpoint, debugTrail, etc.)
- `services/ImportAuditionsLogger.cfc` -- 8 `variables.*` writes (same pattern)
- `services/AuditionImportService.cfc` -- `variables.VALID_STATUSES`, `variables.STATUS_TRANSITIONS`
- `services/ContactImportV3Service.cfc` -- `variables.VALID_STATUSES`, `variables.STATUS_TRANSITIONS`
- `services/ContactImportV2Service.cfc` -- 5 service dependencies cached in `variables` scope
- `services/RelationshipService.cfc` -- `variables.enableLogging`, `variables.logFile`

### `application.dbug` User-Specific Gating

`application.dbug` is set to `"Y"` at the component body level (not in `onApplicationStart`). It's used with user-specific checks:
- `include/debugLog.cfm:4` -- `<cfif application.dbug eq "Y" and userid eq 30>`
- `include/qry/delete_ref_368_4.cfm:5` -- `<cfif application.dbug eq "Y" and userid eq 30>`

This is a **hardcoded user ID** (`30`) gating debug output in shared scope.

### Findings

| ID | Level | Finding |
|----|-------|---------|
| C01 | :x: | **OAuth tokens (`accessToken`, `refreshToken`) dumped into `variables` scope on every request** via `fetchUsers.cfm`. Any template or included file can read them. |
| C02 | :x: | **60+ unscoped variables set on every request.** With `strictVariables=false`, any naming collision silently shadows values. No `var` keyword, no scope prefix. |
| C03 | :warning: | **Logger services write mutable state to `variables` scope.** Safe only because they are per-request. If moved to `application.services`, these become race conditions. Document this constraint before any caching refactor. |
| C04 | :warning: | **`application.dbug` is a global flag gated by hardcoded user ID `30`.** Should use a feature flag or admin setting, not a magic number. |

---

## 5D -- Error Handling Audit

### Exception Handling Overview
- **284 `<cfcatch>` tag blocks** across the codebase (excluding dev_backup)
- **153 `catch()` cfscript blocks** across the codebase (excluding dev_backup)
- Total: ~437 exception catch points

### Swallowed Exceptions -- Empty Catch Bodies

#### CFScript empty `catch(any e) {}` blocks (12 total):

| File | Line(s) | Context |
|------|---------|---------|
| `services/ContactImportV3Service.cfc` | 213, 245, 296, 352 | Logger/lock operations silently swallowed |
| `services/AuditionImportService.cfc` | 173, 205, 249, 252, 308, 1172, 1345, 1534 | Logger, lock release, and status update errors silently swallowed |

#### Tag-based empty/comment-only `<cfcatch>` blocks (36+ total):

| File | Empty catches | Context |
|------|---------------|---------|
| `ajax/import-auditions/columns.cfm` | 4 | JSON parse and status errors swallowed |
| `ajax/import-auditions/finalize.cfm` | 2 | Finalization errors swallowed |
| `ajax/import-auditions/recompute.cfm` | 3 | Recompute errors swallowed |
| `ajax/importv3/columns.cfm` | 4 | JSON parse and status errors swallowed |
| `ajax/importv3/finalize.cfm` | 2 | Finalization errors swallowed |
| `ajax/importv3/finalize_update.cfm` | 1 | Update error swallowed |
| `ajax/importv3/preview_update.cfm` | 1 | Preview error swallowed |
| `ajax/importv3/recompute.cfm` | 3 | Recompute errors swallowed |
| `include/bigbrotherinclude.cfm` | 1 | Monitoring include fully swallowed |
| `recover/404.cfm` | 2 | Error recovery page swallows its own errors |

#### Comment-only catches (intentional but still silent):
Multiple catches across import endpoints have `<!--- Ignore logging errors --->` or `<!--- ignore JSON parse errors --->`. These are intentionally silent but prevent diagnosis of persistent logging failures.

### `onError` Implementation Issues

The main `app/Application.cfc` is the **only** Application.cfc with an `onError` handler. The sub-applications (`/ajax/`, `/app/ajax/`, `/include/`, `/sched/`, `/database/`, `/setup/`) have **no `onError`** handler.

- `/ajax/Application.cfc` -- no `onError`: uncaught exceptions produce default CF error pages (not JSON)
- `/database/Application.cfc` -- no `onError`: admin tool errors produce raw CF dumps
- `/sched/Application.cfc` -- no `onError`: scheduler failures are silently lost

### Findings

| ID | Level | Finding |
|----|-------|---------|
| D01 | :x: | **48+ swallowed exceptions** (12 empty cfscript catches + 36+ empty/comment-only cfcatch blocks). Silent failures in import pipelines, finalization, and monitoring. |
| D02 | :x: | **`onError` shows `<cfdump>` to end users** in browser mode. Exposes file paths, SQL, internal state. |
| D03 | :x: | **`onError` sends SQL fragments in JSON** to AJAX clients. `left(arguments.exception.sql, 300)` leaks query structure. |
| D04 | :warning: | **No `onError` in 5 of 7 Application.cfc files.** Uncaught exceptions in `/ajax/`, `/sched/`, `/database/`, `/setup/`, `/include/` produce CF default error output. `/sched/` errors may be completely lost. |
| D05 | :warning: | **No error logging to file in `onError`.** Errors are only displayed, never persisted. No `<cflog>` call, no error table, no alerting. |
| D06 | :warning: | **`onError` in main app does not check `application.dbug` flag.** Always dumps full exception regardless of environment. |

---

## 5E -- Environment Config Audit

### Environment Detection Mechanism

All Application.cfc files use the same pattern:
```
host = ListFirst(cgi.server_name, ".");
if (host EQ "app") { /* production */ } else { /* development */ }
```

- Production: `host = "app"` -> `dsn = "abo"`, schema = `"actorsbusinessoffice"`
- Development: anything else -> `dsn = "abod"`, schema = `"new_development"`

### Config Switching Assessment

| Aspect | Status |
|--------|--------|
| Separate config files per environment | **None** -- all inline in Application.cfc |
| Environment variable usage | **None** |
| `.env` or properties files | **None** |
| Feature flags | DB-driven via `feature_flags` table (good) |
| DSN credentials | Server-managed via CF admin (good -- no passwords in code) |
| Media paths | Hardcoded production path `C:\home\theactorsoffice.com\...` in `setup/Application.cfc` and `share/Applicationx.cfc`; main app uses `expandPath()` fallback for dev |

### DSN Configuration Duplication

The hostname-to-DSN mapping is duplicated in **6 separate files**:
1. `/app/Application.cfc` (lines 10-18)
2. `/ajax/Application.cfc` (lines 15-21)
3. `/database/Application.cfc` (lines 3-11)
4. `/setup/Application.cfc` (lines 22-30)
5. `/share/Applicationx.cfc` (lines 30-36)
6. Setup templates

Files that `extends="/app/Application"` correctly inherit:
- `/include/Application.cfc`
- `/sched/Application.cfc`

### Session Scope Fragmentation

| Application.cfc | `this.name` | Shares sessions with main app? |
|-----------------|-------------|-------------------------------|
| `/app/` | `"TAO"` | Yes (is the main app) |
| `/ajax/` | `"TAO"` | Yes |
| `/app/ajax/` | `"TAO"` | Yes |
| `/include/` | inherits `"TAO"` | Yes |
| `/sched/` | inherits `"TAO"` | Yes |
| `/database/` | `"TAO"` | Yes |
| `/setup/` | `"Setup"` | **NO -- separate session scope** |
| `/share/Applicationx.cfc` | `"TAO_Share"` | No (intentionally separate) |

### Findings

| ID | Level | Finding |
|----|-------|---------|
| E01 | :warning: | **No environment config files.** All environment switching is inline hostname checks duplicated across 6 Application.cfc files. |
| E02 | :recycle: | **DSN config duplicated in 6 files.** Single change to DSN requires editing 6 files. Recommend centralizing into a shared config include or having all sub-apps extend the main Application.cfc. |
| E03 | :x: | **`/setup/Application.cfc` uses `this.name = "Setup"`** -- it cannot share sessions with the main TAO app. Auth checks against `session.userid` will fail since it is a different session scope. |
| E04 | :warning: | **No staging environment support.** Only production (`app`) and development (everything else). No way to test with production-like config without deploying to `app.*`. |
| E05 | :warning: | **Hardcoded production file paths** in `/setup/Application.cfc` (line 41) and `/share/Applicationx.cfc` (line 53). These will fail on dev/local environments. |

---

## Consolidated Critical Findings Summary

### Critical (:x:) -- 10 items
| ID | Area | Summary |
|----|------|---------|
| A03 | Error handling | `onError` dumps raw exception to browser |
| A04 | Error handling | `onError` leaks SQL fragments in JSON |
| A05 | Lifecycle | No `onSessionStart`/`onSessionEnd` |
| A06 | Performance | `fetchUsers.cfm` + UserService per-request on every page |
| A17 | Auth | `/database/` has no admin role check |
| A19 | Session | `/setup/` uses wrong `this.name`, cannot share sessions |
| B01 | Performance | 965 per-request `createObject` calls |
| C01 | Security | OAuth tokens in variables scope every request |
| D01 | Reliability | 48+ swallowed exceptions |
| D02 | Security | `onError` exposes internals to users |

### Needs Review (:warning:) -- 18 items
A01, A02, A07, A08, A09, A10, A11, A13, A14, A15, A16, A20, A21, A22, C03, C04, D04, D05, D06, E01, E04, E05

### Merge Candidates (:recycle:) -- 4 items
A10, A12, A18, B02, B03, E02

---

## Recommended Priority Actions

1. **Immediate security**: Remove `<cfdump>` from `onError`; replace with logged error + generic user message. Remove `exception.sql` from JSON response.
2. **Immediate security**: Add admin role check to `/database/Application.cfc` `onRequestStart`.
3. **Immediate security**: Make CSRF validation in `/ajax/Application.cfc` mandatory (reject requests without token, not just validate if present).
4. **Performance**: Move top-10 services into `application.services` registry. Start with stateless services (`ContactService`, `EventService`, `PageService`). Audit each for `variables.*` mutable state first.
5. **Performance**: Cache `fetchUsers.cfm` result in session scope instead of re-querying every request. Only refresh on login/impersonation.
6. **Architecture**: Fix `/setup/Application.cfc` to use `this.name = "TAO"` or extend `/app/Application`.
7. **Architecture**: Centralize DSN config -- have all sub-app Application.cfc files extend `/app/Application` instead of duplicating hostname detection.
8. **Reliability**: Add `<cflog>` to all empty catch blocks, at minimum logging the exception message and the file/line context.
9. **Reliability**: Add `onError` handlers to sub-application Application.cfc files, or have them extend the main app which already has one.
10. **Security**: Move OAuth tokens out of `fetchUsers.cfm` bare variable dump. Store in `session` scope only if needed, never in `variables`.
