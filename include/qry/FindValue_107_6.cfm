<!--- This ColdFusion page retrieves a specific value from the RPG table based on the provided record ID. --->

<cfquery name="FindValue">
    <!--- Query to select the first name from the RPG table where the ID matches the given record ID. --->
    Select #RPGUpdate.fname# as fvalue
    FROM #rpg_compTable#
    Where #Fid# = #recid#
</cfquery>
