<!--- This ColdFusion page retrieves a specific value from the RPG database based on a given record ID. --->

<cfquery name="FindValue">
    <!--- Query to select the first name from the RPG table based on the record ID --->
    Select #RPGUpdate.fname# as fvalue
    FROM #rpg_compTable#
    Where #Fid# = #recid#
</cfquery>
