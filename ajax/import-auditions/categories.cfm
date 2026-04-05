<cfsilent>
<!---
    Audition Import - Category Options Endpoint
    GET /ajax/import-auditions/categories.cfm

    Returns the available audition categories (with "Other" subcategory IDs)
    for use in the review grid category dropdown.

    Response: { success: true, data: { options: [{ audcatid, audcatname, audsubcatid }] } }
--->

<cfset variables.response = {
    "success": false,
    "code": "",
    "message": "",
    "data": {}
}>

<cftry>
    <!--- Auth --->
    <cfif not structKeyExists(session, "userid") or not isNumeric(session.userid) or session.userid lte 0>
        <cfset variables.response.code = "AUTH_REQUIRED">
        <cfset variables.response.message = "Authentication required">
        <cfheader statuscode="401">
    <cfelse>
        <cfset variables.svc = new services.AuditionImportService()>
        <cfset variables.result = variables.svc.getCategoryOptions()>
        <cfif variables.result.success>
            <cfset variables.response.success = true>
            <cfset variables.response.data = variables.result.data>
        <cfelse>
            <cfset variables.response.code = variables.result.code>
            <cfset variables.response.message = variables.result.message>
            <cfheader statuscode="500">
        </cfif>
    </cfif>

    <cfcatch type="any">
        <cfset variables.response.code = "INTERNAL_ERROR">
        <cfset variables.response.message = "Failed to load categories: " & cfcatch.message>
        <cfheader statuscode="500">
    </cfcatch>
</cftry>
</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(variables.response)#</cfoutput>
