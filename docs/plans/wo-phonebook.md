# WO-PHONEBOOK: AuditionImportService email-resolution references a nonexistent table

FIRST ACTION: save this WO verbatim to docs/plans/wo-phonebook.md (uncommitted). All
findings and probe results land in docs/plans/evidence/ with dated filenames. Gates:
Recon -> STOP -> Plan -> STOP -> Implement + Proof Bundle. Kevin holds commit auth.

## Established facts (do not re-derive)
- phonebook is ABSENT in every schema (prod information_schema sentinel,
  evidence/2026-07-03-merge-repoint-sqlpack.txt).
- AuditionImportService.cfc:1618-1630 INNER JOINs phonebook on the V3 audition-import
  email-resolution path, gated only by len(trim(contact_email)) > 0. Any email-bearing
  row reaching it throws ER_NO_SUCH_TABLE.
- tickets probe: zero phonebook references (superset LIKE '%phone%', 2026-07-03).
  INCONCLUSIVE — import-context onError routing to ErrorService is UNPROVEN.
- Corroboration: auditions has 55 rows, 0 with contactid — consistent with the
  resolution step never completing.
- 09-database-schema.md lists phonebook as table #153: known audit-doc drift; live
  sentinel wins.

## Phase R — Recon (STOP after; report findings table)
1. History: git log -S "phonebook" (and blame on :1618-1630). When was the join added,
   by which commit, and does any repo-history migration/DDL ever create phonebook?
   Verdict: never-functional vs orphaned-by-drop.
2. Intent: paste the block. What columns does it expect from phonebook, and what does
   the resolved value feed downstream (auditions.contactid? an xref? staging column)?
3. Swallow check: is :1618-1630 inside any cftry/cfcatch that would eat the exception?
   If yes, document what the user sees and what partial state results.
4. Exercise evidence — produce two SQL probes for Kevin (do not run against prod
   yourself):
   a. error_tickets probe: derive exact searchable columns from ErrorService.cfc's
      INSERT list plus 2026-04-17_error_tickets_add_root_cause.sql; emit
      LIKE '%phonebook%' across message/detail/root_cause columns.
   b. Staging probe: identify where audition-import rows stage; emit counts of rows
      with non-empty contact_email (all-time, and distinct import jobs affected).
5. Failure-mode trace: in the two-phase import, does the throw hit Stage or Finalize?
   Partial-write and idempotency risk statement (NN#8/NN#9).
PRIORITY TRIGGER: if 4a hits or 4b shows email-bearing rows are routinely attempted,
flag for upgrade to hotfix — Kevin decides.

## Phase P — Plan (STOP after)
Choose with evidence, do not default:
- Option A (contactitems resolution): match on valueCategory='Email', itemStatus
  active, isDeleted=0, userid-scoped; tie-break deterministic (primary_yn='Y' first,
  then lowest itemID); explicit no-match path (leave contactid NULL, row still imports).
  Address the shared-email hazard: multiple contacts per email must not misassign.
- Option B (delete dead block): only if Phase R proves the output feeds nothing that
  survives today.
- Rejected default: guard-and-log around a broken join.
Plan must state transaction posture and idempotent re-run behavior for the touched
import step.

## Phase I — Implement + Proof Bundle
- Diff with file:line anchors; isolation via git show of staged diff.
- Dev acceptance: import fixture with email-bearing rows completes; contactid resolved
  where a matching contact exists; clean no-match; email-less import regression
  unchanged; grep proves zero phonebook references remain in the repo.
- Runbook pattern: CC authors DEV-PROOF steps + parameterized SQL; Kevin executes.

## Out of scope — register, do not action
- Import-v3 architecture changes beyond this block; phone-formatting tickets
  (1636/1616); master-directory linkage; audition-import feature work.
