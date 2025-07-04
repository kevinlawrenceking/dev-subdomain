<cfset systemUserService = createObject("component", "services.SystemUserService")>
<cfset systemUserService.updateSystemUser(suid=newsuid, sustatus="Completed")>