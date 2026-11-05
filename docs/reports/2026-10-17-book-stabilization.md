# Book stabilization (ticket 2757), Excel import failure, Targeted/duplicate checks - 2026-10-17

Status: LOCAL CHANGES ONLY. Nothing committed, deployed, or written to any database. The
production checks were read-only (READ ONLY transaction, SELECT only).

## 1. Book: Add company / email / phone trace

Request path:

1. `include/contact_info.cfm` primary-fields loop (`<cfloop array="#primaryDefs#">`). An unlinked
   contact renders a pencil (`.primary-edit`) or an "Add X" button (`.book-field__add`).
2. The inline editor JS POSTs `{contactid, field, value}` to `/ajax/contact/updateprimary.cfm`
   (CSRF auto-injected by core.cfm).
3. `ajax/contact/updateprimary.cfm` calls `ContactService.updatePrimary()`
   (services/ContactService.cfc:276). That is one conditional UPDATE of `contactdetails_tbl`
   (owner + unlinked + not deleted). The ajax/Application.cfc datasource is chosen by host
   (`app` -> abo).
4. It writes no audit row, by design. Only the master-link paths write `master_audit_tbl`
   (MasterAuditService, called from link-confirm, unlink and the WO-8 sync).

Findings:

| Claim | Status | Evidence |
|---|---|---|
| "Save failed." on prod is a missing deployment | PROVISIONAL | `/ajax/contact/updateprimary.cfm` returns IIS 404 on app and dev, byte-identical to a non-existent control file (probe 2026-10-18 00:11 UTC), and the jQuery `error:` branch prints exactly "Save failed." That is consistent with a missing file but does not prove it (an IIS rule or a mapping could also return that page). Confirm by server inspection: does the file exist under `C:\home	heactorsoffice.com\wwwrootpp-subdomain_1.5jax\contact\`? |
| Routing/WAF | VERIFIED historical, not the current cause | 1cb0e552 renamed `update-primary.cfm` because a front-layer URI rule 404'd the hyphenated SQL keyword. The current name answers 404 like an absent file, and its siblings answer 401. |
| Code defect in the endpoint | NOT ESTABLISHED | It has never executed on any server (dev is behind the branch). |
| Empty prod `master_audit_tbl` | Row counts VERIFIED; explanation PROVISIONAL (depends on which files prod runs) | Prod has 0 audit rows and 0 contacts with `master_co_contact_id` set. The writers are link-confirm (404 on prod), resyncall (404) and the on-read sync (gated off by `masterBookEnabled`). Unlink has nothing to unlink. No link event has ever happened on prod, so there is nothing to audit. |

## 2. Ticket 2757 patch ("Relationship Info - Upper left pane")

- The gate lives in the tracked dev file:
  - `<cfset primaryEditEnabled = masterBookEnabled>`.
  - With the Book off, primary values render read-only and a blank field renders no row. The
    pre-WO-6 panel showed only values on file, via the item-derived company loop.
- The master-link controller JS is now emitted only with the Book on, so a Book-off page carries
  no `/ajax/master/*` or `master_link_preview.cfm` URL.
- `include/contact_info_PROD.cfm` was regenerated from the dev file:
  - Only the banner and `masterBookEnabled = false` differ; a test enforces this.
  - The file is gitignored (`.gitignore:35 include/*_PROD.cfm`). The previous copy is saved in
    the session scratchpad as `contact_info_PROD.cfm.bak-2026-10-08`.

| Control | dev file:line (PROD) | Prod before | Prod after |
|---|---|---|---|
| Pencil edit on primary company/email/phone | contact_info.cfm:888-890 (913-) | shown, opens editor | hidden |
| "Add company / Add email / Add phone" | :891-893 | shown, Save -> 404 -> "Save failed." | hidden; blank rows not rendered |
| Inline editor JS (POST updateprimary.cfm) | :909-981 (934-1006) | emitted | not emitted |
| Primary values (company/email/phone text) | :872-899 | shown | shown read-only (unchanged values) |
| "Find in the Book" chip, search input, location box | :995-1053 (1020-) | hidden by c213a4d8 IF prod runs that file | hidden (unchanged) |
| Book band, unlink, "Suggest a correction" | same block | hidden (same caveat) | hidden |
| Link-preview modal shell | same block | hidden (same caveat) | hidden |
| Master-link JS (search.cfm, unlink.cfm, master_link_preview.cfm) | :1532-1603 (1557-1628) | emitted, inert | not emitted |
| On-read sync hook | :673 (698) | gated | gated (unchanged) |
| Name / tag / item / system edit modals | :198-446 | shown | unchanged (tested) |

Caveat: ticket 2757 (filed 2026-10-08) says the "find the book" box is visible on prod.
c213a4d8 already hides it, so prod is probably running a pre-c213a4d8 `contact_info.cfm`.
That is unverified; see the fingerprint runbook.

## 3. Excel (.xlsx) contacts import

The failure is verified on prod:

- 11 xlsx jobs since May. 9 are stuck in `parsing` (ids 51, 54, 56-59, among others) and 2 are
  cancelled. There are no xlsx successes. CSV and VCF imports work.
- Error tickets 565-569 show `java.lang.NoSuchMethodError` (POI -> commons-compress
  `ZipArchiveInputStream.getNextEntry()`), thrown from `parse.cfm:265`.
- The stack frames 265/261/215/39 line up with the repo's cfspreadsheet / elseif / inner cftry /
  outer cftry lines. That is consistent with the Error escaping three `cfcatch type="any"` blocks,
  but matching line numbers do not establish that prod runs this file (PROVISIONAL until a hash
  or server inspection). The runtime facts (tickets, stuck job rows) are verified.
- Hypothesis: Adobe CF's "any" does not catch `java.lang.Error`. This is consistent with the
  above but unverified against Adobe documentation.

The fix (parse.cfm):

- Read the first 8 bytes of the upload:
  - zip (`50 4B 03 04`) or OLE2 (`D0 CF 11 E0`) means a real workbook;
  - "text" means a CSV saved with an Excel extension, which is the only case that may still use
    the CSV fallback.
- For .xlsx, a reflection probe runs before cfspreadsheet. It loads commons-compress through
  POI's own classloader and checks that `getNextEntry()` returns `ZipArchiveEntry`. If not, the
  import fails cleanly without calling POI.
- The read is wrapped in `cfcatch type="java.lang.LinkageError"` plus "any". Nothing broader,
  such as Throwable or Error, is caught.
- An unreadable workbook throws `TAO.Import.ExcelUnreadable`. Its handler:
  - sets the job to `failed`;
  - logs a `parse_failed` event;
  - writes a handled `error_tickets` row via `captureHandled`, with the jar locations in
    `detail`;
  - returns `PARSE_FAILED` with "We couldn't read this Excel file right now. Please save it as
    CSV (.csv) and upload it again.", which the UI shows via `showAlert`.
- Caveat: whether `cfcatch type="java.lang.LinkageError"` catches the Error on CF 2021 is
  unverified. The probe does not depend on it.
- The jar fix itself (aligning commons-compress with POI) is a server change. It is not done
  here.

## 4. Read-only checks (followup_detail.sql parts C and D, all SELECT)

### Targeted list (C2)

The intended exclusions:

- `contacts_ss_target` is built on `contacts_ss`, which lists the owner's Active, non-deleted
  contacts.
- A deleted contact or a non-Active `contactStatus` is excluded on purpose.

| Reason | Rows | Users |
|---|---|---|
| INELIGIBLE: contact deleted | 351 | 26 |
| GENUINE: enrollment userid differs from contact owner | 14 | 2 |
| GENUINE: orphan enrollment (contactid 0) | 2 | 2 |
| GENUINE: eligible but absent from view | 0 | - |

- All 16 "genuine" rows are 2021 legacy data:
  - suids 425-456: users 9/10 enrolled in contacts owned by user 2;
  - suids 643/661: contactid 0.
- No view-body defect was found, and no current defect. Ticket 1267 (2023) is not reproduced
  by current data.

### Duplicate candidates (D)

- 20 pairs, 8 users, created 2026-04-12 to 2026-10-12. 0 match a failed-create error ticket.
- 9 pairs are within 60 s, and 13 pairs have related records on both sides.
- Notable: user 1054 has 6 pairs created 0-1 s apart. In each, the first record is empty and the
  second carries the items and system. That pattern looks like a double insert or double
  submit in the create path, not a retry after an error.

Nothing was merged or deleted.

## 5. Tests

`tests/regression/test_book_stabilization.py` and `tests/regression/test_import_fallback.py`
are static.

- Working tree: 16/16 pass.
- With `TAO_TEST_GIT_REV=HEAD`: 10 fail, 2 error, 3 skipped (the gitignored PROD file is not
  read at a revision).

Not tested: CFML execution of either change. There is no CF engine locally, and dev is behind the
branch.

## 6. Dev smoke steps (after an approved dev deploy)

1. Open a dev contact (Book on). The pencil and "Add X" work and Save returns JSON, not 404.
2. Temporarily serve the PROD variant on dev, or check prod after an approved deploy:
   - no pencil or "Add X";
   - values render;
   - name, tag and item modals still open;
   - View Source contains no `updateprimary.cfm` or `/ajax/master/`.
3. Upload a real .xlsx on dev. Expect one of:
   - it imports (jars compatible); or
   - the alert reads "We couldn't read this Excel file right now..." AND
     `import_v3_jobs.status='failed'` AND a `cf_context='handled'` error_tickets row whose
     detail names the jar paths.
4. Upload a CSV renamed to .xlsx. It parses through the CSV fallback.
