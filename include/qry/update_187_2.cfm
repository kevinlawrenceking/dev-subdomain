<cfinclude template="/include/perfcount.cfm" />
<cfset notificationService = request.svc("NotificationService")>
<cfset notificationService.UPDnotifications_24009(userid=userid)>