<cfcomponent displayname="AuditionUnionService" hint="Handles operations for AuditionUnion table" > 
<cffunction output="false" name="SELaudunions" access="public" returntype="query">
    <cfargument name="new_countryid" type="string" required="false" default="">
    <cfargument name="new_audcatid" type="numeric" required="false" default=0>

<cfset var queryResult = "">
    <cfset var sql = "">
    <cfset var whereClause = "">
    <cfset var params = []>

<!--- Construct the base SQL query --->
    <cfset sql = "
        SELECT 
            u.unionid AS ID, 
            u.unionName AS NAME, 
            c.countryid, 
            u.audcatid 
        FROM 
            audunions u 
        INNER JOIN 
            countries c ON c.countryid = u.countryid 
        WHERE 
            u.isDeleted IS FALSE">

<!--- Add conditions based on arguments --->
    <cfif len(trim(arguments.new_countryid))>
        <cfset whereClause &= " AND c.countryid = ?">
        <cfset arrayAppend(params, {value=arguments.new_countryid, cfsqltype="CF_SQL_VARCHAR"})>
    </cfif>

<cfif arguments.new_audcatid neq 0>
        <cfset whereClause &= " AND u.audcatid = ?">
        <cfset arrayAppend(params, {value=arguments.new_audcatid, cfsqltype="CF_SQL_INTEGER"})>
    </cfif>

<!--- Append WHERE clause to SQL query --->
    <cfset sql &= whereClause & " ORDER BY u.unionname">

<!--- Execute the query --->
    <cfquery result="result" name="queryResult">
        #sql#
        <cfloop array="#params#" index="param">
            <cfqueryparam value="#param.value#" cfsqltype="#param.cfsqltype#">
        </cfloop>
    </cfquery>

<!--- Return the result --->
    <cfreturn queryResult>
</cffunction>

<cffunction output="false" name="INSaudunions" access="public" returntype="numeric">
    <cfargument name="new_unionName" type="string" required="true">
    <cfargument name="new_countryid" type="string" required="true">
    <cfargument name="new_audCatID" type="numeric" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">

<cfquery result="result">
        INSERT INTO audunions (unionName, countryid, audCatID, isDeleted)
        VALUES (
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_unionName#" maxlength="100" null="#NOT len(trim(arguments.new_unionName))#">,
            <cfqueryparam cfsqltype="CF_SQL_CHAR" value="#arguments.new_countryid#" null="#NOT len(trim(arguments.new_countryid))#">,
            <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audCatID#" null="#NOT len(trim(arguments.new_audCatID))#">,
            <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#" null="#NOT len(trim(arguments.new_isDeleted))#">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="UPDaudunions" access="public" returntype="void">
    <cfargument name="new_unionName" type="string" required="true">
    <cfargument name="new_countryid" type="string" required="true">
    <cfargument name="new_audCatID" type="numeric" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">
    <cfargument name="new_unionID" type="numeric" required="true">

<cfquery result="result">
        UPDATE audunions
        SET 
            unionName = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.new_unionName)#" maxlength="100" null="#NOT len(trim(arguments.new_unionName))#">,
            countryid = <cfqueryparam cfsqltype="CF_SQL_CHAR" value="#trim(arguments.new_countryid)#" null="#NOT len(trim(arguments.new_countryid))#">,
            audCatID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audCatID#" null="#NOT len(trim(arguments.new_audCatID))#">,
            isDeleted = <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#" null="#NOT len(trim(arguments.new_isDeleted))#">
        WHERE 
            unionID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_unionID#">
    </cfquery>
</cffunction>
</cfcomponent>