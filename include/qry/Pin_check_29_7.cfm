<cfinclude template="/include/perfcount.cfm" />
<cfset eventService = request.svc("EventService")>
<cfset Pin_check = eventService.SELevents_23787(audroleid=audroleid)>