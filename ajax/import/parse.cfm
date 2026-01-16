<cfsilent>
<!---
    Contact Import V2 - Parse File Endpoint
    POST /ajax/import/parse.cfm

    Expects JSON body: { job_id: number, options: object }
    Returns: JSON with parse results
--->

<cfset response = {
    success: false,
    totalRows: 0,
    parsedRows: 0,
    message: "",
    DEBUG_STEP: "init"
}>

<cftry>
    <!--- Validate user session --->
    <cfset response.DEBUG_STEP = "auth_check">
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid)>
        <cfset response.message = "Authentication required">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    <cfset userid = session.userid>
    <cfset response.DEBUG_USERID = userid>

    <!--- Parse request body --->
    <cfset response.DEBUG_STEP = "parse_request">
    <cfset requestBody = toString(getHTTPRequestData().content)>
    <cfif not len(requestBody)>
        <cfset response.message = "Missing request body">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <cfset requestData = deserializeJSON(requestBody)>
    <cfset response.DEBUG_STEP = "validate_job_id">

    <!--- Validate job_id --->
    <cfif not structKeyExists(requestData, "job_id") or not isNumeric(requestData.job_id)>
        <cfset response.message = "Missing or invalid job_id">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    <cfset response.DEBUG_JOB_ID = requestData.job_id>

    <!--- Get and validate job --->
    <cfset response.DEBUG_STEP = "create_service">
    <cfset importService = new services.ContactImportV2Service()>

    <cfset response.DEBUG_STEP = "get_job">
    <cfset job = importService.getJob(requestData.job_id)>

    <cfif not job.found>
        <cfset response.message = "Job not found">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>
    <cfset response.DEBUG_STEP = "job_found">
    <cfset response.DEBUG_JOB_STATUS = job.status>
    <cfset response.DEBUG_JOB_FILE = job.stored_file_path>

    <!--- Verify ownership --->
    <cfset response.DEBUG_STEP = "verify_ownership">
    <cfif job.userid neq userid>
        <cfset response.message = "Access denied">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Parse the file --->
    <cfset response.DEBUG_STEP = "parse_file">
    <cfset parseResult = importService.parseFile(requestData.job_id)>
    <cfset response.DEBUG_PARSE_SUCCESS = parseResult.success>
    <cfset response.DEBUG_PARSE_MSG = parseResult.message>

    <cfif not parseResult.success>
        <cfset response.message = parseResult.message>
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Process rows (apply mapping, validation, duplicate detection) --->
    <cfset response.DEBUG_STEP = "process_rows">
    <cfset processResult = importService.processRows(requestData.job_id, userid)>
    <cfset response.DEBUG_STEP = "complete">

    <!--- Return success --->
    <cfset response.success = true>
    <cfset response.totalRows = parseResult.totalRows>
    <cfset response.parsedRows = parseResult.parsedRows>
    <cfset response.validRows = processResult.valid>
    <cfset response.problemRows = processResult.problem>
    <cfset response.dupeRows = processResult.dupe>
    <cfset response.message = "File parsed successfully">

    <cfcatch type="any">
        <cfset response.message = "Parsing failed: " & cfcatch.message>
        <cfif structKeyExists(cfcatch, "detail") and len(cfcatch.detail)>
            <cfset response.detail = cfcatch.detail>
        </cfif>
        <cfif structKeyExists(cfcatch, "sql") and len(cfcatch.sql)>
            <cfset response.sql = cfcatch.sql>
        </cfif>
        <cfif structKeyExists(cfcatch, "where") and len(cfcatch.where)>
            <cfset response.where = cfcatch.where>
        </cfif>
        <cfif structKeyExists(cfcatch, "tagContext") and isArray(cfcatch.tagContext) and arrayLen(cfcatch.tagContext)>
            <cfset response.DEBUG_ERROR_FILE = cfcatch.tagContext[1].template>
            <cfset response.DEBUG_ERROR_LINE = cfcatch.tagContext[1].line>
        </cfif>
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
