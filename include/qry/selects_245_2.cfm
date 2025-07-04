<!--- This ColdFusion page retrieves a list of records from a specified table for selection purposes. --->

<cfquery name="selects">
    <!--- Query to select record names from the specified table and order them. --->
    select 
        recordname as value, 
        recordname as text 
    from 
        #RPGAdd.tableSelect# 
    order by 
        recordname
</cfquery>
