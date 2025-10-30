Goal:
Identify and remove legacy /include/qry/*.cfm files that are no longer referenced
anywhere in the application.

These are “orphan” files—safe to delete once all includes using them have been
replaced with service calls.

Steps Claude should follow:

1) Confirm environment:
   - You are in the root of the project.
   - The tools/cleanup/find_orphans.ps1 script exists.
   - Ripgrep (rg) is installed and available in PATH.

2) Generate orphan list:
   Command:
     pwsh tools/cleanup/find_orphans.ps1
   Behavior:
     - Scans /app and /cfm for any include statements referencing /qry/.
     - Compares results to the actual files under /include/qry/.
     - Outputs the list of unused .cfm files to tools/cleanup/orphans.txt.

3) Review results:
   - Open tools/cleanup/orphans.txt.
   - Verify that each file listed is truly obsolete.
   - Remove any false positives you still need.

4) Stage safe deletions:
   - Limit deletions to 10 files per PR to keep diffs readable.
   Command (manual):
     Get-Content tools/cleanup/orphans.txt | Select-Object -First 10 | ForEach-Object { git rm $_ }
   or let the Auto Clean workflow handle this automatically:
     - Workflow file: .github/workflows/auto-clean.yml
     - It runs nightly and opens a PR labeled "auto-cleanup" deleting up to 10 orphans.

5) Commit and push (if manual):
   Commands:
     git checkout -b refactor/delete-orphaned-qry
     git commit -m "Remove orphaned /include/qry files (batch 1)"
     git push -u origin refactor/delete-orphaned-qry
   - Open a Pull Request and verify CI passes (no /qry includes remaining).

6) Verify cleanup:
   - Run again:
       pwsh tools/cleanup/find_orphans.ps1
   - If tools/cleanup/orphans.txt is empty, that module’s cleanup is complete.
   - Keep this file in version control as an audit record of what was removed.

Deliverables:
- tools/cleanup/orphans.txt showing removed files.
- Pull request that deletes the confirmed orphans.
- Passing CI (no /qry includes detected).

Rules:
- Never delete /qry files that are still referenced.
- Each deletion PR should include a link or note to the prior migration batch
  confirming replacements were successful.
- The Auto Clean workflow should only act when orphans.txt is non-empty.
- Do not remove scripts or prompts inside /tools/cleanup.

Outcome:
After successful execution of this step, the /include/qry directory should contain
only files that are still in active use. When orphans.txt is empty for multiple runs,
the directory can be archived or removed entirely.
