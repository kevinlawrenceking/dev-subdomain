# Diagnostics Note — CI guard drift on branch `dev` (2026-07-06)

**Binding:** TAO / `dev-subdomain` / branch `dev` · **Author:** CC · **Method:** Evidence-First
(ran `.github/workflows/ci.yml`'s guards locally). Surfaced while reconning the deploy path for the
R-4 push decision. No code changed by this note.

## Finding

`ci.yml` fires on `push` to `main`/`develop` and on `pull_request`, running two hard guards
(`Write-Error` → step fails). Run locally against `./app` at HEAD (`b5aef977`):

| Guard | Rule | Count | Verdict |
|-------|------|-------|---------|
| 1 | no `include .../qry/*.cfm` under `./app` | **3** | FAIL |
| 2 | no `<cfquery` / `queryExecute(` outside `/services` under `./app` | **68** | FAIL |

Guard-1 hits: `app/Application.cfc:357`, `app/Application.cfc:456`, `app/assets/js/eventtypes_user.cfm:2`.
Guard-2: 68 raw-SQL sites across `app/admin-*`, `app/Application.cfc`, etc. (admin pages dominate).

## Interpretation (dominant path, not an edge case)

Raw `cfquery` in `/app` pages is **widespread** (68 sites) — the "SQL only in `/services`" guard is
**aspirational, not met**. Consequences:
- Any push/PR of `dev` content to `develop`/`main` **fails CI today** on 71 pre-existing violations.
- Our branch is `dev`; `ci.yml` watches `main`/`develop`, so a **`git push origin dev` does NOT run
  CI** and is unaffected. The guards only bite at promotion.

## Scope impact

- **R-4 / WO-DUPES-R1 work is guard-neutral.** All changes are in `/services` (outside the `./app`
  guard scope); zero new violations introduced. The 71 are entirely pre-existing.
- **Promotion path is blocked** until either (a) the 71 violations are remediated (large qry-elimination
  effort — see `15-qry-elimination-plan.md`), or (b) the guards are scoped/relaxed, or (c) the team
  promotes by a path that bypasses these triggers. Decision is Kevin's; recorded here so it is not
  rediscovered as a surprise at merge time.

## Recommendation
Do not gate WO-DUPES-R1 on this. Track the 71 as a separate promotion-readiness workstream. When it is
picked up, the CI guard commands here are the exact acceptance oracle (drive both counts to 0).
