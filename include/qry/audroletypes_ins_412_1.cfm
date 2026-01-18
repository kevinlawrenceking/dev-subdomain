<cfset auditionRoleTypeService = createObject("component", "services.AuditionRoleTypeService")>
<cfset new_audroletypeid = auditionRoleTypeService.INSaudroletypes(
    new_audroletype = new_audroletype,
    new_audCatid = new_audCatid,
    new_isDeleted = new_isDeleted
)>