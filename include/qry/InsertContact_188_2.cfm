<cfinclude template="/include/perfcount.cfm" />
<cfset userService = request.svc("UserService")>
<cfset userService.UPDtaousers_23999(userFirstName=FindUser.userfirstname, userId=userid)>
<cfset session.bustUserCache = true>