<cfinclude template="/include/perfcount.cfm" />
<cfset eventService = request.svc("EventService")>
<cfset events = eventService.SELevents_24597(audroleid=audroleid, focusid=focusid)>