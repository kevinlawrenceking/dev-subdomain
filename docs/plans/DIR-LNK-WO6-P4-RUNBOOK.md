# DIR-LNK-WO-6 — Operator Deploy + P5 Execution Runbook

**Authored:** 2026-07-16 · **Lock:** `docs/plans/DIR-LNK-WO6-PLANLOCK.md` · **Design:** `docs/plans/DIR-LNK-WO6-P2-DESIGN.md` · **Rulings:** `docs/plans/DIR-LNK-WO6-P2-RULINGS-STAMP.md`
**Code of record:** `2bac27c1` (ratified 2026-07-16) · **Tooling:** `2a4e8dcd` · **origin/dev HEAD:** `2a4e8dcd`
**Executor:** Kevin. The deploy is the operator's — the implementer does not deploy.
**Environment:** dev only (`dev.theactorsoffice.com`, schema `new_development`, datasource `abod`). Prod is never touched by this runbook.
**Status:** Section A/B ready to execute. Section C-F (P5) opens only after the D-17 liveness probe passes.

**Holds in force:** No DDL. No DML outside the Section C fixture doctrine. No audit-table writes. No push without a named PUSH GO. Halt-don't-guess: any unexpected output stops the run and gets pasted back before the next step.

---

## Section A — A-6 ROLLBACK PIN CAPTURE (FIRST — before any pull)

The pull is not authorized until the rollback pin is written down. If the pin cannot be established, STOP.

| # | Action | Gate |
|---|---|---|
| A-1 | Read the currently deployed SHA on dev **before touching anything**. Preferred: Hostek panel git status for `dev-subdomain`. Alternate: run `bash tests/p4-landing-check.sh` from the workspace root — probe G reads `/.git/refs/heads/dev` directly if exposed. | A SHA is captured verbatim, or STOP |
| A-2 | Record it as **PIN_PRIOR**. Expected value `a4b68bad` (WO-5 dev read cutover, deployed 2026-07-15). | If it is NOT `a4b68bad`, STOP and report — the deployed tree is not where the record says it is, and the rollback target is unknown |
| A-3 | Record **PIN_TARGET** = `2a4e8dcd` (current `origin/dev`). | — |
| A-4 | Write both pins into the P6 bundle draft before proceeding. | Pins recorded |

### Rollback sequence (execute ONLY under a named rollback decision)

1. Hostek panel: re-pin / pull `dev-subdomain` to **PIN_PRIOR** (`a4b68bad`).
2. CF Admin: clear **template cache AND component cache**. Both. The WO-2 acceptance failed the first time on exactly this — new `/ajax/*` files were live while modified `.cfc` services were stale (the D-17 gap).
3. Liveness probe: load the **full contact page** for a contact whose templates changed (not the `/include` fragment) and confirm it renders. The primary-edit affordance should be **gone** — that absence is the rollback proof.
4. Paste the panel output + probe result into the bundle.

Rollback expectations: WO-6 shipped **zero DDL and zero migrations**, so a code-only revert is complete — there is no data state to unwind. The three primary columns and their `_src` columns predate WO-6 (V3_7/V3_8/V3_9, already in prod). Any fixture rows created in Section C are cleaned up by Section E independently of the pin.

---

## Section B — D-17 DEV DEPLOY (operator-executed)

| # | Action | Gate |
|---|---|---|
| B-1 | **Pre-pull landing check.** From `/c/Users/kevin/TAO/dev-subdomain`: `bash tests/p4-landing-check.sh`. Capture verbatim. | Expect verdict **NOT LANDED** (target classifies with the MISSING control). If it already says LANDED, STOP — the tree is ahead of the record |
| B-2 | Hostek panel: git pull `dev-subdomain` to **PIN_TARGET** `2a4e8dcd`. Capture the panel output. | Pull reports success |
| B-3 | CF Admin: clear **template cache**, then **component cache**. Both, in that order. | Both confirmed cleared |
| B-4 | **Post-pull landing check.** Re-run `bash tests/p4-landing-check.sh`. Capture verbatim. | Expect verdict **LANDED**. The NOT LANDED -> LANDED flip across B-1/B-4 is the file-landing proof |
| B-5 | **Liveness probe (D-17 core).** Logged-in browser, load the **FULL contact page** for an UNLINKED contact owned by user 30 — not the `/include` fragment. | Page renders; no CF error |
| B-6 | **Freshness probe (the stale-compile trap).** On that same page confirm the primary block renders with pencil-edit affordances on company/phone/email, and the item grid header reads **"Additional information"**. | Both visible. If the page renders but these do not, the `.cfc`/`.cfm` compile is stale -> repeat B-3, re-probe. If still absent, STOP |
| B-7 | Optional automated confirmation of B-6: re-run the landing check with probe B enabled (see the cookie recipe in Section D-0). | `update-primary` occurrence count greater than 0 |

**Why B-6 is not optional in substance:** B-4 proves the NEW file landed. It does not prove the MODIFIED files (`ContactService.cfc`, `ContactDuplicateService.cfc`, `contact_info.cfm`, `contact_pane.cfm`) recompiled. That is precisely the D-17 gap that broke the first WO-2 acceptance run.

---

## Section C — A-5 FIXTURE DISCIPLINE (baseline FIRST, then register)

HeidiSQL, `USE new_development;` every session, every step. All fixtures under **test user 30**.

### C-1. Baseline capture (BEFORE any fixture is created)

Run all five, capture verbatim into the bundle as **BASE-1..BASE-5**:

```sql
USE new_development;

-- BASE-1  canonical contacts_ss membership for user 30
SELECT COUNT(*) AS ss_rows FROM contacts_ss WHERE userid = 30;

-- BASE-2  canonical populated-column counts for user 30
SELECT
  SUM(contactPhone   IS NOT NULL AND contactPhone   != '') AS phone_pop,
  SUM(contactEmail   IS NOT NULL AND contactEmail   != '') AS email_pop,
  SUM(contactCompany IS NOT NULL AND contactCompany != '') AS company_pop,
  COUNT(*)                                                 AS active_contacts
FROM contactdetails_tbl
WHERE userid = 30 AND isdeleted = 0;

-- BASE-3  _src distribution for user 30 (every row must be 'user' pre-test)
SELECT contactPhone_src, contactEmail_src, contactCompany_src, COUNT(*) AS n
FROM contactdetails_tbl
WHERE userid = 30 AND isdeleted = 0
GROUP BY contactPhone_src, contactEmail_src, contactCompany_src;

-- BASE-4  audit + log tables (must not move on any negative test)
SELECT COUNT(*) AS master_audit_rows FROM master_audit_tbl;
SELECT COUNT(*) AS updatelog_rows FROM updatelog_tbl WHERE userid = 30;

-- BASE-5  items for user 30 (negative tests must not touch items either)
SELECT COUNT(*) AS item_rows
FROM contactitems_tbl i
JOIN contactdetails_tbl d ON d.contactid = i.contactid
WHERE d.userid = 30 AND i.isdeleted = 0;
```

### C-2. Target identification (do not hardcode from memory — resolve live)

```sql
-- T-LINKED: the linked target of record. Expect 132419 and a NON-NULL master pointer.
SELECT contactid, userid, master_co_contact_id, contactPhone, contactEmail, contactCompany,
       contactPhone_src, contactEmail_src, contactCompany_src, master_last_sync
FROM contactdetails_tbl WHERE contactid = 132419;

-- T-UNLINKED: an unlinked user-30 contact for the positive round-trip.
SELECT contactid, contactFullName, contactPhone, contactEmail, contactCompany
FROM contactdetails_tbl
WHERE userid = 30 AND isdeleted = 0 AND master_co_contact_id IS NULL
ORDER BY contactid DESC LIMIT 5;

-- T-FOREIGN: a contact owned by someone OTHER than user 30, for tenant isolation.
SELECT contactid, userid FROM contactdetails_tbl
WHERE userid != 30 AND isdeleted = 0 LIMIT 3;

-- T-MERGE: linked contacts and their masters, to build the Q1b pairs.
SELECT contactid, userid, master_co_contact_id
FROM contactdetails_tbl
WHERE userid = 30 AND isdeleted = 0 AND master_co_contact_id IS NOT NULL;
```

**Gate:** 132419 must return a non-NULL `master_co_contact_id`. If it is unlinked, the linked-reject tests have no target — STOP and report.

### C-3. Fixture register

Before any assertion runs, write a register table into the bundle. Every ID created during P5 — including add-form and wizard creations — goes here **at creation time**, not retroactively:

| Fixture ID | Origin (test step) | Purpose | Expected end state |
|---|---|---|---|
| (fill live) | e.g. F-CREATE-1 / add form | `_src` create-injection proof | soft-deleted at E-1 |

**Stated expected fixture delta:** Section D creates contacts only in tests D-6 (create-path `_src` injection) and D-9 (create-path D-22 closure). Every other test is a negative and must create **zero** rows. Declare the expected delta before running: `ss_rows` and `active_contacts` rise by exactly the number of fixtures created, and return to BASE at E-2.

---

## Section D — P5 HARNESS (enforcement matrix rows 1, 6, 8)

### D-0. Credentials recipe (no angle brackets; concat-style placeholders)

Get a live session: log into `dev.theactorsoffice.com` as test user 30 in a browser.

- **Cookie** — DevTools, Network tab, pick any request to the domain, copy the **entire `Cookie:` request header value verbatim**. ColdFusion may issue `CFID`/`CFTOKEN` or `JSESSIONID` depending on config, so copying the whole header avoids guessing which.
- **CSRF token** — View source on any logged-in page and read the meta tag emitted by `include/core.cfm:58-59`:
  `meta name="csrf-token" content="THE_TOKEN"`. That is the same value `jQuery.ajaxSetup` sends as `X-CSRF-Token` on every non-GET (`include/core.cfm:226-233`), which is how the WO-6 UI authenticates without naming the token in its own call.

**Git Bash (preferred — curl does not throw on 401/403):**

```bash
HOST="https://dev.theactorsoffice.com"
EP="${HOST}/ajax/contact/update-primary.cfm"

COOKIE="PASTE_THE_ENTIRE_COOKIE_HEADER_VALUE_HERE"
CSRF="PASTE_THE_CSRF_TOKEN_HERE"

T_LINKED="132419"
T_UNLINKED="PASTE_UNLINKED_CONTACTID_FROM_C2"
T_FOREIGN="PASTE_FOREIGN_CONTACTID_FROM_C2"

# helper: prints HTTP status then the JSON body
post() {  # usage: post "form=data&pairs=here" [extra curl args...]
  local body="$1"; shift
  curl -s -m 30 -w '\nHTTP_STATUS:%{http_code}\n' \
       -H "Cookie: ${COOKIE}" \
       -H "X-CSRF-Token: ${CSRF}" \
       --data "${body}" "$@" "${EP}"
}
```

**Windows PowerShell 5.1 alternate** — 5.1 has no `-SkipHttpErrorCheck`, so non-2xx throws and must be caught or the status is lost:

```powershell
$HOST_   = "https://dev.theactorsoffice.com"
$EP      = $HOST_ + "/ajax/contact/update-primary.cfm"
$COOKIE  = "PASTE_THE_ENTIRE_COOKIE_HEADER_VALUE_HERE"
$CSRF    = "PASTE_THE_CSRF_TOKEN_HERE"

function Post-Primary {
    param([string]$Body, [switch]$NoToken, [string]$BadToken)
    $h = @{ "Cookie" = $COOKIE }
    if     ($BadToken) { $h["X-CSRF-Token"] = $BadToken }
    elseif (-not $NoToken) { $h["X-CSRF-Token"] = $CSRF }
    try {
        $r = Invoke-WebRequest -Uri $EP -Method POST -Headers $h -Body $Body -UseBasicParsing
        "HTTP " + $r.StatusCode; $r.Content
    } catch {
        "HTTP " + $_.Exception.Response.StatusCode.value__
        (New-Object IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd()
    }
}
```

---

### D-1. CSRF negative — no token (L-3 P5 addendum, ruling of record)

```bash
curl -s -m 30 -w '\nHTTP_STATUS:%{http_code}\n' \
     -H "Cookie: ${COOKIE}" \
     --data "contactid=${T_UNLINKED}&field=contactPhone&value=555-0100" "${EP}"
```

**Expect:** `HTTP_STATUS:403` and body `{"success":false,"message":"CSRF token required"}` — from the central gate at `ajax/Application.cfc:102-108`, before any template code runs.

**D-1b invalid token:**

```bash
curl -s -m 30 -w '\nHTTP_STATUS:%{http_code}\n' \
     -H "Cookie: ${COOKIE}" -H "X-CSRF-Token: not-a-real-token" \
     --data "contactid=${T_UNLINKED}&field=contactPhone&value=555-0100" "${EP}"
```

**Expect:** `403` / `{"success":false,"message":"Invalid CSRF token"}` (`ajax/Application.cfc:119-125`).

**D-1c no session:**

```bash
curl -s -m 30 -w '\nHTTP_STATUS:%{http_code}\n' \
     --data "contactid=${T_UNLINKED}&field=contactPhone&value=555-0100" "${EP}"
```

**Expect:** `401` / `{"success":false,"message":"Authentication required"}` (`ajax/Application.cfc:57-63`).

Then confirm BASE-2/BASE-3 unmoved.

---

### D-2. Linked-reject on 132419 — all three fields (matrix row 1)

```bash
post "contactid=${T_LINKED}&field=contactPhone&value=555-0199"
post "contactid=${T_LINKED}&field=contactEmail&value=wo6probe@example.com"
post "contactid=${T_LINKED}&field=contactCompany&value=WO6 Probe Co"
```

**Expect each:** `HTTP_STATUS:200`, `success:false`, message *"This contact is linked to the TAO Master Directory. Its primary phone, email, and company are managed by the directory and cannot be edited here - use Suggest a correction to propose a change."*

The 200 is correct and intended: the request is authentic and well-formed; the **rejection is in the payload**, not the transport. The write matched zero rows at `ContactService.cfc:324-332` because of `master_co_contact_id IS NULL`; the message came from the read-only disambiguation branch at `:357`.

**Zero-write proof — run after all three, compare to Section C:**

```sql
USE new_development;
-- columns + _src unchanged on the linked target
SELECT contactid, contactPhone, contactEmail, contactCompany,
       contactPhone_src, contactEmail_src, contactCompany_src, master_last_sync
FROM contactdetails_tbl WHERE contactid = 132419;
-- no probe value leaked anywhere
SELECT COUNT(*) AS leaked FROM contactdetails_tbl
WHERE contactPhone LIKE '%555-0199%' OR contactEmail LIKE '%wo6probe%' OR contactCompany LIKE '%WO6 Probe%';
-- items untouched
SELECT COUNT(*) AS item_rows FROM contactitems_tbl WHERE contactid = 132419 AND isdeleted = 0;
-- audit + log unmoved vs BASE-4
SELECT COUNT(*) AS master_audit_rows FROM master_audit_tbl;
SELECT COUNT(*) AS updatelog_rows FROM updatelog_tbl WHERE userid = 30;
```

**Gate:** `leaked` = 0; audit/log counts identical to BASE-4; item count identical to C-2.

**Also test the UI door (A-4 "every door"):** on 132419's contact page confirm the pencil affordances are **not rendered**, the "Managed by the TAO Master Directory" caption and "Suggest a correction" link **are** rendered, and the item grid is still editable (items stay editable in both link states, per lock 8.2).

---

### D-3. Tenant isolation — contactID substitution (matrix row 1)

Authenticated as user 30, target a contact owned by another user:

```bash
post "contactid=${T_FOREIGN}&field=contactPhone&value=555-0177"
```

**Expect:** `200`, `success:false`, message exactly **"Contact not found."** — deliberately not distinguishing "not yours" from "does not exist" (no enumeration oracle, `ContactService.cfc:353-356`).

**Zero-write proof:**

```sql
SELECT contactid, userid, contactPhone, contactPhone_src
FROM contactdetails_tbl WHERE contactid = PASTE_T_FOREIGN;
SELECT COUNT(*) AS leaked FROM contactdetails_tbl WHERE contactPhone LIKE '%555-0177%';
```

**Gate:** foreign row byte-identical to C-2; `leaked` = 0.

---

### D-4. Oversize per field — on TRIMMED length (matrix row 1, L-6)

Widths: phone **100**, email **150**, company **255**. All on the UNLINKED fixture so the oversize pre-check at `ContactService.cfc:314` is what rejects, not the link guard.

```bash
# one char over each limit
post "contactid=${T_UNLINKED}&field=contactPhone&value=$(printf '9%.0s' $(seq 1 101))"
post "contactid=${T_UNLINKED}&field=contactEmail&value=$(printf 'e%.0s' $(seq 1 141))@example.com"   # 141+12 = 153
post "contactid=${T_UNLINKED}&field=contactCompany&value=$(printf 'C%.0s' $(seq 1 256))"
```

**Expect each:** `200`, `success:false`, *"Primary phone is limited to 100 characters. Nothing was saved."* (and the email/company equivalents). Clean reject — **never truncation**.

**Trim-boundary proof (this is what makes it "on TRIMMED length"):** exactly at the limit plus trailing spaces must **succeed**, because `newValue = trim(arguments.value)` runs at `:283` before the length test:

```bash
post "contactid=${T_UNLINKED}&field=contactPhone&value=$(printf '9%.0s' $(seq 1 100))%20%20%20"
```

**Expect:** `success:true`, "Saved." Then confirm the stored value is exactly 100 chars with no trailing space:

```sql
SELECT contactid, LENGTH(contactPhone) AS len, contactPhone RLIKE ' $' AS has_trailing_space,
       contactPhone_src
FROM contactdetails_tbl WHERE contactid = PASTE_T_UNLINKED;
```

**Gate:** `len` = 100; `has_trailing_space` = 0; no row anywhere has a primary longer than its column width.

---

### D-5. `_src` injection via UPDATE payload (matrix rows 1 + 6, bypass spoof)

Three shapes. All must fail to move provenance:

```bash
# (a) extra _src param riding a legitimate save
post "contactid=${T_UNLINKED}&field=contactPhone&value=555-0111&contactPhone_src=master"

# (b) _src named as the field itself
post "contactid=${T_UNLINKED}&field=contactPhone_src&value=master"

# (c) bypass-shaped params: try to disable the SQL predicate from the client
post "contactid=${T_UNLINKED}&field=contactPhone&value=555-0112&isMaster=1&trusted=1&bypass=1&master_co_contact_id=&userid=99"
```

**Expect:** (a) `success:true` with `data.src` = `"user"` — the extra param is simply never read; `_src` is written server-side from the literal at `ContactService.cfc:327`. (b) `success:false`, **"Unknown field."** — the `cfdefaultcase` at `:307-310`; `_src` is not a routable field key. (c) `success:true` for the phone value only; the spoofed `userid=99` is ignored because the endpoint passes `session.userid` (`ajax/contact/update-primary.cfm:38`), and no parameter exists that can relax `master_co_contact_id IS NULL`.

```sql
SELECT contactid, userid, contactPhone, contactPhone_src FROM contactdetails_tbl WHERE contactid = PASTE_T_UNLINKED;
SELECT COUNT(*) AS non_user_src FROM contactdetails_tbl
WHERE userid = 30 AND (contactPhone_src != 'user' OR contactEmail_src != 'user' OR contactCompany_src != 'user');
```

**Gate:** `contactPhone_src` = `'user'` after every shape; `userid` still 30 (not 99); `non_user_src` matches BASE-3 (master-set `_src` values on linked rows are legitimate and unchanged).

**Row-6 door:** `ContactService.update()` is the trusted master writer and has **no client-facing endpoint that hands it p/e/c keys**. Prove the adjacent door stays shut — POST p/e/c keys at the name-editor that shares `update()`:

```bash
curl -s -m 30 -w '\nHTTP_STATUS:%{http_code}\n' -H "Cookie: ${COOKIE}" \
  --data "currentid=${T_UNLINKED}&contactPhone=555-0166&contactEmail=spoof@example.com&contactCompany=Spoof Co" \
  "${HOST}/include/remoteUpdateNameUpdate.cfm"
```

**Expect:** the p/e/c keys are ignored — that handler passes only name/meeting/pronoun/referral/isdeleted keys to `update()`. Verify no primary moved:

```sql
SELECT COUNT(*) AS leaked FROM contactdetails_tbl
WHERE contactPhone LIKE '%555-0166%' OR contactEmail LIKE '%spoof@example%' OR contactCompany LIKE '%Spoof Co%';
```

**Gate:** `leaked` = 0. Note for the bundle: this surface has **no login gate and no effective CSRF** (`/include` layer) — a registered pre-existing exposure, report-only, not a WO-6 regression.

---

### D-6. `_src` injection via CREATE payload

`create()`'s whitelist (`ContactService.cfc:28-49`) admits the three primary columns and **no `_src` key**, so provenance falls to the column default. Prove it end-to-end through a real create door.

1. Add a contact via the **add form** in the UI as user 30, filling company/phone/email. **Register the new contactID immediately** in C-3.
2. Replay the same create with injected `_src` params using the captured form action and field names from DevTools, appending `contactPhone_src=master&contactEmail_src=master&contactCompany_src=master`. Register that ID too.

```sql
SELECT contactid, userid, contactPhone, contactEmail, contactCompany,
       contactPhone_src, contactEmail_src, contactCompany_src, master_co_contact_id
FROM contactdetails_tbl WHERE contactid IN (PASTE_FIXTURE_IDS);
```

**Gate:** every `_src` = `'user'` (the column default) on both; `master_co_contact_id` NULL on both (new contacts are unlinked by construction). The injected params were dropped by the whitelist loop at `:55-63`, never reaching the INSERT.

**Register note (not a WO-6 defect, carried from the DIR-LNK-WO-6 debt relay):** `create()`'s whitelist also admits `userid` and `isdeleted` and applies no server-side session override — safety today rests entirely on every caller building the struct as a server-side literal from `session.userid`. If this test's replay is ever extended to inject `userid`, expect it to be **ignored by the caller**, not by `create()`.

---

### D-7. Same-value re-submit idempotency

```bash
post "contactid=${T_UNLINKED}&field=contactEmail&value=wo6.idem@example.com"   # first
post "contactid=${T_UNLINKED}&field=contactEmail&value=wo6.idem@example.com"   # second, identical
```

**Expect both:** `200`, `success:true`, `"Saved."`, `data.src` = `"user"`.

The second is the ratified affected-vs-matched path: MySQL may report zero affected rows for an unchanged value depending on the connector's `useAffectedRows` setting, so the disambiguation read at `:344-350` sees row-exists + unlinked + value-identical and returns idempotent success (`:359-366`) rather than a spurious error. This makes the endpoint config-independent across both connector settings.

```sql
SELECT contactid, contactEmail, contactEmail_src FROM contactdetails_tbl WHERE contactid = PASTE_T_UNLINKED;
SELECT COUNT(*) AS n FROM contactdetails_tbl WHERE userid = 30 AND contactEmail = 'wo6.idem@example.com';
```

**Gate:** exactly one row; value and `_src` correct; no duplicate row created by the second submit.

---

### D-8. Merge guard — Q1b (matrix row 8)

From C-2's `T-MERGE` set, build two pairs under user 30:

- **Pair X — different masters:** two contacts with **different** non-NULL `master_co_contact_id`. Attempt the merge via `app/contact-duplicates/index.cfm`.
  **Expect:** blocked with *"These contacts are linked to two different TAO Master Directory records. Unlink one of them first, then merge."* The guard at `ContactDuplicateService.cfc:521` fires **before the transaction opens**, so zero writes on reject.
- **Pair Y — same master:** two contacts sharing the **same** `master_co_contact_id`. **Expect: the merge PASSES** — same-master is not a conflict by ruling.

If dev has no natural Pair X, construct it from fixtures via the UI link control (register both IDs); do not hand-write pointer values — that would be DML outside the fixture doctrine.

```sql
-- after the Pair X rejection: nothing moved
SELECT contactid, master_co_contact_id, isdeleted FROM contactdetails_tbl WHERE contactid IN (PASTE_PAIR_X);
SELECT COUNT(*) AS master_audit_rows FROM master_audit_tbl;   -- vs BASE-4
```

**Gate:** both Pair X rows still active, both pointers intact, audit count unmoved.

**Registered residue (not tested here, by ruling):** Q1a — discard-linked / keep-unlinked — is **not** guarded; the merge is link-blind in that shape and the link is silently buried. This is a known D-15-class gap owned by the merge-owning WO, and it must be restated in the P6 bundle as a live known gap, not a WO-6 failure.

---

### D-9. Positive round-trip + D-22 closure

1. On the unlinked fixture, edit each primary through the UI. **Expect:** inline save, no page reload, "Saved." toast.
2. Create a fresh contact via the add form with all three primaries populated. Register the ID.

```sql
-- columns updated in the BASE TABLE
SELECT contactid, contactPhone, contactEmail, contactCompany,
       contactPhone_src, contactEmail_src, contactCompany_src
FROM contactdetails_tbl WHERE contactid IN (PASTE_FIXTURE_IDS);

-- D-22 closure: the same values are visible through the canonical read view immediately
SELECT contactid, col1, col2, col3, col4, col5 FROM contacts_ss WHERE contactid IN (PASTE_FIXTURE_IDS);
```

**Gate:** every `_src` = `'user'`; `contacts_ss` shows the values with no intermediate step. That is the D-22 closure proof for the manual create/edit paths (Q1e) — since the WO-5 read cutover, `contacts_ss` reads columns, and WO-6 is what finally makes the manual paths write them.

3. **Class-B check:** item grid header reads "Additional information"; item add/edit works on **both** linked and unlinked contacts; an item edit on a linked contact moves item panes only, never the primary block.

4. **Edit-logging:** per the P2e ruling **(ii) accept-unlogged**, primary edits produce **no** `updatelog` rows. Confirm `updatelog_rows` for user 30 is unchanged from BASE-4 after all of D-9. A rise here contradicts the ruling and must be reported.

---

## Section E — CLEANUP + BASELINE RESTORATION (A-5)

| # | Action | Gate |
|---|---|---|
| E-1 | Soft-delete every registered fixture contact per established fixture doctrine (`isdeleted = 1` via the UI delete control, not hand DML). Count must equal the C-3 register exactly. | register count matched |
| E-2 | Re-run **BASE-1 through BASE-5** verbatim. | Every count returns **exactly** to baseline. Any drift stops the run and gets reported, not explained away |
| E-3 | Restore the unlinked fixture's pre-test primary values if it was a pre-existing contact rather than a created fixture (D-4/D-5/D-7 wrote real values into it). Capture its C-2 row first — that is the restore target. | row matches its C-2 capture |
| E-4 | Unlink any links created for Pair X in D-8. | pointers back to their C-2 state |

**Note on E-3:** if you prefer zero mutation of pre-existing rows, create a dedicated fixture contact for D-4/D-5/D-7 instead of reusing `T_UNLINKED`, and register it. That is the cleaner path and is recommended.

---

## Section F — CAPTURE AND REPORT

Paste back, verbatim, for the P6 bundle:

1. Section A pins (PIN_PRIOR, PIN_TARGET) and the rollback sequence as executed or held.
2. B-1 and B-4 landing-check output (the NOT LANDED -> LANDED flip), plus B-5/B-6 probe results.
3. BASE-1..BASE-5 and their E-2 re-runs, side by side.
4. The fixture register, complete, with the stated expected delta and the observed delta.
5. Every D-step response body with its HTTP status, and every zero-write proof query result.
6. PASS/FAIL per lock P5 criterion (a) through (i).
7. Register items restated as live gaps, not failures: Q1a merge residue (D-15 class); `/include` layer auth/CSRF exposure (matrix rows 3-5); `selfCsrfPaths` opt-outs `/ajax/importv3/` and `/ajax/import-auditions/` (standing, report-only); `create()` whitelist admitting `userid`/`isdeleted` with no session override.
8. Deferred tidy riding the next code touch: the `include/contact_info.cfm:163` comment says "its only consumer" but `include/qry/findcompany.cfm:4` still includes `findcompany_476_1.cfm`. Both qry files register to the qry-elimination list as a dead chain — the wrapper appears consumer-less and that must be verified at elimination, not assumed here.

Then STOP for architect review.
