<cfinclude template="/include/perfcount.cfm" />
<cfset userService = request.svc("UserService")>
<cfset Details = userService.GetUserDetails(userid=userid)>

