<cfinclude template="/include/perfcount.cfm" />
<!--- This ColdFusion page retrieves user data based on the provided user ID and orders the results. --->

<!--- Sanitize ORDER BY column name to prevent SQL injection --->
<cfset orderby = reReplace(orderby, "[^a-zA-Z0-9_]", "", "all")>

<cfquery name="#tname#_sel">
    SELECT a.#fid# as ID,
           a.#fname# as NAME
    FROM #tname# a
    WHERE 0=0
      AND a.userid = <cfqueryparam value="#new_userid#" cfsqltype="cf_sql_integer" />
    ORDER BY a.#orderby#
</cfquery>
