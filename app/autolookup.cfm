<cfset userid = url.userid>
<cfset searchTerm = url.searchTerm>

<cfset lookupService = createObject("component", "services.LookupService")>
<cfset tagData = lookupService.getTags(userid=userid, searchTerm=searchTerm)>
<cfset contactData = lookupService.getContacts(userid=userid, searchTerm=searchTerm)>
<cfset appointmentData = lookupService.getAppointments(userid=userid, searchTerm=searchTerm)>


<!--- Create suggestions array --->
<cfset suggestions = [] />

<!--- Loop through tagData --->
<cfloop query="tagData">
    <cfset arrayAppend(suggestions, {
        "value": tagData.col1,
        "id": tagData.id,
        "data": {
            "category": "Tags"
        }
    })>
</cfloop>

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

<!--- Loop through appointmentData --->
<cfloop query="appointmentData">
    <cfset arrayAppend(suggestions, {
        "value": appointmentData.col1,
        "id": appointmentData.id,
        "data": {
            "category": "Appointments"
        }
    })>
</cfloop>

<!--- Return JSON response --->
<cfcontent type="application/json">
<cfoutput>#serializeJSON({"suggestions": suggestions})#</cfoutput>
