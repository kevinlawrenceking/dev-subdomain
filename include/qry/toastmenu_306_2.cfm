<cfinclude template="/include/perfcount.cfm" />
<cfset notificationService = request.svc("NotificationService")>
<cfset toastmenu = notificationService.SELnotifications_24351(userID=userid)>