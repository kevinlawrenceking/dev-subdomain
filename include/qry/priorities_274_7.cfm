<cfset ticketPriorityService = createObject("component", "services.TicketPriorityService")>
<cfset priorities = ticketPriorityService.SELticketpriority()>