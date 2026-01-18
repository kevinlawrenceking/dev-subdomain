<cfset systemService = createObject("component", "services.SystemService")>

<cfset action_user_del = systemService.SELfusystems_24322(
    systemID = mysystems.systemid,
    userID = userid
) />