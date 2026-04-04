<cfset eventService = request.svc("EventService")>
<cfset events = eventService.SELevents_24695(sessionUserID=userid, contactID=rcontactid)>