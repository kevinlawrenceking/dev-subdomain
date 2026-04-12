<cfinclude template="/include/perfcount.cfm" />
<cfset timezoneService = createObject("component", "services.TimeZoneService")>
<cfset timezones = timezoneService.SELtimezones()>