<cfset eventsService = createObject("component", "services.EventService")>
<cfset events = eventsService.SELevents_24686(sessionUserId=userid, contactId=rcontactid)>