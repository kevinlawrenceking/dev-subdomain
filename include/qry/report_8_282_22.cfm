<cfset auditionMediaService = createObject("component", "services.AuditionMediaService")>
<cfset report_8 = auditionMediaService.SELaudmedia_24249(
    userid = userid,
    new_audcatid = new_audcatid,
    rangestart = rangeselected.rangestart,
    rangeend = rangeselected.rangeend
)>