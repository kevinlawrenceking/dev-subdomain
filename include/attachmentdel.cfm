<!--- This ColdFusion page handles file deletion and redirects the user accordingly. --->

<cfset userid = userid />
<cfparam name="reventid" default="0"/>
<cfparam name="rcontactid" default="0"/>
<cfparam name="eventid" default="0"/>

<cfset currentURL = cgi.server_name />
<cfset host = ListFirst(currentURL, ".") />

<cfinclude template="/include/qry/attachdetails_25_1.cfm" />

<cfoutput>
    <cfset attachfilename = "#attachdetails.attachfilename#" />
</cfoutput>

<!--- Check if the file exists before attempting to delete it. --->
<cfif FileExists("#session.userMediaPath#\#attachfilename#")>
    <cffile action="delete" 
            file="#session.userMediaPath#\#attachfilename#">
    
    <cfinclude template="/include/qry/del_25_2.cfm" />
<cfelse>
    <p>Sorry, can't delete the file - it doesn't exist.<cfabort>
</cfif>

<cfoutput>
    <!--- Set the return URL for redirection after deletion. --->
    <cfset returnurl = "/app/#returnurl#/?contactid=#contactid#&eventid=#eventid#&tab2_expand=true&t3=1" />
</cfoutput>

<!--- Redirect the user to the return URL. --->
<cflocation url="#returnurl#" />
