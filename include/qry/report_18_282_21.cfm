<cfset auditionProjectService = createObject("component", "services.AuditionProjectService")>
<cfset report_18 = auditionProjectService.SELaudprojects_24248(
    new_audsourceid=new_audsourceid, 
    userid=userid, 
    rangeselected=rangeselected
)>