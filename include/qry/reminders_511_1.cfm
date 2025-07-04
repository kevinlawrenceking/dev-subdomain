<cfset reminders_total = 0>
<cfset notificationService = createObject("component", "services.NotificationService")>
<cfset reminders_total = notificationService.getRemindersTotal(userid)>