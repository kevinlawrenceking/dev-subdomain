<cfinclude template="/include/perfcount.cfm" />
<cfparam name="url.userid" type="numeric" default="0">

<cfset userService = request.svc("UserService")>

<cfset Find = userService.GetUserDetails(userid=url.userid) />