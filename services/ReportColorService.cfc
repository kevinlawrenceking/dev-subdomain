<cfcomponent displayname="ReportColorService" hint="Handles operations for ReportColor table" > 
<cffunction output="false" name="SELreportcolors" access="public" returntype="query">
    <cfargument name="colorName" type="string" required="false">

<cfset var sql = "SELECT colorid, colorname, colorscheme FROM reportcolors">
    <cfset var whereClause = "">
    <cfset var params = []>

<cfif structKeyExists(arguments, "colorName") and len(trim(arguments.colorName))>
        <cfset whereClause = " WHERE colorname = ?">
        <cfset arrayAppend(params, {value=arguments.colorName, cfsqltype="CF_SQL_VARCHAR"})>
    </cfif>

<cfset sql &= whereClause & " ORDER BY colorname">

<cfquery name="result">
        #sql#
        <cfloop array="#params#" index="param">
            <cfqueryparam value="#param.value#" cfsqltype="#param.cfsqltype#">
        </cfloop>
    </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>