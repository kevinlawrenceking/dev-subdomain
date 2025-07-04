<cfset notificationService = createObject("component", "services.NotificationService")>
<cfset new_notid = notificationService.addNotification(
    actionID = NotificationDetails.actionID,
    userid = userid,
    suid = NewSuid,
    notstartdate = newest_notstartdate
)>
