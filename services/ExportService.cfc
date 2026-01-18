<cfcomponent displayname="ExportService" hint="Handles operations for Export table" > 
  <cffunction output="false" name="INSexports" access="public" returntype="numeric">
        <cfargument name="userid" type="numeric" required="true">

<cfquery result="result" name="insertQuery">
            INSERT INTO exports (userid)
            VALUES (<cfqueryparam value="#arguments.userid#" cfsqltype="CF_SQL_INTEGER">)
        </cfquery>

<cfreturn result.generatedKey>
    </cffunction>

<cffunction output="false" name="UPDexports" access="public" returntype="void">
        <cfargument name="exportID" type="numeric" required="true">
        <cfargument name="status" type="string" required="true">

<cfquery result="result">
            UPDATE exports
            SET exportstatus = <cfqueryparam value="#arguments.status#" cfsqltype="CF_SQL_VARCHAR">
            WHERE exportid = <cfqueryparam value="#arguments.exportID#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
    </cffunction>
</cfcomponent>