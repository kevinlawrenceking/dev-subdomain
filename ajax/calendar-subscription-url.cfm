<cfsilent>
<!--- ajax/calendar-subscription-url.cfm — return the user's ICS subscription URL,
      regenerating the .ics file synchronously first so the link is always current.
      Method: POST (CSRF enforced by ajax/Application.cfc)
      Auth:   session.userid required (gated by Application.cfc)
      TAO-CAL-01
--->

<cfset response = { "success": false, "url": "", "message": "" }>

<cftry>
    <cfif NOT structKeyExists(session, "userid") OR NOT isNumeric(session.userid) OR session.userid LTE 0>
        <cfheader statuscode="401">
        <cfset response.message = "Not signed in">
        <cfthrow message="no session">
    </cfif>

    <cfset uid = session.userid>

    <!--- Regenerate synchronously so the file exists and matches current DB state. --->
    <cfset request.svc("IcsService").generateUserIcs(uid)>

    <!--- Rebuild the URL from current session context so a stale value cannot be cached. --->
    <cfif structKeyExists(session, "userCalendarUrl") AND len(session.userCalendarUrl)>
        <cfset response.url = session.userCalendarUrl>
    <cfelse>
        <cfquery name="qUrl">
            SELECT REPLACE(REPLACE(recordname, ' ', ''), '-', '') AS calendarName
            FROM taousers
            WHERE userid = <cfqueryparam value="#uid#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfif qUrl.recordCount AND len(qUrl.calendarName)>
            <cfset response.url = "https://"
                & listFirst(cgi.server_name, ".")
                & ".theactorsoffice.com/media-" & application.dsn
                & "/calendar/" & qUrl.calendarName & ".ics">
        </cfif>
    </cfif>

    <cfset response.success = true>

    <cfcatch type="any">
        <cfif NOT len(response.message)>
            <cfset response.message = "Subscription link unavailable">
        </cfif>
        <cflog file="ics_service" type="error"
               text="calendar-subscription-url: userid=#structKeyExists(session,'userid') ? session.userid : 0# msg=#left(cfcatch.message,300)#">
    </cfcatch>
</cftry>

</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
