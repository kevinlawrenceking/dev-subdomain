<!--- admin-enum-delete.cfm
     POST endpoint: soft-delete or hard-delete an enum row.
     Params: enum_id (integer), pk_value (string)
     Security: Administrator role required. Auth + CSRF handled by ajax/Application.cfc.
--->
<cfparam name="form.enum_id"  default="0" type="numeric">
<cfparam name="form.pk_value" default="" type="string">

<cftry>

    <!--- Admin check --->
    <cfif NOT structKeyExists(session, "userrole") OR session.userrole NEQ "Administrator">
        <cfheader statuscode="403">
        <cfcontent type="application/json" reset="true">
        <cfoutput>{"success":false,"message":"Administrator access required."}</cfoutput>
        <cfabort>
    </cfif>

    <!--- Validate required fields --->
    <cfif form.enum_id EQ 0>
        <cfcontent type="application/json" reset="true">
        <cfoutput>{"success":false,"message":"enum_id is required."}</cfoutput>
        <cfabort>
    </cfif>
    <cfif NOT len(trim(form.pk_value))>
        <cfcontent type="application/json" reset="true">
        <cfoutput>{"success":false,"message":"pk_value is required."}</cfoutput>
        <cfabort>
    </cfif>

    <cfset svc = request.svc("AdminEnumService")>
    <cfset result = svc.deleteEnumRow(
        enum_id  = form.enum_id,
        pk_value = form.pk_value
    )>

    <cfset response = {
        "success" = result.success,
        "message" = result.message,
        "data"    = {}
    }>

    <cfcontent type="application/json" reset="true">
    <cfoutput>#serializeJSON(response)#</cfoutput>

<cfcatch type="any">
    <cfheader statuscode="500">
    <cfcontent type="application/json" reset="true">
    <cfoutput>{"success":false,"message":"#encodeForJavaScript(cfcatch.message)#"}</cfoutput>
</cfcatch>
</cftry>
