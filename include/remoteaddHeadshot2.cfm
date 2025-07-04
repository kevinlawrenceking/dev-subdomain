<!--- This ColdFusion page handles user file uploads and manages media storage for user accounts. --->

<cfset userid = userid />

<cfset currentURL = cgi.server_name />

<cfset host = ListFirst(currentURL, ".") />

<cfset NEW_ISSHARE = TRUE />

<!--- Check if the user media path directory exists, if not, create it. --->
<cfif not DirectoryExists("#session.userMediaPath#")>
    <CFDIRECTORY directory="#session.userMediaPath#" action="create">
</cfif>

<!--- Upload the file to the user's media path. --->
<cffile action="upload" 
        filefield="form.file" 
        destination="#session.userMediaPath#\" 
        nameconflict="MAKEUNIQUE" />

<cfset new_userid = userid />

<cfset new_filename = CFFILE.serverfile />

<cfoutput>
    <!--- Set the media name if it is not already defined. --->
    <cfif #new_medianame# is "">
        <cfset new_medianame = "#new_filename#" />
    </cfif>
    
    <cfset new_mediaFilename = "#new_filename#" />
</cfoutput>

<cfset new_mediaext = listLast(new_mediaFilename, ".") />

<!--- Include the media insertion query script. --->
<cfinclude template="/include/qry/audmedia_ins.cfm" />

<cfset new_uploadid = new_mediaID />

<!--- Redirect to the account page with the new upload ID. --->
<cflocation url="/app/myaccount/?t8=1&tab8_expand=true&new_uploadid=<cfoutput>#new_uploadid#</cfoutput>" /> 
