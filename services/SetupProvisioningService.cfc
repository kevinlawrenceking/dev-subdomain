<cfcomponent displayname="SetupProvisioningService"
    hint="Idempotently ensures a user's per-user enum/lookup tables are populated from the master tables. Safe to call repeatedly (e.g. at initial login). Mirrors the sync logic in /setup/user_setup_core.cfm but is keyed only on userid and returns a structured matrix of results.">

    <!--- ================================================================
         init -- optional DSN override (defaults to application.dsn)
    ================================================================ --->
    <cffunction name="init" access="public" returntype="SetupProvisioningService" output="false">
        <cfargument name="dsn" type="string" required="false" default="">
        <cfset variables.dsn = len(trim(arguments.dsn)) ? arguments.dsn : application.dsn>
        <cfreturn this>
    </cffunction>

    <!--- Lazy DSN getter so the component also works without an explicit init() --->
    <cffunction name="getDSN" access="private" returntype="string" output="false">
        <cfif not structKeyExists(variables, "dsn") or not len(trim(variables.dsn))>
            <cfset variables.dsn = application.dsn>
        </cfif>
        <cfreturn variables.dsn>
    </cffunction>

    <!--- ================================================================
         Matrix definition -- the 16 per-user tables, their master source,
         the effective master filter (matching user_setup_core.cfm), and
         whether master/user counts are expected to match exactly.
         "exact=false" tables are derived (joins/dynamic panels) where a
         non-zero count is the success signal rather than an equal count.
    ================================================================ --->
    <cffunction name="getMatrixTables" access="private" returntype="array" output="false">
        <cfreturn [
            {name="auddialects_user",        desc="Audition Dialects",       master="auddialects",          where="isdeleted = 0", exact=true},
            {name="audgenres_user",          desc="Audition Genres",         master="audgenres",            where="isdeleted = 0", exact=true},
            {name="audnetworks_user",        desc="Audition Networks",       master="audnetworks",          where="isdeleted = 0", exact=true},
            {name="audopencalloptions_user", desc="Open Call Options",       master="audopencalloptions",   where="1=1",           exact=true},
            {name="audplatforms_user",       desc="Audition Platforms",      master="audplatforms",         where="isdeleted = 0", exact=true},
            {name="audtones_user",           desc="Audition Tones",          master="audtones",             where="isdeleted = 0", exact=true},
            {name="eventtypes_user",         desc="Event Types",             master="eventtypes",           where="1=1",           exact=true},
            {name="genderpronouns_users",    desc="Gender Pronouns",         master="genderpronouns",       where="1=1",           exact=true},
            {name="itemtypes_user",          desc="Item Types",              master="itemtypes",            where="isdeleted = 0", exact=true},
            {name="tags_user",               desc="Tags",                    master="tags",                 where="1=1",           exact=true},
            {name="sitetypes_user",          desc="Site Types",              master="sitetypes_master",     where="isdeleted = 0", exact=true},
            {name="audquestions_user",       desc="Audition Questions",      master="audquestions_default", where="isdeleted = 0", exact=false},
            {name="audsubmitsites_user",     desc="Audition Submit Sites",   master="audsubmitsites",       where="1=1",           exact=true},
            {name="itemcatxref_user",        desc="Item Category XRef",      master="itemcatxref",          where="1=1",           exact=false},
            {name="pgpanels_user",           desc="Dashboard Panels",        master="pgpanels_master",      where="1=1",           exact=false},
            {name="sitelinks_user_tbl",      desc="Site Links",              master="sitelinks_master",     where="1=1",           exact=false}
        ]>
    </cffunction>

    <!--- ================================================================
         PUBLIC: ensureUserRecords(userid)
         The one entry point. Validates the user, snapshots counts, runs
         every sync step (each isolated so one failure cannot abort the
         rest), then returns a matrix of before/inserted/after vs master.
    ================================================================ --->
    <cffunction name="ensureUserRecords" access="public" returntype="struct" output="false">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="skipIfComplete" type="boolean" required="false" default="false"
                    hint="When true, run only the cheap count check first and skip the full heal if the user is already fully provisioned. Great for fast batch re-runs.">

        <cfset var local = {}>
        <cfset local.dsn = getDSN()>
        <cfset local.uid = val(arguments.userid)>
        <cfset local.result = {
            success    = false,
            message    = "",
            data       = {
                userid        = local.uid,
                dsn           = local.dsn,
                matrix        = [],
                totalInserted = 0,
                issues        = [],
                complete      = false,
                skipped       = false
            }
        }>

        <!--- Guard: valid userid --->
        <cfif local.uid LTE 0>
            <cfset local.result.message = "Invalid userid.">
            <cfreturn local.result>
        </cfif>

        <!--- Guard: user must exist. taousers is the active-users view (matches
              user_setup_core.cfm usage), so no extra isdeleted filter is needed. --->
        <cftry>
            <cfset local.qUser = queryExecute(
                "SELECT userid FROM taousers WHERE userid = ?",
                [local.uid], {datasource = local.dsn})>
            <cfif local.qUser.recordCount EQ 0>
                <cfset local.result.message = "User #local.uid# not found.">
                <cfreturn local.result>
            </cfif>
            <cfcatch type="any">
                <cfset local.result.message = "User lookup failed: " & cfcatch.message>
                <cfreturn local.result>
            </cfcatch>
        </cftry>

        <cfset local.tables = getMatrixTables()>

      <!--- Orchestration is fully isolated: this must never throw to a caller
            (it may run on the login path). Per-step helpers also self-contain
            their errors; this outer guard covers anything unexpected. --->
      <cftry>
        <!--- Snapshot BEFORE counts (per-user) and MASTER expected counts --->
        <cfset local.before = countUserTables(local.uid, local.tables, local.dsn)>
        <cfset local.master = countMasterTables(local.tables, local.dsn)>

        <!--- Fast path: if already complete, skip the (expensive) heal entirely.
              The heal does a per-master-row existence check, so skipping a
              complete user turns minutes of work into ~16 cheap COUNT(*)s. --->
        <cfif arguments.skipIfComplete AND countsAreComplete(local.before, local.master, local.tables)>
            <cfset buildMatrix(local.result, local.tables, local.before, local.before, local.master)>
            <cfset local.result.data.complete = true>
            <cfset local.result.data.skipped  = true>
            <cfset local.result.success = true>
            <cfset local.result.message = "Already complete -- skipped (no heal run).">
            <cfreturn local.result>
        </cfif>

        <!---
            Run syncs in dependency order:
              1. itemtypes_user + sitetypes_user + pgpanels_user first
                 (itemcatxref/sitelinks/panels depend on them)
              2. remaining simple + category lookups
              3. special-case tables
              4. derived tables (xref, sitelinks, panels)
              5. tag property updates + contact backfill
            Each call swallows its own errors via syncLookup/special helpers.
        --->
        <cfset syncLookup(local.uid, "itemtypes",        "itemtypes_user",   "valuetype",     "typeicon",            "isdeleted = 0", local.dsn)>
        <cfset syncLookup(local.uid, "sitetypes_master", "sitetypes_user",   "sitetypename",  "sitetypedescription", "isdeleted = 0", local.dsn)>
        <cfset syncLookup(local.uid, "tags",             "tags_user",        "tagname",       "",                    "1=1",           local.dsn)>
        <cfset syncPanels(local.uid, local.dsn)>

        <cfset syncLookup(local.uid, "audopencalloptions", "audopencalloptions_user", "opencallname",  "",               "1=1",           local.dsn)>
        <cfset syncLookup(local.uid, "eventtypes",         "eventtypes_user",         "eventTypeName", "eventtypedescription", "1=1",     local.dsn)>
        <cfset syncLookup(local.uid, "genderpronouns",     "genderpronouns_users",    "genderpronoun", "genderpronounplural",  "1=1",     local.dsn)>
        <cfset syncLookup(local.uid, "audplatforms",       "audplatforms_user",       "audplatform",   "",               "isdeleted = 0", local.dsn)>

        <cfset syncLookupWithCategory(local.uid, "auddialects", "auddialects_user", "auddialect", "audcatid", "isdeleted = 0", local.dsn)>
        <cfset syncLookupWithCategory(local.uid, "audgenres",   "audgenres_user",   "audgenre",   "audcatid", "isdeleted = 0", local.dsn)>
        <cfset syncLookupWithCategory(local.uid, "audnetworks", "audnetworks_user", "network",    "audcatid", "isdeleted = 0", local.dsn)>
        <cfset syncLookupWithCategory(local.uid, "audtones",    "audtones_user",    "tone",       "audcatid", "isdeleted = 0", local.dsn)>

        <cfset syncAudQuestions(local.uid, local.dsn)>
        <cfset syncAudSubmitSites(local.uid, local.dsn)>
        <cfset syncItemCatXref(local.uid, local.dsn)>
        <cfset syncSiteLinks(local.uid, local.dsn)>
        <cfset syncSiteTypePanels(local.uid, local.dsn)>
        <cfset updateTagProperties(local.uid, local.dsn)>
        <cfset ensureUserContact(local.uid, local.dsn)>

        <!--- Snapshot AFTER counts and build the matrix --->
        <cfset local.after = countUserTables(local.uid, local.tables, local.dsn)>
        <cfset buildMatrix(local.result, local.tables, local.before, local.after, local.master)>
        <cfset local.totalInserted = local.result.data.totalInserted>
        <cfset local.result.success = true>
        <cfset local.result.message = local.result.data.complete
                ? "All user tables populated (#local.totalInserted# record(s) inserted)."
                : "Provisioning ran; #arrayLen(local.result.data.issues)# table(s) still flagged (#local.totalInserted# inserted).">

        <!--- Audit log -- mirrors user_setup_core provisioning logging --->
        <cftry>
            <cfif local.result.data.complete>
                <cflog file="TAO_setup_provisioning" type="information"
                    text="ensureUserRecords userid=#local.uid# | inserted=#local.totalInserted# | status=complete">
            <cfelse>
                <cflog file="TAO_setup_errors" type="warning"
                    text="ensureUserRecords userid=#local.uid# | inserted=#local.totalInserted# | issues=#arrayToList(local.result.data.issues)#">
            </cfif>
            <cfcatch type="any"><!--- never let logging break the caller ---></cfcatch>
        </cftry>

        <cfcatch type="any">
            <!--- Unexpected orchestration failure -- degrade gracefully --->
            <cfset local.result.success = false>
            <cfset local.result.message = "Provisioning aborted: " & cfcatch.message>
            <cftry>
                <cflog file="TAO_setup_errors" type="error"
                    text="ensureUserRecords FATAL userid=#local.uid# err=#cfcatch.message#">
                <cfcatch type="any"></cfcatch>
            </cftry>
        </cfcatch>
      </cftry>

        <cfreturn local.result>
    </cffunction>

    <!--- ================================================================
         Status for one table given its user count vs master expectation.
         exact=false tables are "OK" on any non-zero count.
    ================================================================ --->
    <cffunction name="rowStatus" access="private" returntype="string" output="false">
        <cfargument name="after"  type="numeric" required="true">
        <cfargument name="master" type="numeric" required="true">
        <cfargument name="exact"  type="boolean" required="true">
        <cfif arguments.after EQ -1 OR arguments.master EQ -1>
            <cfreturn "ERROR">
        <cfelseif arguments.after EQ 0 AND (arguments.master GT 0 OR NOT arguments.exact)>
            <cfreturn "EMPTY">
        <cfelseif arguments.exact AND arguments.master GT 0 AND arguments.after LT arguments.master>
            <cfreturn "SHORT">
        </cfif>
        <cfreturn "OK">
    </cffunction>

    <!--- True only when every table is OK (used for the skip-if-complete check). --->
    <cffunction name="countsAreComplete" access="private" returntype="boolean" output="false">
        <cfargument name="counts" type="struct" required="true">
        <cfargument name="master" type="struct" required="true">
        <cfargument name="tables" type="array"  required="true">
        <cfset var t = "">
        <cfloop array="#arguments.tables#" index="t">
            <cfif rowStatus(arguments.counts[t.name], arguments.master[t.name], t.exact) NEQ "OK">
                <cfreturn false>
            </cfif>
        </cfloop>
        <cfreturn true>
    </cffunction>

    <!--- Populate result.data.matrix / issues / totalInserted / complete from
          before/after/master count maps. Mutates the passed-in result struct. --->
    <cffunction name="buildMatrix" access="private" returntype="void" output="false">
        <cfargument name="result" type="struct" required="true">
        <cfargument name="tables" type="array"  required="true">
        <cfargument name="before" type="struct" required="true">
        <cfargument name="after"  type="struct" required="true">
        <cfargument name="master" type="struct" required="true">

        <cfset var local = {totalInserted = 0}>
        <cfloop array="#arguments.tables#" index="local.t">
            <cfset local.b = arguments.before[local.t.name]>
            <cfset local.a = arguments.after[local.t.name]>
            <cfset local.m = arguments.master[local.t.name]>
            <cfset local.ins = (local.a GTE 0 AND local.b GTE 0) ? (local.a - local.b) : 0>
            <cfif local.ins GT 0><cfset local.totalInserted += local.ins></cfif>
            <cfset local.status = rowStatus(local.a, local.m, local.t.exact)>
            <cfif local.status NEQ "OK">
                <cfset arrayAppend(arguments.result.data.issues, local.t.name)>
            </cfif>
            <cfset arrayAppend(arguments.result.data.matrix, {
                table       = local.t.name,
                description = local.t.desc,
                master      = local.m,
                before      = local.b,
                inserted    = local.ins,
                after       = local.a,
                status      = local.status
            })>
        </cfloop>
        <cfset arguments.result.data.totalInserted = local.totalInserted>
        <cfset arguments.result.data.complete = (arrayLen(arguments.result.data.issues) EQ 0)>
    </cffunction>

    <!--- ================================================================
         COUNT HELPERS
    ================================================================ --->
    <cffunction name="countUserTables" access="private" returntype="struct" output="false">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="tables" type="array"   required="true">
        <cfargument name="dsn"    type="string"  required="true">
        <cfset var local = {counts = {}}>
        <cfloop array="#arguments.tables#" index="local.t">
            <cftry>
                <cfset local.q = queryExecute(
                    "SELECT COUNT(*) AS c FROM " & local.t.name & " WHERE userid = ?",
                    [arguments.userid], {datasource = arguments.dsn})>
                <cfset local.counts[local.t.name] = local.q.c>
                <cfcatch type="any">
                    <cfset local.counts[local.t.name] = -1>
                </cfcatch>
            </cftry>
        </cfloop>
        <cfreturn local.counts>
    </cffunction>

    <cffunction name="countMasterTables" access="private" returntype="struct" output="false">
        <cfargument name="tables" type="array"  required="true">
        <cfargument name="dsn"    type="string" required="true">
        <cfset var local = {counts = {}}>
        <cfloop array="#arguments.tables#" index="local.t">
            <cftry>
                <cfset local.q = queryExecute(
                    "SELECT COUNT(*) AS c FROM " & local.t.master &
                    (len(local.t.where) ? " WHERE " & local.t.where : ""),
                    [], {datasource = arguments.dsn})>
                <cfset local.counts[local.t.name] = local.q.c>
                <cfcatch type="any">
                    <cfset local.counts[local.t.name] = -1>
                </cfcatch>
            </cftry>
        </cfloop>
        <cfreturn local.counts>
    </cffunction>

    <!--- ================================================================
         GENERIC LOOKUP SYNC (value + optional extra fields)
         Mirrors syncLookupTable() in user_setup_core.cfm.
    ================================================================ --->
    <cffunction name="syncLookup" access="private" returntype="numeric" output="false">
        <cfargument name="userid"           type="numeric" required="true">
        <cfargument name="masterTable"      type="string"  required="true">
        <cfargument name="userTable"        type="string"  required="true">
        <cfargument name="valueField"       type="string"  required="true">
        <cfargument name="additionalFields" type="string"  required="false" default="">
        <cfargument name="whereClause"      type="string"  required="false" default="isdeleted = 0">
        <cfargument name="dsn"              type="string"  required="true">

        <cfset var local = {inserted = 0}>
        <cftry>
            <cfset local.selectFields = arguments.valueField>
            <cfif len(arguments.additionalFields)>
                <cfset local.selectFields = listAppend(local.selectFields, arguments.additionalFields)>
            </cfif>

            <cfset local.master = queryExecute(
                "SELECT " & local.selectFields & " FROM " & arguments.masterTable &
                (len(arguments.whereClause) ? " WHERE " & arguments.whereClause : ""),
                [], {datasource = arguments.dsn})>

            <cfloop query="local.master">
                <cfset local.checkParams = [local.master[arguments.valueField][local.master.currentRow], arguments.userid]>
                <cfset local.chk = queryExecute(
                    "SELECT COUNT(*) AS c FROM " & arguments.userTable &
                    " WHERE " & arguments.valueField & " = ? AND userid = ?",
                    local.checkParams, {datasource = arguments.dsn})>

                <cfif local.chk.c EQ 0>
                    <cfset local.fields = arguments.valueField & ", userid">
                    <cfset local.placeholders = "?, ?">
                    <cfset local.insParams = [local.master[arguments.valueField][local.master.currentRow], arguments.userid]>

                    <cfif len(arguments.additionalFields)>
                        <cfloop list="#arguments.additionalFields#" index="local.f">
                            <cfif listFindNoCase(local.master.columnList, local.f)>
                                <cfset local.fields = listAppend(local.fields, local.f)>
                                <cfset local.placeholders = listAppend(local.placeholders, "?")>
                                <cfset arrayAppend(local.insParams, local.master[local.f][local.master.currentRow])>
                            </cfif>
                        </cfloop>
                    </cfif>

                    <cfset queryExecute(
                        "INSERT INTO " & arguments.userTable & " (" & local.fields & ") VALUES (" & local.placeholders & ")",
                        local.insParams, {datasource = arguments.dsn})>
                    <cfset local.inserted++>
                </cfif>
            </cfloop>
            <cfcatch type="any">
                <cflog file="TAO_setup_errors" type="error"
                    text="syncLookup userid=#arguments.userid# #arguments.masterTable#->#arguments.userTable# err=#cfcatch.message#">
            </cfcatch>
        </cftry>
        <cfreturn local.inserted>
    </cffunction>

    <!--- ================================================================
         CATEGORY LOOKUP SYNC (value + audcatid pair)
         Mirrors syncLookupTableWithCategory() in user_setup_core.cfm.
    ================================================================ --->
    <cffunction name="syncLookupWithCategory" access="private" returntype="numeric" output="false">
        <cfargument name="userid"        type="numeric" required="true">
        <cfargument name="masterTable"   type="string"  required="true">
        <cfargument name="userTable"     type="string"  required="true">
        <cfargument name="valueField"    type="string"  required="true">
        <cfargument name="categoryField" type="string"  required="true">
        <cfargument name="whereClause"   type="string"  required="false" default="isdeleted = 0">
        <cfargument name="dsn"           type="string"  required="true">

        <cfset var local = {inserted = 0}>
        <cftry>
            <cfset local.master = queryExecute(
                "SELECT " & arguments.valueField & ", " & arguments.categoryField &
                " FROM " & arguments.masterTable &
                (len(arguments.whereClause) ? " WHERE " & arguments.whereClause : ""),
                [], {datasource = arguments.dsn})>

            <cfloop query="local.master">
                <cfset local.v = local.master[arguments.valueField][local.master.currentRow]>
                <cfset local.cat = local.master[arguments.categoryField][local.master.currentRow]>
                <cfset local.chk = queryExecute(
                    "SELECT COUNT(*) AS c FROM " & arguments.userTable &
                    " WHERE " & arguments.valueField & " = ? AND " & arguments.categoryField & " = ? AND userid = ?",
                    [local.v, local.cat, arguments.userid], {datasource = arguments.dsn})>

                <cfif local.chk.c EQ 0>
                    <cfset queryExecute(
                        "INSERT INTO " & arguments.userTable &
                        " (" & arguments.valueField & ", " & arguments.categoryField & ", userid) VALUES (?, ?, ?)",
                        [local.v, local.cat, arguments.userid], {datasource = arguments.dsn})>
                    <cfset local.inserted++>
                </cfif>
            </cfloop>
            <cfcatch type="any">
                <cflog file="TAO_setup_errors" type="error"
                    text="syncLookupWithCategory userid=#arguments.userid# #arguments.masterTable#->#arguments.userTable# err=#cfcatch.message#">
            </cfcatch>
        </cftry>
        <cfreturn local.inserted>
    </cffunction>

    <!--- ================================================================
         SPECIAL: audquestions_default -> audquestions_user
         Existence is keyed on qorder (matches user_setup_core.cfm).
    ================================================================ --->
    <cffunction name="syncAudQuestions" access="private" returntype="numeric" output="false">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="dsn"    type="string"  required="true">
        <cfset var local = {inserted = 0}>
        <cftry>
            <cfset local.master = queryExecute(
                "SELECT qtypeid, qtext, qorder FROM audquestions_default WHERE isdeleted = 0",
                [], {datasource = arguments.dsn})>
            <cfloop query="local.master">
                <cfset local.chk = queryExecute(
                    "SELECT COUNT(*) AS c FROM audquestions_user WHERE isdeleted = 0 AND qorder = ? AND userid = ?",
                    [local.master.qorder, arguments.userid], {datasource = arguments.dsn})>
                <cfif local.chk.c EQ 0>
                    <cfset queryExecute(
                        "INSERT INTO audquestions_user (qtypeid, qtext, qorder, userid) VALUES (?, ?, ?, ?)",
                        [local.master.qtypeid, local.master.qtext, local.master.qorder, arguments.userid],
                        {datasource = arguments.dsn})>
                    <cfset local.inserted++>
                </cfif>
            </cfloop>
            <cfcatch type="any">
                <cflog file="TAO_setup_errors" type="error"
                    text="syncAudQuestions userid=#arguments.userid# err=#cfcatch.message#">
            </cfcatch>
        </cftry>
        <cfreturn local.inserted>
    </cffunction>

    <!--- ================================================================
         SPECIAL: audsubmitsites -> audsubmitsites_user (carries catlist)
    ================================================================ --->
    <cffunction name="syncAudSubmitSites" access="private" returntype="numeric" output="false">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="dsn"    type="string"  required="true">
        <cfset var local = {inserted = 0}>
        <cftry>
            <cfset local.master = queryExecute(
                "SELECT submitsitename, catlist FROM audsubmitsites",
                [], {datasource = arguments.dsn})>
            <cfloop query="local.master">
                <cfset local.chk = queryExecute(
                    "SELECT COUNT(*) AS c FROM audsubmitsites_user WHERE submitsitename = ? AND userid = ?",
                    [local.master.submitsitename, arguments.userid], {datasource = arguments.dsn})>
                <cfif local.chk.c EQ 0>
                    <cfset queryExecute(
                        "INSERT INTO audsubmitsites_user (submitsitename, catlist, userid) VALUES (?, ?, ?)",
                        [local.master.submitsitename, local.master.catlist, arguments.userid],
                        {datasource = arguments.dsn})>
                    <cfset local.inserted++>
                </cfif>
            </cfloop>
            <cfcatch type="any">
                <cflog file="TAO_setup_errors" type="error"
                    text="syncAudSubmitSites userid=#arguments.userid# err=#cfcatch.message#">
            </cfcatch>
        </cftry>
        <cfreturn local.inserted>
    </cffunction>

    <!--- ================================================================
         SPECIAL: itemcatxref -> itemcatxref_user
         Remaps master typeid to the user's itemtypes_user.typeid via
         valuetype. Depends on itemtypes_user already being synced.
         Mirrors the complex join block in user_setup_core.cfm.
    ================================================================ --->
    <cffunction name="syncItemCatXref" access="private" returntype="numeric" output="false">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="dsn"    type="string"  required="true">
        <cfset var local = {inserted = 0}>
        <cftry>
            <cfset local.master = queryExecute(
                "SELECT DISTINCT c.catid, i.valuetype
                 FROM itemcategory c
                 INNER JOIN itemcatxref x ON x.catid = c.catid
                 INNER JOIN itemtypes i ON i.typeid = x.typeid
                 WHERE c.isdeleted = 0 AND i.isdeleted = 0",
                [], {datasource = arguments.dsn})>

            <cfloop query="local.master">
                <!--- Resolve this master valuetype to the user's typeid --->
                <cfset local.ut = queryExecute(
                    "SELECT typeid FROM itemtypes_user WHERE valuetype = ? AND userid = ?",
                    [local.master.valuetype, arguments.userid], {datasource = arguments.dsn})>
                <cfif local.ut.recordCount GT 0>
                    <cfset local.chk = queryExecute(
                        "SELECT COUNT(*) AS c FROM itemcatxref_user WHERE userid = ? AND typeid = ? AND catid = ?",
                        [arguments.userid, local.ut.typeid, local.master.catid], {datasource = arguments.dsn})>
                    <cfif local.chk.c EQ 0>
                        <cfset queryExecute(
                            "INSERT INTO itemcatxref_user (typeid, catid, userid) VALUES (?, ?, ?)",
                            [local.ut.typeid, local.master.catid, arguments.userid], {datasource = arguments.dsn})>
                        <cfset local.inserted++>
                    </cfif>
                </cfif>
            </cfloop>
            <cfcatch type="any">
                <cflog file="TAO_setup_errors" type="error"
                    text="syncItemCatXref userid=#arguments.userid# err=#cfcatch.message#">
            </cfcatch>
        </cftry>
        <cfreturn local.inserted>
    </cffunction>

    <!--- ================================================================
         SPECIAL: sitelinks_master -> sitelinks_user_tbl
         Maps each master link's sitetype to the user's sitetypeid via
         sitetypename. Depends on sitetypes_user already being synced.
    ================================================================ --->
    <cffunction name="syncSiteLinks" access="private" returntype="numeric" output="false">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="dsn"    type="string"  required="true">
        <cfset var local = {inserted = 0}>
        <cftry>
            <cfset local.master = queryExecute(
                "SELECT s.sitename, s.siteURL, s.siteicon, t.sitetypename
                 FROM sitelinks_master s
                 INNER JOIN sitetypes_master t ON t.sitetypeid = s.siteTypeid
                 ORDER BY s.sitename",
                [], {datasource = arguments.dsn})>

            <cfloop query="local.master">
                <cfset local.ust = queryExecute(
                    "SELECT sitetypeid FROM sitetypes_user WHERE sitetypename = ? AND userid = ?",
                    [local.master.sitetypename, arguments.userid], {datasource = arguments.dsn})>
                <cfif local.ust.recordCount EQ 1>
                    <cfset local.chk = queryExecute(
                        "SELECT COUNT(*) AS c FROM sitelinks_user_tbl WHERE sitename = ? AND userid = ?",
                        [local.master.sitename, arguments.userid], {datasource = arguments.dsn})>
                    <cfif local.chk.c EQ 0>
                        <cfset queryExecute(
                            "INSERT INTO sitelinks_user_tbl (siteName, siteURL, siteicon, siteTypeid, userid) VALUES (?, ?, ?, ?, ?)",
                            [local.master.sitename, local.master.siteURL, local.master.siteicon, local.ust.sitetypeid, arguments.userid],
                            {datasource = arguments.dsn})>
                        <cfset local.inserted++>
                    </cfif>
                </cfif>
            </cfloop>
            <cfcatch type="any">
                <cflog file="TAO_setup_errors" type="error"
                    text="syncSiteLinks userid=#arguments.userid# err=#cfcatch.message#">
            </cfcatch>
        </cftry>
        <cfreturn local.inserted>
    </cffunction>

    <!--- ================================================================
         pgpanels_master -> pgpanels_user (base panels).
         Detects which optional columns exist before selecting them.
    ================================================================ --->
    <cffunction name="syncPanels" access="private" returntype="numeric" output="false">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="dsn"    type="string"  required="true">
        <cfset var local = {additional = ""}>
        <cftry>
            <cfset local.probe = queryExecute("SELECT * FROM pgpanels_master LIMIT 1", [], {datasource = arguments.dsn})>
            <cfif listFindNoCase(local.probe.columnList, "pnTitle")>
                <cfset local.additional = listAppend(local.additional, "pnTitle")>
            </cfif>
            <cfif listFindNoCase(local.probe.columnList, "pnDescription")>
                <cfset local.additional = listAppend(local.additional, "pnDescription")>
            </cfif>
            <cfcatch type="any">
                <cfset local.additional = "">
            </cfcatch>
        </cftry>
        <cfreturn syncLookup(arguments.userid, "pgpanels_master", "pgpanels_user", "pnFilename", local.additional, "1=1", arguments.dsn)>
    </cffunction>

    <!--- ================================================================
         Create one "<SiteType> Links" panel per user sitetype that has
         no panel yet, and link it back. Mirrors user_setup_core.cfm.
    ================================================================ --->
    <cffunction name="syncSiteTypePanels" access="private" returntype="numeric" output="false">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="dsn"    type="string"  required="true">
        <cfset var local = {created = 0}>
        <cftry>
            <cfset local.types = queryExecute(
                "SELECT sitetypeid, sitetypename, pnid FROM sitetypes_user WHERE userid = ?",
                [arguments.userid], {datasource = arguments.dsn})>

            <cfloop query="local.types">
                <cfif len(trim(local.types.pnid)) EQ 0 OR val(local.types.pnid) EQ 0>
                    <cfset local.title = local.types.sitetypename & " Links">
                    <cfset local.existing = queryExecute(
                        "SELECT pnid FROM pgpanels_user WHERE pnTitle = ? AND userid = ? AND IsDeleted = 0",
                        [local.title, arguments.userid], {datasource = arguments.dsn})>

                    <cfif local.existing.recordCount GT 0>
                        <cfset local.pnid = local.existing.pnid>
                    <cfelse>
                        <cfset local.ord = queryExecute(
                            "SELECT COALESCE(MAX(pnOrderno), 0) + 1 AS n FROM pgpanels_user WHERE userid = ?",
                            [arguments.userid], {datasource = arguments.dsn})>
                        <cfset queryExecute(
                            "INSERT INTO pgpanels_user (pnTitle, pnFilename, pnorderno, pncolxl, pncolMd, pnDescription, IsDeleted, IsVisible, userid)
                             VALUES (?, 'mylinks_user.cfm', ?, 3, 3, '', 0, 1, ?)",
                            [local.title, local.ord.n, arguments.userid],
                            {datasource = arguments.dsn, result = "local.panelIns"})>
                        <cfset local.pnid = local.panelIns.generatedKey>
                        <cfset local.created++>
                    </cfif>

                    <cfset queryExecute(
                        "UPDATE sitetypes_user SET pnid = ? WHERE sitetypeid = ? AND userid = ?",
                        [local.pnid, local.types.sitetypeid, arguments.userid], {datasource = arguments.dsn})>
                </cfif>
            </cfloop>
            <cfcatch type="any">
                <cflog file="TAO_setup_errors" type="error"
                    text="syncSiteTypePanels userid=#arguments.userid# err=#cfcatch.message#">
            </cfcatch>
        </cftry>
        <cfreturn local.created>
    </cffunction>

    <!--- ================================================================
         Push master tag properties (IsTeam/IsCasting/tagtype) onto the
         user's tag copies. Mirrors user_setup_core.cfm tag updates.
    ================================================================ --->
    <cffunction name="updateTagProperties" access="private" returntype="void" output="false">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="dsn"    type="string"  required="true">
        <cftry>
            <cfset var local = {}>
            <!--- Team flag first (set-based) --->
            <cfset queryExecute(
                "UPDATE tags_user SET IsTeam = 1
                 WHERE userid = ? AND tagname IN (SELECT tagname FROM tags WHERE IsTeam = 1)",
                [arguments.userid], {datasource = arguments.dsn})>

            <cfset local.master = queryExecute(
                "SELECT tagname, IsTeam, IsCasting, tagtype FROM tags",
                [], {datasource = arguments.dsn})>
            <cfloop query="local.master">
                <cfset queryExecute(
                    "UPDATE tags_user SET IsTeam = ?, IsCasting = ?, tagtype = ? WHERE tagname = ? AND userid = ?",
                    [
                        {value = (local.master.IsTeam ? 1 : 0),    cfsqltype = "CF_SQL_BIT"},
                        {value = (local.master.IsCasting ? 1 : 0), cfsqltype = "CF_SQL_BIT"},
                        {value = local.master.tagtype,             cfsqltype = "CF_SQL_VARCHAR"},
                        {value = local.master.tagname,             cfsqltype = "CF_SQL_VARCHAR"},
                        {value = arguments.userid,                 cfsqltype = "CF_SQL_INTEGER"}
                    ],
                    {datasource = arguments.dsn})>
            </cfloop>
            <cfcatch type="any">
                <cflog file="TAO_setup_errors" type="error"
                    text="updateTagProperties userid=#arguments.userid# err=#cfcatch.message#">
            </cfcatch>
        </cftry>
    </cffunction>

    <!--- ================================================================
         Backfill a contactdetails row for the user when missing, and
         link it on taousers. Mirrors user_setup_core.cfm (current user
         only). Uses a transaction so the FK link stays consistent.
    ================================================================ --->
    <cffunction name="ensureUserContact" access="private" returntype="void" output="false">
        <cfargument name="userid" type="numeric" required="true">
        <cfargument name="dsn"    type="string"  required="true">
        <cftry>
            <cfset var local = {}>
            <cfset local.u = queryExecute(
                "SELECT userid, userfirstname, userlastname, contactid
                 FROM taousers WHERE userid = ? AND (contactid IS NULL OR contactid = '')",
                [arguments.userid], {datasource = arguments.dsn})>

            <cfif local.u.recordCount GT 0 AND NOT len(trim(local.u.contactid))>
                <cftransaction>
                    <cfset queryExecute(
                        "INSERT INTO contactdetails (contactfullname, userid, user_yn) VALUES (?, ?, 'Y')",
                        [trim(local.u.userfirstname & " " & local.u.userlastname), arguments.userid],
                        {datasource = arguments.dsn, result = "local.cIns"})>
                    <cfset queryExecute(
                        "UPDATE taousers SET contactid = ? WHERE userid = ?",
                        [local.cIns.generatedKey, arguments.userid], {datasource = arguments.dsn})>
                </cftransaction>
            </cfif>
            <cfcatch type="any">
                <cflog file="TAO_setup_errors" type="error"
                    text="ensureUserContact userid=#arguments.userid# err=#cfcatch.message#">
            </cfcatch>
        </cftry>
    </cffunction>

</cfcomponent>
