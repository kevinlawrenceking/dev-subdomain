<cfset notificationService = createObject("component", "services.NotificationService")>
<cfset notificationService.INSnotifications(
    new_contactname = new_contactname, 
    userid = userid, 
    contactid = contactid
)>