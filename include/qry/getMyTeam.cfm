<cfset contactService = createObject("component", "services.ContactService")>
<cfset myteam = contactService.getMyTeam(userId=userid)>