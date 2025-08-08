<cfset dsn = "abod">

<!--- Fetch all events with missing or invalid end times --->
<cfquery name="getEvents" datasource="#dsn#">
    SELECT eventid, eventstarttime, eventstoptime, eventstart
    FROM events_tbl
    WHERE eventstoptime IS NULL
       OR eventstoptime <= eventstarttime
       OR eventstart IS NULL
</cfquery>

<cfset updatedCount = 0>

<cfloop query="getEvents">
    <cfset validStartTime = false>
    <cfset newStopTime = "">
    
    <!--- Check if we have a valid start time --->
    <cfif isDate(getEvents.eventstarttime)>
        <cfset validStartTime = true>
        <!--- Add 1 hour to the start time --->
        <cfset newStopTime = dateAdd("n", 60, getEvents.eventstarttime)>
    <cfelseif isDate(getEvents.eventstart)>
        <!--- If no start time but we have start date, create a default time --->
        <cfset defaultStartTime = createDateTime(year(getEvents.eventstart), month(getEvents.eventstart), day(getEvents.eventstart), 9, 0, 0)>
        <cfset defaultStopTime = createDateTime(year(getEvents.eventstart), month(getEvents.eventstart), day(getEvents.eventstart), 10, 0, 0)>
        <cfset validStartTime = true>
        
        <!--- Update both start and stop times --->
        <cfquery datasource="#dsn#">
            UPDATE events_tbl
            SET eventstarttime = <cfqueryparam value="#defaultStartTime#" cfsqltype="cf_sql_timestamp">,
                eventstoptime = <cfqueryparam value="#defaultStopTime#" cfsqltype="cf_sql_timestamp">
            WHERE eventid = <cfqueryparam value="#getEvents.eventid#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfset updatedCount = updatedCount + 1>
        <cfcontinue>
    </cfif>
    
    <!--- Only update if we have a valid start time --->
    <cfif validStartTime AND newStopTime NEQ "">
        <cfquery datasource="#dsn#">
            UPDATE events_tbl
            SET eventstoptime = <cfqueryparam value="#newStopTime#" cfsqltype="cf_sql_timestamp">
            WHERE eventid = <cfqueryparam value="#getEvents.eventid#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfset updatedCount = updatedCount + 1>
    </cfif>
</cfloop>

<cfoutput>
    <h3>Calendar Fix Results</h3>
    <p>Total events found with issues: #getEvents.recordCount#</p>
    <p>Successfully updated: #updatedCount# events</p>
    <p>Skipped (invalid data): #getEvents.recordCount - updatedCount# events</p>
</cfoutput>
