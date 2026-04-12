<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset findscope = contactItemService.SELcontactitems_24761(contactid=contactid)>