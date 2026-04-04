<cfinclude template="/include/perfcount.cfm" />
<cfset systemUserService = request.svc("SystemUserService")>
<cfset rels = systemUserService.getRemindersByRelationship(
    currentid = currentid,
    sessionUserId = userid
)>