<!--- This ColdFusion page retrieves a list of values and texts from a specified table and orders them by record name. --->
<cfquery name="selects">
    <!--- Query to select values and texts from the specified table --->
    select #rpgupdate.fname# as value, 
           recordname as text 
    from #RPgupdate.tableSelect# 
    order by recordname
</cfquery>

