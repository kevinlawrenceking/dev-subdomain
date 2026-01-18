<!--- This ColdFusion page retrieves event types for a specific user from the database. --->

<cfquery name="types">
    SELECT eventtypename 
    FROM eventtypes_user 
    WHERE userid = #userid# 
    ORDER BY eventtypename
</cfquery>
