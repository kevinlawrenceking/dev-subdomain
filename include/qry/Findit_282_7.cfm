<cfset auditionTypeService = createObject("component", "services.AuditionTypeService")>
<cfset Findit = auditionTypeService.SELaudtypes_24234(
    audstepid = report_4_loop.audstepid,
    new_audtypeid = report_4_loop.new_audtypeid,
    rangestart = rangeselected.rangestart,
    rangeend = rangeselected.rangeend,
    userid = userid
)>