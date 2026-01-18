<cfset auditionTypeService = createObject("component", "services.AuditionTypeService")>
<cfset auditionTypeService.UPDaudtypes(
    new_audtype = trim(new_audtype),
    new_audCatid = new_audCatid,
    new_isDeleted = new_isDeleted,
    new_audtypeid = new_audtypeid
)>