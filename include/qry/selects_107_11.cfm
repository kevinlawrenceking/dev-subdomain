<!--- This ColdFusion page retrieves field values and texts from a specified table and orders them by field text. --->

<cfquery name="selects">
    <!--- Query to select field values and texts from the specified table and order by field text --->
    select fieldvalue as value, 
           fieldtext as text 
    from #RPgupdate.tableSelect# 
    order by fieldtext
</cfquery>
