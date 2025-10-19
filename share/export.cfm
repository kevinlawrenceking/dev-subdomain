<!---
    PURPOSE: Export shared contact data as CSV file (OPTIMIZED)
    AUTHOR: Updated by GitHub Copilot
    DATE: 2025-07-22
    PARAMETERS: shareID (public share identifier)
    DEPENDENCIES: remote_load_common.cfm
    OPTIMIZATIONS: Secure parameterization, simplified query, direct CSV output
--->

<cfinclude template="remote_load_common.cfm">

<!--- Validate required parameters --->
<cfparam name="url.shareID" default="">
<cfset shareID = trim(url.shareID)>
<cfif NOT len(shareID)>
    <cflocation url="index.cfm" addtoken="false">
</cfif>

<!--- Get user information from share identifier --->
<cfquery name="qUser" datasource="#dsn#" maxrows="1">
    SELECT 
        u.userid,
        u.userfirstname,
        u.userlastname
    FROM taousers u
    WHERE u.shareID = <cfqueryparam value="#shareID#" cfsqltype="cf_sql_varchar" maxlength="36">
    LIMIT 1
</cfquery>

<cfif qUser.recordCount EQ 0>
    <cfinclude template="invalid_token.cfm">
    <cfabort>
</cfif>

<!--- OPTIMIZED EXPORT QUERY: Use same data as main report --->
<cfquery name="qExportData" datasource="#dsn#">
    SELECT 
        s.Name,
        COALESCE(s.Company, '') AS Company,
        COALESCE(s.Title, '') AS Title,
        COALESCE(s.Audition, '') AS 'Audition_Status',
        COALESCE(s.last_met, '') AS 'Last_Met',
        COALESCE(s.lasteventtype, '') AS 'Meeting_Type',
        s.no_mtgs AS 'Total_Meetings',
        REPLACE(REPLACE(COALESCE(s.NotesLog, ''), '<BR>', ' | '), '\n', ' ') AS 'Notes_Log'
    FROM sharez s
    WHERE s.userid = <cfqueryparam value="#qUser.userid#" cfsqltype="cf_sql_integer">
    ORDER BY s.Name
</cfquery>

<!--- Generate unique filename --->
<cfset cleanFirstName = REReplace(qUser.userfirstname, "[^A-Za-z0-9]", "", "ALL")>
<cfset cleanLastName = REReplace(qUser.userlastname, "[^A-Za-z0-9]", "", "ALL")>
<cfset dateStamp = dateFormat(now(), "yyyymmdd")>
<cfset timeStamp = timeFormat(now(), "HHmmss")>
<cfset fileName = "#cleanFirstName##cleanLastName#_Contacts_#dateStamp#_#timeStamp#.csv">

<!--- Set CSV headers --->
<cfheader name="Content-Disposition" value="attachment; filename=#fileName#">
<cfheader name="Content-Type" value="text/csv; charset=utf-8">
<cfheader name="Cache-Control" value="no-cache, no-store, must-revalidate">
<cfheader name="Pragma" value="no-cache">
<cfheader name="Expires" value="0">

<!--- Output CSV content directly --->
<cfcontent type="text/csv" reset="true"><cfoutput>Name,Company,Title,Audition Status,Last Met,Last Meeting Type,Total Meetings,Notes Log
<cfloop query="qExportData">"#Replace(Name, '"', '""', 'ALL')#","#Replace(Company, '"', '""', 'ALL')#","#Replace(Title, '"', '""', 'ALL')#","#Replace(Audition_Status, '"', '""', 'ALL')#","#Replace(Last_Met, '"', '""', 'ALL')#","#Replace(Meeting_Type, '"', '""', 'ALL')#","#Total_Meetings#","#Replace(Notes_Log, '"', '""', 'ALL')#"
</cfloop></cfoutput>