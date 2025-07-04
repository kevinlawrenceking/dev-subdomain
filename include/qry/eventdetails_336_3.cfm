<!--- This ColdFusion page retrieves event details based on the provided event ID. --->

<cfquery name="eventdetails">
    SELECT 
        e.eventID,
        e.eventID AS recid,
        e.eventTitle,
        e.eventDescription,
        e.eventLocation,
        e.eventStatus,
        e.eventCreation,
        e.eventStart,
        e.eventStop,
        e.eventTypeName,
        e.userid,
        e.eventStartTime,
        e.eventStopTime,
        e.contactid,
        e.dow,
        e.endRecur
    FROM 
        events e
    WHERE 
        e.eventid = #eventid#
</cfquery>
