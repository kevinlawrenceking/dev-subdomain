<cfinclude template="/include/perfcount.cfm" />
<cfset eventService = request.svc("EventService") />
<cfset callback_check = eventService.SELevents_23785(audroleid=audroleid) />