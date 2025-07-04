<cfset notificationService = createObject("component", "services.NotificationService")>


<cfset new_notid = notificationService.addNotification(
    actionID = addDaysNo.actionID,
    userid = userid,
    suID = NewSuid,
    notstartdate = newest_notstartdate
    )>
