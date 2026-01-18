<!--- This ColdFusion page retrieves a list of records from a specified table and formats them for selection. --->

<cfquery name="selects">
    <!--- Query to select values and text from the specified table, ordered by record name. --->
    select #rpgupdate.fname# as value, 
           recordname as text 
    from #RPgupdate.tableSelect# 
    order by recordname
</cfquery>
