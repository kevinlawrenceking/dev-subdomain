<!--- This ColdFusion page handles file deletion based on user input and redirects accordingly. --->

<cfset userid = userid />

<cfparam name="rcontactid" default="0" />

<cfset currentURL = cgi.server_name />
<cfset host = ListFirst(currentURL, ".") />

<cfinclude template="/include/qry/attachdetails_25_1.cfm" />

<cfoutput>
    session.userMediaPath
    <cfset attachfilename = "#attachdetails.attachfilename#" />
</cfoutput>

<!--- Check if the file exists before attempting to delete it. --->
<cfif FileExists("#session.userMediaPath#\#attachfilename#")>
    <cffile action="delete" file="#session.userMediaPath#\#attachfilename#">
    
    <cfinclude template="/include/qry/del_25_2.cfm" />
<cfelse>
    <p>Sorry, can't delete the file - it doesn't exist.<cfabort>
</cfif>

<cfoutput>
    <cfset returnurl = "/app/audition/?audprojectid=#audprojectid#&secid=178" />
</cfoutput>

<!--- Redirect to the specified return URL after processing. --->
<cflocation url="#returnurl#">

