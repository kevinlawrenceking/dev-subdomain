<cfset notificationService = request.svc("NotificationService")>
<cfset toasts = notificationService.SELnotifications(userID=userid)>