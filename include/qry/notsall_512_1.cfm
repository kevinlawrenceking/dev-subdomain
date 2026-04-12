<cfinclude template="/include/perfcount.cfm" />
<cfset notificationService = request.svc("NotificationService")>
<cfset notsall = notificationService.SELfunotifications_24711(currentid=currentid)>