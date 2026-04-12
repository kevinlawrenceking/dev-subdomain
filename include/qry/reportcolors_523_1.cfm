<cfinclude template="/include/perfcount.cfm" />
<cfset reportColorService = createObject("component", "services.ReportColorService")>
<cfset reportcolors = reportColorService.SELreportcolors()>