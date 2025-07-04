<cfset userid = url.userid>
<cfset searchTerm = url.searchTerm>

<cfset lookupService = createObject("component", "services.LookupService")>
<cfset contactData = lookupService.getContacts(userid=userid, searchTerm=searchTerm)>
<cfset contactData = lookupService.getContactsNotTeam(userid=userid, searchTerm=searchTerm)>


<!--- Create suggestions array --->
<cfset suggestions = [] />



<!--- Loop through contactData --->
<cfloop query="contactData">
    <cfset arrayAppend(suggestions, {
        "value": contactData.col1,
        "id": contactData.id,
        "data": {
            "category": "Contacts"
        }
    })>
</cfloop>

<!--- Return JSON response --->
<cfcontent type="application/json">
<cfoutput>#serializeJSON({"suggestions": suggestions})#</cfoutput>
