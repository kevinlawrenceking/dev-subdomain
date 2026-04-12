<cfinclude template="/include/perfcount.cfm" />
<cfset notificationsService = createObject("component", "services.NotificationsService")>
<cfset newNotificationID = notificationsService.addNotifications(
    subtitle = subtitle,
    userid = userid,
    notifUrl = "notiURL",
    notifTitle = "Maintenance System Created!",
    notifType = "System Added",
    contactid = contactid,
    isRead = 0
)>
