<cfset userId = session.userid>
<cfset searchTerm = cgi.searchTerm>
<cfset lookupService = createObject("component", "services.LookupService")>
<cfset contactResults = lookupService.getContacts(userId=userId, searchTerm=searchTerm)>
<cfcontent type="application/json">
<cfoutput>#serializeJSON(contactResults)#</cfoutput>