<cfcomponent displayname="ItemTypeService" hint="Handles operations for ItemType table" >

<cffunction output="false" name="getValueTypesByCategory" access="public" returntype="struct">
    <cfargument name="catid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="false" default="">

<cfset var result = structNew()>

<cfquery result="result" name="types" >
        SELECT DISTINCT i.valuetype
        FROM 
            <cfif arguments.catid eq 4>
                itemtypes i
                INNER JOIN itemcatxref x ON x.typeid = i.typeid
            <cfelse>
                itemcategory c
                INNER JOIN itemcatxref_user x ON x.catid = c.catid
                INNER JOIN itemtypes_user i ON i.typeid = x.typeid
            </cfif>
        WHERE 
            x.catid = <cfqueryparam value="#arguments.catid#" cfsqltype="cf_sql_integer">
            <cfif arguments.catid eq 4>
                AND i.typeid <> 1000
            <cfelse>
                AND i.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer">
                AND x.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer">
            </cfif>
        ORDER BY i.valuetype
    </cfquery>

<cfset result.types = types>
    <cfset result.recordcount = types.recordcount>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELitemTypesByCategoryAndUser" access="public" returntype="struct">
    <!--- This function retrieves distinct value types based on user and category IDs. --->
    <cfargument name="new_catid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfset var resultStruct = structNew()>

<!--- Query to get distinct value types for a given category and user --->
    <cfquery result="result" name="types" >
        SELECT DISTINCT 
            i.valuetype
        FROM 
            itemcategory c
        INNER JOIN 
            itemcatxref_user x ON x.catid = c.catid
        INNER JOIN 
            itemtypes_user i ON i.typeid = x.typeid
        WHERE 
            x.catid = <cfqueryparam value="#arguments.new_catid#" cfsqltype="cf_sql_integer">
            AND i.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer">
            AND x.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer">
        ORDER BY 
            i.valuetype
    </cfquery>

<cfset resultStruct.types = types>
    <cfset resultStruct.recordcount = types.recordcount>

<cfreturn resultStruct>
</cffunction>

<cffunction output="false" name="SELitemTypesByCategory_4" access="public" returntype="struct">

<cfset var resultStruct = structNew()>

<cfquery result="result" name="types">
        SELECT 
            i.valuetype
        FROM 
            itemtypes i
        INNER JOIN 
            itemcatxref x ON x.typeid = i.typeid
        WHERE 
            x.catid = 4 
            AND i.typeid <> 1000
        ORDER BY 
            i.valuetype
    </cfquery>

<cfset resultStruct.types = types>
    <cfset resultStruct.recordcount = types.recordcount>

<cfreturn resultStruct>

</cffunction>

<cffunction output="false" name="SELitemtypes" access="public" returntype="query">
    <cfargument name="catId" type="numeric" required="true">
    <cfargument name="excludeTypeId" type="numeric" required="true">

<cfquery name="result">
        SELECT i.valuetype
        FROM itemtypes i
        INNER JOIN itemcatxref x ON x.typeid = i.typeid
        WHERE x.catid = <cfqueryparam value="#arguments.catId#" cfsqltype="CF_SQL_INTEGER">
        AND i.typeid <> <cfqueryparam value="#arguments.excludeTypeId#" cfsqltype="CF_SQL_INTEGER">
        ORDER BY i.valuetype
    </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELitemtypes_24462" access="public" returntype="query">
    <cfargument name="typeid" type="numeric" required="false">
    <cfargument name="valuetype" type="string" required="false">
    <cfargument name="typeicon" type="string" required="false">

<cfset var queryResult = "">
    <cfset var whereClause = []>
    <cfset var params = []>

<!--- Construct WHERE clause dynamically based on provided arguments --->
    <cfif structKeyExists(arguments, "typeid") and not isNull(arguments.typeid)>
        <cfset arrayAppend(whereClause, "typeid = ?")>
        <cfset arrayAppend(params, {value=arguments.typeid, cfsqltype="CF_SQL_INTEGER"})>
    </cfif>

<cfif structKeyExists(arguments, "valuetype") and not isNull(arguments.valuetype)>
        <cfset arrayAppend(whereClause, "valuetype = ?")>
        <cfset arrayAppend(params, {value=arguments.valuetype, cfsqltype="CF_SQL_VARCHAR"})>
    </cfif>

<cfif structKeyExists(arguments, "typeicon") and not isNull(arguments.typeicon)>
        <cfset arrayAppend(whereClause, "typeicon = ?")>
        <cfset arrayAppend(params, {value=arguments.typeicon, cfsqltype="CF_SQL_VARCHAR"})>
    </cfif>

<!--- Execute query only if there are conditions to prevent unfiltered queries --->
    <cfif arrayLen(whereClause) gt 0>
        <cfquery result="result" name="queryResult">
            SELECT typeid, valuetype, typeicon
            FROM itemtypes
            WHERE #arrayToList(whereClause, " AND ")#
            <!--- Bind parameters securely --->
            <cfloop array="#params#" index="param">
                <cfqueryparam value="#param.value#" cfsqltype="#param.cfsqltype#">
            </cfloop>
        </cfquery>
    <cfelse>
        <!--- Return an empty query if no conditions are provided --->
        <cfquery result="result" name="queryResult" dbtype="query">
            SELECT typeid, valuetype, typeicon
            WHERE 1=0
        </cfquery>
    </cfif>

<!--- Return the result set --->
    <cfreturn queryResult>

</cffunction>
</cfcomponent>