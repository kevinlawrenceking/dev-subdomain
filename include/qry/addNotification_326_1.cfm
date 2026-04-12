<cfinclude template="/include/perfcount.cfm" />
<cfset notificationService = request.svc("NotificationService")>


<cfset new_notid = notificationService.addNotification(
    actionID = addDaysNo.actionID,
    userid = userid,
    suID = NewSuid,
    notstartdate = newest_notstartdate
    )>
