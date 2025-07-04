<cfset objTicketsLogTableService = createObject("component", "services.TicketsLogTableService")>
<cfset objTicketsLogTableService.INSticketslog(
    new_tlogDetails = new_tlogDetails,
    new_ticketid = new_ticketid,
    new_ticketstatus = new_ticketstatus
)>