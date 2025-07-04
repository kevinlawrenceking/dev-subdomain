<!--- This ColdFusion page retrieves active contact details for a specific user from the database. --->

<cfquery name="contacts">
    SELECT 
        d.contactid,
        d.recordname
    FROM 
        contactdetails d
    WHERE 
        d.contactStatus = 'Active' 
        AND d.userid = <cfqueryparam value="#userid#" cfsqltype="CF_SQL_INTEGER" />
    ORDER BY 
        d.contactfullname
</cfquery>
