<cfsilent>
<!--- ajax/calendar-event-update.cfm — Update event start/end via drag-and-drop
      Method: POST (JSON body)
      Body: { eventid: int, start: ISO8601, end: ISO8601|null }
      Auth: session.userid enforced by ajax/Application.cfc
      CSRF: X-CSRF-Token header validated by ajax/Application.cfc
--->

<cfset response = { "success": false, "message": "" }>

<cftry>
    <!--- Parse JSON body --->
    <cfset requestBody = toString(getHTTPRequestData().content)>
    <cfif NOT len(requestBody)>
        <cfheader statuscode="400">
        <cfset response.message = "Request body is required">
        <cfthrow message="empty body">
    </cfif>

    <cfset payload = deserializeJSON(requestBody)>

    <!--- Validate required fields --->
    <cfif NOT structKeyExists(payload, "eventid") OR NOT isNumeric(payload.eventid)>
        <cfheader statuscode="400">
        <cfset response.message = "Valid eventid is required">
        <cfthrow message="invalid eventid">
    </cfif>
    <cfif NOT structKeyExists(payload, "start") OR NOT isDate(payload.start)>
        <cfheader statuscode="400">
        <cfset response.message = "Valid start datetime is required">
        <cfthrow message="invalid start">
    </cfif>

    <cfset eventId = int(payload.eventid)>
    <cfset newStart = payload.start>
    <cfset newEnd = structKeyExists(payload, "end") AND isDate(payload.end) ? payload.end : "">

    <!--- Parse start date and time --->
    <cfset newStartDate = createODBCDate(newStart)>
    <cfset newStartTime = createODBCTime(newStart)>

    <!--- Parse end date and time (if provided) --->
    <cfif len(newEnd)>
        <cfset newStopDate = createODBCDate(newEnd)>
        <cfset newStopTime = createODBCTime(newEnd)>
    <cfelse>
        <!--- No end provided: default to start + 1 hour --->
        <cfset newStopDate = newStartDate>
        <cfset newStopTime = createODBCTime(dateAdd("h", 1, newStart))>
    </cfif>

    <!--- Verify ownership: event must belong to current user --->
    <cfquery name="checkOwner">
        SELECT eventid FROM events
        WHERE eventid = <cfqueryparam value="#eventId#" cfsqltype="CF_SQL_INTEGER">
            AND userid = <cfqueryparam value="#userid#" cfsqltype="CF_SQL_INTEGER">
            AND isdeleted = 0
    </cfquery>

    <cfif checkOwner.recordCount EQ 0>
        <cfheader statuscode="403">
        <cfset response.message = "Event not found or access denied">
        <cfthrow message="ownership check failed">
    </cfif>

    <!--- Update the event --->
    <cfquery>
        UPDATE events
        SET eventStart = <cfqueryparam value="#newStartDate#" cfsqltype="CF_SQL_DATE">,
            eventStartTime = <cfqueryparam value="#newStartTime#" cfsqltype="CF_SQL_TIME">,
            eventStop = <cfqueryparam value="#newStopDate#" cfsqltype="CF_SQL_DATE">,
            eventStopTime = <cfqueryparam value="#newStopTime#" cfsqltype="CF_SQL_TIME">
        WHERE eventid = <cfqueryparam value="#eventId#" cfsqltype="CF_SQL_INTEGER">
            AND userid = <cfqueryparam value="#userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

    <cfset response.success = true>
    <cfset response.message = "Event updated">
    <cflog file="tao_calendar" text="[event-update] eventid=#eventId# moved by user=#userid#">

<cfcatch type="any">
    <cfif NOT len(response.message)>
        <cfset response.message = "Update failed">
    </cfif>
    <cflog file="tao_calendar" type="error" text="[event-update] #cfcatch.message# user=#userid#">
</cfcatch>
</cftry>

</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(response)#</cfoutput>
