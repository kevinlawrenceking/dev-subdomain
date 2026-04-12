<cfinclude template="/include/perfcount.cfm" />
<cfset objNotificationService = request.svc("NotificationService")>
<cfset objNotificationService.INSfunotifications(
    actionID = addDaysNo.actionID,
    userid = userid,
    suID = NewSuid,
    notstartdate = notstartdate
)>