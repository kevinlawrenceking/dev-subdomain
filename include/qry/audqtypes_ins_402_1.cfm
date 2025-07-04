<cfset service = createObject("component", "services.AuditionQuestionTypeService")>
<cfset new_qtypeid = service.INSaudqtypes(new_qtype=new_qtype, new_isDeleted=new_isDeleted)>