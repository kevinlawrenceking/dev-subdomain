<cfinclude template="/include/perfcount.cfm" />
<cfset notificationService = request.svc("NotificationService")>

<cfset notifications = notificationService.delSystemNotifications(
    userID = userid
) />

