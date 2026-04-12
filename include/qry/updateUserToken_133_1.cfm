<cfinclude template="/include/perfcount.cfm" />
<cfset userService = request.svc("UserService")>
<cfset userService.UPDtaousers_23911(accessToken=authResult.access_token, userId=userid)>
<cfset session.bustUserCache = true>