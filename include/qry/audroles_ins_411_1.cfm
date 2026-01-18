<cfset componentPath = "/services/AuditionRoleService">
<cfset auditionRoleService = createObject("component", componentPath)>
<cfset auditionRoleService.UPDaudroles_24594(
    new_audRoleName = trim(new_audRoleName),
    new_audprojectID = new_audprojectID,
    new_audRoleTypeID = new_audRoleTypeID,
    new_charDescription = trim(new_charDescription),
    new_holdStartDate = new_holdStartDate,
    new_holdEndDate = new_holdEndDate,
    new_audDialectID = new_audDialectID,
    new_audSourceID = new_audSourceID,
    new_userid = new_userid,
    new_isDeleted = new_isDeleted,
    new_audRoleID = new_audRoleID
)>
