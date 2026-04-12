<cfinclude template="/include/perfcount.cfm" />
<cfset objContactItemService = request.svc("ContactItemService")>
<cfset objContactItemService.UPDcontactitems(new_itemid=new_itemid)>