<!---
    PURPOSE: AJAX endpoint to fetch detailed note information
    AUTHOR: GitHub Copilot
    DATE: 2025-08-03
    PARAMETERS: note_id (required)
    RETURNS: JSON response with note details
--->

<!--- Set content type for JSON response --->
<cfcontent type="application/json">
<cfheader name="Content-Type" value="application/json; charset=utf-8">

<!--- Include common settings if not already included --->
<cfif NOT isDefined('dsn')>
    <cfinclude template="remote_load_common.cfm">
</cfif>

<!--- Parameter validation --->
<cfparam name="noteid" default="0">

<!--- Initialize response structure --->
<cfset response = structNew()>
<cfset response.success = false>
<cfset response.message = "">
<cfset response.notedetails = "">
<cfset response.notedetailshtml = "">
<cfset response.timestamp = "">

<cftry>
    <!--- Validate noteid parameter --->
    <cfif NOT isNumeric(noteid) OR val(noteid) LTE 0>
        <cfset response.message = "Invalid note ID provided">
        <cfoutput>#serializeJSON(response)#</cfoutput>
        <cfabort>
    </cfif>

    <!--- Query to get note details --->
    <cfquery name="qGetNoteDetails" datasource="#dsn#">
        SELECT 
            noteid,
            notedetails,
            notedetailshtml,
            notetimestamp
        FROM noteslog 
        WHERE noteid = <cfqueryparam value="#val(noteid)#" cfsqltype="cf_sql_integer">
    </cfquery>

    <!--- Check if note was found --->
    <cfif qGetNoteDetails.recordCount EQ 0>
        <cfset response.message = "Note not found">
    <cfelse>
        <!--- Success - populate response with note data --->
        <cfset response.success = true>
        <cfset response.notedetails = qGetNoteDetails.notedetails>
        <cfset response.notedetailshtml = qGetNoteDetails.notedetailshtml>
        
        <!--- Format timestamp if available --->
        <cfif isDate(qGetNoteDetails.notetimestamp)>
            <cfset response.timestamp = dateFormat(qGetNoteDetails.notetimestamp, "mmm d, yyyy") & " at " & timeFormat(qGetNoteDetails.notetimestamp, "h:mm tt")>
        </cfif>
    </cfif>

    <cfcatch type="any">
        <!--- Handle any errors --->
        <cfset response.message = "Database error occurred while fetching note details">
        <cflog file="share_notes_error" text="Error in get_note_details.cfm: #cfcatch.message# - #cfcatch.detail#">
    </cfcatch>
</cftry>

<!--- Output JSON response --->
<cfoutput>#serializeJSON(response)#</cfoutput>
