<cfset objService = createObject("component", "services.AuditionVocalTypeXRefService")>
<cfset objService.UPDaudvocaltypes_audition_xref(
    new_audRoleID = new_audRoleID,
    new_vocaltypeid = new_vocaltypeid,
    new_id = new_id
)>
