Goal:
Consolidate service functions into canonical CRUD + explicit specials.
Rename methods, update call sites, and standardize signatures and SQL.

Inputs:
- /app/services/*.cfc
- Naming rules in README_naming_rules.md
- Project DSN: application.datasource = "reach"

Output:
- CRUD-only service surfaces per resource
- Updated call sites
- Deprecation notes
- One small PR per resource

Rules:
1) Allowed canonical methods per resource:
   - create<Resource>(data) -> numeric id or struct
   - get<Resource>(id) -> struct or {}
   - list<ResourcePlural>(filters={offset,limit,userid,status,search,sort}) -> query (repo-wide standard)
   - update<Resource>(id, data) -> boolean
   - delete<Resource>(id) -> boolean (soft delete preferred)
2) Specials allowed: <verb><Resource>(...) with concrete verbs only.
3) All SQL uses queryExecute with typed params and application.datasource.
4) No <cfquery> tags. No includes. No dynamic SQL concatenation.
5) Small, atomic PRs. One resource per PR.

Steps:

A) Inventory methods in a target service
   - Open one file under /app/services, e.g., AuditionSubmitSiteUserService.cfc.
   - List all functions with names and signatures.
   - Classify each into one bucket: create|get|list|update|delete|special.

B) Propose rename map
   - Use these regex normalizations:
     INS|ADD|CREATE          -> create
     UPD|UPDATE|SET          -> update
     DEL|RM|DELETE           -> delete
     GET.*BYID               -> get
     (GET|LIST|FIND)(?!.*BYID) -> list
   - Build a table:
     fromName, toName, notes (merged? params reshaped?)

C) Consolidate list methods
   - Merge variants like listByUser, listActive, findX into list<ResourcePlural>(filters).
   - Implement optional filters with default {}.
   - Example filter handling pattern:
     - Build WHERE clauses conditionally.
     - Accept offset, limit, sort with sane defaults.

D) Normalize create/update signatures
   - create<Resource>(data) with a struct `data`.
   - update<Resource>(id, data) with scalar id + struct `data`.
   - Map legacy arguments to fields inside data.
   - Return types:
     - create -> inserted id (prefer OUTPUT INSERTED.id)
     - update -> true if executed; optionally check rowcount

E) Soft delete standard
   - delete<Resource>(id): set IsDeleted=1 if column exists.
   - If no IsDeleted, perform hard delete only with explicit product decision.
   - Add TODO in code comment if schema change is required.

F) Update call sites
   - Use application.services.<service>.<method>(...).
   - Convert scattered scalar args into struct literals for create/update.
   - For list, convert ad-hoc args to a single filters struct.

G) Document specials
   - Keep only necessary non-CRUD functions.
   - Name as <verb><Resource>.
   - Add a Javadoc block: @since, purpose, inputs, side effects.

H) Add minimal tests (if tests present)
   - One spec per service with create/get/update/delete smoke flow.
   - For list, assert it returns a query and respects basic filters.

I) CI checks
   - Ensure no <cfquery> and that only queryExecute exists in services.
   - Ensure no remaining references to removed method names.

J) Deprecations
   - For each removed or renamed method, add a deprecation note in the PR description:
     - oldName -> newName
     - example call-site migration
   - If needed temporarily, keep a thin wrapper that calls the new method, then remove in a later PR.

Commands Claude should run:

1) Create a rename report (manual prep):
   - Scan the chosen CFC and write a table in the PR body:
     | from | to | type | notes |

2) Update the CFC:
   - Rename functions to canonical names.
   - Merge list variants using filters.
   - Replace <cfquery> with queryExecute and typed params.
   - Ensure `datasource: application.datasource` is set.

3) Update call sites:
   - rg preview:
       rg -n "<serviceName>\." ./app
   - Replace old method names with new ones.
   - Reshape args to struct for create/update.

4) Self-checks:
   - rg -n "(<cfquery\b)" ./app/services  -> must be 0
   - rg -n "application\.services\.<serviceName>\.(oldName)" ./app -> must be 0
   - Build/run tests if present.

5) Commit and PR:
   - Branch: refactor/crud-<resource>
   - Commit with concise summary and the rename table.
   - Push and open PR. Verify CI green.

Templates:

Create (sample)
---------------
public numeric function createAuditionSubmitSiteUser(required struct data) {
  var q = queryExecute(
    "INSERT INTO audsubmitsites_user (submitsitename, catlist, userid)
     OUTPUT INSERTED.id
     VALUES (:name, :catlist, :userid)",
    {
      name:   {value: data.submitsitename, cfsqltype: "cf_sql_varchar"},
      catlist:{value: data.catlist,        cfsqltype: "cf_sql_varchar"},
      userid: {value: data.userid,         cfsqltype: "cf_sql_integer"}
    },
    {datasource: application.datasource}
  );
  return q[1].id;
}

List with filters (sample)
--------------------------
public query function listAuditionSubmitSiteUsers(struct filters={}) {
  var f = structNew();
  f.userid = structKeyExists(filters,"userid") ? filters.userid : javacast("null","");
  f.status = structKeyExists(filters,"status") ? filters.status : javacast("null","");
  f.search = structKeyExists(filters,"search") ? "%#filters.search#%" : javacast("null","");
  f.offset = structKeyExists(filters,"offset") ? filters.offset : 0;
  f.limit  = structKeyExists(filters,"limit")  ? filters.limit  : 50;

  var sql = "
    SELECT id, submitsitename, catlist, userid
      FROM audsubmitsites_user
     WHERE IsDeleted = 0
       AND (:userid IS NULL OR userid = :userid)
       AND (:status IS NULL OR status = :status)
       AND (:search IS NULL OR submitsitename LIKE :search)
     ORDER BY id DESC
     OFFSET :offset ROWS FETCH NEXT :limit ROWS ONLY
  ";

  return queryExecute(
    sql,
    {
      userid:{value:f.userid, cfsqltype:"cf_sql_integer", null=f.userid EQ javacast('null','')},
      status:{value:f.status, cfsqltype:"cf_sql_varchar", null=NOT structKeyExists(filters,'status')},
      search:{value:f.search, cfsqltype:"cf_sql_varchar", null=NOT structKeyExists(filters,'search')},
      offset:{value:f.offset, cfsqltype:"cf_sql_integer"},
      limit:{value:f.limit,  cfsqltype:"cf_sql_integer"}
    },
    {datasource: application.datasource}
  );
}

Update (sample)
---------------
public boolean function updateAuditionSubmitSiteUser(required numeric id, required struct data) {
  queryExecute(
    "UPDATE audsubmitsites_user
        SET submitsitename = :name,
            catlist = :catlist
      WHERE id = :id",
    {
      id:     {value:id, cfsqltype:"cf_sql_integer"},
      name:   {value:data.submitsitename, cfsqltype:"cf_sql_varchar"},
      catlist:{value:data.catlist,        cfsqltype:"cf_sql_varchar"}
    },
    {datasource: application.datasource}
  );
  return true;
}

Delete (sample)
---------------
public boolean function deleteAuditionSubmitSiteUser(required numeric id) {
  queryExecute(
    "UPDATE audsubmitsites_user SET IsDeleted = 1 WHERE id = :id",
    { id:{value:id, cfsqltype:"cf_sql_integer"} },
    { datasource: application.datasource }
  );
  return true;
}

PR checklist:
- [ ] Rename map table in description
- [ ] All call sites updated
- [ ] No <cfquery> tags remain in the service
- [ ] Tests added/updated (if test suite exists)
- [ ] CI green
