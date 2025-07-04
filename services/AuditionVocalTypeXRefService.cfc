<cfcomponent displayname="AuditionVocalTypeXRefService" hint="Handles operations for AuditionVocalTypeXRef table" >

<cffunction output="false" name="audvocaltypes_audition_xref" access="public" returntype="query">
    <cfargument name="audroleid" type="numeric" required="true">

<cfquery name="result">
SELECT * FROM audvocaltypes t 
inner join audvocaltypes_audition_xref x on x.vocaltypeid = t.vocaltypeid
WHERE audroleid = <cfqueryparam value="#arguments.audroleid#" cfsqltype="CF_SQL_INTEGER"> 
  </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELaudvocaltypes_audition_xref" access="public" returntype="query">
    <cfargument name="audroleid" type="numeric" required="true">
    <cfargument name="new_vocaltypeid" type="numeric" required="true">

<cfquery name="result">
        SELECT * 
        FROM audvocaltypes_audition_xref 
        WHERE audroleid = <cfqueryparam value="#arguments.audroleid#" cfsqltype="CF_SQL_INTEGER"> 
        AND vocaltypeid = <cfqueryparam value="#arguments.new_vocaltypeid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="DELaudvocaltypes_audition_xref" access="public" returntype="void">
    <cfargument name="audroleid" type="numeric" required="true">

<cfquery result="result">
        DELETE FROM audvocaltypes_audition_xref
        WHERE audroleid = <cfqueryparam value="#arguments.audroleid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>
</cffunction>

<cffunction output="false" name="INSaudvocaltypes_audition_xref" access="public" returntype="numeric">
    <cfargument name="new_vocaltypeid" type="numeric" required="true">
    <cfargument name="new_audroleid" type="numeric" required="true">

<cfquery result="result">
        INSERT INTO audvocaltypes_audition_xref (vocaltypeid, audroleid)
        VALUES (
            <cfqueryparam value="#arguments.new_vocaltypeid#" cfsqltype="CF_SQL_INTEGER">,
            <cfqueryparam value="#arguments.new_audroleid#" cfsqltype="CF_SQL_INTEGER">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="INSaudvocaltypes_audition_xref_24613" access="public" returntype="numeric">
    <cfargument name="new_audRoleID" type="numeric" required="true">
    <cfargument name="new_vocaltypeid" type="numeric" required="true">

<cfquery result="result">
        INSERT INTO audvocaltypes_audition_xref (audRoleID, vocaltypeid)
        VALUES (
            <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audRoleID#" null="#NOT len(trim(arguments.new_audRoleID))#">,
            <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_vocaltypeid#" null="#NOT len(trim(arguments.new_vocaltypeid))#">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="UPDaudvocaltypes_audition_xref" access="public" returntype="void" >
    <cfargument name="new_audRoleID" type="numeric" required="true">
    <cfargument name="new_vocaltypeid" type="numeric" required="true">
    <cfargument name="new_id" type="numeric" required="true">

<cfquery result="result">
        UPDATE audvocaltypes_audition_xref
        SET 
            audRoleID = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audRoleID#" null="#NOT len(trim(arguments.new_audRoleID))#">,
            vocaltypeid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_vocaltypeid#" null="#NOT len(trim(arguments.new_vocaltypeid))#">
        WHERE 
            id = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_id#" null="#NOT len(trim(arguments.new_id))#">
    </cfquery>
</cffunction>

</cfcomponent>