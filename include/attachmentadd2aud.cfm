<!--- This ColdFusion page handles user file uploads and manages user media paths. --->

<!--- Safely setup form and URL parameters with cfparam --->
<cfparam name="form.file" default="" />
<cfparam name="form.attachname" default="" />
<cfparam name="form.returnurl" default="audition" />
<cfparam name="form.noteid" default="0" />
<cfparam name="form.audprojectid" default="0" />
<cfparam name="form.rcontactid" default="0" />

<!--- Set local variables from form scope --->
<cfset attachname = form.attachname />
<cfset returnurl = form.returnurl />
<cfset noteid = form.noteid />
<cfset audprojectid = form.audprojectid />
<cfset rcontactid = form.rcontactid />

<cfinclude template="/include/qry/fetchusers.cfm" />

<cfset currentURL = cgi.server_name />
<cfset host = ListFirst(currentURL, ".") />

<!--- Check if the user media directory exists, if not, create it --->
<cfif not DirectoryExists(session.userMediaPath)>
    <cfdirectory directory="#session.userMediaPath#" action="create">
</cfif>

<!--- Handle file upload --->
<cffile action="upload" 
        filefield="form.file" 
        destination="#session.userMediaPath#\" 
        nameconflict="MAKEUNIQUE" />

<cfset new_filename = CFFILE.serverfile />

<!--- Set the attachment name if not already set --->
<cfif len(trim(attachname)) EQ 0>
    <cfset attachname = new_filename />
</cfif>

<cfset attachfilename = new_filename />

<!--- Include the insert query template --->
<cfinclude template="/include/qry/INSERT_22_1.cfm" />

<!--- Set the return URL for redirection after upload --->
<cfset returnurl = "/app/audition/?audprojectid=#audprojectid#&secid=178" />

<!--- Redirect to the return URL --->
<cflocation url="#returnurl#" />

