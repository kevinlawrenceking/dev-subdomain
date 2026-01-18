<cfcomponent displayname="AuditionVocalTypeService" hint="Handles operations for AuditionVocalType table" > 
<cffunction output="false" name="SELaudvocaltypes" access="public" returntype="query">
    <cfargument name="isDeleted" type="boolean" required="true">

<cfquery name="result">
        SELECT vocaltypeid, vocaltype 
        FROM audvocaltypes 
        WHERE isdeleted = <cfqueryparam value="#arguments.isDeleted#" cfsqltype="CF_SQL_BIT">
        ORDER BY vocaltype
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="INSaudvocaltypes" access="public" returntype="numeric">
    <cfargument name="new_vocaltype" type="string" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">

<cfquery result="result">
        INSERT INTO audvocaltypes (vocaltype, isDeleted)
        VALUES (
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.new_vocaltype)#" maxlength="100">,
            <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="UPDaudvocaltypes" access="public" returntype="void">
    <cfargument name="new_vocaltype" type="string" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">
    <cfargument name="new_vocaltypeid" type="numeric" required="true">

<cfquery result="result">
        UPDATE audvocaltypes 
        SET vocaltype = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_vocaltype#" maxlength="100">,
            isDeleted = <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#">
        WHERE vocaltypeid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_vocaltypeid#">
    </cfquery>
</cffunction>
</cfcomponent>