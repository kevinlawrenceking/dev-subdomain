<!--- This ColdFusion page retrieves a value from the RPG update table based on a given record ID. --->

<cfquery name="FindValue">
    <!--- Query to select the first name from the RPG update table based on record ID --->
    Select #RPGUpdate.fname# as fvalue
    FROM #rpg_compTable#
    Where #Fid# = #recid#
</cfquery>
