<cfset contactService = request.svc("ContactService")>

<cfset find = structNew()>
<cfset find.recordcount = contactService.getContactCount(userid=userid, relationship=relationship)>
