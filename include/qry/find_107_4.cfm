<!--- This ColdFusion page retrieves the record name from the specified table based on the provided record ID. --->

<cfquery name="find">
    <!--- Query to select the record name from the RPG_COMP table based on the record ID. --->
    Select recordname
    FROM #rpg_compTable#
    Where #Fid# = #recid#
</cfquery>
