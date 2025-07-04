<cfset auditionService = createObject("component", "services.AuditionAgeRangeXRefService")>
<cfset auditionService.UPDaudageranges_audtion_xref(
    new_audRoleID=new_audRoleID, 
    new_rangeid=new_rangeid, 
    new_id=new_id
)>