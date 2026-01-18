<cfset reportUserService = createObject("component", "services.ReportUserService")>
<cfset find = reportUserService.SELreports_user_24728(
    reportid = x.reportid,
    userid = u.userid,
    reportname = x.reportname
)>