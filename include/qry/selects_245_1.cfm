<!--- This ColdFusion page retrieves a list of values and text from a specified table and orders them by record name. --->

<cfquery name="selects">
    <!--- Query to select the first name and record name from the specified table, ordered by record name --->
    select #rpgadd.fname# as value, 
           recordname as text 
    from #rpgadd.tableSelect# 
    order by recordname
</cfquery>
