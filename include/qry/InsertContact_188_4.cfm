<cfset userService = request.svc("UserService")>
<cfset userService.UPDtaousers_24001(new_contactid=new_contactid, userid=userid)>
<cfset session.bustUserCache = true>