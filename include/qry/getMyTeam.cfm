<cfset contactService = request.svc("ContactService")>
<cfset myteam = contactService.getMyTeam(userId=userid)>