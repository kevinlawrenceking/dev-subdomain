<cfinclude template="/include/perfcount.cfm" />
<cfset notificationService = request.svc("NotificationService")>
<cfset notsActive = notificationService.SELfunotifications_24706(
    currentid = currentid,
    sysActiveSuid = sysActive.suid,
    userid = userid,
    hide_Completed = hide_completed
)>