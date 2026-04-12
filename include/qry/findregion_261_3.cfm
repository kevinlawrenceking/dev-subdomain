<cfinclude template="/include/perfcount.cfm" />
<cfset regionService = createObject("component", "services.RegionService")>
<cfset findregion = regionService.SELregions_24170(valueregion=details.valueregion)>