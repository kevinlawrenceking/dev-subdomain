<cfset eventService = createObject("component", "services.EventService")>
<cfset events = eventService.SELevents_24546(audroleid=audroleid)>


<cfset current_queryResult = events />
<cfinclude template="/include/debugLog.cfm">