<Cfif #isdefined('currentid')#>

<cfset eventService = createObject("component", "services.EventService")>
<cfset events = eventService.SELevents_24659(sessionUserID=userid, currentID=currentid)>

<cfelse>
<cfset eventService = createObject("component", "services.EventService")>
<cfset events = eventService.SELevents_24659(sessionUserID=userid)>

</cfif>