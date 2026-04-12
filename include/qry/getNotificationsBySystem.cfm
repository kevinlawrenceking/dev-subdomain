<cfinclude template="/include/perfcount.cfm" />
<cfset notificationService = request.svc("NotificationService") />
<cfset notsNext = notificationService.getNotifications(suid=newsuid,maxrow=1) />
<cfset notsAfter = notsNext.recordcount />