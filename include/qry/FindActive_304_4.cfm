<cfinclude template="/include/perfcount.cfm" />
<cfset systemUserService = request.svc("SystemUserService") />
<cfset FindActive = systemUserService.SELfusystemusers_24343(contactID=new_contactid) />