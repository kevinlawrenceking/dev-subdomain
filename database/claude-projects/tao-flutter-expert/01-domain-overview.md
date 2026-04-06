# The Actors Office (TAO) - CLAUDE.md

This repo is TAO. Use this file as the default operating guide for planning, coding, debugging, and database work.

## Purpose

TAO is a ColdFusion + MySQL web app that helps actors run the admin side of their careers: contacts, reminders, relationship workflows, scheduling, and project tracking. Users live inside contacts and notifications.

## Tech stack and environment

- Backend: ColdFusion (CFML)
- Database: **MySQL** (NOT SQL Server - verified January 2026)
  - Production schema: `actorsbusinessoffice`
  - Development schema: `new_development`
- ColdFusion datasource names: `abo` (production), `abod` (development)
  - Determined at runtime by hostname: `app` = prod, anything else = dev
  - Application name is env-specific (`TAO_PROD`, `TAO_DEV`, `TAO_UAT`) to isolate scopes
- Frontend: HTML, JS, CSS with heavy AJAX patterns
- AJAX endpoints typically under `/ajax/...`
- Mobile extension may exist later (Flutter), but do not assume it is part of the current task unless you see it in the repo.

## Core modules

### Contacts
Contacts are central. Contacts can link to notes, events, relationship systems, notifications, and custom metadata. Any change to contacts or contact importing must preserve integrity and downstream behavior.

### Relationship Systems
Relationship systems automate structured follow-up and maintenance.

Critical tables (treat as infrastructure):
- `fuactions` (master action templates)
- `actionusers` (per-user action copies and scheduling overrides)
- `fusystems` (system definitions)
- `fusystemusers` (per-contact per-user system enrollment/instances)
- `funotifications` (actionable reminders)

### Notification Engine
Notifications drive daily user activity.
- Reminders are surfaced when `notstartdate <= NOW()`.
- Completion typically schedules the next action, creates recurring items, or starts another system (example: maintenance after follow-up).

### Action lifecycle rules
Actions commonly include:
- Initial delay (`actionDaysNo`)
- Recurrence (`actionDaysRecurring`)
- Uniqueness rules (`isUnique`) to prevent repeats
- On user creation, `actionusers` is populated as a per-user override set

### Event system
Auditions and meetings are stored as events and can trigger follow-up and maintenance workflows. Events include casting info, notes, and appointment data.

## Reference documentation

Relationship workflow and data flow:
- `/mnt/data/TAO Relationship System_ Process & Data Flow Documentation.md`

Use it when a task touches systems, actions, scheduling, recurrence, or notification generation.

## Non-negotiables

- Do not guess. Inspect the repo code paths and the schema first.
- Do not change the meaning of existing fields or tables unless the task explicitly requires it and you have traced impacts.
- Do not ship a feature that can hard-crash on malformed input. Validate, isolate, and recover.
- Prefer incremental, reversible changes. For DB changes, include rollback scripts.
- Keep UI behavior consistent with TAO patterns: AJAX updates and modals over full page reloads.
- No emojis in code, comments, logs, commit messages, or UI strings used for logging.

## Standard workflow for any task

1. Recon
   - Find the entrypoint page(s) and `/ajax` endpoints.
   - Trace the call chain and write down the request flow.

2. Data impact
   - Identify tables touched, keys, constraints, and any dependent tables/pages.
   - Identify existing validation logic (forms, existing endpoints, constraints).

3. Plan
   - List implementation steps in order.
   - Call out risk points and performance concerns.
   - Define acceptance criteria and verification steps.

4. Implement
   - Keep changes scoped.
   - Parameterize all SQL.
   - Add targeted logging where silent failure is possible.

5. Verify
   - Provide a checklist of UI steps and SQL queries to confirm results.
   - Include edge cases.

## Coding standards

### CFML
- Use `cfqueryparam` for all user input. No string-concatenated SQL.
- Keep endpoints predictable: return JSON with `success`, `message`, and `data`.
- Keep functions small and readable. Prefer shared helpers over copy-paste logic.

### MySQL (CRITICAL - TAO uses MySQL, not SQL Server)

**Use MySQL syntax patterns:**
- `NOW()` for current datetime (NOT `GETDATE()`)
- `LIMIT n` at end of query (NOT `SELECT TOP n`)
- `AUTO_INCREMENT` for identity columns (NOT `IDENTITY(1,1)`)
- `information_schema` for metadata queries (NOT `sys.columns`)
- `INSERT IGNORE` or `ON DUPLICATE KEY UPDATE` for upserts (NOT `MERGE`)
- `DELIMITER //` for stored procedures (NOT `GO` batch separator)

**General MySQL rules:**
- Use transactions for multi-table writes.
- Design idempotency for any endpoint that can be double-submitted.
- Avoid schema changes that require long locks during business hours unless requested.
- Prefer set-based operations when safe, but do not sacrifice clarity or safety.
- Use `ENGINE=InnoDB` for tables requiring transactions and foreign keys.

### JavaScript and UI
- Prefer AJAX-driven filtering, paging, and modal editing.
- Show validation errors per field.
- Avoid page-wide blocking for single-row updates.

## Import and data ingestion rule (high impact)

When touching any importer (contacts or otherwise), use a two-phase pattern:

1) Stage
- Store the raw file and parsed rows in staging tables.
- Record per-field validation errors and warnings.
- Never write into production tables while parsing unreliable input.

2) Review and finalize
- Provide a review UI for problems and duplicates.
- Only finalized, user-approved rows get inserted into production tables.
- Finalize must be idempotent (double finalize must not double insert).

## Contact importer requirements pattern (use for the new importer)

- Accept CSV, XLS, XLSX, **VCF** (vCard from Apple/iCloud).
- Tolerate malformed values with row-level error capture.
- Provide a review grid:
  - Problems tab
  - Duplicates tab with candidate matches and reasons
  - Inline editors with correct widgets (date picker, select dropdown, text)
  - Bulk actions (ignore, approve, finalize)
- Finalize imports only approved rows and never double-inserts.
- Provide an import summary: total, ready, problem, dupes, imported.
- Support `relationship_system` field to enroll contacts in Target or Maintenance systems.
- File hash-based duplicate detection to prevent re-importing same file.

## Output requirements when you deliver work

- Always include file paths.
- Provide complete code blocks for changed functions/endpoints, not fragments.
- For DB changes, include:
  - Full CREATE/ALTER scripts
  - Rollback script
- Include a verification checklist:
  - UI steps
  - SQL queries (counts, specific rows)
  - Edge cases tested

## Current development priorities (use as tie-breakers)

- Improve notifications UI (AJAX toggles, modals)
- Strengthen relationship automation and reminders
- Standardize DB access patterns and validation
- Event-based triggers that feed workflows
- Contact importer replacement and dedupe workflows