<cfinclude template="/include/perfcount.cfm" />
<cfset essenceService = createObject("component", "services.EssenceService")>
<cfset details = essenceService.DETessences(essenceid=essenceid)>