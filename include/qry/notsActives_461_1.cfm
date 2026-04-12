<cfinclude template="/include/perfcount.cfm" />
<cfset notificationService = request.svc("NotificationService")>
<cfset notsActives = notificationService.SELfunotifications_24639(userid=userid)>