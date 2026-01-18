<cfset contactService = createObject("component", "services.ContactService")>
<cfset details = contactService.DETcontactdetails(contactid=FOLLOWUP_CONTACTID)>