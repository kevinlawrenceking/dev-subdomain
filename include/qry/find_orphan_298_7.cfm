<cfset contactItemService = createObject("component", "services.ContactItemService")>
<cfset find_orphan = contactItemService.SELcontactitems_24329(userid=userid, tagname=left(y.tagname, 40))>