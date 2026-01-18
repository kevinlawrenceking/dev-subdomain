<cfcomponent displayname="AuditionOpenCallOptionUserService" hint="Handles operations for AuditionOpenCallOptionUser table" > 
<cffunction output="false" name="SELaudopencalloptions_user" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT opencallid, opencallname
        FROM audopencalloptions_user
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        ORDER BY opencallname
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELaudopencalloptions_user_24262" access="public" returntype="query">
    <cfargument name="new_opencallid" type="numeric" required="true">

<cfquery name="result">
        SELECT opencallid, opencallname
        FROM audopencalloptions_user
        WHERE opencallid = <cfqueryparam value="#arguments.new_opencallid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELaudopencalloptions_user_24280" access="public" returntype="query">
    <cfargument name="new_opencallname" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT *
        FROM audopencalloptions_user
        WHERE opencallname = <cfqueryparam value="#arguments.new_opencallname#" cfsqltype="CF_SQL_VARCHAR">
        AND userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="INSaudopencalloptions_user" access="public" returntype="numeric">
    <cfargument name="new_opencallname" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery result="result">
        INSERT INTO audopencalloptions_user (opencallname, userid, isdeleted)
        VALUES (
            <cfqueryparam value="#arguments.new_opencallname#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
        )
    </cfquery><cfreturn result.generatedKey>
</cffunction>
</cfcomponent>