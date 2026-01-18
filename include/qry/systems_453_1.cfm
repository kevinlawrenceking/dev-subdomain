<!--- This ColdFusion page retrieves system types and their names from the database. --->
<cfquery name="systems">
    <!--- Query to select system types and their corresponding names from the fusystemtypes table. --->
    SELECT systemtype AS ID, 
           systemtype AS systemname 
    FROM fusystemtypes 
    ORDER BY systemtype
</cfquery>
