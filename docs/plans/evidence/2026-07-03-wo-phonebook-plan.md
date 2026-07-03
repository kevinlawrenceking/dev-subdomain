# WO-PHONEBOOK — Phase P (Plan) — Option B (delete dead email-resolution block)

Date: 2026-07-03
Author: CC (Claude)
Scope: `services/AuditionImportService.cfc` — remove the never-functional
`INNER JOIN phonebook` email-resolution block in `processRowForImport`.
Gate status: **PLAN COMPLETE — STOP.** Phase I (implement) is gated on Kevin's D1
confirmation + paste of the 4a'/4b probe results. This document is paper only; no
code was changed in `AuditionImportService.cfc`.

Depends on / supersedes evidence:
- `docs/plans/evidence/2026-07-03-wo-phonebook-recon.md` (Phase R — accepted)
- `docs/plans/evidence/2026-07-03-merge-repoint-sqlpack.txt` (pack `E_phonebook`: ABSENT)

---

## Option ruling — Option B (recommend), Option A registered as follow-up WO

**Chosen: Option B — delete the dead block.** Justification (per Phase R proof):
- The block is **NEVER-FUNCTIONAL** (R1): `phonebook` has never existed in any schema
  and the join has thrown `ER_NO_SUCH_TABLE` for every email-bearing row since
  2026-03-12. It resolves nothing today.
- B is **strictly restorative, not feature work.** The `len(trim(contact_email)) > 0`
  guard kills email-bearing rows at the email block **before** the proven-working
  name resolver at `:1637`. Deleting the block lets those rows fall through to the
  name resolver unchanged — restoring name linkage for exactly the rows the bug was
  killing. No new matching semantics are introduced.

**Option A (contactitems email resolution) is real value but is deferred as a
separate, gated WO — NOT done here.** Reasons:
- A is **feature work with a known hazard.** The 5A finding (shared office emails)
  means naive email auto-linking would attach auditions to the **wrong** contact when
  multiple contacts share one email.
- A introduces a **second match definition**, re-creating the very divergence that the
  unified-matcher work (items 1 / 5A) is eliminating.
- **Registered follow-up:** `WO-PHONEBOOK-A` — email-based audition→contact linkage
  via `contactitems`. Gated on the unified matcher semantics from items 1/5A;
  priority-weighted by the 4b email-row volume; its plan **must** handle the
  shared-email / multi-match case explicitly (deterministic tie-break or no-link).
  Do not action until the matcher semantics land.

Rejected default (per WO): guard-and-log around a broken join. Not pursued — leaves
dead SQL and a phantom table reference in the tree.

---

## 1. Exact deletion — file:line

**File:** `services/AuditionImportService.cfc`
**Delete:** the email-resolution `if` block, **lines 1617–1635 inclusive** (the
`if (len(trim(audData.contact_email))) { ... }` block that contains the
`INNER JOIN phonebook` query at :1618–1630).

- **Keep** `var contactId = 0;` at **:1616** — the name resolver at :1637 depends on it.
- **Keep** the name resolver (`:1637–1652`) and everything below unchanged.
- **Update** the section comment at **:1615** from
  `// D) Resolve contact: lookup by email or name, or create minimal contact`
  to reflect name-only resolution, e.g.
  `// D) Resolve contact by name (email-based resolution removed 2026-07-03, WO-PHONEBOOK — referenced a nonexistent 'phonebook' table; see docs/plans/evidence/2026-07-03-wo-phonebook-recon.md).`

Block being removed (current text, for the diff record):
```
1617  if (len(trim(audData.contact_email))) {
1618      var qContact = queryExecute(
1619          "SELECT cd.contactid
1620           FROM contactdetails cd
1621           INNER JOIN phonebook pb ON pb.contactid = cd.contactid
1622           WHERE cd.userid = :userid AND pb.type = 'email'
1623             AND pb.phoneNumber = :email AND cd.IsDeleted = 0
1624           LIMIT 1",
1625          { userid: {...}, email: {...} },
1626          { datasource: application.datasource }
1627      );
1631      if (structKeyExists(request, "perfSvcQueryCount")) request.perfSvcQueryCount++;
1632      if (qContact.recordCount gt 0) {
1633          contactId = qContact.contactid;
1634      }
1635  }
```
No other change to `AuditionImportService.cfc`. Delete-only; no replacement query
(that would be Option A).

## 2. Grep sweep — zero code references remain

Post-edit acceptance grep (repo-wide, case-insensitive):
```
git -C c:/Users/kevin/TAO/dev-subdomain grep -in phonebook -- . ':!docs/**' ':!database/claude-projects/**'
```
- **Pre-fix baseline (2026-07-03):** the ONLY executable code reference is
  `services/AuditionImportService.cfc:1621`. Remaining hits are all non-code:
  WO/evidence docs under `docs/plans/**` and the phantom audit-doc row #153 in
  `database/claude-projects/tao-coldfusion-expert/09-database-schema.md:235`
  (+ sibling copies `.../tao-migration-analyst/04-...:235`,
  `.../tao-flutter-expert/03-...:235`), now annotated as DRIFT.
- **Post-fix expectation:** the code grep above (docs and audit-doc copies excluded)
  returns **zero rows**. A full unfiltered `git grep -in phonebook` will still match
  the intentional evidence/WO/drift-note references — that is expected and desired
  (the drift record must survive). The acceptance assertion is specifically: **no
  `.cfc`/`.cfm` code path references `phonebook`.**

## 3. Flow statement — both row classes reach the name resolver unchanged

Control flow after deletion (cite `AuditionImportService.cfc`):
- **:1616** `var contactId = 0;` runs for every row.
- The email block is gone; execution proceeds directly to **:1637**
  `if (contactId eq 0 && len(trim(audData.contact_name)))`. Because `contactId` is
  now unconditionally `0` at this point, the name resolver runs whenever
  `contact_name` is non-empty.
- **Email-bearing rows** (previously threw at the phonebook join, :1618): now skip
  the removed block and hit the name resolver at :1637. They resolve by
  `contactFullName` if a name match exists, else `contactId` stays `0` and the row
  **still imports** with `audprojects.contactid` / `auditions.contactid` NULL
  (`:1717`, `:1795` — both already use `null: <id> eq 0`). Casting-director linkage
  (`:1654–1671`) and the transaction (`:1696+`) are untouched.
- **Email-less rows** (`len(trim(contact_email))` was false): behavior **identical**
  to today — they already skipped the email block via the guard and reached the name
  resolver. Zero change → regression-safe by construction.

Net effect: deletion removes a throw, never a resolution. No row that imports today
stops importing; email-bearing rows that fail today begin importing (with name-based
linkage where a name matches, NULL otherwise).

## 4. Failed-row recovery on next finalize — CLEAN, automatic, no reset needed

The finalize path already self-heals prior phonebook failures. On the next
`finalizeJob` run:
- **Block B (`:1416–1428`)** runs first and executes:
  ```sql
  UPDATE import_auditions_rows
  SET status = 'ready', import_error = NULL, updated_at = NOW()
  WHERE job_id = :job_id AND status = 'failed' AND created_audition_id IS NULL
  ```
  Every phonebook-failed row qualifies: the throw fired **pre-transaction** (R5), so
  `created_audition_id` is `NULL`. These rows are flipped back to `'ready'` **and
  their stale `import_error` (the "Table 'phonebook' doesn't exist" text) is NULLed**
  in the same statement. No residue.
- **Block C (`:1431–1442`)** then re-selects `status = 'ready'` rows → the reset rows
  are re-processed by `processRowForImport`.
- The **idempotency guard (`:1573`)** short-circuits only on
  `action_taken = 'created'`; a prior `'failed'` `row_results` row does not
  short-circuit, so the row proceeds through the (now email-block-free) resolver into
  the transaction and creates the audition. On success, **E6 (`:1852–1873`)** upserts
  `import_auditions_row_results` with `ON DUPLICATE KEY UPDATE action_taken='created'`,
  correcting the stale `'failed'` result row too.

**Answer: clean automatic retry — no manual reset, flag, or backfill required.**
`import_auditions_rows.import_error` is cleared by the existing Block-B reset;
`row_results.action_taken` is corrected by the E6 upsert; no double-insert is possible
because a pre-transaction failure inserted nothing. Rows that had failed ONLY on the
phonebook error will import cleanly on the first finalize after the fix.

## 5. Transaction posture & idempotency (unchanged, restated for the record)

- The deletion is entirely **outside** `transaction { }` (`:1696`); posture is
  untouched. Per-row transaction, per-row isolation preserved.
- Idempotency unchanged: `UNIQUE(row_id)` on `import_auditions_row_results` + the
  `:1573` guard + Block-B reset. Double-finalize remains safe (created rows
  short-circuit; failed-then-fixed rows retry once and become `'created'`).

## 6. Acceptance — DEV-PROOF runbook (CC authors; Kevin executes on dev `abod`)

All steps on **dev** (`new_development` / datasource `abod`). CC does not run these.

**Fixture:** a small audition-import CSV/XLSX with four row classes:
1. **email + matching name** — `contact_email` set AND `contact_name` equals an
   existing `contactdetails.contactFullName` for the test user.
2. **email + non-matching name** — `contact_email` set, `contact_name` matches no
   contact.
3. **email only, no name** — `contact_email` set, `contact_name` blank.
4. **email-less** (regression control) — no `contact_email`; `contact_name` matches
   an existing contact.
Each row must carry a `project_name` and a resolvable category (else it fails on an
unrelated required-field check, not this path).

**Procedure:**
- P0. Confirm the code change is in place:
  ```
  git -C <repo> grep -in phonebook -- 'services/**' 'include/**' 'app/**' 'ajax/**'
  ```
  → expect **zero rows**.
- P1. Import the fixture through the normal audition-import wizard to staging, review,
  approve all four rows, and **Finalize**.
- P2. Finalize summary shows **0 failed** for these rows (previously rows 1–3 would
  show `IMPORT_EXCEPTION` / phonebook).

**Verification SQL (parameterize `:job_id`, `:uid`):**
```sql
-- (a) No row failed with the phonebook signature anymore
SELECT row_id, status, LEFT(import_error,200) AS import_error
FROM import_auditions_rows
WHERE job_id = :job_id
ORDER BY row_num;
-- expect all four 'imported'; import_error NULL for all.

-- (b) Result rows all 'created', none 'failed'
SELECT row_id, action_taken, error_code
FROM import_auditions_row_results
WHERE job_id = :job_id
ORDER BY row_id;

-- (c) Name-match linkage populated on project + flat audition (row class 1)
--     Use the created_audition_id (= audprojectid) from import_auditions_rows.
SELECT ap.audprojectid, ap.projName, ap.contactid AS proj_contactid
FROM audprojects ap
WHERE ap.audprojectid IN (
  SELECT created_audition_id FROM import_auditions_rows
  WHERE job_id = :job_id AND created_audition_id IS NOT NULL);
-- row class 1: proj_contactid = the matched contact (or the casting-director
--   contact if casting_director also matched — casting takes precedence, :1699).

SELECT userid, project_name, contactid
FROM auditions
WHERE userid = :uid
ORDER BY audition_id DESC
LIMIT 8;
-- row class 1: contactid = matched contact.
-- row classes 2 and 3 (no name match): contactid IS NULL, row still present.

-- (d) Email-less regression control (row class 4) links by name exactly as before
--     — contactid populated from the name match, identical to pre-fix behavior.
```

**Pass criteria:**
1. Zero code references to `phonebook` (P0).
2. Rows 1–3 (email-bearing) import with **no** `IMPORT_EXCEPTION`; previously all
   three failed.
3. Row 1 resolves `contactid` by name on both `audprojects` and `auditions`.
4. Rows 2 & 3 import with `contactid` **NULL** (clean no-match), row present.
5. Row 4 (email-less) unchanged vs pre-fix — links by name.
6. **Retry proof (optional, if 4a'/4b showed pre-existing failed rows on dev):**
   re-finalize a job that has prior phonebook-`'failed'` rows; Block B resets them and
   they import cleanly, `import_error` NULL, `action_taken` flips to `'created'`.
7. Grep proof pasted into the Phase I proof bundle.

---

## Registers (do not action — carried from Phase R acceptance)

- **OBS-1 (observability):** the row-level `catch (any e)` (`:1559`/`:1879`) means the
  entire audition-import **exception** failure class never reaches
  `ErrorService`/`error_tickets` — only staging tables. Cross-register to the
  observability thread: exception-class failures (as distinct from validation
  failures) should surface beyond staging. Not part of Option B.
- **A-WO (Option A follow-up):** `WO-PHONEBOOK-A` — email-based audition→contact
  linkage via `contactitems`, gated on unified matcher semantics (items 1/5A),
  weighted by 4b volume, must handle shared-email/multi-match explicitly.
- **Probe-interpretation note (for the paste):** `auditions` at 0/55 `contactid` is
  consistent with EITHER rare feature usage OR systematic email-row failure — **4b
  disambiguates.** Append the reading to the recon doc when results land.

**STOP — Phase I gates on Kevin's D1 confirmation + 4a'/4b probe paste. No code
change performed in `AuditionImportService.cfc`.**
