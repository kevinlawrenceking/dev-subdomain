<cfcomponent displayname="AuditionRoleTypeService" hint="Handles operations for AuditionRoleType table" >

<cffunction output="false" name="SELaudroletypes" access="public" returntype="query">
    <cfargument name="audcatid" type="numeric" required="true">

<cfquery name="result">
        SELECT audroletypeid AS id, audroletype AS name
        FROM audroletypes
        WHERE audcatid = <cfqueryparam value="#arguments.audcatid#" cfsqltype="CF_SQL_INTEGER">
        AND isdeleted = <cfqueryparam value="false" cfsqltype="CF_SQL_BIT">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="INSaudroletypes" access="public" returntype="numeric">
    <cfargument name="new_audroletype" type="string" required="true">
    <cfargument name="new_audCatid" type="numeric" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">

<cfquery result="result">
        INSERT INTO audroletypes (audroletype, audCatid, isDeleted)
        VALUES (
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_audroletype#" maxlength="100">,
            <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audCatid#">,
            <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="UPDaudroletypes" access="public" returntype="void">
    <cfargument name="new_audroletype" type="string" required="true">
    <cfargument name="new_audCatid" type="numeric" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">
    <cfargument name="new_audroletypeid" type="numeric" required="true">

<cfquery result="result">
        UPDATE audroletypes 
        SET 
            audroletype = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.new_audroletype)#" maxlength="100">,
            audCatid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audCatid#">,
            isDeleted = <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#">
        WHERE 
            audroletypeid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audroletypeid#">
    </cfquery>
</cffunction>

</cfcomponent>