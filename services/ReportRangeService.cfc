<cfcomponent displayname="ReportRangeService" hint="Handles operations for ReportRange table" >

<cffunction output="false" name="SELreportranges" access="public" returntype="query">
    <!--- Function to retrieve report ranges excluding specific IDs provided as a comma-separated string. --->

<cfquery name="qryResult">
        SELECT rangeid, rangename, rangestart, rangeend
        FROM reportranges
        where rangeid not in (1,7)
    </cfquery>

<cfreturn qryResult>
</cffunction>

<cffunction output="false" name="UPDreportranges" access="public" returntype="void">
    <cfargument name="new_rangestart" type="date" required="true">
    <cfargument name="new_rangeend" type="date" required="true">
    <cfargument name="current_rangeid" type="numeric" required="true">

<cfquery result="result">
        UPDATE reportranges 
        SET rangestart = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.new_rangestart#" />, 
            rangeend = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.new_rangeend#" />
        WHERE rangeid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.current_rangeid#" />
    </cfquery>

</cffunction>

<cffunction output="false" name="UPDreportranges_24221" access="public" returntype="void">
    <cfargument name="customStart" type="date" required="true">
    <cfargument name="customEnd" type="date" required="true">

<cfquery result="result">
        UPDATE reportranges 
        SET rangestart = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.customStart#" />, 
            rangeend = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.customEnd#" />
        WHERE rangename = 'Custom'
    </cfquery>

</cffunction>

<cffunction output="false" name="SELreportranges_24229" access="public" returntype="struct">
    <cfargument name="new_rangeid" type="numeric" required="true">

<!--- Query to fetch the range details --->
    <cfquery name="result">
        SELECT rangeid, rangename, rangestart, rangeend
        FROM reportranges
        WHERE rangeid = <cfqueryparam value="#arguments.new_rangeid#" cfsqltype="CF_SQL_INTEGER">
    </cfquery>

<!--- Initialize the output struct --->
    <cfset var rangeSelected = {}>
    <cfif result.recordcount EQ 1>
        <cfset rangeSelected.rangeid = result.rangeid>
        <cfset rangeSelected.rangename = result.rangename>

<!--- Validate and set rangestart --->
        <cfif IsDate(result.rangestart)>
            <cfset rangeSelected.rangestart = DateFormat(result.rangestart, "yyyy-mm-dd")>
        <cfelse>
            <cfset rangeSelected.rangestart = "1900-01-01">
        </cfif>

<!--- Validate and set rangeend --->
        <cfif IsDate(result.rangeend)>
            <cfset rangeSelected.rangeend = DateFormat(result.rangeend, "yyyy-mm-dd")>
        <cfelse>
            <cfset rangeSelected.rangeend = "2100-01-01">
        </cfif>
    <cfelse>
        <!--- Handle case where no record is found --->
        <cfset rangeSelected.error = "No record found for rangeid #arguments.new_rangeid#">
    </cfif>

<cfreturn rangeSelected>
</cffunction>

<cffunction name="getReportRanges" access="public" returntype="query" output="false">
    <cfquery name="result">
        SELECT 
            rangeid, 
            rangename, 
            rangestart, 
            rangeend 
        FROM reportranges 
        WHERE 1=1
    </cfquery>
    <cfreturn result>
</cffunction>

<cffunction name="getCFSQLType" access="public" returntype="string" output="false">
    <cfargument name="columnName" type="string" required="true">

<cfif arguments.columnName EQ "rangeid">
        <cfreturn "CF_SQL_INTEGER">
    <cfelseif arguments.columnName EQ "rangename">
        <cfreturn "CF_SQL_VARCHAR">
    <cfelseif arguments.columnName EQ "rangestart" OR arguments.columnName EQ "rangeend">
        <cfreturn "CF_SQL_TIMESTAMP">
    <cfelse>
        <cfreturn "CF_SQL_VARCHAR">
    </cfif>
</cffunction>

</cfcomponent>