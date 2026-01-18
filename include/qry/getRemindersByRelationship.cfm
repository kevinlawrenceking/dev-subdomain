<cfset systemUserService = createObject("component", "services.SystemUserService")>
<cfset rels = systemUserService.getRemindersByRelationship(
    currentid = currentid,
    sessionUserId = userid
)>