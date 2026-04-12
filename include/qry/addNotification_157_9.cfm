<cfinclude template="/include/perfcount.cfm" />
<cfset notificationService = request.svc("NotificationService")>
<cfset notificationService.INSfunotifications_23940(
    new_actionid = new_actionid,
    new_userid = new_userid,
    NewSuid = NewSuid,
    notstartdate = notstartdate,
    sunotes = sunotes
)>