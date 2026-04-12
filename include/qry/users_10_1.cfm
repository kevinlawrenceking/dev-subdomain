<cfinclude template="/include/perfcount.cfm" />
<cfset userService = request.svc("UserService")>
<cfset users = userService.SELtaousers(ticketActive="Y")>