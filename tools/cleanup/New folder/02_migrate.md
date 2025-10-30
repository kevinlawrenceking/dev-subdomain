Goal:
Replace all legacy /include/qry/*.cfm fetch pages with direct service method calls,
using the mapping defined in tools/cleanup/qry_map.csv.

Steps Claude should follow:

1) Confirm the environment:
   - You are operating inside a ColdFusion project.
   - The cleanup scripts are under /tools/cleanup.
   - The mapping file tools/cleanup/qry_map.csv exists and is filled out.

2) Run a dry-run replacement first to preview changes:
   Command:
     pwsh tools/cleanup/replace_includes.ps1 -DryRun
   - Review the console output.
   - For any “No mapping for ...” warnings, open the corresponding legacy .cfm file,
     identify the target service and method, and add a row to qry_map.csv.
   - Repeat until there are no warnings.

3) Apply the replacements:
   Command:
     pwsh tools/cleanup/replace_includes.ps1
   - This replaces every <cfinclude> pointing to /include/qry/*.cfm
     with a <cfset> call to the mapped service.method using the argument struct.
   - Backups (.bak) are created once per file for rollback safety.

4) Verify correctness:
   - Open several modified .cfm files.
   - Confirm that each new line reads like:
       <cfset id = application.services.auditionSubmitSiteUserService.createAuditionSubmitSiteUser({
         submitsitename = new_submitsitename,
         catlist        = sortedCatList,
         userid         = userid
       })>
   - Ensure no <cfinclude template="/include/qry/..."> remains.

5) Commit and push:
   Commands:
     git checkout -b refactor/replace-includes-batch1
     git add .
     git commit -m "Replace legacy /include/qry includes with service calls (batch 1)"
     git push -u origin refactor/replace-includes-batch1
   - Open a Pull Request titled “Refactor: replace legacy includes (batch 1)”.
   - Verify the CI pipeline passes (no /qry includes found, no SQL outside /services).

6) Post-migration cleanup:
   - Run find_orphans.ps1 to identify unused fetch files:
       pwsh tools/cleanup/find_orphans.ps1
   - Review tools/cleanup/orphans.txt.
   - Delete or allow the Auto Clean workflow to open a PR removing them.

Deliverables:
- Updated .cfm pages with direct service calls.
- Updated tools/cleanup/qry_map.csv.
- tools/cleanup/orphans.txt listing candidates for deletion.
- Pull request with CI passing and reviewed.

Important rules:
- Never create new /include/qry files.
- Keep changes small: one feature area or 10–20 includes per PR.
- All SQL stays inside /app/services.
- Maintain consistent naming and argument structure per CRUD conventions.
