<cfcomponent displayname="PageFieldService" hint="Handles operations for PageField table" >

<cffunction output="false" name="SELpgfields" access="public" returntype="query">
    <cfargument name="rpgid" type="numeric" required="true">

<cfquery name="result">
        SELECT fname 
        FROM pgfields 
        WHERE pgid = <cfqueryparam value="#arguments.rpgid#" cfsqltype="CF_SQL_INTEGER"> 
        AND updatename = <cfqueryparam value="ID" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELpgfields_24115" access="public" returntype="query">
    <cfargument name="rpgid" type="numeric" required="true">

<cfquery name="result">
        SELECT *
        FROM pgfields
        WHERE pgid = <cfqueryparam value="#arguments.rpgid#" cfsqltype="CF_SQL_INTEGER">
        AND updatename = <cfqueryparam value="ID" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELpgfields_24651" access="public" returntype="query">
    <cfargument name="pgid" type="numeric" required="true">
    <cfargument name="updatename" type="string" required="true" default="ID">

<cfquery name="result">
        SELECT * 
        FROM pgfields 
        WHERE pgid = <cfqueryparam value="#arguments.pgid#" cfsqltype="CF_SQL_INTEGER"> 
        AND updatename = <cfqueryparam value="#arguments.updatename#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

<cfreturn result>
</cffunction>

</cfcomponent>