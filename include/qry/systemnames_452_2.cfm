<!--- This ColdFusion page retrieves system names and their IDs from the fusystems table and orders them by system name. --->

<cfquery name="systemnames">                      
    <!--- Query to select system ID and name from the fusystems table --->
    SELECT systemid AS id, 
           systemname 
    FROM fusystems 
    ORDER BY systemname                    
</cfquery>
