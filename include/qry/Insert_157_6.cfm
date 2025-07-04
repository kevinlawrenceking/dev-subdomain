<cfset notificationService = createObject("component", "services.NotificationService")>
<cfset Newnotification = notificationService.INSnotifications_23937(
    new_contactname = new_contactname,
    new_userid = new_userid,
    new_contactid = new_contactid,
    sunotes = sunotes
)>