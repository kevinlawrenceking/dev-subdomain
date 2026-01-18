<cfcomponent displayname="AuditionDialectService" hint="Handles operations for AuditionDialect table" > 
<cffunction output="false" name="INSauddialects" access="public" returntype="numeric">
    <cfargument name="new_auddialect" type="string" required="true">
    <cfargument name="new_audCatid" type="numeric" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">

<cfquery result="result">
        INSERT INTO auddialects (auddialect, audCatid, isDeleted) 
        VALUES (
            <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_auddialect#" maxlength="100" null="#NOT len(trim(arguments.new_auddialect))#">,
            <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audCatid#" null="#NOT len(trim(arguments.new_audCatid))#">,
            <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#" null="#NOT len(trim(arguments.new_isDeleted))#">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="UPDauddialects" access="public" returntype="void">
    <cfargument name="new_auddialect" type="string" required="true">
    <cfargument name="new_audCatid" type="numeric" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">
    <cfargument name="new_auddialectid" type="numeric" required="true">

<cfquery result="result">
        UPDATE auddialects 
        SET 
            auddialect = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.new_auddialect)#" maxlength="100" null="#NOT len(trim(arguments.new_auddialect))#" />, 
            audCatid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audCatid#" null="#NOT len(trim(arguments.new_audCatid))#" />, 
            isDeleted = <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#" null="#NOT len(trim(arguments.new_isDeleted))#" /> 
        WHERE 
            auddialectid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_auddialectid#" />
    </cfquery>
</cffunction>
</cfcomponent>