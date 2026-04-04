<Cfif #isdefined('currentid')#>

<cfset eventService = request.svc("EventService")>
<cfset events = eventService.SELevents_24659(sessionUserID=userid, currentID=currentid)>

<cfelse>
<cfset eventService = request.svc("EventService")>
<cfset events = eventService.SELevents_24659(sessionUserID=userid)>

</cfif>