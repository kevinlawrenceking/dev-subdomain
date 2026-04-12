<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset itemDetails = contactItemService.DETcontactitems_23910(itemid=url.itemid)>