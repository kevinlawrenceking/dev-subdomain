<cfset notificationStatusService = createObject("component", "services.NotificationStatusService")>
<cfset notsInactive = notificationStatusService.SELnotstatuses(
    currentid = currentid,
    sysActiveSuid = sysActive.suid,
    userid = userid
)>

