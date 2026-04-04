<cfinclude template="/include/perfcount.cfm" />
<cfset systemUserService = request.svc("SystemUserService")>
<cfset checkformaint = systemUserService.SELfusystemusers(contactid=contactid, userid=userid)>