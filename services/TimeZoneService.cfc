<cfcomponent displayname="TimeZoneService" hint="Handles operations for TimeZone table" > 
<cffunction output="false" name="SELtimezones" access="public" returntype="query">
    <cfargument name="filters" type="struct" required="false" default="#structNew()#">
    <cfset var queryResult = "">
    <cfset var sql = "SELECT tzid, gmt, tzname, utchouroffset FROM timezones">
    <cfset var whereClause = []>
    <cfset var params = []>

<!--- Build WHERE clause dynamically based on filters --->
    <cfif structKeyExists(arguments.filters, "tzid")>
        <cfset arrayAppend(whereClause, "tzid = ?")>
        <cfset arrayAppend(params, {value=arguments.filters.tzid, cfsqltype="CF_SQL_INTEGER"})>
    </cfif>

<cfif structKeyExists(arguments.filters, "gmt")>
        <cfset arrayAppend(whereClause, "gmt = ?")>
        <cfset arrayAppend(params, {value=arguments.filters.gmt, cfsqltype="CF_SQL_VARCHAR"})>
    </cfif>

<cfif structKeyExists(arguments.filters, "tzname")>
        <cfset arrayAppend(whereClause, "tzname = ?")>
        <cfset arrayAppend(params, {value=arguments.filters.tzname, cfsqltype="CF_SQL_VARCHAR"})>
    </cfif>

<cfif structKeyExists(arguments.filters, "utchouroffset")>
        <cfset arrayAppend(whereClause, "utchouroffset = ?")>
        <cfset arrayAppend(params, {value=arguments.filters.utchouroffset, cfsqltype="CF_SQL_INTEGER"})>
    </cfif>

<!--- Append WHERE clause if conditions exist --->
    <cfif arrayLen(whereClause) gt 0>
        <cfset sql &= " WHERE " & arrayToList(whereClause, " AND ")>
    </cfif>

<!--- Append ORDER BY clause --->
    <cfset sql &= " ORDER BY utcHourOffset">

<!--- Execute the query --->
    <cfquery result="result" name="queryResult">
        #sql#
        <cfloop array="#params#" index="param">
            <cfqueryparam value="#param.value#" cfsqltype="#param.cfsqltype#">
        </cfloop>
    </cfquery>

<!--- Return the query result --->
    <cfreturn queryResult>
</cffunction>
<cffunction output="false" name="SELtimezones_24770" access="public" returntype="query">
    <cfargument name="tzGeneral" type="string" required="false" default="">

<cfquery name="result">
            SELECT tzid, gmt, tzname, tzgeneral, utchouroffset
            FROM timezones
            WHERE 1=1
            and tzgeneral <> '' and tzgeneral is not null 
            <cfif len(trim(arguments.tzGeneral))>
                AND tzgeneral = <cfqueryparam value="#arguments.tzGeneral#" cfsqltype="CF_SQL_VARCHAR">
            </cfif>
            ORDER BY gmt
        </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>