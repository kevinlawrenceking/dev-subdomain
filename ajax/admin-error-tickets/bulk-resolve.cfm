<!---
AJAX endpoint: Bulk-resolve multiple error tickets.
POST /ajax/admin-error-tickets/bulk-resolve.cfm

Params: ticket_ids (comma-separated list of ERR-xxxxxxxx strings), resolved_notes, csrf_token
Returns JSON: { success, message, data: { resolved_count } }
--->
<!--- Admin check: query DB directly since AJAX context has no fetchUsers --->
<cfquery name="qAdminCheck" datasource="#application.dsn#" maxrows="1">
    SELECT userRole FROM taousers
    WHERE userid = <cfqueryparam value="#session.userid#" cfsqltype="cf_sql_integer">
</cfquery>
<cfif qAdminCheck.recordCount EQ 0 OR (qAdminCheck.userRole NEQ "Admin" AND qAdminCheck.userRole NEQ "Administrator")>
    <cfheader statuscode="403" statustext="Forbidden" />
    <cfoutput>#serializeJSON({ "success": false, "message": "Access denied." })#</cfoutput>
    <cfabort />
</cfif>

<cfsetting showdebugoutput="false" />
<cfcontent type="application/json" />

<!--- Only accept POST --->
<cfif cgi.REQUEST_METHOD IS NOT "POST">
    <cfoutput>#serializeJSON({ "success": false, "message": "POST required." })#</cfoutput>
    <cfabort />
</cfif>

<cfparam name="form.ticket_ids" default="" />
<cfparam name="form.resolved_notes" default="" />
<cfparam name="form.csrf_token" default="" />

<!--- CSRF validation --->
<cfif NOT CSRFVerifyToken(form.csrf_token)>
    <cfoutput>#serializeJSON({ "success": false, "message": "Invalid security token. Please reload the page and try again." })#</cfoutput>
    <cfabort />
</cfif>

<!--- Validate ticket_ids --->
<cfif NOT len(trim(form.ticket_ids))>
    <cfoutput>#serializeJSON({ "success": false, "message": "No tickets selected." })#</cfoutput>
    <cfabort />
</cfif>

<cftry>
    <!--- Clean and validate the list: only allow ERR- prefixed IDs --->
    <cfscript>
        rawList = listToArray(trim(form.ticket_ids));
        cleanIds = [];
        for (item in rawList) {
            item = trim(item);
            if (len(item) AND left(item, 4) EQ "ERR-") {
                arrayAppend(cleanIds, item);
            }
        }
    </cfscript>

    <cfif arrayLen(cleanIds) EQ 0>
        <cfoutput>#serializeJSON({ "success": false, "message": "No valid ticket IDs provided." })#</cfoutput>
        <cfabort />
    </cfif>

    <cfquery datasource="#application.dsn#">
        UPDATE error_tickets
        SET resolved = 1,
            resolved_at = NOW(),
            resolved_by = <cfqueryparam value="#session.userid#" cfsqltype="cf_sql_integer" />,
            resolved_notes = <cfqueryparam value="#trim(form.resolved_notes)#" cfsqltype="cf_sql_longvarchar" null="#NOT len(trim(form.resolved_notes))#" />
        WHERE ticket_id IN (
            <cfloop from="1" to="#arrayLen(cleanIds)#" index="i">
                <cfqueryparam value="#cleanIds[i]#" cfsqltype="cf_sql_varchar" />
                <cfif i LT arrayLen(cleanIds)>,</cfif>
            </cfloop>
        )
        AND resolved = 0
    </cfquery>

    <cflog file="TAO_error_tickets" type="info"
           text="Bulk resolve: #arrayLen(cleanIds)# ticket(s) resolved by user #session.userid#" />

    <cfoutput>#serializeJSON({
        "success": true,
        "message": arrayLen(cleanIds) & " ticket(s) resolved.",
        "data": { "resolved_count": arrayLen(cleanIds) }
    })#</cfoutput>

    <cfcatch>
        <cflog file="TAO_error_tickets" type="error"
               text="bulk-resolve.cfm error: #cfcatch.message# | #cfcatch.detail#" />
        <cfoutput>#serializeJSON({ "success": false, "message": "Failed to bulk-resolve tickets." })#</cfoutput>
    </cfcatch>
</cftry>
