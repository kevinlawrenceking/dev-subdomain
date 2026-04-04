<cfset userService = request.svc("UserService")>
<cfset userService.UPDtaousers_23989(accesstoken=accesstoken, refreshToken=refreshToken, userid=userid)>
<cfset session.bustUserCache = true>