<!--- This ColdFusion page checks if a user is associated with a specific maintenance list based on contact ID and user ID. --->

<cfquery name="checkformaint" maxrows="1">
    <!--- Query to select user ID from fusystemusers where the user is linked to a maintenance list --->
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
