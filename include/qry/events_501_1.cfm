<cfset eventsService = request.svc("EventService")>
<cfset events = eventsService.SELevents_24686(sessionUserId=userid, contactId=rcontactid)>