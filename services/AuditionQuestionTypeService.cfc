<cfcomponent displayname="AuditionQuestionTypeService" hint="Handles operations for AuditionQuestionType table" > 
<cffunction output="false" name="INSaudqtypes" access="public" returntype="numeric">
    <cfargument name="new_qtype" type="string" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">

<cfquery result="result" name="insertQuery">
        INSERT INTO audqtypes (qtype, isDeleted) 
        VALUES (
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_qtype#" maxlength="100" null="#NOT len(trim(arguments.new_qtype))#">,
            <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#">
        );
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="UPDaudqtypes" access="public" returntype="void">
    <cfargument name="new_qtype" type="string" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">
    <cfargument name="new_qtypeid" type="numeric" required="true">

<cfquery result="result">
        UPDATE audqtypes 
        SET 
            qtype = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_qtype#" maxlength="100" null="#NOT len(trim(arguments.new_qtype))#">, 
            isDeleted = <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#"> 
        WHERE 
            qtypeid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_qtypeid#">
    </cfquery>
</cffunction>
</cfcomponent>