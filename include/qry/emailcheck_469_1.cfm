<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset emailcheck = contactItemService.SELcontactitems_24657(currentid=currentid)>