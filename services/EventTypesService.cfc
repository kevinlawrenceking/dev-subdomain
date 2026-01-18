<cfcomponent displayname="EventTypesService" hint="Handles operations for EventTypes table" > 
<cffunction output="false" name="SELeventtypes" access="public" returntype="query">
    <cfargument name="filters" type="struct" required="false" default="#structNew()#">
    <cfset var queryResult = "">
    <cfset var sql = "SELECT eventTypeName, eventtypedescription, eventtypecolor FROM eventtypes">
    <cfset var whereClauses = []>
    <cfset var paramValues = []>

<!--- Add WHERE clauses dynamically based on filters --->
    <cfloop collection="#arguments.filters#" item="key">
        <cfif listFindNoCase("eventTypeName,eventtypedescription,eventtypecolor", key)>
            <cfset arrayAppend(whereClauses, "#key# = ?")>
            <cfset arrayAppend(paramValues, {value=arguments.filters[key], cfsqltype=determineSQLType(key)})>
        </cfif>
    </cfloop>

<!--- Construct final SQL statement --->
    <cfif arrayLen(whereClauses) gt 0>
        <cfset sql &= " WHERE " & arrayToList(whereClauses, " AND ")>
    </cfif>

<!--- Execute the query --->
    <cfquery result="result" name="queryResult">
        #sql#
        <cfloop array="#paramValues#" index="param">
            <cfqueryparam value="#param.value#" cfsqltype="#param.cfsqltype#">
        </cfloop>
    </cfquery>

<cfreturn queryResult>
</cffunction>
</cfcomponent>