<!--- This ColdFusion page handles user file uploads and manages user media paths. --->

<cfinclude template="/include/qry/fetchusers.cfm" />

<cfset currentURL = cgi.server_name />
<cfset host = ListFirst(currentURL, ".") />

<cfoutput>
    session.userMediaPath
</cfoutput>

<!--- Check if the user media directory exists, if not, create it --->
<CFIF not DirectoryExists("#session.userMediaPath#")>
    <CFDIRECTORY directory="#session.userMediaPath#" action="create">
</CFIF>

<!--- Handle file upload --->
<cffile action="upload" 
        filefield="form.file" 
        destination="#session.userMediaPath#\" 
        nameconflict="MAKEUNIQUE" />

<cfset new_filename = CFFILE.serverfile />

<cfoutput>
    <!--- Set the attachment name if not already set --->
    <cfif #attachname# is "">
        <cfset attachname = "#new_filename#" />
    </cfif>
    
    <cfset attachfilename = "#new_filename#" />
</cfoutput>

<!--- Include the insert query template --->
<cfinclude template="/include/qry/INSERT_22_1.cfm" />

<cfoutput>
    <!--- Set the return URL for redirection after upload --->
    <cfset returnurl = "/app/audition/?audprojectid=#audprojectid#&secid=178" />
</cfoutput>

<!--- Redirect to the return URL --->
<cflocation url="#returnurl#" />

