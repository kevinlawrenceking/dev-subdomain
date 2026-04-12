<cfinclude template="/include/perfcount.cfm" />
<cfset objNotificationService = request.svc("NotificationService")>
<cfset objNotificationService.INSnotifications_23830(
    new_contactname = new_contactname, 
    contactid = contactid
)>