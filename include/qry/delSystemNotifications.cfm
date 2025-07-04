<cfset notificationService = createObject("component", "services.NotificationService")>

<cfset notifications = notificationService.delSystemNotifications(
    userID = userid
) />

