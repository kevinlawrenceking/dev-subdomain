<cfset actionUserService = createObject("component", "services.ActionUserService")>
<cfset find = actionUserService.G(actionid=xs.actionid, userid=u.userid)>