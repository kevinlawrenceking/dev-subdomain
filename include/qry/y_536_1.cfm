<!--- This ColdFusion page retrieves table names from the information schema that start with 'aud' --->
<cfquery name="y">  
    <!--- Query to select table names from the information schema --->
    SELECT table_name AS new_comptable 
    FROM information_schema.tables 
    WHERE TABLE_NAME LIKE 'aud%';
</cfquery>
