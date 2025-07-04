<cfset userid = userid />
<cfset currentURL = cgi.server_name />
<cfset host = ListFirst(currentURL, ".") />
<cfinclude template="/include/qry/attachdetails_109_1.cfm" />

<cfif structKeyExists(attachdetails, "mediafilename") and len(attachdetails.mediafilename)>
    <cfhttp url="https://#host#.theactorsoffice.com/#session.userMediaUrl#/#attachdetails.mediafilename#" getAsBinary="yes" throwOnError="yes"/>
    <cfheader name="Content-Disposition" value="attachment; filename=#attachdetails.mediafilename#" />
    <cfcontent type="application/octet-stream" variable="#cfhttp.fileContent#">
<cfelse>
    <cfoutput>No media found for download.</cfoutput>
</cfif>
