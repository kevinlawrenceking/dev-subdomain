<cfinclude template="/include/perfcount.cfm" />
<cfset systemUserService = request.svc("SystemUserService") />
<cfset updatedRecordCount = systemUserService.UPDfusystemusers_24345(new_contactid=new_contactid) />
