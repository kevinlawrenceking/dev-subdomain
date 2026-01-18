<cfparam name="url.userid" type="numeric" default="0">

<cfset userService = createObject("component", "services.UserService")>

<cfset Find = userService.GetUserDetails(userid=url.userid) />