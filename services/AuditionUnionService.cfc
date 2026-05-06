<cfcomponent displayname="AuditionUnionService" hint="Handles operations for AuditionUnion table" >

<!---
    Post-2026-05-05 schema:
        audunions(unionID, unionName, countryid, audCatIDList, isDeleted, recordname)
    audCatIDList is a comma-separated string of audCategories.audcatid values
    (e.g. "1,2,6"). Category filtering uses FIND_IN_SET.
--->

<cffunction output="false" name="SELaudunions" access="public" returntype="query">
    <cfargument name="new_countryid" type="string"  required="false" default="">
    <cfargument name="new_audcatid"  type="numeric" required="false" default="0">

    <cfset var queryResult = "">
    <cfset var sql = "">
    <cfset var whereClause = "">
    <cfset var params = []>

    <cfset sql = "
        SELECT
            u.unionid       AS ID,
            u.unionName     AS NAME,
            c.countryid,
            u.audCatIDList
        FROM
            audunions u
        INNER JOIN
            countries c ON c.countryid = u.countryid
        WHERE
            u.isDeleted IS FALSE">

    <cfif len(trim(arguments.new_countryid))>
        <cfset whereClause &= " AND c.countryid = ?">
        <cfset arrayAppend(params, {value=arguments.new_countryid, cfsqltype="CF_SQL_VARCHAR"})>
    </cfif>

    <cfif arguments.new_audcatid neq 0>
        <cfset whereClause &= " AND FIND_IN_SET(?, u.audCatIDList) > 0">
        <cfset arrayAppend(params, {value=arguments.new_audcatid, cfsqltype="CF_SQL_INTEGER"})>
    </cfif>

    <cfset sql &= whereClause & " ORDER BY u.unionname">

    <cfquery result="result" name="queryResult">
        #sql#
        <cfloop array="#params#" index="param">
            <cfqueryparam value="#param.value#" cfsqltype="#param.cfsqltype#">
        </cfloop>
    </cfquery>
    <cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>

    <cfreturn queryResult>
</cffunction>

<cffunction output="false" name="INSaudunions" access="public" returntype="numeric">
    <cfargument name="new_unionName"    type="string"  required="true">
    <cfargument name="new_countryid"    type="string"  required="true">
    <cfargument name="new_audCatIDList" type="string"  required="true">
    <cfargument name="new_isDeleted"    type="boolean" required="true">

    <cfquery result="result">
        INSERT INTO audunions (unionName, countryid, audCatIDList, isDeleted)
        VALUES (
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.new_unionName)#" maxlength="100" null="#NOT len(trim(arguments.new_unionName))#">,
            <cfqueryparam cfsqltype="CF_SQL_CHAR"    value="#trim(arguments.new_countryid)#" maxlength="2" null="#NOT len(trim(arguments.new_countryid))#">,
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.new_audCatIDList)#" maxlength="50">,
            <cfqueryparam cfsqltype="CF_SQL_BIT"     value="#arguments.new_isDeleted#">
        )
    </cfquery>
    <cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="UPDaudunions" access="public" returntype="void">
    <cfargument name="new_unionName"    type="string"  required="true">
    <cfargument name="new_countryid"    type="string"  required="true">
    <cfargument name="new_audCatIDList" type="string"  required="true">
    <cfargument name="new_isDeleted"    type="boolean" required="true">
    <cfargument name="new_unionID"      type="numeric" required="true">

    <cfquery result="result">
        UPDATE audunions
        SET
            unionName    = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.new_unionName)#" maxlength="100" null="#NOT len(trim(arguments.new_unionName))#">,
            countryid    = <cfqueryparam cfsqltype="CF_SQL_CHAR"    value="#trim(arguments.new_countryid)#" maxlength="2" null="#NOT len(trim(arguments.new_countryid))#">,
            audCatIDList = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.new_audCatIDList)#" maxlength="50">,
            isDeleted    = <cfqueryparam cfsqltype="CF_SQL_BIT"     value="#arguments.new_isDeleted#">
        WHERE
            unionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_unionID#">
    </cfquery>
    <cfif structKeyExists(request,"perfSvcQueryCount")><cfset request.perfSvcQueryCount++></cfif>
</cffunction>

</cfcomponent>
