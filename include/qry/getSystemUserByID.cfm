<cfinclude template="/include/perfcount.cfm" />
<cfset systemUserService = request.svc("SystemUserService")>
<cfset reldetails = systemUserService.getSystemUserByID(suid=suid)>