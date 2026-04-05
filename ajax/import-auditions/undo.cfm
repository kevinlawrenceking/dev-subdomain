<cfsilent>
<!---
    Audition Import - Undo Imported Row Endpoint
    POST /ajax/import-auditions/undo.cfm

    Reverses a single imported row: deletes created records and resets row to ready.

    Request Parameters (from JSON body, form, or URL):
    - row_id (required): The row ID to undo
    - csrf_token (required): CSRF protection token (also accepts X-CSRF-Token header)

    Response codes:
    - AUTH_REQUIRED: No session userid (401)
    - CSRF_INVALID: Invalid or missing CSRF token (403)
    - NOT_FOUND: Row not found or access denied (404)
    - UNDO_NOT_AVAILABLE: Undo already used or not available (400)
    - UNDO_ERROR: Database error during undo (500)
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
<cfset variables.rowId = 0>
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

    <!--- E) Read row_id: body -> form -> url --->
    <cfparam name="url.row_id" default="">
    <cfparam name="form.row_id" default="">

    <cfif structKeyExists(variables.body, "row_id") and isNumeric(variables.body.row_id) and val(variables.body.row_id) gt 0>
        <cfset variables.rowId = val(variables.body.row_id)>
    <cfelseif isNumeric(form.row_id) and val(form.row_id) gt 0>
        <cfset variables.rowId = val(form.row_id)>
    <cfelseif isNumeric(url.row_id) and val(url.row_id) gt 0>
        <cfset variables.rowId = val(url.row_id)>
    </cfif>

    <cfif variables.rowId lte 0>
        <cfset returnError("MISSING_PARAMS", "row_id is required", 400)>
    </cfif>
    <cfset arrayAppend(variables.debug, "params_ok")>

    <!--- F) Initialize service --->
    <cfset variables.auditionService = new services.AuditionImportService()>
    <cfset arrayAppend(variables.debug, "service_init")>

    <!--- G) Call undo service method --->
    <cfset arrayAppend(variables.debug, "undo_called")>
    <cfset variables.undoResult = variables.auditionService.undoImportedRow(variables.rowId, variables.userid)>

    <cfif variables.undoResult.success>
        <cfset arrayAppend(variables.debug, "done")>
        <cfset variables.response.success = true>
        <cfset variables.response.message = variables.undoResult.message>
        <cfset variables.response.data = variables.undoResult.data>
        <cfset variables.response.data.debug = variables.debug>
    <cfelse>
        <cfset variables.httpStatusCode = 400>
        <cfif variables.undoResult.code eq "NOT_FOUND">
            <cfset variables.httpStatusCode = 404>
        <cfelseif variables.undoResult.code eq "UNDO_ERROR">
            <cfset variables.httpStatusCode = 500>
        </cfif>
        <cfset arrayAppend(variables.debug, "undo_failed")>
        <cfset returnError(variables.undoResult.code, variables.undoResult.message, variables.httpStatusCode)>
    </cfif>

    <cfcatch type="any">
        <cflog file="import_auditions" text="[undo] ERROR userid=#variables.userid# row_id=#variables.rowId# message=#cfcatch.message# detail=#cfcatch.detail#">
        <cfset arrayAppend(variables.debug, "exception")>
        <cfset variables.response.code = "INTERNAL_ERROR">
        <cfset variables.response.message = "Undo failed: " & cfcatch.message>
        <cfset variables.response.data.debug = variables.debug>
        <cfheader statuscode="500">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>