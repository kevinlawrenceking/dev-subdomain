<cfset dsn = "abod">

<!--- Fetch all events with missing or invalid end times --->
<cfquery name="getEvents" datasource="#dsn#">
    SELECT eventid, eventstarttime, eventstoptime
    FROM events_tbl
    WHERE eventstoptime IS NULL
       OR eventstoptime <= eventstarttime
</cfquery>

<cfloop query="getEvents">
    <!--- Add 1 hour to the start time --->
    <cfset newStopTime = dateAdd("n", 60, getEvents.eventstarttime)>

    <!--- Update the row --->
    <cfquery datasource="#dsn#">
        UPDATE events_tbl
        SET eventstoptime = <cfqueryparam value="#newStopTime#" cfsqltype="cf_sql_timestamp">
        WHERE eventid = <cfqueryparam value="#getEvents.eventid#" cfsqltype="cf_sql_integer">
    </cfquery>
</cfloop>

<cfoutput>Updated #getEvents.recordCount# events.</cfoutput>
