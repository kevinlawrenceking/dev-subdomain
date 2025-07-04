<cfcomponent displayname="GenderPronounUserService" hint="Handles operations for GenderPronounUser table" >

<cffunction output="false" name="SELgenderpronouns_users" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT genderPronoun
        FROM genderpronouns_users
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELgenderpronouns_users_24203" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="custom" type="string" required="true">

<cfquery name="result">
        SELECT * 
        FROM genderpronouns_users 
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
        AND genderPronoun = <cfqueryparam value="#arguments.custom#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="INSgenderpronouns_users" access="public" returntype="numeric">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="custom" type="string" required="true">

<cfquery result="result">
        INSERT INTO genderpronouns_users_tbl (userid, isDeleted, isCustom, genderpronoun, genderpronounPlural)
        VALUES (
            <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">,
            <cfqueryparam value="1" cfsqltype="CF_SQL_BIT">,
            <cfqueryparam value="#arguments.custom#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.custom#" cfsqltype="CF_SQL_VARCHAR">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="SELgenderpronouns_users_24444" access="public" returntype="query">
    <cfargument name="genderpronoun" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT * 
        FROM genderpronouns_users 
        WHERE genderpronoun = <cfqueryparam value="#arguments.genderpronoun#" cfsqltype="CF_SQL_VARCHAR"> 
        AND userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="INSgenderpronouns_users_24445" access="public" returntype="numeric">
    <cfargument name="genderpronoun" type="string" required="true">
    <cfargument name="genderpronounplural" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery result="result">
        INSERT INTO genderpronouns_users (genderpronoun, genderpronounplural, userid)
        VALUES (
            <cfqueryparam value="#arguments.genderpronoun#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.genderpronounplural#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="SELgenderpronouns_users_24627" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT genderPronoun
        FROM genderpronouns_users
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>

</cfcomponent>