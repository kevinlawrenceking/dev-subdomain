<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset find_new_homePhone = contactItemService.SELcontactitems_23895(new_contactid=new_contactid)>