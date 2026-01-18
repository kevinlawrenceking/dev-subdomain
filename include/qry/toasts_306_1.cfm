<cfset notificationService = createObject("component", "services.NotificationService")>
<cfset toasts = notificationService.SELnotifications(userID=userid)>