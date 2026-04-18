# TAO-SPEC-2026-005 Phase 2c — Dev Deploy + Smoke Test Runbook

Date: 2026-04-17
Scope: **Dev only** (`abod` / `new_development`). Do **not** promote to prod in this step.
Owner: Kevin King

## What this runbook covers
1. Apply the additive migration on dev.
2. Confirm the dev branch has the Phase 2b ErrorService changes deployed.
3. Trigger all three smoke-test exception shapes.
4. Run the verification SQL bundle and check pass criteria.
5. Inspect the `TAO_error_fallback` log for silent failures.
6. Stop. **Do not promote to prod** in this step.

---

## Pre-flight

- [ ] Current branch is `dev` and working tree is clean except for the three expected files:
  - `services/ErrorService.cfc`
  - `database/migrations/2026-04-17_error_tickets_add_root_cause.sql`
  - `database/migrations/2026-04-17_error_tickets_add_root_cause_rollback.sql`
  - `app/admin-error-test/index.cfm` (new)
  - `database/verification/2026-04-17_phase_2c_verification.sql` (new)
  - `database/verification/2026-04-17_phase_2c_deploy_steps.md` (this file)
- [ ] Dev app is reachable at the dev subdomain (NOT `app.theactorsoffice.com`).
- [ ] You have a MySQL client pointed at `new_development` on the dev server.

---

## Step 1 — Apply the migration (dev only)

Run against **`new_development`** only:

```bash
mysql -u <user> -p new_development < database/migrations/2026-04-17_error_tickets_add_root_cause.sql
```

Confirm the six new columns exist and the index is present by executing **Check 1** from
`database/verification/2026-04-17_phase_2c_verification.sql`.

**Pass criteria:**
- 6 rows returned for the columns query, all `IS_NULLABLE = YES`, `COLUMN_DEFAULT = NULL`.
- 1 row returned for the index query (`INDEX_NAME = idx_root_cause_type`).

If either fails, run the rollback immediately and stop:

```bash
mysql -u <user> -p new_development < database/migrations/2026-04-17_error_tickets_add_root_cause_rollback.sql
```

---

## Step 2 — Confirm dev branch has Phase 2b changes

From the dev web host, verify `services/ErrorService.cfc` on disk contains:

- `unwrapCauseChain` function (starts around line 79)
- The 8 new `diag.rootCause*` / `diag.causeChain*` assignments in `buildDiagnostics`
  (starts around line 211)
- The 6 new INSERT columns and bindings in `persistTicket`
  (column list lines 294-295, VALUES bindings lines 307-312)
- The conditional Root Cause block in `createSupportTicket`
  (lines 368-376)

Also restart the dev CF application so the ErrorService singleton reloads with the new code.
In TAO this is typically a touch of `Application.cfc` or a bounce of the CF instance.

---

## Step 3 — Trigger the three smoke-test shapes

Log in to the dev app as an Administrator, then hit in order:

1. `/app/admin-error-test/?mode=query` — SQL exception
2. `/app/admin-error-test/?mode=expression` — undefined scope
3. `/app/admin-error-test/?mode=nested` — catch + rethrow with `object=cfcatch`

Each request should render the standard TAO error page (or `safeMessage` via onError).
A matching `ERR-xxxxxxxx` ticket id should appear in the page, and one row should land
in each of `error_tickets` and `tickets`.

**Do not** call these more than once per mode during verification — repeat runs make the
"3 most recent rows" check harder to read.

---

## Step 4 — Run the verification SQL bundle

```bash
mysql -u <user> -p new_development < database/verification/2026-04-17_phase_2c_verification.sql
```

**Pass criteria:**

| Check | Expectation |
|---|---|
| 1. Schema | 6 column rows + 1 index row, all NULL-able, default NULL. |
| 2. Recent 3 error_tickets | 3 rows — newest is `nested`, then `expression`, then `query`. `query` row has non-empty `root_cause_type` and non-zero `root_cause_line`. `expression` row has empty `root_cause_type`. `nested` row has `cause_chain_bytes > 0`. |
| 3. Paired tickets rows | 3 rows with `tickettype = 'Error'` and `pgid > 0`, `verid > 0`, `userid > 0`. `query` and `nested` rows have `has_root_cause_block = 1`. |
| 4. Nested chain depth | At least one row in the last hour with `chain_depth >= 1`. `nested` row ideally has `chain_depth >= 1`. |
| 5. Fallback health | `missing_ticket_id = 0`, `missing_error_message = 0`, `with_root_cause_type >= 1`. |

If **any** row for the `query` mode has empty `root_cause_type` or `root_cause_line = 0`,
stop and investigate — that's the primary capture path and must work.

---

## Step 5 — Inspect the fallback log

On the dev CF host, tail the fallback log:

```bash
tail -n 200 <CF_HOME>/logs/TAO_error_fallback.log
```

**Pass criteria:**
- Zero lines containing `unwrapCauseChain failed`.
- Zero lines containing `DB persist failed` for any of the three smoke-test ticket ids.
- Zero lines containing `Failed to create support ticket` for those ticket ids.

A warning about `lookupUser failed` is only a problem if the test user is a real
`taousers` row — for the Admin session it should succeed silently.

---

## Step 6 — Stop here

Do **not**:
- Apply the migration against `actorsbusinessoffice` (prod).
- Merge the dev branch to the production branch.
- Page the support inbox.

Promotion to prod is a separate phase (Phase 3). That phase is gated on a full day of
dev error traffic without `TAO_error_fallback` noise and on a sign-off review of the
three captured smoke-test rows.

---

## Rollback (dev) — if anything above fails

```bash
mysql -u <user> -p new_development < database/migrations/2026-04-17_error_tickets_add_root_cause_rollback.sql
```

Then revert `services/ErrorService.cfc` to the prior commit. ErrorService code is
backward-compatible with the pre-migration schema via the `null="..."` bindings, but
rolling the code back keeps the dev branch consistent while the capture gap is
investigated.
