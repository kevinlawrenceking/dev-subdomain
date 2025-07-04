<!--- This ColdFusion page retrieves active records from a specified table and orders them by a given field. --->

<cfquery name="#tname#_sel">
    <!--- Select ID and NAME from the specified table where records are not deleted, ordered by a specified field. --->
    SELECT a.#fid# as ID, 
           a.#fname# as NAME
    FROM #tname# a
    WHERE a.isDeleted is false
    ORDER BY a.#orderby#
</cfquery>
