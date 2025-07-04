<cfcomponent displayname="RegionService" hint="Handles operations for Region table" >

<cffunction output="false" name="GetRegions" access="public" returntype="query"  hint="Retrieve all regions ordered by region name.">
        <cfset var regions = "">
        <cfquery result="result" name="regions">
            SELECT 
                countryid, 
                region_id, 
                regionname 
            FROM 
                regions 
            ORDER BY 
                regionname
        </cfquery>
        <cfreturn regions>
    </cffunction>

<cffunction output="false" name="SELregions" access="public" returntype="query">
        <cfargument name="region_id" type="numeric" required="true">

<cfquery name="result">
            SELECT regionname 
            FROM regions 
            WHERE region_id = <cfqueryparam value="#arguments.region_id#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
        <cfreturn result>
    </cffunction>

<cffunction output="false" name="SELregions_24170" access="public" returntype="query">
        <cfargument name="valueregion" type="string" required="true">

<cfquery name="result">
            SELECT region_id 
            FROM regions 
            WHERE regionname = <cfqueryparam value="#arguments.valueregion#" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>
        <cfreturn result>
    </cffunction>

<cffunction output="false" name="SELregions_24177" access="public" returntype="query">
        <cfargument name="region_id" type="numeric" required="true">
        <cfargument name="old_countryid" type="string" required="true">

<cfquery name="result">
            SELECT regionname 
            FROM regions 
            WHERE region_id = <cfqueryparam value="#arguments.region_id#" cfsqltype="CF_SQL_INTEGER"> 
            AND countryid = <cfqueryparam value="#arguments.old_countryid#" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>
        <cfreturn result>
    </cffunction>

<cffunction output="false" name="SELregions_24717" access="public" returntype="query">
        <cfargument name="regionID" type="numeric" required="false">
        <cfargument name="regionName" type="string" required="false">
        <cfset var queryResult = "">
        <cfset var sql = "SELECT countryid, region_id, regionname FROM regions">
        <cfset var conditions = []>
        <cfset var params = []>
        <cfif structKeyExists(arguments, "regionID")>
            <cfset arrayAppend(conditions, "region_id = ?")>
            <cfset arrayAppend(params, {value=arguments.regionID, cfsqltype="CF_SQL_INTEGER"})>
        </cfif>
        <cfif structKeyExists(arguments, "regionName")>
            <cfset arrayAppend(conditions, "regionname = ?")>
            <cfset arrayAppend(params, {value=arguments.regionName, cfsqltype="CF_SQL_VARCHAR"})>
        </cfif>
        <cfif arrayLen(conditions) gt 0>
            <cfset sql &= " WHERE " & arrayToList(conditions, " AND ")>
        </cfif>
        <cfset sql &= " ORDER BY regionname">
        <cfquery result="result" name="queryResult">
            #sql#
            <cfloop array="#params#" index="param">
                <cfqueryparam value="#param.value#" cfsqltype="#param.cfsqltype#">
            </cfloop>
        </cfquery>
        <cfreturn queryResult>
    </cffunction>

<cffunction output="false" name="SELregions_24721" access="public" returntype="query">
        <cfargument name="regionName" type="string" required="true">

<cfquery name="result">
            SELECT region_id
            FROM regions
            WHERE regionname = <cfqueryparam value="#arguments.regionName#" cfsqltype="CF_SQL_VARCHAR">
        </cfquery>
        <cfreturn result>
    </cffunction>

</cfcomponent>