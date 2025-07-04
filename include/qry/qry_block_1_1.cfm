<cfset actionUserService = createObject("component", "services.ActionUserService")>
<cfset actions = actionUserService.GetUserActions(userid=userid)>