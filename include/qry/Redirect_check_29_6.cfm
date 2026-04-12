<cfinclude template="/include/perfcount.cfm" />
<cfset eventService = request.svc("EventService") />
<cfset Redirect_check = eventService.SELevents_23786(audroleid=audroleid) />