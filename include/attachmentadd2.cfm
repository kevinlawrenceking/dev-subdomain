<!--- This ColdFusion page handles file uploads and manages user media paths. --->

<cfset userid = userid />

<cfset currentURL = cgi.server_name />

<cfset host = ListFirst(currentURL, ".") />

<!--- Check if the base user media path directory exists, if not, create it --->
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

<!--- Upload the file to the attachments directory --->
<!--- Upload the file --->
<cffile action="upload" 
        filefield="form.file" 
        destination="#attachmentsPath#\" 
        nameconflict="MAKEUNIQUE" 
        result="uploadResult" />

<!--- Check if uploadResult variables exist --->
<cfif StructKeyExists(uploadResult, "FileWasSaved") AND uploadResult.FileWasSaved>
    <!--- Success message --->
    <cfoutput>
        File uploaded successfully!<br>
        File Name: #uploadResult.ServerFile#<br>
        File Path: #uploadResult.ServerDirectory#
    </cfoutput>
<cfelse>
    <!--- Failure message --->
    <cfoutput>
        File upload failed. Please try again.
    </cfoutput>
</cfif>

<cfset new_filename = uploadResult.serverfile />

<cfoutput>


    <!--- Set the attachment name if it is not already set --->
    <cfif #attachname# is "">
        <cfset attachname = "#new_filename#" />
    </cfif>
    
    <cfset attachfilename = "#new_filename#" />
</cfoutput>

<!--- Include the query for inserting the upload record --->
<cfinclude template="/include/qry/INSERT_22_1.cfm" />

<cfoutput>
    <!--- Construct the return URL with parameters --->
    <cfset returnurl = "/app/#returnurl#/?contactid=#rcontactid#&eventid=#reventid#&tab2_expand=true&t3=1" />
</cfoutput>

<!--- Redirect to the return URL --->
<cflocation url="#returnurl#" addtoken="no"  />
