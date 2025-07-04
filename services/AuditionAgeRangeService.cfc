<cfcomponent displayname="AuditionAgeRangeService" hint="Handles operations for AuditionAgeRange table" >

<cffunction output="false" name="SELaudageranges" access="public" returntype="query">
        <cfargument name="isDeleted" type="boolean" required="true">

<cfquery name="result">
            SELECT rangeid, rangename 
            FROM audageranges 
            WHERE isdeleted = <cfqueryparam value="#arguments.isDeleted#" cfsqltype="CF_SQL_BIT">
            ORDER BY rangeid
        </cfquery>

<cfreturn result>
    </cffunction>

<cffunction output="false" name="INSaudageranges" access="public" returntype="numeric">
        <cfargument name="new_rangename" type="string" required="true">
        <cfargument name="new_age_min" type="numeric" required="true">
        <cfargument name="new_age_max" type="numeric" required="true">
        <cfargument name="new_age_group" type="string" required="true">
        <cfargument name="new_isDeleted" type="boolean" required="true">

<cfquery result="result">
            INSERT INTO audageranges (rangename, age_min, age_max, age_group, isDeleted)
            VALUES (
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.new_rangename)#" maxlength="100">,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_age_min#">,
                <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_age_max#">,
                <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#trim(arguments.new_age_group)#" maxlength="45">,
                <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#">
            )
        </cfquery>
         <cfreturn result.generatedKey>
    </cffunction>

<cffunction output="false" name="UPDaudageranges" access="public" returntype="void">
        <cfargument name="new_rangename" type="string" required="true">
        <cfargument name="new_age_min" type="numeric" required="true">
        <cfargument name="new_age_max" type="numeric" required="true">
        <cfargument name="new_age_group" type="string" required="true">
        <cfargument name="new_isDeleted" type="boolean" required="true">
        <cfargument name="new_rangeid" type="numeric" required="true">

<cfquery result="result">
            UPDATE audageranges 
            SET 
                rangename = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_rangename#" maxlength="100">,
                age_min = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_age_min#">,
                age_max = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_age_max#">,
                age_group = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_age_group#" maxlength="45">,
                isDeleted = <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#">
            WHERE 
                rangeid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_rangeid#">
        </cfquery>
    </cffunction>

<cffunction output="false" name="SELaudageranges_24552" access="public" returntype="query">
        <cfargument name="audroleid" type="numeric" required="true">

<cfquery name="result">
            SELECT g.rangename, g.rangeid 
            FROM audageranges g 
            INNER JOIN audageranges_audtion_xref x ON x.rangeid = g.rangeid 
            WHERE x.audroleid = <cfqueryparam value="#arguments.audroleid#" cfsqltype="cf_sql_integer"> 
            ORDER BY g.rangeid
        </cfquery>

<cfreturn result>
    </cffunction>

</cfcomponent>