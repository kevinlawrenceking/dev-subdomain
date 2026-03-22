<cfinclude template="/include/perfcount.cfm" />
<cfset systemUserService = createObject("component", "services.SystemUserService")>
<cfset rels = systemUserService.getRemindersByRelationship(
    currentid = currentid,
    sessionUserId = userid
)>