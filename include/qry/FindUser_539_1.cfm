<cfinclude template="/include/perfcount.cfm" />
<cfset userService = request.svc("UserService")>
<cfset FindUser = userService.SELtaousers_24760(userEmail=GetAuthUser())>