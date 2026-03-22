<!--- This ColdFusion page initializes the LocationService and fetches countries and regions for use in the  --->
<cfinclude template="/include/perfcount.cfm" />
<cfset locationService = createObject("component", "services.LocationService")>

<!--- Fetch countries (cached) --->
<cfset countries = locationService.getCountries() />

<!--- Fetch regions --->
<cfset regions = locationService.getRegions() />
