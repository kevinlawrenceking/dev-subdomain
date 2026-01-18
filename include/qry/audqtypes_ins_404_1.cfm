<cfset auditionQuestionTypeService = createObject("component", "services.AuditionQuestionTypeService")>
<cfset auditionQuestionTypeService.UPDaudqtypes(
    new_qtype = new_qtype,
    new_isDeleted = new_isDeleted,
    new_qtypeid = new_qtypeid
)>