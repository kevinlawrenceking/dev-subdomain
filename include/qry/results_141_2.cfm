<cfset contactItemService = createObject("component", "services.ContactItemService")>
<cfset results = contactItemService.REScontactitems(userid=userid, uploadid=uploadid)>