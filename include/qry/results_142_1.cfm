<cfset contactItemService = createObject("component", "services.ContactItemService")>
<cfset results = contactItemService.getContactDetails(uploadid=uploadid)>