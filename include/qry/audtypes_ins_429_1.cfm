<cfset auditionTypeService = createObject("component", "services.AuditionTypeService")>
<cfset new_audtypeid - auditionTypeService.INSaudtypes(
    new_audtype=new_audtype,
    new_audCatid=new_audCatid,
    new_isDeleted=new_isDeleted
)>