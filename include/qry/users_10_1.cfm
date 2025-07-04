<cfset userService = createObject("component", "services.UserService")>
<cfset users = userService.SELtaousers(ticketActive="Y")>