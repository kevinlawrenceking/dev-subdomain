<!--- This ColdFusion page retrieves a record name from a specified table based on a given key and record ID. --->

<cfquery name="Findrec">
    <!--- Query to select the record name from the specified table based on the provided key and record ID. --->
    SELECT recordname 
    FROM #rpg_comptable#_tbl 
    WHERE #findkey.fname# = #recid#
</cfquery>
