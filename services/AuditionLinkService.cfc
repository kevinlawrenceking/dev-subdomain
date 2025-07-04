Here is the updated ColdFusion component code:

<cfcomponent displayname="AuditionLinkService" hint="Handles operations for AuditionLink table" > 
<cffunction output="false" name="SELaudlinks" access="public" returntype="query">
    <cfargument name="audroleid" type="numeric" required="true">

<cfquery name="result">
        SELECT * 
        FROM audlinks 
        WHERE audroleid = <cfqueryparam value="#arguments.audroleid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="INSaudlinks" access="public" returntype="numeric">
    <cfargument name="linkname" type="string" required="true">
    <cfargument name="linkurl" type="string" required="true">
    <cfargument name="audroleid" type="numeric" required="true">

<cfquery result="result">
        INSERT INTO audlinks_tbl (linkname, linkurl, isdeleted, userid, audroleid)
        VALUES (
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.linkname#" />,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.linkurl#" />,
            <cfqueryparam cfsqltype="cf_sql_integer" value="0" />,
            <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#" />,
            <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.audroleid#" />
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="DETaudlinks" access="public" returntype="query">
    <cfargument name="linkid" type="numeric" required="true">

<cfquery name="result">
        SELECT * 
        FROM audlinks 
        WHERE linkid = <cfqueryparam value="#arguments.linkid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="UPDaudlinks" access="public" returntype="void">
    <cfargument name="linkid" type="numeric" required="true">

<cfquery result="result">
        UPDATE audlinks 
        SET isdeleted = 1 
        WHERE linkid = <cfqueryparam value="#arguments.linkid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>
</cfcomponent>
