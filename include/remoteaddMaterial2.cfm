<!--- This ColdFusion page handles user media uploads and manages the media path for the session. --->

<cfoutput>
    <cfset session.userMediaPath = "#session.userMediaPath#"/>
</cfoutput>

<!--- Check if the user media directory exists, if not, create it --->
<cfif not DirectoryExists("#session.userMediaPath#")>
    <cfdirectory directory="#session.userMediaPath#" action="create">
</cfif>

<!--- Check if a file has been uploaded --->
<cfif structKeyExists(form, "file") AND len(trim(form.file)) NEQ 0>
    <cffile action="upload" 
            filefield="form.file" 
            destination="#session.userMediaPath#\" 
            nameconflict="MAKEUNIQUE"/>
    
    <cfset new_filename = CFFILE.serverfile/>

    <cfoutput>
        <!--- Set new media name if it's not already set --->
        <cfif #new_medianame# is "">
            <cfset new_medianame = "#new_filename#"/>
        </cfif>
        <cfset new_mediaFilename = "#new_filename#"/>
    </cfoutput>

    <cfset new_mediaext = listLast(new_mediaFilename, ".")>
<cfelse>
    <cfset new_mediaext = "" />
    <cfset new_filename = "" />
</cfif>

<!--- Include the media insertion query template --->
<cfinclude template="/include/qry/audmedia_ins.cfm"/>
<cfset new_uploadid = new_mediaID>

<!--- Redirect based on the source of the upload --->
<cfif #src# is "account">
    <cflocation url="/app/myaccount/?t9=1&tab9_expand=true&new_uploadid=<cfoutput>#new_uploadid#</cfoutput>"/>
<cfelse>
    <cflocation url="/app/audition/?audprojectid=#audprojectid#&secid=177"/>
</cfif>
