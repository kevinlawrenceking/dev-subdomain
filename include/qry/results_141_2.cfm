<cfset contactItemService = request.svc("ContactItemService")>
<cfset results = contactItemService.REScontactitems(userid=userid, uploadid=uploadid)>