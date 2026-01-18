<cfset actionUserService = createObject("component", "services.ActionUserService")>
<cfset insertedCount = actionUserService.restoreActionUsers(userid=userid, target_id_system=target_id_system)>
 