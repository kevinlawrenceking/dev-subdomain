<!--- This ColdFusion page retrieves a list of values and text from a specified table and orders the results by record name. --->

<cfquery name="selects">
    <!--- Query to select values and text from the specified table, ordered by record name --->
    select #rpgupdate.fname# as value, 
           recordname as text 
    from #RPgupdate.tableSelect# 
    order by recordname
</cfquery>
