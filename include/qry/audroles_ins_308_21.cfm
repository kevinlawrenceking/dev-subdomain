<cfset auditionRoleService = createObject("component", "services.AuditionRoleService")>
<cfset new_audRoleID = auditionRoleService.INSaudroles_24372(
    new_audRoleName = new_audRoleName,
    new_audprojectID = new_audprojectID,
    new_charDescription = new_charDescription,
    new_audSourceID = new_audSourceID,
    userid = userid,
    new_isDeleted = new_isDeleted,
    isbooked = isbooked,
    isCallback = isCallback,
    ispin = ispin,
    isredirect = isredirect
)>