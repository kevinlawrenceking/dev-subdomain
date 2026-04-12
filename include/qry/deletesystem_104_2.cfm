<cfinclude template="/include/perfcount.cfm" />
<cfset systemUserService = request.svc("SystemUserService")>
<cfset systemUserService.UPDfusystemusers_23865(idList=idlist, newSystemId=new_systemid)>