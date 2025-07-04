<!--- This ColdFusion page retrieves a list of items from a specified table, optionally filtered by a category ID, and orders the results. --->

<cfquery name="#tname#_sel">
    SELECT a.#fid# as ID, 
           a.#fname# as NAME, 
           ac.audCatName, 
           ac.audCatId
    FROM #tname# a
    INNER JOIN audcategories ac 
        ON ac.audcatid = a.audcatid
    WHERE a.isDeleted IS FALSE

    <!--- Check if a new category ID is provided and filter results accordingly. --->
    <cfif #new_audcatid# is not "0">
        AND a.audcatid = <cfqueryparam value="#new_audcatid#" cfsqltype="cf_sql_integer" />
    </cfif>
    
    ORDER BY a.#fname#, 
             ac.audcatname, 
             a.#orderby#
</cfquery>
