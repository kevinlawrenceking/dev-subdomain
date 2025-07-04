<cfset systemUserService = createObject("component", "services.SystemUserService")>
<cfset reldetails = systemUserService.getSystemUserByID(suid=suid)>