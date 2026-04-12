<cfinclude template="/include/perfcount.cfm" />
<cfset taoVersionService = createObject("component", "services.TaoVersionService")>
<cfset vers = taoVersionService.SELtaoversions_24215()>