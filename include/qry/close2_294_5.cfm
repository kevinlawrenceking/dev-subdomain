<cfinclude template="/include/perfcount.cfm" />
<cfset notificationService = request.svc("NotificationService")>
<cfset notificationService.deleteNotificationBySystem(suid=suid)>