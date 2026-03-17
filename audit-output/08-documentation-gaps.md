# Phase 8 — Documentation Gaps Audit

Generated: 2026-03-16

---

## Current Documentation Inventory

### Root-Level Docs
| File | Purpose | Status |
|---|---|---|
| `README.md` | Project overview | ⚠️ Exists — needs review for accuracy |
| `CLAUDE.md` | AI assistant operating guide | ✅ Well-maintained |
| `TAO-PROJECT-PLAN.md` | Project planning | ✅ Exists |
| `TAO-FULL-SITE-AUDIT-2026-03-15.md` | Previous audit | ✅ Exists |
| `AUDITIONS_MODULE_CHANGES.md` | Audition module changelog | ✅ Exists |
| `CALENDAR_TIMESLOT_FIX.md` | Calendar fix documentation | ✅ Exists |
| `CONTACT_DUPLICATE_MANAGEMENT.md` | Duplicate contact handling | ✅ Exists |
| `GOOGLE_OAUTH_VERIFICATION.md` | OAuth setup docs | ✅ Exists |
| `QUICK_FIX_README.md` | Quick fix guide | ✅ Exists |
| `CHANGELOG.md` | Release changelog | ❌ **MISSING** — no changelog exists |
| `CONTRIBUTING.md` | Contributor guidelines | ❌ **MISSING** |
| `.env.example` | Environment variable template | ❌ **MISSING** — no env example for new developers |

### /docs Directory (56 files)
Well-documented areas:
- ✅ Contact Import v3 — **17 docs** including API, process maps, test data, proof bundles
- ✅ Contact Import v2 — 4 docs
- ✅ Contacts module — 4 table/column mapping docs
- ✅ Relationship System — health report
- ✅ Audition Import — error fix, UI improvements, module review

Undocumented areas:
- ❌ **Notification Engine** — zero docs in /docs despite being core daily-use feature
- ❌ **Event/Appointment System** — zero docs
- ❌ **User Management** — zero docs (admin-users has DESIGN_PLAN.md and PROOF_BUNDLE.md in app/)
- ❌ **Reports Module** — zero docs
- ❌ **Sharing/Collaboration** — zero docs
- ❌ **Billing/IPN** — zero docs despite ipn-handler.cfm and ipn-cancelled.cfm at root
- ❌ **Scheduled Tasks** — zero docs for /sched/ directory
- ❌ **Tags System** — zero docs
- ❌ **Export System** — zero docs
- ❌ **Panel/Dashboard System** — zero docs

### /database Directory
| File | Status |
|---|---|
| `migrations/` (18 migration + rollback files) | ✅ Good — versioned with rollbacks |
| `OPTIMIZATION_SUMMARY.md` | ✅ Exists |
| `QUICK_DEPLOY.md` | ✅ Exists |
| `PRODUCTION_DEPLOY.sql` | ✅ Exists |
| Full schema reference | ❌ **MISSING** — no complete ERD or schema doc |
| Migration runner/process | ❌ **MISSING** — no documented migration procedure |

---

## Code Documentation Coverage

### Service CFC Hints
- **130 / 137** service CFCs have `hint=` attributes (95% coverage) ✅
- 7 CFCs missing hints — ⚠️ minor gap

### Template Comments (.cfm)
- **8 / 163** .cfm files in `/app/` have inline comments `<!--- ... --->` (5% coverage) ❌
- **155 templates with zero documentation** — nearly all templates undocumented

### JavaScript JSDoc
- **6 / 142** JS files have JSDoc annotations (4% coverage) ❌
- **136 JS files with zero JSDoc** — AJAX handlers, form validation, UI logic all undocumented

### API Documentation
- **1** API doc exists: `docs/contact-import-v3/API.md`
- ❌ **No API docs for any other AJAX endpoints** — the app has extensive AJAX surface
- ❌ **No OpenAPI/Swagger spec**
- ❌ **No endpoint catalog** for `app/ajax/` handlers

---

## Critical Documentation Gaps

### 1. ❌ No Onboarding / Setup Guide
- No `.env.example` or `env.template`
- No step-by-step local development setup
- No ColdFusion server configuration guide
- No MySQL database setup instructions
- Developer must reverse-engineer setup from Application.cfc and config files

### 2. ❌ No Architecture Overview
- No high-level architecture diagram
- No data flow documentation for core workflows
- No module dependency map
- CLAUDE.md has module descriptions but no visual architecture

### 3. ❌ No AJAX Endpoint Catalog
- 131 app module directories, many with AJAX handlers
- `/app/ajax/` and `/ajax/` directories with endpoints
- No single reference of available endpoints, parameters, or response formats
- New developers must grep to discover available operations

### 4. ❌ No Test Documentation
- `/tests/` directory exists but contains only fixture files and 1 SQL test
- **Zero automated test files** (no CFUnit, TestBox, or any CF test framework)
- No test strategy document
- No regression test checklist

### 5. ❌ No Deployment Documentation
- `deploy_uat.bat` and `deploy_uat_local.bat` exist but no docs explaining the process
- `database/QUICK_DEPLOY.md` and `PRODUCTION_DEPLOY.sql` exist for DB only
- No CI/CD pipeline documentation
- No rollback procedure for application deployments

### 6. ❌ No Database Schema Reference
- Migration files exist but no consolidated schema map
- No ERD (Entity Relationship Diagram)
- `docs/contacts/` has table maps for contacts — nothing for other entities
- No data dictionary documenting column purposes and valid values

### 7. ❌ No Notification Engine Documentation
- Core user-facing feature with complex scheduling logic
- Touches `funotifications`, `fuactions`, `actionusers`, `fusystems`, `fusystemusers`
- Action lifecycle rules (delays, recurrence, uniqueness) only in CLAUDE.md
- No flowchart or state diagram for notification lifecycle

### 8. ❌ No Security Documentation
- No documented authentication flow
- No session management documentation
- No authorization/role model documentation
- No security incident response procedure

### 9. ❌ No Scheduled Task Documentation
- `/sched/` directory with multiple Application.cfc variants (backup, xx, _back, _last)
- No docs explaining what scheduled tasks run, frequency, or dependencies
- Multiple backup copies of Application.cfc suggest undocumented config iterations

### 10. ❌ No Error Handling / Troubleshooting Guide
- No documented common errors and resolutions
- No log file locations documented
- No monitoring/alerting setup guide

---

## Module Documentation Matrix

| Module | Code Exists | Docs Exist | Gap Level |
|---|---|---|---|
| Contacts | ✅ | ✅ (4 docs) | LOW |
| Contact Import v3 | ✅ | ✅ (17 docs) | NONE |
| Contact Import v2 | ✅ | ✅ (4 docs) | LOW |
| Auditions | ✅ | ✅ (3 docs) | MEDIUM — no data model docs |
| Audition Import | ✅ | ✅ (2 docs) | LOW |
| Relationship Systems | ✅ | ⚠️ (1 health report) | HIGH — core feature, minimal docs |
| Notifications | ✅ | ❌ | **CRITICAL** — complex feature, zero docs |
| Events/Appointments | ✅ | ❌ | HIGH |
| User Management | ✅ | ⚠️ (design plan in app/) | MEDIUM |
| Reports | ✅ | ❌ | HIGH |
| Sharing | ✅ | ❌ | MEDIUM |
| Billing/IPN | ✅ | ❌ | HIGH — financial, needs docs |
| Scheduled Tasks | ✅ | ❌ | HIGH |
| Tags | ✅ | ❌ | LOW |
| Export | ✅ | ❌ | MEDIUM |
| Panels/Dashboard | ✅ | ❌ | MEDIUM |
| Calendar | ✅ | ⚠️ (1 fix doc) | MEDIUM |
| OAuth/Auth | ✅ | ⚠️ (1 Google doc) | HIGH — security-critical |

---

## Documentation Debt Summary

| Category | Count |
|---|---|
| Modules with zero documentation | 8 |
| Missing critical docs (onboarding, architecture, security) | 6 |
| Templates with zero comments (of 163) | 155 |
| JS files with zero JSDoc (of 142) | 136 |
| AJAX endpoints with no API docs | ~100+ |
| Service CFCs missing hints | 7 |
| Test files (automated) | 0 |

---

## Recommended Documentation Priority

1. **CRITICAL**: Notification Engine lifecycle documentation — most complex undocumented feature
2. **CRITICAL**: Developer onboarding guide with local setup steps
3. **HIGH**: AJAX endpoint catalog — needed for any API migration
4. **HIGH**: Database schema reference / ERD
5. **HIGH**: Relationship system deep documentation (beyond health report)
6. **HIGH**: Authentication and authorization flow documentation
7. **MEDIUM**: Scheduled task inventory and documentation
8. **MEDIUM**: Deployment procedure documentation
9. **LOW**: Inline code documentation in templates and JS
10. **LOW**: CHANGELOG.md to track releases
