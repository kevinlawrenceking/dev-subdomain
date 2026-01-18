<!--- This ColdFusion page retrieves a user's ID from the maintenance list based on the contact ID and user ID provided. --->

<cfquery name="checkformaint" maxrows="1">
    <!--- Query to select the user ID from fusystemusers where the contact ID and user ID match and the system type is 'Maintenance List' --->
    SELECT
        fc.suID
    FROM 
        fusystemusers fc
    INNER JOIN 
        fusystems s ON s.systemID = fc.systemID
    WHERE 
        fc.contactid = #contactid# 
        AND s.systemtype = 'Maintenance List' 
        AND fc.userid = #userid#
</cfquery>
