<cfset contactItemService = request.svc("ContactItemService")>
<cfset contactItemService.INScontactitems_23955(
    contactID = currentid,
    valueTypeDef = categories.valueTypeDef,
    valuecategory = categories.valuecategory
)>