<cfcomponent displayname="AuditionGenreUserService" hint="Handles operations for AuditionGenreUser table" > 
<cffunction output="false" name="SELaudgenres_user" access="public" returntype="query">
    <cfargument name="audcatid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT *
        FROM audgenres_user
        WHERE audcatid = <cfqueryparam value="#arguments.audcatid#" cfsqltype="CF_SQL_INTEGER">
        AND userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELaudgenres_user_24272" access="public" returntype="query">
    <cfargument name="new_audcatid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT * 
        FROM audgenres_user 
        WHERE audcatid = <cfqueryparam value="#arguments.new_audcatid#" cfsqltype="CF_SQL_INTEGER"> 
          AND userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELaudgenres_user_24273" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="new_audcatid" type="numeric" required="true">

<cfquery name="result">
        SELECT audgenreid, audgenre, audcatid
        FROM audgenres_user
        WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        AND audcatid = <cfqueryparam value="#arguments.new_audcatid#" cfsqltype="CF_SQL_INTEGER">
        ORDER BY audgenre
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELaudgenres_user_24285" access="public" returntype="query">
    <cfargument name="new_genre" type="string" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT audgenreid
        FROM audgenres_user
        WHERE audgenre = <cfqueryparam value="#arguments.new_genre#" cfsqltype="CF_SQL_VARCHAR">
        AND userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="INSaudgenres_user" access="public" returntype="numeric">
    <cfargument name="new_genre" type="string" required="true">
    <cfargument name="new_catid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery result="result">
        INSERT INTO audgenres_user (audgenre, audcatid, userid)
        VALUES (
            <cfqueryparam value="#arguments.new_genre#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.new_catid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="SELaudgenres_user_24523" access="public" returntype="query">
    <cfargument name="audroleid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT g.audgenre 
        FROM audgenres_user g 
        INNER JOIN audgenres_audition_xref x ON x.audgenreID = g.audgenreID 
        WHERE x.audroleid = <cfqueryparam value="#arguments.audroleid#" cfsqltype="CF_SQL_INTEGER"> 
        AND g.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
        ORDER BY g.audgenre
    </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>