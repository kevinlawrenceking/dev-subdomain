<cfinclude template="/include/perfcount.cfm" />
<cfset notificationService = request.svc("NotificationService")>
<cfset new_notid = notificationService.addNotification(
    actionID = NotificationDetails.actionID,
    userid = userid,
    suid = NewSuid,
    notstartdate = newest_notstartdate
)>
