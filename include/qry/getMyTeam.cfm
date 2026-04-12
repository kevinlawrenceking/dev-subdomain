<cfinclude template="/include/perfcount.cfm" />
<cfset contactService = request.svc("ContactService")>
<cfset myteam = contactService.getMyTeam(userId=userid)>