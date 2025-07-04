<cfset auditionRoleService = createObject("component", "services.AuditionRoleService")>
<cfset new_audRoleID = auditionRoleService.INSaudroles(
    new_audRoleName = new_audRoleName,
    new_audprojectID = new_audprojectID,
    new_audRoleTypeID = new_audRoleTypeID,
    new_charDescription = new_charDescription,
    new_holdStartDate = new_holdStartDate,
    new_holdEndDate = new_holdEndDate,
    new_audDialectID = new_audDialectID,
    new_audSourceID = new_audSourceID,
    new_userid = new_userid,
    new_isDeleted = new_isDeleted,
    isdirect = isdirect
)>