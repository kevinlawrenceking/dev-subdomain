<!--- This ColdFusion page retrieves a list of values and text from a specified table based on the given category ID. --->
<cfquery name="selects">
    <!--- Query to select values and text from the specified table based on the category ID --->
    select #rpgupdate.fname# as value, 
           recordname as text 
    from #RPgupdate.tableSelect# 
    where audcatid = #audcatid#
    order by recordname
</cfquery>
