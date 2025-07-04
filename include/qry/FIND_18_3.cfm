<cfset contactService = createObject("component", "services.ContactService")>

<cfset find = structNew()>
<cfset find.recordcount = contactService.getContactCount(userid=userid, relationship=relationship)>
