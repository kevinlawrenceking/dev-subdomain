<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset find_new_BusinessEmail = contactItemService.SELcontactitems_23890(new_contactid=new_contactid)>