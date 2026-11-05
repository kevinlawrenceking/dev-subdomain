# 2026-10-08 Prod change package (FOR REVIEW - NOTHING HERE HAS BEEN EXECUTED)

Owner: Kevin King. Prepared by Claude Code. Every step below is operator-executed after review.
Branch `dev`, base HEAD `c7bdde78` (local, 1 ahead of origin/dev `8aa80d9f`). All code changes are
UNCOMMITTED in the working tree.

## 0. What was observed (evidence, 2026-10-08)

Unauthenticated GET probes. Existing endpoints answer 401 from `/ajax/Application.cfc`; missing
ones answer the IIS 404 page, byte-identical to a deliberately non-existent file on the same host.

| Path | app (prod) | dev |
| --- | --- | --- |
| /ajax/contact/updateprimary.cfm | **404** | **404** |
| /ajax/master/search.cfm, link.cfm, unlink.cfm, locations.cfm | 401 (present) | 401 (present) |
| /ajax/master/link-confirm.cfm | **404** | **404** |
| /ajax/master/resyncall.cfm | **404** | **404** |
| /include/master_link_preview.cfm | **404** | **404** |

`web.config` has no URL-sequence filter that could produce these 404s. The Book's inline primary
editor (`include/contact_info.cfm`, and the prod variant `include/contact_info_PROD.cfm`) renders
"Add company" / "Add email" for every unlinked contact and POSTs to
`/ajax/contact/updateprimary.cfm`. A 404 lands in the jQuery `error:` branch, which prints exactly
**"Save failed."** This reproduces the reported symptom at the transport level on prod. The dev web
server is also missing the file, so the dev host is not running the `dev` branch either.

Schema: last read-only diff 2026-08-29 + operator verification 2026-09-13 show every Book table and
column present on prod (see `docs/reports/PROD-SCHEMA-DRIFT-2026-08-29.md`). Not re-verified today:
MySQL 3306 resets the connection from this workstation (egress IP 65.244.196.2) before the server
greeting. Step 1 re-verifies.

## 1. Re-verify schema (read-only)

Run `database/verify/2026-10-08_book_parity_check.sql`. Expected: sections 1-4 all `OK`.
Section 5 gives reference-data row counts (co_contacts / companies / co_locations).
Sections 7-8 collect evidence for TAO-E001 and possible duplicate contacts from TAO-E002.

If and only if a section reports `GAP`, apply the matching existing idempotent migration (each is a
guarded no-op for objects already present, and each has a ROLLBACK file beside it):

| Gap | Migration (already in repo) |
| --- | --- |
| contactdetails_tbl primary/_src/master columns or idx_cd_* | `database/migrations/V3_7__master_directory_wo1_contactdetails_columns.sql` |
| contactdetails view lacks the columns | `database/migrations/V3_8__master_directory_wo1_contactdetails_view.sql` |
| master_audit_tbl / master_correction_requests_tbl | `database/migrations/2026-08-29_wo8_prod_promotion_master_audit_correction.sql` |

No new DDL is proposed: nothing observed today calls for it, and none of these migrations touch
existing rows. Before any DDL: `mysqldump --single-transaction actorsbusinessoffice contactdetails_tbl`
(InnoDB, online). ALTER on contactdetails_tbl (~65k rows) is INSTANT/INPLACE in MySQL 8.0.41 for
nullable ADD COLUMN; MySQL DDL is not transactional, so rollback = the ROLLBACK file, not a ROLLBACK.

## 2. The Book "Add company / Add email" fix = deploy, not code

Prerequisite check on the PROD file system: `services\ContactService.cfc` contains
`name="updatePrimary"`. If it does not, the deployed ContactService predates WO-6 and must be
replaced as well; diff it against the repo copy first, because the repo copy also carries WO-8
`writeMasterSync` (unreachable on prod while `masterBookEnabled = false`).

Deploy to dev first, then prod:
- `ajax/contact/updateprimary.cfm` (new folder `ajax/contact/` if absent)
- `services/ContactService.cfc` only if the prerequisite check fails

Do NOT deploy `include/master_link_preview.cfm`, `ajax/master/link-confirm.cfm` or `resyncall.cfm`
as part of this item: those belong to the WO-8 promotion, and the prod Book band stays gated off.

Smoke (prod, a test user's unlinked contact): Add company -> "Saved." -> hard reload -> value is
still there; Add email -> same. SQL read-back:
`SELECT contactCompany, contactCompany_src, contactEmail, contactEmail_src FROM contactdetails_tbl WHERE contactid = <id>;`
expect the values plus `_src = 'user'`. Linked contact: editor is not offered; a forged POST returns
the "linked to the Book" reject and writes nothing.

## 3. Code changes in the working tree (deploy after review + "commit approved")

| Issue | Files |
| --- | --- |
| Ticket 2751 audition contact removal | include/aud_rel_pane.cfm, include/delete_audcontact.cfm, services/ContactItemService.cfc |
| Ticket 2547 headshot rename reverts | include/card_photo.cfm, include/update_media_name.cfm |
| TAO-E002 / E023 USERMEDIAURL on contact create | app/Application.cfc, include/Application.cfc, include/remoteAddNameAdd.cfm, include/remoteAddContactAdd.cfm |
| TAO-E010 default avatar copied from a URL | include/contactfolder_setup.cfm, include/contact_info.cfm, include/birthdays.cfm, include/dash_repteam.cfm |

`include/contact_info_PROD.cfm` (git-ignored prod variant) carries the same one-line avatar change
at line 824. Its diff against `include/contact_info.cfm` is still only the banner and the
`masterBookEnabled = false` gate. On prod it deploys as `include/contact_info.cfm`.

Rollback: redeploy the previous copies of the files above (no schema involved).

## 4. Smoke tests after deploy (dev first, then prod)

Ticket 2751:
1. Add contact C to audition A and to audition B.
2. On A, click the remove icon, confirm. Card disappears with no alert.
3. Hard reload A: C is gone. Open B: C is still listed. Contacts list: C still exists.
4. SQL: `SELECT audprojectid FROM audcontacts_auditions_xref WHERE contactid = <C>;` returns B only.
5. Edge: click remove twice quickly (second call is a no-op success). Let the session expire
   and click remove: an alert appears and nothing is deleted.

Ticket 2547:
1. Rename a headshot and press Enter. Hard reload: the new name persists.
2. SQL: `SELECT mediaName FROM audmedia WHERE mediaid = <id>;`.
3. Edge: rename to the same name (success). Expired session: the name reverts and an alert appears.

TAO-E002 / E023:
1. Log in, open Add Contact, wait out the session (or delete the session cookie but keep the
   `userid` cookie), submit. Expect a redirect to login and NO new row:
   `SELECT COUNT(*) FROM contactdetails_tbl WHERE userid = <u> AND contactFullName = '<name>';`.
2. Normal create still lands on the new contact, and `media-abo\users\<u>\contacts\<id>\` exists.

## 5. Security findings found during this pass (not yet fixed beyond the items above)

- Before this change, `/include/delete_audcontact.cfm` had no auth and no ownership check, and
  `include/Application.cfc` only enforces CSRF when the session already holds a token. An anonymous
  POST could delete any audition-contact link. Fixed in the working tree. NOT probed on prod.
- The same pattern remains in `/include/delete_team.cfm` (deletes `contactitems_tbl` "My Team"
  rows for any contactid) and in any other `/include/*` writer. `include/Application.cfc` has no
  login gate at all. Recommended next work order: an inventory of `/include/*` POST handlers
  plus a session gate in `include/Application.cfc`, with an allow-list for pages that are
  legitimately public.
- `cookie.userid` (`include/pgload.cfm:39`) is client-controlled and is read bare (`userid`) by
  legacy handlers whenever the variables scope lacks it. Pinning `userid = session.userid` at
  handler entry, as done here for the two contact-create handlers, should spread to every writer.
