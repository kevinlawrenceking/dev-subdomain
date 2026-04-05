<!---
AJAX endpoint: Get full detail for a single error ticket.
GET /ajax/admin-error-tickets/detail.cfm

Params: ticket_id (the ERR-xxxxxxxx string)
Returns JSON: { success, data: { ...full ticket record... } }
--->
<cfif NOT isDefined("session.userrole") OR session.userrole IS NOT "Administrator">
    <cfheader statuscode="403" statustext="Forbidden" />
    <cfoutput>#serializeJSON({ "success": false, "message": "Access denied." })#</cfoutput>
    <cfabort />
</cfif>

<cfsetting showdebugoutput="false" />
<cfcontent type="application/json" />

<cfparam name="url.ticket_id" default="" />

<cfif NOT len(trim(url.ticket_id))>
    <cfoutput>#serializeJSON({ "success": false, "message": "Missing ticket_id parameter." })#</cfoutput>
    <cfabort />
</cfif>

<cftry>
    <cfquery name="qDetail" datasource="#application.dsn#">
        SELECT id, ticket_id, created_at, resolved, resolved_at, resolved_by, resolved_notes,
               user_id, user_email, error_type, error_message, error_detail,
               stack_trace, tag_context, sql_statement,
               script_name, query_string, http_method, http_referer,
               remote_ip, user_agent, form_data,
               cf_context, event_name, environment, cf_engine, server_name, email_sent
        FROM error_tickets
        WHERE ticket_id = <cfqueryparam value="#trim(url.ticket_id)#" cfsqltype="cf_sql_varchar" />
        LIMIT 1
    </cfquery>

    <cfif qDetail.recordCount EQ 0>
        <cfoutput>#serializeJSON({ "success": false, "message": "Ticket not found." })#</cfoutput>
        <cfabort />
    </cfif>

    <cfscript>
        t = {
            "id": qDetail.id,
            "ticket_id": qDetail.ticket_id,
            "created_at": len(qDetail.created_at) ? dateTimeFormat(qDetail.created_at, "yyyy-mm-dd HH:nn:ss") : "",
            "resolved": qDetail.resolved ? true : false,
            "resolved_at": (qDetail.resolved AND len(qDetail.resolved_at)) ? dateTimeFormat(qDetail.resolved_at, "yyyy-mm-dd HH:nn:ss") : "",
            "resolved_by": qDetail.resolved_by,
            "resolved_notes": qDetail.resolved_notes,
            "user_id": qDetail.user_id,
            "user_email": qDetail.user_email,
            "error_type": qDetail.error_type,
            "error_message": qDetail.error_message,
            "error_detail": qDetail.error_detail,
            "stack_trace": qDetail.stack_trace,
            "tag_context": qDetail.tag_context,
            "sql_statement": qDetail.sql_statement,
            "script_name": qDetail.script_name,
            "query_string": qDetail.query_string,
            "http_method": qDetail.http_method,
            "http_referer": qDetail.http_referer,
            "remote_ip": qDetail.remote_ip,
            "user_agent": qDetail.user_agent,
            "form_data": qDetail.form_data,
            "cf_context": qDetail.cf_context,
            "event_name": qDetail.event_name,
            "environment": qDetail.environment,
            "cf_engine": qDetail.cf_engine,
            "server_name": qDetail.server_name,
            "email_sent": qDetail.email_sent ? true : false
        };
    </cfscript>

    <cfoutput>#serializeJSON({ "success": true, "data": t })#</cfoutput>

    <cfcatch>
        <cflog file="TAO_error_tickets" type="error"
               text="detail.cfm error: #cfcatch.message# | #cfcatch.detail#" />
        <cfoutput>#serializeJSON({ "success": false, "message": "Failed to load ticket detail." })#</cfoutput>
    </cfcatch>
</cftry>
