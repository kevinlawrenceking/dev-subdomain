<cfset notificationService = request.svc("NotificationService")>
<cfset notificationService.UPDnotifications(notificationId=numberformat(dn))>