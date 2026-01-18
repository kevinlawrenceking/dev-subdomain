<cfset notificationService = createObject("component", "services.NotificationService")>
<cfset notificationService.updateNotification(
    notStatus = notStatus,
    notEndDate = notEndDate,
    notId = notid
)>