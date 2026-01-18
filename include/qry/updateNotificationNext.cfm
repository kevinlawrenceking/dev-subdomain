<cfset notificationService = createObject("component", "services.NotificationService")>

<cfset notificationService.updateNotification(
    notstartdate = DateFormat(new_notstartdate, 'yyyy-mm-dd'),
    notid = notsnext.notid,
    notstatus = "Pending"
)>



