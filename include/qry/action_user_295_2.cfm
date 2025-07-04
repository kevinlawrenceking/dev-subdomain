<cfset systemService = createObject("component", "services.SystemService")>

<cfset action_user = systemService.SELfusystems_24321(
    systemID = mysystems.systemid,
    userID = userid
) />