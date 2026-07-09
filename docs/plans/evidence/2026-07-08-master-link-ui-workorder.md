# STATUS: SUPERSEDED 2026-07-09 by DIR-WO-2 Plan Lock v1. Not plan of record.

This recon/work-order is retained as history only. It is superseded by the architect
DIR-WO-2 deconfliction ruling (2026-07-09) and Plan Lock v1. The following points in
this document are OVERRULED:

- (a) Namespace is `/ajax/master/`, NOT `/ajax/contacts/master-*`.
- (b) `MasterDirectoryService` orchestrates; `ContactService` remains the SOLE
  `contactdetails` writer (this doc split writes across services).
- (c) PD-L2: link UPSERTS a `contactitems` Company row IN the same `cftransaction`
  (this doc said snapshot-only).
- (d) PD-L3: unlink CLEARS the managed fields where `_src='master'` and resets
  `_src='user'` (this doc kept the values and only flipped `_src`).
- (e) PD-L4: re-link refreshes `_src='master'` fields and fills blanks, and NEVER
  touches `_src='user'` fields.
- (f) PD-L5: existing contacts only; the create-form surface is deferred (this doc
  proposed a create-pane control).
- (g) Photo is EXCLUDED and there is ZERO DDL in this WO.

Build to Plan Lock v1, not to the text below.

---

# Master-Link UI — Recon & Work-Order (WO-2, draft)

**Binding:** TAO / `dev-subdomain` / branch `dev` · **Date:** 2026-07-08 · **Author:** CC (recon agent)
**Status:** RECON COMPLETE — build not started. Depends on WO-1 schema (LIVE in prod 2026-07-08).
**Feature:** On contact create/edit, search the master directory (`co_contacts`/`companies`) and
"link to master" — write the 3 pointer columns, and fill-blank-only snapshot fields with `_src='master'`.
Link state is DERIVED (`master_co_contact_id IS NOT NULL`); no status column.

## Entrypoints
- **Create form:** `include/remoteAddName.cfm` (posts to `include/remoteAddNameAdd.cfm` → `include/qry/add_211_1.cfm` → `ContactService.INScontactdetails_24070`). Company/Phone/Email are NOT on the create form today. It already wires two hand-rolled autocompletes (`#contactFullName`→`FullNameLookup.cfc`, `#companySearch`→`CompanyLookup.cfc` at `remoteAddName.cfm:185-186`) and a pre-submit dupe check to `ajax/contacts/check-duplicate.cfm` (`remoteAddName.cfm:91-132`) — the model to copy.
- **Detail/edit pane:** `app/contact/index.cfm` → `include/contact_info.cfm`. Company at `contact_info.cfm:687` (+ change handler `:1155`); phone/email `:607-611`. These are stored as **`contactitems_tbl` EAV rows** (Company uses `valueCompany`, not `valuetext`).
- Recommended surface: master-link control on BOTH the create pane and the detail pane.

## Service layer — `services/ContactService.cfc`
- `create(dataStruct)` (`:9-68`): allow-list-driven INSERT into the `contactdetails` VIEW. Allow-list does NOT yet include the hot fields, `_src`, or the 3 pointers — add them (INT pointers→`CF_SQL_INTEGER`; hot fields/`_src`→`CF_SQL_VARCHAR`; dates→`CF_SQL_TIMESTAMP`).
- `update(contactid, data)` (`:114-211`): additive `structKeyExists` block per column — clean minimal-diff insertion point; only writes keys the caller supplies (fill-blank decided in the endpoint).
- **`recordname` is VIRTUAL GENERATED — never write it.** It's wrongly in the allow-list (`:25`) and legacy `updatebad` (`:272`); leave that untouched here (tracked as WO-G). Use `update()`, not `update22`/`updatebad`.
- The view is INVOKER + updatable, so writes through `contactdetails` reach `contactdetails_tbl`.

## Autocomplete pattern to mirror
Use the **jQuery-UI `.autocomplete()`** style: `include/autocomplete.cfm:28-61` (source=`$.ajax` to a `.cfm`, `minLength:2`, maps `data.suggestions`→`{label,value,id}`), endpoint template `app/autolookup.cfm:4-48` (`serializeJSON({"suggestions":[...]})`). jQuery UI is loaded app-wide. Avoid the legacy `CompanyLookup.cfc` remote-CFC style that passes `dsn`/`userid` as URL params.

## Proposed endpoints (follow `ajax/contacts/` conventions; auth+CSRF central in `ajax/Application.cfc`)
1. **`GET ajax/contacts/master-search.cfm`** — typeahead read. Session-auth, GET (no CSRF). Returns `{success,data:{suggestions:[...]}}`.
2. **`POST ajax/contacts/master-link.cfm`** — writes 3 pointers + fill-blank `_src`. CSRF required (`X-CSRF-Token`, enforced `ajax/Application.cfc:81-127`). Verify `contactdetails.userid = request.userid` before writing. Idempotent.
3. **(optional) `POST ajax/contacts/master-unlink.cfm`** — null pointers, revert `_src` `'master'→'user'`.

## Proposed read query (parameterized)
```sql
SELECT cc.id AS master_co_contact_id, cc.fullname AS person_name, cc.jobtitle_type AS job_title,
       cc.coid AS master_coid, co.coName AS company_name,
       cl.colocid AS company_location_id, cl.address1 AS company_address
FROM co_contacts cc
LEFT JOIN companies    co ON co.coid = cc.coid
LEFT JOIN co_locations cl ON cl.coid = cc.coid          -- collapse to one office (MIN(colocid)); verify key
WHERE cc.fullname LIKE <cfqueryparam value="#trim(term)#%" cfsqltype="cf_sql_varchar">
ORDER BY cc.fullname
LIMIT <cfqueryparam value="#val(limit)#" cfsqltype="cf_sql_integer">   -- default 10
```
Prefix `LIKE 'term%'` (index-friendly). `co_locations` may be many-per-company → pick a primary/first office. **Verify `co_locations`→company key (`coid`) against live schema before finalizing** (Section 0b of the linkage preview captures it).

## Write path (fill-blank-only)
On link: set 3 pointers; `master_linked_date=NOW()` (first link), `master_last_sync=NOW()`; for each snapshot field (`contactCompany` from `coName`, optionally phone/email if master supplies) — if current value blank → write it + set `*_src='master'`; if user value present → leave it, keep `_src='user'`. Never write `recordname`. Wrap read-then-write in `<cftransaction>`. Extend `ContactService.read()` SELECT (`:73-97`) to return the new columns for the fill-blank check.

## Risks / notes
1. **No sync trigger on hot fields** — Part A was a one-time backfill; snapshot vs `contactitems` can drift. Phase-1 decision: master-link writes the **snapshot only**, not a `contactitems` row (matches `_src='master'` intent). Document the drift.
2. `recordname` VIRTUAL — never in any INSERT/UPDATE column list.
3. `contactdetails` is a VIEW over `_tbl` — writes go through it; don't mix view/base within one logical write.
4. CSRF/auth: all `/ajax/*` need a session; POST needs `X-CSRF-Token` (`core.cfm` auto-injects). Read=GET, write=POST.
5. Datasource by hostname → use framework `request.dsn`; don't pass dsn/userid as URL params.
6. Master tables are global (no userid) — search unscoped, but every WRITE checks `userid` ownership.
7. Company text = `contactitems.valueCompany` (distinct column) if a `contactitems` row is ever written.

## Implementation steps (minimal-diff, TAO conventions)
1. `ajax/contacts/master-search.cfm` (GET) — parameterized read; `{success,data:{suggestions}}`; fail-open to empty.
2. Client widget — `#masterSearch` input + jQuery-UI autocomplete in `remoteAddName.cfm` and `contact_info.cfm`; `select:` stashes `id/coid/colocid` in hidden inputs.
3. `ContactService.update()` — additive blocks for 3 pointers + hot fields + `_src` + dates; extend `create()` allow-list too. Don't touch `recordname`.
4. `ContactService.read()` — add new columns to SELECT for fill-blank.
5. `ajax/contacts/master-link.cfm` (POST, CSRF) — ownership check, read current, compute fill-blank, `update()` in `<cftransaction>`, stamp `NOW()`.
6. (optional) `ajax/contacts/master-unlink.cfm`.
7. Verify — link a contact; confirm pointers set + blank Company filled `_src='master'` while user Phone stays `'user'`; re-link idempotent; non-owned contactid → not-found; missing CSRF → 403.

**Key files:** `services/ContactService.cfc`, `include/remoteAddName.cfm`, `include/contact_info.cfm`, `include/autocomplete.cfm`, `app/autolookup.cfm`, `ajax/Application.cfc`, `ajax/contacts/check-duplicate.cfm`.
