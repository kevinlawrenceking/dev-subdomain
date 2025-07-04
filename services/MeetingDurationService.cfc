<cfcomponent displayname="MeetingDurationService" hint="Handles operations for MeetingDuration table" > 
<cffunction output="false" name="SELmtgdurations" access="public" returntype="query">
    <cfargument name="new_durhours" type="numeric" required="true">

    <cfquery name="result">
        SELECT durid AS new_durid
        FROM mtgdurations
        WHERE durhours = <cfqueryparam value="#DecimalFormat(arguments.new_durhours)#" cfsqltype="CF_SQL_DOUBLE">
    </cfquery>

    <cfreturn result>
</cffunction>


<cffunction output="false" name="SELmtgdurations_24493" access="public" returntype="query">
    <cfargument name="new_durhours" type="numeric" required="true">

<cfquery name="result">
        SELECT durid AS new_durid
        FROM mtgdurations
        WHERE durhours = <cfqueryparam value="#DecimalFormat(arguments.new_durhours)#" cfsqltype="CF_SQL_DOUBLE">
    </cfquery>

<cfreturn result>
</cffunction>
<cffunction output="false" name="SELmtgdurations_24655" access="public" returntype="query">
    <cfargument name="new_durid" type="numeric" required="true">

<cfquery name="result">
    SELECT durid, 
           durhours, 
           CAST(durhours * 3600 AS decimal(20,2)) AS durseconds, 
           durname
    FROM mtgdurations
    WHERE durid = <cfqueryparam value="#arguments.new_durid#" cfsqltype="CF_SQL_INTEGER">
</cfquery>


<cfreturn result>
</cffunction>
<cffunction output="false" name="SELmtgdurations_24656" access="public" returntype="query">
    <cfargument name="conditions" type="struct" required="false" default="#structNew()#">

<cfset var queryResult = "">
    <cfset var sql = "SELECT durid, durhours, durname FROM mtgdurations">
    <cfset var whereClauses = []>
    <cfset var params = []>

<cfloop collection="#arguments.conditions#" item="key">
        <cfif listFindNoCase("durid,durhours,durname", key)>
            <cfset arrayAppend(whereClauses, "#key# = ?")>
            <cfset arrayAppend(params, {value=arguments.conditions[key], cfsqltype=getSQLType(key)})>
        </cfif>
    </cfloop>

<!--- Add WHERE clause if conditions exist --->
    <cfif arrayLen(whereClauses) gt 0>
        <cfset sql &= " WHERE " & arrayToList(whereClauses, " AND ")>
    </cfif>

<!--- Add ORDER BY clause --->
    <cfset sql &= " ORDER BY durid">

<!--- Execute the query --->
    <cfquery result="result" name="queryResult">
        #sql#
        <cfloop array="#params#" index="param">
            <cfqueryparam value="#param.value#" cfsqltype="#param.cfsqltype#">
        </cfloop>
    </cfquery>

<cfreturn queryResult>
</cffunction>

<cffunction name="SELdurations" access="public" returntype="query" output="false">
    <cfquery name="durationsQuery">
        SELECT durid, durhours, durname, (durhours * 3600) AS durseconds
        FROM mtgdurations 
        ORDER BY durid
    </cfquery>
    <cfreturn durationsQuery>
</cffunction>


</cfcomponent>