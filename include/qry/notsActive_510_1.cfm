<cfset notificationService = createObject("component", "services.NotificationService")>
<!--- <cfset notsActive = notificationService.SELfunotifications_24706(
    currentid = currentid,
    sysActiveSuid = sysActive.suid,
    userid = userid,
    hide_Completed = hide_completed
)> --->

<cfset notsActive = notificationService.SELfunotifications(
    currentid = currentid,
    sysActiveSuid = sysActive.suid,
    userid = userid
)>