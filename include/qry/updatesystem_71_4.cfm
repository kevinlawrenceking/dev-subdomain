<cfinclude template="/include/perfcount.cfm" />
<cfset notificationService = request.svc("NotificationService")>
<cfset notificationService.UPDfunotifications_23818(
    new_notstartdate = new_notstartdate, 
    notid = notsnext.notid
)>
UPDfunotifications_23818