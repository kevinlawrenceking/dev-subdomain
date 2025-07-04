<!--- This ColdFusion page retrieves active contact details for the current user from the database. --->

<cfquery name="results">
    <!--- Query to select active contacts for the logged-in user --->
    SELECT 
        d.contactid, 
        d.recordname AS col1
    FROM 
        contactdetails d
    WHERE 
        d.contactstatus = 'Active'
        AND d.userid = #userid#
    ORDER BY 
        d.contactfullname
</cfquery>
