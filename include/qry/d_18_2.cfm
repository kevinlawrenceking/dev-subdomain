<cfinclude template="/include/perfcount.cfm" />
<cfset eventService = createObject("component", "services.EventContactsXRefService")>
<cfset eventService.UPDeventcontactsxref(eventid=eventid)>