<cfcomponent displayname="DebugService" hint="Handles debug logging">

<cffunction name="insertDebugLog" access="public" returntype="void">
    <cfargument name="filename" type="string" required="true">
    <cfargument name="debugDetails" type="string" required="true">

    <!--- Ensure debugDetails is not appended repeatedly --->
    <cfquery>
        INSERT INTO debugLog (filename, debugDetails, timestamp)
        VALUES (
            <cfqueryparam value="#arguments.filename#" cfsqltype="CF_SQL_VARCHAR">,
            <cfqueryparam value="#arguments.debugDetails#" cfsqltype="CF_SQL_LONGVARCHAR">,
            <cfqueryparam value="#Now()#" cfsqltype="CF_SQL_TIMESTAMP">
        )
    </cfquery>
</cffunction>


</cfcomponent>
