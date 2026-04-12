<cfinclude template="/include/perfcount.cfm" />
<cfset eventService = request.svc("EventService")>
<cfset events = eventService.SELevents_24546(audroleid=audroleid)>


<cfset current_queryResult = events />
<cfinclude template="/include/debugLog.cfm">