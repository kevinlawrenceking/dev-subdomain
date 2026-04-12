<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset find_new_WorkPhone = contactItemService.SELcontactitems_23893(new_contactid=new_contactid)>