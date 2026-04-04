<cfset notificationService = request.svc("NotificationService")>
<cfset notificationService.INSfunotifications_23817(
    actionID = NotificationDetails.actionID,
    userid = userid,
    NewSuid = NewSuid,
    newest_notstartdate = newest_notstartdate
)>
