<cfset contactItemService = request.svc("ContactItemService")>
<cfset results = contactItemService.getContactDetails(uploadid=uploadid)>