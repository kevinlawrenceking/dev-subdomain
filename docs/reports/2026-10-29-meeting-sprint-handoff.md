# TAO meeting stabilization sprint - 2026-10-29

Checkout `C:\Users\kevin\TAO\dev-subdomain`, branch `dev`, HEAD `c7bdde78` (origin/dev is 1 behind).
Nothing committed, pushed or deployed in this sprint. No database writes (DEV or PROD).
CFML status for everything below: UNRUN-CFML (static checks only) until the hosted-DEV checklist passes.

## Blockers

1. MySQL unreachable from this workstation. Egress IP is `65.244.196.2`; port 3306 accepts TCP and
   then resets before the MySQL greeting (host allowlist). On Oct 17 the allowed IP was
   `76.33.177.146`. Result: no DEV/PROD schema parity check, no DB-backed tests (17 skipped), no
   ticket re-reads (565-569, 2751, 2757, ContactService/TicketService errors), no DEV migration.
   Fix: add 65.244.196.2 to the Hostek remote-MySQL allowlist (or work from the .177.146 network).
2. DEV deploy = Hostek git-update from origin/dev (ruling D-13). It needs code commits + a push, and
   standing rule SR-1 requires a standalone `PUSH GO` instrument. See "Deploy" below.

## Changes this sprint (local working tree)

Book hidden behind one switch:
- NEW `include/book_feature.cfm` - `request.bookFeatureEnabled = false`. Re-enable = set true.
- NEW `include/book_feature_guard.cfm` - 403 + `{success:false, code:"FEATURE_DISABLED", message, data}`, aborts before any work.
- `ajax/master/{search,locations,link-confirm,unlink,resyncall,link}.cfm`, `ajax/contact/updateprimary.cfm` - include the guard right after `cfcontent`. Logged-out requests still get the existing 401 from ajax/Application.cfc first.
- `include/master_link_preview.cfm` - neutral notice + 403 when off, before any param/query.
- `include/contact_info.cfm` (+ gitignored `contact_info_PROD.cfm`) - `masterBookEnabled` forced false when the switch is off. That hides the Book band, "Find in the Book", the preview modal, all master-link JS, the WO-6 pencil / "Add company|email|phone" editor, and the on-read sync. Primary values render read-only. Name/tag/item/system modals are unchanged.
- Not touched: audition "Booked" (`aud_book_pane.cfm`, `bookupdateform.cfm`). Book code and data are preserved.

Excel import:
- `ajax/importv3/parse.cfm` - NEW POI-free `.xlsx` reader (`readXlsxNative`: JDK java.util.zip + xmlParse; first sheet; shared/inline strings, booleans, date-styled numbers -> yyyy-mm-dd; 60 MB/part guard; DOCTYPE refused). Used when the existing reflection probe says POI/commons-compress is incompatible, or when cfspreadsheet throws on a real workbook. If the native reader also fails, the Oct 17 clean-failure path still applies (job `failed`, save-as-CSV message, handled error ticket). No shared JAR change, no restart.

Tests: NEW `tests/regression/test_book_switch.py`; `test_book_stabilization.py` adjusted for the
second hard-false assignment. Suite: 74 run, OK, 17 skipped (DB). Tag balance check clean on all changed CFML.

Carried from Oct 17 (still uncommitted, see `2026-10-17-repair-batches.md`): D1 security, D2 signup,
D3 audition/media (#2751), D4 contact create, D5 error capture, D6 (#2757), D8 events (count-only).

## Hosted-DEV baseline (logged out, 2026-10-29, before any deploy)

| URL | Result | Meaning |
|---|---|---|
| /include/master_link_preview.cfm | 404 | dev does not run the branch |
| /ajax/contact/updateprimary.cfm | 404 | same |
| /ajax/master/search.cfm | 401 JSON | auth gate works |
| /include/get_reminders.cfm?currentid=1 | 500 | D1 defect class: no login gate |
| /include/icsmaker.cfm | 500 | same |
| /ajax/importv3/parse.cfm | 401 JSON | auth gate works |

## Deploy to hosted DEV (needs Kevin)

Proposed commits (I make them once you reply "commit approved"):
1. D1 security - include/get_reminders.cfm, services/PanelUserService.cfc, include/dashboardupdate2.cfm, include/icsmaker.cfm
2. Book switch + #2757 - include/book_feature.cfm, include/book_feature_guard.cfm, include/contact_info.cfm, include/master_link_preview.cfm, ajax/master/*.cfm, ajax/contact/updateprimary.cfm, services/ErrorService.cfc (the D5 caller changes already in those ajax files need it)
3. #2751 + media - include/aud_rel_pane.cfm, include/delete_audcontact.cfm, services/ContactItemService.cfc, include/card_photo.cfm, include/update_media_name.cfm
4. Import - ajax/importv3/parse.cfm
5. Docs/tests (pre-authorized class) - docs/, tests/, database/verify/

Not included: D2, D4 (both Application.cfc files), D8, .vscode. One git-update ships commits 1-4 together. That departs from the one-dev-batch-at-a-time rule. The checklist below runs D1 first, and the alternative is to push commit 1 alone.

Instrument to paste (SR-1):

```
PUSH GO
range: c7bdde78..<tip after commits 1-5> on dev -> origin/dev
set: c7bdde78 (auditions empty export) + commits 1-5 above
target: hosted DEV via Hostek git-update only; NOT production
```

Then run the Hostek git-update for dev-subdomain, and clear the template cache if trusted cache is on.

Rollback: `git revert` the commits, push (new PUSH GO), and git-update again. No DB changes to undo.
To bring the Book back on DEV without reverting, set `request.bookFeatureEnabled = true` in
`include/book_feature.cfm`. Prod stays off through its host gate and the PROD variant.

## Kevin's final checklist (about 10 minutes, dev.theactorsoffice.com, after git-update)

I run steps 1-2 myself as soon as the deploy lands (logged out). Steps 3-7 need your login.

1. Logged out: GET /include/get_reminders.cfm?currentid=1 -> 401 `[]` (was 500). GET /include/icsmaker.cfm -> login redirect (was 500).
2. Logged out: GET /include/master_link_preview.cfm -> 403 "temporarily unavailable" (was 404).
3. Book hidden: open any contact. No "Find in the Book", no Book band, no pencil, no "Add company/email/phone". Company/email/phone values still show. The name, tag and item edit modals still open and save. View Source contains no `/ajax/master/` and no `updateprimary.cfm`. DevTools Network on load: no request to /ajax/master/*.
4. Book endpoint while logged in: in the console, `fetch('/ajax/master/search.cfm?term=ab').then(r=>r.status)` -> 403, body code FEATURE_DISABLED.
5. #2751: add a contact to audition A and to audition B. Remove it from A, reload A: it is gone. Open B: it is still there. Contacts list: the contact still exists.
6. Import: upload a small real .xlsx (3 rows, with a date column) -> mapping screen shows the 3 rows with correct headers and yyyy-mm-dd dates. Finalize -> 3 contacts. Finalize again (or refresh) -> still 3, no duplicates. Then upload a CSV -> works as before.
7. Cross-user (D1): logged in as test user A, GET /include/get_reminders.cfm?currentid=<B's contactid> -> only A's rows (empty).

If step 6 shows the save-as-CSV alert instead of rows, the native reader failed. Send me the `importv3` log line `EXCEL_UNREADABLE ... native reader:` (cfusion/logs/importv3.log on the dev server).

## Remaining work, ranked

1. Allowlist 65.244.196.2 in MySQL, then: DEV/PROD parity check for Book/import objects, DB tests, re-read of tickets 565-569 (confirm the NoSuchMethodError descriptor matches the probe).
2. Hosted-DEV D1 harness with test accounts A/B (`tests/http/d1_security_http.py`, env TAO_TEST_A_*/B_*), including test-data cleanup.
3. ContactService/TicketService InvalidTagAttributeException: needs the ticket text. Leading hypothesis (unverified) is an intermittent empty default datasource. Not changed.
4. Jar inventory on the server (POI vs commons-compress) so the native reader becomes a fallback, not the main path.
5. D2/D4/D8 batches; prod promotion (separately gated).
