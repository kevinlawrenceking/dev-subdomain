<cfinclude template="/include/perfcount.cfm" />
<cfset itemsService = request.svc("ContactItemService")>
<cfset items = itemsService.SELcontactitems_24671(contactID=contactid)>