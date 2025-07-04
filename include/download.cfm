<!--- This ColdFusion page handles user media file downloads and ensures the media directory exists before downloading the file. --->

<cfset currentURL = cgi.server_name />
<cfset host = ListFirst(currentURL, ".") />

<!--- Include the query to fetch attachment details --->
<cfinclude template="/include/qry/attachdetails_25_1.cfm" />

<cfset rcontactid = attachdetails.contactid />

<!--- Base path for the user media directory --->
<cfif not DirectoryExists(session.userMediaPath)>
    <cfdirectory directory="#session.userMediaPath#" action="create">
</cfif>

<!--- Construct the path for rcontactid and check/create --->
<cfset rcontactPath = session.userMediaPath & "\" & rcontactid>
<cfif not DirectoryExists(rcontactPath)>
    <cfdirectory directory="#rcontactPath#" action="create">
</cfif>

<!--- Construct the path for attachments and check/create --->
<cfset attachmentsPath = rcontactPath & "\attachments">
<cfif not DirectoryExists(attachmentsPath)>
    <cfdirectory directory="#attachmentsPath#" action="create">
</cfif>

<!--- Construct the full file path --->
<cfset filePath = attachmentsPath & "\" & attachdetails.attachfilename>

<!--- Ensure the file exists before attempting to download --->
<cfif FileExists(filePath)>
    <!--- Read the file and serve it as a download --->
    <cfheader name="Content-Disposition" value="attachment; filename=#attachdetails.attachfilename#" />
    <cfcontent type="application/octet-stream" file="#filePath#" />
<cfelse>
    <cfoutput>
        The requested file does not exist: #filePath#
    </cfoutput>
</cfif>
