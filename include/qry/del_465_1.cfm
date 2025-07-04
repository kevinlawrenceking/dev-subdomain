<cfset suidList = []> <!--- Assuming you have a list of suids to exclude, otherwise keep it empty --->
<cfset notificationService = createObject("component", "services.NotificationService")>
<cfset notificationService.UPDfunotifications_24650(suidList=suidList)>