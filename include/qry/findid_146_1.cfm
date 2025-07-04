<cfset reportUserService = createObject("component", "services.ReportUserService")>
<cfset findid = reportUserService.SELreports_user(userID=userid, reportID=new_reportid)>