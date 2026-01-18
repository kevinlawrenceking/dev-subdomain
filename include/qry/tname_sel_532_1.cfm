<!--- This ColdFusion page retrieves user information from the database based on specific criteria. --->
<cfquery name="#tname#_sel">
    SELECT a.#fid# as ID, 
           a.#fname# as NAME
    FROM #tname# a
    WHERE a.isDeleted is false
    
    <!--- Check if a new user ID is provided --->
    <cfif #new_userid# is not "0">
        AND a.userid = <cfqueryparam value="#new_userid#" cfsqltype="cf_sql_integer" />
    </cfif>
    
    ORDER BY a.#orderby#
</cfquery>
