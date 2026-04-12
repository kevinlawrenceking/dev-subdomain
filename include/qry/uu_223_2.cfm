<cfinclude template="/include/perfcount.cfm" />
<cfset userService = request.svc("UserService")>
<cfset uu = userService.DETtaousers(userid=userid)>