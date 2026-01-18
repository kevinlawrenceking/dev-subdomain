<!--- This ColdFusion page updates the eventstop field in the events table where eventstop is NULL and eventstart is not NULL. --->

<cfquery name="dd">
    <!--- Update the eventstop field to match eventstart for events with NULL eventstop. --->
    UPDATE events 
    SET eventstop = eventstart 
    WHERE eventstop IS NULL 
    AND eventstart IS NOT NULL;
</cfquery>
