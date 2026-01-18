<cfset reportUserService = createObject("component", "services.ReportUserService")>
<cfset stats = reportUserService.SELreports_user_24734(
    userID = userid,
    reportTypeID = 4
)>