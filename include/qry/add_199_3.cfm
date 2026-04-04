<cfset contactItemService = request.svc("ContactItemService")>
<cfset itemid = contactItemService.INScontactitems_24043(
    contactid = contactid,
    valuetype = trim(valuetype),
    valueCategory = valueCategory
)>