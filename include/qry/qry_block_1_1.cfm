<cfinclude template="/include/perfcount.cfm" />
<cfset actionUserService = createObject("component", "services.ActionUserService")>
<cfset actions = actionUserService.GetUserActions(userid=userid)>