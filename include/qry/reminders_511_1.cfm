<cfinclude template="/include/perfcount.cfm" />
<cfset reminders_total = 0>
<cfset notificationService = request.svc("NotificationService")>
<cfset reminders_total = notificationService.getRemindersTotal(userid)>