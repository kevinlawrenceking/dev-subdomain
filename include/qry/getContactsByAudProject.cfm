<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>
<cfset audcontacts = contactService.getContactsByAudProject(audprojectid=audprojectid)>