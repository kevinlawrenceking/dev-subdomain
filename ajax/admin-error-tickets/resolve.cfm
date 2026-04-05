<!---
AJAX endpoint: Resolve a single error ticket.
POST /ajax/admin-error-tickets/resolve.cfm

Params: ticket_id, resolved_notes, csrf_token
Returns JSON: { success, message }
--->
<cfif NOT isDefined("session.userrole") OR session.userrole IS NOT "Administrator">
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

<cfparam name="form.ticket_id" default="" />
<cfparam name="form.resolved_notes" default="" />
<cfparam name="form.csrf_token" default="" />

<!--- CSRF validation --->
<cfif NOT CSRFVerifyToken(form.csrf_token)>
    <cfoutput>#serializeJSON({ "success": false, "message": "Invalid security token. Please reload the page and try again." })#</cfoutput>
    <cfabort />
</cfif>

<!--- Validate ticket_id --->
<cfif NOT len(trim(form.ticket_id))>
    <cfoutput>#serializeJSON({ "success": false, "message": "Missing ticket_id." })#</cfoutput>
    <cfabort />
</cfif>

<cftry>
    <cfquery datasource="#application.dsn#">
        UPDATE error_tickets
        SET resolved = 1,
            resolved_at = NOW(),
            resolved_by = <cfqueryparam value="#session.userid#" cfsqltype="cf_sql_integer" />,
            resolved_notes = <cfqueryparam value="#trim(form.resolved_notes)#" cfsqltype="cf_sql_longvarchar" null="#NOT len(trim(form.resolved_notes))#" />
        WHERE ticket_id = <cfqueryparam value="#trim(form.ticket_id)#" cfsqltype="cf_sql_varchar" />
          AND resolved = 0
    </cfquery>

    <cflog file="TAO_error_tickets" type="info"
           text="Ticket #form.ticket_id# resolved by user #session.userid#" />

    <cfoutput>#serializeJSON({ "success": true, "message": "Ticket resolved." })#</cfoutput>

    <cfcatch>
        <cflog file="TAO_error_tickets" type="error"
               text="resolve.cfm error: #cfcatch.message# | #cfcatch.detail#" />
        <cfoutput>#serializeJSON({ "success": false, "message": "Failed to resolve ticket." })#</cfoutput>
    </cfcatch>
</cftry>
