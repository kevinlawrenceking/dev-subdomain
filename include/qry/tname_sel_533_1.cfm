<!--- This ColdFusion page retrieves user data based on the provided user ID and orders the results. --->

<cfquery name="#tname#_sel">
    <!--- Select ID and NAME from the specified table for the given user ID --->
    SELECT a.#fid# as ID, 
           a.#fname# as NAME
    FROM #tname# a
    WHERE 0=0
      AND a.userid = <cfqueryparam value="#new_userid#" cfsqltype="cf_sql_integer" />
    ORDER BY a.#orderby#
</cfquery>
