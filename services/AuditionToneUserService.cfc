<cfcomponent displayname="AuditionToneUserService" hint="Handles operations for AuditionToneUser table" >

<cffunction output="false" name="INSaudtones_user" access="public" returntype="numeric">
    <cfargument name="tone" type="string" required="true">
    <cfargument name="audcatid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery result="result">
        INSERT INTO audtones_user (tone, audcatid, userid)
        VALUES (
            <cfqueryparam value="#arguments.tone#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.audcatid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="SELaudtones_user" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="new_audcatid" type="numeric" required="true">

<cfquery name="result">
        SELECT 
            a.toneid AS ID, 
            a.tone AS NAME, 
            a.audcatid, 
            a.userid 
        FROM 
            audtones_user a 
        WHERE 
            userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
            AND audcatid = <cfqueryparam value="#arguments.new_audcatid#" cfsqltype="CF_SQL_INTEGER"> 
        ORDER BY 
            a.tone
    </cfquery>

<cfreturn result>
</cffunction>

</cfcomponent>