<cfcomponent displayname="AuditionStepService" hint="Handles operations for AuditionStep table" > 
<cffunction output="false" name="SELaudsteps" access="public" returntype="query">
    <cfargument name="stepinfo1" type="string" required="false">

<cfquery name="result">
            SELECT *
            FROM audsteps
            WHERE stepinfo1 IS NOT NULL
            <cfif structKeyExists(arguments, "stepinfo1") and len(arguments.stepinfo1)>
                AND stepinfo1 = <cfqueryparam value="#arguments.stepinfo1#" cfsqltype="CF_SQL_VARCHAR">
            </cfif>
        </cfquery>
    <cfreturn result>
</cffunction>
<cffunction output="false" name="SELaudsteps_23784" access="public" returntype="query">
    <cfargument name="new_audstepid" type="numeric" required="true">

<cfquery name="result">
            SELECT audstep
            FROM audsteps
            WHERE audstepid = <cfqueryparam value="#arguments.new_audstepid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
    <cfreturn result>
</cffunction>
<cffunction output="false" name="SELaudsteps_23792" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">
    <cfset var result = "" />
        <cfquery name="result">
            SELECT audstepid AS id, audstep AS name
            FROM audsteps
            WHERE audstepid IN (
                SELECT audstepid
                FROM events
                WHERE userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER" />
                AND isdeleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT" />
            )
            ORDER BY audstep
        </cfquery>
    <cfreturn result />
</cffunction>
<cffunction output="false" name="SELaudsteps_24083" access="public" returntype="query">
    <cfargument name="isDeleted" type="boolean" required="true">

<cfquery name="result">
            SELECT 
                audstepid AS id, 
                audstep AS NAME 
            FROM 
                audsteps 
            WHERE 
                isdeleted = <cfqueryparam value="#arguments.isDeleted#" cfsqltype="CF_SQL_BIT"> 
            ORDER BY 
                audstep
        </cfquery>
    <cfreturn result>
</cffunction>
<cffunction output="false" name="INSaudsteps" access="public" returntype="numeric">
    <cfargument name="new_audstep" type="string" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">
        <cfquery result="result">
            INSERT INTO audsteps (audstep, isDeleted)
            VALUES (
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_audstep#" maxlength="100" null="#NOT len(trim(arguments.new_audstep))#">,
                <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#" null="#NOT len(trim(arguments.new_isDeleted))#">
            )
        </cfquery>
        <cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="UPDaudsteps" access="public" returntype="void">
    <cfargument name="new_audstep" type="string" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">
    <cfargument name="new_audstepid" type="numeric" required="true">
        <cfquery result="result">
            UPDATE audsteps 
            SET 
                audstep = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_audstep#" maxlength="100" null="#NOT len(trim(arguments.new_audstep))#">, 
                isDeleted = <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#" null="#NOT len(trim(arguments.new_isDeleted))#"> 
            WHERE 
                audstepid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audstepid#">
        </cfquery>
</cffunction>
</cfcomponent>