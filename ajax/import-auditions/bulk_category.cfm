<cfsilent>
<!---
    Audition Import - Bulk Category Assignment Endpoint
    POST /ajax/import-auditions/bulk_category.cfm

    Sets audsubcatid for all rows that don't already have one assigned.

    Request Parameters (JSON body):
    - job_id (required): The import job ID
    - audsubcatid (required): The "Other" subcategory ID to apply
    - csrf_token (required): CSRF protection token (also accepts X-CSRF-Token header)

    Response codes:
    - AUTH_REQUIRED: No session userid (401)
    - CSRF_INVALID: Invalid or missing CSRF token (403)
    - MISSING_PARAMS: Required parameters missing (400)
    - INVALID_CATEGORY: audsubcatid is not a valid "Other" subcategory (400)
--->

<cfset variables.response = {
    "success": false,
    "code": "",
    "message": "",
    "data": {}
}>

<cffunction name="returnError" access="private" returntype="void" output="true">
    <cfargument name="code" type="string" required="true">
    <cfargument name="message" type="string" required="true">
    <cfargument name="statusCode" type="numeric" required="true">

    <cfset variables.response.code = arguments.code>
    <cfset variables.response.message = arguments.message>
    <cfheader statuscode="#arguments.statusCode#">
    <cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput><cfabort>
</cffunction>

<cftry>
    <!--- Auth --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset returnError("AUTH_REQUIRED", "Authentication required", 401)>
    </cfif>
    <cfset variables.userid = session.userid>

    <!--- CSRF --->
    <cfif not structKeyExists(session, "csrf_token") or not len(session.csrf_token)>
        <cfset session.csrf_token = createUUID()>
    </cfif>

    <cfset variables.body = {}>
    <cftry>
        <cfset variables.rawBody = toString(getHttpRequestData().content)>
        <cfset variables.rawBody = trim(variables.rawBody)>
        <cfif len(variables.rawBody)>
            <cfset variables.body = deserializeJSON(variables.rawBody)>
        </cfif>
        <cfcatch type="any"><cfset variables.body = {}></cfcatch>
    </cftry>

    <cfset variables.csrfToken = "">
    <cfif structKeyExists(cgi, "http_x_csrf_token") and len(trim(cgi.http_x_csrf_token))>
        <cfset variables.csrfToken = trim(cgi.http_x_csrf_token)>
    <cfelseif structKeyExists(variables.body, "csrf_token") and len(trim(variables.body.csrf_token))>
        <cfset variables.csrfToken = trim(variables.body.csrf_token)>
    </cfif>

    <cfif not len(variables.csrfToken) or variables.csrfToken neq session.csrf_token>
        <cfset returnError("CSRF_INVALID", "Invalid or missing CSRF token", 403)>
    </cfif>

    <!--- Read params --->
    <cfset variables.jobId = 0>
    <cfset variables.audsubcatid = 0>
    <cfif structKeyExists(variables.body, "job_id") and isNumeric(variables.body.job_id)>
        <cfset variables.jobId = val(variables.body.job_id)>
    </cfif>
    <cfif structKeyExists(variables.body, "audsubcatid") and isNumeric(variables.body.audsubcatid)>
        <cfset variables.audsubcatid = val(variables.body.audsubcatid)>
    </cfif>

    <cfif variables.jobId lte 0 or variables.audsubcatid lte 0>
        <cfset returnError("MISSING_PARAMS", "job_id and audsubcatid are required", 400)>
    </cfif>

    <!--- Call service --->
    <cfset variables.svc = new services.AuditionImportService()>
    <cfset variables.result = variables.svc.bulkSetCategory(
        job_id = variables.jobId,
        userid = variables.userid,
        audsubcatid = variables.audsubcatid
    )>

    <cfif variables.result.success>
        <cfset variables.response.success = true>
        <cfset variables.response.message = variables.result.message>
        <cfset variables.response.data = variables.result.data>
    <cfelse>
        <cfset variables.response.code = variables.result.code>
        <cfset variables.response.message = variables.result.message>
        <cfheader statuscode="400">
    </cfif>

    <cfcatch type="any">
        <cflog file="import_auditions" text="[bulk_category] ERROR userid=#variables.userid# err=#cfcatch.message#">
        <cfset variables.response.code = "INTERNAL_ERROR">
        <cfset variables.response.message = "Bulk category update failed: " & cfcatch.message>
        <cfheader statuscode="500">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>
