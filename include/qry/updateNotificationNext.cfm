<cfinclude template="/include/perfcount.cfm" />
<cfset notificationService = request.svc("NotificationService")>

<cfset notificationService.updateNotification(
    notstartdate = DateFormat(new_notstartdate, 'yyyy-mm-dd'),
    notid = notsnext.notid,
    notstatus = "Pending"
)>



