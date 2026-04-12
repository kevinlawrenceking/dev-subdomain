<cfinclude template="/include/perfcount.cfm" />
<Cfoutput>new_contactid</cfoutput>

<cfset contactService = request.svc("ContactService")>
<cfset checkUnique = contactService.SELcontactdetails(
    addDaysNoUniqueName = adddaysno.uniquename,
    newContactId = new_contactid
)>