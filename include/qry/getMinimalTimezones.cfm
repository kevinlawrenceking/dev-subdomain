<cfinclude template="/include/perfcount.cfm" />
<cfset timeZoneService = createObject("component", "services.TimeZoneService")>
<cfset timezones_min = timeZoneService.SELtimezones_24770()>