<cfcomponent displayname="AuditionPlatformUserService" hint="Handles operations for AuditionPlatformUser table" >

<cffunction output="false" name="SELaudPlatforms_user_23778" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="CustomPlatform" type="string" required="true">

<cfquery name="result">
        SELECT audplatformid 
        FROM audPlatforms_user_tbl 
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
        AND audplatform = <cfqueryparam value="#arguments.CustomPlatform#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="INSaudPlatforms_user_23779" access="public" returntype="numeric">
    <cfargument name="CustomPlatform" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery result="result">
        INSERT INTO audPlatforms_user_tbl (audPlatform, userid, isdeleted) 
        VALUES (
            <cfqueryparam value="#arguments.CustomPlatform#" cfsqltype="CF_SQL_VARCHAR">, 
            <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
        )
    </cfquery>
    <cfreturn result.GeneratedKey>
</cffunction>

<cffunction output="false" name="SELaudplatforms_user_24582" access="public" returntype="query">
    <cfargument name="new_userid" type="numeric" required="true">

<cfquery name="result">
        SELECT audplatformid AS ID, audplatform AS NAME
        FROM audplatforms_user
        WHERE userid = <cfqueryparam value="#arguments.new_userid#" cfsqltype="cf_sql_integer" />
        ORDER BY audplatform
    </cfquery>

<cfreturn result>
</cffunction>

</cfcomponent>