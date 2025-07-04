<cfset systemUserService = createObject("component", "services.SystemUserService")>
<cfset sysActive = systemUserService.SELfusystemusers_24758(
    currentid = currentid,
    sessionUserId = userid,
    hideCompleted = hide_completed
)>