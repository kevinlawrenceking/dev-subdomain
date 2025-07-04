<cfset reportUserService = createObject("component", "services.ReportUserService")>
<cfset reportUserService.INSreports_user(
    reportid = x.reportid,
    reportname = x.reportname,
    reportorderno = x.reportorderno,
    reporttypeid = x.reporttypeid,
    reportdescription = x.reportdescription,
    userid = u.userid,
    colmd = x.colmd,
    colxl = colxl,
    datalabel = x.datalabel,
    colorid = x.colorid
)>