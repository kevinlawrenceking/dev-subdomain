<cfcomponent displayname="ItemCategoryService" hint="Handles operations for ItemCategory table" > 
<cffunction output="false" name="SELitemcategory" access="public" returntype="query">
    <cfargument name="conditions" type="struct" required="false" default="#structNew()#">

<cfset var queryResult = "">
    <cfset var sql = "SELECT * FROM itemcategory">
    <cfset var whereClause = "">
    <cfset var params = []>

<!--- Build WHERE clause dynamically based on arguments --->
    <cfif structCount(arguments.conditions) gt 0>
        <cfset whereClause = " WHERE ">
        <cfloop collection="#arguments.conditions#" item="columnName">
            <cfif listFind("validColumn1,validColumn2,validColumn3", columnName)>
                <cfset whereClause &= "#columnName# = ? AND ">
                <cfset arrayAppend(params, {value=arguments.conditions[columnName], cfsqltype=determineCFSQLType(columnName)})>
            </cfif>
        </cfloop>
        <!--- Remove trailing AND --->
        <cfset whereClause = left(whereClause, len(whereClause) - 5)>
    </cfif>

<!--- Construct final SQL statement --->
    <cfset sql &= whereClause>

<!--- Execute the query --->
    <cfquery result="result" name="queryResult">
        #sql#
        <cfloop array="#params#" index="param">
            <cfqueryparam value="#param.value#" cfsqltype="#param.cfsqltype#">
        </cfloop>
    </cfquery>

<cfreturn queryResult>
</cffunction>

<cffunction output="false" name="DETitemcategory" access="public" returntype="query">
    <cfargument name="catid" type="numeric" required="true">

<cfquery name="result">
        SELECT * 
        FROM itemcategory 
        WHERE catid = <cfqueryparam value="#arguments.catid#" cfsqltype="cf_sql_integer">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELitemcategory_24039" access="public" returntype="query">
    <cfargument name="new_catid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT DISTINCT i.valuetype 
        FROM itemcategory c 
        INNER JOIN itemcatxref_user x ON x.catid = c.catid 
        INNER JOIN itemtypes_user i ON i.typeid = x.typeid 
        WHERE x.catid = <cfqueryparam value="#arguments.new_catid#" cfsqltype="cf_sql_integer"> 
        AND i.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer"> 
        AND x.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer"> 
        ORDER BY valuetype
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELitemcategory_24465" access="public" returntype="query">
    <cfargument name="catidList" type="array" required="false" default="#ArrayNew(1)#">

<cfquery name="result">
        SELECT DISTINCT c.catid, i.valuetype
        FROM itemcategory c
        INNER JOIN itemcatxref x ON x.catid = c.catid
        INNER JOIN itemtypes i ON i.typeid = x.typeid
        WHERE 1=1
        <cfif ArrayLen(arguments.catidList) GT 0>
            AND c.catid IN (
                <cfloop from="1" to="#ArrayLen(arguments.catidList)#" index="i">
                    <cfqueryparam value="#arguments.catidList[i]#" cfsqltype="CF_SQL_INTEGER">
                    <cfif i LT ArrayLen(arguments.catidList)>,</cfif>
                </cfloop>
            )
        </cfif>
        ORDER BY c.catid, i.valuetype
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELitemcategory_24621" access="public" returntype="query">
    <cfargument name="catArea_UCB" type="string" required="true">

<cfquery name="result">
        SELECT 
            i.catID, 
            i.valuecategory, 
            i.catIcon, 
            i.catOrder, 
            i.valuetypedef, 
            i.catSelectList, 
            i.catFieldSet 
        FROM 
            itemcategory i 
        WHERE 
            i.catArea_UCB IN ('B', <cfqueryparam value="#arguments.catArea_UCB#" cfsqltype="CF_SQL_VARCHAR">) 
        ORDER BY 
            catOrder
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELitemcategory_24722" access="public" returntype="query">
    <cfargument name="new_catid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT DISTINCT i.valuetype
        FROM itemcategory c
        INNER JOIN itemcatxref_user x ON x.catid = c.catid
        INNER JOIN itemtypes_user i ON i.typeid = x.typeid
        WHERE x.catid = <cfqueryparam value="#arguments.new_catid#" cfsqltype="CF_SQL_INTEGER">
        AND i.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        AND x.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        ORDER BY valuetype
    </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>