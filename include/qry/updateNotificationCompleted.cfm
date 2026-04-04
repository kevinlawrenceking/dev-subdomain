<cfset notificationService = request.svc("NotificationService")>
<cfset notificationService.updateNotification(
    notStatus = notStatus,
    notEndDate = notEndDate,
    notId = notid
)>