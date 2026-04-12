<cfinclude template="/include/perfcount.cfm" />
<!--- This ColdFusion page fetches ticket details, statuses, types, priorities, active pages, users, and versions from various services. --->

<!--- Fetch ticket details using the Ticket_det function --->
<cfset ticketService = request.svc("TicketService")>
<cfset ticketDetails = ticketService.DETtickets(recid = recid)>

<!--- Fetch the ticket statuses using the SELticketstatuses function --->
<cfset ticketStatusService = createObject("component", "services.ticketStatusService")>
<cfset ticketStatuses = ticketStatusService.SELticketstatuses()>

<!--- Fetch the ticket types using the SELtickettypes function --->
<cfset ticketTypeService = createObject("component", "services.ticketTypeService")>
<cfset tickettypes = ticketTypeService.SELtickettypes()>

<!--- Fetch the ticket priorities --->
<cfset ticketPriorityService = createObject("component", "services.ticketPriorityService")>
<cfset ticketPriorities = ticketPriorityService.SELticketpriority()>

<!--- Fetch active pages using the pages_sel function from PageService --->
<cfset pageService = request.svc("PageService")>
<cfset activePages = pageService.pages_sel()>
<cfset pages = pageService.pages_sel()>

<!--- Fetch users using the users_sel function from UserService --->
<cfset userService = request.svc("UserService")>
<cfset users = userService.users_sel()>

<!--- Call the versions_sel function from VersionsService --->
<cfset taoVersionService = createObject("component", "services.taoVersionService")>
<cfset vers = taoVersionService.versions_sel()>
