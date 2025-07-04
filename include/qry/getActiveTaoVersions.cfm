<cfset taoVersionService = createObject("component", "services.taoVersionService")>
<cfset activeVersions = taoVersionService.getActiveTaoVersions()>