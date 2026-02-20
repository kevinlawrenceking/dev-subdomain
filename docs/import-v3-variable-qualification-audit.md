# Contact Import V3 - Variable Qualification Audit

Generated: 2026-02-19

## Summary

Audit of all 12 files in the Contact Import V3 system for ColdFusion variable scope qualification. In ColdFusion, variables set with `<cfset varName = ...>` at page scope land in the `variables` scope by default. While technically defined behavior, unqualified names create collision risk with URL, form, session, and application scopes.

**Total findings: ~180 unqualified variables**
- HIGH: 10 (SQL interpolation, scope collision, uninitialized vars)
- MEDIUM: ~40 (core ID variables unqualified)
- LOW: ~130 (intermediate processing variables)

---

## Aggregate Risk Summary

| Risk | Count | Description |
|------|-------|-------------|
| HIGH | 10 | SQL interpolation in CFC (4, NOW FIXED), scope collision with common names like "action"/"intent" (2), uninitialized vars in cfcatch blocks (2), variable shadowing (1), result attribute scope leak (1) |
| MEDIUM | ~40 | Core ID variables (userid, jobId, rowId) unqualified, critical data variables unqualified |
| LOW | ~130 | Intermediate processing variables, counters, temp vars |

## Most Critical Findings (Priority Fix Order)

### 1. SQL String Interpolation in ContactImportV3Service.cfc [FIXED]

Lines 2062, 2116, 2793, 2807 used `#arrayToList(...)#` inside SQL strings instead of cfqueryparam with `list: true`. All four instances have been fixed to use parameterized queries.

### 2. Bare `action` Variable in row_action.cfm (Lines 179-207)

The variable name `action` collides with `form.action` which is cfparam'd on the same page. ColdFusion scope search order means a bare `action` read could resolve to `form.action` instead of the intended `variables.action`.

**Recommendation:** Rename to `variables.rowAction` or qualify as `variables.action`.

### 3. Bare `intent` Variable in recompute.cfm (Line 289)

Similar collision risk with form/url scopes. The variable `intent` is a common field name that could appear in form or URL scope.

**Recommendation:** Qualify as `variables.intent` or rename to `variables.colIntent`.

### 4. Uninitialized Variable References in cfcatch Blocks

- upload.cfm line 209: cfcatch references `userid` in cflog, but if exception occurs before userid is assigned, cflog itself throws
- parse.cfm line 492: Same pattern with `userid` and `jobId`
- columns.cfm line 475: Same pattern

**Recommendation:** These variables ARE initialized at the top of each file (e.g., `jobId = 0`, `userid = 0`), so the cfcatch risk is mitigated. However, qualifying as `variables.userid` and `variables.jobId` makes the intent explicit.

### 5. `result:` Attribute in CFC queryExecute Options

The `result: "qResult"` pattern in `queryExecute()` writes to `variables` scope, not `local`/`var` scope. This is a known ColdFusion gotcha. For single-threaded request processing the risk is minimal, but technically incorrect.

**Recommendation:** Use `result: "local.qResult"` for strict correctness.

---

## Per-File Detailed Findings

### File 1: upload.cfm

| Line | Current | Should Be | Risk |
|------|---------|-----------|------|
| 30 | `userid = session.userid` | `variables.userid = session.userid` | LOW |
| 71 | `uploadedPath = uploadDir & ...` | `variables.uploadedPath = variables.uploadDir & ...` | MEDIUM |
| 73 | `fileInfo = getFileInfo(uploadedPath)` | `variables.fileInfo = getFileInfo(variables.uploadedPath)` | MEDIUM |
| 178 | `newJobId = qResult.generatedKey` | `variables.newJobId = variables.qResult.generatedKey` | MEDIUM |
| 209 | cfcatch `userid=#userid#` | `#variables.userid#` | HIGH |

**Totals: 1 HIGH, 2 MEDIUM, ~22 LOW**

### File 2: parse.cfm

| Line | Current | Should Be | Risk |
|------|---------|-----------|------|
| 76 | `jobId = 0` | `variables.jobId = 0` | MEDIUM |
| 125 | `job = jobResult.data.job` | `variables.job = jobResult.data.job` | MEDIUM |
| 206 | `filePath = job.stored_file_path` | `variables.filePath = variables.job.stored_file_path` | MEDIUM |
| 492 | cfcatch `userid=#userid# job_id=#jobId#` | `#variables.userid# #variables.jobId#` | HIGH |

**Totals: 1 HIGH, 3 MEDIUM, ~31 LOW**

### File 3: columns.cfm

| Line | Current | Should Be | Risk |
|------|---------|-----------|------|
| 55 | `jobId = val(url.job_id)` | `variables.jobId = val(url.job_id)` | MEDIUM |
| 75 | `job = jobResult.data.job` | `variables.job = jobResult.data.job` | MEDIUM |
| 215 | `columnId = val(form.column_id)` | `variables.columnId = val(form.column_id)` | MEDIUM |
| 475 | cfcatch `userid=#userid# job_id=#jobId#` | `#variables.userid# #variables.jobId#` | HIGH |

**Totals: 1 HIGH, 3 MEDIUM, ~26 LOW**

### File 4: recompute.cfm (WORST QUALIFIED FILE)

| Line | Current | Should Be | Risk |
|------|---------|-----------|------|
| 289 | `intent` (bare) | `variables.intent` | HIGH |
| 398 | `rowId = qRows.row_id` | `variables.rowId = qRows.row_id` | MEDIUM |
| 400 | `userAction` (bare) | `variables.userAction` | HIGH |
| 432-436 | `rowData`, `rowErrors`, `rowWarnings` | All `variables.*` | MEDIUM |
| 606 | `rowStatus = "ready"` | `variables.rowStatus = "ready"` | MEDIUM |
| 618 | `dupeRowData = {}` | `variables.dupeRowData = {}` | HIGH |

**Totals: 3 HIGH, 6 MEDIUM, ~46 LOW**

### File 5: rows.cfm (BEST QUALIFIED - MODEL FILE)

Nearly 100% qualified with `variables.*` prefix. Only `debug` and `startTick` are unqualified.

**Totals: 0 HIGH, 0 MEDIUM, 2 LOW**

### File 6: row.cfm

| Line | Current | Should Be | Risk |
|------|---------|-----------|------|
| 41-43 | `jobId = 0`, `rowId = 0`, `userid = 0` | `variables.jobId = 0`, etc. | MEDIUM |
| 99 | `job = jobResult.data.job` | `variables.job = jobResult.data.job` | MEDIUM |

**Totals: 0 HIGH, 6 MEDIUM, ~10 LOW**

### File 7: row_action.cfm

| Line | Current | Should Be | Risk |
|------|---------|-----------|------|
| 177-192 | `action` (bare) | `variables.action` | HIGH |
| 254 | `job = jobResult.data.job` | `variables.job = jobResult.data.job` | MEDIUM |
| 316 | cfcatch `userid=#userid# job_id=#jobId#` | `#variables.userid# #variables.jobId#` | MEDIUM |

**Totals: 1 HIGH, 6 MEDIUM, ~18 LOW**

### File 8: fact_update.cfm

| Line | Current | Should Be | Risk |
|------|---------|-----------|------|
| 46-48 | `jobId`, `rowId`, `userid` unqualified | `variables.*` | MEDIUM |
| 216 | `job = jobResult.data.job` | `variables.job = jobResult.data.job` | MEDIUM |
| 264 | cfcatch `userid=#userid# job_id=#jobId# row_id=#rowId#` | `variables.*` | MEDIUM |

**Totals: 0 HIGH, 8 MEDIUM, ~14 LOW**

### File 9: finalize.cfm

| Line | Current | Should Be | Risk |
|------|---------|-----------|------|
| 44-45 | `jobId = 0`, `userid = 0` | `variables.*` | MEDIUM |
| 196 | `job = jobResult.data.job` | `variables.job = jobResult.data.job` | MEDIUM |
| 247 | cfcatch `userid=#userid# job_id=#jobId#` | `variables.*` | MEDIUM |

**Totals: 0 HIGH, 6 MEDIUM, ~14 LOW**

### File 10: status.cfm

| Line | Current | Should Be | Risk |
|------|---------|-----------|------|
| 39-40 | `jobId = 0`, `userid = 0` | `variables.*` | MEDIUM |
| 132 | `newStatus = ""` | `variables.newStatus = ""` | MEDIUM |
| 190 | cfcatch `userid=#userid# job_id=#jobId#` | `variables.*` | MEDIUM |

**Totals: 0 HIGH, 6 MEDIUM, ~9 LOW**

### File 11: import-contacts-v3.cfm

UI template. All `session.userid` and `url.job_id` references are properly qualified. Unqualified vars are low-risk display variables.

**Totals: 0 HIGH, 0 MEDIUM, ~8 LOW**

### File 12: ContactImportV3Service.cfc

CFC with different scoping rules. Uses `var` and `arguments.*` consistently. Main concerns are SQL interpolation (FIXED) and the `result:` attribute pattern.

**Totals: 4 HIGH (SQL interpolation - FIXED), rest OK**

---

## Files Ranked by Qualification Compliance (Best to Worst)

1. **rows.cfm** - Nearly 100% qualified. Model file.
2. **ContactImportV3Service.cfc** - Good `var` and `arguments.*` usage. SQL issues fixed.
3. **import-contacts-v3.cfm** - Session/URL references properly qualified.
4. **status.cfm** - Initializes key vars at top, but unqualified.
5. **finalize.cfm** - Same pattern as status.cfm.
6. **fact_update.cfm** - Similar.
7. **row.cfm** - Similar, inconsistent with rows.cfm pattern.
8. **row_action.cfm** - HIGH-risk `action` collision.
9. **columns.cfm** - Many unqualified vars, cfcatch risk.
10. **upload.cfm** - Many unqualified vars, cfcatch risk.
11. **parse.cfm** - Highest count of unqualified vars.
12. **recompute.cfm** - Highest total count plus HIGH-risk `intent` collision and naming confusion.

---

## Remediation Approach

### Phase 1: HIGH-risk fixes (scope collisions and cfcatch safety)

1. Qualify `action` in row_action.cfm as `variables.action`
2. Qualify `intent` and `userAction` in recompute.cfm as `variables.*`
3. Ensure all cfcatch blocks reference `variables.userid` and `variables.jobId`
4. Rename or qualify `dupeRowData` vs `rowDupeData` in recompute.cfm

### Phase 2: MEDIUM-risk fixes (core ID variables)

Apply `variables.*` prefix to `userid`, `jobId`, `rowId`, `job`, and `v3Service` across all endpoint files. Follow the rows.cfm pattern.

### Phase 3: LOW-risk fixes (everything else)

Apply `variables.*` prefix to all remaining page-scope variables. This is safe and improves consistency but is lowest priority.

---

## ColdFusion Scope Search Order Reference

When reading an unqualified variable, ColdFusion searches these scopes in order:
1. Local (function scope, `var` keyword)
2. Arguments
3. Thread local
4. Query (inside cfquery/cfloop)
5. Thread
6. Variables (page scope)
7. CGI
8. Cffile
9. URL
10. Form
11. Cookie
12. Client

The risk is that `form.action` or `url.intent` could be found before `variables.action` or `variables.intent` in steps 9-10 before step 6 is reached. Explicit qualification eliminates this ambiguity.
