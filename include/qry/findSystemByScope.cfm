<cfinclude template="/include/perfcount.cfm" />
<cfset systemService = createObject("component", "services.SystemService")>
<cfset systemid = systemUserService.findSystemByScope(systemscope=newsystemscope)>

 