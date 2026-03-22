<cfinclude template="/include/perfcount.cfm" />
<cfset systemUserService = createObject("component", "services.SystemUserService")>
<cfset checkformaint = systemUserService.SELfusystemusers(contactid=contactid, userid=userid)>