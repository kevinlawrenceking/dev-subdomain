You are refactoring a ColdFusion app to remove /include/qry fetch pages and standardize on CFC services with CRUD methods. Rules:
- No new fetch pages. Delete legacy includes after replacement.
- All SQL must be queryExecute with typed params and datasource application.datasource.
- Call sites must use application.services.<service>.<method>(...).
- Service method names follow CRUD. Specials require concrete verbs.
- Keep changes atomic. Open small PRs with mapping and tests.
Commands to run are documented under /tools/cleanup. Start with 01_inventory.md.
