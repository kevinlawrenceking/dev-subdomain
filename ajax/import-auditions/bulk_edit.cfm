<cfsilent>
<!---
    Audition Import - Bulk Field Edit Endpoint
    POST /ajax/import-auditions/bulk_edit.cfm

    Updates a single field for multiple rows at once.

    Request Parameters (from JSON body, form, or URL):
    - job_id (required): The import job ID
    - row_ids (required): Comma-separated list or JSON array of row IDs
    - field_key (required): The field to update (whitelist: audition_date, location, status, medium, notes, audition_time)
    - new_value (required): The new value for the field
    - csrf_token (required): CSRF protection token (also accepts X-CSRF-Token header)

    Response codes:
    - AUTH_REQUIRED: No session userid (401)
    - CSRF_INVALID: Invalid or missing CSRF token (403)
    - ACCESS_DENIED: Job does not belong to user (403)
    - MISSING_PARAMS: Required parameters missing (400)
    - INVALID_FIELD: Field not in whitelist (400)
    - UPDATE_ERROR: Database error during update (500)
--->

<!--- Initialize response structure --->
<cfset variables.response = {
    "success": false,
    "code": "",
    "message": "",
    "data": {}
}>

<!--- Debug breadcrumbs array (no PII) --->
<cfset variables.debug = ["start"]>

<!--- Initialize variables for error handling --->
<cfset variables.jobId = 0>
<cfset variables.userid = 0>
<cfset variables.auditionService = "">

<!--- Helper: Return JSON error response with debug trail --->
<cffunction name="returnError" access="private" returntype="void" output="true">
    <cfargument name="code" type="string" required="true">
    <cfargument name="message" type="string" required="true">
    <cfargument name="statusCode" type="numeric" required="true">
    <cfargument name="extraData" type="struct" required="false" default="#{}#">

    <cfset variables.response.code = arguments.code>
    <cfset variables.response.message = arguments.message>
    <cfset variables.response.data = arguments.extraData>
    <cfset variables.response.data.debug = variables.debug>
    <cfset variables.response.data.last_step = arrayLen(variables.debug) gt 0 ? variables.debug[arrayLen(variables.debug)] : "none">
    <cfheader statuscode="#arguments.statusCode#">
    <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
</cffunction>

<!--- Helper: Strip BOM and whitespace from raw body --->
<cffunction name="cleanRawBody" access="private" returntype="string" output="false">
    <cfargument name="raw" type="string" required="true">
    <cfset var cleaned = arguments.raw>
    <cfif len(cleaned) gte 3 and asc(left(cleaned, 1)) eq 239 and asc(mid(cleaned, 2, 1)) eq 187 and asc(mid(cleaned, 3, 1)) eq 191>
        <cfset cleaned = mid(cleaned, 4, len(cleaned) - 3)>
    </cfif>
    <cfset cleaned = trim(cleaned)>
    <cfreturn cleaned>
</cffunction>

<!--- Helper: Safely parse JSON body --->
<cffunction name="parseJsonBody" access="private" returntype="struct" output="false">
    <cfargument name="rawBody" type="string" required="true">
    <cfset var body = {}>
    <cfset var cleaned = cleanRawBody(arguments.rawBody)>
    <cfif len(cleaned)>
        <cftry>
            <cfset body = deserializeJSON(cleaned)>
            <cfif not isStruct(body)>
                <cfset body = {}>
            </cfif>
            <cfcatch type="any">
                <cfset body = {}>
            </cfcatch>
        </cftry>
    </cfif>
    <cfreturn body>
</cffunction>

<cftry>
    <!--- A) Auth: Require logged-in session userid --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset returnError("AUTH_REQUIRED", "Authentication required", 401)>
    </cfif>
    <cfset variables.userid = session.userid>
    <cfset arrayAppend(variables.debug, "auth_ok")>

    <!--- B) Generate CSRF token if not exists --->
    <cfif not structKeyExists(session, "csrf_token") or not len(session.csrf_token)>
        <cfset session.csrf_token = createUUID()>
    </cfif>

    <!--- C) Parse JSON request body --->
    <cfset variables.body = {}>
    <cftry>
        <cfset variables.httpData = getHttpRequestData()>
        <cfif isBinary(variables.httpData.content)>
            <cfset variables.rawBody = charsetEncode(variables.httpData.content, "utf-8")>
        <cfelseif isSimpleValue(variables.httpData.content)>
            <cfset variables.rawBody = toString(variables.httpData.content)>
        <cfelse>
            <cfset variables.rawBody = "">
        </cfif>
        <cfset variables.body = parseJsonBody(variables.rawBody)>
        <cfcatch type="any">
            <cfset variables.body = {}>
        </cfcatch>
    </cftry>
    <cfset arrayAppend(variables.debug, "body_parsed")>

    <!--- D) Read CSRF token: header -> body -> form --->
    <cfset variables.csrfToken = "">
    <cfset variables.csrfSource = "none">

    <cfif structKeyExists(cgi, "http_x_csrf_token") and len(trim(cgi.http_x_csrf_token))>
        <cfset variables.csrfToken = trim(cgi.http_x_csrf_token)>
        <cfset variables.csrfSource = "header">
    <cfelseif structKeyExists(variables.body, "csrf_token") and len(trim(variables.body.csrf_token))>
        <cfset variables.csrfToken = trim(variables.body.csrf_token)>
        <cfset variables.csrfSource = "body">
    <cfelseif structKeyExists(form, "csrf_token") and len(trim(form.csrf_token))>
        <cfset variables.csrfToken = trim(form.csrf_token)>
        <cfset variables.csrfSource = "form">
    </cfif>

    <cfif not len(variables.csrfToken)>
        <cfset returnError("CSRF_INVALID", "CSRF token is required", 403, { csrf_source: "missing" })>
    </cfif>
    <cfif variables.csrfToken neq session.csrf_token>
        <cfset returnError("CSRF_INVALID", "Invalid CSRF token", 403, { csrf_source: variables.csrfSource })>
    </cfif>
    <cfset arrayAppend(variables.debug, "csrf_ok")>

    <!--- E) Read job_id: body -> form -> url --->
    <cfparam name="url.job_id" default="">
    <cfparam name="form.job_id" default="">

    <cfif structKeyExists(variables.body, "job_id") and isNumeric(variables.body.job_id) and val(variables.body.job_id) gt 0>
        <cfset variables.jobId = val(variables.body.job_id)>
    <cfelseif isNumeric(form.job_id) and val(form.job_id) gt 0>
        <cfset variables.jobId = val(form.job_id)>
    <cfelseif isNumeric(url.job_id) and val(url.job_id) gt 0>
        <cfset variables.jobId = val(url.job_id)>
    </cfif>

    <cfif variables.jobId lte 0>
        <cfset returnError("MISSING_PARAMS", "job_id is required", 400)>
    </cfif>

    <!--- F) Read field_key and new_value --->
    <cfset variables.fieldKey = "">
    <cfset variables.newValue = "">

    <cfif structKeyExists(variables.body, "field_key") and len(trim(variables.body.field_key))>
        <cfset variables.fieldKey = trim(variables.body.field_key)>
    <cfelseif structKeyExists(form, "field_key") and len(trim(form.field_key))>
        <cfset variables.fieldKey = trim(form.field_key)>
    </cfif>

    <cfif structKeyExists(variables.body, "new_value")>
        <cfset variables.newValue = variables.body.new_value>
    <cfelseif structKeyExists(form, "new_value")>
        <cfset variables.newValue = form.new_value>
    </cfif>

    <cfif not len(variables.fieldKey)>
        <cfset returnError("MISSING_PARAMS", "field_key is required", 400)>
    </cfif>

    <!--- G) Read row_ids: body array or comma-separated string --->
    <cfset variables.rowIds = []>

    <cfif structKeyExists(variables.body, "row_ids")>
        <cfif isArray(variables.body.row_ids)>
            <cfloop array="#variables.body.row_ids#" index="rid">
                <cfif isNumeric(rid) and val(rid) gt 0>
                    <cfset arrayAppend(variables.rowIds, val(rid))>
                </cfif>
            </cfloop>
        <cfelseif isSimpleValue(variables.body.row_ids) and len(trim(variables.body.row_ids))>
            <cfloop list="#variables.body.row_ids#" index="rid">
                <cfif isNumeric(rid) and val(rid) gt 0>
                    <cfset arrayAppend(variables.rowIds, val(rid))>
                </cfif>
            </cfloop>
        </cfif>
    <cfelseif structKeyExists(form, "row_ids") and len(trim(form.row_ids))>
        <cfloop list="#form.row_ids#" index="rid">
            <cfif isNumeric(rid) and val(rid) gt 0>
                <cfset arrayAppend(variables.rowIds, val(rid))>
            </cfif>
        </cfloop>
    </cfif>

    <cfif arrayLen(variables.rowIds) eq 0>
        <cfset returnError("MISSING_PARAMS", "row_ids is required (comma-separated list or array)", 400)>
    </cfif>
    <cfset arrayAppend(variables.debug, "params_ok")>

    <!--- H) Initialize service --->
    <cfset variables.auditionService = new services.AuditionImportService()>
    <cfset arrayAppend(variables.debug, "service_init")>

    <!--- I) Call bulk update service method --->
    <cfset arrayAppend(variables.debug, "bulk_edit_called")>
    <cfset variables.editResult = variables.auditionService.bulkUpdateField(
        job_id = variables.jobId,
        userid = variables.userid,
        row_ids = variables.rowIds,
        field_key = variables.fieldKey,
        new_value = variables.newValue
    )>

    <cfif variables.editResult.success>
        <cfset arrayAppend(variables.debug, "done")>
        <cfset variables.response.success = true>
        <cfset variables.response.message = variables.editResult.message>
        <cfset variables.response.data = variables.editResult.data>
        <cfset variables.response.data.debug = variables.debug>
    <cfelse>
        <cfset variables.httpStatusCode = 400>
        <cfif variables.editResult.code eq "ACCESS_DENIED">
            <cfset variables.httpStatusCode = 403>
        <cfelseif variables.editResult.code eq "NOT_FOUND">
            <cfset variables.httpStatusCode = 404>
        <cfelseif variables.editResult.code eq "UPDATE_ERROR">
            <cfset variables.httpStatusCode = 500>
        </cfif>
        <cfset arrayAppend(variables.debug, "bulk_edit_failed")>
        <cfset returnError(variables.editResult.code, variables.editResult.message, variables.httpStatusCode)>
    </cfif>

    <cfcatch type="any">
        <cflog file="import_auditions" text="[bulk_edit] ERROR userid=#variables.userid# job_id=#variables.jobId# message=#cfcatch.message# detail=#cfcatch.detail#">
        <cfset arrayAppend(variables.debug, "exception")>
        <cfset variables.response.code = "INTERNAL_ERROR">
        <cfset variables.response.message = "Bulk edit failed: " & cfcatch.message>
        <cfset variables.response.data.debug = variables.debug>
        <cfheader statuscode="500">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>