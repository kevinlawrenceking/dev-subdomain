<cfset contactItemService = createObject("component", "services.ContactItemService")>
<cfset findSame = contactItemService.SELcontactitems_24347(
    new_contactid = new_contactid,
    new_tagname = new_tagname
)>