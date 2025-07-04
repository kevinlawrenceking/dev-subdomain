<!--- This ColdFusion page retrieves ticket statuses for display. --->
<cfquery name="statuses">
    <!--- Retrieve ticket statuses for display. --->
    SELECT 
        'Completed' AS id, 
        'Completed' AS name 
    FROM 
        ticketstatuses 
    UNION
    SELECT 
        'Pending' AS id, 
        'Pending' AS name 
    FROM 
        ticketstatuses 
</cfquery>
