<cfinclude template="/include/perfcount.cfm" />
<cfset auditionProjectService = request.svc("AuditionProjectService")>
<cfset report_18 = auditionProjectService.SELaudprojects_24248(
    new_audsourceid=new_audsourceid, 
    userid=userid, 
    rangeselected=rangeselected
)>