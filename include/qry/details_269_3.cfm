<cfset contactService = createObject("component", "services.ContactService")>
<cfset details = contactService.DETcontactdetails(contactid=contactid)>