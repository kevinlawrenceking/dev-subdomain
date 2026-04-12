<cfinclude template="/include/perfcount.cfm" />
<cfset reportsMasterService = createObject("component", "services.ReportsMasterService")>
<cfset x = reportsMasterService.SELreports_master()>