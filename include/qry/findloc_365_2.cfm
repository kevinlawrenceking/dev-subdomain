<cfinclude template="/include/perfcount.cfm" />
<cfset eventService = request.svc("EventService")>
<cfset findloc = eventService.SELevents_24527(new_eventid=new_eventid)>