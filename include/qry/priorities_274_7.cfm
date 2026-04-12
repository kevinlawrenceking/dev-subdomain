<cfinclude template="/include/perfcount.cfm" />
<cfset ticketPriorityService = createObject("component", "services.TicketPriorityService")>
<cfset priorities = ticketPriorityService.SELticketpriority()>