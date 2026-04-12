<cfinclude template="/include/perfcount.cfm" />
<cfset regionService = createObject("component", "services.RegionService")>
<cfset regions = regionService.GetRegions()>