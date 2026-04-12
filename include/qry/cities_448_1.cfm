<cfinclude template="/include/perfcount.cfm" />
<cfset cityService = createObject("component", "services.CityService")>
<cfset cities = cityService.SELcities()>