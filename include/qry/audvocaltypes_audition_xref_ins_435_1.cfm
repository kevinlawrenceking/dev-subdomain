<cfset componentPath = "/services/AuditionVocalTypeXRefService">
<cfset auditionService = createObject("component", componentPath)>
<cfset new_ = auditionService.INSaudvocaltypes_audition_xref_24613(
    new_audRoleID = new_audRoleID,
    new_vocaltypeid = new_vocaltypeid
)>