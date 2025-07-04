<cfset contactItemService = createObject("component", "services.ContactItemService")>
<cfset itemid = contactItemService.INScontactitems_24043(
    contactid = contactid,
    valuetype = trim(valuetype),
    valueCategory = valueCategory
)>