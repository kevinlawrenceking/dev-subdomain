<cfinclude template="/include/perfcount.cfm" />
<cfset suidList = []> <!--- Assuming you have a list of suids to exclude, otherwise keep it empty --->
<cfset notificationService = request.svc("NotificationService")>
<cfset notificationService.UPDfunotifications_24650(suidList=suidList)>