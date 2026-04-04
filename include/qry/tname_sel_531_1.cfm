<!--- This ColdFusion page retrieves active records from a specified table and orders them by a given field. --->

<!--- Sanitize ORDER BY column name to prevent SQL injection --->
<cfset orderby = reReplace(orderby, "[^a-zA-Z0-9_]", "", "all")>

<!--- PERF: Generic lookup tables (categories, etc.) rarely change; cache for 60 minutes. --->
<cfquery name="#tname#_sel" cachedwithin="#createTimeSpan(0,1,0,0)#">
    SELECT a.#fid# as ID,
           a.#fname# as NAME
    FROM #tname# a
    WHERE a.isDeleted is false
    ORDER BY a.#orderby#
</cfquery>
