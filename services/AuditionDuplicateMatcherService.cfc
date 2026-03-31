<cfcomponent displayname="AuditionDuplicateMatcherService" hint="Duplicate detection and matching for audition imports">

<!--- ========================================
      AUDITION DUPLICATE MATCHER SERVICE
      Purpose: Find potential duplicate auditions
      in the database before import. Uses scoring
      algorithm based on date+project+actor+role.

      KNOWN LIMITATION: buildUserDupeIndex() queries the flat
      "auditions" table only. Auditions created through the
      normal UI (audprojects -> audroles -> events_tbl) will
      NOT be detected as duplicates unless they were also
      written to the flat auditions table by the import process.
      TODO: Extend to also query audprojects/audroles/events_tbl
      for full coverage of manually-created auditions.
     ======================================== --->

<!--- Matching thresholds --->
<cfset this.THRESHOLD_HIGH = 70>
<cfset this.THRESHOLD_MEDIUM = 40>
<cfset this.THRESHOLD_LOW = 25>
<cfset this.MAX_CANDIDATES = 5>

<!--- Memory guardrails --->
<cfset this.MAX_DUPE_INDEX_ITEMS = 100000>
<cfset this.MAX_DUPE_INDEX_BUILD_MS = 5000>

<!--- ========================================
      NORMALIZATION HELPERS (pure, no DB)
     ======================================== --->

<cffunction name="normalizeProjectName" access="public" returntype="string" output="false"
    hint="Normalize project name: lowercase, strip punctuation, collapse whitespace">
    <cfargument name="name" type="string" required="true">
    <cfset var result = trim(arguments.name)>
    <cfset result = lcase(result)>
    <!--- Strip punctuation except spaces --->
    <cfset result = reReplace(result, "[^a-z0-9\s]", "", "ALL")>
    <!--- Collapse multiple spaces --->
    <cfset result = reReplace(result, "\s+", " ", "ALL")>
    <cfreturn result>
</cffunction>

<cffunction name="normalizeActorName" access="public" returntype="string" output="false"
    hint="Normalize actor name: lowercase, trim">
    <cfargument name="name" type="string" required="true">
    <cfreturn lcase(trim(arguments.name))>
</cffunction>

<cffunction name="normalizeDate" access="public" returntype="string" output="false"
    hint="Normalize date to YYYY-MM-DD format">
    <cfargument name="dateStr" type="string" required="true">
    <cftry>
        <cfset var d = parseDateTime(arguments.dateStr)>
        <cfreturn dateFormat(d, "yyyy-mm-dd")>
        <cfcatch type="any">
            <cfreturn "">
        </cfcatch>
    </cftry>
</cffunction>

<!--- ========================================
      TABLE AVAILABILITY CHECK
     ======================================== --->

<cffunction name="isDupeDetectionAvailable" access="public" returntype="struct" output="false"
    hint="Check if auditions table exists for duplicate detection">

    <cfset var result = {
        available: false,
        reason: "",
        schema: ""
    }>

    <cftry>
        <cfquery name="qSchema" datasource="#application.datasource#" timeout="5">
            SELECT DATABASE() AS schema_name
        </cfquery>
        <cfset result.schema = qSchema.schema_name>

        <cfquery name="qCheck" datasource="#application.datasource#" timeout="5">
            SELECT TABLE_NAME, TABLE_TYPE
            FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'auditions'
        </cfquery>

        <cfif qCheck.recordCount gt 0>
            <cfset result.available = true>
            <cfset result.reason = "auditions table available in schema [" & result.schema & "]">
        <cfelse>
            <cfset result.reason = "auditions table not found in schema [" & result.schema & "]">
        </cfif>

        <cfcatch type="any">
            <cfset result.available = false>
            <cfset result.reason = "Table check failed: " & cfcatch.message>
            <cflog file="import_auditions" text="DupeService.isDupeDetectionAvailable ERROR: #cfcatch.message#">
        </cfcatch>
    </cftry>

    <cfreturn result>
</cffunction>

<!--- ========================================
      BUILD IN-MEMORY DUPE INDEX
      Queries existing auditions for the user,
      builds lookup maps for O(1) matching.
     ======================================== --->

<cffunction name="buildUserDupeIndex" access="public" returntype="struct" output="false"
    hint="Build in-memory dupe index for a user (one-time per job)">
    <cfargument name="userid" type="numeric" required="true">

    <cfset var startTime = getTickCount()>
    <cfset var result = {
        "date_project_map": {},
        "date_actor_map": {},
        "project_role_map": {},
        "date_cd_map": {},
        "build_ms": 0,
        "items_total": 0,
        "abort_reason": ""
    }>

    <cftry>
        <!--- Query existing auditions for this user --->
        <cfquery name="qAuditions" datasource="#application.datasource#" timeout="30">
            SELECT a.audition_id, a.contactid, a.project_name, a.role_name,
                   a.audition_date, a.casting_director,
                   COALESCE(cd.firstName, '') AS contact_first,
                   COALESCE(cd.lastName, '') AS contact_last
            FROM auditions a
            LEFT JOIN contactdetails cd ON cd.contactid = a.contactid
            WHERE a.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
              AND (a.status IS NULL OR a.status != 'cancelled')
        </cfquery>

        <cfset result.items_total = qAuditions.recordCount>

        <!--- Memory guardrail --->
        <cfif qAuditions.recordCount gt this.MAX_DUPE_INDEX_ITEMS>
            <cfset result.abort_reason = "Too many auditions: " & qAuditions.recordCount>
            <cflog file="import_auditions" text="DupeService: index build aborted, count=#qAuditions.recordCount#">
            <cfreturn result>
        </cfif>

        <!--- Build maps --->
        <cfloop query="qAuditions">
            <cfset var audId = qAuditions.audition_id>
            <cfset var dateStr = "">
            <cfif isDate(qAuditions.audition_date)>
                <cfset dateStr = dateFormat(qAuditions.audition_date, "yyyy-mm-dd")>
            </cfif>
            <cfset var normProject = normalizeProjectName(qAuditions.project_name)>
            <cfset var normRole = len(qAuditions.role_name) ? lcase(trim(qAuditions.role_name)) : "">
            <cfset var normCD = len(qAuditions.casting_director) ? lcase(trim(qAuditions.casting_director)) : "">
            <cfset var contactName = lcase(trim(qAuditions.contact_first & " " & qAuditions.contact_last))>

            <!--- date_project_map: "YYYY-MM-DD|normalized_project" -> [audition_id, ...] --->
            <cfif len(dateStr) and len(normProject)>
                <cfset var dpKey = dateStr & "|" & normProject>
                <cfif not structKeyExists(result.date_project_map, dpKey)>
                    <cfset result.date_project_map[dpKey] = []>
                </cfif>
                <cfset arrayAppend(result.date_project_map[dpKey], audId)>
            </cfif>

            <!--- date_actor_map: "YYYY-MM-DD|normalized_contact_name" -> [audition_id, ...] --->
            <cfif len(dateStr) and len(trim(contactName))>
                <cfset var daKey = dateStr & "|" & contactName>
                <cfif not structKeyExists(result.date_actor_map, daKey)>
                    <cfset result.date_actor_map[daKey] = []>
                </cfif>
                <cfset arrayAppend(result.date_actor_map[daKey], audId)>
            </cfif>

            <!--- project_role_map: "normalized_project|normalized_role" -> [audition_id, ...] --->
            <cfif len(normProject) and len(normRole)>
                <cfset var prKey = normProject & "|" & normRole>
                <cfif not structKeyExists(result.project_role_map, prKey)>
                    <cfset result.project_role_map[prKey] = []>
                </cfif>
                <cfset arrayAppend(result.project_role_map[prKey], audId)>
            </cfif>

            <!--- date_cd_map: "YYYY-MM-DD|normalized_cd" -> [audition_id, ...] --->
            <cfif len(dateStr) and len(normCD)>
                <cfset var dcKey = dateStr & "|" & normCD>
                <cfif not structKeyExists(result.date_cd_map, dcKey)>
                    <cfset result.date_cd_map[dcKey] = []>
                </cfif>
                <cfset arrayAppend(result.date_cd_map[dcKey], audId)>
            </cfif>
        </cfloop>

        <cfset result.build_ms = getTickCount() - startTime>
        <cflog file="import_auditions" text="DupeService: index built items=#result.items_total# ms=#result.build_ms#">

        <cfcatch type="any">
            <cfset result.abort_reason = "Build failed: " & cfcatch.message>
            <cflog file="import_auditions" text="DupeService.buildUserDupeIndex ERROR: #cfcatch.message#">
        </cfcatch>
    </cftry>

    <cfreturn result>
</cffunction>

<!--- ========================================
      FIND DUPLICATES FOR A SINGLE ROW
      Scores a row's facts against the index.
     ======================================== --->

<cffunction name="findDuplicates" access="public" returntype="struct" output="false"
    hint="Find duplicate auditions for a single import row">
    <cfargument name="rowFacts" type="struct" required="true" hint="Struct of field_name -> normalized_value">
    <cfargument name="dupeIndex" type="struct" required="true" hint="Result from buildUserDupeIndex">

    <cfset var result = {
        "candidates": [],
        "best_score": 0,
        "best_audition_id": 0
    }>

    <cftry>
        <!--- Extract key fields from row facts --->
        <cfset var rowDate = structKeyExists(arguments.rowFacts, "audition_date") ? normalizeDate(arguments.rowFacts.audition_date) : "">
        <cfset var rowProject = structKeyExists(arguments.rowFacts, "project_name") ? normalizeProjectName(arguments.rowFacts.project_name) : "">
        <cfset var rowRole = structKeyExists(arguments.rowFacts, "role_name") ? lcase(trim(arguments.rowFacts.role_name)) : "">
        <cfset var rowCD = structKeyExists(arguments.rowFacts, "casting_director") ? lcase(trim(arguments.rowFacts.casting_director)) : "">
        <cfset var rowActor = structKeyExists(arguments.rowFacts, "contact_name") ? normalizeActorName(arguments.rowFacts.contact_name) : "">

        <!--- Collect candidate audition IDs with their scores --->
        <cfset var candidateScores = {}>

        <!--- Match 1: Same date + same project = +80 --->
        <cfif len(rowDate) and len(rowProject)>
            <cfset var dpKey = rowDate & "|" & rowProject>
            <cfif structKeyExists(arguments.dupeIndex.date_project_map, dpKey)>
                <cfloop array="#arguments.dupeIndex.date_project_map[dpKey]#" index="local.audId">
                    <cfif not structKeyExists(candidateScores, local.audId)>
                        <cfset candidateScores[local.audId] = 0>
                    </cfif>
                    <cfset candidateScores[local.audId] = candidateScores[local.audId] + 80>
                </cfloop>
            </cfif>
        </cfif>

        <!--- Match 2: Same date + same actor name = +60 --->
        <cfif len(rowDate) and len(rowActor)>
            <cfset var daKey = rowDate & "|" & rowActor>
            <cfif structKeyExists(arguments.dupeIndex.date_actor_map, daKey)>
                <cfloop array="#arguments.dupeIndex.date_actor_map[daKey]#" index="local.audId">
                    <cfif not structKeyExists(candidateScores, local.audId)>
                        <cfset candidateScores[local.audId] = 0>
                    </cfif>
                    <cfset candidateScores[local.audId] = candidateScores[local.audId] + 60>
                </cfloop>
            </cfif>
        </cfif>

        <!--- Match 3: Same project + same role = +40 --->
        <cfif len(rowProject) and len(rowRole)>
            <cfset var prKey = rowProject & "|" & rowRole>
            <cfif structKeyExists(arguments.dupeIndex.project_role_map, prKey)>
                <cfloop array="#arguments.dupeIndex.project_role_map[prKey]#" index="local.audId">
                    <cfif not structKeyExists(candidateScores, local.audId)>
                        <cfset candidateScores[local.audId] = 0>
                    </cfif>
                    <cfset candidateScores[local.audId] = candidateScores[local.audId] + 40>
                </cfloop>
            </cfif>
        </cfif>

        <!--- Match 4: Same casting director + same date = +30 --->
        <cfif len(rowDate) and len(rowCD)>
            <cfset var dcKey = rowDate & "|" & rowCD>
            <cfif structKeyExists(arguments.dupeIndex.date_cd_map, dcKey)>
                <cfloop array="#arguments.dupeIndex.date_cd_map[dcKey]#" index="local.audId">
                    <cfif not structKeyExists(candidateScores, local.audId)>
                        <cfset candidateScores[local.audId] = 0>
                    </cfif>
                    <cfset candidateScores[local.audId] = candidateScores[local.audId] + 30>
                </cfloop>
            </cfif>
        </cfif>

        <!--- Sort candidates by score descending, take top MAX_CANDIDATES --->
        <cfset var sortedCandidates = []>
        <cfloop collection="#candidateScores#" item="local.candId">
            <cfset arrayAppend(sortedCandidates, {
                "audition_id": local.candId,
                "score": candidateScores[local.candId]
            })>
        </cfloop>

        <!--- Sort by score descending --->
        <cfset arraySort(sortedCandidates, function(a, b) {
            return b.score - a.score;
        })>

        <!--- Take top N --->
        <cfset var topN = min(arrayLen(sortedCandidates), this.MAX_CANDIDATES)>
        <cfloop from="1" to="#topN#" index="local.i">
            <cfset arrayAppend(result.candidates, sortedCandidates[local.i])>
        </cfloop>

        <!--- Set best match --->
        <cfif arrayLen(result.candidates) gt 0>
            <cfset result.best_score = result.candidates[1].score>
            <cfset result.best_audition_id = result.candidates[1].audition_id>
        </cfif>

        <cfcatch type="any">
            <cflog file="import_auditions" text="DupeService.findDuplicates ERROR: #cfcatch.message#">
        </cfcatch>
    </cftry>

    <cfreturn result>
</cffunction>

<!--- ========================================
      GET CANDIDATE DETAILS FOR DISPLAY
     ======================================== --->

<cffunction name="getCandidateDetails" access="public" returntype="array" output="false"
    hint="Fetch full details for candidate audition IDs">
    <cfargument name="candidateIds" type="array" required="true">
    <cfargument name="userid" type="numeric" required="true">

    <cfset var details = []>

    <cfif arrayLen(arguments.candidateIds) eq 0>
        <cfreturn details>
    </cfif>

    <cftry>
        <cfset var idList = arrayToList(arguments.candidateIds)>

        <cfquery name="qDetails" datasource="#application.datasource#" timeout="10">
            SELECT a.audition_id, a.project_name, a.role_name, a.casting_director,
                   a.agency, a.audition_date, a.audition_time, a.location,
                   a.medium, a.status, a.self_tape,
                   COALESCE(cd.firstName, '') AS contact_first,
                   COALESCE(cd.lastName, '') AS contact_last
            FROM auditions a
            LEFT JOIN contactdetails cd ON cd.contactid = a.contactid
            WHERE a.audition_id IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#idList#" list="true">)
              AND a.userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
        </cfquery>

        <cfloop query="qDetails">
            <cfset arrayAppend(details, {
                "audition_id": qDetails.audition_id,
                "project_name": qDetails.project_name,
                "role_name": qDetails.role_name,
                "casting_director": qDetails.casting_director,
                "agency": qDetails.agency,
                "audition_date": isDate(qDetails.audition_date) ? dateFormat(qDetails.audition_date, "yyyy-mm-dd") : "",
                "audition_time": len(qDetails.audition_time) ? timeFormat(qDetails.audition_time, "HH:mm") : "",
                "location": qDetails.location,
                "medium": qDetails.medium,
                "status": qDetails.status,
                "self_tape": qDetails.self_tape,
                "contact_name": trim(qDetails.contact_first & " " & qDetails.contact_last)
            })>
        </cfloop>

        <cfcatch type="any">
            <cflog file="import_auditions" text="DupeService.getCandidateDetails ERROR: #cfcatch.message#">
        </cfcatch>
    </cftry>

    <cfreturn details>
</cffunction>

</cfcomponent>
