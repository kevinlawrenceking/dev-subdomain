# TAO Deep Reference Index

Quick lookup for agents and skills that need deeper context than CLAUDE.md provides.
All paths relative to C:\Users\kevin\TAO\claude-projects\.

## By topic

### Security hardening
- tao-coldfusion-expert/05-security-findings.md -- 46 SQLi, 20 XSS, 94 CSRF with file paths and fix approaches
- tao-coldfusion-expert/10-risk-register.md -- 54 findings ranked CRITICAL/HIGH/MED/LOW

### Database schema
- tao-coldfusion-expert/09-database-schema.md -- all 150+ tables, usage context, FK analysis
- tao-coldfusion-expert/17-contact-data-model.md -- contactdetails, contactitems EAV, type/category map

### Relationship system
- tao-coldfusion-expert/03-relationship-system-architecture.md -- full workflow, state machine, table chain
- Use with: /tao-relationship skill, tao-cfml agent

### Service layer and refactoring
- tao-coldfusion-expert/11-service-migration-reference.md -- legacy numbered names to CRUD mapping
- tao-coldfusion-expert/08-code-quality.md -- magic numbers, validation gaps, tag/script mixing
- Use with: /cf-service, /cf-refactor skills

### Architecture and debugging
- tao-coldfusion-expert/06-architecture.md -- Application.cfc deep read, sub-apps, auth gates, scope leaks
- tao-coldfusion-expert/07-performance.md -- N+1 patterns, caching gaps, missing indexes
- tao-coldfusion-expert/14-observability.md -- logging inventory, instrumentation gaps
- Use with: /cf-debug, /cf-expert skills

### Query fragment cleanup
- tao-coldfusion-expert/15-qry-elimination-plan.md -- disposition for all 1,267 /include/qry/ files
- Use with: /cf-refactor skill

### Import system
- tao-coldfusion-expert/12-import-v3-workflow.md -- state machine, all AJAX endpoints, finalization
- Use with: /tao-import skill

### Full audit
- tao-coldfusion-expert/16-full-site-audit.md -- complete findings register with severity, file paths, effort
- tao-coldfusion-expert/04-audit-summary.md -- executive summary

### Go/Flutter migration
- tao-migration-analyst/05-migration-prep.md -- session-to-JWT, API surface map (75+ endpoints), file storage
- tao-migration-analyst/15-repository-stubs.md -- 8 Go repository stubs (45 methods)
- tao-migration-analyst/14-crud-overlap.md -- entity CRUD matrix
- tao-flutter-expert/02-api-surface-map.md -- complete API surface with proposed Go routes

## By skill/agent

| Skill or Agent | Primary reference docs |
|---------------|----------------------|
| /cf-debug | 06-architecture, 05-security-findings |
| /cf-query | 09-database-schema, 07-performance |
| /cf-refactor | 15-qry-elimination-plan, 08-code-quality, 11-service-migration-reference |
| /cf-service | 11-service-migration-reference, 06-architecture |
| /cf-expert | 06-architecture, 14-observability |
| /db-admin | 09-database-schema, 10-risk-register |
| /tao-relationship | 03-relationship-system-architecture, 10-risk-register |
| /tao-import | 12-import-v3-workflow, 17-contact-data-model |
| /tao-admin | 16-full-site-audit, 06-architecture |
| /tao-frontend | 06-architecture, 08-code-quality |
| tao-manager agent | 04-audit-summary, 10-risk-register |
| tao-gatekeeper agent | 05-security-findings, 10-risk-register |
| tao-cfml agent | 06-architecture, 03-relationship-system-architecture |
| tao-db agent | 09-database-schema, 07-performance |
