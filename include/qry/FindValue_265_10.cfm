<!--- This ColdFusion page retrieves a specific value from the RPG database based on a given record ID. --->

<cfquery name="FindValue">
    <!--- Select the first name as fvalue from the specified table where the ID matches the record ID. --->
    Select #RPGUpdate.fname# as fvalue
    FROM #rpg_compTable#
    Where #Fid# = #recid#
</cfquery>
