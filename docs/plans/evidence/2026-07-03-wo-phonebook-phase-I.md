# WO-PHONEBOOK — Phase I (Implement) deliverable

Date: 2026-07-03
Author: CC (Claude)
Ruling: **D1 = B APPROVED** (Kevin). Option B, delete-only, executed per the accepted plan.
Baseline spec: `docs/plans/evidence/2026-07-03-wo-phonebook-plan.md`.
Gate status: **DELIVERABLES COMPLETE — STOP.** No commit performed. Kevin executes the
runbook on `abod`, returns outputs; commit authorization at proof-bundle review.
Binding verified this run: cwd `C:\Users\kevin\TAO\dev-subdomain`, branch `dev`, remote
`kevinlawrenceking/dev-subdomain` — matches WO header (NN#10).

---

## 1. Conformance note (baseline = the accepted plan)

This change conforms to `2026-07-03-wo-phonebook-plan.md` item 1 exactly: the dead
email-resolution block (`if (len(trim(audData.contact_email))) { ... INNER JOIN phonebook ... }`,
pre-edit lines 1617-1635) is **deleted with no replacement query** (Option B, not Option A);
`var contactId = 0;` is retained; the `// D)` comment is rewritten to name-only with a
tombstone pointing at the recon doc. Control flow is exactly as the plan's item 3 predicted
— both email-bearing and email-less rows now fall straight through to the unchanged
name resolver at (post-edit) `:1621` `if (contactId eq 0 && len(trim(audData.contact_name)))`,
which resolves `contactFullName` or leaves `contactId = 0` (row still imports NULL). The
transaction (plan item 5), idempotency, and the finalize self-heal (plan item 4) are
untouched. No other code path is modified.

## 2. Staged-style diff (file:line anchors)

**File: `services/AuditionImportService.cfc`** — inside `processRowForImport()`, section D.
Pre-edit lines 1617-1635 removed; comment at 1615 rewritten. Net: 4 insertions
(comment), 20 deletions.

```diff
@@ services/AuditionImportService.cfc  processRowForImport()  (pre-edit :1615-1635) @@
-            // D) Resolve contact: lookup by email or name, or create minimal contact
+            // D) Resolve contact by name (email-based resolution removed 2026-07-03,
+            //    WO-PHONEBOOK -- it referenced a nonexistent 'phonebook' table and threw
+            //    ER_NO_SUCH_TABLE for every email-bearing row; never-functional since
+            //    2026-03-12. See docs/plans/evidence/2026-07-03-wo-phonebook-recon.md.)
             var contactId = 0;
-            if (len(trim(audData.contact_email))) {
-                var qContact = queryExecute(
-                    "SELECT cd.contactid
-                     FROM contactdetails cd
-                     INNER JOIN phonebook pb ON pb.contactid = cd.contactid
-                     WHERE cd.userid = :userid AND pb.type = 'email'
-                       AND pb.phoneNumber = :email AND cd.IsDeleted = 0
-                     LIMIT 1",
-                    {
-                        userid: { value: arguments.userid, cfsqltype: "cf_sql_integer" },
-                        email: { value: trim(audData.contact_email), cfsqltype: "cf_sql_varchar" }
-                    },
-                    { datasource: application.datasource }
-                );
-                if (structKeyExists(request, "perfSvcQueryCount")) request.perfSvcQueryCount++;
-                if (qContact.recordCount gt 0) {
-                    contactId = qContact.contactid;
-                }
-            }

             if (contactId eq 0 && len(trim(audData.contact_name))) {   // name resolver, unchanged
```

Isolation: `git show`/`git diff -- services/AuditionImportService.cfc` shows ONLY this hunk.

**Incidental (declared, NOT part of the fix):** the working tree carried a pre-existing
stray corruption on line 1 (`e /**` instead of `/**`) — present before this WO (the file
was already `M` at session start), unrelated to phonebook. I reverted line 1 to its HEAD
value `/**`. Because that restores HEAD state, it is a no-op and does NOT appear in the
commit diff; flagged only so the stray edit is on record. The clean single-hunk diff
confirms line 1 was the sole other working-tree edit in this file.

## 3. Grep proof (code-scoped)

```
# executable references -- MUST be zero
git grep -n -E 'JOIN[[:space:]]+phonebook|FROM[[:space:]]+phonebook|phonebook[[:space:]]+pb|pb\.phoneNumber' -- '*.cfc' '*.cfm'
  -> (no output)  ZERO executable phonebook references  [PASS]

# any 'phonebook' token in code dirs
git grep -in phonebook -- services/** include/** app/** ajax/** sched/** share/**
  services/AuditionImportService.cfc:1616:  //    WO-PHONEBOOK -- it referenced a nonexistent 'phonebook' table and threw
  services/AuditionImportService.cfc:1618:  //    2026-03-12. See docs/plans/evidence/2026-07-03-wo-phonebook-recon.md.)
```

**Read explicitly (so a full grep isn't misread):** the executable `INNER JOIN phonebook`
query is gone — zero SQL/table references remain in any code path. The only surviving
code-file hits are the **two intentional tombstone-comment lines** I added (they name the
WO and the recon-doc filename, both of which contain the substring "phonebook"). Beyond
code, the deliberate doc/drift references survive by design in
`database/claude-projects/{09,03,04}-*schema*.md` (the annotated phantom row #153) and the
`docs/plans/**` WO/evidence set. A raw `git grep phonebook` therefore returns these
intentional references — that is expected and correct, not a leak.

## 4. DEV-PROOF runbook (Kevin executes on `abod`) — SELF-HEAL BLOCK ORDERED FIRST

All on dev (`new_development` / datasource `abod`). CC authors; Kevin runs. Parameterize
`:JOB_ID`, `:uid`. Order is deliberate: capture the live failure BEFORE deploying the fix,
then prove the existing finalize self-heal (plan item 4 / Block B) clears it.

### Phase 0 — PRE-DEPLOY failure capture (run BEFORE deploying the code change)
```sql
-- P0.1 rows currently failing on the phonebook signature (the smoking gun)
SELECT row_id, job_id, status, LEFT(import_error,200) AS import_error, updated_at
FROM import_auditions_rows
WHERE import_error LIKE '%phonebook%' OR import_error LIKE '%doesn''t exist%'
ORDER BY updated_at DESC;

-- P0.2 same signature on the result table
SELECT result_id, job_id, row_id, error_code, LEFT(error_message,200) AS error_message, created_at
FROM import_auditions_row_results
WHERE error_message LIKE '%phonebook%' OR error_message LIKE '%ER_NO_SUCH_TABLE%'
ORDER BY created_at DESC;
```
Record a target **`:JOB_ID`** that has phonebook-failed email-bearing rows (this is the
job re-finalized in Phase 2). If P0 returns zero (clean dev), skip to Phase F to synthesize
email-bearing rows, then use that job as `:JOB_ID`.

### Phase 1 — DEPLOY the fix on `abod`
Deploy the edited `services/AuditionImportService.cfc`; confirm the code-scoped grep
(section 3) returns zero executable references on the deployed tree.

### Phase 2 — RE-FINALIZE the same job -> Block-B self-heal assertions
Re-run finalize for `:JOB_ID`. `finalizeJob` Block B (`:1416-1428`) resets the prior
`status='failed'` / `created_audition_id IS NULL` rows to `'ready'` and NULLs
`import_error`; Block C re-selects them; the row now clears the (deleted) email block and
imports.
```sql
-- B.1 previously-failed rows imported cleanly, no phonebook residue
SELECT row_id, status, LEFT(import_error,200) AS import_error, created_audition_id
FROM import_auditions_rows WHERE job_id = :JOB_ID ORDER BY row_num;
--   expect: status='imported', import_error IS NULL, created_audition_id NOT NULL

-- B.2 result rows flipped failed -> created (E6 upsert)
SELECT row_id, action_taken, error_code
FROM import_auditions_row_results WHERE job_id = :JOB_ID ORDER BY row_id;
--   expect: action_taken='created', error_code IS NULL

-- B.3 no double-insert (UNIQUE(row_id) holds; audition created once)
SELECT row_id, COUNT(*) AS n FROM import_auditions_row_results
WHERE job_id = :JOB_ID GROUP BY row_id HAVING COUNT(*) > 1;
--   expect: empty
```

### Phase F — Fresh four-class fixture (regression + name-linkage, from plan item 6)
Import a fixture with: (1) email + matching name, (2) email + non-matching name,
(3) email only/no name, (4) email-less control (name matches). Approve all, finalize.
```sql
SELECT row_id, status, LEFT(import_error,120) AS import_error FROM import_auditions_rows
WHERE job_id = :JOB_ID ORDER BY row_num;                      -- all 'imported', import_error NULL
SELECT userid, project_name, contactid FROM auditions
WHERE userid = :uid ORDER BY audition_id DESC LIMIT 8;
--   class 1: contactid = matched contact;  classes 2 & 3: contactid NULL (row present);
--   class 4: contactid by name = unchanged vs pre-fix.
SELECT ap.audprojectid, ap.contactid FROM audprojects ap
WHERE ap.audprojectid IN (SELECT created_audition_id FROM import_auditions_rows
                          WHERE job_id=:JOB_ID AND created_audition_id IS NOT NULL);
```

### Pass criteria
1. Section-3 grep: zero executable phonebook references on the deployed tree.
2. Phase 2: B.1/B.2/B.3 all as expected — the previously phonebook-failed rows self-heal
   and import; no residue; no double-insert.
3. Phase F: classes 1-3 (email-bearing) import with no `IMPORT_EXCEPTION` (all failed
   pre-fix); class 1 links by name; classes 2/3 import NULL; class 4 unchanged.
4. Outputs pasted into the proof bundle.

## 5. Commit-scope preview (NO COMMIT THIS TURN)

- **Commit 1 (code):** `services/AuditionImportService.cfc` ONLY — delete-only removal of
  the dead phonebook email-resolution block + name-only tombstone comment. Single hunk;
  isolation via `git show`/`git diff -- services/AuditionImportService.cfc`. The reverted
  line-1 corruption is a no-op vs HEAD and is not in this commit.
- **`docs/plans/**` evidence disposition:** `2026-07-03-wo-phonebook-recon.md`,
  `-plan.md`, and this `-phase-I.md` are untracked working evidence. Declared disposition:
  NOT bundled into commit 1 — either (a) a separate `docs:` evidence commit at
  proof-bundle review, or (b) left untracked as working evidence. Kevin's call at review.
- **Out of scope / stay unstaged:** the merge-repoint files (`services/ContactDuplicateService.cfc`,
  `include/*`, `app/contact-duplicates/*`), the role-doc/drift docs commit (still held on
  the 00-twin adjudication), `WO0-PROOF-BUNDLE.md`, `database/migrations/*`. None are
  staged.

## 6. Owed / registered (unchanged)
- Probes 4a'/4b still owed from Kevin — priority-setting only (hotfix vs normal deploy);
  they change zero lines of this fix. On paste, append interpretation to the recon doc:
  **zero hits = INCONCLUSIVE, not exoneration** — the row-level swallow is proven, so
  absence of tickets proves nothing.
- WO-PHONEBOOK-A (contactitems email resolution) stays registered: gated on unified
  matcher semantics from items 1/5A, weighted by 4b volume.

**STOP — awaiting Kevin's `abod` runbook outputs. Commit authorization at proof-bundle
review; isolation via `git show` against the declared staged set (commit 1 only).**
