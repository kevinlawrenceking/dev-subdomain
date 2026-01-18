<cfset userService = createObject("component", "services.userService")>
<cfset users = userService.getUsers()>