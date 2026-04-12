<cfinclude template="/include/perfcount.cfm" />
<cfset systemUserService = request.svc("SystemUserService")>
<cfset k = systemUserService.SELfusystemusers_24031(userid=#userid#)>