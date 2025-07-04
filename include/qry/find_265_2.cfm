<!--- This ColdFusion page retrieves a record name from the rpg_compTable based on a given record ID. --->

<cfquery name="find">
    <!--- Query to select the record name from the specified table based on the record ID. --->
    Select recordname
    FROM #rpg_compTable#
    Where #Fid# = #recid#
</cfquery>
