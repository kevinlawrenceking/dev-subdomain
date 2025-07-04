<cfcomponent displayname="ItemCategoryXRefUserService" hint="Handles operations for ItemCategoryXRefUser table" > 
<cffunction output="false" name="INSitemcatxref_user" access="public" returntype="numeric">
    <cfargument name="new_typeid" type="numeric" required="true">
    <cfargument name="catid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery result="result">
        INSERT INTO itemcatxref_user (typeid, catid, userid, IsCustom) 
        VALUES (
            <cfqueryparam value="#arguments.new_typeid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="#arguments.catid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="1" cfsqltype="CF_SQL_BIT">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="SELitemcatxref_user" access="public" returntype="query">
    <cfargument name="select_userid" type="numeric" required="true">
    <cfargument name="new_typeid" type="numeric" required="true">
    <cfargument name="new_catid" type="numeric" required="true">

<cfquery name="result">
        SELECT *
        FROM itemcatxref_user
        WHERE userid = <cfqueryparam value="#arguments.select_userid#" cfsqltype="CF_SQL_INTEGER">
        AND typeid = <cfqueryparam value="#arguments.new_typeid#" cfsqltype="CF_SQL_INTEGER">
        AND catid = <cfqueryparam value="#arguments.new_catid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="INSitemcatxref_user_24468" access="public" returntype="numeric" >
    <cfargument name="new_typeid" type="numeric" required="true">
    <cfargument name="new_catid" type="numeric" required="true">
    <cfargument name="select_userid" type="numeric" required="true">

<cfquery result="result">
        INSERT INTO itemcatxref_user (typeid, catid, userid)
        VALUES (
            <cfqueryparam value="#arguments.new_typeid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="#arguments.new_catid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="#arguments.select_userid#" cfsqltype="CF_SQL_INTEGER">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>
</cfcomponent>