<cfset notificationService = request.svc("NotificationService")>
<cfset notificationService.deleteNotificationBySystem(suid=suid)>