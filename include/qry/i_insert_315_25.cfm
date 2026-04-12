<cfinclude template="/include/perfcount.cfm" />
<cfset contactItemService = request.svc("ContactItemService")>
<cfset contactItemService.INScontactitems_24418(
    contactid = i.contactid,
    home_phone = i.home_phone
)>