<cfcomponent displayname="TagService" hint="Handles operations for Tag table" > 
<cffunction output="false" name="SELtags" access="public" returntype="query">
    <cfargument name="conditions" type="struct" required="false" default="#structNew()#">
    <cfset var queryResult = "">
    <cfset var sql = "SELECT * FROM tags">
    <cfset var whereClause = "">
    <cfset var paramList = []>

<cfif structCount(arguments.conditions) gt 0>
        <cfset whereClause = " WHERE ">
        <cfloop collection="#arguments.conditions#" item="key">
            <cfset arrayAppend(paramList, "#key# = ?")>
        </cfloop>
        <cfset whereClause &= arrayToList(paramList, " AND ")>
    </cfif>

<cfquery result="result" name="queryResult">
        #sql##whereClause#
        <cfloop collection="#arguments.conditions#" item="key">
            <cfqueryparam value="#arguments.conditions[key]#" cfsqltype="#determineSQLType(key)#">
        </cfloop>
    </cfquery>

<cfreturn queryResult>
</cffunction>
</cfcomponent>