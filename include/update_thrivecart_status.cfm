<!---
    PURPOSE: AJAX handler for updating ThriveCart order status
    AUTHOR: Kevin King
    DATE: 2025-09-12
    PARAMETERS: id, status
    RETURNS: JSON response
--->

<cfsetting enablecfoutputonly="true">
<cfcontent type="application/json">

<cfparam name="form.id" default="">
<cfparam name="form.status" default="">

<cfset response = {}>

<cftry>
    <!--- Validate parameters --->
    <cfif not isNumeric(form.id) or len(trim(form.status)) eq 0>
        <cfset response.success = false>
        <cfset response.message = "Invalid parameters">
    <cfelse>
        <!--- Validate status value --->
        <cfset validStatuses = "Pending,Emailed,Completed,Cancelled">
        <cfif not listFindNoCase(validStatuses, form.status)>
            <cfset response.success = false>
            <cfset response.message = "Invalid status value">
        <cfelse>
            <!--- Update the status --->
            <cfquery datasource="#application.dsn#">
                UPDATE thrivecart 
                SET status = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.status#">
                WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.id#">
            </cfquery>
            
            <cfset response.success = true>
            <cfset response.message = "Status updated successfully">
        </cfif>
    </cfif>
    
    <cfcatch>
        <cfset response.success = false>
        <cfset response.message = "Database error: " & cfcatch.message>
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(response)#</cfoutput>
