<cfcomponent displayname="ItemTypesUserService" hint="Handles operations for ItemTypesUser table" > 
<cffunction output="false" name="INSitemtypes_user" access="public" returntype="numeric">
    <cfargument name="customtype" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery result="result">
        INSERT INTO itemtypes_user (valuetype, userid)
        VALUES (
            <cfqueryparam value="#arguments.customtype#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        )
    </cfquery>
        <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="SELitemtypes_user" access="public" returntype="query">
    <cfargument name="valuetype" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT *
        FROM itemtypes_user
        WHERE valuetype = <cfqueryparam value="#arguments.valuetype#" cfsqltype="CF_SQL_VARCHAR">
        AND userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="INSitemtypes_user_24464" access="public" returntype="numeric">
    <cfargument name="valuetype" type="string" required="true">
    <cfargument name="typeicon" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery result="result">
        INSERT INTO itemtypes_user (valuetype, typeicon, userid) 
        VALUES (
            <cfqueryparam value="#arguments.valuetype#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.typeicon#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="SELitemtypes_user_24466" access="public" returntype="query">
    <cfargument name="valuetype" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT typeid
        FROM itemtypes_user
        WHERE valuetype = <cfqueryparam value="#arguments.valuetype#" cfsqltype="CF_SQL_VARCHAR">
        AND userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>