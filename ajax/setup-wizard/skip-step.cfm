<!---
    P11: Skip Step
    POST endpoint that advances setup_step without saving data.
    Auth and CSRF are handled by ajax/Application.cfc.

    Params: step (current step number)
    Returns: JSON {success, nextStep}
--->
<cfset requestData = {}>
<cfset contentType = cgi.CONTENT_TYPE>

<!--- Accept both form-encoded and JSON body --->
<cfif findNoCase("application/json", contentType)>
    <cfset rawBody = toString(getHTTPRequestData().content)>
    <cfif len(trim(rawBody))>
        <cfset requestData = deserializeJSON(rawBody)>
    </cfif>
<cfelse>
    <cfset requestData = form>
</cfif>

<cfset currentStep = val(structKeyExists(requestData, "step") ? requestData.step : 0)>
<cfset userid = session.userid>

<!--- Calculate next step (skip step 4 if audition module is off) --->
<cfset nextStep = currentStep + 1>

<!--- Check audition module flag --->
<cfquery name="qUser" datasource="#application.datasource#" maxrows="1">
    SELECT isAuditionModule
    FROM taousers
    WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
</cfquery>

<cfif qUser.recordCount AND val(qUser.isAuditionModule) EQ 0 AND nextStep EQ 4>
    <cfset nextStep = 5>
</cfif>

<cfif nextStep GT 7>
    <cfset nextStep = 7>
</cfif>

<!--- Update setup_step in DB --->
<cfquery datasource="#application.datasource#">
    UPDATE taousers_tbl
    SET setup_step = <cfqueryparam value="#currentStep#" cfsqltype="cf_sql_tinyint" />
    WHERE userid = <cfqueryparam value="#userid#" cfsqltype="cf_sql_integer" />
</cfquery>

<!--- Update session --->
<cfset session.setup_step = currentStep>

<cfcontent type="application/json; charset=utf-8" reset="true">
<cfoutput>#serializeJSON({
    "success": true,
    "nextStep": nextStep
})#</cfoutput>
