<cfset contactService = createObject("component", "services.ContactService")>
<cfset audcontacts = contactService.getContactsByAudProject(audprojectid=audprojectid)>