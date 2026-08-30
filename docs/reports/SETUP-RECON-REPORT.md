# SETUP-RECON-REPORT — thrivecart_tbl vs taousers_tbl reconciliation

Date: 2026-08-17 · Schema: `actorsbusinessoffice` (PROD) · **READ-ONLY. No data changed.**
All remediation below is a **proposal**, held for individual operator authorization.

---

## 0. Scope corrections found while running this

Two premises in the relay needed adjusting before the numbers mean anything.

**0.1 — The supplied TAO product list mixes two different columns.** Of the 25 IDs given,
only 10 exist as `BaseProductID`: **21, 33, 37, 51, 61, 62, 69, 82, 86, 24201**. The other 15
(95048, 95181, 95803–95813, 96343, 97435) are **`BasePaymentPlanID`** values, not product IDs.
Tested both ways: 846 rows match as `BaseProductID`, 188 as `BasePaymentPlanID`. This report
uses the 10 real product IDs as "TAO app products".

**0.2 — TAO-labelled products NOT in the supplied list** (per the relay's request to complete it):

| BaseProductID | Label | Rows | Verdict |
|---|---|---|---|
| 50 | TAO - Relationships Course | 182 | Course, not app access — confirm |
| 50 | TAO - Mini Course | 48 | Course, not app access — confirm |
| 0 | Manual | 5 | Julia's manual records (§2e) |
| 0 | TAO Monthly | 2 | Needs a real product ID |
| 0 | The Actor's Office | 1 | Needs a real product ID |

**0.3 — "Most Emailed rows belong to users who already have accounts" is not what the data shows.**
Of 278 Emailed TAO-app rows, **116 (42%)** have an account; **162 (58%)** genuinely do not.
Both problems are real, but the larger group is still the blocked one.

---

## 1. STATUS LOGIC — the legend

### Join key (confirmed from code, three independent sites)

`taousers_tbl.customerid = thrivecart_tbl.id` — `sched/cancel.cfm:98`,
`sched/events_completed.cfm:154`, `sched/fix_user_statuses.cfm:17`.
**No code joins it the other way.** `thrivecart_tbl.customerid` (the IPN `customer_id`) is
read by nothing and is NULL on real purchases.

### `userstatuses` — the routing table (only 4 rows)

| userstatus | HEX | status_url |
|---|---|---|
| `active` | 616374697665 | `/app/dashboard/` |
| `setup ` | 7365747570**20** ← trailing space | `/app/` |
| `signup` | 7369676E7570 | `/signup/` |
| `suspended` | 73757370656E646564 | `/app/suspended/` |

`app/login2.cfm:15-27` does `INNER JOIN userstatuses us ON us.userstatus = u.userstatus`
and redirects to `us.status_url` (`:39`). **Any userstatus absent from this table returns 0
rows, and `:46` sends the user to `/loginform.cfm?pwrong=Y` — the "Incorrect Email Address
and Password!" message.**

### Live `taousers.userstatus` values

| userstatus | n | In lookup? | Effect |
|---|---|---|---|
| `active` | 426 | yes | → `/app/dashboard/` |
| `Active` | 33 | yes (ci) | → `/app/dashboard/` |
| `setup` | 25 | yes (PAD SPACE) | → `/app/` |
| `Setup` | 1 | yes | → `/app/` |
| `Cancelled` | 22 | **NO** | **cannot log in — told "wrong password"** |
| `inactive` | 2 | **NO** | **cannot log in — told "wrong password"** |
| `Pending` | 1 | **NO** | **cannot log in — told "wrong password"** |

### Live `thrivecart.status` values (IsDeleted=0)

`Pending` 773 · `Completed` 516 · `Emailed` 281 · `Cancelled` 56. No case or whitespace variants.

- `Pending` — awaiting the welcome email. `sched/thrivecart_process.cfm:34` selects these.
- `Emailed` — link sent, setup not finished. **`setup/index.cfm:50` requires exactly this
  value**; anything else renders "Link Expired".
- `Completed` — setup finished (`setup2.cfm:135`).
- `Cancelled` — set by `sched/cancel.cfm:58`.

### Case sensitivity — NOT a bug (checked, contrary to expectation)

Both columns are `utf8mb4_unicode_ci` — case-**insensitive** and PAD SPACE, so `'Active'`
matches `'active'` and `'setup'` matches `'setup '` in SQL. CFML `EQ` on strings is also
case-insensitive, and `app/Application.cfc:493` / `include/qry/fetchUsers.cfm:97` wrap in
`trim()`. **The case variance is cosmetic inconsistency, not a defect.** Severity: LOW
(cleanliness only). The *missing lookup values* above are the real defect.

---

## 2. CORE RECONCILIATION (TAO app products, `IsDeleted=0`)

```sql
SELECT th.status AS tc_status,
  CASE WHEN uk.userid IS NOT NULL THEN 'linked_by_key'
       WHEN ue.userid IS NOT NULL THEN 'matched_by_email_only'
       ELSE 'NO_ACCOUNT' END AS linkage, COUNT(*) n
FROM thrivecart_tbl th
LEFT JOIN taousers_tbl uk ON uk.customerid=th.id AND uk.isdeleted=0
LEFT JOIN taousers_tbl ue ON LOWER(TRIM(ue.userEmail))=LOWER(TRIM(th.CustomerEmail)) AND ue.isdeleted=0
WHERE th.IsDeleted=0 AND th.BaseProductID IN ('21','33','37','51','61','62','69','82','86','24201')
GROUP BY tc_status, linkage;
```

| tc status | linked by key | by email only | NO ACCOUNT |
|---|---|---|---|
| Emailed | 39 | 77 | **162** |
| Completed | 426 | 66 | 33 |
| Cancelled | 7 | 3 | 47 |

**(a) NEEDS SETUP — 162.** See §3.

**(b) ALREADY SET UP, stale `Emailed` — 116** (39 + 77). These split by *how* they fail:

- **39 linked by key** → `index.cfm:50` fires on the GET → generic **"Link Expired"**.
- **77 matched by email only** → GET guard misses (key mismatch), form renders, POST reaches
  `setup2.cfm:109` → redirect carries `error=email_taken`, and `index.cfm:162` *does* show a
  correct message. So this half is already handled; the 39 are the misleading ones.

**(c) STATUS MISMATCH.** 103 `Emailed` purchases whose user is already `Active`;
23 `Completed` with a `Cancelled` user; 33 `Completed` with **no user at all**;
6 `Emailed`/`Cancelled`; 5 `Cancelled`/`setup`; 3 `Cancelled`/`active`; 1 `Completed`/`Pending`.

**(d) DUPLICATE USERS — 0 live duplicates by email.** The relay's `allisonvonhausen` = 8 rows
is **already resolved**: userids 956–962 are `isdeleted=1`, only **963** (`active`) is live.
This is `setup2.cfm:88-91` working as designed — it soft-deletes priors on each retry. The
churn is large (`andrewwhunter@live.com` = 49 rows, 48 deleted; `soyinicrenshaw` 26;
`ce.rothschild47` 20) but harmless: **no cleanup needed, and none is recommended.**
The real duplicates are **14 live clusters sharing a `customerid`**, each exactly 2 rows —
typically a `setup` row plus an `active` row (e.g. cid 3485 → 871:setup, 872:active;
cid 3805 → 1026:Pending, 1027:active). See §4.

**(e) MANUAL CONTAMINATION — 5 rows**, all `BaseProductID=0`, `BasePaymentPlanID=0`,
`InvoiceID` NULL, `customerid` NULL:

| tc id | created | email | status | linked user |
|---|---|---|---|---|
| 3853 | 2026-04-07 | shani.ferry@ | Emailed | 1073:Setup |
| 3858 | 2026-04-14 | jtparson2000@ | Emailed | 1084:Active |
| 3864 | 2026-06-17 | chavarriaerick@ | Emailed | 1090:Active |
| 3879 | 2026-08-11 | manuelsantiagorenken@ | **Pending** | 1095:Active |
| 3880 | 2026-08-11 | cmaloyjacobs@ | **Pending** | 1096:Active |

Damage: `BasePaymentPlanID=0` matches no `paymentplans` row, so
`thrivecart_process.cfm:33`'s INNER JOIN **permanently skips them**. 3879/3880 were flipped to
`Pending` during the resend and can never leave it. They also double-count purchases in any
report keyed on thrivecart.

**(f) ORPHANS.** 9 live users whose `customerid` points at a non-existent thrivecart row;
21 live users with `customerid` NULL (admin-created, incl. userid 1097 `abensley12@`);
322 thrivecart rows have `userid` set vs 1304 NULL — that column is written only by the
test harness and is not a general linkage.

---

## 3. NEEDS-SETUP SHORTLIST — the actionable list

162 total, but most is dead history: **30 undated, 2022:16, 2023:27, 2024:27, 2025:47, 2026:15.**
Recommend acting on 2026 only. Test/internal rows are marked.

| id | created | name | email |
|---|---|---|---|
| 3830 | 01-20 | Noha Arafa Delamésière | noha.arafa@gmail.com |
| 3831 | 01-26 | Welcome to TAO | info@theactorsoffice.com ← internal |
| 3833 | 02-12 | Jason Cox | memask@gmail.com |
| 3842 | 03-21 | Lynette Kelly | lckelly3559@gmail.com ← dup purchase |
| 3849 | 04-03 | Lynette Kelly | lckelly3559@gmail.com ← dup purchase |
| 3854 | 04-08 | Jodie Bentley | nerdgirl1500@gmail.com |
| 3855 | 04-08 | Krystal Lynn Hedrick | krystallynnhedrick@gmail.com |
| 3860 | 04-23 | Andrea Tyler | andreatyler111@gmail.com |
| 3866 | 06-22 | Julia Alexandra | anactorsjournal@gmail.com |
| 3872 | 07-01 | Alison Stover | msalisonstover@gmail.com |
| 3873 | 07-07 | Andrew Wind | theandrewwind@gmail.com |
| 3881 | 08-12 | Angela Fornero | fornero.angela@gmail.com |
| 3882 | 08-12 | Isabella Miranda | 17Isabella17@gmail.com |
| 3885 | 08-17 | Renee Chahoy | rchahoy@gmail.com |
| 3886 | 08-17 | Carole Swann | caroleswann22@gmail.com |

Live setup links (all verified non-blank; 0 Emailed rows have a blank UUID):

```sql
SELECT th.id, th.CustomerFirst, th.CustomerLast, th.CustomerEmail,
       CONCAT('https://app.theactorsoffice.com/setup/?uuid=', th.UUID) AS setup_link
FROM   thrivecart_tbl th
WHERE  th.IsDeleted=0 AND th.status='Emailed'
  AND  th.BaseProductID IN ('21','33','37','51','61','62','69','82','86','24201')
  AND  IFNULL(th.BaseProductLabel,'') <> 'Manual'
  AND  th.`timestamp` >= '2026-01-01'
  AND  NOT EXISTS (SELECT 1 FROM taousers_tbl u  WHERE u.customerid=th.id AND u.isdeleted=0)
  AND  NOT EXISTS (SELECT 1 FROM taousers_tbl u2 WHERE LOWER(TRIM(u2.userEmail))=LOWER(TRIM(th.CustomerEmail)) AND u2.isdeleted=0)
ORDER BY th.id;
```

Lynette Kelly holds 5 separate purchases (3538, 3639, 3670, 3842, 3849) with no account —
worth checking whether she was double-charged. **Severity: HIGH, billing.**

---

## 4. DUPLICATE-RESOLUTION PLAN — proposals only, nothing run

**Deletion safety:** 9 FK constraints reference `taousers_tbl.userID`
(`auditions_tbl`, `audmedia`, `audprojects`, `audquestions_user`, `audroles`,
`contactdetails_tbl`, `essences`, `import_jobs`, `sharetokens`), and **106 tables carry a
`userid` column**. **Never hard-DELETE a user row.** Soft-delete only (`isdeleted=1`), which
is what the app already does.

For each of the 14 live `customerid` clusters, the pattern is one `setup`/`Pending` remnant
plus one `active` row. Recommendation: **keep the `active` row, soft-delete the remnant**,
but only after confirming the remnant owns no data.

Check before acting on any cluster (run per userid, read-only):

```sql
SELECT 'contactdetails' t, COUNT(*) n FROM contactdetails_tbl WHERE userID = :uid
UNION ALL SELECT 'auditions',   COUNT(*) FROM auditions_tbl   WHERE userid = :uid
UNION ALL SELECT 'audprojects', COUNT(*) FROM audprojects     WHERE userid = :uid
UNION ALL SELECT 'essences',    COUNT(*) FROM essences        WHERE userID = :uid
UNION ALL SELECT 'sharetokens', COUNT(*) FROM sharetokens     WHERE userID = :uid
UNION ALL SELECT 'import_jobs', COUNT(*) FROM import_jobs     WHERE userid = :uid;
```

Proposed action **(DO NOT RUN — per-cluster authorization required)**:

```sql
-- snapshot first
CREATE TABLE taousers_dupe_snap_20260817 AS
SELECT userid, userEmail, userstatus, customerid, isdeleted FROM taousers_tbl
WHERE customerid IN (15,19,53,102,422,480,1598,1909,3485,3543,3547,3554,3805,3828);

-- then, ONE cluster at a time, only if the counts above are all zero:
UPDATE taousers_tbl SET isdeleted = 1 WHERE userid = :remnant_uid;
```

**Unsafe / hold:** cid 3543 (895:active, 909:active) and cid 3547 (919:active, 920:active) —
**both rows active in each**, so there is no obvious remnant. Do not touch without deciding
which is canonical. cid 1909 (384:active, 663:inactive) — 663 cannot log in anyway (§8.2).

---

## 5. THE MISLEADING-ERROR ROOT CAUSE — confirmed, with a correction

Confirmed: an already-setup user re-clicking hits `setup2.cfm:103-112` (`qEmailCheck`) →
`cftransaction rollback` → `cflocation /setup/?uuid=...&error=email_taken`.

**Correction to the relay's framing:** that path is *already* handled — it carries the uuid
and `index.cfm:162` prints "That email address is already associated with an active account."
The genuinely misleading page comes from the **other** 39 rows, which never reach setup2:
`index.cfm:50` (`qExistingUser.recordCount GT 0 OR u.status NEQ "Emailed"`) renders the
generic **"Link Expired"** on the GET.

Compounding it: `setup2.cfm:9/17/35/41` redirect **without the uuid**, and `index.cfm` has no
branch for `error=expired`/`error=invalid`, so those fall through to the single row where
`uuid=''` (id 124, Megan Larsen, `Completed`) and *also* render "Link Expired".

**Proposal (DEV only, no deploy):** give `index.cfm:50` a third branch — when a live account
exists for the purchase, show "You've already set up your account" plus a `/loginform.cfm`
link, distinct from single-use expiry; carry `uuid` through all four `setup2` redirects; add
explicit `error=invalid` / `error=expired` branches; and add a `cflog` to `setup2.cfm:17` and
`:35`, which are currently silent and are why this took several passes to localize.

---

## 6. UUID-ROTATION / RESEND HAZARD

`sched/thrivecart_process.cfm:48,56-60` writes a fresh `CreateUUID()` on **every** run, so a
resend orphans links already delivered. Verified: **10 rows were rotated in the 2026-08-17
run**, identifiable by the shared `9CD06…` time prefix — 3872, 3873, 3874, 3876, 3877, 3878,
3881, 3882, 3883, 3884. **Any original link those people received is now dead.** The other
268 Emailed TAO rows retain their original UUID. No duplicate UUIDs exist (0 collisions).

**Proposal:** write the UUID only when blank —
`SET uuid = <new> WHERE id = :id AND (uuid IS NULL OR uuid = '')` — so a resend re-delivers
the *existing* link. Severity: HIGH; this actively destroys working links today.

---

## 7. EMAIL DELIVERY — still open, and it gates everything

- Send path: `sched/thrivecart_process.cfm:131-174`, `cfmail` with **no `server=`**, so it
  uses the CF Admin default. From `support@theactorsoffice.com`, BCC `kevinking7135@gmail.com`.
- **No table logs email sends** — the only mail-ish tables are `funotifications` /
  `casting_notifications`, which are unrelated in-app reminders. There is no send audit trail.
- Failure semantics: a `cfmail` throw is caught at `:177` and hits `<cfcontinue/>` at `:183`,
  which **skips the status update**. So `status='Emailed'` proves only that CF **queued** the
  message, never that it was delivered.
- Operator reports the BCCs for 2026-08-09→16 never arrived. Combined with the above, the
  break is in the **spool → SMTP handoff**, below the CFML.
- Evidence to pull (server-side, not reachable from here): `<cf_root>/cfusion/Mail/undelivr`,
  `.../Mail/spool`, `.../logs/mail.log`. CF build 2021,0,21,330451.
- Prime suspect: envelope sender `support@theactorsoffice.com` rejected — `ipn-cancelled.cfm:84`
  already records `kevin@theactorsoffice.com` as SMTP-rejected ("Invalid Addresses").
- Safe prober: `app/admin-users/ajax/create-test-setup.cfm` (prod-enabled,
  `allowedDsns="abo,abod"`) → IsDemo row → `[TEST]` mail to the admin via the identical path.
  **Not** `sched/standalone_email_test.cfm`, which hardcodes `127.0.0.1:25` and bypasses the
  default server.

**This is the top blocker.** The §3 links are valid; the people cannot receive them.

---

## 8. OTHER INTEGRITY FINDINGS

| # | Finding | Sev | Action |
|---|---|---|---|
| 8.1 | **All 773 `Pending` rows have a `BasePaymentPlanID` with no `paymentplans` match** — `thrivecart_process.cfm:33`'s INNER JOIN can never pick up a single one. The entire Pending backlog is unreachable, and "flip to Pending to resend" cannot work for any of them. | **CRITICAL** | Fix the join (LEFT JOIN + fallback plan name) or backfill `paymentplans`. Proposal only. |
| 8.2 | **25 live users cannot log in** — `userstatus` in (`Cancelled` 22, `inactive` 2, `Pending` 1) is absent from `userstatuses`, so `app/login2.cfm:24` drops them and `:46` reports **wrong password**. | **HIGH** | Add the missing statuses with an appropriate `status_url`, or give login a distinct "account not active" message. |
| 8.3 | **`app/login2.cfm:15` uses `maxrows="1"` with no `ORDER BY`** — with any duplicate email the winning row is arbitrary, so a correct password can fail. Currently 0 live dupes, so latent. | **HIGH (latent)** | Add `AND u.isdeleted=0`, a deterministic `ORDER BY`, and reject on >1. |
| 8.4 | `TrialEndDate` carries the column-default sentinel `2024-12-31` on 321 rows; 733 NULL. Any trial logic reading it is wrong. | MED | Confirm nothing reads it; drop the default. |
| 8.5 | 33 `Completed` TAO purchases with **no user account at all** — status says finished, nothing exists. | MED | Investigate; likely pre-dates the key convention. |
| 8.6 | `thrivecart_tbl.customerid` is read by no code and NULL on real rows. | LOW | Drop the column once §5 lands. |
| 8.7 | Lynette Kelly holds 5 unredeemed purchases (3538/3639/3670/3842/3849). | **HIGH** | Billing check — possible repeat charges. |
| 8.8 | `setup/index.cfm` renders whatever single row matches `uuid=''`. Masked today only because that row (id 124) is `Completed`; if it were `Emailed` with no user, a stranger's name/email would render in the form. | MED (latent disclosure) | Fixed by carrying `uuid` through the redirects (§5). |
| 8.9 | No email-send audit table anywhere. | MED | Add a send log so §7 is diagnosable next time. |

---

## 9. HOLDS

Every query above was `SELECT`/`SHOW` only. **No data was modified. Nothing was deployed.**

**Urgent, safe:** §7 mail diagnosis (read-only, unblocks everyone); §8.2 add missing
`userstatuses` rows (additive, reversible).

**Urgent, needs care:** §8.1 scheduler join — changes who receives mail, so pair it with §7;
§6 UUID write-only-if-blank — one-line change but alters resend semantics.

**Safe but not urgent:** §5 copy/routing (DEV first, dev fixture with NULL `customerid`);
§8.3 login hardening; §8.4/§8.6 schema tidy.

**Do not act without per-cluster review:** §4 duplicates — 106 tables carry `userid`, and two
clusters have two active rows each. Soft-delete only; snapshot first.

**Explicitly recommended AGAINST:** cleaning the soft-deleted `taousers` churn (§2d). It is
`setup2.cfm` working correctly and nothing reads those rows.
