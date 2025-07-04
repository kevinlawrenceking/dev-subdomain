<cfset auditionProjectService = createObject("component", "services.AuditionProjectService")>
<cfset new_audprojectID = auditionProjectService.INSaudprojects(
    new_projName = new_projName,
    new_projDescription = new_projDescription,
    new_audSubCatID = new_audSubCatID,
    new_isDeleted = new_isDeleted,
    isdirect = isdirect,
    new_contactid = new_contactid,
    new_projdate = new_projdate
)>