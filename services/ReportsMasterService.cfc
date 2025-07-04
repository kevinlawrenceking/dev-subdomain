<cfcomponent displayname="ReportsMasterService" hint="Handles operations for ReportsMaster table" > 
<cffunction output="false" name="SELreports_master" access="public" returntype="query">
    <cfargument name="conditions" type="struct" required="false" default="#structNew()#">

<cfset var queryResult = "">
    <cfset var sql = "SELECT reportid, reportname, reportorderno, reporttypeid, reportdescription, colmd, colxl, datalabel, colorid FROM reports_master">
    <cfset var whereClauses = []>
    <cfset var params = []>

<!--- Build WHERE clause dynamically based on conditions argument --->
    <cfloop collection="#arguments.conditions#" item="key">
        <cfif listFindNoCase("reportid,reportname,reportorderno,reporttypeid,reportdescription,colmd,colxl,datalabel,colorid", key)>
            <cfset arrayAppend(whereClauses, "#key# = ?")>
            <cfset arrayAppend(params, {value=arguments.conditions[key], cfsqltype=getSQLType(key)})>
        </cfif>
    </cfloop>

<!--- Append WHERE clause to SQL if conditions exist --->
    <cfif arrayLen(whereClauses) gt 0>
        <cfset sql &= " WHERE " & arrayToList(whereClauses, " AND ")>
    </cfif>

<!--- Execute the query --->
    <cfquery result="result" name="queryResult">
        #sql#
        <cfloop array="#params#" index="param">
            <cfqueryparam value="#param.value#" cfsqltype="#param.cfsqltype#">
        </cfloop>
    </cfquery>

<cfreturn queryResult>
</cffunction>
</cfcomponent>