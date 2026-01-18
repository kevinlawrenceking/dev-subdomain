<cfset notificationService = createObject("component", "services.NotificationService")>
<cfset checkUnique = notificationService.SELfunotifications_24429(
    maint_contactid = maint_contactid,
    actionTitle = addDaysNo.actionTitle,
    isUnique = adddaysNo.IsUnique
)>