<cfset eventService = createObject("component", "services.eventservice")>
<cfset eventresults = eventService.eventresults(userid=userid, currentid=currentid)>
