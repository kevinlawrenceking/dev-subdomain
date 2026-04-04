<cfset systemUserService = request.svc("SystemUserService")>
<cfset systemUserService.updateSystemUser(suid=newsuid, sustatus="Completed")>