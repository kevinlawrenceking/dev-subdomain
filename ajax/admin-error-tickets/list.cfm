<!---
AJAX endpoint: List error tickets with filtering and pagination.
GET /ajax/admin-error-tickets/list.cfm

Params: status, date_from, date_to, search, environment, page, pageSize
Returns JSON: { success, data: { tickets, total, page, pageSize } }
--->
<cfif NOT isDefined("session.userrole") OR session.userrole IS NOT "Administrator">
    <cfheader statuscode="403" statustext="Forbidden" />
    <cfoutput>#serializeJSON({ "success": false, "message": "Access denied." })#</cfoutput>
    <cfabort />
</cfif>

<cfsetting showdebugoutput="false" />
<cfcontent type="application/json" />

<cfparam name="url.status" default="unresolved" />
<cfparam name="url.date_from" default="" />
<cfparam name="url.date_to" default="" />
<cfparam name="url.search" default="" />
<cfparam name="url.environment" default="" />
<cfparam name="url.page" default="1" />
<cfparam name="url.pageSize" default="50" />

<cfscript>
    pageNum = max(1, val(url.page));
    pageSz = max(1, min(200, val(url.pageSize)));
    offset = (pageNum - 1) * pageSz;
</cfscript>

<cftry>
    <!--- Count query --->
    <cfquery name="qCount" datasource="#application.dsn#">
        SELECT COUNT(*) AS total
        FROM error_tickets
        WHERE 1=1
        <cfif url.status EQ "unresolved">
            AND resolved = 0
        <cfelseif url.status EQ "resolved">
            AND resolved = 1
        </cfif>
        <cfif len(trim(url.date_from)) AND isDate(url.date_from)>
            AND created_at >= <cfqueryparam value="#url.date_from# 00:00:00" cfsqltype="cf_sql_timestamp" />
        </cfif>
        <cfif len(trim(url.date_to)) AND isDate(url.date_to)>
            AND created_at <= <cfqueryparam value="#url.date_to# 23:59:59" cfsqltype="cf_sql_timestamp" />
        </cfif>
        <cfif len(trim(url.environment))>
            AND environment = <cfqueryparam value="#url.environment#" cfsqltype="cf_sql_varchar" />
        </cfif>
        <cfif len(trim(url.search))>
            AND (
                ticket_id LIKE <cfqueryparam value="%#trim(url.search)#%" cfsqltype="cf_sql_varchar" />
                OR error_message LIKE <cfqueryparam value="%#trim(url.search)#%" cfsqltype="cf_sql_varchar" />
                OR script_name LIKE <cfqueryparam value="%#trim(url.search)#%" cfsqltype="cf_sql_varchar" />
                OR user_email LIKE <cfqueryparam value="%#trim(url.search)#%" cfsqltype="cf_sql_varchar" />
            )
        </cfif>
    </cfquery>

    <!--- Data query --->
    <cfquery name="qTickets" datasource="#application.dsn#">
        SELECT id, ticket_id, created_at, resolved, resolved_at, resolved_by, resolved_notes,
               user_id, user_email, error_type, error_message, script_name,
               environment, email_sent
        FROM error_tickets
        WHERE 1=1
        <cfif url.status EQ "unresolved">
            AND resolved = 0
        <cfelseif url.status EQ "resolved">
            AND resolved = 1
        </cfif>
        <cfif len(trim(url.date_from)) AND isDate(url.date_from)>
            AND created_at >= <cfqueryparam value="#url.date_from# 00:00:00" cfsqltype="cf_sql_timestamp" />
        </cfif>
        <cfif len(trim(url.date_to)) AND isDate(url.date_to)>
            AND created_at <= <cfqueryparam value="#url.date_to# 23:59:59" cfsqltype="cf_sql_timestamp" />
        </cfif>
        <cfif len(trim(url.environment))>
            AND environment = <cfqueryparam value="#url.environment#" cfsqltype="cf_sql_varchar" />
        </cfif>
        <cfif len(trim(url.search))>
            AND (
                ticket_id LIKE <cfqueryparam value="%#trim(url.search)#%" cfsqltype="cf_sql_varchar" />
                OR error_message LIKE <cfqueryparam value="%#trim(url.search)#%" cfsqltype="cf_sql_varchar" />
                OR script_name LIKE <cfqueryparam value="%#trim(url.search)#%" cfsqltype="cf_sql_varchar" />
                OR user_email LIKE <cfqueryparam value="%#trim(url.search)#%" cfsqltype="cf_sql_varchar" />
            )
        </cfif>
        ORDER BY created_at DESC
        LIMIT <cfqueryparam value="#pageSz#" cfsqltype="cf_sql_integer" />
        OFFSET <cfqueryparam value="#offset#" cfsqltype="cf_sql_integer" />
    </cfquery>

    <cfscript>
        tickets = [];
        for (row in qTickets) {
            arrayAppend(tickets, {
                "id": row.id,
                "ticket_id": row.ticket_id,
                "created_at": len(row.created_at) ? dateTimeFormat(row.created_at, "yyyy-mm-dd HH:nn:ss") : "",
                "resolved": row.resolved ? true : false,
                "resolved_at": (row.resolved AND len(row.resolved_at)) ? dateTimeFormat(row.resolved_at, "yyyy-mm-dd HH:nn:ss") : "",
                "resolved_by": row.resolved_by,
                "resolved_notes": row.resolved_notes,
                "user_id": row.user_id,
                "user_email": row.user_email,
                "error_type": row.error_type,
                "error_message": row.error_message,
                "script_name": row.script_name,
                "environment": row.environment,
                "email_sent": row.email_sent ? true : false
            });
        }

        result = {
            "success": true,
            "data": {
                "tickets": tickets,
                "total": qCount.total,
                "page": pageNum,
                "pageSize": pageSz
            }
        };
    </cfscript>

    <cfoutput>#serializeJSON(result)#</cfoutput>

    <cfcatch>
        <cflog file="TAO_error_tickets" type="error"
               text="list.cfm error: #cfcatch.message# | #cfcatch.detail#" />
        <cfoutput>#serializeJSON({ "success": false, "message": "Failed to load tickets." })#</cfoutput>
    </cfcatch>
</cftry>
