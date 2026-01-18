<cfset notificationService = createObject("component", "services.NotificationService")>
<cfset notificationService.UPDnotifications(notificationId=numberformat(dn))>