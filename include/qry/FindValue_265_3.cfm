<!--- This ColdFusion page retrieves a specific value from the database based on the provided record ID. --->

<cfquery name="FindValue">
    <!--- Query to select the first name from the specified table where the ID matches the record ID. --->
    Select #RPGUpdate.fname# as fvalue
    FROM #rpg_compTable#
    Where #Fid# = #recid#
</cfquery>
