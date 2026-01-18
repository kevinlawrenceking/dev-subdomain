<cfset objNotificationService = createObject("component", "services.NotificationService")>
<cfset objNotificationService.INSfunotifications(
    actionID = addDaysNo.actionID,
    userid = userid,
    suID = NewSuid,
    notstartdate = notstartdate
)>