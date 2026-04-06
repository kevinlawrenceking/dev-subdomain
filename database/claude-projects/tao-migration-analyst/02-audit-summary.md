# TAO Full Codebase Maintenance Audit — Summary

**Generated:** 2026-03-16
**Branch:** dev (commit ce57de13)
**Auditor:** Claude Opus 4.6 (automated)

---

## Summary Stats Table

| Category | Count |
|---|---|
| **Total service CFCs** | 138 |
| **Total service functions** | 1,159 |
| **Dead service functions** | ~50+ (pending dynamic include trace) |
| **Total /qry files** | 1,267 |
| **Page-specific /qry copies** | 967 (76%) |
| **Shared /qry files** | 300 |
| **Dead /qry files (confirmed)** | 283 (zero static callers — some may be dynamic) |
| **/qry files with SQL injection risk** | 46 vectors across codebase |
| **Naming violations** | 293 functions flagged |
| **N+1 query patterns** | 14 detected |
| **XSS vectors** | 20 |
| **CSRF unprotected forms** | 94 (100% — zero protected) |
| **Hardcoded credentials** | 3 in app code |
| **Tables referenced in code** | 80+ |
| **Tables missing timestamps** | Multiple (pending live DB audit) |
| **Stored procedures (need Go equivalent)** | Pending live DB audit |
| **Functions with no logging** | Majority (~90%+) |
| **cfhttp calls with no timeout** | Multiple found |
| **cfmail calls outside email service** | Multiple in templates |
| **Total .cfm templates** | 777 |
| **App module directories** | 131 |
| **Documentation files** | 56 |
| **Repository stubs generated** | 8 (45 methods) |
| **Risk register entries** | 54 |

---

## Audit Output Files

| File | Phase | Size | Status |
|---|---|---|---|
| `00-summary.md` | 15 | — | This file |
| `01-security.md` | 4 | 19KB | ✅ Complete — 46 SQLi, 20 XSS, 94 CSRF, 8 upload, 3 credential issues |
| `02-architecture.md` | 5 | 24KB | ✅ Complete — Application.cfc analysis, service instantiation, scope leaks |
| `03-performance.md` | 6 | 15KB | ✅ Complete — N+1 patterns, caching audit, missing indexes |
| `04-code-quality.md` | 7 | 17KB | ✅ Complete — Magic numbers, tag/script mix, validation gaps |
| `05-email-integrations.md` | 8 | 40KB | ✅ Complete — cfmail and cfhttp audit with findings |
| `06-database.md` | 9 | 36KB | ✅ Complete — 80+ tables mapped, FK analysis, transaction gaps |
| `07-observability.md` | 10 | 21KB | ✅ Complete — Logging inventory, error handling, instrumentation |
| `08-documentation-gaps.md` | — | 8KB | ✅ Complete — 8 undocumented modules, 155 uncommented templates |
| `09-migration-prep.md` | 14 | 32KB | ✅ Complete — Session vars, API surface, file storage, REST candidates |
| `10-dead-code.md` | 1+3 | 193KB | ✅ Complete — Full function inventory, /qry inventory, template inventory |
| `11-naming-violations.md` | 1 | 22KB | ✅ Complete — 293 naming standard violations |
| `12-crud-overlap.md` | 11 | 11KB | ✅ Complete — Entity CRUD matrix, duplication analysis |
| `13-qry-elimination-plan.md` | 12 | 17KB | ✅ Complete — Disposition for all /qry files (A/B/C/D) |
| `14-repository-stubs.md` | 13 | 4KB | ✅ Complete — 8 repositories documented + stubs generated |
| `15-full-risk-register.md` | 15 | — | ✅ Complete — 54 findings (6 CRIT, 14 HIGH, 19 MED, 9 LOW, 6 INFO) |
| `call-graph-raw.md` | 2 | 216KB | ✅ Complete — Full caller analysis |
| `stubs/` | 13 | 8 files | ✅ Complete — ContactRepository, NotificationRepository, EventRepository, SystemRepository, SystemUserRepository, ActionUserRepository, NoteRepository, UserRepository |

**Total audit output: ~680KB across 17 files + 8 CFC stubs**

---

## Critical Risk Profile

```
CRITICAL:  ██████ 6 findings
HIGH:      ██████████████ 14 findings
MEDIUM:    ███████████████████ 19 findings
LOW:       █████████ 9 findings
INFO:      ██████ 6 findings
```

### Top 5 Immediate Priorities

1. **CSRF: 94 unprotected forms** — Every form POST in the application is vulnerable. Implement token framework.
2. **SQL Injection: 46 vectors** — Recent hardening (commit ce57de13) addressed 68 files; 46 vectors remain.
3. **Session Security: Missing flags** — Add httponly/secure cookie flags and sessionInvalidate() on login.
4. **Hardcoded Credentials: 3 instances** — Move to server environment configuration.
5. **/qry Explosion: 1,267 files** — 967 page-specific duplicates create maintenance burden and hide bugs.

---

## Architecture Health Assessment

### Strengths
- ✅ Service layer exists (138 CFCs with 1,159 functions) — good foundation for separation of concerns
- ✅ Most services have `hint` attributes (95% coverage)
- ✅ Database migration files with rollbacks exist (`database/migrations/`)
- ✅ Recent security hardening effort (commit ce57de13) addressed 68 files
- ✅ Contact Import v3 is well-documented (17 docs) and follows staged pattern
- ✅ Active development with clear module separation in /app/

### Weaknesses
- ❌ 1,267 /qry files — massive SQL duplication via scope-leaking cfinclude pattern
- ❌ Zero CSRF protection across entire application
- ❌ Dynamic include system (pgload.cfm) makes static analysis unreliable
- ❌ Duplicate services (Notification/Notifications, Contact/ContactConsolidated, Genre/GenreStandardized)
- ❌ Minimal logging — errors and slow queries are invisible
- ❌ No automated tests
- ❌ No environment configuration management

### Migration Readiness
- 🚩 Session variable inventory needed for JWT design
- 🚩 Local file storage must move to cloud before Go migration
- 🚩 /qry elimination plan provides path to repository pattern (prerequisite for Go repos)
- 🚩 80+ tables need schema documentation / ERD
- ✅ 8 repository stubs generated as starting templates
- ✅ API surface mapping started in migration prep document

---

## Verification Checklist

- [x] All 15+ output files written
- [x] All /qry files have disposition (A/B/C/D) or are marked dead in Phase 12
- [x] All service functions inventoried in Phase 1
- [x] Repository stubs generated in /audit-output/stubs/ (8 files)
- [x] Risk register has entries across all finding categories (54 total)
- [x] Summary stats table populated from actual findings
- [x] Call graph analysis captured (216KB raw data)
- [x] Naming violations catalogued (293 functions)
- [x] CRUD overlap matrix built for core entities
- [x] Documentation gaps identified (8 undocumented modules)
