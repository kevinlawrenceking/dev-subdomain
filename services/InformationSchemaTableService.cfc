<cfcomponent displayname="InformationSchemaTableService" hint="Handles operations for InformationSchemaTable table" >
 
<cffunction output="false" name="SELinformation_schema" access="public" returntype="query">
    <cfargument name="tableNamePattern" type="string" required="true">

<cfquery name="result">
        SELECT table_name AS new_comptable
        FROM information_schema.tables
        WHERE TABLE_NAME LIKE <cfqueryparam value="#arguments.tableNamePattern#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>