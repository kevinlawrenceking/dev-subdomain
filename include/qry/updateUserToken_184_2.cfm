<cfinclude template="/include/perfcount.cfm" />
<cfset userService = request.svc("UserService")>
<cfset userService.UPDtaousers_23990(accessToken=accessToken, userid=userid)>
<cfset session.bustUserCache = true>