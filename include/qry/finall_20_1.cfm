<cfinclude template="/include/perfcount.cfm" />
<cfset eventContactsService = createObject("component", "services.EventContactsXRefService")>
<cfset finall = eventContactsService.SELeventcontactsxref_23738(eventId=eventresults.eventresults.eventid)>