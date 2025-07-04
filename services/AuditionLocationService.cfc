<cfcomponent displayname="AuditionLocationService" hint="Handles operations for AuditionLocation table" > 
<cffunction output="false" name="UPDaudlocations" access="public" returntype="void">
    <cfargument name="new_userid" type="numeric" required="true">
    <cfargument name="new_eventLocation" type="string" required="true">
    <cfargument name="new_audlocadd1" type="string" required="true">
    <cfargument name="new_audlocadd2" type="string" required="true">
    <cfargument name="new_audcity" type="string" required="true">
    <cfargument name="new_region_id" type="numeric" required="true">
    <cfargument name="new_audzip" type="string" required="true">
    <cfargument name="new_isDeleted" type="boolean" required="true">
    <cfargument name="new_audlocid" type="numeric" required="true">

<cfquery result="result">
        UPDATE audlocations 
        SET 
            userid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_userid#" null="#NOT len(trim(arguments.new_userid))#">,
            eventLocation = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_eventLocation#" maxlength="500" null="#NOT len(trim(arguments.new_eventLocation))#">,
            audlocadd1 = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_audlocadd1#" maxlength="500" null="#NOT len(trim(arguments.new_audlocadd1))#">,
            audlocadd2 = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_audlocadd2#" maxlength="500" null="#NOT len(trim(arguments.new_audlocadd2))#">,
            audcity = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_audcity#" maxlength="500" null="#NOT len(trim(arguments.new_audcity))#">,
            region_id = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_region_id#" null="#NOT len(trim(arguments.new_region_id))#">,
            audzip = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.new_audzip#" maxlength="50" null="#NOT len(trim(arguments.new_audzip))#">,
            isDeleted = <cfqueryparam cfsqltype="CF_SQL_BIT" value="#arguments.new_isDeleted#" null="#NOT len(trim(arguments.new_isDeleted))#">
        WHERE 
            audlocid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.new_audlocid#">
    </cfquery>
</cffunction>

<cffunction output="false" name="INSaudlocations" access="public" returntype="numeric">
    <cfargument name="userid" type="numeric" required="true">
    <cfargument name="custom" type="string" required="true">

<cfquery result="result">
        INSERT INTO audlocations (userid, eventLocation) 
        VALUES (
            <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">, 
            <cfqueryparam value="#arguments.custom#" cfsqltype="CF_SQL_VARCHAR">
        )
    </cfquery>
    <cfreturn result.generatedKey>
</cffunction>

<cffunction output="false" name="SELaudlocations" access="public" returntype="query">
    <cfargument name="userid" type="numeric" required="true">

<cfquery name="result">
        SELECT l.audlocid AS ID, l.eventLocation AS Name 
        FROM audlocations l 
        WHERE l.userid = <cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER"> 
        ORDER BY l.eventLocation
    </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>