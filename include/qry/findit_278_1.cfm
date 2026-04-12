<cfinclude template="/include/perfcount.cfm" />
<cfset taoVersionService = createObject("component", "services.TaoVersionService")>
<cfset findit = taoVersionService.SELtaoversions()>