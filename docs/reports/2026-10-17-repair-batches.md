# TAO repair batches - 2026-10-17 (PURPLE)

Base: branch `dev`, HEAD `c7bdde78`, nothing committed, nothing deployed, no prod writes.
Companion docs: `docs/reports/2026-10-17-book-stabilization.md`,
`docs/runbooks/2026-10-17-events-backlog-recovery.md`, `docs/reports/TAO-REPAIR-QUEUE-2026-10-08.md`.

Status words: VERIFIED (checked today against code, prod read-only SQL, or a passing test),
TESTED-SQL (exact SQL from the source run against `new_development` fixtures, rolled back),
TESTED-STATIC (source-level regression test that also fails on HEAD), UNRUN-CFML (no ColdFusion
engine exists on the workstation; the CFML itself has not executed anywhere).

Test suite: `python -I tests/regression/run_all.py` (DB tests need TAO_DB_HOST/USER/PASSWORD in
the environment; without them they skip). Result today: 67 run, 67 OK with DB; 48 OK + 19 skipped
without DB. Fixture rows left in new_development after the run: 0 (checked).

## 1. Buyer access (12 purchase rows at 'Emailed' with no linked account)

'Emailed' means cfmail accepted the message into the spool. It is not proof of delivery.

| Class | thrivecart ids | Evidence (prod, read-only) | Access today |
| --- | --- | --- | --- |
| A. Working account under another purchase row | 3889 (user 1073), 3891 (1104), 3897 (918), 3903 (1113) | Same email has an account linked to a different thrivecart row; setup_step 7; contacts created | Has access. Possible duplicate billing: billing system check |
| B. Account exists, setup never finished | 3890 (user 1105, step 0), 3896 (1106, step 1), 3907 (1110, step 0) | 1105/1110 were linked to admin-created 'Manual' rows 3902/3909 (plan 0) = the admin welcome path; 0 contacts | Partial: account, no completed setup |
| C. No account at all | 3888, 3892, 3908, 3911, 3916 | InvoiceID present; PurchaseAmountCents NULL; plans 97435 "Three Months Free!" (4) and 95048 "$17/month after free trial" (1); no cancel rows | None. Delivery unknown |

Payment: no row records an amount; all 12 are trial-type plans. "Paid" is UNVERIFIED until the
billing dashboard confirms each invoice. `loggins` stopped writing on 2026-09-24, so it cannot show
login attempts.

Defect found (VERIFIED in code; that it affected 1105/1110 is consistent but not proven): `app/admin-users/ajax/send-email.cfm`
template `welcome` always targets an existing user and links the purchase to it; since 862e7a28
(deployed 2026-08-17) `setup/index.cfm` treats a purchase with a linked user as used and shows
"Link Expired". Every admin welcome email since then was dead on arrival.

Token assessment:
- Generation: `createUUID()` (35 chars). Adobe documents uniqueness, not unpredictability; treat
  as not cryptographically assured (UNVERIFIED either way).
- Storage: plaintext (`thrivecart_tbl.uuid`, `taousers_tbl.recover`).
- Setup link: single-use (status 'Emailed' + no linked user + in-transaction re-check +
  email_taken guard). NO expiry: 247 live links, 201 older than one year.
- Recover link: single-use, cleared on use, 60-minute TTL. `taousers_tbl.recover` DEFAULTS to the
  literal 'setup' (991 rows), so `?recover=setup` matched real accounts; only the NULL
  `recover_requested_at` check blocked it.
- Revocation: only implicit (each scheduled send rotates the setup token). No explicit revoke.

Local fixes (TESTED-STATIC, UNRUN-CFML): welcome template refuses with a pointer to
password_reset before any write; setup/recover pages reject tokens shorter than 32 chars before the
lookup; lost-session setup redirects get an accurate "Setup Timed Out" page instead of the
misleading "Link Expired". No token format change, no new reusable token.

Proposed next (needs approval): CSPRNG tokens (`hash(generateSecretKey("AES",256),"SHA-256")`,
no schema change); `setup_token_issued_at` column + 30-day validity (schema change, migration +
rollback to be written); revoke live setup links older than 180 days (data change; see the
revocation rules in section 4 - revoked tokens are never restored).

## 2. Dev deployment manifest (do not deploy without approval)

Exclude `.vscode/settings.json`, `tests/`, `docs/`, `database/verify/`. Before copying, back up
each target file on the dev server into `_rollback_2026-10-17\<same path>`. No batch needs a DB
change. If trusted cache is on, clear the template cache after copying.

| Batch | Files | Must ship together | Dev smoke test |
| --- | --- | --- | --- |
| D1 Security | include/get_reminders.cfm, services/PanelUserService.cfc, include/dashboardupdate2.cfm, include/icsmaker.cfm | - | Logged out: GET /include/get_reminders.cfm?currentid=X -> 401 []. Logged in as test user A with ?userid=<test B> -> only A's rows. Dashboard panel save still works for A; posting userid=B changes only A. Logged out /include/icsmaker.cfm -> login redirect |
| D2 Signup | app/admin-users/ajax/send-email.cfm, setup/index.cfm, recover/index.cfm, recover/setup2.cfm | - | Admin "welcome" on a test user -> refusal message, thrivecart row unchanged. /setup/?uuid= (blank) -> dashboard redirect; /setup/?error=expired -> "Setup Timed Out". /recover/?recover=setup -> login form. A fresh IsDemo test purchase completes setup end to end |
| D3 Audition + media | include/aud_rel_pane.cfm, include/delete_audcontact.cfm, services/ContactItemService.cfc, include/card_photo.cfm, include/update_media_name.cfm | pane+endpoint+service | Remove a contact from a test audition, reload: gone; the contact and its other auditions remain. Rename a headshot, reload: name stays. Rename with another user's mediaid via devtools -> "error" |
| D4 Contact create | app/Application.cfc, include/Application.cfc, include/remoteAddName.cfm, include/remoteAddNameAdd.cfm, include/remoteAddContactAdd.cfm, include/contactfolder_setup.cfm, include/birthdays.cfm, include/dash_repteam.cfm | BOTH Application.cfc files (include/ calls the new parent method; shipping only include/Application.cfc breaks every /include/ request); remoteAddName.cfm with remoteAddNameAdd.cfm | Create a contact with a fresh session; create after deleting the session cookie -> login redirect, no row inserted; double-click Add (or resubmit the same form) -> one contact; open the modal twice and add the same name twice -> two contacts; retry from a form rendered before the deploy (no token) -> inserts as before; new test user with no avatar.jpg -> default avatar copied |
| D5 Error capture | services/ErrorService.cfc, ajax/contact/updateprimary.cfm, ajax/master/link-confirm.cfm, locations.cfm, resyncall.cfm, search.cfm, unlink.cfm | ErrorService first (callers are guarded, so order is safe either way) | Trigger a known dev error -> error_tickets row has root_cause_type/message filled; a handled failure -> cf_context='handled', no email, no user_email |
| D6 Book (2757) | include/contact_info.cfm (dev). Prod uses include/contact_info_PROD.cfm deployed AS contact_info.cfm (gitignored file) | - | Dev: Book controls still present. Render the PROD variant on dev (or a dev copy with masterBookEnabled=false): no Add company/email/phone, no pencil, values read-only; name/tag/item/system edits work |
| D7 Import | ajax/importv3/parse.cfm | - | CSV import works; .xlsx on dev -> either parses or job 'failed' with the save-as-CSV message (never junk rows, never stuck in 'parsing') |
| D8 Events | sched/events_completed.cfm | - | Dev: plain run (no enableWrites) -> status `jobc_count_only` with eligibleEvents / wouldEnroll / wouldBellNotifications / wouldRemindersMax, and 0 new fusystemusers / notifications / funotifications rows and 0 events changed (compare max ids before/after). Then `?dryrun=1`. No `enableWrites=1` run |

Rollback (any batch): restore the backed-up files from `_rollback_2026-10-17` (D4: both
Application.cfc together), clear template cache, re-run that batch's smoke test. No data to undo
except: D3/D4 smoke tests create test rows (use test users only).

## 3. Proposed production batches (each needs explicit approval after its dev batch passes)

- P0 urgent containment: D1. Closes an unauthenticated cross-user reminder read and an
  injectable UPDATE reachable without login (exploitability inferred from code; no prod probes
  were sent). Confirm via fingerprint that prod calendar-appoint.cfm no longer includes icsmaker.cfm.
- P1: D2 (stops dead admin welcome links and misleading expired pages).
- P2: D3 (tickets 2751, 2547).
- P3: D4 + D5 together (contact-create integrity + real root causes in tickets).
- P4: D6 (2757; needs Kevin's scope acceptance of the control table).
- P5: D7 (needs the jar inventory first to know whether the message or a server fix is the end state).
- P6: D8 deployed with the scheduled-task URL UNCHANGED (no `enableWrites`): JOB C count-only,
  JOB D + ICS off. Review at least one night's counts (eligible events, enrollments, bell
  notifications, reminders) before any approval to add `enableWrites=1`. The backlog stays
  untouched until the recovery runbook decisions D1-D4 are made.

## 4. Data recovery proposals (none executed; each needs approval)

Rollback rule (replaces the earlier "restore the snapshot" proposal). A sent email cannot be
unsent, and putting an old token back can kill a link that was just emailed or revive one that
was deliberately revoked. Recovery is therefore forward-only:
- Old tokens are never restored. The snapshot is for audit only: row id, status, timestamp and
  a SHA-256 of the token, never the token itself.
- "Undo" of a mistaken send = revoke the new token (replace it with a fresh random value that
  is never emailed, so the sent link stops working). If the person should still get access,
  issue one more link through the normal path.
- At any moment a purchase has at most one live setup link: the most recently issued one.

- R1 class C buyers (3888, 3892, 3908, 3911, 3916). One id at a time, and only after an IsDemo
  [TEST] send (`app/admin-users/ajax/create-test-setup.cfm`) reaches state 2 in section 5:
  1. Re-check the row: still 'Emailed', still no linked account, purchase still active in billing.
  2. Record the audit snapshot (id, status, timestamp, sha256(uuid)).
  3. Set status 'Pending'. The scheduler rotates the token (permanently revoking the old,
     never-confirmed link) and queues one email.
  4. Track that send through the section 5 states. Do not resend while it is in state 1 or 2.
     A bounce (state 3) means fix the address first, never a blind repeat.
  5. Close the case only at state 4 (customer-confirmed).
  Alternative for any buyer: Kevin contacts them personally first and confirms the address.
- R2 class B (users 1105, 1106, 1110): password_reset (60-minute, single-use link) at a time
  agreed with the person, or personal contact. Never a setup link (it shows "Link Expired" by
  design). Same tracking states.
- R3 class A: no access action; billing check for duplicate charges.
- R4 9 importv3 jobs stuck in 'parsing' -> 'failed' (audit snapshot first; these rows carry no
  token).
- R5 events backlog: per `docs/runbooks/2026-10-17-events-backlog-recovery.md` after decisions
  D1-D4, and only after count-only nights have been reviewed.
- R6 duplicate contacts: 20 pairs / 8 users; user 1054 has 7 same-second pairs (double submit).
  Review only; merges only via the existing safe merge tool with the user's approval.
- Old live setup links (247; 201 older than one year): revoke by replacing the token with a
  fresh never-emailed random value (same forward-only rule). Needs approval and an age threshold.

## 5. Mail delivery states (track each send separately; never infer a later state)

| State | Meaning | Evidence that establishes it | Does NOT prove |
| --- | --- | --- | --- |
| 1 Queued | cfmail accepted the message into CF's spool | thrivecart status 'Emailed' (set only when cfmail did not throw) | that it left the server |
| 2 Accepted by relay | the configured SMTP server took the message for that recipient | a `cfusion/logs/mail.log` entry for the message, no matching file in `cfusion/Mail/undelivr`, spool drained | that the recipient's provider accepted or delivered it |
| 3 Bounced / rejected | the relay or the recipient's provider refused it | a file in `Mail/undelivr` (headers give the reason), or a bounce/DSN in the support@ mailbox | - |
| 4 Customer-confirmed | the person actually has it | they complete setup (taousers row + Completed), or confirm by reply or phone | - |

The BCC copy to kevinking7135@gmail.com proves only that the message reached the BCC inbox,
which shows the relay worked for that one address. It is not evidence for the customer address
(a different provider can still reject or spam-folder it). Record a BCC receipt as a supporting
note under state 2, never as state 4.

## 6. Production identity (PROVISIONAL until hashes or server inspection)

Matching error-ticket line numbers, or a 404 page, do not establish which file prod runs. These
stay provisional:
- prod `sched/events_completed.cfm` and `ajax/importv3/parse.cfm` are the HEAD versions
  (inferred from frame line numbers);
- `/ajax/contact/updateprimary.cfm`, `/ajax/master/link-confirm.cfm`, `/ajax/master/resyncall.cfm`
  and `/include/master_link_preview.cfm` are missing on prod and dev (the 404 page is consistent
  with a missing file but could also come from an IIS rule or a mapping);
- prod `include/contact_info.cfm` predates c213a4d8 (inferred from ticket 2757's wording);
- prod `services/ErrorService.cfc` predates the April cause-chain work (inferred from 0 stored
  root causes since April).

To confirm: run `certutil -hashfile <file> SHA256` on the server and compare with
`docs/runbooks/2026-10-17-prod-identity-hashes.md` (HEAD in LF and CRLF form, plus the
working-tree hash a deploy would produce). For the 404s, also list the directory on the server.

## 7. D1 dev gate (next step; copying files to dev needs approval)

Files: include/get_reminders.cfm, services/PanelUserService.cfc, include/dashboardupdate2.cfm,
include/icsmaker.cfm. After the copy, each dev file must hash to its working-tree value in the
hashes runbook.

1. Before the copy, run `python tests/http/d1_security_http.py` against dev with two dedicated
   dev test accounts (A and B). On the old code, expect the cross-user reminder and/or panel
   checks to FAIL: that reproduces the defects over real HTTP. Save the output.
2. Back up the four dev files to `_rollback_2026-10-17`, copy the new ones, verify the hashes,
   and clear the template cache if trusted cache is on.
3. Re-run the harness. Expect every check to PASS, except `ics.cross_user`, which stays
   INCONCLUSIVE unless TAO_TEST_B_ICS_URL is supplied. Save the output.
4. Review both outputs before any other batch goes to dev.

Rollback: restore the four files from `_rollback_2026-10-17`, clear the cache, re-run the
harness (expect the step-1 results again).
