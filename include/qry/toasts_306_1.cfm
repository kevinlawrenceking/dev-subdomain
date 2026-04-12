<cfinclude template="/include/perfcount.cfm" />
<cfset notificationService = request.svc("NotificationService")>
<cfset toasts = notificationService.SELnotifications(userID=userid)>