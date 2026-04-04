<cfset ContactService = request.svc("ContactService")>

<cfset ContactService.addMembers(userid=userid, topsearch_myteam=topsearch_myteam) />
