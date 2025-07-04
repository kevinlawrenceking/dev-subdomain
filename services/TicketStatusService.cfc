<cfcomponent displayname="TicketStatusService" hint="Handles operations for TicketStatus table" > 
<cffunction output="false" name="SELticketstatuses" access="public" returntype="query">
    <!--- Execute the query --->
    <cfquery name="result">
        SELECT ticketstatus AS id, ticketstatus AS name 
        FROM ticketstatuses 
        ORDER BY id
    </cfquery>

<!--- Return the query result --->
    <cfreturn result>
</cffunction>

<cffunction output="false" name="SELticketstatuses_24766" access="public" returntype="query">
    <cfargument name="conditions" type="struct" required="false" default="#structNew()#">
    <cfset var queryResult = "">
    <cfset var sql = "SELECT ticketstatus AS name FROM ticketstatuses">
    <cfset var whereClause = "">
    <cfset var paramList = []>

<!--- Build WHERE clause dynamically --->
    <cfif structCount(arguments.conditions) gt 0>
        <cfset whereClause = " WHERE ">
        <cfloop collection="#arguments.conditions#" item="key">
            <cfset whereClause &= "#key# = ? AND ">
            <cfset arrayAppend(paramList, {value=arguments.conditions[key], cfsqltype=determineSQLType(key)})>
        </cfloop>
        <!--- Remove trailing 'AND ' --->
        <cfset whereClause = left(whereClause, len(whereClause) - 4)>
    </cfif>

<!--- Execute query --->
    <cfquery result="result" name="queryResult">
        #sql##whereClause#
        <cfloop array="#paramList#" index="param">
            <cfqueryparam value="#param.value#" cfsqltype="#param.cfsqltype#">
        </cfloop>
    </cfquery>

<cfreturn queryResult>
</cffunction>

<cffunction output="false" name="SELticketstatuses_24781" access="public" returntype="query">
    <cfargument name="status" type="string" required="false">

<cfset var sql = "">
    <cfset var params = []>

<cfset sql = "
        SELECT 'Completed' AS id, 'Completed' AS name 
        FROM ticketstatuses 
        WHERE 1=1
    ">

<cfif structKeyExists(arguments, "status") and len(trim(arguments.status))>
        <cfset sql &= " AND name = ?">
        <cfset arrayAppend(params, {value=arguments.status, cfsqltype="CF_SQL_VARCHAR"})>
    </cfif>

<cfset sql &= "
        UNION 
        SELECT 'Pending' AS id, 'Pending' AS name 
        FROM ticketstatuses
        WHERE 1=1
    ">

<cfif structKeyExists(arguments, "status") and len(trim(arguments.status))>
        <cfset sql &= " AND name = ?">
        <cfset arrayAppend(params, {value=arguments.status, cfsqltype="CF_SQL_VARCHAR"})>
    </cfif>

<cfquery name="result">
        #sql#
        <cfloop array="#params#" index="param">
            <cfqueryparam value="#param.value#" cfsqltype="#param.cfsqltype#">
        </cfloop>
    </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>