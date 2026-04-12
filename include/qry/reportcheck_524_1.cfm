<cfinclude template="/include/perfcount.cfm" />
<cfset reportUserService = createObject("component", "services.ReportUserService")>
<cfset reportcheck = reportUserService.SELreports_user_24725(userid=userid)>