<cfset eventService = createObject("component", "services.EventService")>
<cfset eventss = eventService.SELevents_24618(
    sessionUserId = userid,
    currentId = (isDefined('currentid') ? currentid : 0)
)>