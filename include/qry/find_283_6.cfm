<cfinclude template="/include/perfcount.cfm" />
<cfset actionUserService = createObject("component", "services.ActionUserService")>
<cfset find = actionUserService.GetActionUsers(actionid=xs.actionid, userid=u.userid)>