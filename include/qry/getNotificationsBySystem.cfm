<cfset notificationService = createObject("component", "services.NotificationService") />
<cfset notsNext = notificationService.getNotifications(suid=newsuid,maxrow=1) />
<cfset notsAfter = notsNext.recordcount />