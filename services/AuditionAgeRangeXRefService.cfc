<cfcomponent displayname="AuditionAgeRangeXRefService" hint="Handles operations for AuditionAgeRangeXRef table" >

<cffunction output="false" name="SELaudageranges_audtion_xref" access="public" returntype="query">
        <cfargument name="audroleid" type="numeric" required="true">
        <cfargument name="new_rangeid" type="numeric" required="true">

<cfquery name="result">
            SELECT id,audRoleID,rangeid 
            FROM audageranges_audtion_xref 
            WHERE audroleid = <cfqueryparam value="#arguments.audroleid#" cfsqltype="CF_SQL_INTEGER"> 
            AND rangeid = <cfqueryparam value="#arguments.new_rangeid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

<cfreturn result>
    </cffunction>

<cffunction output="false" name="DELaudageranges_audtion_xref" access="public" returntype="void">
        <cfargument name="new_audroleid" type="numeric" required="true">

<cfquery result="result">
            DELETE FROM audageranges_audtion_xref
            WHERE audroleid = <cfqueryparam value="#arguments.new_audroleid#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
    </cffunction>

<cffunction output="false" name="INSaudageranges_audtion_xref" access="public" returntype="numeric">
        <cfargument name="new_rangeid" type="numeric" required="true">
        <cfargument name="new_audroleid" type="numeric" required="true">

<cfquery result="result">
            INSERT INTO audageranges_audtion_xref (rangeid, audroleid)
            VALUES (
                <cfqueryparam value="#arguments.new_rangeid#" cfsqltype="CF_SQL_INTEGER">,
                <cfqueryparam value="#arguments.new_audroleid#" cfsqltype="CF_SQL_INTEGER">
            )
        </cfquery>
         <cfreturn result.generatedKey>
    </cffunction>

<cffunction output="false" name="INSaudageranges_audtion_xref_24502" access="public" returntype="numeric">
        <cfargument name="new_audRoleID" type="numeric" required="true">
        <cfargument name="new_rangeid" type="numeric" required="true">

<cfquery result="result">
            INSERT INTO audageranges_audtion_xref (audRoleID, rangeid)
            VALUES (
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audRoleID#" null="#NOT len(trim(arguments.new_audRoleID))#">,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_rangeid#" null="#NOT len(trim(arguments.new_rangeid))#">
            )
        </cfquery>
        <cfreturn result.generatedKey>
    </cffunction>

<cffunction output="false" name="UPDaudageranges_audtion_xref" access="public" returntype="void">
        <cfargument name="new_audRoleID" type="numeric" required="true">
        <cfargument name="new_rangeid" type="numeric" required="true">
        <cfargument name="new_id" type="numeric" required="true">

<cfquery result="result">
            UPDATE audageranges_audtion_xref 
            SET 
                audRoleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audRoleID#" null="#NOT len(trim(arguments.new_audRoleID))#">,
                rangeid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_rangeid#" null="#NOT len(trim(arguments.new_rangeid))#">
            WHERE 
                id = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_id#">
        </cfquery>
    </cffunction>

</cfcomponent>