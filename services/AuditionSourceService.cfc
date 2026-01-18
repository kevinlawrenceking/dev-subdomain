<cfcomponent displayname="AuditionSourceService" hint="Handles operations for AuditionSource table" > 
<cffunction output="false" name="SELaudsources" access="public" returntype="query">
    <cfargument name="conditions" type="struct" required="false" default="#structNew()#">

<cfset var sql = "SELECT audsource AS NAME FROM audsources">
    <cfset var whereClause = "">
    <cfset var paramList = []>

<!--- Build WHERE clause dynamically --->
    <cfif structCount(arguments.conditions) gt 0>
        <cfset whereClause = " WHERE ">
        <cfloop collection="#arguments.conditions#" item="key">
            <cfset whereClause &= "#key# = ? AND ">
            <cfset arrayAppend(paramList, {value=arguments.conditions[key], cfsqltype=determineSQLType(key)})>
        </cfloop>
        <!--- Remove trailing ' AND ' --->
        <cfset whereClause = left(whereClause, len(whereClause) - 5)>
    </cfif>

<!--- Execute query --->
    <cfquery name="result">
        #sql##whereClause#
        <cfloop array="#paramList#" index="param">
            <cfqueryparam value="#param.value#" cfsqltype="#param.cfsqltype#">
        </cfloop>
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELaudsources_24222" access="public" returntype="query">
    <cfquery name="result">
        SELECT audsourceid, audsource
        FROM audsources
        WHERE isdeleted = 0
        ORDER BY audsource
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELaudsources_24359" access="public" returntype="query">
    <cfargument name="audsource" type="string" required="true">

<cfquery name="result">
        SELECT *
        FROM audsources
        WHERE isdeleted = 0
        AND audsource = <cfqueryparam value="#arguments.audsource#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELaudsources_24371" access="public" returntype="query">
    <cfargument name="audsource" type="string" required="true">

<cfquery name="result">
        SELECT *
        FROM audsources
        WHERE audsource = <cfqueryparam value="#arguments.audsource#" cfsqltype="CF_SQL_VARCHAR">
        AND isdeleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="INSaudsources" access="public" returntype="numeric">
    <cfargument name="new_audsource" type="string" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">

<cfquery result="result">
        INSERT INTO audsources (audsource, isDeleted)
        VALUES (
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.new_audsource)#" maxlength="100" null="#NOT len(trim(arguments.new_audsource))#">,
            <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#" null="#NOT len(trim(arguments.new_isDeleted))#">
        );
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="UPDaudsources" access="public" returntype="void">
    <cfargument name="new_audsource" type="string" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">
    <cfargument name="new_audsourceid" type="numeric" required="true">

<cfquery result="result">
        UPDATE audsources 
        SET 
            audsource = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.new_audsource)#" maxlength="100" null="#NOT len(trim(arguments.new_audsource))#">,
            isDeleted = <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#" null="#NOT len(trim(arguments.new_isDeleted))#">
        WHERE 
            audsourceid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audsourceid#">
    </cfquery>
</cffunction>

<cffunction output="false" name="SELaudsources_24684" access="public" returntype="query">
    <cfargument name="excludeMyTeam" type="boolean" required="false" default="false">

<cfquery name="result">
        SELECT audsourceid AS id, audsource AS NAME 
        FROM audsources
        WHERE 1=1
        <cfif arguments.excludeMyTeam>
            AND audsource <> <cfqueryparam value="My Team" cfsqltype="CF_SQL_VARCHAR">
        </cfif>
        ORDER BY audsource
    </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>