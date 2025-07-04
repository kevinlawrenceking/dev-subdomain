<cfparam name="deleteaction" default="0" /> 
<cfset ActionUserService = createObject("component", "services.ActionUserService")>

<cfset ActionUserService.updateActionUsers(
    id = new_id,
    actionDaysNo = actionDaysNo,
    isDeleted = deleteaction,
    actionDaysRecurring = actionDaysRecurring,
    systemid = 0
)>