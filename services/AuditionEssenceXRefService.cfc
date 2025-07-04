<cfcomponent displayname="AuditionEssenceXRefService" hint="Handles operations for AuditionEssenceXRef table" > 
<cffunction output="false" name="SELaudessences_audtion_xref" access="public" returntype="query">
    <cfargument name="essencename" type="string" required="true">
    <cfargument name="audroleid" type="numeric" required="true">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT *
        FROM audessences_audtion_xref x
        INNER JOIN essences e ON e.essenceid = x.essenceid
        WHERE e.essencename = <cfqueryparam value="#arguments.essencename#" cfsqltype="CF_SQL_VARCHAR">
        AND x.audroleid = <cfqueryparam value="#arguments.audroleid#" cfsqltype="CF_SQL_INTEGER">
        AND e.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">
        AND e.isdeleted = 0
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="DELaudessences_audtion_xref" access="public" returntype="void">
    <cfargument name="new_audroleid" type="numeric" required="true">

<cfquery result="result">
        DELETE FROM audessences_audtion_xref 
        WHERE audroleid = <cfqueryparam value="#arguments.new_audroleid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>

<cffunction output="false" name="INSaudessences_audtion_xref" access="public" returntype="numeric">
    <cfargument name="new_essenceid" type="numeric" required="true">
    <cfargument name="new_audroleid" type="numeric" required="true">

<cfquery result="result">
        INSERT INTO audessences_audtion_xref (essenceid, audroleid)
        VALUES (
            <cfqueryparam value="#arguments.new_essenceid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="#arguments.new_audroleid#" cfsqltype="CF_SQL_INTEGER">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>
</cfcomponent>