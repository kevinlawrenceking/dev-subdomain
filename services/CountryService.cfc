<cfcomponent displayname="CountryService" hint="Handles operations for Country table" > 
<cffunction output="false" name="SELcountries" access="public" returntype="query">
    <cfargument name="countryid" type="string" required="true">

<cfquery name="result">
        SELECT countryid, countryname
        FROM countries
        WHERE countryid = <cfqueryparam value="#arguments.countryid#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcountries_24169" access="public" returntype="query">
    <cfargument name="countryName" type="string" required="true">

<cfquery name="result">
        SELECT * 
        FROM countries 
        WHERE countryname = <cfqueryparam value="#arguments.countryName#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcountries_24637" access="public" returntype="query">
    <cfargument name="countryIds" type="array" required="true">

<!--- PERF: Countries list rarely changes; cache for 24 hours. --->
<cfquery name="result" cachedwithin="#createTimeSpan(1,0,0,0)#">
        SELECT countryid, countryname FROM countries
        WHERE isdeleted = 0 and countryid in (select countryid from regions)
        ORDER BY countryname
    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELcountries_24720" access="public" returntype="query">
    <cfargument name="countryName" type="string" required="true">

<cfquery name="result">
        SELECT * 
        FROM countries 
        WHERE countryname = <cfqueryparam value="#arguments.countryName#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>
<cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

<cfreturn result>
</cffunction>
</cfcomponent>