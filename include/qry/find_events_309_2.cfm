<cfinclude template="/include/perfcount.cfm" />
<cfset eventService = request.svc("EventService")>
<cfset find_events = eventService.SELevents_24379(
    eventtypename = linkdetails.eventtypename,
    userid = linkdetails.userid
)>