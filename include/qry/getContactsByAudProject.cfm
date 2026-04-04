<cfset contactService = request.svc("ContactService")>
<cfset audcontacts = contactService.getContactsByAudProject(audprojectid=audprojectid)>