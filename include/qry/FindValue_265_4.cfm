<!--- This ColdFusion code retrieves a value from the RPGUpdate table based on a given record ID. --->

<cfquery name="FindValue">
    <!--- Select the first name as fvalue from the specified table based on the record ID --->
    Select #RPGUpdate.fname# as fvalue
    FROM #rpg_compTable#
    Where #Fid# = #recid#
</cfquery>
