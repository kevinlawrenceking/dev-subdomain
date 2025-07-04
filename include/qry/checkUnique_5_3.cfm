<Cfoutput>new_contactid</cfoutput>

<cfset contactService = createObject("component", "services.ContactService")>
<cfset checkUnique = contactService.SELcontactdetails(
    addDaysNoUniqueName = adddaysno.uniquename,
    newContactId = new_contactid
)>