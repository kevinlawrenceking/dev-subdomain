<cfinclude template="/include/perfcount.cfm" />
<cfset actionUserService = createObject("component", "services.ActionUserService")>
<cfset actionUserService.updateActionUsers(id=new_id)>