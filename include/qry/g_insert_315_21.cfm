<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset contactItemService.INScontactitems_24414(
    contactid = g.contactid,
    work_phone = g.work_phone
)>