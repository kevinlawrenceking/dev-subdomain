<cfcomponent displayname="FilteredQueryService" hint="Handles operations for FilteredQuery table" > 
<cffunction output="false" name="SELqFiltered" access="public" returntype="query">
    <cfargument name="sIndexColumn" type="string" required="true">
    <cfargument name="conditions" type="struct" required="false" default="#StructNew()#">

<cfset var sql = "SELECT COUNT(#arguments.sIndexColumn#) as total FROM qFiltered">
    <cfset var whereClause = "">
    <cfset var paramList = []>

<!--- Build WHERE clause dynamically based on conditions --->
    <cfif StructCount(arguments.conditions) gt 0>
        <cfset whereClause = " WHERE ">
        <cfloop collection="#arguments.conditions#" item="key">
            <cfset whereClause &= "#key# = ? AND ">
            <cfset ArrayAppend(paramList, {value=arguments.conditions[key], cfsqltype=determineSQLType(key)})>
        </cfloop>
        <!--- Remove trailing 'AND ' --->
        <cfset whereClause = Left(whereClause, Len(whereClause) - 4)>
    </cfif>

<!--- Combine SQL with WHERE clause --->
    <cfset sql &= whereClause>

<!--- Execute query --->
    <cfquery name="result">
        #sql#
        <cfloop array="#paramList#" index="param">
            <cfqueryparam value="#param.value#" cfsqltype="#param.cfsqltype#">
        </cfloop>
    </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>