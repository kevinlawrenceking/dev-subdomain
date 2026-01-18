<cfset actionUserService = createObject("component", "services.ActionUserService")>
<cfset insertedCount = actionUserService.updateActionUsers(userid=userid, target_id_system=target_id_system)>


<cfoutput>
target_id_system: #target_id_system#<BR>
userid: #userid#<BR>
    Number of actions inserted: #insertedCount#
</cfoutput>
