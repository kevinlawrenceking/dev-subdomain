<!--- This ColdFusion page retrieves events for the logged-in user based on their contact ID --->
<cfquery name="events">
    <!--- Query to fetch events for the logged-in user based on their contact ID --->
    SELECT 
        e.eventID,
        e.eventID AS recid,
        e.eventTitle,
        e.eventStart,
        e.eventStartTime
    FROM 
        events e 
    INNER JOIN 
        eventtypes_user t ON t.eventtypename = e.eventtypename
    WHERE 
        e.userid = #userid# 
        AND t.userid = #userid#
        AND e.eventid IN (
            SELECT 
                eventid 
            FROM 
                eventcontactsxref 
            WHERE 
                contactid = #rcontactid#
        )
</cfquery>
