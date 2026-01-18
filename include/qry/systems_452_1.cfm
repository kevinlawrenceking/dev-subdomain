<!--- This page retrieves system types from the database for further processing or display. --->

<cfquery name="systems">                      
    <!--- Query to select system types from the fusystemtypes table. --->
    SELECT 
        systemtype AS ID, 
        systemtype AS systemname 
    FROM 
        fusystemtypes 
    ORDER BY 
        systemtype                       
</cfquery>
