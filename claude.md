# Claude Project Brief — The Actors Office (TAO)

## Purpose
The Actors Office (TAO) is a ColdFusion + MSSQL web application for managing the business side of an actor’s career.
Claude Code assists with code cleanup, modernization, and migration toward an API-driven architecture.

## Stack
- ColdFusion (Adobe CF2021)
- MSSQL database
- Client-side: HTML, JS, CSS
- Services directory: `/app/services`
- Fetch includes (legacy): `/include/qry`
- Current environment:
  - Production DSN: `abo`
  - Dev DSN: `abod`
  - Datasource variable: `application.datasource`

## Ongoing Work
**Project: Service Cleanup and API Prep**

### Goals
1. Remove legacy `/include/qry/*.cfm` includes.
2. Consolidate business logic into `/app/services/*.cfc` with standardized CRUD methods.
3. Replace `<cfinclude>` calls with `application.services.<service>.<method>(args)`.
4. Add unit tests and CI linting.
5. Prepare for eventual REST API migration (likely Go backend + Flutter frontend).

### Active Scripts
Located in `/tools/cleanup`:
- `replace_includes.ps1` — replaces `<cfinclude>` calls using mappings in `qry_map.csv`.
- `find_orphans.ps1` — lists unused fetch includes.
- `qry_map.csv` — maps legacy include filenames to service method calls.
- Prompts in `/tools/cleanup/prompts/` define the step-by-step agent workflow.

### Current Known Mappings
- `add_197_3` → `auditionSubmitSiteUserService.createAuditionSubmitSiteUser`
- `eventtypes_user` → `eventTypesUserService.listEventTypesUser`
- `core` and `fetchUsers` → marked as `skip`

### Application.cfc Setup
The application registers all services under:
```cfml
application.services = {
  auditionSubmitSiteUserService = new services.AuditionSubmitSiteUserService()
  // add others as you consolidate
};
```
and exposes `application.datasource = this.datasource`.

---

## Claude Code Guidelines
When working inside this repo:

1. **Never add new files under `/include/qry`.**
2. **All SQL must use `queryExecute`** with parameterized arguments and `datasource: application.datasource`.
3. **Respect CRUD structure** in service CFCs:
   - `create<Resource>(data)`
   - `get<Resource>(id)`
   - `list<ResourcePlural>(filters)`
   - `update<Resource>(id, data)`
   - `delete<Resource>(id)`
4. Keep all edits small and self-contained (1 feature or 10 files per PR).
5. Always run the PowerShell cleanup scripts in dry-run mode before applying.
6. Update `tools/cleanup/qry_map.csv` as new includes are encountered.
7. When encountering unmapped includes like `core` or `fetchUsers`, label them `skip` until replaced manually.

---

## Long-Term Vision
- Replace all ColdFusion includes with service-based logic.
- Move to a RESTful API layer (Go or CFML-Lucee-based) and eventually connect via a Flutter client.
- Keep backward compatibility until all legacy pages are migrated.

---

## Contacts
**Maintainer:** Kevin King  
**Email:** kevinking7135@gmail.com  
**Primary environment:** Hostek VPS (ColdFusion 2021, MSSQL `abo` / `abod`)

---

### Revision
`claude.md` generated 2025-10-28
