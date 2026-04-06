# Phase 15 — Full Risk Register

Generated: 2026-03-16

Consolidated from all audit phases. Severity: CRITICAL / HIGH / MEDIUM / LOW / INFO.
Sorted by: Severity DESC, Category ASC.

---

## CRITICAL Findings

| ID | Severity | Category | File/Area | Finding | Tag | Recommended Action |
|---|---|---|---|---|---|---|
| R-001 | CRITICAL | SECURITY | Multiple /qry files + services | 46 SQL injection vectors — variables interpolated without cfqueryparam | 🔒 SECURITY | Wrap ALL variables in cfqueryparam; prioritize user-facing inputs (url.*, form.*) |
| R-002 | CRITICAL | SECURITY | 94 form handlers | Zero CSRF protection on ANY form POST in the entire application — 94 unprotected forms found, 0 protected | 🔒 SECURITY | Implement CSRF token generation and validation framework |
| R-003 | CRITICAL | SECURITY | app/Application.cfc | Session cookies missing httponly and secure flags | 🔒 SECURITY | Add `this.sessioncookie.httponly = true` and `this.sessioncookie.secure = true` |
| R-004 | CRITICAL | SECURITY | 3 files | Hardcoded credentials (passwords, API keys) in application code | 🔒 SECURITY | Move to server-level environment variables immediately |
| R-005 | CRITICAL | ARCH | /include/qry/ | 1,267 /qry files — 76% are page-specific SQL duplicates; scope-leaking cfinclude pattern with implicit in/out via variables scope | 🚩 MIGRATE | Execute /qry elimination plan (Phase 12) — consolidate to ~175 repository methods |
| R-006 | CRITICAL | ARCH | /include/pgload.cfm | Dynamic cfinclude loads qry files from database — cannot statically verify which files are used | ⚠️ ARCH | Query pages table to map pgFilename → qry file usage before any deletion |

## HIGH Findings

| ID | Severity | Category | File/Area | Finding | Tag | Recommended Action |
|---|---|---|---|---|---|---|
| R-007 | HIGH | SECURITY | 20 locations | XSS vectors — user input output without encodeForHTML() | 🔒 SECURITY | Add encodeForHTML() to all user-derived output |
| R-008 | HIGH | SECURITY | 8 cffile locations | File uploads with no server-side MIME validation or filename sanitization | 🔒 SECURITY | Add MIME whitelist, sanitize filenames, store outside webroot |
| R-009 | HIGH | SECURITY | Login flow | No sessionInvalidate() on login — session fixation vulnerability | 🔒 SECURITY | Call sessionInvalidate() before creating new session at login |
| R-010 | HIGH | SECURITY | Multiple templates | Client-side-only validation with no server-side equivalent | 🔒 SECURITY | Add server-side validation for all form inputs |
| R-011 | HIGH | PERFORMANCE | Multiple services | N+1 query patterns detected — queries inside loops | 🚩 MIGRATE | Rewrite with JOINs or IN() clauses |
| R-012 | HIGH | ARCH | Services layer | NotificationService.cfc + NotificationsService.cfc — duplicate service for same entity | 🔁 MERGE | Merge into single NotificationService |
| R-013 | HIGH | ARCH | Services layer | ContactService.cfc + ContactService_Consolidated.cfc — parallel implementations | 🔁 MERGE | Merge — consolidated should replace original |
| R-014 | HIGH | ARCH | Services layer | AuditionGenreService.cfc + AuditionGenreService_standardized.cfc — parallel implementations | 🔁 MERGE | Standardized should replace original |
| R-015 | HIGH | OBSERVABILITY | Entire codebase | Minimal logging infrastructure — majority of service functions have no logging | ⚠️ TECH-DEBT | Implement structured logging service |
| R-016 | HIGH | OBSERVABILITY | Application.cfc onError | Error handler may expose stack traces to end users | 🔒 SECURITY | Show generic error page; log full stack trace server-side |
| R-017 | HIGH | DATABASE | fusystemusers, contactdetails | Multi-step writes without cftransaction — partial failures leave orphaned data | ⚠️ TECH-DEBT | Wrap related writes in cftransaction |
| R-018 | HIGH | DOCUMENTATION | Notification Engine | Core daily-use feature with complex scheduling — zero documentation | ⚠️ TECH-DEBT | Document notification lifecycle, action rules, recurrence logic |
| R-019 | HIGH | MIGRATE | Local filesystem | File storage uses local filesystem paths — must move to S3/cloud storage before Go migration | 🚩 MIGRATE | Plan S3 migration for all file uploads |
| R-020 | HIGH | ARCH | Multiple files | Per-request createObject() calls for services outside Application.cfc — should be application-scoped singletons | ⚠️ ARCH | Cache service instances in application scope |

## MEDIUM Findings

| ID | Severity | Category | File/Area | Finding | Tag | Recommended Action |
|---|---|---|---|---|---|---|
| R-021 | MEDIUM | CODE-QUALITY | 6+ files | Magic numbers for audstepid (1-5, 999), pgid, audcatid, actionLinkID | ⚠️ TECH-DEBT | Extract to named constants CFC |
| R-022 | MEDIUM | CODE-QUALITY | Multiple services | Mixed tag/CFScript within same function bodies | ⚠️ TECH-DEBT | Standardize to CFScript on next touch |
| R-023 | MEDIUM | PERFORMANCE | Multiple queries | Missing indexes suspected on WHERE/JOIN/ORDER BY columns | ⚠️ MYSQL | Audit indexes against actual query patterns |
| R-024 | MEDIUM | PERFORMANCE | Various | Cached queries potentially returning user-specific data to wrong user | ⚠️ TECH-DEBT | Review all cachedwithin usage for user-safety |
| R-025 | MEDIUM | ARCH | Multiple CFCs | Unscoped variables in CFC function bodies — thread-safety risk in cached components | ⚠️ TECH-DEBT | Add var/local scope to all function variables |
| R-026 | MEDIUM | ARCH | Multiple locations | Empty cfcatch blocks — swallowed exceptions causing silent failures | ⚠️ TECH-DEBT | Add logging to all catch blocks |
| R-027 | MEDIUM | ARCH | No config mechanism | No environment-specific configuration switching (dev/staging/prod) | ⚠️ ARCH | Implement config service with environment detection |
| R-028 | MEDIUM | EMAIL | Multiple .cfm files | cfmail calls scattered in templates instead of centralized email service | ⚠️ TECH-DEBT | Consolidate all email sends to emailService.cfc |
| R-029 | MEDIUM | EMAIL | Multiple files | cfhttp calls with no timeout set — potential thread hangs | ⚠️ TECH-DEBT | Add timeout to all cfhttp calls |
| R-030 | MEDIUM | EMAIL | Some cfhttp calls | No error handling on non-200 responses — silent failure on API outage | ⚠️ TECH-DEBT | Add response status checking and logging |
| R-031 | MEDIUM | DATABASE | 2 tables | Typo in table names: `audessences_audtion_xref`, `audageranges_audtion_xref` (should be "audition") | ⚠️ MYSQL | Plan rename migration (requires coordinated code + schema change) |
| R-032 | MEDIUM | DATABASE | Multiple tables | Tables missing created_at/updated_at timestamp columns | ⚠️ MYSQL | Add timestamp columns in batched migration |
| R-033 | MEDIUM | DATABASE | Multiple tables | Tables missing soft-delete columns — hard deletes only | ⚠️ MYSQL | Review deletion patterns; add is_deleted where needed |
| R-034 | MEDIUM | DATABASE | Views + _tbl pattern | Core tables use VIEW over _tbl pattern (contactdetails, contactitems, taousers, events, etc.) — DDL must target _tbl base tables | ⚠️ MYSQL | Document view/base table pattern; verify all DDL targets _tbl |
| R-035 | MEDIUM | MIGRATE | Session variables | Large session variable surface — needs JWT payload design before Go migration | 🚩 MIGRATE | Complete session inventory → JWT field mapping |
| R-036 | MEDIUM | MIGRATE | Stored procedures/views | Database stored procedures and views need Go equivalents | 🚩 MIGRATE | Inventory all procs/views; plan Go repository equivalents |
| R-037 | MEDIUM | DEAD-CODE | ContactImportService.cfc, ContactImportV2Service.cfc | V1 and V2 import services likely obsoleted by V3 | 💀 DEAD | Verify V3 is fully deployed; remove V1/V2 |
| R-038 | MEDIUM | DEAD-CODE | 283 /qry files | Files with zero static callers — may be loaded via dynamic pgload.cfm | ⚠️ TECH-DEBT | Query pages table to confirm usage before deleting |
| R-039 | MEDIUM | NAMING | 293 service functions | Naming convention violations — banned verbs (fetch, load, process), vague names (getData, getAll) | ⚠️ TECH-DEBT | Rename on next touch per naming standard |

## LOW Findings

| ID | Severity | Category | File/Area | Finding | Tag | Recommended Action |
|---|---|---|---|---|---|---|
| R-040 | LOW | CODE-QUALITY | Page-level templates | cfset without explicit scope prefix — pollutes variables scope | ⚠️ TECH-DEBT | Prefix with local./variables. on next touch |
| R-041 | LOW | CODE-QUALITY | Multiple templates | Duplicated validation logic across multiple form handlers | 🔁 MERGE | Move to service layer validators |
| R-042 | LOW | DOCUMENTATION | 155 of 163 .cfm files | Templates with zero inline comments | ⚠️ TECH-DEBT | Low priority — add comments on complex logic only |
| R-043 | LOW | DOCUMENTATION | 136 of 142 JS files | JavaScript files with zero JSDoc annotations | ⚠️ TECH-DEBT | Add JSDoc to AJAX handlers on next touch |
| R-044 | LOW | DOCUMENTATION | Project root | No CHANGELOG.md, CONTRIBUTING.md, or .env.example | ⚠️ TECH-DEBT | Create as part of onboarding guide effort |
| R-045 | LOW | DEAD-CODE | headshots_sel_unused.cfm, materials_sel_unused.cfm | Files explicitly marked _unused in name | 💀 DEAD | Safe to delete immediately |
| R-046 | LOW | DATABASE | Some columns | Non-utf8mb4 columns may exist (cannot verify without live DB) | ⚠️ MYSQL | Run character set audit query against live database |
| R-047 | LOW | PERFORMANCE | No instrumentation | Zero performance instrumentation (no getTickCount() timing) — cannot identify slow operations | ⚠️ TECH-DEBT | Add timing to critical paths |
| R-048 | LOW | ARCH | /sched directory | Multiple Application.cfc backup copies (Applicationbackup.cfc, Applicationxx.cfc, Application_back.cfc, Application_last.cfc) | 💀 DEAD | Archive or delete backup copies |

## INFO Findings

| ID | Severity | Category | File/Area | Finding | Tag | Recommended Action |
|---|---|---|---|---|---|---|
| R-049 | INFO | INVENTORY | /services/ | 138 service CFCs with 1,159 total functions | INFO | Baseline for tracking |
| R-050 | INFO | INVENTORY | /include/qry/ | 1,267 qry files (967 page-specific, 300 shared) | INFO | Target: reduce to ~175 repository methods |
| R-051 | INFO | INVENTORY | /app/ | 131 module directories, 777 template files | INFO | Baseline for tracking |
| R-052 | INFO | INVENTORY | Database | 80+ tables referenced in code across core business and audition modules | INFO | Schema reference needed |
| R-053 | INFO | MIGRATE | 8 repository stubs | Generated in /audit-output/stubs/ with real table/column names | INFO | Use as foundation for /qry elimination |
| R-054 | INFO | DOCUMENTATION | docs/ | 56 documentation files, heavily weighted toward contact import (17 of 56) | INFO | Expand to other modules |

---

## Risk Distribution Summary

| Severity | Count |
|---|---|
| CRITICAL | 6 |
| HIGH | 14 |
| MEDIUM | 19 |
| LOW | 9 |
| INFO | 6 |
| **TOTAL** | **54** |

| Category | Count |
|---|---|
| SECURITY | 11 |
| ARCHITECTURE | 8 |
| DATABASE/MYSQL | 6 |
| PERFORMANCE | 4 |
| CODE-QUALITY | 4 |
| TECH-DEBT (mixed) | 5 |
| MIGRATE | 5 |
| DOCUMENTATION | 4 |
| DEAD-CODE | 4 |
| EMAIL/INTEGRATIONS | 3 |
| OBSERVABILITY | 2 |
| NAMING | 1 |
| INVENTORY (info) | 5 |

---

## Immediate Action Items (next 2 weeks)

1. **R-002**: Implement CSRF framework — 94 unprotected forms is the single highest-volume vulnerability
2. **R-001**: Parameterize remaining 46 SQL injection vectors (recent commit ce57de13 addressed 68 files; continue that work)
3. **R-003**: Add session cookie security flags (1-line fix)
4. **R-004**: Remove hardcoded credentials (move to environment)
5. **R-009**: Add sessionInvalidate() to login flow
6. **R-016**: Ensure error handler doesn't expose stack traces

## Short-term (next 1-2 months)

7. **R-005/R-006**: Begin /qry elimination — start with most-duplicated patterns (addNotification has 11 copies)
8. **R-012/R-013/R-014**: Merge duplicate service CFCs
9. **R-015**: Implement logging service
10. **R-020**: Cache service instances in application scope
