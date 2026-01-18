<!--- This ColdFusion page updates the event start time for events that currently have a NULL start time. --->

<cfquery name="t">
    <!--- Update the event start time to '12:00:00' for events with a NULL start time --->
    UPDATE events
    SET eventstarttime = '12:00:00'
    WHERE eventstarttime IS NULL
</cfquery>
