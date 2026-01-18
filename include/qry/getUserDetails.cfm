<cfset userService = createObject("component", "services.UserService")>
<cfset Details = userService.GetUserDetails(userid=userid)>

