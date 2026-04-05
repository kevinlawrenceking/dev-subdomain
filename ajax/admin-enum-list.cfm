<!--- admin-enum-list.cfm
     GET endpoint: returns JSON rows + metadata for a single enum panel.
     Params: enum_id (integer)
     Security: Administrator role required. Auth + CSRF handled by ajax/Application.cfc.
--->
<cfparam name="url.enum_id" default="0" type="numeric">

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

    <cfset svc = request.svc("AdminEnumService")>

    <!--- Load enum definition for metadata --->
    <cfquery name="qDef" datasource="#request.dsn#">
        SELECT enum_id, display_name, parent_table, parent_label,
               fk_column, is_read_only
        FROM   admin_enums
        WHERE  enum_id   = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#url.enum_id#">
          AND  is_active = 1
    </cfquery>

    <cfif qDef.recordCount EQ 0>
        <cfheader statuscode="404">
        <cfcontent type="application/json" reset="true">
        <cfoutput>{"success":false,"message":"Enum not found."}</cfoutput>
        <cfabort>
    </cfif>

    <!--- Get rows --->
    <cfset qRows = svc.getEnumRows(url.enum_id)>

    <!--- Build response --->
    <cfset rows = []>
    <cfloop query="qRows">
        <cfset row = { "id" = qRows.id, "name" = qRows.name }>
        <cfif listFindNoCase(qRows.columnList, "parent_name")>
            <cfset row["parent_name"] = qRows.parent_name>
            <cfset row["parent_id"]   = qRows.parent_id>
        </cfif>
        <cfset arrayAppend(rows, row)>
    </cfloop>

    <cfset enumMeta = {
        "display_name" = qDef.display_name,
        "has_parent"   = len(trim(qDef.parent_table)) GT 0,
        "parent_label" = len(trim(qDef.parent_label)) ? qDef.parent_label : "Parent",
        "is_read_only" = qDef.is_read_only
    }>

    <cfset response = { "success" = true, "message" = "", "data" = { "rows" = rows, "enum" = enumMeta } }>

    <cfcontent type="application/json" reset="true">
    <cfoutput>#serializeJSON(response)#</cfoutput>

<cfcatch type="any">
    <cfheader statuscode="500">
    <cfcontent type="application/json" reset="true">
    <cfoutput>{"success":false,"message":"#encodeForJavaScript(cfcatch.message)#"}</cfoutput>
</cfcatch>
</cftry>
