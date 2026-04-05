<!--- admin-enum-update.cfm
     POST endpoint: update an existing enum row's name and optional parent.
     Params: enum_id (integer), pk_value (string), name (string), parent_id (string, optional)
     Security: Administrator role required. Auth + CSRF handled by ajax/Application.cfc.
--->
<cfparam name="form.enum_id"   default="0" type="numeric">
<cfparam name="form.pk_value"  default="" type="string">
<cfparam name="form.name"      default="" type="string">
<cfparam name="form.parent_id" default="" type="string">

<cftry>

    <!--- Admin check: query DB directly since AJAX context has no fetchUsers --->
    <cfquery name="qAdminCheck" datasource="#request.dsn#" maxrows="1">
        SELECT userRole FROM taousers
        WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="cf_sql_integer">
    </cfquery>
    <cfif qAdminCheck.recordCount EQ 0 OR (qAdminCheck.userRole NEQ "Admin" AND qAdminCheck.userRole NEQ "Administrator")>
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
    <cfif NOT len(trim(form.name))>
        <cfcontent type="application/json" reset="true">
        <cfoutput>{"success":false,"message":"Name is required."}</cfoutput>
        <cfabort>
    </cfif>

    <cfset svc = request.svc("AdminEnumService")>
    <cfset result = svc.updateEnumRow(
        enum_id   = form.enum_id,
        pk_value  = form.pk_value,
        name      = form.name,
        parent_id = form.parent_id
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
