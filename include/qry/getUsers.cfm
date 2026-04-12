<cfinclude template="/include/perfcount.cfm" />
<cfset userService = createObject("component", "services.userService")>
<cfset users = userService.getUsers()>