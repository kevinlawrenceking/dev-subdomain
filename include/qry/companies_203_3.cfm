<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset companies = contactItemService.SELcontactitems_24064(userid=userid)>