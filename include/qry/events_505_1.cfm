<cfset eventService = createObject("component", "services.EventService")>
<cfset events = eventService.SELevents_24695(sessionUserID=userid, contactID=rcontactid)>