<cfcomponent displayname="FUActionService" hint="Handles operations for FUAction table" > 
<cffunction output="false" name="SELfuactions" access="public" returntype="query">
    <cfargument name="target_id_system" type="numeric" required="true">

<cfquery name="result">
        SELECT actionid, actiondaysno, actiondaysrecurring
        FROM fuactions
        WHERE actionid IN (
            SELECT actionid 
            FROM fuactions 
            WHERE systemid = <cfqueryparam value="#arguments.target_id_system#" cfsqltype="CF_SQL_INTEGER">
        )
    </cfquery>

<cfreturn result>
</cffunction>

<cffunction output="false" name="SELfuactions_24453" access="public" returntype="query">
    <cfargument name="actionId" type="numeric" required="false">
    <cfargument name="actionDaysNo" type="numeric" required="false">
    <cfargument name="actionDaysRecurring" type="numeric" required="false">

<cfset var queryResult = "">

<cfquery result="result" name="queryResult">
        SELECT actionid, actiondaysno, actiondaysrecurring
        FROM fuactions
        WHERE 1=1
        <cfif structKeyExists(arguments, "actionId")>
            AND actionid = <cfqueryparam value="#arguments.actionId#" cfsqltype="CF_SQL_INTEGER">
        </cfif>
        <cfif structKeyExists(arguments, "actionDaysNo")>
            AND actiondaysno = <cfqueryparam value="#arguments.actionDaysNo#" cfsqltype="CF_SQL_INTEGER">
        </cfif>
        <cfif structKeyExists(arguments, "actionDaysRecurring")>
            AND actiondaysrecurring = <cfqueryparam value="#arguments.actionDaysRecurring#" cfsqltype="CF_SQL_INTEGER">
        </cfif>
    </cfquery>

<cfreturn queryResult>
</cffunction>
</cfcomponent>