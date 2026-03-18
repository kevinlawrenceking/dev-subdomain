<cfsilent>
<!--- ajax/calendar-events.cfm — JSON feed for FullCalendar v6
      Method: GET
      Params: start (ISO 8601), end (ISO 8601) — sent automatically by FullCalendar
      Returns: JSON array of event objects
      Auth: session.userid enforced by ajax/Application.cfc onRequestStart
--->

<!--- Date range from FullCalendar (ISO 8601 strings like "2026-03-01T00:00:00-08:00") --->
<cfparam name="url.start" default="" />
<cfparam name="url.end" default="" />

<!--- Parse and validate date range --->
<cfset rangeStart = "">
<cfset rangeEnd = "">
<cfif len(url.start) AND isDate(url.start)>
    <cfset rangeStart = createODBCDate(url.start)>
</cfif>
<cfif len(url.end) AND isDate(url.end)>
    <cfset rangeEnd = createODBCDate(url.end)>
</cfif>

<!--- Query events for this user with date-range filtering --->
<cfquery name="events">
    SELECT
        e.eventID,
        e.eventTitle,
        e.eventDescription,
        e.eventStart,
        e.eventStop,
        e.eventStartTime,
        e.eventStopTime,
        e.eventTypeName,
        e.dow,
        e.endRecur,
        t.id AS eventtypeId,
        t.eventtypecolor,
        r.audprojectid
    FROM events e
    INNER JOIN eventtypes_user t
        ON t.eventtypename = e.eventtypename
        AND t.userid = <cfqueryparam value="#userid#" cfsqltype="CF_SQL_INTEGER">
    LEFT JOIN audroles r
        ON r.audroleid = e.audroleid
    WHERE e.userid = <cfqueryparam value="#userid#" cfsqltype="CF_SQL_INTEGER">
        AND e.isdeleted = 0
        <!--- Dedup: keep only lowest eventid per unique event --->
        AND e.eventid = (
            SELECT MIN(e2.eventid)
            FROM events e2
            WHERE e2.eventtitle = e.eventtitle
                AND e2.eventstart = e.eventstart
                AND (e2.eventstarttime = e.eventstarttime
                     OR (e2.eventstarttime IS NULL AND e.eventstarttime IS NULL))
                AND e2.eventstatus = e.eventstatus
                AND e2.userid = e.userid
                AND e2.isdeleted = 0
        )
        <!--- Date range filter: include if event or recurrence overlaps view window --->
        <cfif isDate(rangeStart) AND isDate(rangeEnd)>
            AND (
                <!--- Non-recurring events: start date within range --->
                (e.dow IS NULL OR e.dow = '')
                AND e.eventStart >= <cfqueryparam value="#rangeStart#" cfsqltype="CF_SQL_DATE">
                AND e.eventStart < <cfqueryparam value="#rangeEnd#" cfsqltype="CF_SQL_DATE">
            ) OR (
                <!--- Recurring events: recurrence period overlaps range --->
                (e.dow IS NOT NULL AND e.dow != '')
                AND e.eventStart <= <cfqueryparam value="#rangeEnd#" cfsqltype="CF_SQL_DATE">
                AND (e.endRecur IS NULL
                     OR e.endRecur = ''
                     OR e.endRecur >= <cfqueryparam value="#rangeStart#" cfsqltype="CF_SQL_DATE">)
            )
        </cfif>
    ORDER BY e.eventStart, e.eventStartTime
</cfquery>

<!--- Build JSON array --->
<cfset eventArray = []>
<cfloop query="events">

    <!--- === Time validation/correction logic (migrated from calendar2.cfm) === --->
    <cfset eventStartDate = events.eventStart>
    <cfset eventStartTime = events.eventStartTime>
    <cfset eventStopDate = events.eventStop>
    <cfset eventStopTime = events.eventStopTime>

    <!--- Ensure valid start date and time --->
    <cfif NOT isDate(eventStartDate)>
        <cfset eventStartDate = now()>
    </cfif>
    <cfif NOT isDate(eventStartTime)>
        <cfset eventStartTime = createTime(9, 0, 0)>
    </cfif>

    <!--- Fix missing or invalid stop date --->
    <cfif NOT isDate(eventStopDate) OR dateCompare(eventStopDate, eventStartDate) LT 0>
        <cfset eventStopDate = eventStartDate>
    </cfif>

    <!--- Fix missing or invalid stop time --->
    <cfif NOT isDate(eventStopTime)>
        <cfset eventStopTime = createTime(hour(eventStartTime) + 1, minute(eventStartTime), 0)>
    <cfelseif dateCompare(eventStopDate, eventStartDate) EQ 0>
        <cfset startMinutes = hour(eventStartTime) * 60 + minute(eventStartTime)>
        <cfset stopMinutes = hour(eventStopTime) * 60 + minute(eventStopTime)>
        <cfif stopMinutes LTE startMinutes>
            <cfset newHour = hour(eventStartTime) + 1>
            <cfif newHour GTE 24>
                <cfset newHour = 23>
                <cfset newMinute = 59>
            <cfelse>
                <cfset newMinute = minute(eventStartTime)>
            </cfif>
            <cfset eventStopTime = createTime(newHour, newMinute, 0)>
        </cfif>
    </cfif>
    <!--- === End validation === --->

    <!--- Build event object --->
    <cfset evt = {}>
    <cfset evt["id"] = events.eventID>
    <cfset evt["title"] = events.eventTitle>
    <cfset evt["className"] = "colorkey-#events.eventtypeId#">
    <cfset evt["allDay"] = false>

    <!--- URL: appointment vs audition --->
    <cfif len(events.audprojectid) AND events.audprojectid NEQ "">
        <cfset evt["url"] = "/app/audition/?focusid=#events.eventID#&audprojectid=#events.audprojectid#">
    <cfelse>
        <cfset evt["url"] = "/app/appoint/?eventid=#events.eventID#&returnurl=calendar-appoint&rcontactid=0">
    </cfif>

    <!--- Recurring vs one-time event --->
    <cfif len(trim(events.dow)) AND events.dow NEQ "">
        <!--- Recurring event: use v6 native recurrence fields --->
        <cfset evt["groupId"] = "recurring#events.eventID#">
        <cfset evt["startRecur"] = dateFormat(eventStartDate, "yyyy-mm-dd")>
        <cfset evt["daysOfWeek"] = listToArray(trim(events.dow))>
        <cfset evt["startTime"] = timeFormat(eventStartTime, "HH:mm")>
        <cfset evt["endTime"] = timeFormat(eventStopTime, "HH:mm")>
        <cfif len(trim(events.endRecur)) AND isDate(events.endRecur)>
            <cfset evt["endRecur"] = dateFormat(events.endRecur, "yyyy-mm-dd")>
        </cfif>
    <cfelse>
        <!--- One-time event --->
        <cfset evt["start"] = dateFormat(eventStartDate, "yyyy-mm-dd") & "T" & timeFormat(eventStartTime, "HH:mm:ss")>
        <cfset evt["end"] = dateFormat(eventStopDate, "yyyy-mm-dd") & "T" & timeFormat(eventStopTime, "HH:mm:ss")>
    </cfif>

    <cfset arrayAppend(eventArray, evt)>
</cfloop>

</cfsilent>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#serializeJSON(eventArray)#</cfoutput>
