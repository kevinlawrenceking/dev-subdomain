<cfsilent>
<!---
    Audition Import - Generate Test Data Endpoint
    POST /ajax/import-auditions/generate-test.cfm

    Generates a test CSV file from a pre-built scenario, writes it to disk,
    creates a job record, and returns the job_id so the user can proceed
    through the normal import flow (parse -> map -> review -> finalize).

    A UUID salt is appended to the notes of the first row so the SHA-256
    hash is unique every time, preventing duplicate-file blocking.

    Parameters:
      scenario  - required: "clean", "mixed", or "dupes"
      csrf_token - required

    Returns: JSON envelope with job object (same shape as upload.cfm)
--->

<!--- CSV field escaper: wraps in quotes if value contains comma, quote, or newline --->
<cffunction name="csvField" returntype="string" output="false" access="private">
    <cfargument name="val" type="string" required="true">
    <cfif find(",", arguments.val) or find('"', arguments.val) or find(chr(10), arguments.val) or find(chr(13), arguments.val)>
        <cfreturn '"' & replace(arguments.val, '"', '""', 'all') & '"'>
    </cfif>
    <cfreturn arguments.val>
</cffunction>

<cfset variables.response = {
    "success": false,
    "code": "",
    "message": "",
    "data": {}
}>
<cfset variables.startTick = getTickCount()>
<cfset variables.debug = ["start"]>
<cfset variables.userid = 0>
<cflog file="import_auditions" text="[generate-test] START">

<cftry>

    <!--- Auth --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset variables.response.code = "AUTH_REQUIRED">
        <cfset variables.response.message = "Authentication required">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>
    <cfset variables.userid = session.userid>

    <!--- CSRF validation --->
    <cfset variables.csrfToken = "">
    <cfif structKeyExists(form, "csrf_token") and len(trim(form.csrf_token))>
        <cfset variables.csrfToken = trim(form.csrf_token)>
    </cfif>
    <cfif not len(variables.csrfToken)>
        <cftry>
            <cfset variables.reqHeaders = getHTTPRequestData().headers>
            <cfif structKeyExists(variables.reqHeaders, "X-CSRF-Token") and len(trim(variables.reqHeaders["X-CSRF-Token"]))>
                <cfset variables.csrfToken = trim(variables.reqHeaders["X-CSRF-Token"])>
            </cfif>
        <cfcatch type="any"></cfcatch>
        </cftry>
    </cfif>
    <cfif not len(variables.csrfToken) and structKeyExists(cgi, "HTTP_X_CSRF_TOKEN") and len(trim(cgi.HTTP_X_CSRF_TOKEN))>
        <cfset variables.csrfToken = trim(cgi.HTTP_X_CSRF_TOKEN)>
    </cfif>
    <cfif not structKeyExists(session, "csrf_token") or not len(session.csrf_token)>
        <cfset session.csrf_token = createUUID()>
    </cfif>
    <cfif not len(variables.csrfToken) or variables.csrfToken neq session.csrf_token>
        <cfset variables.response.code = "CSRF_INVALID">
        <cfset variables.response.message = "Invalid or missing CSRF token">
        <cfheader statuscode="403">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>

    <!--- Validate scenario parameter --->
    <cfparam name="form.scenario" default="">
    <cfset variables.scenario = lcase(trim(form.scenario))>
    <cfif not listFindNoCase("clean,mixed,dupes", variables.scenario)>
        <cfset variables.response.code = "INVALID_SCENARIO">
        <cfset variables.response.message = "Invalid scenario. Use: clean, mixed, or dupes">
        <cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
    </cfif>

    <!--- Generate a unique salt so every file has a different SHA-256 hash --->
    <cfset variables.salt = left(replace(createUUID(), "-", "", "all"), 8)>
    <cfset variables.genTimestamp = dateFormat(now(), "yyyy-mm-dd") & " " & timeFormat(now(), "HH:mm:ss")>

    <!--- ================================================================
         BUILD CSV ROWS PER SCENARIO
         Each scenario returns an array of structs with the 7 CSV columns:
         project_name, role_name, casting_director, audition_date, medium, self_tape, notes
         ================================================================ --->
    <cfset variables.rows = []>

    <cfif variables.scenario eq "clean">
        <!--- 20 clean, fully valid rows --->
        <cfset variables.scenarioLabel = "Clean Data">
        <cfset variables.rows = [
            { p: "The Morning After",          r: "Detective Mills",    cd: "Sarah Chen",       d: "04/15/2026", m: "Film",       st: "0", n: "Initial read - bring sides" },
            { p: "Untitled Netflix Drama",     r: "Nurse Parker",       cd: "James Rodriguez",  d: "04/17/2026", m: "Television", st: "1", n: "Self-tape due by 5pm" },
            { p: "City on Fire",               r: "Mayor Thompson",     cd: "Lisa Yamamoto",    d: "04/18/2026", m: "Film",       st: "0", n: "Callback confirmed for 4/22" },
            { p: "Brooklyn Revival",           r: "Perp ##2",           cd: "Mark Gonzalez",    d: "04/20/2026", m: "Television", st: "0", n: "One-liner comedic bit" },
            { p: "Pepsi Summer Campaign",      r: "Dad",                cd: "Amy Foster",        d: "04/21/2026", m: "Commercial", st: "1", n: "Upbeat energy - family BBQ" },
            { p: "The Last Semester",          r: "Professor Kane",     cd: "David Kim",         d: "04/22/2026", m: "Film",       st: "0", n: "Accent work needed - British" },
            { p: "Hulu Limited Series",        r: "Young Cop",          cd: "Rachel Moore",      d: "04/24/2026", m: "Television", st: "1", n: "Submit tape via Casting Networks" },
            { p: "Ford F-150 National",        r: "Construction Worker",cd: "Brian Walsh",       d: "04/25/2026", m: "Commercial", st: "0", n: "In-person at Silver Dream Studio" },
            { p: "Westside Story Reimagined",  r: "Officer Krupke",     cd: "Nina Patel",        d: "04/28/2026", m: "Theater",    st: "0", n: "Bring headshot and resume" },
            { p: "Stranger Things S6",         r: "Lab Tech",           cd: "Tommy Chen",        d: "04/29/2026", m: "Television", st: "1", n: "NDA required before audition" },
            { p: "Apple TV Pilot",             r: "News Anchor",        cd: "Carla Diaz",        d: "05/01/2026", m: "Television", st: "0", n: "Wear professional attire" },
            { p: "Geico Regional",             r: "Confused Driver",    cd: "Mike Stevens",      d: "05/02/2026", m: "Commercial", st: "1", n: "Comedic timing important" },
            { p: "A Quiet Place 3",            r: "Survivor Dan",       cd: "Amanda Liu",        d: "05/05/2026", m: "Film",       st: "0", n: "Very physical - bring movement clothes" },
            { p: "Law and Order SVU",          r: "Witness",            cd: "Robert Taylor",     d: "05/06/2026", m: "Television", st: "0", n: "One scene - emotional range" },
            { p: "Target Back to School",      r: "College Student",    cd: "Jessica Nguyen",    d: "05/08/2026", m: "Commercial", st: "1", n: "Young energy 18-22 look" },
            { p: "The Playwright",             r: "Arthur Miller",      cd: "Steven Berkoff",    d: "05/10/2026", m: "Theater",    st: "0", n: "Prepared monologue required" },
            { p: "HBO Docudrama",              r: "Senator Williams",   cd: "Karen Phillips",    d: "05/12/2026", m: "Television", st: "0", n: "Political drama - measured delivery" },
            { p: "Indie Short - Dusk",         r: "The Stranger",       cd: "Alex Rivera",       d: "05/14/2026", m: "Film",       st: "1", n: "No pay but strong festival prospects" },
            { p: "Amazon Prime Feature",       r: "Bartender",          cd: "Michelle Grant",    d: "05/15/2026", m: "Film",       st: "0", n: "Improv skills helpful" },
            { p: "State Farm Regional",        r: "Neighbor",           cd: "Chris Donovan",     d: "05/18/2026", m: "Commercial", st: "1", n: "Friendly approachable read" }
        ]>

    <cfelseif variables.scenario eq "mixed">
        <!--- 15 rows: some clean, some with problems (missing project_name, bad dates, unknown medium) --->
        <cfset variables.scenarioLabel = "Mixed with Errors">
        <cfset variables.rows = [
            { p: "The Morning After",      r: "Detective Mills",    cd: "Sarah Chen",       d: "04/15/2026",  m: "Film",        st: "0", n: "Clean row" },
            { p: "City on Fire",           r: "Mayor Thompson",     cd: "Lisa Yamamoto",    d: "04/18/2026",  m: "Film",        st: "0", n: "Clean row" },
            { p: "",                       r: "Mystery Role",       cd: "Unknown CD",       d: "04/19/2026",  m: "Film",        st: "0", n: "PROBLEM: missing project_name" },
            { p: "Pepsi Summer Campaign",  r: "Dad",                cd: "Amy Foster",        d: "04/21/2026",  m: "Commercial",  st: "1", n: "Clean row" },
            { p: "Hulu Limited Series",    r: "Young Cop",          cd: "Rachel Moore",      d: "not-a-date",  m: "Television",  st: "1", n: "PROBLEM: invalid date format" },
            { p: "",                       r: "Unnamed Part",       cd: "",                  d: "04/23/2026",  m: "Film",        st: "0", n: "PROBLEM: missing project_name and CD" },
            { p: "Ford F-150 National",    r: "Construction Worker",cd: "Brian Walsh",       d: "04/25/2026",  m: "Commercial",  st: "0", n: "Clean row" },
            { p: "Westside Story",         r: "Officer Krupke",     cd: "Nina Patel",        d: "04/28/2026",  m: "Theater",     st: "0", n: "Clean row" },
            { p: "Apple TV Pilot",         r: "News Anchor",        cd: "Carla Diaz",        d: "13/32/2026",  m: "Television",  st: "0", n: "PROBLEM: impossible date" },
            { p: "Geico Regional",         r: "Confused Driver",    cd: "Mike Stevens",      d: "05/02/2026",  m: "Podcast",     st: "1", n: "PROBLEM: unknown medium value" },
            { p: "A Quiet Place 3",        r: "Survivor Dan",       cd: "Amanda Liu",        d: "05/05/2026",  m: "Film",        st: "0", n: "Clean row" },
            { p: "",                       r: "",                   cd: "",                  d: "",            m: "",            st: "",  n: "PROBLEM: completely empty row" },
            { p: "Law and Order SVU",      r: "Witness",            cd: "Robert Taylor",     d: "05/06/2026",  m: "Television",  st: "0", n: "Clean row" },
            { p: "Target Back to School",  r: "College Student",    cd: "Jessica Nguyen",    d: "05/08/2026",  m: "Commercial",  st: "1", n: "Clean row" },
            { p: "HBO Docudrama",          r: "Senator Williams",   cd: "Karen Phillips",    d: "05/12/2026",  m: "Television",  st: "0", n: "Clean row" }
        ]>

    <cfelseif variables.scenario eq "dupes">
        <!--- 15 rows: groups designed to trigger weighted duplicate scoring --->
        <cfset variables.scenarioLabel = "With Duplicates">
        <cfset variables.rows = [
            { p: "The Morning After",      r: "Detective Mills",    cd: "Sarah Chen",       d: "04/15/2026", m: "Film",       st: "0", n: "Original audition" },
            { p: "The Morning After",      r: "Detective Mills",    cd: "Sarah Chen",       d: "04/15/2026", m: "Film",       st: "0", n: "DUPE: exact match of row 1 (date+project)" },
            { p: "The Morning After",      r: "Lt. Rogers",         cd: "Sarah Chen",       d: "04/15/2026", m: "Film",       st: "0", n: "DUPE: same date+project different role" },
            { p: "City on Fire",           r: "Mayor Thompson",     cd: "Lisa Yamamoto",    d: "04/18/2026", m: "Film",       st: "0", n: "Clean row" },
            { p: "Pepsi Summer Campaign",  r: "Dad",                cd: "Amy Foster",        d: "04/21/2026", m: "Commercial", st: "1", n: "Original audition" },
            { p: "Pepsi Summer Campaign",  r: "Son",                cd: "Amy Foster",        d: "04/21/2026", m: "Commercial", st: "0", n: "DUPE: same project+date different role" },
            { p: "Hulu Limited Series",    r: "Young Cop",          cd: "Rachel Moore",      d: "04/24/2026", m: "Television", st: "1", n: "Clean row" },
            { p: "Ford F-150 National",    r: "Construction Worker",cd: "Brian Walsh",       d: "04/25/2026", m: "Commercial", st: "0", n: "Clean row" },
            { p: "Stranger Things S6",     r: "Lab Tech",           cd: "Tommy Chen",        d: "04/29/2026", m: "Television", st: "1", n: "Original audition" },
            { p: "Stranger Things S6",     r: "Lab Tech",           cd: "Tommy Chen",        d: "04/29/2026", m: "Television", st: "1", n: "DUPE: exact duplicate of row 9" },
            { p: "Apple TV Pilot",         r: "News Anchor",        cd: "Carla Diaz",        d: "05/01/2026", m: "Television", st: "0", n: "Clean row" },
            { p: "Geico Regional",         r: "Confused Driver",    cd: "Mike Stevens",      d: "05/02/2026", m: "Commercial", st: "1", n: "Clean row" },
            { p: "A Quiet Place 3",        r: "Survivor Dan",       cd: "Amanda Liu",        d: "05/05/2026", m: "Film",       st: "0", n: "Original audition" },
            { p: "A Quiet Place 3",        r: "Survivor Dan",       cd: "Amanda Liu",        d: "05/06/2026", m: "Film",       st: "0", n: "DUPE: same project+role day apart" },
            { p: "Law and Order SVU",      r: "Witness",            cd: "Robert Taylor",     d: "05/06/2026", m: "Television", st: "0", n: "Clean row" }
        ]>
    </cfif>

    <!--- ================================================================
         BUILD CSV STRING
         ================================================================ --->
    <cfset variables.csvLines = []>
    <cfset arrayAppend(variables.csvLines, "project_name,role_name,casting_director,audition_date,medium,self_tape,notes")>

    <cfloop from="1" to="#arrayLen(variables.rows)#" index="variables.i">
        <cfset variables.row = variables.rows[variables.i]>
        <!--- Append salt to notes on first row to guarantee unique hash --->
        <cfset variables.noteVal = variables.row.n>
        <cfif variables.i eq 1>
            <cfset variables.noteVal = variables.noteVal & " [test-" & variables.salt & "]">
        </cfif>
        <cfset arrayAppend(variables.csvLines,
            csvField(variables.row.p) & "," &
            csvField(variables.row.r) & "," &
            csvField(variables.row.cd) & "," &
            csvField(variables.row.d) & "," &
            csvField(variables.row.m) & "," &
            csvField(variables.row.st) & "," &
            csvField(variables.noteVal)
        )>
    </cfloop>

    <cfset variables.csvContent = arrayToList(variables.csvLines, chr(10))>

    <!--- ================================================================
         WRITE FILE TO DISK
         ================================================================ --->
    <cfif structKeyExists(session, "userImportsPath") and len(session.userImportsPath)>
        <cfset variables.uploadDir = session.userImportsPath>
    <cfelse>
        <cfset variables.uploadDir = application.baseMediaPath & "\users\" & variables.userid & "\imports">
    </cfif>
    <cfif not directoryExists(variables.uploadDir)>
        <cfdirectory directory="#variables.uploadDir#" action="create">
    </cfif>

    <cfset variables.filename = "test_" & variables.scenario & "_" & variables.salt & ".csv">
    <cfset variables.filePath = variables.uploadDir & "\" & variables.filename>
    <cffile action="write" file="#variables.filePath#" output="#variables.csvContent#" charset="utf-8">
    <cfset arrayAppend(variables.debug, "file_written")>

    <!--- Compute SHA-256 hash --->
    <cfset variables.fileBytes = fileReadBinary(variables.filePath)>
    <cfset variables.messageDigest = createObject("java", "java.security.MessageDigest").getInstance("SHA-256")>
    <cfset variables.hashBytes = variables.messageDigest.digest(variables.fileBytes)>
    <cfset variables.fileHash = "">
    <cfloop from="1" to="#arrayLen(variables.hashBytes)#" index="variables.i">
        <cfset variables.byteVal = variables.hashBytes[variables.i]>
        <cfif variables.byteVal lt 0>
            <cfset variables.byteVal = variables.byteVal + 256>
        </cfif>
        <cfset variables.fileHash = variables.fileHash & right("0" & formatBaseN(variables.byteVal, 16), 2)>
    </cfloop>
    <cfset variables.fileHash = lcase(variables.fileHash)>
    <cfset arrayAppend(variables.debug, "hash_computed")>

    <!--- Get file size --->
    <cfset variables.fileInfo = getFileInfo(variables.filePath)>
    <cfset variables.fileSize = variables.fileInfo.size>

    <!--- Create job record --->
    <cfset variables.sourceFilename = "Test - " & variables.scenarioLabel & " (" & arrayLen(variables.rows) & " rows)">
    <cfset variables.qResult = {}>
    <cfset queryExecute(
        "INSERT INTO import_auditions_jobs (
            userid, source_filename, file_type, file_size, file_hash,
            stored_file_path, status, created_at, updated_at
        ) VALUES (
            :userid, :source_filename, :file_type, :file_size, :file_hash,
            :stored_file_path, 'uploaded', NOW(), NOW()
        )",
        {
            userid: { value: variables.userid, cfsqltype: "cf_sql_integer" },
            source_filename: { value: variables.sourceFilename, cfsqltype: "cf_sql_varchar", maxlength: 255 },
            file_type: { value: "csv", cfsqltype: "cf_sql_varchar", maxlength: 10 },
            file_size: { value: variables.fileSize, cfsqltype: "cf_sql_bigint" },
            file_hash: { value: variables.fileHash, cfsqltype: "cf_sql_varchar", maxlength: 64 },
            stored_file_path: { value: variables.filePath, cfsqltype: "cf_sql_varchar", maxlength: 500 }
        },
        { datasource: application.datasource, result: "variables.qResult" }
    )>

    <cfset variables.newJobId = variables.qResult.generatedKey>
    <cfset arrayAppend(variables.debug, "job_created")>

    <!--- Log event --->
    <cfset variables.importService = new services.AuditionImportService()>
    <cfset variables.importService.logEvent(
        job_id = variables.newJobId,
        userid = variables.userid,
        event_type = "generate_test",
        detail = {
            scenario: variables.scenario,
            salt: variables.salt,
            row_count: arrayLen(variables.rows)
        }
    )>

    <cflog file="import_auditions" text="[generate-test] SUCCESS userid=#variables.userid# job_id=#variables.newJobId# scenario=#variables.scenario# rows=#arrayLen(variables.rows)# elapsed_ms=#getTickCount() - variables.startTick#">
    <cfset arrayAppend(variables.debug, "done")>

    <cfset variables.response.success = true>
    <cfset variables.response.message = "Test data generated">
    <cfset variables.response.data = {
        "job": {
            "job_id": variables.newJobId,
            "status": "uploaded",
            "file_hash": variables.fileHash,
            "source_filename": variables.sourceFilename,
            "file_size": variables.fileSize
        },
        "scenario": variables.scenario,
        "row_count": arrayLen(variables.rows),
        "elapsed_ms": getTickCount() - variables.startTick
    }>

    <cfcatch type="any">
        <cflog file="import_auditions" text="[generate-test] ERROR userid=#variables.userid# message=#cfcatch.message# detail=#cfcatch.detail#">
        <cfset variables.response.code = "GENERATE_FAILED">
        <cfset variables.response.message = "Test data generation failed: " & cfcatch.message>
    </cfcatch>
</cftry>
</cfsilent>
<cfset variables.response.data.debug = variables.debug>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>
