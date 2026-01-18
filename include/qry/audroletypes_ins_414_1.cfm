<cfset auditionRoleTypeService = createObject("component", "services.AuditionRoleTypeService")>
<cfset auditionRoleTypeService.UPDaudroletypes(
    new_audroletype = trim(new_audroletype),
    new_audCatid = new_audCatid,
    new_isDeleted = new_isDeleted,
    new_audroletypeid = new_audroletypeid
)>