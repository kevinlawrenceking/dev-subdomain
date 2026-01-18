<cfcomponent displayname="AuditionCallbackTypeService" hint="Handles operations for AuditionCallbackType table" > 
<cffunction output="false" name="SELaudcallbacktypes" access="public" returntype="query">
    <cfargument name="audcatid" type="numeric" required="true">

<cfquery name="result">
        SELECT 
            callbacktypeid AS id, 
            callbacktype AS name 
        FROM 
            audcallbacktypes 
        WHERE 
            audstepid = 2 
            AND audcatid = <cfqueryparam value="#arguments.audcatid#" cfsqltype="CF_SQL_INTEGER"> 
            AND callbacktype <> <cfqueryparam value="Callback" cfsqltype="CF_SQL_VARCHAR"> 
        ORDER BY 
            callbacktype
    </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELaudcallbacktypes_24509" access="public" returntype="query">
    <cfargument name="audcatid" type="numeric" required="true">

<cfquery name="result">
        SELECT callbacktypeid AS id, callbacktype AS name
        FROM audcallbacktypes
        WHERE audstepid = 2
        AND audcatid = <cfqueryparam value="#arguments.audcatid#" cfsqltype="CF_SQL_INTEGER">
        AND callbacktype = <cfqueryparam value="Callback" cfsqltype="CF_SQL_VARCHAR">
        ORDER BY callbacktype
    </cfquery>

<cfreturn result>
</cffunction>
</cfcomponent>