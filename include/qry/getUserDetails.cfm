<cfset userService = request.svc("UserService")>
<cfset Details = userService.GetUserDetails(userid=userid)>

