<cfinclude template="/include/perfcount.cfm" />
<cfset notificationService = request.svc("NotificationService")>
<cfset notsActives = notificationService.SELfunotifications_24641(userid=userid)>