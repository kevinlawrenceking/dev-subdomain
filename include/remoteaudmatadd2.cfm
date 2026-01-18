<!--- This ColdFusion page handles user media uploads and manages the storage of uploaded files. --->

<cfset userid = userid />

<cfset currentURL = cgi.server_name />
<cfset host = ListFirst(currentURL, ".") />

<!--- Check if the user media directory exists, if not, create it --->
<cfif not DirectoryExists("#session.userMediaPath#")>
    <CFDIRECTORY directory="#session.userMediaPath#" action="create">
</cfif>

<!--- Upload the file to the user's media path --->
<cffile action="upload" 
        filefield="form.file" 
        destination="#session.userMediaPath#\" 
        nameconflict="MAKEUNIQUE" />

<cfset new_userid = userid />
<cfset new_filename = CFFILE.serverfile />

<cfoutput>
    <!--- Set the media name if it is not already set --->
    <cfif #new_medianame# is "">
        <cfset new_medianame = "#new_filename#" />
    </cfif>
    <cfset new_mediaFilename = "#new_filename#" />
</cfoutput>

<cfset new_mediaext = listLast(new_mediaFilename, ".") />

<!--- Include the media insertion query --->
<cfinclude template="/include/qry/audmedia_ins.cfm" />

<cfset new_uploadid = new_mediaID />

<cfoutput>
    <!--- Set the return URL after upload --->
    <cfset returnurl = "/app/audition/?audprojectid=#audprojectid#&secid=177" />
</cfoutput>

<!--- Redirect to the return URL --->
<cflocation url="#returnurl#">
