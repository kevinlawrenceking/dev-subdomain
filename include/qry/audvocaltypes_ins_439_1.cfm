<cfset vocalTypeService = createObject("component", "services.AuditionVocalTypeService")>
<cfset vocalTypeService.UPDaudvocaltypes(
    new_vocaltype = new_vocaltype,
    new_isDeleted = new_isDeleted,
    new_vocaltypeid = new_vocaltypeid
)>