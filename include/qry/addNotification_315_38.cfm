<cfinclude template="/include/perfcount.cfm" />
<cfset notificationService = request.svc("NotificationService")>
<cfset notificationService.INSfunotifications_24431(
    actionID = addDaysNo.actionID,
    userid = userid,
    NewSuid = NewSuid,
    notstartdate = notstartdate
)>