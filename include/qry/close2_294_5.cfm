<cfset notificationService = createObject("component", "services.NotificationService")>
<cfset notificationService.deleteNotificationBySystem(suid=suid)>