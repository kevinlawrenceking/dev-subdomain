# TAO repair queue - status register (2026-10-08)

Companion to `docs/runbooks/2026-10-08-book-and-repair-queue-prod-change.md` (the prod change
package) and `database/verify/2026-10-08_book_parity_check.sql` (read-only checks).

Status values: REPRODUCED (with how) / FIXED-IN-DEV-TREE (uncommitted, not deployed, not executed) /
FIXED-IN-CODE (already in git; the prod deploy is unverified) / DEPLOYED / VERIFIED-PROD.
Nothing in this register is DEPLOYED or VERIFIED-PROD. There is no deploy channel from this
workstation, and the dev web server is not running the `dev` branch: probes show it lacks
`/ajax/contact/updateprimary.cfm`.

## Access blockers (2026-10-08)
- MySQL 3306 on www.theactorsoffice.com resets the TCP connection before the server greeting for
  egress IP 65.244.196.2. That IP is on the IIS allow-list in web.config but is evidently not
  allowed at MySQL or the firewall. As a result there is no live schema diff, no ticket status
  read, and no error_tickets read today.
- The Gmail connector lacks read scope, so the alert and ticket email bodies were not readable.

## Priority items

| Item | Status | Evidence | Root cause |
| --- | --- | --- | --- |
| The Book "Add company / Add email" = "Save failed." | REPRODUCED (transport level, prod) | `/ajax/contact/updateprimary.cfm` returns IIS 404 on app and dev, byte-identical to a non-existent file. Sibling `/ajax/master/*.cfm` files return 401 (present). | Deploy gap: the inline editor POSTs to a file that is not on the server. The jQuery error branch prints "Save failed." The endpoint also catches its own exceptions into cflog `wo6_primary`, so it never raises an alert email. Schema is not implicated per the 2026-09-13 prod verification; re-check with SQL sections 1-4. |
| Ticket 2751 remove contact from audition | REPRODUCED (code path) -> FIXED-IN-DEV-TREE | `aud_rel_pane.cfm` `confirmRemove()` POSTs with `fetch()` and no CSRF token. `include/Application.cfc` returns a 403 HTML page. `response.json()` throws and the error only reaches `console.error`, so the DELETE never runs. | Missing token. Same defect class as the earlier `myteam_pane.cfm` fix. |
| Ticket 2547 headshot rename reverts | REPRODUCED (code path) -> FIXED-IN-DEV-TREE | `card_photo.cfm` updates the UI optimistically and POSTs with no token (403, error swallowed). `update_media_name.cfm` also read bare `mediaid`. | Same as 2751. |
| TAO-E002 / E023 USERMEDIAURL (contact create) | REPRODUCED (code path) -> FIXED-IN-DEV-TREE | `include/Application.cfc` overrides onRequestStart without the parent's post-login block. Bare `userid` resolves from the browser-session `cookie.userid` after the CF session expires. The INSERT runs and then `folder_setup.cfm:22` throws. | Half-completed creates, with possible duplicate contacts (SQL section 8). |
| TAO-E010 default avatar FileNotFound | REPRODUCED (code) -> FIXED-IN-DEV-TREE | `contactfolder_setup.cfm:87` copied from `application.defaultAvatarUrl` (a URL). The same bug exists silently in 3 other places. | URL used where a file path is required. |
| Ticket 1267 Targeted list | NEEDS DB | The April rebuild of `contacts_ss_target` (ticket 2191) filters `systemtype='Targeted List'`. The prod view differs from dev per the 2026-08-29 drift report. | SQL sections 9-10. |

## Error register (static triage against HEAD c7bdde78 + working tree; agent-assisted, key claims spot-checked)

FIXED-IN-CODE (prod deploy unverified): E003 (56bc0237), E016 (450fe1c4), E020 (9895e43d),
E021 (7ce2cba8), E022 (a2151b6f), E025 (b690838c), E026 (883c359d), E030 (a99cd5cd),
E033 (a0d26630), E034 (14ffec8c), E035/E036 (861be60c, 862e7a28), E039 (f36e937b),
E040 (60037a5e, probable), E041 (760856c5), E042 (7f97dc6f).
E007 (c7bdde78) is partial: `include/export_auditions.cfm` still reads `session.projectlist` with no check.

FIXED-IN-DEV-TREE today: E002, E010, E023.

STILL-PRESENT, grouped by shared root cause:
- G1, field/variable only defined on the core.cfm or full-post path: E005 `remoteUpdateCUpdate.cfm:14`,
  E009 `remoteAddCAdd.cfm` -> `RegionService.SELregions`, E012 `contact_info.cfm:99` (direct request),
  E013 `get_reminders.cfm:12/75`, E015 `remoteUpdateNameUpdate.cfm:9`, E024 `pgpanels_94_2.cfm`.
- G2, generated key read from the wrong variable: E014 `roleupdateform2.cfm:108`, E017 `:262`
  (and `:202`). The service return values are discarded.
- G3, `CALL UpdateAudProjects()` on every audition page load, unthrottled: E031 `include/qry/audition.cfm:7`.
- E032 orphaned `include/icsmaker.cfm` is still reachable by URL.

INFRA-NOT-CODE: E004/E006/E008 (commons-compress jar conflict in CF lib; needs server admin),
E027 (JCS `cache.ccf` missing).

CANNOT-DETERMINE from source: E001/E018/E019/E037 (cfquery attribute validation). Every affected
query carries no dynamic attribute except the implicit datasource, so the likely failure is an
empty `this.datasource` (app/Application.cfc:35 reads it back from application scope; an
`applicationStop()` exists at app/admin-cache/index.cfm:81). Unconfirmed; SQL section 7 pulls
the stored root-cause text. E028/E029 (a partial deploy is likely; compare the prod file hash).
E038 (needs the stack trace).

## Security findings (not yet fixed unless noted)
1. `/include/*` has no login gate, and CSRF is enforced only when the session already holds a token.
   Unauthenticated writers: `delete_audcontact.cfm` (fixed in tree), `update_media_name.cfm`
   (fixed in tree), `delete_team.cfm` (open), others not yet inventoried.
2. `include/get_reminders.cfm:9` accepts `url.userid`, so a user can read another user's reminders.
3. SQL injection: `services/PanelUserService.cfc:45` `pnid IN (#arguments.new_isvisible#)`;
   `include/icsmaker.cfm:117`.
4. `cookie.userid` is client-controlled and resolves bare `userid` in legacy handlers.

## Not done today
Ticket-queue reconciliation (needs tickets_tbl), relationship engine checks (needs DB),
G1/G2/G3 fixes, and the security items 1-4 above beyond the two endpoints fixed.

---

## Revision 2 (2026-10-08, after the operator ran the parity check)

Operator result: the checked Book inventory exists in both environments. Prod `master_audit_tbl`
is empty. Section 10 returned Targeted enrollments that are missing from `contacts_ss_target`.
Section 8 returned duplicate candidates. Ruling: no Book tables or fields will be added, and no
dev data will be copied.

| # | Item | Status | Evidence / next |
| --- | --- | --- | --- |
| 1 | Full definitions, all column rows, index DEFINITIONS | SQL ready | `database/verify/2026-10-08_followup_detail.sql` part A: SHOW CREATE for 8 tables/views x 2 schemas; every column with position, type, null, default, extra and collation; indexes compared by uniqueness + type + ordered columns + prefix + direction, including same-definition/different-name; FKs; triggers. |
| 2 | Prod Add company / Add email | REPRODUCED at transport level (re-probed today: still 404). Browser repro still owed. | Trace, verified in code: contact_info primary editor -> POST /ajax/contact/updateprimary.cfm -> ContactService.updatePrimary() = ONE conditional UPDATE on contactdetails_tbl (owner + unlinked + not deleted). It calls no master sync and writes no audit, by design. A 404 lands in the jQuery error branch = "Save failed.". Browser repro: DevTools > Network on an unlinked prod contact, click Add company > Save, and expect the POST to show 404. Deploy dependency: `docs/runbooks/2026-10-08-prod-file-fingerprints.md`. |
| 3 | Why prod master_audit_tbl is empty | CAUSE IDENTIFIED IN CODE; deployed-version proof owed | In current code only confirmLink (link-confirm.cfm), the WO-7 unlinkMaster, and syncLinkedContact (on-read sync / resyncall.cfm) write it. On prod: link-confirm.cfm 404, resyncall.cfm 404, on-read sync hard-gated off (`masterBookEnabled = false`). link.cfm and unlink.cfm are PRESENT on prod (401), but neither the HTTP probe nor the repo can say which version. The WO-2 link.cfm linked contacts with no audit row. Datasource: ajax/Application.cfc picks `abo` for host `app`, and MasterAuditService uses the default datasource. Swallowed exceptions: every /ajax/master catch was cflog-only, so failures there left no ticket (fixed in item 6). Proof: fingerprints runbook (file versions) + followup SQL B1-B4 (prod link counts by month vs audit rows). |
| 4 | Targeted misses | SQL ready | Followup SQL part C classifies each miss. INELIGIBLE = contact deleted or contactStatus <> 'Active' (prod contacts_ss filters `contactStatus = 'Active'`). GENUINE = orphan enrollment, enrollment userid differs from the contact owner, filtered by the contactdetails view, or eligible but absent (view-body defect). Verified in code: the Targeted tab renders `contacts_ss_target` directly (include/contacts.cfm:308). No view change until the GENUINE rows are known. |
| 5 | Duplicate candidates | SQL ready, REVIEW ONLY | Followup SQL part D: each pair with failed-create tickets in the window (matched on time + posted name in form_data, because expired-session tickets carry user_id NULL) and related records on each side (items, systems, auditions, events, master link). Notes are not counted: the noteslog contact column is unverified. Nothing merges or deletes. |
| 6 | Root-cause capture | FIXED-IN-DEV-TREE | services/ErrorService.cfc: (a) an exception with no cause chain now uses the outer exception as root (previously every root_cause_* column persisted NULL for unwrapped exceptions); (b) every VARCHAR is clamped to its column width before the INSERT (one over-long Referer used to fail the whole insert under strict mode and leave only a TAO_error_fallback line); (c) new `captureHandled(exception, context)` persists a cf_context='handled' ticket with no user email and no support ticket, wired into the 7 swallowing catches: updateprimary, link-confirm, unlink, resyncall, search, locations, delete_audcontact. Coverage baseline: followup SQL part E. |
| 7 | Ticket 2751 | FIXED-IN-DEV-TREE; dev-server repro blocked (dev host is not running the branch) | Re-verified the reload path. getContactsByAudProject reads audcontacts_auditions_xref directly (no cache). The on-load re-insert (add_cd_368_10) is dead code (`contactid is "99999999"`). The on-load delete (DELaudcontacts_auditions_xref_24545) touches only xrefNotes='Referral' rows. The only defect is the token-less POST (403), plus the missing auth/ownership checks, both fixed. |

Test evidence status: none of the code changes has executed on a server. No CF engine runs on this
workstation, the dev host is behind the branch, and MySQL 3306 still resets from 65.244.196.2
(re-checked today). Acceptance = the smoke steps in the 2026-10-08 runbook after a dev deploy.
