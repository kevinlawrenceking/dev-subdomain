<cfcomponent displayname="AuditionPayCycleService" hint="Handles operations for AuditionPayCycle table" > 
<cffunction output="false" name="SELaudpaycycles" access="public" returntype="query">
    <cfargument name="paycycleid" type="numeric" required="false">

<cfquery name="result">
        SELECT paycycleid AS id, paycycle AS name
        FROM audpaycycles
        WHERE 1=1
        <cfif structKeyExists(arguments, "paycycleid")>
            AND paycycleid = <cfqueryparam value="#arguments.paycycleid#" cfsqltype="CF_SQL_INTEGER">
        </cfif>
        ORDER BY paycycle
    </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELaudpaycycles_24579" access="public" returntype="query">
    <cfargument name="conditions" type="struct" required="false" default="#structNew()#">
    <cfset var queryResult = "">
    <cfset var sql = "SELECT paycycleid AS id, paycyclename AS name FROM audpaycycles">
    <cfset var whereClause = "">
    <cfset var paramList = []>

<!--- Construct WHERE clause dynamically --->
    <cfif structCount(arguments.conditions) gt 0>
        <cfset whereClause = " WHERE ">
        <cfloop collection="#arguments.conditions#" item="key">
            <cfif key eq "id">
                <cfset whereClause &= "paycycleid = ? AND ">
                <cfset arrayAppend(paramList, {value=arguments.conditions[key], cfsqltype="CF_SQL_INTEGER"})>
            </cfif>
            <cfif key eq "name">
                <cfset whereClause &= "paycyclename LIKE ? AND ">
                <cfset arrayAppend(paramList, {value=arguments.conditions[key], cfsqltype="CF_SQL_VARCHAR"})>
            </cfif>
        </cfloop>
        <!--- Remove trailing 'AND ' --->
        <cfset whereClause = left(whereClause, len(whereClause) - 4)>
    </cfif>

<!--- Complete SQL statement --->
    <cfset sql &= whereClause & " ORDER BY paycyclename">

<!--- Execute query --->
    <cfquery result="result" name="queryResult">
        #sql#
        <cfloop array="#paramList#" index="param">
            <cfqueryparam value="#param.value#" cfsqltype="#param.cfsqltype#">
        </cfloop>
    </cfquery>

<!--- Return the result --->
    <cfreturn queryResult>
</cffunction>
</cfcomponent>