<cfset notificationService = request.svc("NotificationService")>

<cfset notifications = notificationService.delSystemNotifications(
    userID = userid
) />

