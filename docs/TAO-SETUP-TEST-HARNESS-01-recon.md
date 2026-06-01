# TAO-SETUP-TEST-HARNESS-01 — Phase 1 Recon Report

**App:** The Actors Office (TAO) — ColdFusion (CFML) + MySQL
**Branch:** `dev`
**Status:** Phase 1 Recon — APPROVED. Saved during Phase 2 (Plan) per D8.
**Scope of this doc:** read-only findings with `file:line` evidence. No code was changed.

---

## DOC-DRIFT NOTE (D8) — Recon supersedes original task doc §2 and AC4

The original TAO-SETUP-TEST-HARNESS-01 task doc (chat/project only; not on disk in this
repo) framed a **login-time ThriveCart status sync** as the "central risk" (§2 / WO-010 /
PERF-H-01) and built **AC4** plus an "exempt setup-test users from the login sync" scope
item around it. **Recon disproved this:** there is no ThriveCart sync on the login path
(see R3). The Phase 2 Plan drops that scope item and revises AC4. Where the original task
doc and this Recon conflict, **Recon wins.** A reader of the original doc should treat its
§2 "central risk" and original AC4 as superseded.

---

## Headline: three original-task-doc assumptions did not match live code

1. **The welcome/setup email is sent before any `taousers` row exists** — a `taousers`-row
   resolver cannot intercept it (R1/R4).
2. **There is no login-time ThriveCart status sync** in either login endpoint — the
   "central risk" / "exempt from sync" item targets code not on the login path (R3).
3. **Setup *start* is hard-coupled to a `thrivecart_tbl` row** (uuid + `status='Emailed'`);
   a faithful "from the beginning" run cannot happen without one (R1/R2).

---

## R1 — Who creates the user row; pre-setup state

`sched/thrivecart_process.cfm` does NOT create the `taousers` row. It loops `thrivecart`
rows `status='Pending'`, stamps `uuid`, emails the setup link, marks `Emailed`:
- `:24-35` select Pending; `:51-55` set uuid; `:58-63` `<cfmail to="#new_customerEmail#" bcc="kevinking7135@gmail.com">`; `:87` link `/setup/?uuid=#new_uuid#`; `:113-117` mark `Emailed`.

The `taousers_tbl` row is created at link-click by `setup2.cfm`:
- `setup/index.cfm:9-23` validate uuid vs `thrivecart` `status='Emailed'`; `:32-33` store `session.setupUUID`/`setupThrivecartID`.
- `setup/setup2.cfm:21-27` re-query `thrivecart_tbl` by uuid; `:96-108` INSERT `taousers_tbl` with `customerid` from thrivecart and `userstatus='Setup'` (`:106`); `:113-117` flip thrivecart→`Completed`; `:148` include `user_setup_core.cfm`; `:151` set `session.userid`; `:158` redirect `/app/setup-wizard/`.

Pre-setup state: `userstatus='Setup'`, `setup_step=0`, `setup_completed_at=NULL`,
`customerid`=thrivecart customerid, `contactid` set by `user_setup_core.cfm`.

Self-contact + provisioning (`setup/user_setup_core.cfm`): `:936-980` self-contact
`INSERT INTO contactdetails (contactfullname, userid, user_yn) VALUES (?, ?, 'Y')` + sets
`taousers.contactid`; `:439-552` syncs ~20 `*_user` lookup tables; `:122-131` media dirs;
`:852-934` panels; `:786-850` sitelinks. All KEPT on reset (provisioning).

## R2 — `taousers→thrivecart` nullability; view pattern

- `customerid` is **NULLABLE, no FK** (app-enforced only). `services/UserService.cfc`
  inserts users without `customerid`; `setup2.cfm:97-108` sets it from thrivecart. A test
  user can legally carry `customerid=NULL` **if it skips `setup2.cfm`**.
- View pattern: `database/2025-10-19_add_shareid_to_taousers.sql` — `ALTER TABLE
  taousers_tbl ADD COLUMN …`, then `DROP VIEW` + `CREATE VIEW taousers AS SELECT
  <explicit column list> FROM taousers_tbl WHERE tu.IsDeleted = 0`. Current column list:
  `database/2026-05-06_rebuild_taousers_view_prefCountryIDList.sql`. View is column-listed
  (not `SELECT *`); a dropped column silently breaks every `taousers` read.
- Neither `is_setup_test` nor `test_email_redirect_userid` exists today (grep clean).

## R3 — Login ThriveCart sync (the "central risk") — DOES NOT EXIST

`loginform.cfm:463` posts to `/login/login2.cfm`. Both login endpoints are clean: email
lookup + SHA-512 hash compare + redirect to `status_url`, no thrivecart UPDATE:
- `login/login2.cfm:44-57` (lookup), `:388-401` (auth+redirect).
- `app/login2.cfm:14-47` (same pattern).

Real coupling: `INNER JOIN userstatuses us ON us.userstatus = u.userstatus`
(`login/login2.cfm:53-54`). `'Setup'` is a valid status (`setup2.cfm:95-96`) with a
`status_url`. `include/update_thrivecart_status.cfm` exists but is NOT included by either
login file. **Exemption scope dropped; AC4 revised.**

## R4 — Welcome-email recipient line (resolver seam)

`sched/thrivecart_process.cfm:58-63`: `from="support@theactorsoffice.com"
to="#new_customerEmail#" bcc="kevinking7135@gmail.com"` — but this is pre-user-row (R1).
The post-row admin send at `app/admin-users/ajax/send-email.cfm:153-176` (same from/bcc,
`to="#variables.userEmail#"`, setup link with uuid, sets status `Setup`) is the correct
injection seam.

## R5 / Gate 3b — Run-created data set (CLOSED)

Per-step writes (keyed by `userid` unless noted):
| Step | Endpoint | Writes |
|------|----------|--------|
| 1 | save-step1 | UPDATE `taousers_tbl` profile; UPDATE self-contact `contactdetails_tbl`; phone upsert `contactitems_tbl` on self-contact (idempotent on replay) |
| 2 | save-step2 | `ContactService.create()` → `contactdetails` rows + `contactitems_tbl` (email/phone/company/tags) |
| 3 | save-step3 | `ContactService.create()` → `contactdetails` + `contactitems_tbl` |
| 4 | save-step4 | `audprojects` + `audroles` (`save-step4.cfm:60-103`) |
| 5 | save-step5 | `RelationshipService.startSystemForContact()` → `fusystemusers` (1) + `funotifications` (N) ONLY (`RelationshipService.cfc:269-348`). The `notifications` insert at `:446` is in `startMaintenanceIfNeeded()`, NOT triggered by setup. |
| 6 | save-step6 | `sitelinks_user_tbl`: UPDATE provisioned rows' siteurl; INSERT custom links (`iscustom=1`) |
| 7 | save-step7 | flip `userstatus`→Active, set `setup_completed_at` |

**KEEP/PURGE predicate:** `ContactService.create()` (`ContactService.cfc:41-67`) never
passes `user_yn`, so wizard contacts take the column default; the **self-contact is the
only `user_yn='Y'` row**. KEEP `user_yn='Y'`; PURGE the rest.

**PURGE (run-created):**
- `contactdetails` WHERE `userid=?` AND (`user_yn<>'Y'` OR NULL) + their `contactitems_tbl` children
- `audroles` WHERE `userid=?`; `audprojects` WHERE `userid=?`
- `funotifications` WHERE `suid IN (fusystemusers WHERE userid=?)`; `fusystemusers` WHERE `userid=?`
- `sitelinks_user_tbl` WHERE `userid=?` AND `iscustom=1`

**RESET (mutate, not delete):** `taousers_tbl` → `setup_step=0`, `userstatus='Setup'`,
`setup_completed_at=NULL`; provisioned `sitelinks_user_tbl` (iscustom=0/NULL) → `siteurl=''`, `isdeleted=0`.

**KEEP (never touch):** the `taousers` row (reset only), the self-contact (`user_yn='Y'`)
+ its items, all `*_user` lookups, panels, sitetypes, media dirs.

> Design principle: a dedicated `is_setup_test=1` user has no legitimate data beyond
> provisioning + run data, so userid-scoped purge of the run tables is inherently safe.

## R6 — Admin host + guards (reuse, do not weaken)

- Auth/role: `app/admin-users/admin-guard.cfm:1-37` (session + `userRole IN ('Admin','Administrator')`, AJAX→403).
- CSRF: central in `app/Application.cfc:387-433`; frontend `adminPost()` `include/admin-users.cfm:204-211`.
- Email seam: `app/admin-users/ajax/send-email.cfm:153-176`.
- Env gate: `app/admin-error-test/index.cfm:14-18` (`application.dsn NEQ "abod"`); env map `app/Application.cfc:3-12`.
- UI homes: list header `include/admin-users.cfm:33-36`; detail "Email Actions" `include/admin-users-detail.cfm:147-160`.

## Gate 3a — sentinel thrivecart row 19 (OPEN — data question)

Cannot be closed from static code (it is runtime data). Evidence points to **test
fixture**: project memory establishes userid 30 ↔ thrivecart 19 as Kevin's deliberate,
repeatable test pair (customerid 429583657593005146, email kevinking7135@gmail.com — the
same address hardcoded as BCC across all sends). **Confirm before activating Option B**
with this read-only check:

```sql
SELECT id, status, CustomerEmail, OrderDate, InvoiceID, PurchaseAmountCents
FROM actorsbusinessoffice.thrivecart_tbl WHERE id = 19;
```
Fixture indicators: test/internal CustomerEmail, zero/absent `PurchaseAmountCents`,
synthetic or null `InvoiceID`. If it reads as a real purchase → defer Option B; never
fabricate a replacement thrivecart row.
