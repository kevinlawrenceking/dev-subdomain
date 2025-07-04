<cfset contactItemService = createObject("component", "services.ContactItemService")>
<cfset contactItemService.INScontactitems_23955(
    contactID = currentid,
    valueTypeDef = categories.valueTypeDef,
    valuecategory = categories.valuecategory
)>