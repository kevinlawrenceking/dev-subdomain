<cfinclude template="/include/perfcount.cfm" />
<cfset eventTypesService = createObject("component", "services.EventTypesService")>
<cfset xs = eventTypesService.SELeventtypes()>