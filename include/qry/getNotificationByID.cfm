<cfset notificationService = createObject("component", "services.NotificationService")>
<cfset NotificationDetails = notificationService.GetNotificationByID(notid=notid)>