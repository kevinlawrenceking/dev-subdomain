<cfcomponent displayname="AuditionPlatformsService" hint="Handles operations for AuditionPlatforms table" > 
<cffunction output="false" name="INSaudplatforms" access="public" returntype="numeric">
    <cfargument name="new_audplatform" type="string" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">

<cfquery result="result">
        INSERT INTO audplatforms (audplatform, isDeleted)
        VALUES (
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.new_audplatform)#" maxlength="100" null="#NOT len(trim(arguments.new_audplatform))#">,
            <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#" null="#NOT len(trim(arguments.new_isDeleted))#">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>
<cffunction output="false" name="UPDaudplatforms" access="public" returntype="void">
    <cfargument name="new_audplatform" type="string" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">
    <cfargument name="new_audplatformid" type="numeric" required="true">

<cfquery result="result">
        UPDATE audplatforms 
        SET 
            audplatform = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_audplatform#" maxlength="100" null="#NOT len(trim(arguments.new_audplatform))#">,
            isDeleted = <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#" null="#NOT len(trim(arguments.new_isDeleted))#">
        WHERE 
            audplatformid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audplatformid#">
    </cfquery>
</cffunction>
</cfcomponent>