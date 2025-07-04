<cfcomponent displayname="SiteTypeMasterService" hint="Handles operations for SiteTypeMaster table" > 
<cffunction output="false" name="SELsitetypes_master" access="public" returntype="query">
    <cfargument name="sitetypename" type="string" required="true">

<cfquery name="result">
        SELECT *
        FROM sitetypes_master
        WHERE sitetypename = <cfqueryparam value="#arguments.sitetypename#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELsitetypes_master_24437" access="public" returntype="query">
    <cfargument name="conditions" type="struct" required="false" default="#structNew()#">
    <cfset var queryResult = "">
    <cfset var sql = "SELECT sitetypename, sitetypedescription FROM sitetypes_master">
    <cfset var whereClauses = []>
    <cfset var paramList = []>

<!--- Build WHERE clauses dynamically based on arguments --->
    <cfloop collection="#arguments.conditions#" item="key">
        <cfif listFindNoCase("sitetypename,sitetypedescription", key)>
            <cfset arrayAppend(whereClauses, "#key# = ?")>
            <cfset arrayAppend(paramList, {value=arguments.conditions[key], cfsqltype="CF_SQL_VARCHAR"})>
        </cfif>
    </cfloop>

<!--- Append WHERE clause if conditions exist --->
    <cfif arrayLen(whereClauses) gt 0>
        <cfset sql = sql & " WHERE " & arrayToList(whereClauses, " AND ")>
    </cfif>

<!--- Execute the query --->
    <cfquery result="result" name="queryResult">
        #sql#
        <cfloop array="#paramList#" index="param">
            <cfqueryparam value="#param.value#" cfsqltype="#param.cfsqltype#">
        </cfloop>
    </cfquery>

<cfreturn queryResult>
</cffunction>
</cfcomponent>