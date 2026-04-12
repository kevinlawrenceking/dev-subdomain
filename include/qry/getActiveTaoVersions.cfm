<cfinclude template="/include/perfcount.cfm" />
<cfset taoVersionService = createObject("component", "services.taoVersionService")>
<cfset activeVersions = taoVersionService.getActiveTaoVersions()>